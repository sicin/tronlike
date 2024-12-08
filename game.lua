local lume = require("lib.reload.lume")

-- GAME STATES
GAME_STATE = { PAUSE = "pause", RUNNING = "running", GAME_OVER = "game over" }
CURRENT_STATE = GAME_STATE.RUNNING
-- needed to not hit itself when going one way and clicking the opposite key in combination with other direction
local directionChangedThisFrame = false
TURBO_ACTIVE = false

-- GAME AREA CONFIG
local WINDOW_WIDTH = 1280
local WINDOW_HEIGHT = 720
GAME_AREA_WIDTH = 864
GAME_AREA_HEIGHT = 576
PADDING_X = (WINDOW_WIDTH - GAME_AREA_WIDTH) / 2
PADDING_Y = (WINDOW_HEIGHT - GAME_AREA_HEIGHT) / 2

-- TURBO
local normalSpeed = 0.02    -- game runs on 60 fps, so everything over 0.017~0.018 will mean it runs every 2 frames
local turboStepDistance = 3 -- how much more distance per move during turbo
local turboDuration = 1.5   -- turbo lasts for 1.5 seconds
local turboCharges = 3
local turboTimeLeft = 0

-- SNAKE CONFIG
local SNAKE_SIZE = 6
local normalStepDistance = 1
local snakeSpeed = normalSpeed
local snakeTimer = 0
local maxX = (GAME_AREA_WIDTH / SNAKE_SIZE) - 1
local maxY = (GAME_AREA_HEIGHT / SNAKE_SIZE) - 1

-- GAME AREA GRID
local TILE_SIZE = 24
local MAX_TILES_X = GAME_AREA_WIDTH / TILE_SIZE
local MAX_TILES_Y = GAME_AREA_HEIGHT / TILE_SIZE

-- MINIMAP CONFIG
local areaRatio = GAME_AREA_WIDTH / GAME_AREA_HEIGHT
local MINIMAP_X = 2
local MINIMAP_Y = 2
local MINIMAP_WIDTH = 96
local MINIMAP_HEIGHT = MINIMAP_WIDTH / areaRatio
local MINIMAP_SNAKE_SIZE = SNAKE_SIZE * (MINIMAP_WIDTH / GAME_AREA_WIDTH)
local minimapScaleX = MINIMAP_WIDTH / GAME_AREA_WIDTH
local minimapScaleY = MINIMAP_HEIGHT / GAME_AREA_HEIGHT

-- STARTING POSITIONS
local STARTING_POSITIONS = {
    SHAPE_X = {
        { x = 30,        y = 30,        dirX = 1,  dirY = 0 }, -- Top-left, moving right
        { x = maxX - 30, y = 30,        dirX = -1, dirY = 0 }, -- Top-right, moving left
        { x = 30,        y = maxY - 30, dirX = 1,  dirY = 0 }, -- Bottom-left, moving right
        { x = maxX - 30, y = maxY - 30, dirX = -1, dirY = 0 }  -- Bottom-right, moving left
    },
    ["SHAPE_+"] = {
        { x = 20,                   y = math.floor(maxY / 2), dirX = 1,  dirY = 0 }, -- Left, moving right
        { x = math.floor(maxX / 2), y = 5,                    dirX = 0,  dirY = 1 }, -- Top, moving down
        { x = maxX - 20,            y = math.floor(maxY / 2), dirX = -1, dirY = 0 }, -- Right, moving left
        { x = math.floor(maxX / 2), y = maxY - 5,             dirX = 0,  dirY = -1 } -- Bottom, moving up
    }
}
local chosenPosition = STARTING_POSITIONS["SHAPE_X"][1]
local snakeX, snakeY, snakeDirX, snakeDirY =
    chosenPosition.x,
    chosenPosition.y,
    chosenPosition.dirX,
    chosenPosition.dirY

-- Snake trail
local snakeTrail = {}
local snakeTrailSet = {}

-- Helper function to get a key for snakeTrailSet
local function posKey(x, y)
    return x .. "," .. y
end

