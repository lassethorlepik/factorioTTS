import hashlib
import time
import os
import threading
import sys
import pygame
import math
import re
import edge_tts
import asyncio
import shutil
from pathlib import Path

# CUSTOMIZE SETTINGS IN SETTINGS.TXT OR IN-GAME OPTIONS

PATTERN = r'\((-?\d+\.\d+),\s*(-?\d+\.\d+)\)(.*)'
CACHE_TAG = "[#@CACHE@#]"
CACHE_TAG_LENGTH = len(CACHE_TAG)
FLUSH_TAG = "[#@FLUSH@#]"
SCRIPT_OUTPUT = Path.cwd().parents[2] / "script-output"
VOICE_DATA_PATH = SCRIPT_OUTPUT / "voicedata.txt"
SETTINGS_PATH = SCRIPT_OUTPUT / "settings.txt"
CACHE_DIR = Path('cache')


def read_settings():
    """Read settings from the settings file and update global variables."""
    global voice, rate, check_delay, startup_message
    with open(SETTINGS_PATH, 'r') as f:
        lines = f.readlines()
    voice = lines[1].strip()
    rate = lines[3].strip()
    check_delay = float(lines[5].strip())
    startup_message = lines[7].strip()


async def save_generated_voice(text, filename) -> None:
    read_settings()
    print(voice)
    volume = "+0%"  # Default, no need to change, we play from mp3 and handle volume manually with greater control
    pitch = "+0Hz"  # Default
    communicate = edge_tts.Communicate(text, voice, rate=rate, volume=volume, pitch=pitch)
    await communicate.save(filename)


def generate_voice(text, filename):
    # This function will run in the new thread and ensure it has its own event loop
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    try:
        loop.run_until_complete(save_generated_voice(text, filename))
    finally:
        # Now it's safe to close the loop since we're done with async operations in this thread
        loop.close()


def process_text(text):
    stripped_text = text.strip()
    if FLUSH_TAG in stripped_text:
        clear_mp3_files_in_cache()
        return
    if stripped_text != "" and stripped_text != CACHE_TAG:  # ignore empty string requests
        print(text)

        # Generate a hash for the filename to avoid long names and weird characters
        hashed_text = hashlib.md5(stripped_text.encode('utf-8')).hexdigest()  # Technically non-zero chance of collision
        cached_filename = os.path.join(CACHE_DIR, f"{hashed_text}.mp3")

        # Find an available channel or use a new one if all are busy
        channel = pygame.mixer.find_channel()
        if channel is None:
            channel = pygame.mixer.Channel(pygame.mixer.get_num_channels())
            pygame.mixer.set_num_channels(pygame.mixer.get_num_channels() + 1)

        match = re.search(PATTERN, stripped_text)
        if match:
            x = float(match.group(1))
            y = float(match.group(2))
            string_to_read = match.group(3)
            if string_to_read == "":  # Ignore if sentence itself is empty
                return
            audio_play(cached_filename, string_to_read, channel, x, y)
        else:
            print("No coordinates found, ignoring spatial audio: " + stripped_text)
            audio_play(cached_filename, stripped_text, channel, 0, 0)


def audio_play(cached_filename, string_to_read, channel, x, y):
    # Check if the sound is not cached
    if not os.path.isfile(cached_filename):
        # Check if cache enabled for this string
        if string_to_read.startswith(CACHE_TAG):
            string_to_read = string_to_read[CACHE_TAG_LENGTH:]
            if string_to_read == "":  # Ignore if sentence itself is empty
                return
            generate_voice(string_to_read, cached_filename)
            sound = pygame.mixer.Sound(cached_filename)
        else:
            generate_voice(string_to_read, cached_filename)
            sound = pygame.mixer.Sound(cached_filename)
    else:
        sound = pygame.mixer.Sound(cached_filename)

    play_sound_based_on_location(sound, channel, x, y)
    # Start a new thread to monitor when the sound has finished playing
    playback_thread = threading.Thread(target=handle_playback_completion, args=(channel,))
    playback_thread.start()


def check_and_play_file_contents():
    """Check the file for contents, play it as sound, and clear the file."""
    try:
        # Check if the file has contents without changing the file modification time
        if os.path.getsize(VOICE_DATA_PATH) > 0:
            with open(VOICE_DATA_PATH, 'r+', encoding='utf-8') as file:
                # Remove the first line from the file
                lines = file.readlines()
                line = lines[:1]  # Get the oldest line
                lines = lines[1:]  # Remove the first line
                with open(VOICE_DATA_PATH, 'w') as voice_data_file:
                    voice_data_file.writelines(lines)
                if line:
                    # Play the text as sound
                    t1 = threading.Thread(target=process_text, args=(line[0],))
                    t1.start()
    except FileNotFoundError:
        print(f"ERROR: The file {VOICE_DATA_PATH} was not found.")


def monitor_loop():
    if startup_message.lower() == "true":
        process_text("(0.0, 0.0)Monitor started! Program will now play sounds from the factorio mod.\n")
    last_checked = 0
    while True:
        # Get the last modification time of the file
        try:
            mod_time = os.path.getmtime(VOICE_DATA_PATH)
        except FileNotFoundError:
            mod_time = 0
            print("ERROR: File not found!")

        # If the file has been modified since last checked, process the file
        if mod_time > last_checked:
            check_and_play_file_contents()
            last_checked = mod_time

        # Wait for a short period before checking again
        time.sleep(check_delay / 1000)


def typing(text):  # unused
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
def handle_playback_completion(channel):
    while channel.get_busy():
        pygame.time.wait(100)  # Wait for 100 milliseconds before checking again


def clear_mp3_files_in_cache():
    """Clear old mp3 file cache."""
    print("Clearing cache...")
    for file in CACHE_DIR.glob('*.mp3'):
        try:
            file.unlink()
            print(f"Removed cached file: {file}")
        except Exception as e:
            print(f"Failed to remove {file}: {e}")


def play_sound_based_on_location(sound, channel, x, y):
    x = max(min(x, 1), -1)
    y = max(min(y, 1), -1)
    left_volume = 1 - max(x, 0)
    right_volume = 1 - max(-x, 0)

    dist = math.sqrt(x ** 2 + y ** 2)
    dist = max(0.0, min(dist, 1.0))
    volume = 1 - dist

    channel.set_volume(left_volume * volume, right_volume * volume)
    channel.play(sound)


def check_settings():
    """Ensure settings file exists and has default settings"""
    if not os.path.exists(SETTINGS_PATH):
        print("Settings not found, copying defaults...")
        shutil.copy("default_settings.txt", SETTINGS_PATH)


def initialize_cache():
    """Ensure the cache directory exists and is cleared."""
    CACHE_DIR.mkdir(exist_ok=True)
    clear_mp3_files_in_cache()


if __name__ == "__main__":
    initialize_cache()
    check_settings()
    voice, rate, check_delay, startup_message = None, None, None, None
    read_settings()
    VOICE_DATA_PATH.write_text('') # Clear the file to ensure nothing carries over from the last session
    pygame.mixer.init() # Start pygame mixer to play sounds
    available_channels = list(range(pygame.mixer.get_num_channels()))
    monitor_loop()
