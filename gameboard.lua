--
-- Helper functions
--

function loadTileSet(filename) 
    local tileset = {}
    local contents, size = love.filesystem.read(filename)
    local t = 0
    local y = 0
    local x = 0
    for str in string.gmatch(contents, '([^,^\n]+)') do
        if tileset[t] == nil then
            tileset[t] = {}
        end
        if tileset[t][y] == nil then
            tileset[t][y] = {}
        end

        tileset[t][y][x] = tonumber(str)

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
    return tileset
end

--
-- Tile
--

Tile = {}
Tile.__index = Tile

function Tile.create(tiles, blocks)
    local self = setmetatable({}, Tile)

    self.tileset = tiles

    self.blocks = blocks
    self.blockSize = self.blocks[1]:getWidth()

    self.tileIndex = 7
    self.turnIndex = 0

    return self
end

function Tile:draw()
    for y=0, 3 do
        for x=0, 3 do
            local i = self.tileset[self.tileIndex][self.turnIndex][y][x]
            if i > 0 then
                love.graphics.draw(self.blocks[i], x * self.blockSize, y * self.blockSize)
            end
        end
    end
end

function Tile:turn(i)
    self.turnIndex = self.turnIndex + 1
    if self.turnIndex > 3 then
        self.turnIndex = 0
    elseif self.turnIndex < 0 then
        self.turnIndex = 3
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

    -- the tile sets
    self.tileSets = {}
    self.tileSets[1] = loadTileSet("assets/tile1.txt") 
    self.tileSets[2] = loadTileSet("assets/tile2.txt") 
    self.tileSets[3] = loadTileSet("assets/tile3.txt") 
    self.tileSets[4] = loadTileSet("assets/tile4.txt") 
    self.tileSets[5] = loadTileSet("assets/tile5.txt") 
    self.tileSets[6] = loadTileSet("assets/tile6.txt") 
    self.tileSets[7] = loadTileSet("assets/tile7.txt") 

    -- the current tile
    self.tile = Tile.create(self.tileSets, self.blocks)

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

    if self.tile then
        self.tile:draw()
    end 

    love.graphics.translate(-self.xOffset, -self.yOffset)
end

function GameBoard:turn(i)
    if self.tile then
        self.tile:turn(i)
    end 
end