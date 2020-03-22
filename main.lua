--
-- Tetris
--

require("gameboard")

function setRGB(r, g, b) 
    love.graphics.setColor(r/255, g/255, b/255, 1)
end

function setRGB(r, g, b, a) 
    love.graphics.setColor(r/255, g/255, b/255, a)
end

function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)

    board = GameBoard.create()
    boardX = math.floor((love.graphics.getWidth() - board.width) / 2)
    boardY = math.floor((love.graphics.getHeight() - board.height) / 2)
    font = love.graphics.newFont("assets/Kenney Mini.ttf", 18)
   
end

function love.draw()
    love.graphics.translate(boardX, boardY)
    board:draw()
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
