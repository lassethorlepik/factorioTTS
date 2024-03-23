local voice_file = "voicedata.txt"
local settings_file = "settings.txt"
local cache_tag = "[#@CACHE@#]"
local flush_tag = "[#@FLUSH@#]"
local voice_tag_start = "[MODEL="

-- Basic TTS logging functionality

local function log_voice(text, player, cache_sound, position)
    local rest_text = text .. "\n"
    if cache_sound then
        rest_text = cache_tag .. rest_text
    end
    local formatted_string = string.format("(%.2f, %.2f)%s", position.x, position.y, rest_text)
    game.write_file(voice_file, formatted_string, true, player.index)
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
        if next_stop_record and train.station and next_stop_record.station then
            play_train_sound_for_players_in_range(train.station.backer_name, next_stop_record.station, train.front_stock)
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
            if player_settings["TTS_MOD_player_TTS"].value then
                if player.connected then  -- Check if the player is currently connected
                    distance = get_player_distance(game.players[player.index], game.players[event.player_index])
                    if distance then
                        if not player_settings["TTS_MOD_distance_limit_enabled"].value or distance <= player_settings["TTS_MOD_distance_limit"].value then
                            local listener = game.players[player.index].character.position
                            local speaker = game.players[event.player_index].character.position

                            -- Message starts with voice tag? Then don't include it automatically, this allows players to temporarily use a different voice using the voice tag
                            local start = string.sub(event.message, 1, string.len(voice_tag_start))
                            if start ~= voice_tag_start then
                                model = voice_tag_start .. settings.get_player_settings(event.player_index)["TTS_MOD_player_voice_model"].value .. "]"
                                final_message = model .. event.message
                            else
                                final_message = event.message
                            end
                            log_voice(final_message, player, false, getRelativePosition(listener, speaker)) -- Don't cache player messages as they are likely to be unique
                        end
                    end
                end
            end
        end
    end
end)

function play_train_sound_for_players_in_range(stop_name, next_stop_name, object)
    for _, player in pairs(game.players) do
        player_settings = settings.get_player_settings(player)
        if player.connected and settings.get_player_settings(player)["TTS_MOD_train_stop_voices"].value then  -- Check if the player is currently connected
            distance = get_player_object_distance(game.players[player.index], object)
            if distance and distance <= player_settings["TTS_MOD_distance_limit_trains"].value then
                text = stop_name .. player_settings["TTS_MOD_train_announcement_text"].value .. next_stop_name
                log_voice(text, player, true, getRelativePosition(player.character.position, object.position))
            end
        end
    end
end

