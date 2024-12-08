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
-- 4 razy wiecej ukrytych tiles (6*4 przyjmijmy)
TILE_SIZE = 24
MAX_TILES_X = GAME_AREA_WIDTH / TILE_SIZE
MAX_TILES_Y = GAME_AREA_HEIGHT / TILE_SIZE
SMALL_TILE_SIZE = 6
MAX_SMALL_TILES_X = GAME_AREA_WIDTH / SMALL_TILE_SIZE
MAX_SMALL_TILES_Y = GAME_AREA_HEIGHT / SMALL_TILE_SIZE

-- SNAKE
-- SNAKE_SIZE = 6 <--- tyle powinno byc, ale problem z przechodzeniemdalej
SNAKE_SIZE = SMALL_TILE_SIZE
SNAKE_SPEED = 0.5
-- zaczynamy z lewego górnego rogu jeśli snakeX, snakeY = BORDER_X / SNAKE_SIZE, BORDER_Y / SNAKE_SIZE
SNAKE_STARTING_POS_X = BORDER_X / SNAKE_SIZE
SNAKE_STARTING_POS_Y = BORDER_Y / SNAKE_SIZE
local snakeX, snakeY = SNAKE_STARTING_POS_X, SNAKE_STARTING_POS_Y
local snakeTimer = 0

-- DIRECTIONS
UP = false
DOWN = false
LEFT = false
-- powinno być true, żeby zaczął się ruszać, teraz false do testów
RIGHT = false

local dirX = 1
local dirY = 0

-- TAIL, ETC.
local tailLength = 0

local function drawMinimap()
    -- minimap snake
    love.graphics.rectangle("fill", (snakeX / 1.5) - 21, (snakeY / 1.5) - 5, 6, 6)
    -- minimap
    -- powinno być lepiej dostosowane do wymiarów GAME_AREA
    love.graphics.setColor(1, 0, 1, 0.5)
    love.graphics.rectangle("line", 2, 2, TILE_SIZE * 4, TILE_SIZE * 3)
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
    -- love.graphics.setColor(1, 1, 1, 1)
    -- love.graphics.rectangle("line", BORDER_X, BORDER_Y, GAME_AREA_WIDTH, GAME_AREA_HEIGHT)

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
    snakeTimer = snakeTimer + dt
    if snakeTimer >= SNAKE_SPEED then
        if UP then
            if dirY ~= 1 then
                dirX, dirY = 0, -1
                snakeY = snakeY - 1
            else
                -- cannot go downwards if is up
            end
        elseif DOWN then
            if dirY ~= -1 then
                dirX, dirY = 0, 1
                snakeY = snakeY + 1
            else
            end
        elseif LEFT then
            if dirX ~= 1 then
                dirX, dirY = -1, 0
                snakeX = snakeX - 1
            else
                -- cannot go rightwards if is left
            end
        elseif RIGHT then
            if dirX ~= -1 then
                dirX, dirY = 1, 0
                snakeX = snakeX + 1
            else
            end
        else
            dirX, dirY = 0, 0
        end
        snakeX = snakeX + dirX * SNAKE_SPEED
        snakeY = snakeY + dirY * SNAKE_SPEED
        snakeTimer = 0
    end


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
    snakeX, snakeY = SNAKE_STARTING_POS_X, SNAKE_STARTING_POS_Y
    dirX, dirY = 0, 0
    -- tail = {}
    UP, DOWN, LEFT, RIGHT = false, false, false, true
    -- tail_length = 0
    STATE = GameStates.RUNNING
end

local prevUP, prevDOWN, prevLEFT, prevRIGHT = false, false, false, false

function game_pause()
    prevUP, prevDOWN, prevLEFT, prevRIGHT = UP, DOWN, LEFT, RIGHT
    UP, DOWN, LEFT, RIGHT = false, false, false, false
    STATE = GameStates.PAUSE
end

function game_unpause()
    UP, DOWN, LEFT, RIGHT = prevUP, prevDOWN, prevLEFT, prevRIGHT
    STATE = GameStates.RUNNING
end
