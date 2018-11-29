--
-- Tetris
--

function love.load()
    --love.graphics.setBackgroundColor(0.5, 0.5, 0.5)

    board = love.graphics.newImage("assets/board.png")
    tile = love.graphics.newImage("assets/tile_1.png")
end

function love.draw()
    -- love.graphics.print('Hello World!', 400, 300)

    love.graphics.draw(board, 340, 4)
    for x=0, 9 do
        for y=0, 23 do
            love.graphics.draw(tile, x * 30 + 361, y * 30 + 26)
        end
    end
end
