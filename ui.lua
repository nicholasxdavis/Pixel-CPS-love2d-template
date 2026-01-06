-- UI Rendering Module

local UI = {}

-- UI assets
UI.ui_image = nil
UI.cursor_image = nil
UI.arrow_image = nil
UI.hit_image = nil
UI.font = nil
UI.cps_font = nil
UI.invert_shader = nil

-- UI quads
UI.player_idle = nil
UI.player_idle2 = nil
UI.red_button = nil
UI.red_button_pressed = nil

function UI.load()
    -- Load images
    UI.ui_image = love.graphics.newImage(ASSETS.images.ui)
    UI.cursor_image = love.graphics.newImage(ASSETS.images.cursor)
    UI.arrow_image = love.graphics.newImage(ASSETS.images.arrow)
    UI.hit_image = love.graphics.newImage(ASSETS.images.hit)
    
    -- Load fonts
    UI.font = love.graphics.newFont(ASSETS.fonts.main, FONT_SIZE)
    UI.cps_font = love.graphics.newFont(ASSETS.fonts.main, CPS_FONT_SIZE)
    
    -- Create invert shader
    UI.invert_shader = love.graphics.newShader([[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec4 pixel = Texel(texture, texture_coords);
            pixel.rgb = 1.0 - pixel.rgb;
            return pixel * color;
        }
    ]])
    
    -- Create quads
    UI.player_idle = love.graphics.newQuad(167, 81, SPRITE_WIDTH, SPRITE_HEIGHT, 2816, 1536)
    UI.player_idle2 = love.graphics.newQuad(1461, 82, SPRITE2_WIDTH, SPRITE2_HEIGHT, 2816, 1536)
    UI.red_button = love.graphics.newQuad(213, 543, BUTTON_WIDTH, BUTTON_HEIGHT, 2816, 1536)
    UI.red_button_pressed = love.graphics.newQuad(765, 543, BUTTON_WIDTH, BUTTON_HEIGHT, 2816, 1536)
end

function UI.getScale()
    local window_width = love.graphics.getWidth()
    local max_width = window_width - 40
    local scale_x = math.min(1.0, max_width / SPRITE_WIDTH)
    return scale_x * 0.5
end

function UI.drawButton(button_x, button_y, scale, pressed, freaking_out)
    local button_scaled_width = BUTTON_WIDTH * scale
    local button_scaled_height = BUTTON_HEIGHT * scale
    
    if pressed or freaking_out then
        love.graphics.draw(UI.ui_image, UI.red_button_pressed, button_x, button_y, 0, scale, scale)
    else
        love.graphics.draw(UI.ui_image, UI.red_button, button_x, button_y, 0, scale, scale)
    end
end

function UI.drawArrow(button_screen_x, button_screen_y, button_scaled_width, button_scaled_height, window_width, window_height)
    local button_center_x = button_screen_x + button_scaled_width / 2
    local button_center_y = button_screen_y + button_scaled_height / 2
    
    if button_center_x < 0 or button_center_x > window_width or
       button_center_y < 0 or button_center_y > window_height then
        local screen_center_x = window_width / 2
        local screen_center_y = window_height / 2
        local dx = button_center_x - screen_center_x
        local dy = button_center_y - screen_center_y
        local angle = math.atan2(dy, dx)
        
        local arrow_x, arrow_y
        local t_x, t_y
        
        if math.abs(dx) > math.abs(dy) then
            if dx > 0 then
                arrow_x = window_width - EDGE_PADDING - ARROW_SIZE / 2
                t_x = window_width
            else
                arrow_x = EDGE_PADDING + ARROW_SIZE / 2
                t_x = 0
            end
            t_y = screen_center_y + dy * (t_x - screen_center_x) / dx
            arrow_y = math.max(EDGE_PADDING + ARROW_SIZE / 2, 
                              math.min(window_height - EDGE_PADDING - ARROW_SIZE / 2, t_y))
        else
            if dy > 0 then
                arrow_y = window_height - EDGE_PADDING - ARROW_SIZE / 2
                t_y = window_height
            else
                arrow_y = EDGE_PADDING + ARROW_SIZE / 2
                t_y = 0
            end
            t_x = screen_center_x + dx * (t_y - screen_center_y) / dy
            arrow_x = math.max(EDGE_PADDING + ARROW_SIZE / 2, 
                              math.min(window_width - EDGE_PADDING - ARROW_SIZE / 2, t_x))
        end
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(UI.arrow_image, arrow_x, arrow_y, angle, 
                          ARROW_SIZE / UI.arrow_image:getWidth(), 
                          ARROW_SIZE / UI.arrow_image:getHeight(), 
                          UI.arrow_image:getWidth() / 2, 
                          UI.arrow_image:getHeight() / 2)
    end
