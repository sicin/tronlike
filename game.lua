local lume = require("reload.lume")

-- GAME STATES
GAME_STATE = { PAUSE = 'pause', RUNNING = 'running', GAME_OVER = 'game over' }
CURRENT_STATE = GAME_STATE.RUNNING

-- GAME AREA CONFIG
local WINDOW_WIDTH = 1280
local WINDOW_HEIGHT = 720
local GAME_AREA_WIDTH = 864
local GAME_AREA_HEIGHT = 576
local PADDING_X = (WINDOW_WIDTH - GAME_AREA_WIDTH) / 2
local PADDING_Y = (WINDOW_HEIGHT - GAME_AREA_HEIGHT) / 2

-- TILE SIZES
local TILE_SIZE = 24
local SMALL_TILE_SIZE = 6
local MAX_TILES_X = GAME_AREA_WIDTH / TILE_SIZE
local MAX_TILES_Y = GAME_AREA_HEIGHT / TILE_SIZE
local MAX_SMALL_TILES_X = GAME_AREA_WIDTH / SMALL_TILE_SIZE
local MAX_SMALL_TILES_Y = GAME_AREA_HEIGHT / SMALL_TILE_SIZE

-- MINIMAP CONFIG
local areaRatio = GAME_AREA_WIDTH / GAME_AREA_HEIGHT
local MINIMAP_X = 2
local MINIMAP_Y = 2
local MINIMAP_WIDTH = 96
local MINIMAP_HEIGHT = MINIMAP_WIDTH / areaRatio
local MINIMAP_SNAKE_SIZE = SMALL_TILE_SIZE / 2
local minimapScaleX = MINIMAP_WIDTH / GAME_AREA_WIDTH
local minimapScaleY = MINIMAP_HEIGHT / GAME_AREA_HEIGHT

-- SNAKE CONFIG
local SNAKE_SIZE = SMALL_TILE_SIZE
local SNAKE_SPEED = 0.02
-- Instead of starting at PADDING_X / SNAKE_SIZE, we start at 0,0 inside the game area.
local snakeX, snakeY = 0, 0
local snakeTimer = 0
local maxX = (GAME_AREA_WIDTH / SNAKE_SIZE) - 1
local maxY = (GAME_AREA_HEIGHT / SNAKE_SIZE) - 1

-- DIRECTIONS
local snakeDirX = 1 -- start moving right by default
local snakeDirY = 0

-- Drawing functions

local function drawMinimap()
    love.graphics.setColor(1, 1, 1, 0.5)
    -- Drawing the minimap outline
    love.graphics.rectangle("line", MINIMAP_X, MINIMAP_Y, MINIMAP_WIDTH + MINIMAP_SNAKE_SIZE,
        MINIMAP_HEIGHT + MINIMAP_SNAKE_SIZE)

    love.graphics.setColor(0, 1, 0, 0.8)
    -- Since snakeX, snakeY are now relative to the game area (0,0 at top-left),
    -- we can directly scale them:
    local snakeWorldX = snakeX * SNAKE_SIZE
    local snakeWorldY = snakeY * SNAKE_SIZE
    local minimapSnakeX = math.floor(MINIMAP_X + snakeWorldX * minimapScaleX)
    local minimapSnakeY = math.floor(MINIMAP_Y + snakeWorldY * minimapScaleY)

    -- Draw snake on minimap
    love.graphics.rectangle("fill", minimapSnakeX, minimapSnakeY, MINIMAP_SNAKE_SIZE, MINIMAP_SNAKE_SIZE)
end

local function drawSnake()
    love.graphics.setColor(0, 1, 0, 1)
    -- Add PADDING_X, PADDING_Y since snakeX, snakeY are now purely game-area coordinates
    love.graphics.rectangle("fill", PADDING_X + snakeX * SNAKE_SIZE, PADDING_Y + snakeY * SNAKE_SIZE, SNAKE_SIZE,
        SNAKE_SIZE)
end

local function drawGrid()
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.rectangle("line", PADDING_X, PADDING_Y, GAME_AREA_WIDTH, GAME_AREA_HEIGHT)

    love.graphics.setColor(1, 1, 1, 0.08)
    love.graphics.rectangle("fill", PADDING_X, PADDING_Y, GAME_AREA_WIDTH, GAME_AREA_HEIGHT)

    love.graphics.setColor(1, 1, 1, 0.10)
    for y = 1, MAX_TILES_Y do
        for x = 1, MAX_TILES_X do
            love.graphics.rectangle('line', (x - 1) * TILE_SIZE + PADDING_X, (y - 1) * TILE_SIZE + PADDING_Y, TILE_SIZE,
                TILE_SIZE)
        end
    end
end

local function drawSmallGrid()
    love.graphics.setColor(1, 1, 1, 0.1)
    for y = 1, MAX_SMALL_TILES_Y do
        for x = 1, MAX_SMALL_TILES_X do
            love.graphics.rectangle('line', (x - 1) * SMALL_TILE_SIZE + PADDING_X, (y - 1) * SMALL_TILE_SIZE + PADDING_Y,
                SMALL_TILE_SIZE, SMALL_TILE_SIZE)
        end
    end
end

-- Public Functions

function game_draw()
    drawGrid()
    -- drawSmallGrid()
    drawSnake()
    drawMinimap()
end

function game_update(dt)
    if CURRENT_STATE ~= GAME_STATE.RUNNING then
        driving:pause()
        return
    end

    driving:play()
    snakeTimer = snakeTimer + dt
    if snakeTimer >= SNAKE_SPEED then
        -- Move exactly one tile in the current direction
        snakeX = snakeX + snakeDirX
        snakeY = snakeY + snakeDirY

        -- Reset the timer
        snakeTimer = 0

        -- it might be too hard if this is outside of snake timer
        if snakeX < 0 or snakeX > maxX or snakeY < 0 or snakeY > maxY then
            if snakeX < 0 then
                -- even though snake head is outside, show as if it hit the wall
                snakeX = snakeX + 1
            end
            if snakeX > maxX then
                snakeX = snakeX - 1
            end
            if snakeY < 0 then
                snakeY = snakeY + 1
            end
            if snakeY > maxY then
                snakeY = snakeY - 1
            end
            CURRENT_STATE = GAME_STATE.GAME_OVER
            crash:play()
        end
    end
end

function game_restart()
    snakeX, snakeY = 0, 0       -- Restart snake at top-left of playable area
    snakeDirX, snakeDirY = 1, 0 -- start moving right by default
    CURRENT_STATE = GAME_STATE.RUNNING
end

function game_pause()
    CURRENT_STATE = GAME_STATE.PAUSE
end

function game_unpause()
    CURRENT_STATE = GAME_STATE.RUNNING
end

-- Called from main.lua when a direction key is pressed
function game_setDirection(dx, dy)
    -- Prevent reversing direction:
    if dx ~= 0 and snakeDirX == -dx then
        return
    end
    if dy ~= 0 and snakeDirY == -dy then
        return
    end

    snakeDirX, snakeDirY = dx, dy
end