function play_sound_for_players_in_range(text, object, global_sound)
    for _, player in pairs(game.players) do
        if player.connected then  -- Check if the player is currently connected
            if global_sound then
                log_voice(text, player, true, {x = 0.0, y = 0.0}) -- Audio is played directly to player
            else
                local distance = get_player_object_distance(player, object)
                if distance and distance <= 250 then
                    log_voice(text, player, true, getRelativePosition(player.character.position, object.position))
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
        if player.gui.screen["TTS_speaker_textbox_frame"] then
            global.TTS_speaker_interface_positions[player.index] = player.gui.screen["TTS_speaker_textbox_frame"].location
            player.gui.screen["TTS_speaker_textbox_frame"].destroy()
            if global.last_opened_speaker[player.index] == entity.unit_number then
                global.last_opened_speaker[player.index] = nil
                return
            end
        end
        if global.last_opened_speaker == nil then
            global.last_opened_speaker = {}
        end
        global.last_opened_speaker[player.index] = entity.unit_number
        -- Remove existing frame if it exists
        if player.gui.screen["TTS_speaker_textbox_frame"] then
            player.gui.screen["TTS_speaker_textbox_frame"].destroy()
        end

        -- Create a new frame that is draggable
        local frame = player.gui.screen.add{
            type = "frame",
            name = "TTS_speaker_textbox_frame",
            direction = "vertical",
            caption = {"TTS-GUI.announcement"},  -- Ensure this caption is not empty
            draggable = true,
        }

        -- It's often a good idea to place the frame inside a flow for better layout control
        local flow = frame.add{
            type = "flow",
            direction = "vertical",
            name = "flow"
        }

        -- Add a text field to the flow for input, preloaded with existing text
        local textbox = flow.add{
            type = "textfield",
            name = "TTS_speaker_textbox"
        }
        -- Load the existing text if available
        textbox.text = global.TTS_speaker_texts and global.TTS_speaker_texts[entity.unit_number] or ""

        textbox.style.minimal_width = 222

        -- Create a new horizontal flow within the existing vertical flow for the buttons
        local button_flow = flow.add{
            type = "flow",
            direction = "horizontal",
            name = "button_flow"
        }

        button_flow.add{
            type = "button",
            name = "TTS_speaker_textbox_submit",
            caption = {"TTS-GUI.set-text"}
        }

        button_flow.add{
            type = "button",
            name = "TTS_speaker_cancel",
            caption = {"TTS-GUI.cancel"}
        }
        
        if global.TTS_speaker_interface_positions[player.index] then
            frame.location = global.TTS_speaker_interface_positions[player.index]
        else
            -- Manually set the location of the frame to center it on the screen
            local resolution = player.display_resolution
            local scale = player.display_scale
            local frame_width = -200
            local frame_height = 250
            frame.location = {
                x = (resolution.width / scale - frame_width) / 2,
                y = (resolution.height / scale - frame_height) / 2
            }
        end
        -- Store the unit number in the frame for later reference
        frame.tags = { speaker_unit_number = entity.unit_number }
    end
end)


script.on_event(defines.events.on_gui_click, function(event)
    if event.element.name == "TTS_speaker_textbox_submit" then
        local frame = event.element.parent.parent.parent
        local textbox = frame.flow.TTS_speaker_textbox
        local text = textbox.text
        local unit_number = frame.tags.speaker_unit_number

        -- Store the text for this specific speaker
        global.TTS_speaker_texts[unit_number] = text
        -- Store the UI position for player
        local player_index = event.player_index
        global.TTS_speaker_interface_positions[player_index] = frame.location

        -- Close the GUI
        frame.destroy()
    else
        if event.element.name == "TTS_speaker_cancel" then
            local frame = event.element.parent.parent.parent
            local player_index = event.player_index
            global.TTS_speaker_interface_positions[player_index] = frame.location
            frame.destroy()
        end
    end
end)

global.TTS_SPEAKERS = global.TTS_SPEAKERS or {}

-- When a TTS speaker is built
script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity},
    function(event)
        local entity = event.created_entity
        if entity.name == "TTS-programmable-speaker" then
            table.insert(global.TTS_SPEAKERS, entity)
        end
    end
)

-- When a TTS speaker is removed
script.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity, defines.events.on_entity_died},
    function(event)
        local entity = event.entity
        if entity.name == "TTS-programmable-speaker" then
            for i, coop in ipairs(global.TTS_SPEAKERS) do
                if coop == entity then
                    table.remove(global.TTS_SPEAKERS, i)
                    break
                end
            end
        end
    end
)

script.on_init(function()
    global.TTS_SPEAKERS = {}
end)

script.on_configuration_changed(function()
    global.TTS_SPEAKERS = {}  -- Clear the existing cache
    for _, surface in pairs(game.surfaces) do  -- Iterate through all surfaces
        for _, entity in pairs(surface.find_entities_filtered{name = "TTS-programmable-speaker"}) do
            table.insert(global.TTS_SPEAKERS, entity)  -- Re-add valid entities to the cache
        end
    end
end)

