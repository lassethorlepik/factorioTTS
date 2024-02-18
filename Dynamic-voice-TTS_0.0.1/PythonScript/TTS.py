import time
import os
import threading
import sys
import pygame
import io
from gtts import gTTS

# CUSTOMIZE SETTINGS:

# How often the program checks for new texts to play, lower values offer better latency but have higher performance cost.
check_delay = 0.1 # seconds
# Voice language
language = 'en' # check gTTS for available options

# --------------------------------------

def play_text_as_sound(text):
    if text.strip():
        print(text)
        # Generate speech
        tts = gTTS(text=text.strip(), lang=language)
        mp3_fp = io.BytesIO()
        tts.write_to_fp(mp3_fp)
        mp3_fp.seek(0)  # Go to the beginning of the in-memory file
        sound = pygame.mixer.Sound(mp3_fp)

        # Find an available channel or use a new one if all are busy
        channel = pygame.mixer.find_channel()
        if channel is None:
            channel = pygame.mixer.Channel(pygame.mixer.get_num_channels())
            pygame.mixer.set_num_channels(pygame.mixer.get_num_channels() + 1)

        # Play the sound
        channel.play(sound)

        # Start a new thread to monitor when the sound has finished playing
        playback_thread = threading.Thread(target=handle_playback_completion, args=(channel, text, on_playback_complete))
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
    play_text_as_sound("Monitor started! Program will now play sounds from factorio mod.\n")
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


if __name__ == "__main__":
    # Path to the file you want to monitor
    file_path = os.path.join(os.path.abspath(os.path.join(os.getcwd(), *[os.pardir]*3)), "script-output", "voicedata.txt")
    with open(file_path, 'w'):
        pass
    pygame.mixer.init()
    # Initialize a list to track available channels
    available_channels = list(range(pygame.mixer.get_num_channels()))
    dynamic_texts = []
    monitor_loop()