--
-- Tile
--

Tile = {}
Tile.__index = Tile

function Tile.create(name, blocks)
    local self = setmetatable({}, Tile)

    print(blockSize)

    self.blocks = blocks
    self.blockSize = self.blocks[1]:getWidth()
    self.board = {}
    self.turn = 0

    local contents, size = love.filesystem.read(name)
    local t = 0
    local y = 0
    local x = 0
    for str in string.gmatch(contents, '([^,^\n]+)') do
        if self.board[t] == nil then
            self.board[t] = {}
        end 
        if self.board[t][y] == nil then
            self.board[t][y] = {}
        end
        
        self.board[t][y][x] = tonumber(str)

        x = x + 1;
        if x > 3 then
            x = 0
            y = y + 1
        end

        if y > 3 then
            y = 0
            t = t + 1
        end
    end
    
    return self
end

function Tile:draw()
    for y=0, 3 do
        for x=0, 3 do
            local i = self.board[self.turn][y][x]
            if i > 0 then
                love.graphics.draw(self.blocks[i], x * self.blockSize, y * self.blockSize)
            end
        end
    end
end

--
-- GameBoard
--

GameBoard = {}
GameBoard.__index = GameBoard

function GameBoard.create()
    local self = setmetatable({}, GameBoard)

    -- the background
    self.background = love.graphics.newImage("assets/board.png")
    self.width = self.background:getWidth()
    self.height = self.background:getHeight()
    self.xOffset = 21
    self.yOffset = 22

    -- the blocks
    self.blocks = {}
    self.blocks[1] = love.graphics.newImage("assets/block1.png")
    self.blocks[2] = love.graphics.newImage("assets/block2.png")
    self.blocks[3] = love.graphics.newImage("assets/block3.png")
    self.blocks[4] = love.graphics.newImage("assets/block4.png")
    self.blocks[5] = love.graphics.newImage("assets/block5.png")
    self.blocks[6] = love.graphics.newImage("assets/block6.png")
    self.blocks[7] = love.graphics.newImage("assets/block7.png")
    self.blockSize = self.blocks[1]:getWidth()

    -- the tiles
    self.tiles = {}
    self.tiles[1] = Tile.create("assets/tile1.txt", self.blocks)
    self.tiles[2] = Tile.create("assets/tile2.txt", self.blocks)
    self.tiles[3] = Tile.create("assets/tile3.txt", self.blocks)
    self.tiles[4] = Tile.create("assets/tile4.txt", self.blocks)

    -- the board
    self.board = {}
    for y=0, 23 do
        self.board[y] = {}
        for x=0, 9 do
            self.board[y][x] = 0
        end
    end

    return self
end

function GameBoard:draw()
    love.graphics.draw(self.background, 0, 0)
    
    love.graphics.translate(self.xOffset, self.yOffset)
    for y=0, 23 do
        for x=0, 9 do
            local i = self.board[y][x]
            if i > 0 then
                love.graphics.draw(self.blocks[i], x * self.blockSize, y * self.blockSize)
            end
        end
    end

    self.tiles[4]:draw()

    love.graphics.translate(-self.xOffset, -self.yOffset)
end