-- Game State Module

local Game = {}

-- Game state
Game.timer_active = false
Game.time_remaining = TIMER_DURATION
Game.click_times = {}
Game.cps = 0
Game.highest_cps_round = 0
Game.highscore = 0
Game.final_cps = 0

-- Hit markers
Game.hit_markers = {}
Game.hit_sound_data = nil

-- Retry screen state
Game.show_retry_screen = false
Game.retry_fade_alpha = 0.0
Game.retry_screen_timer = 0.0
Game.show_exit_confirm = false

-- Start screen state
Game.show_start_screen = true
Game.start_screen_timer = 0.0

function Game.load()
    -- Load highscore from save file
    local success, saved_highscore = pcall(function()
        if love.filesystem.getInfo("highscore.txt") then
            local contents = love.filesystem.read("highscore.txt")
            if contents then
                return tonumber(contents)
            end
        end
        return nil
    end)
    
    if success and saved_highscore then
        Game.highscore = saved_highscore
    end
    
    -- Load hit sound
    Game.hit_sound_data = love.sound.newSoundData(ASSETS.audio.hit)
end

function Game.saveHighscore()
    local success, err = pcall(function()
        love.filesystem.write("highscore.txt", tostring(Game.highscore))
    end)
    if not success then
        print("Failed to save highscore: " .. tostring(err))
    end
end

function Game.update(dt)
    -- Update timer if active
    if Game.timer_active then
        Game.time_remaining = Game.time_remaining - dt
        if Game.time_remaining <= 0 then
            Game.time_remaining = 0
            Game.timer_active = false
            Game.final_cps = Game.highest_cps_round
            if Game.highest_cps_round > Game.highscore then
                Game.highscore = Game.highest_cps_round
                Game.saveHighscore()
            end
            Game.show_retry_screen = true
            Game.retry_screen_timer = 0.0
        end
    end
    
    -- Update start screen timer
    if Game.show_start_screen then
        Game.start_screen_timer = Game.start_screen_timer + dt
    else
        Game.start_screen_timer = 0.0
    end
    
    -- Fade in retry screen
    if Game.show_retry_screen then
        Game.retry_fade_alpha = math.min(1.0, Game.retry_fade_alpha + dt * 2.0)
        Game.retry_screen_timer = Game.retry_screen_timer + dt
    else
        Game.retry_fade_alpha = 0.0
        Game.retry_screen_timer = 0.0
    end
    
    -- Update CPS counter
    local current_time = love.timer.getTime()
    for i = #Game.click_times, 1, -1 do
        if current_time - Game.click_times[i] > 1.0 then
            table.remove(Game.click_times, i)
        end
    end
    Game.cps = #Game.click_times
    
    -- Update highest CPS for current round
    if Game.timer_active and Game.cps > Game.highest_cps_round then
        Game.highest_cps_round = Game.cps
    end
    
    -- Update hit markers
    for i = #Game.hit_markers, 1, -1 do
        local marker = Game.hit_markers[i]
        marker.time_left = marker.time_left - dt
        
        if marker.time_left <= 0 then
            table.remove(Game.hit_markers, i)
        else
            marker.alpha = (marker.time_left / HIT_MARKER_DURATION) * (marker.max_alpha or 1.0)
        end
    end
end

function Game.onClick()
    -- Track click for CPS counter
    table.insert(Game.click_times, love.timer.getTime())
    
    -- Start timer on first button click
    if not Game.timer_active and Game.time_remaining == TIMER_DURATION then
        Game.timer_active = true
        Game.highest_cps_round = 0
    end
    
    -- Create hit marker
    local mouse_x, mouse_y = love.mouse.getPosition()
    local base_alpha = 0.98
    local random_variation = (math.random() - 0.5) * 0.04
    table.insert(Game.hit_markers, {
        x = mouse_x,
        y = mouse_y,
        time_left = HIT_MARKER_DURATION,
        alpha = math.max(0.96, math.min(1.0, base_alpha + random_variation)),
        max_alpha = math.max(0.96, math.min(1.0, base_alpha + random_variation))
    })
    
    -- Play hit sound
    local sound_instance = love.audio.newSource(Game.hit_sound_data)
    sound_instance:setVolume(HIT_SOUND_VOLUME)
    sound_instance:setLooping(false)
    sound_instance:play()
end

function Game.retry()
    Game.show_retry_screen = false
    Game.retry_fade_alpha = 0.0
    Game.retry_screen_timer = 0.0
    Game.show_exit_confirm = false
    Game.time_remaining = TIMER_DURATION
    Game.timer_active = false
    Game.highest_cps_round = 0
    Game.click_times = {}
    Game.cps = 0
end

function Game.isPaused()
    return Game.show_retry_screen or Game.show_start_screen
end

return Game

