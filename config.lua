-- Configuration and Constants

-- Sprite dimensions
SPRITE_WIDTH = 1189
SPRITE_HEIGHT = 381
SPRITE2_WIDTH = 477
SPRITE2_HEIGHT = 381
BUTTON_WIDTH = 432
BUTTON_HEIGHT = 435

-- Map boundaries
MAP_WIDTH = 5000 -- pixels
MAP_HEIGHT = 5000 -- pixels
CORNER_AVOIDANCE_RADIUS = 300 -- pixels - avoid getting within this distance of corners

-- Camera/Player settings
PLAYER_SPEED = 200 -- pixels per second
ACCELERATION = 800 -- pixels per second squared
DECELERATION = 1000 -- pixels per second squared
MAX_SPEED = 265 -- maximum speed in pixels per second
SPEED_BOOST_MULTIPLIER = 1.4 -- 40% increase when shift is held

-- Button movement settings
BUTTON_MOVE_SPEED = 140 -- pixels per second
BUTTON_FREAK_OUT_SPEED = 200 -- pixels per second when freaking out
BUTTON_HOVER_THRESHOLD = 0.5 -- seconds of hover before freaking out
BUTTON_MOVE_DISTANCE_MIN = 200 -- minimum movement distance
BUTTON_MOVE_DISTANCE_MAX = 500 -- maximum movement distance
BUTTON_ESCAPE_DISTANCE_MIN = 300 -- minimum escape distance
BUTTON_ESCAPE_DISTANCE_MAX = 500 -- maximum escape distance

-- Game settings
TIMER_DURATION = 15.0 -- seconds
BUTTON_DELAY = 1.0 -- seconds delay before buttons are clickable

-- Hit marker settings
HIT_MARKER_DURATION = 0.3 -- seconds to show hit marker
HIT_MARKER_SCALE = 0.07 -- scale for hit markers
HIT_SOUND_VOLUME = 0.55 -- 45% volume reduction (55% of original)

-- UI settings
FONT_SIZE = 23
CPS_FONT_SIZE = 53 -- 30px bigger than regular font
CURSOR_SCALE = 0.2 -- 20% of original size (80% smaller)
ARROW_SIZE = 40 -- Size of arrow indicator
EDGE_PADDING = 10 -- Padding from screen edge

-- Asset paths
ASSETS = {
    images = {
        ui = "assets/images/ui.png",
        cursor = "assets/images/clicker.png",
        arrow = "assets/images/arrow.png",
        hit = "assets/images/hit.png"
    },
    audio = {
        hit = "assets/audio/hit.wav"
    },
    fonts = {
        main = "assets/fonts/1up.ttf"
    }
}

