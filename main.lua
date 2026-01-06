-- Pixel Click - Main Entry Point
-- LÖVE2D Game Template

-- Load configuration
require("config")

-- Load modules
local Camera = require("camera")
local Button = require("button")
local Game = require("game")
local UI = require("ui")

function love.load()
    -- Set window title
    love.window.setTitle("Pixel Click")
    
    -- Enable window resizing
    love.window.setMode(love.graphics.getWidth(), love.graphics.getHeight(), {
        resizable = true,
        minwidth = 800,
        minheight = 600
    })
    
    -- Hide default cursor
    love.mouse.setVisible(false)
    
    -- Initialize modules
    Camera.init()
    Game.load()
    UI.load()
    
    -- Initialize button when scale is available
    local scale = UI.getScale()
    Button.init(scale)
end

function love.update(dt)
    Game.update(dt)
    
    local paused = Game.isPaused()
    Camera.update(dt, paused)
    
    local scale = UI.getScale()
    Button.update(dt, Camera.x, Camera.y, paused)
end

function love.draw()
    love.graphics.clear(0, 0, 0)
    
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    local scale = UI.getScale()
    
    -- Draw game world
    if not Game.show_start_screen then
        love.graphics.push()
        love.graphics.translate(-Camera.x, -Camera.y)
        love.graphics.setColor(1, 1, 1)
        
        -- Draw button
        if Button.x and Button.y then
            UI.drawButton(Button.x, Button.y, scale, Button.pressed, Button.freaking_out)
        end
        
        love.graphics.pop()
        
        -- Draw arrow indicator
        if Button.x and Button.y then
            local button_screen_x = Button.x - Camera.x
            local button_screen_y = Button.y - Camera.y
            local button_scaled_width = BUTTON_WIDTH * scale
            local button_scaled_height = BUTTON_HEIGHT * scale
            UI.drawArrow(button_screen_x, button_screen_y, button_scaled_width, button_scaled_height, window_width, window_height)
        end
        
        -- Draw HUD
        UI.drawHUD(Game.time_remaining, Game.cps, window_width)
        
        -- Draw hit markers
        UI.drawHitMarkers(Game.hit_markers)
    end
    
    -- Draw start screen
    if Game.show_start_screen then
        UI.drawStartScreen(Game.highscore, Game.start_screen_timer, window_width, window_height)
    end
    
    -- Draw retry screen
    if Game.show_retry_screen and Game.retry_fade_alpha > 0 then
        UI.drawRetryScreen(Game.final_cps, Game.show_exit_confirm, Game.retry_fade_alpha, Game.retry_screen_timer, window_width, window_height)
    end
    
    -- Draw cursor
    UI.drawCursor()
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        -- Handle start screen
        if Game.show_start_screen then
            if Game.start_screen_timer < BUTTON_DELAY then
                return
            end
            
            local window_width = love.graphics.getWidth()
            local window_height = love.graphics.getHeight()
            love.graphics.setFont(UI.font)
            
            local yes_text = "Yes"
            local no_text = "No"
            local yes_width = UI.font:getWidth(yes_text)
            local no_width = UI.font:getWidth(no_text)
            local text_height = UI.font:getHeight()
            
            local highscore_text_height = UI.cps_font:getHeight()
            local highscore_y = (window_height - highscore_text_height) / 2
            local start_text_height = UI.font:getHeight()
            local start_y = highscore_y + highscore_text_height + 10
            
            local button_spacing = 40
            local total_width = yes_width + no_width + button_spacing
            local yes_x = (window_width - total_width) / 2
            local no_x = yes_x + yes_width + button_spacing
            local button_y = start_y + start_text_height + 30
            
            if x >= yes_x and x <= yes_x + yes_width and y >= button_y and y <= button_y + text_height then
                Game.show_start_screen = false
                return
            end
            
            if x >= no_x and x <= no_x + no_width and y >= button_y and y <= button_y + text_height then
                love.event.quit()
                return
            end
            return
        end
        
        -- Handle retry screen
        if Game.show_retry_screen then
            if Game.retry_screen_timer < BUTTON_DELAY then
                return
            end
            
            local window_width = love.graphics.getWidth()
            local window_height = love.graphics.getHeight()
            love.graphics.setFont(UI.font)
            
            local yes_text = "Yes"
            local no_text = "No"
            local yes_width = UI.font:getWidth(yes_text)
            local no_width = UI.font:getWidth(no_text)
            local text_height = UI.font:getHeight()
            
            local main_text = Game.show_exit_confirm and "Exit game?" or "Retry?"
            local cps_text_height = UI.cps_font:getHeight()
            local cps_y = (window_height - cps_text_height) / 2
            local main_y = cps_y + cps_text_height + 10
            
            local button_spacing = 40
            local total_width = yes_width + no_width + button_spacing
            local yes_x = (window_width - total_width) / 2
            local no_x = yes_x + yes_width + button_spacing
            local button_y = main_y + UI.font:getHeight() + 30
            
            if x >= yes_x and x <= yes_x + yes_width and y >= button_y and y <= button_y + text_height then
                if Game.show_exit_confirm then
                    love.event.quit()
                else
                    Game.retry()
                end
                return
            end
            
            if x >= no_x and x <= no_x + no_width and y >= button_y and y <= button_y + text_height then
                if Game.show_exit_confirm then
                    Game.show_exit_confirm = false
                else
                    Game.show_exit_confirm = true
                    Game.retry_screen_timer = 0.0
                end
                return
            end
            return
        end
        
        -- Handle game button click
        if Button.x and Button.y then
            local scale = UI.getScale()
            local mouse_world_x = x + Camera.x
            local mouse_world_y = y + Camera.y
            
            if Button.checkClick(mouse_world_x, mouse_world_y, scale) then
                Button.pressed = true
                Game.onClick()
            end
        end
    end
end

function love.mousereleased(x, y, button, istouch)
    if button == 1 then
        Button.pressed = false
    end
end

function love.keypressed(key, scancode, isrepeat)
    -- Window controls
    if key == "f11" or (key == "return" and love.keyboard.isDown("lalt", "ralt")) then
        local fullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not fullscreen)
    elseif key == "escape" and love.window.getFullscreen() then
        love.window.setFullscreen(false)
    end
end

function love.resize(width, height)
    Camera.onResize(width, height)
end

function love.quit()
    Game.saveHighscore()
end