end

function UI.drawHUD(time_remaining, cps, window_width)
    local padding = 10
    love.graphics.setFont(UI.font)
    
    -- Draw timer
    local minutes = math.floor(time_remaining / 60)
    local seconds = math.floor(time_remaining % 60)
    local timer_text = string.format("%d:%02d", minutes, seconds)
    local timer_text_width = UI.font:getWidth(timer_text)
    local timer_text_height = UI.font:getHeight()
    local timer_x = window_width - timer_text_width - padding
    local timer_y = padding
    
    if time_remaining < 4 then
        love.graphics.setColor(0.878, 0.208, 0.169) -- #e0352b red
    else
        love.graphics.setColor(1, 1, 1) -- White
    end
    love.graphics.print(timer_text, timer_x, timer_y)
    
    -- Draw CPS
    love.graphics.setColor(1, 1, 1)
    local cps_text = string.format("CPS: %d", cps)
    local cps_text_width = UI.font:getWidth(cps_text)
    local cps_x = window_width - cps_text_width - padding
    local cps_y = timer_y + timer_text_height + 5
    love.graphics.print(cps_text, cps_x, cps_y)
end

function UI.drawHitMarkers(hit_markers)
    love.graphics.setShader(UI.invert_shader)
    for _, marker in ipairs(hit_markers) do
        love.graphics.setColor(1, 1, 1, marker.alpha)
        love.graphics.draw(UI.hit_image, marker.x, marker.y, 0, HIT_MARKER_SCALE, HIT_MARKER_SCALE, 
                          UI.hit_image:getWidth() / 2, UI.hit_image:getHeight() / 2)
    end
    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1)
end

function UI.drawCursor()
    local mouse_x, mouse_y = love.mouse.getPosition()
    love.graphics.draw(UI.cursor_image, mouse_x, mouse_y, 0, CURSOR_SCALE, CURSOR_SCALE)
end

function UI.drawStartScreen(highscore, start_screen_timer, window_width, window_height)
    love.graphics.setColor(0, 0, 0, 1.0)
    love.graphics.rectangle("fill", 0, 0, window_width, window_height)
    
    local mouse_x, mouse_y = love.mouse.getPosition()
    
    -- Draw highscore
    love.graphics.setFont(UI.cps_font)
    local label_text = "Best score: "
    local number_text = tostring(highscore)
    local label_width = UI.cps_font:getWidth(label_text)
    local number_width = UI.cps_font:getWidth(number_text)
    local total_width = label_width + number_width
    local highscore_text_height = UI.cps_font:getHeight()
    local label_x = (window_width - total_width) / 2
    local number_x = label_x + label_width
    local highscore_y = (window_height - highscore_text_height) / 2
    
    love.graphics.setColor(1, 1, 1, 1.0)
    love.graphics.print(label_text, label_x, highscore_y)
    love.graphics.setColor(0.365, 0.745, 0.302, 1.0) -- #5dbe4d green
    love.graphics.print(number_text, number_x, highscore_y)
    
    -- Draw "Start Game"
    love.graphics.setFont(UI.font)
    local start_text = "Start Game"
    local start_text_width = UI.font:getWidth(start_text)
    local start_text_height = UI.font:getHeight()
    local start_x = (window_width - start_text_width) / 2
    local start_y = highscore_y + highscore_text_height + 10
    
    love.graphics.setColor(1, 1, 1, 1.0)
    love.graphics.print(start_text, start_x, start_y)
    
    -- Draw Yes/No buttons
    local yes_text = "Yes"
    local no_text = "No"
    local yes_width = UI.font:getWidth(yes_text)
    local no_width = UI.font:getWidth(no_text)
    local text_height = UI.font:getHeight()
    local button_spacing = 40
    local button_y = start_y + start_text_height + 30
    
    local total_width = yes_width + no_width + button_spacing
    local yes_x = (window_width - total_width) / 2
    local no_x = yes_x + yes_width + button_spacing
    
    local hovering_yes = start_screen_timer >= BUTTON_DELAY and
                         mouse_x >= yes_x and mouse_x <= yes_x + yes_width and
                         mouse_y >= button_y and mouse_y <= button_y + text_height
    local hovering_no = start_screen_timer >= BUTTON_DELAY and
                        mouse_x >= no_x and mouse_x <= no_x + no_width and
                        mouse_y >= button_y and mouse_y <= button_y + text_height
    
    if hovering_yes then
        love.graphics.setColor(0.878, 0.208, 0.169, 1.0)
    else
        love.graphics.setColor(1, 1, 1, 1.0)
    end
    love.graphics.print(yes_text, yes_x, button_y)
    
    if hovering_no then
        love.graphics.setColor(0.878, 0.208, 0.169, 1.0)
    else
        love.graphics.setColor(1, 1, 1, 1.0)
    end
    love.graphics.print(no_text, no_x, button_y)
