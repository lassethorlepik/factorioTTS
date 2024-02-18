import hashlib
import time
import os
import io
import threading
import sys
import pygame
import math
import re
from decimal import Decimal
from gtts import gTTS

# CUSTOMIZE SETTINGS:

# How often the program checks for new texts to play, lower values offer better latency but have higher performance cost.
check_delay = 0.1 # seconds
# Voice language
language = 'en' # Check gTTS for available options
# Play "Monitor started" message at the start of the mod?
startup_message = True

# --------------------------------------

def play_text_as_sound(text):
    stripped_text = text.strip()
    if stripped_text != "" and stripped_text != cache_tag: # ignore empty string requests
        print(text)
        
        # Generate a hash for the filename to avoid long names and weird characters
        hashed_text = hashlib.md5(stripped_text.encode('utf-8')).hexdigest() # Technically non-zero chance of collision
        cached_filename = os.path.join(cache_dir, f"{hashed_text}.mp3")

        # Find an available channel or use a new one if all are busy
        channel = pygame.mixer.find_channel()
        if channel is None:
            channel = pygame.mixer.Channel(pygame.mixer.get_num_channels())
            pygame.mixer.set_num_channels(pygame.mixer.get_num_channels() + 1)

        match = re.search(pattern, stripped_text)
        if match:
            x = float(match.group(1))
            y = float(match.group(2))
            string_to_read = match.group(3)
            if string_to_read == "": # Ignore if sentence itself is empty
                return
            audio_process(cached_filename, string_to_read, channel, x, y)
        else:
            print("No coordinates found, ignoring spatial audio: " + stripped_text)
            audio_process(cached_filename, stripped_text, channel, 0, 0)

def audio_process(cached_filename, string_to_read, channel, x, y):
    # Check if the sound is not cached
    if not os.path.isfile(cached_filename):
        # Check if cache enabled for this string
        if string_to_read.startswith(cache_tag):
            string_to_read = string_to_read[cache_tag_length:]
            if string_to_read == "": # Ignore if sentence itself is empty
                return
            tts = gTTS(text=string_to_read, lang=language)
            # Save it in cache folder
            tts.save(cached_filename)
            sound = pygame.mixer.Sound(cached_filename)
        else:
            tts = gTTS(text=string_to_read, lang=language)
            # Hold it in memory
            mp3_fp = io.BytesIO()
            tts.write_to_fp(mp3_fp)
            mp3_fp.seek(0)  # Go to the beginning of the in-memory file
            sound = pygame.mixer.Sound(mp3_fp)
    else:
        sound = pygame.mixer.Sound(cached_filename)
        
    play_sound_based_on_location(sound, channel, x, y)
    # Start a new thread to monitor when the sound has finished playing
    playback_thread = threading.Thread(target=handle_playback_completion, args=(channel, string_to_read, on_playback_complete))
    playback_thread.start()


def check_and_play_file_contents():
    """Check the file for contents, play it as sound, and clear the file."""
    try:
        # Check if the file has contents without changing the file modification time
        if os.path.getsize(file_path) > 0:
            with open(file_path, 'r+', encoding='utf-8') as file:
                # Remove the first line from the file
                lines = file.readlines()
                line = lines[:1] # get oldest line
                lines = lines[1:]  # Remove the first line
                with open(file_path, 'w') as file:
                    file.writelines(lines)
                if line:
                    # Play the text as sound
                    t1 = threading.Thread(target=play_text_as_sound, args=(line[0],))
                    t1.start()
    except FileNotFoundError:
        print(f"ERROR: The file {file_path} was not found.")
        
def monitor_loop():
    if startup_message:
        play_text_as_sound("(0.0, 0.0)Monitor started! Program will now play sounds from the factorio mod.\n")
    last_checked = 0
    while True:
        # Get the last modification time of the file
        try:
            mod_time = os.path.getmtime(file_path)
        except FileNotFoundError:
            mod_time = 0
            print("ERROR: File not found!")

        # If the file has been modified since last checked, process the file
        if mod_time > last_checked:
            check_and_play_file_contents()
            last_checked = mod_time

        # Wait for a short period before checking again
        time.sleep(check_delay)

def typing(text):
    for char in text:
        time.sleep(0.04)
        sys.stdout.write(char)
        sys.stdout.flush()

def get_available_channel():
    if available_channels:
        return available_channels.pop(0)  # Remove and return the first available channel
    else:
        raise Exception("No available channels.")

# Function to handle the playback completion
def handle_playback_completion(channel, text, callback):
    while channel.get_busy():
        pygame.time.wait(100)  # Wait for 100 milliseconds before checking again
    callback(text)  # Call the callback function after playback is finished

# Callback function to be called after playback is finished
def on_playback_complete(text):
    pass
    # Any additional cleanup or post-playback logic can go here

def clear_mp3_files_in_cache():
    print("Clearing cache...")
    for filename in os.listdir(cache_dir):
        if filename.endswith('.mp3'):
            file_path = os.path.join(cache_dir, filename)
            try:
                os.remove(file_path)
                print(f"Removed: {file_path}")
            except Exception as e:
                print(f"Error removing {file_path}: {e}")

def play_sound_based_on_location(sound, channel, x, y):
    x = max(min(x, 1), -1)
    y = max(min(y, 1), -1)
    left_volume = 1 - max(x, 0)
    right_volume = 1 - max(-x, 0)
    
    dist = math.sqrt(x**2 + y**2)
    dist = max(0, min(dist, 1))
    volume = 1 - dist
    
    channel.set_volume(left_volume * volume, right_volume * volume)
    channel.play(sound)

if __name__ == "__main__":
    # Regular expression to extract coordinates
    pattern = r'\((-?\d+\.\d+),\s*(-?\d+\.\d+)\)(.*)'
    cache_tag = "[#@CACHE@#]" # Used to determine if voice should be cached
    cache_tag_length = len(cache_tag)
    # Ensure the cache directory exists
    cache_dir = 'cache'
    if not os.path.exists(cache_dir):
        os.makedirs(cache_dir)
    clear_mp3_files_in_cache()
    # Path to the file you want to monitor
    file_path = os.path.join(os.path.abspath(os.path.join(os.getcwd(), *[os.pardir]*3)), "script-output", "voicedata.txt")
    with open(file_path, 'w'): # Clear the file passing strings to ensure nothing carries over from last session
        pass
    pygame.mixer.init()
    # Initialize a list to track available channels
    available_channels = list(range(pygame.mixer.get_num_channels()))
    dynamic_texts = []
    monitor_loop()
