require('game')


function love.load()
    love.window.setPosition(500, 50, 1)
end

function love.draw()
    game_draw()

    if STATE == GameStates.pause then
        -- use font:getWidth later
        love.graphics.print("PAUSED", (love.graphics.getWidth() / 2) - 100, (love.graphics.getHeight() / 2) - 100, 0, 4,
            4)
    end
    if STATE == GameStates.game_over then
        love.graphics.print("LOST", 330, 350, 0, 4, 4)
    end
end

function love.update(dt)
    game_update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    if key == 'left' and STATE == GameStates.running then
        LEFT, RIGHT, UP, DOWN = true, false, false, false
    elseif key == 'right' and STATE == GameStates.running then
        LEFT, RIGHT, UP, DOWN = false, true, false, false
    elseif key == "up" and STATE == GameStates.running then
        LEFT, RIGHT, UP, DOWN = false, false, true, false
    elseif key == 'down' and STATE == GameStates.running then
        LEFT, RIGHT, UP, DOWN = false, false, false, true
    elseif key == 'space' then
        -- and STATE == GameStates.game_over
        game_restart()
    elseif key == 'p' then
        if STATE == GameStates.running then
            game_pause()
        else
            game_unpause()
        end
    end
end
