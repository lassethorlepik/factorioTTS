local voice_file = "voicedata.txt"
local start_tag = "<voiceTTS>"
local end_tag = "</voiceTTS>"

-- Basic TTS logging functionality

local function log_voice(text, player)
    game.write_file(voice_file, text .. "\n", true, player.index)
end

-- Train announcments

function on_train_starts(train)
    
end

function on_train_stops(train)
    -- Get the train's schedule
    local schedule = train.schedule
    if schedule and schedule.records and schedule.current then
        -- Determine the index of the next stop
        local next_stop_index = schedule.current + 1
        -- If the current stop is the last one, loop back to the first stop if the schedule loops
        if next_stop_index > #schedule.records then
            next_stop_index = 1
        end
        -- Get the next stop's record
        local next_stop_record = schedule.records[next_stop_index]
        if next_stop_record then
            play_train_sound_for_players_in_range(train.station.backer_name .. ". Next stop " .. next_stop_record.station, train.front_stock)
        end
    end
end

-- Event handler for when a train changes its state
script.on_event(defines.events.on_train_changed_state, function(event)
    local train = event.train
    if train.state == defines.train_state.wait_station then
        on_train_stops(train)
    else
        on_train_starts(train)
    end
end)

-- Other

-- Event handler for player messages
script.on_event(defines.events.on_console_chat, function(event)
    -- Check if the message was sent by a player
    if event.player_index then
        -- Print the text sent by the player
        for _, player in pairs(game.players) do
            player_settings = settings.get_player_settings(player)
            if player_settings["player_TTS"].value then
                if player.connected then  -- Check if the player is currently connected
                    distance = get_player_distance(game.players[player.index], game.players[event.player_index])
                    if distance then
                        if not player_settings["distance_limit_enabled"].value or distance <= player_settings["distance_limit"].value then
                            log_voice(event.message .. "\n", player)
                        end
                    end
                end
            end
        end
    end
end)

function play_train_sound_for_players_in_range(text, object)
    for _, player in pairs(game.players) do
        if player.connected and settings.get_player_settings(player)["train_stop_voices"].value then  -- Check if the player is currently connected
            distance = get_player_object_distance(game.players[player.index], object)
            if distance and distance <= 250 then
                log_voice(text .. "\n", player)
            end
        end
    end
end

function play_sound_for_players_in_range(text, object, global_sound)
    for _, player in pairs(game.players) do
        if player.connected then  -- Check if the player is currently connected
            if global_sound then
                log_voice(text .. "\n", player)
            else
                local distance = get_player_object_distance(player, object)
                if distance and distance <= 250 then
                    log_voice(text .. "\n", player)
                end
            end
        end
    end
end

-- Function to calculate the distance between two positions
function calculate_distance(pos1, pos2)
    return math.sqrt((pos1.x - pos2.x)^2 + (pos1.y - pos2.y)^2)
end

-- Function to get the distance between two players
function get_player_distance(player1, player2)
    -- Ensure both players exist and have a valid character
    if player1.character and player2.character then
        local pos1 = player1.character.position
        local pos2 = player2.character.position
        return calculate_distance(pos1, pos2)
    else
        return nil -- One or both players do not have a character
    end
end

-- Function to get the distance between two players
function get_player_object_distance(player1, object)
    if player1.character then
        local pos1 = player1.character.position
        local pos2 = object.position
        return calculate_distance(pos1, pos2)
    else
        return nil -- Player does not have a character
    end
end

script.on_event(defines.events.on_gui_opened, function(event)
    local entity = event.entity
    if entity and entity.name == "TTS-programmable-speaker" then
        local player = game.players[event.player_index]
        player.opened = nil

        -- Remove existing frame if it exists
        if player.gui.screen["TTS_speaker_textbox_frame"] then
            player.gui.screen["TTS_speaker_textbox_frame"].destroy()
        end

        -- Create a new frame that is draggable
        local frame = player.gui.center.add{
            type = "frame",
            name = "TTS_speaker_textbox_frame",
            direction = "vertical",
            caption = "TTS Announcement",  -- The caption is necessary for the frame to be draggable
            draggable = true,
        }

        -- Add a text field to the frame for input, preloaded with existing text
        local textbox = frame.add{
            type = "textfield",
            name = "TTS_speaker_textbox"
        }
        -- Load the existing text if available
        textbox.text = global.TTS_speaker_texts and global.TTS_speaker_texts[entity.unit_number] or ""

        -- Add a submit button to the frame
        frame.add{
            type = "button",
            name = "TTS_speaker_textbox_submit",
            caption = "Set Text"
        }

        -- Store the unit number in the frame for later reference
        frame.tags = { speaker_unit_number = entity.unit_number }
    end
end)



script.on_event(defines.events.on_gui_click, function(event)
    if event.element.name == "TTS_speaker_textbox_submit" then
        local frame = event.element.parent
        local textbox = frame.TTS_speaker_textbox
        local text = textbox.text
        local unit_number = frame.tags.speaker_unit_number

        -- Initialize the global storage if it doesn't exist
        if not global.TTS_speaker_texts then
            global.TTS_speaker_texts = {}
        end

        -- Store the text for this specific speaker
        global.TTS_speaker_texts[unit_number] = text

        -- Close the GUI
        frame.destroy()
    end
end)


script.on_event(defines.events.on_tick, function(event)
    -- Example: Check every 2 seconds to allow time for sound to play when looping
    if event.tick % 120 == 0 then
        for _, surface in pairs(game.surfaces) do
            for _, speaker in pairs(surface.find_entities_filtered{name="TTS-programmable-speaker"}) do
                -- Check if the speaker is connected to a circuit network
                if speaker.get_circuit_network(defines.wire_type.red) or speaker.get_circuit_network(defines.wire_type.green) then
                    local network = speaker.get_circuit_network(defines.wire_type.red) or speaker.get_circuit_network(defines.wire_type.green)
                    local green = network.get_signal({type="virtual", name="signal-green"})
                    -- If the signal is present and greater than 0, play the sound
                    local info = network.get_signal({type="virtual", name="signal-info"})
                    if info and info ~= 0 then
                        speaker_play(green, speaker)
                    else
                        if green and green ~= 0 then
                            -- Initialize the global storage if it doesn't exist
                            if not global.TTS_speaker_texts then
                                global.TTS_speaker_texts = {}
                            end
                            if global.TTS_speaker_texts[speaker.unit_number] == nil then
                                global.TTS_speaker_texts[speaker.unit_number] = ""
                            end
                            speaker_play(global.TTS_speaker_texts[speaker.unit_number], speaker)
                        end
                    end
                end
            end
        end
    end
end)


function speaker_play(text, speaker)
    play_sound_for_players_in_range(text, speaker, true)
end

