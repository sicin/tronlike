local SMALL_TILE_SIZE = 6 -- same as snake size
local MAX_SMALL_TILES_X = GAME_AREA_WIDTH / SMALL_TILE_SIZE
local MAX_SMALL_TILES_Y = GAME_AREA_HEIGHT / SMALL_TILE_SIZE

function drawSmallGrid()
    love.graphics.setColor(1, 1, 1, 0.1)
    for y = 1, MAX_SMALL_TILES_Y do
        for x = 1, MAX_SMALL_TILES_X do
            love.graphics.rectangle(
                "line",
                (x - 1) * SMALL_TILE_SIZE + PADDING_X,
                (y - 1) * SMALL_TILE_SIZE + PADDING_Y,
                SMALL_TILE_SIZE,
                SMALL_TILE_SIZE
            )
        end
    end
end
