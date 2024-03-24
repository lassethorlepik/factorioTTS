# Factorio TTS Mod

This mod integrates Text-To-Speech (TTS) into Factorio, providing an immersive auditory experience by voicing specific in-game events. Stereo audio is supported for all sounds - voice will come from a direction and have correct volume depending on the distance of the source. To use this mod, follow the setup instructions and keep the accompanying Python script running in the background while playing.
Following links include short clips showing basic functionality:

Train voice in action | Multiplayer chat in action
:-: | :-:
<video src='https://github.com/lassethorlepik/factorioTTS/assets/59596492/67b51e25-0491-460c-9c55-abfe9f4690ec' width=180/></video> | <video src='https://github.com/lassethorlepik/factorioTTS/assets/59596492/70c25cf1-fdcf-4daf-8fe4-3c3922784f8b' width=180/></video>

## Setup Instructions

1. Unpack the contents of the zip file into the `mods` folder of Factorio.
2. Navigate to `/PythonScript/` and run `launcher.py`. This script will set up a virtual environment, install necessary dependencies, and start the Python program.
3. Ensure you have an active internet connection as this mod utilizes Edge TTS for voicing text.

## Features

### Player Chat Text-To-Speech

- Player messages in chat are voiced through TTS.
- Each player can choose their own voice, that is heard by others in multiplayer.
- Proximity chat is enabled by default, allowing you to hear messages from players within a 250 tile radius.
- This feature can be toggled off if desired.

### Train Stop Announcements

- When a player is within 150 tiles of a train stop and a train arrives, the mod will announce the current and next stops.
- Announcement text can be customized.
- This feature can be disabled by each player.

### Custom Voices

- There are 314 supported voice models in different languages and genders.
- Swap models and all settings at runtime, no reloads necessary for both factorio and the python script.
- You can customize the speed and pitch of the voice.
- If any read text includes a tag with model name, for example: [MODEL=en-GB-RyanNeural], then it will override the used voice model for that text.

### TTS Speakers

- TTS speakers voice the text in their memory when they receive a green signal. Text can be edited by interacting with the speaker.
- If a TTS speaker receives an info signal, it will voice the number of the green signal.

## Dependencies

- An active internet connection for Edge TTS.
- Python installed, most likely version 3.6 and newer will work.
- Python environment set up through the provided `launcher.py` script.
- Factorio base game

## Usage

Keep the Python script running in the background while playing Factorio to enjoy real-time voice notifications of in-game events.
