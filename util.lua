--
-- Helper functions
--

function setRGB(r, g, b) 
    love.graphics.setColor(r/255, g/255, b/255, 1)
end

function setRGB(r, g, b, a) 
    love.graphics.setColor(r/255, g/255, b/255, a)
end

function newText(font, str) 
    return love.graphics.newText(font, str)
end

function getCenteredX(width, drawables)
    
    local totalwitdh = 0
    local i = 1
    while drawables[i] do
        totalwitdh = totalwitdh + drawables[i]:getWidth()
        i = i + 1;
    end

    return math.floor((width - totalwitdh) / 2)
end

function drawCentered(width, drawables, y, r, g, b)
    
    local totalwitdh = 0
    local maxheight = 0
    local i = 1
    while drawables[i] do
        totalwitdh = totalwitdh + drawables[i]:getWidth()
        if drawables[i]:getHeight() > maxheight then
            maxheight = drawables[i]:getHeight()
        end
        i = i + 1;
    end

    local x = math.floor((width - totalwitdh) / 2)
    local yy = y + math.floor(maxheight / 2)
    
    local i = 1
    while drawables[i] do
        if drawables[i]:typeOf("Text") then
            setRGB(r, g, b)
        else 
            love.graphics.setColor(1, 1, 1, 1)
        end

        love.graphics.draw(drawables[i], x, yy - math.floor(drawables[i]:getHeight() / 2))
        x = x + drawables[i]:getWidth()
        i = i + 1;
    end
    return y + maxheight
end

function drawAbsolute(drawables, x, y, r, g, b)
    
    local maxheight = 0
    local i = 1
    while drawables[i] do
        if drawables[i]:getHeight() > maxheight then
            maxheight = drawables[i]:getHeight()
        end
        i = i + 1;
    end

    local yy = y + math.floor(maxheight / 2)
    
    local i = 1
    while drawables[i] do
        if drawables[i]:typeOf("Text") then
            setRGB(r, g, b)
        else 
            love.graphics.setColor(1, 1, 1, 1)
        end

        love.graphics.draw(drawables[i], x, yy - math.floor(drawables[i]:getHeight() / 2))
        x = x + drawables[i]:getWidth()
        i = i + 1;
    end
    return y + maxheight
end
