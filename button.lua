-- Button Module

local Button = {}

-- Button state
Button.x = nil
Button.y = nil
Button.pressed = false
Button.moving = false
Button.freaking_out = false
Button.hover_timer = 0
Button.stationary_timer = 0
Button.target_x = nil
Button.target_y = nil
Button.move_timer = 0

-- Helper function to check if position is too close to corners
local function isTooCloseToCorner(x, y, button_width, button_height)
    local button_center_x = x + button_width / 2
    local button_center_y = y + button_height / 2
    
    local corners = {
        {0, 0},
        {MAP_WIDTH, 0},
        {0, MAP_HEIGHT},
        {MAP_WIDTH, MAP_HEIGHT}
    }
    
    for _, corner in ipairs(corners) do
        local dx = button_center_x - corner[1]
        local dy = button_center_y - corner[2]
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist < CORNER_AVOIDANCE_RADIUS then
            return true
        end
    end
    return false
end

-- Helper function to find a safe position away from corners
local function findSafePosition(start_x, start_y, button_width, button_height, max_attempts)
    max_attempts = max_attempts or 10
    for i = 1, max_attempts do
        local test_x = math.max(0, math.min(MAP_WIDTH - button_width, start_x + (math.random() - 0.5) * 800))
        local test_y = math.max(0, math.min(MAP_HEIGHT - button_height, start_y + (math.random() - 0.5) * 800))
        
        test_x = math.max(0, math.min(MAP_WIDTH - button_width, test_x))
        test_y = math.max(0, math.min(MAP_HEIGHT - button_height, test_y))
        
        if not isTooCloseToCorner(test_x, test_y, button_width, button_height) then
            return test_x, test_y
        end
    end
    return MAP_WIDTH / 2 - button_width / 2, MAP_HEIGHT / 2 - button_height / 2
end

function Button.init(scale)
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    local button_scaled_width = BUTTON_WIDTH * scale
    local button_scaled_height = BUTTON_HEIGHT * scale
    Button.x = MAP_WIDTH / 2 - button_scaled_width / 2
    Button.y = MAP_HEIGHT / 2 - button_scaled_height / 2
    Button.stationary_timer = 0.3 + math.random() * 0.7
end

