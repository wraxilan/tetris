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

    -- board = love.graphics.newImage("assets/board.png")
    -- tile = love.graphics.newImage("assets/tile_1.png")
end

function love.draw()
    -- love.graphics.print('Hello World!', 400, 300)


    --love.graphics.draw(board, 340, 4)
    --for x=0, 9 do
    --    for y=0, 23 do
    --        love.graphics.draw(tile, x * 30 + 361, y * 30 + 26)
    --    end
    --end

    love.graphics.translate(boardX, boardY)
    board:draw()
    love.graphics.origin()

    ---------------------

    love.graphics.setFont(font)
    love.graphics.print("debug: " .. boardX, 10, 680)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 700)
    love.graphics.print("dt: " .. love.timer.getDelta(), 10, 720)

    ---------------------

    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    if love.keyboard.isDown("left") then
        board:turn(-1)
    end
    if love.keyboard.isDown("right") then
        board:turn(1)
    end
end