script.on_event(defines.events.on_tick, function(event)
    -- Example: Check every 2 seconds to allow time for sound to play when looping
    if event.tick % 120 == 0 then
        for _, speaker in pairs(global.TTS_SPEAKERS) do
            if speaker.valid then
                local network = speaker.get_circuit_network(defines.wire_type.red) or speaker.get_circuit_network(defines.wire_type.green)
                -- Proceed only if the speaker is connected to a circuit network
                if network then
                    local info_signal = network.get_signal({type="virtual", name="signal-info"})
                    if info_signal and info_signal ~= 0 then
                        speaker_play(info_signal, speaker)
                        local control_behavior = speaker.get_control_behavior()
                        control_behavior.circuit_condition = {
                            condition = {
                                first_signal = {type = "virtual", name = "signal-info"},
                                constant = 0,
                                comparator = "!="
                            },
                        }
                    else
                        local green_signal = network.get_signal({type="virtual", name="signal-green"})
                        if green_signal and green_signal ~= 0 then
                            global.TTS_speaker_texts[speaker.unit_number] = global.TTS_speaker_texts[speaker.unit_number] or ""
                            speaker_play(global.TTS_speaker_texts[speaker.unit_number], speaker)
                            local control_behavior = speaker.get_control_behavior()
                            control_behavior.circuit_condition = {
                                condition = {
                                    first_signal = {type = "virtual", name = "signal-green"},
                                    constant = 0,
                                    comparator = "!="
                                }
                            }
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

script.on_init(function()
    global.TTS_speaker_interface_positions = global.TTS_speaker_interface_positions or {}
    global.TTS_speaker_texts = global.TTS_speaker_texts or {}
    global.last_opened_speaker = global.last_opened_speaker or {}
end)

script.on_configuration_changed(function()
    global.TTS_speaker_interface_positions = global.TTS_speaker_interface_positions or {}
    global.TTS_speaker_texts = global.TTS_speaker_texts or {}
    global.last_opened_speaker = global.last_opened_speaker or {}
end)

function getRelativePosition(playerPos, objectPos)
    maxDistance = 100

    -- Calculate the differences in positions
    local dx = objectPos.x - playerPos.x
    local dy = objectPos.y - playerPos.y
    
    -- Normalize the differences based on the maximum distance
    -- Use math.min and math.max to ensure the values are within the range [-1, 1]
    local normalized_dx = math.max(math.min(dx / maxDistance, 1), -1)
    local normalized_dy = math.max(math.min(dy / maxDistance, 1), -1)
    return {x = normalized_dx, y = normalized_dy}
end

script.on_event(defines.events.on_entity_settings_pasted, function(event)
    if event.source.name == "TTS-programmable-speaker" and event.destination.name == "TTS-programmable-speaker" then
        -- Apply the text from the source entity to the destination entity
        global.TTS_speaker_texts[event.destination.unit_number] = global.TTS_speaker_texts[event.source.unit_number]
    end
end)

-- When any mod setting is changed, this event is fired
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    apply_mod_settings()
end)

-- When the game configuration changes, such as when mods are added or updated
script.on_configuration_changed(onConfigChangedHandler)
local function onConfigChangedHandler(eventData)
    if eventData.mod_changes and eventData.mod_changes["Dynamic-voice-TTS"] then
        apply_mod_settings()
    end
end

-- When a player joins the game, useful if settings are player-specific
script.on_event(defines.events.on_player_joined_game, function(event)
    apply_mod_settings()
end)

function apply_mod_settings()
    base_string = "[VOICE]\n%s\n[RATE]\n%s\n[CHECK_DELAY]\n%s\n[STARTUP_MESSAGE]\n%s\n"
    for _, player in pairs(game.players) do
        player_settings = settings.get_player_settings(player)
        voice = player_settings["TTS_MOD_voice_model"].value
        rate = player_settings["TTS_MOD_voice_rate"].value
        delay = player_settings["TTS_MOD_check_delay"].value
        startup_message = player_settings["TTS_MOD_startup_message"].value
        settings_string = string.format(base_string, voice, rate, delay, startup_message)
        game.write_file(settings_file, settings_string, false, player.index)
        log_voice(flush_tag, player, false, {x = 0, y = 0}) -- Forces python script to flush cache
    end
end