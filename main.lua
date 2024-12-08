require('game')

function love.load()
    love.window.setPosition(500, 50, 1)
    placeholderImage = love.graphics.newImage("placeholder.png")
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.draw(placeholderImage, 0, 100)
    game_draw()

    if CURRENT_STATE == GAME_STATE.PAUSE then
        -- use font:getWidth later
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.print("PAUSED", (love.graphics.getWidth() / 2) - 100, (love.graphics.getHeight() / 2) - 100, 0, 4,
            4)
    end

    if CURRENT_STATE == GAME_STATE.GAME_OVER then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.print("LOST", 330, 350, 0, 4, 4)
    end
end

function love.update(dt)
    game_update(dt)
    require("reload.lurker").update()
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if CURRENT_STATE == GAME_STATE.RUNNING then
        if key == 'left' then
            game_setDirection(-1, 0)
        elseif key == 'right' then
            game_setDirection(1, 0)
        elseif key == 'up' then
            game_setDirection(0, -1)
        elseif key == 'down' then
            game_setDirection(0, 1)
        end
    end

    if key == 'space' then
        game_restart()
    elseif key == 'p' then
        if CURRENT_STATE == GAME_STATE.RUNNING then
            game_pause()
        else
            game_unpause()
        end
    end
end
