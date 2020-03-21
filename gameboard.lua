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

function Tile.create(tiles, blocks, brd, tindex)
    local self = setmetatable({}, Tile)

    self.tileset = tiles
    self.blocks = blocks
    self.board = brd

    self.blockSize = self.blocks[1]:getWidth()

    self.tileIndex = tindex
    self.turnIndex = 0
    self.xPos = 3
    self.yPos = 1
    self.offset = 0
    self.aplha = 1

    return self
end

function Tile:draw()

    love.graphics.setColor(1, 1, 1, self.alpha)
    for y=0, 3 do
        for x=0, 3 do
            local i = self.tileset[self.tileIndex][self.turnIndex][y][x]
            if i > 0 then
                love.graphics.draw(self.blocks[i], (x + self.xPos) * self.blockSize, ((y + self.yPos) * self.blockSize) - self.offset)
            end
        end
    end
end

function Tile:turn()
    if self:check((self.turnIndex + 1) % 4, self.xPos, self.yPos) then
        self.turnIndex = (self.turnIndex + 1) % 4
    end 
end

function Tile:descend(drop)

    if drop then
        local y = self.yPos + 1
        while self:check(self.turnIndex, self.xPos, y) do
            self.yPos = y
            y = y + 1
        end
    end

    if self:check(self.turnIndex, self.xPos, self.yPos + 1) then
        self.yPos = self.yPos + 1
        return false
    else
        for y=0, 3 do
            for x=0, 3 do
                local i = self.tileset[self.tileIndex][self.turnIndex][y][x]
                if i > 0 then
                    self.board[self.yPos + y][self.xPos + x] = i
                end
            end
        end
        return true
    end 
end

function Tile:move(i, multiple)
    if multiple then 
        local x = self.xPos + i
        while self:check(self.turnIndex, x, self.yPos) do
            self.xPos = x
            x = x + i
        end 
    else 
        if self:check(self.turnIndex, self.xPos + i, self.yPos) then
            self.xPos = self.xPos + i
        end 
    end
end

function Tile:check(turnindex, xpos, ypos)
    for y=0, 3 do
        for x=0, 3 do
            local i = self.tileset[self.tileIndex][turnindex][y][x]
            if i > 0 then
                local checkx = x + xpos
                local checky = y + ypos
                if checkx < 0 or checkx > 9 then
                    return false
                end
                if checky > 23 then
                    return false
                end
                if self.board[ypos + y][xpos + x] > 0 then
                    return false
                end
            end
        end
    end
    return true
end

function Tile:setPhase(p)
    self.offset = self.blockSize - p * self.blockSize
end

function Tile:setAlpha(a)
    self.alpha = a
end

function Tile:getAlpha()
    return self.alpha
end

--
-- GameBoard
--

STATE__RUNNING = 1
STATE__DROPPING_IN = 2
STATE__CLEARING_FADE_OUT = 3
STATE__CLEARING_COLLAPSE = 4

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

    -- the current statte
    self.state = STATE__RUNNING

    -- the current tile
    self.tile = nil

    -- tempo in s
    self.tempo = 0.15
    self.delta = 0

    -- the clearing phases
    self.clearingPhase = 1

    -- keyboard 
    self.f1Down = false
    self.upDown = false
    self.leftDown = false
    self.rightDown = false
    self.dropDown = false

    -- the board
    self.board = {}
    self.completedLines = {}
    for y=0, 23 do
        self.board[y] = {}
        self.completedLines[y] = false
        for x=0, 9 do
            self.board[y][x] = 0
        end
    end

    return self
end

