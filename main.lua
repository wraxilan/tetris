--
-- Tetris
--

require("util")
require("gameboard")
require("boards")

function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)

    font = love.graphics.newFont("assets/Kenney Mini.ttf", 18)

    nextBoard = NextBoard.create()

    board = GameBoard.create(nextBoard)
    boardX = math.floor((love.graphics.getWidth() - board.width) / 2)
    boardY = math.floor((love.graphics.getHeight() - board.height) / 2)
end

function love.draw()
    love.graphics.translate(boardX, boardY)
    board:draw()
    love.graphics.origin()

    love.graphics.translate(boardX + board.width, boardY)
    nextBoard:draw()
    love.graphics.origin()

    ---------------------

    love.graphics.setFont(font)

    setRGB(237, 211, 7)
    love.graphics.print("debug: " .. boardX, 10, 680)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 700)
    love.graphics.print("dt: " .. love.timer.getDelta(), 10, 720) -- seconds

    ---------------------

    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
end
