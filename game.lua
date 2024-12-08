lume = require("reload.lume")

-- game states
GameStates = { pause = 'pause', running = 'running', game_over = 'game over' }
STATE = GameStates.running

-- game area
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
GAME_AREA_WIDTH = 864
GAME_AREA_HEIGHT = 576
BORDER_X = (WINDOW_WIDTH - GAME_AREA_WIDTH) / 2
BORDER_Y = (WINDOW_HEIGHT - GAME_AREA_HEIGHT) / 2
-- 4 razy wiecej ukrytych tiles (6*4 przyjmijmy)
TILE_SIZE = 24
MAX_TILES_X = GAME_AREA_WIDTH / TILE_SIZE
MAX_TILES_Y = GAME_AREA_HEIGHT / TILE_SIZE

-- snake
-- SNAKE_SIZE = 6 <--- tyle powinno byc, ale problem z przechodzeniemdalej
SNAKE_SIZE = 6
SNAKE_SPEED = 0.5
-- zaczynamy z lewego górnego rogu jeśli snakeX, snakeY = BORDER_X / SNAKE_SIZE, BORDER_Y / SNAKE_SIZE
local snakeX, snakeY = BORDER_X / SNAKE_SIZE, BORDER_Y / SNAKE_SIZE

-- directions
UP = false
DOWN = false
LEFT = false
RIGHT = true
local dirX = 1
local dirY = 0

local tailLength = 0

local function drawMinimap()
    -- minimap
    -- musze zrozumiec co jest czym xd
    -- love.graphics.rectangle("fill", (snakeX) - 12, (snakeY / 2) - 6, 6, 6)
    -- love.graphics.rectangle("line", 0, 0, TILE_SIZE * 4, TILE_SIZE * 3)
end


local function drawSnake()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.rectangle("fill", snakeX * SNAKE_SIZE, snakeY * SNAKE_SIZE, SNAKE_SIZE, SNAKE_SIZE)
end

local function drawGrid()
    love.graphics.setColor(1, 0, 0, 0.3)
    love.graphics.rectangle("line", BORDER_X, BORDER_Y, GAME_AREA_WIDTH, GAME_AREA_HEIGHT)

    love.graphics.setColor(0, 0, 1, 0.3)
    for y = 1, MAX_TILES_Y do
        for x = 1, MAX_TILES_X do
            love.graphics.rectangle('line', (x - 1) * TILE_SIZE + BORDER_X, (y - 1) * TILE_SIZE + BORDER_Y, TILE_SIZE,
                TILE_SIZE)
        end
    end
end

function game_draw()
    drawGrid()
    drawSnake()
    drawMinimap()
end

function game_update(dt)
    love.graphics.print(dt, 0, 0)
    if UP then
        if dirY ~= 1 then
            dirX, dirY = 0, -1
        else
            -- cannot go downwards if is up
        end
    elseif DOWN then
        if dirY ~= -1 then
            dirX, dirY = 0, 1
        else
        end
    elseif LEFT then
        if dirX ~= 1 then
            dirX, dirY = -1, 0
        else
            -- cannot go rightwards if is left
        end
    elseif RIGHT then
        if dirX ~= -1 then
            dirX, dirY = 1, 0
        else
        end
    else
        dirX, dirY = 0, 0
    end
    snakeX = snakeX + dirX * SNAKE_SPEED
    snakeY = snakeY + dirY * SNAKE_SPEED

    -- for now go through to the other side
    -- if snakeX < 0 then
    --     snakeX = SNAKE_SIZE - 1
    -- elseif snakeX > (SNAKE_SIZE - 1) / SNAKE_SPEED then
    --     print("snakeX:", snakeX)
    --     snakeX = 0
    -- elseif snakeY < 0 then
    --     snakeY = SNAKE_SIZE - 1
    -- elseif snakeY > SNAKE_SIZE - 1 then
    --     print("snakeY:", snakeY)
    --     snakeY = 0
    -- end
end

function game_restart()
    snakeX, snakeY = 15, 15
    dirX, dirY = 0, 0
    -- tail = {}
    UP, DOWN, LEFT, RIGHT = false, false, false, true
    -- tail_length = 0
    STATE = GameStates.running
end

local prevUP, prevDOWN, prevLEFT, prevRIGHT = false, false, false, false

function game_pause()
    prevUP, prevDOWN, prevLEFT, prevRIGHT = UP, DOWN, LEFT, RIGHT
    UP, DOWN, LEFT, RIGHT = false, false, false, false
    STATE = GameStates.pause
end

function game_unpause()
    UP, DOWN, LEFT, RIGHT = prevUP, prevDOWN, prevLEFT, prevRIGHT
    STATE = GameStates.running
end
