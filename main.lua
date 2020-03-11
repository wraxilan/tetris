--
-- Tetris
--

require("gameboard")

function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)

    board = GameBoard.create()
    boardX = math.floor((love.graphics.getWidth() - board.width) / 2)
    boardY = math.floor((love.graphics.getHeight() - board.height) / 2)
    font = love.graphics.newFont("assets/azonix.otf", 18)

    keyDelta = 0
    f1Down = false
    upDown = false
    leftDown = false
    rightDown = false
end

function love.draw()
    love.graphics.translate(boardX, boardY)
    board:draw(love.timer.getDelta())
    love.graphics.origin()

    ---------------------

    love.graphics.setFont(font)
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.print("debug: " .. boardX, 10, 680)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 700)
    love.graphics.print("dt: " .. love.timer.getDelta(), 10, 720) -- seconds

    ---------------------

    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    if love.keyboard.isDown("f1") then
        if not f1Down then
            board:test()
        end
        f1Down = true
    else
        f1Down = false
    end

    if love.keyboard.isDown("up") then
        if not upDown then
            board:turn()
        end
        upDown = true
    else
        upDown = false
    end

    if love.keyboard.isDown("left") then
        if not leftDown then
            board:move(-1, love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl"))
        end
        leftDown = true
    else
        leftDown = false
    end

    if love.keyboard.isDown("right") then
        if not rightDown then
            board:move(1, love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl"))
        end
        rightDown = true
    else
        rightDown = false
    end
end
