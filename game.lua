local lume = require("reload.lume")

-- GAME STATES
GameStates = { PAUSE = 'pause', RUNNING = 'running', GAME_OVER = 'game over' }
STATE = GameStates.RUNNING

-- GAME AREA
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
GAME_AREA_WIDTH = 864
GAME_AREA_HEIGHT = 576
BORDER_X = (WINDOW_WIDTH - GAME_AREA_WIDTH) / 2
BORDER_Y = (WINDOW_HEIGHT - GAME_AREA_HEIGHT) / 2
TILE_SIZE = 24
MAX_TILES_X = GAME_AREA_WIDTH / TILE_SIZE
MAX_TILES_Y = GAME_AREA_HEIGHT / TILE_SIZE

-- SMALL TILES GRID
SMALL_TILE_SIZE = 6
MAX_SMALL_TILES_X = GAME_AREA_WIDTH / SMALL_TILE_SIZE
MAX_SMALL_TILES_Y = GAME_AREA_HEIGHT / SMALL_TILE_SIZE

-- MINIMAP
local areaRatio = GAME_AREA_WIDTH / GAME_AREA_HEIGHT
local MINIMAP_X = 2
local MINIMAP_Y = 2
local MINIMAP_WIDTH = 96 -- for example
local MINIMAP_HEIGHT = MINIMAP_WIDTH / areaRatio

local minimapScaleX = MINIMAP_WIDTH / GAME_AREA_WIDTH
local minimapScaleY = MINIMAP_HEIGHT / GAME_AREA_HEIGHT

-- SNAKE
SNAKE_SIZE = SMALL_TILE_SIZE
SNAKE_SPEED = 0.02
SNAKE_STARTING_POS_X = BORDER_X / SNAKE_SIZE
SNAKE_STARTING_POS_Y = BORDER_Y / SNAKE_SIZE

local snakeX, snakeY = SNAKE_STARTING_POS_X, SNAKE_STARTING_POS_Y
local snakeTimer = 0

-- DIRECTIONS
local dirX = 1 -- start moving right by default
local dirY = 0

-- Drawing functions
local function drawMinimap()
    love.graphics.setColor(1, 0, 1, 0.5)
    love.graphics.rectangle("line", MINIMAP_X, MINIMAP_Y, MINIMAP_WIDTH, MINIMAP_HEIGHT)

    love.graphics.setColor(0, 1, 0, 1)
    local snakeWorldX = snakeX * SNAKE_SIZE
    local snakeWorldY = snakeY * SNAKE_SIZE
    local minimapSnakeX = (MINIMAP_X + snakeWorldX) * minimapScaleX
    local minimapSnakeY = (MINIMAP_Y + snakeWorldY) * minimapScaleY
    love.graphics.rectangle("fill", minimapSnakeX, minimapSnakeY, 3, 3)
end

local function drawSnake()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.rectangle("fill", snakeX * SNAKE_SIZE, snakeY * SNAKE_SIZE, SNAKE_SIZE, SNAKE_SIZE)
end

local function drawGrid()
    love.graphics.setColor(1, 0, 1, 1)
    love.graphics.rectangle("line", BORDER_X, BORDER_Y, GAME_AREA_WIDTH, GAME_AREA_HEIGHT)

    love.graphics.setColor(0, 0, 1, 0.5)
    for y = 1, MAX_TILES_Y do
        for x = 1, MAX_TILES_X do
            love.graphics.rectangle('line', (x - 1) * TILE_SIZE + BORDER_X, (y - 1) * TILE_SIZE + BORDER_Y, TILE_SIZE,
                TILE_SIZE)
        end
    end
end

local function drawSmallGrid()
    love.graphics.setColor(1, 1, 1, 0.1)
    for y = 1, MAX_SMALL_TILES_Y do
        for x = 1, MAX_SMALL_TILES_X do
            love.graphics.rectangle('line', (x - 1) * SMALL_TILE_SIZE + BORDER_X, (y - 1) * SMALL_TILE_SIZE + BORDER_Y,
                SMALL_TILE_SIZE, SMALL_TILE_SIZE)
        end
    end
end

function game_draw()
    drawGrid()
    drawSmallGrid()
    drawSnake()
    drawMinimap()
end

function game_update(dt)
    if STATE ~= GameStates.RUNNING then
        -- If the game is paused or over, do nothing
        return
    end

    snakeTimer = snakeTimer + dt
    if snakeTimer >= SNAKE_SPEED then
        -- Move exactly one tile in the current direction
        snakeX = snakeX + dirX
        snakeY = snakeY + dirY

        -- Reset the timer
        snakeTimer = 0
    end

    -- Wrap around logic (optional)
    -- Example: If you want the snake to wrap around the playing area
    -- local maxX = (GAME_AREA_WIDTH / SNAKE_SIZE) - 1
    -- local maxY = (GAME_AREA_HEIGHT / SNAKE_SIZE) - 1
    -- if snakeX < 0 then snakeX = maxX end
    -- if snakeX > maxX then snakeX = 0 end
    -- if snakeY < 0 then snakeY = maxY end
    -- if snakeY > maxY then snakeY = 0 end
end

function game_restart()
    snakeX, snakeY = SNAKE_STARTING_POS_X, SNAKE_STARTING_POS_Y
    dirX, dirY = 1, 0 -- start moving right by default
    STATE = GameStates.RUNNING
end

function game_pause()
    STATE = GameStates.PAUSE
end

function game_unpause()
    STATE = GameStates.RUNNING
end

-- This function will be called from main.lua when a direction key is pressed
function game_setDirection(dx, dy)
    -- Prevent reversing direction:
    if dx ~= 0 and dirX == -dx then
        return
    end
    if dy ~= 0 and dirY == -dy then
        return
    end

    dirX, dirY = dx, dy
end