function GameBoard:draw()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.background, 0, 0)

    love.graphics.translate(self.xOffset, self.yOffset)

    local clearedcount = 0
    for y=23, 0, -1 do
        local drawline = true
        if self.state == STATE__CLEARING_FADE_OUT and self.completedLines[y] then
            love.graphics.setColor(1, 1, 1, self.clearingPhase)
        elseif self.state == STATE__CLEARING_COLLAPSE then
            if self.completedLines[y] then
                drawline = false
                clearedcount = clearedcount + 1
            end
            love.graphics.setColor(1, 1, 1, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        if drawline then
            collapseoffset = clearedcount * self.clearingPhase * self.blockSize
            for x=0, 9 do
                local i = self.board[y][x]
                if i > 0 then
                    love.graphics.draw(self.blocks[i], x * self.blockSize, (y * self.blockSize) + collapseoffset)
                end
            end
        end
    end

    self.delta = self.delta + love.timer.getDelta()

    if self.state == STATE__RUNNING  then
        self:running()
    elseif self.state == STATE__DROPPING_IN  then
        self:droppingIn()
    elseif self.state == STATE__CLEARING_FADE_OUT  then
        self:clearingFadeOut()
    elseif self.state == STATE__CLEARING_COLLAPSE  then
        self:clearingCollapse()
    end

    love.graphics.translate(-self.xOffset, -self.yOffset)

    -----------------------------------------------

    if love.keyboard.isDown("f1") then
        if not self.f1Down then
            self:test()
        end
        self.f1Down = true
    else
        self.f1Down = false
    end

    if love.keyboard.isDown("up") then
        if not self.upDown then
            self:turn()
        end
        self.upDown = true
    else
        self.upDown = false
    end

    if love.keyboard.isDown("left") then
        if not self.leftDown then
            self:move(-1, love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl"))
        end
        self.leftDown = true
    else
        self.leftDown = false
    end

    if love.keyboard.isDown("right") then
        if not self.rightDown then
            self:move(1, love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl"))
        end
        self.rightDown = true
    else
        self.rightDown = false
    end

    if love.keyboard.isDown("space") then
        if not self.dropDown then
            self:drop()
        end
        self.dropDown = true
    else
        self.dropDown = false
    end
end

function GameBoard:droppingIn()

    if self.tile then
        local a = self.delta * 6;
        if a > 1 then
            a = 1;
            self.delta = 0
            self.state = STATE__RUNNING
        end
        self.tile:setAlpha(a)
        self.tile:draw()
    end 
end

function GameBoard:clearingCollapse()
    
    local a = self.delta * 12;
    if a > 1 then
        self:clearLines(false)
        self:dropIn()
    else 
        self.clearingPhase = a
    end
end

function GameBoard:clearingFadeOut()
    
    local a = self.delta * 12;
    if a > 1 then
        self.delta = 0
        self.clearingPhase = 0
        self.state = STATE__CLEARING_COLLAPSE
    else 
        self.clearingPhase = 1 - a
    end
end

function GameBoard:running()

    if self.tile then
        self.tile:draw()
    end 

    if self.tile then

        local tempo = self.tempo
        if love.keyboard.isDown("down") then
            tempo = 0.06
        end

        local newtile = false
        if self.delta >= tempo then
            self.delta = self.delta - tempo
            newtile = self.tile:descend()
        end

        if newtile then
            self:checkLines()
        else 
            self.tile:setPhase(self.delta / tempo)
        end
    end
end

---------------------
---------------------
---------------------

function GameBoard:turn()

    if self.tile then
        self.tile:turn()
    end 
end

function GameBoard:move(i, multiple)

    if self.tile then
        self.tile:move(i, multiple)
    end 
end

function GameBoard:drop()

    if self.tile then
        self.tile:descend(true)
        self:checkLines()
    end 
end

function GameBoard:dropIn()

    local li = -1
    if self.tile then
        li = self.tile.tileIndex
    end

    local i = love.math.random(1, 8)
    if i == li or i == 8 then
        i = love.math.random(1, 7)
    end

    self.tile = Tile.create(self.tileSets, self.blocks, self.board, i)
    self.tile:setAlpha(0.0)
    self.tile:setPhase(0)
    self.delta = 0
    self.state = STATE__DROPPING_IN
end

function GameBoard:checkLines()

    if self:clearLines(true) then
        self.tile = nil
        self.delta = 0
        self.clearingPhase = 1
        self.state = STATE__CLEARING_FADE_OUT
    else
        self:dropIn()
    end
end

function GameBoard:clearLines(markonly)

    local clearedlines = false    
    local y = 23
    while y >= 0 do
        self.completedLines[y] = false
        local i = 0
        for x=0, 9 do
            if self.board[y][x] > 0 then
                i = i + 1
            end
        end
        if i >= 10 then
            clearedlines = true
            if markonly then
                self.completedLines[y] = true
            else
                for yy=y, 1, -1 do
                    for x=0, 9 do
                        self.board[yy][x] = self.board[yy-1][x]
                    end
                end
                for x=0, 9 do
                    self.board[0][x] = 0
                end
                y = y + 1
            end
        end
         
        y = y - 1
    end
    return clearedlines
end

function GameBoard:test()

    self:dropIn()
end