end

function UI.drawRetryScreen(final_cps, show_exit_confirm, retry_fade_alpha, retry_screen_timer, window_width, window_height)
    love.graphics.setColor(0, 0, 0, retry_fade_alpha)
    love.graphics.rectangle("fill", 0, 0, window_width, window_height)
    
    local mouse_x, mouse_y = love.mouse.getPosition()
    
    -- Draw final CPS
    love.graphics.setFont(UI.cps_font)
    love.graphics.setColor(1, 1, 1, retry_fade_alpha)
    local cps_text = string.format("CPS: %d", final_cps)
    local cps_text_width = UI.cps_font:getWidth(cps_text)
    local cps_text_height = UI.cps_font:getHeight()
    local cps_x = (window_width - cps_text_width) / 2
    local cps_y = (window_height - cps_text_height) / 2
    
    love.graphics.print(cps_text, cps_x, cps_y)
    
    -- Draw main text
    love.graphics.setFont(UI.font)
    local main_text = show_exit_confirm and "Exit game?" or "Retry?"
    local main_text_width = UI.font:getWidth(main_text)
    local main_text_height = UI.font:getHeight()
    local main_x = (window_width - main_text_width) / 2
    local main_y = cps_y + cps_text_height + 10
    
    love.graphics.setColor(1, 1, 1, retry_fade_alpha)
    love.graphics.print(main_text, main_x, main_y)
    
    -- Draw Yes/No buttons
    local yes_text = "Yes"
    local no_text = "No"
    local yes_width = UI.font:getWidth(yes_text)
    local no_width = UI.font:getWidth(no_text)
    local text_height = UI.font:getHeight()
    local button_spacing = 40
    local button_y = main_y + main_text_height + 30
    
    local total_width = yes_width + no_width + button_spacing
    local yes_x = (window_width - total_width) / 2
    local no_x = yes_x + yes_width + button_spacing
    
    local hovering_yes = retry_screen_timer >= BUTTON_DELAY and
                         mouse_x >= yes_x and mouse_x <= yes_x + yes_width and
                         mouse_y >= button_y and mouse_y <= button_y + text_height
    local hovering_no = retry_screen_timer >= BUTTON_DELAY and
                        mouse_x >= no_x and mouse_x <= no_x + no_width and
                        mouse_y >= button_y and mouse_y <= button_y + text_height
    
    if hovering_yes then
        love.graphics.setColor(0.878, 0.208, 0.169, retry_fade_alpha)
    else
        love.graphics.setColor(1, 1, 1, retry_fade_alpha)
    end
    love.graphics.print(yes_text, yes_x, button_y)
    
    if hovering_no then
        love.graphics.setColor(0.878, 0.208, 0.169, retry_fade_alpha)
    else
        love.graphics.setColor(1, 1, 1, retry_fade_alpha)
    end
    love.graphics.print(no_text, no_x, button_y)
end

return UI

