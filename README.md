# Factorio TTS Mod

This mod integrates Text-To-Speech (TTS) into Factorio, providing an immersive auditory experience by voicing specific in-game events. To use this mod, follow the setup instructions and keep the accompanying Python script running in the background while playing.

## Setup Instructions

1. Unpack the contents of the zip file into the `mods` folder of Factorio.
2. Navigate to `/PythonScript/` and run `Start.bat`. This script will set up a virtual environment, install necessary dependencies, and start the Python program.
3. Ensure you have an active internet connection as this mod utilizes Google TTS for voicing text.

## Features

### Player Chat Text-To-Speech

- Player messages in chat are voiced through TTS.
- Proximity chat is enabled by default, allowing you to hear messages from players within a 10-1000 tile radius.
- This feature can be toggled off if desired.
- *Note:* Future updates aim to consider the spatial position of sound sources for an enhanced experience.

### Train Stop Announcements

- When a player is within 250 tiles of a train stop and a train arrives, the mod will announce the current and next stops.
- Announcement format: "`<current stop name>. Next stop <next stop name>.`"
- This feature can be disabled by each player.

### TTS Speakers

- TTS speakers voice the text in their memory when they receive a green signal. Text can be edited by interacting with the speaker.
- If a TTS speaker receives an info signal, it will voice the number of the green signal.

## Dependencies

- An active internet connection for Google TTS.
- Python environment set up through the provided `Start.bat` script.
- Factorio base game

## Usage

Keep the Python script running in the background while playing Factorio to enjoy real-time voice notifications of in-game events.

