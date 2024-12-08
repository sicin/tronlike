require("game")
require("lib.visualdebug.visualDebug")

function love.load()
    love.window.setPosition(500, 50, 1)
    placeholderImage = love.graphics.newImage("assets/images/placeholder.png")

    -- https://freesound.org/people/DeezSoundzTho/sounds/407431/
    crash = love.audio.newSource("assets/audio/bottle-break.wav", "static")
    crash:setVolume(0.5)
    -- https://freesound.org/people/Joao_Janz/sounds/482664/
    driving = love.audio.newSource("assets/audio/car-loop.wav", "static")

    futuristicFont = love.graphics.newFont("assets/fonts/BrunoAce-Regular.ttf", 96)
    fontHeight = futuristicFont:getHeight()
    love.graphics.setFont(futuristicFont)
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.draw(placeholderImage, 0, 100)
    game_draw()

    if CURRENT_STATE == GAME_STATE.PAUSE then
        love.graphics.setColor(0, 1, 0, 1)
        local text = "Paused..."
        local textWidth = futuristicFont:getWidth(text)
        love.graphics.print(
            text,
            (love.graphics.getWidth() - textWidth) / 2,
            (love.graphics.getHeight() - fontHeight) / 2,
            0
        )
    end

    if CURRENT_STATE == GAME_STATE.GAME_OVER then
        love.graphics.setColor(1, 0, 0, 1)
        local text = "You lost!"
        local textWidth = futuristicFont:getWidth(text)
        love.graphics.print(
            text,
            (love.graphics.getWidth() - textWidth) / 2,
            (love.graphics.getHeight() - fontHeight) / 2,
            0
        )
    end
    -- visual debug
    -- drawSmallGrid()
    -- end visual debug
end

function love.update(dt)
    game_update(dt)
    require("lib.reload.lurker").update()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if CURRENT_STATE == GAME_STATE.RUNNING then
        if key == "left" then
            game_setDirection(-1, 0)
        elseif key == "right" then
            game_setDirection(1, 0)
        elseif key == "up" then
            game_setDirection(0, -1)
        elseif key == "down" then
            game_setDirection(0, 1)
        elseif key == 'space' then
            activateTurbo()
        end
    end

    if CURRENT_STATE == GAME_STATE.GAME_OVER and key == "return" then
        game_restart()
    end

    if CURRENT_STATE ~= GAME_STATE.GAME_OVER and key == "p" then
        if CURRENT_STATE == GAME_STATE.RUNNING then
            game_pause()
        elseif CURRENT_STATE == GAME_STATE.PAUSE then
            game_unpause()
        end
    end
end
