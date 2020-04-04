
require("util")

--
-- NextBoard
--

NextBoard = {}
NextBoard.__index = NextBoard

function NextBoard.create()
    local self = setmetatable({}, NextBoard)

    self.background = love.graphics.newImage("assets/nextboard.png")
    self.width = self.background:getWidth()
    self.height = self.background:getHeight()
    self.xOffset = 0
    self.yOffset = 0
    self.oldXOffset = 0
    self.oldYOffset = 0
    self.font = love.graphics.newFont("assets/Kenney Rocket.ttf", 16)
    self.tile = nil
    self.oldTile = nil
    self.fadeInAlpha = 1

    return self
end

function NextBoard:draw()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.background, 0, 0)
    drawCentered(self.width, {newText(self.font, "Next")}, 30, 237, 211, 7)

    if self.oldTile and self.fadeInAlpha < 1 then
        love.graphics.translate(self.oldXOffset, self.oldYOffset)
        self.oldTile:drawPreview(1 - self.fadeInAlpha)
        love.graphics.translate(-self.oldXOffset, -self.oldYOffset)
    end 
    if self.tile then
        love.graphics.translate(self.xOffset, self.yOffset)
        self.tile:drawPreview(self.fadeInAlpha)
        love.graphics.translate(-self.xOffset, -self.yOffset)
    end 
end

function NextBoard:setTile(t)
    
    self.oldTile = self.tile
    self.oldXOffset = self.xOffset
    self.oldYOffset = self.yOffset
    self.tile = t
    if self.tile then
        self.xOffset = math.floor((self.width -  self.tile:getPreviewWidth()) / 2)
        self.yOffset = math.floor((self.height -  self.tile:getPreviewHeight()) / 2) + 10
    end
end

function NextBoard:setFadeInAlpha(a) 
    self.fadeInAlpha = a
end