-- Initialize the snake trail with the starting position
snakeTrail[#snakeTrail + 1] = { x = snakeX, y = snakeY }
snakeTrailSet[posKey(snakeX, snakeY)] = true

local function drawMinimap()
    love.graphics.setColor(1, 1, 1, 0.5)
    -- Draw minimap boundary
    love.graphics.rectangle(
        "line",
        MINIMAP_X,
        MINIMAP_Y,
        MINIMAP_WIDTH + MINIMAP_SNAKE_SIZE,
        MINIMAP_HEIGHT + MINIMAP_SNAKE_SIZE
    )

    -- Loop over the snake trail
    love.graphics.setColor(0, 1, 0, 0.7)
    for i, segment in ipairs(snakeTrail) do
        local worldX = segment.x * SNAKE_SIZE
        local worldY = segment.y * SNAKE_SIZE
        local miniX = math.floor(MINIMAP_X + worldX * minimapScaleX)
        local miniY = math.floor(MINIMAP_Y + worldY * minimapScaleY)

        love.graphics.rectangle("fill", miniX, miniY, MINIMAP_SNAKE_SIZE, MINIMAP_SNAKE_SIZE)
    end
end

local function drawSnake()
    for i, segment in ipairs(snakeTrail) do
        if i == #snakeTrail then
            -- Draw the head
            love.graphics.setColor(0, 0, 1, 1)
            love.graphics.rectangle(
                "line",
                PADDING_X + segment.x * SNAKE_SIZE,
                PADDING_Y + segment.y * SNAKE_SIZE,
                SNAKE_SIZE,
                SNAKE_SIZE,
                10,
                10
            )
            love.graphics.setColor(0, 1, 0, 0.6)
            love.graphics.rectangle(
                "fill",
                PADDING_X + segment.x * SNAKE_SIZE,
                PADDING_Y + segment.y * SNAKE_SIZE,
                SNAKE_SIZE,
                SNAKE_SIZE
            )
        else
            -- Draw the body
            love.graphics.setColor(0, 1, 0, 0.8)
            love.graphics.rectangle(
                "fill",
                PADDING_X + segment.x * SNAKE_SIZE,
                PADDING_Y + segment.y * SNAKE_SIZE,
                SNAKE_SIZE,
                SNAKE_SIZE
            )
        end
    end
end

local function drawGrid()
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.rectangle("line", PADDING_X, PADDING_Y, GAME_AREA_WIDTH, GAME_AREA_HEIGHT)

    love.graphics.setColor(1, 1, 1, 0.08)
    love.graphics.rectangle("fill", PADDING_X, PADDING_Y, GAME_AREA_WIDTH, GAME_AREA_HEIGHT)

    love.graphics.setColor(1, 1, 1, 0.1)
    for y = 1, MAX_TILES_Y do
        for x = 1, MAX_TILES_X do
            love.graphics.rectangle(
                "line",
                (x - 1) * TILE_SIZE + PADDING_X,
                (y - 1) * TILE_SIZE + PADDING_Y,
                TILE_SIZE,
                TILE_SIZE
            )
        end
    end
end

-- Public Functions

function game_draw()
    drawGrid()
    drawSnake()
    drawMinimap()
end

function game_update(dt)
    if CURRENT_STATE ~= GAME_STATE.RUNNING then
        driving:pause()
        return
    end

    driving:play()

    if TURBO_ACTIVE then
        turboTimeLeft = turboTimeLeft - dt
        if turboTimeLeft <= 0 then
            TURBO_ACTIVE = false
        end
    end

    snakeTimer = snakeTimer + dt
    if snakeTimer >= snakeSpeed then
        -- Determine step distance based on turbo

        if TURBO_ACTIVE then
            normalStepDistance = turboStepDistance
        else
            normalStepDistance = 1
        end

        local newX = snakeX + snakeDirX * normalStepDistance
        local newY = snakeY + snakeDirY * normalStepDistance

        -- Check wall collision
        if newX < 0 or newX > maxX or newY < 0 or newY > maxY then
            CURRENT_STATE = GAME_STATE.GAME_OVER
            crash:play()
            return
        end

        -- Check if new position hits the trail
        local key = posKey(newX, newY)
        if snakeTrailSet[key] then
            -- Hit the trail
            CURRENT_STATE = GAME_STATE.GAME_OVER
            crash:play()
            return
        end

        -- Move the snake to the new position
        snakeX, snakeY = newX, newY
        snakeTrail[#snakeTrail + 1] = { x = snakeX, y = snakeY }
        snakeTrailSet[key] = true

        directionChangedThisFrame = false
        -- Reset the timer
        snakeTimer = 0
    end
end

function game_restart()
    snakeX, snakeY, snakeDirX, snakeDirY = chosenPosition.x, chosenPosition.y, chosenPosition.dirX, chosenPosition.dirY
    snakeSpeed = normalSpeed
    snakeTrail = {}
    snakeTrailSet = {}
    snakeTrail[#snakeTrail + 1] = { x = snakeX, y = snakeY }
    snakeTrailSet[posKey(snakeX, snakeY)] = true

    turboCharges = 3
    TURBO_ACTIVE = false

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
    if directionChangedThisFrame then
        return
    end

    -- Prevent reversing direction
    if dx ~= 0 and snakeDirX == -dx then
        return
    end
    if dy ~= 0 and snakeDirY == -dy then
        return
    end

    snakeDirX, snakeDirY = dx, dy
    directionChangedThisFrame = true
end

function activateTurbo()
    if turboCharges > 0 and not TURBO_ACTIVE then
        TURBO_ACTIVE = true
        turboTimeLeft = turboDuration
        turboCharges = turboCharges - 1
    end
end
