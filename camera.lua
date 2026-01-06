-- Camera/Player Movement Module

local Camera = {}

-- Camera state
Camera.x = 0
Camera.y = 0
Camera.vel_x = 0
Camera.vel_y = 0

function Camera.init()
    -- Initialize camera to center of map
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    Camera.x = MAP_WIDTH / 2 - window_width / 2
    Camera.y = MAP_HEIGHT / 2 - window_height / 2
    -- Clamp to map boundaries
    Camera.x = math.max(0, math.min(MAP_WIDTH - window_width, Camera.x))
    Camera.y = math.max(0, math.min(MAP_HEIGHT - window_height, Camera.y))
end

function Camera.update(dt, paused)
    if paused then
        return
    end
    
    -- Player movement (WASD or Arrow keys)
    local input_x = 0
    local input_y = 0
    
    if love.keyboard.isDown("w", "up") then
        input_y = input_y - 1
    end
    if love.keyboard.isDown("s", "down") then
        input_y = input_y + 1
    end
    if love.keyboard.isDown("a", "left") then
        input_x = input_x - 1
    end
    if love.keyboard.isDown("d", "right") then
        input_x = input_x + 1
    end
    
    -- Normalize diagonal movement
    if input_x ~= 0 and input_y ~= 0 then
        input_x = input_x * 0.707 -- 1/sqrt(2)
        input_y = input_y * 0.707
    end
    
    -- Check if shift is held for speed boost
    local speed_multiplier = 1.0
    if love.keyboard.isDown("lshift", "rshift") then
        speed_multiplier = SPEED_BOOST_MULTIPLIER
    end
    
    -- Calculate target velocity based on input
    local target_vel_x = input_x * MAX_SPEED * speed_multiplier
    local target_vel_y = input_y * MAX_SPEED * speed_multiplier
    
    -- Apply acceleration or deceleration
    if input_x ~= 0 then
        -- Accelerate towards target velocity
        if Camera.vel_x < target_vel_x then
            Camera.vel_x = math.min(target_vel_x, Camera.vel_x + ACCELERATION * dt)
        elseif Camera.vel_x > target_vel_x then
            Camera.vel_x = math.max(target_vel_x, Camera.vel_x - ACCELERATION * dt)
        end
    else
        -- Decelerate when no input
        if Camera.vel_x > 0 then
            Camera.vel_x = math.max(0, Camera.vel_x - DECELERATION * dt)
        elseif Camera.vel_x < 0 then
            Camera.vel_x = math.min(0, Camera.vel_x + DECELERATION * dt)
        end
    end
    
    if input_y ~= 0 then
        -- Accelerate towards target velocity
        if Camera.vel_y < target_vel_y then
            Camera.vel_y = math.min(target_vel_y, Camera.vel_y + ACCELERATION * dt)
        elseif Camera.vel_y > target_vel_y then
            Camera.vel_y = math.max(target_vel_y, Camera.vel_y - ACCELERATION * dt)
        end
    else
        -- Decelerate when no input
        if Camera.vel_y > 0 then
            Camera.vel_y = math.max(0, Camera.vel_y - DECELERATION * dt)
        elseif Camera.vel_y < 0 then
            Camera.vel_y = math.min(0, Camera.vel_y + DECELERATION * dt)
        end
    end
    
    -- Stop very small velocities to prevent jitter
    if math.abs(Camera.vel_x) < 5 then
        Camera.vel_x = 0
    end
    if math.abs(Camera.vel_y) < 5 then
        Camera.vel_y = 0
    end
    
    -- Update camera position based on velocity
    Camera.x = Camera.x + Camera.vel_x * dt
    Camera.y = Camera.y + Camera.vel_y * dt
    
    -- Clamp camera position to map boundaries
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    Camera.x = math.max(0, math.min(MAP_WIDTH - window_width, Camera.x))
    Camera.y = math.max(0, math.min(MAP_HEIGHT - window_height, Camera.y))
    
    -- Stop velocity if at boundary to prevent bouncing
    if (Camera.x <= 0 and Camera.vel_x < 0) or (Camera.x >= MAP_WIDTH - window_width and Camera.vel_x > 0) then
        Camera.vel_x = 0
    end
    if (Camera.y <= 0 and Camera.vel_y < 0) or (Camera.y >= MAP_HEIGHT - window_height and Camera.vel_y > 0) then
        Camera.vel_y = 0
    end
end

function Camera.onResize(width, height)
    -- Ensure camera stays within map boundaries after resize
    Camera.x = math.max(0, math.min(MAP_WIDTH - width, Camera.x))
    Camera.y = math.max(0, math.min(MAP_HEIGHT - height, Camera.y))
end

return Camera