function Button.update(dt, camera_x, camera_y, paused)
    if paused or Button.x == nil or Button.y == nil then
        return
    end
    
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    local max_width = window_width - 40
    local scale_x = math.min(1.0, max_width / SPRITE_WIDTH)
    local scale = scale_x * 0.5
    local button_scaled_width = BUTTON_WIDTH * scale
    local button_scaled_height = BUTTON_HEIGHT * scale
    
    -- Check if mouse is hovering over button
    local mouse_x, mouse_y = love.mouse.getPosition()
    local mouse_world_x = mouse_x + camera_x
    local mouse_world_y = mouse_y + camera_y
    
    local is_hovering = mouse_world_x >= Button.x and mouse_world_x <= Button.x + button_scaled_width and
                       mouse_world_y >= Button.y and mouse_world_y <= Button.y + button_scaled_height
    
    if is_hovering then
        Button.hover_timer = Button.hover_timer + dt
        if Button.hover_timer >= BUTTON_HOVER_THRESHOLD and not Button.freaking_out then
            -- Start freaking out
            Button.freaking_out = true
            Button.moving = true
            Button.move_timer = 1.2
            Button.pressed = false
            
            local dx = Button.x - mouse_world_x
            local dy = Button.y - mouse_world_y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance > 0 then
                local escape_distance = BUTTON_ESCAPE_DISTANCE_MIN + math.random() * (BUTTON_ESCAPE_DISTANCE_MAX - BUTTON_ESCAPE_DISTANCE_MIN)
                local perp_angle = math.atan2(dy, dx) + (math.random() > 0.5 and math.pi/2 or -math.pi/2)
                local perp_component = 0.3
                local direct_component = 1 - perp_component
                
                local temp_target_x = Button.x + (dx / distance) * escape_distance * direct_component + 
                                     math.cos(perp_angle) * escape_distance * perp_component
                local temp_target_y = Button.y + (dy / distance) * escape_distance * direct_component + 
                                     math.sin(perp_angle) * escape_distance * perp_component
                
                temp_target_x = math.max(0, math.min(MAP_WIDTH - button_scaled_width, temp_target_x))
                temp_target_y = math.max(0, math.min(MAP_HEIGHT - button_scaled_height, temp_target_y))
                
                if isTooCloseToCorner(temp_target_x, temp_target_y, button_scaled_width, button_scaled_height) then
                    Button.target_x, Button.target_y = findSafePosition(Button.x, Button.y, button_scaled_width, button_scaled_height)
                else
                    Button.target_x = temp_target_x
                    Button.target_y = temp_target_y
                end
            else
                local angle = math.random() * math.pi * 2
                local escape_distance = BUTTON_ESCAPE_DISTANCE_MIN + math.random() * (BUTTON_ESCAPE_DISTANCE_MAX - BUTTON_ESCAPE_DISTANCE_MIN)
                local temp_target_x = Button.x + math.cos(angle) * escape_distance
                local temp_target_y = Button.y + math.sin(angle) * escape_distance
                temp_target_x = math.max(0, math.min(MAP_WIDTH - button_scaled_width, temp_target_x))
                temp_target_y = math.max(0, math.min(MAP_HEIGHT - button_scaled_height, temp_target_y))
                
                if isTooCloseToCorner(temp_target_x, temp_target_y, button_scaled_width, button_scaled_height) then
                    Button.target_x, Button.target_y = findSafePosition(Button.x, Button.y, button_scaled_width, button_scaled_height)
                else
                    Button.target_x = temp_target_x
                    Button.target_y = temp_target_y
                end
            end
        end
    else
        Button.hover_timer = 0
        Button.pressed = false
        if Button.freaking_out and not Button.moving then
            Button.freaking_out = false
        end
    end
    
    if Button.moving then
        Button.pressed = false
        Button.move_timer = Button.move_timer - dt
        
        if Button.move_timer <= 0 then
            Button.moving = false
            if Button.freaking_out then
                Button.freaking_out = false
                Button.hover_timer = 0
                Button.stationary_timer = 0.3 + math.random() * 0.5
            else
                Button.stationary_timer = 0.3 + math.random() * 0.7
            end
        else
            local dx = Button.target_x - Button.x
            local dy = Button.target_y - Button.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance > 1 then
                local current_speed = Button.freaking_out and BUTTON_FREAK_OUT_SPEED or BUTTON_MOVE_SPEED
                local move_x = (dx / distance) * current_speed * dt
                local move_y = (dy / distance) * current_speed * dt
                
                Button.x = Button.x + move_x
                Button.y = Button.y + move_y
                
                Button.x = math.max(0, math.min(MAP_WIDTH - button_scaled_width, Button.x))
                Button.y = math.max(0, math.min(MAP_HEIGHT - button_scaled_height, Button.y))
                
                -- Corner avoidance during movement
                if isTooCloseToCorner(Button.x, Button.y, button_scaled_width, button_scaled_height) then
                    local button_center_x = Button.x + button_scaled_width / 2
                    local button_center_y = Button.y + button_scaled_height / 2
                    
                    local corners = {
                        {0, 0}, {MAP_WIDTH, 0}, {0, MAP_HEIGHT}, {MAP_WIDTH, MAP_HEIGHT}
                    }
                    
                    local nearest_corner = corners[1]
                    local min_dist = math.huge
                    for _, corner in ipairs(corners) do
                        local dx = button_center_x - corner[1]
                        local dy = button_center_y - corner[2]
                        local dist = math.sqrt(dx * dx + dy * dy)
                        if dist < min_dist then
                            min_dist = dist
                            nearest_corner = corner
                        end
                    end
                    
                    local dx = button_center_x - nearest_corner[1]
                    local dy = button_center_y - nearest_corner[2]
                    local dist = math.sqrt(dx * dx + dy * dy)
                    if dist > 0 then
                        local nudge_distance = (CORNER_AVOIDANCE_RADIUS - dist + 50) * dt * 100
                        Button.x = Button.x + (dx / dist) * nudge_distance
                        Button.y = Button.y + (dy / dist) * nudge_distance
                        Button.x = math.max(0, math.min(MAP_WIDTH - button_scaled_width, Button.x))
                        Button.y = math.max(0, math.min(MAP_HEIGHT - button_scaled_height, Button.y))
                    end
                end
            else
                Button.moving = false
                if Button.freaking_out then
                    Button.freaking_out = false
                    Button.hover_timer = 0
                    Button.stationary_timer = 0.3 + math.random() * 0.5
                else
                    Button.stationary_timer = 0.3 + math.random() * 0.7
                end
            end
        end
    else
        Button.stationary_timer = Button.stationary_timer - dt
        
        if Button.stationary_timer <= 0 then
            Button.moving = true
            Button.pressed = false
            Button.move_timer = 2.0 + math.random() * 2.0
            
            local angle = math.random() * math.pi * 2
            local distance = 400 + math.random() * 400
            
            local temp_target_x = Button.x + math.cos(angle) * distance
            local temp_target_y = Button.y + math.sin(angle) * distance
            
            temp_target_x = math.max(0, math.min(MAP_WIDTH - button_scaled_width, temp_target_x))
            temp_target_y = math.max(0, math.min(MAP_HEIGHT - button_scaled_height, temp_target_y))
            
            if isTooCloseToCorner(temp_target_x, temp_target_y, button_scaled_width, button_scaled_height) then
                Button.target_x, Button.target_y = findSafePosition(Button.x, Button.y, button_scaled_width, button_scaled_height)
            else
                Button.target_x = temp_target_x
                Button.target_y = temp_target_y
            end
        end
    end
end

function Button.checkClick(world_x, world_y, scale)
    local button_scaled_width = BUTTON_WIDTH * scale
    local button_scaled_height = BUTTON_HEIGHT * scale
    local hitbox_padding = (Button.pressed or Button.freaking_out) and 10 or 0
    local hitbox_x = Button.x - hitbox_padding
    local hitbox_y = Button.y - hitbox_padding
    local hitbox_width = button_scaled_width + hitbox_padding * 2
    local hitbox_height = button_scaled_height + hitbox_padding * 2
    
    return world_x >= hitbox_x and world_x <= hitbox_x + hitbox_width and
           world_y >= hitbox_y and world_y <= hitbox_y + hitbox_height
end

return Button

