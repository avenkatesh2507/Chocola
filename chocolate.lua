local utils = require "utils"

Chocolate = {}
Chocolate.__index = Chocolate

function Chocolate:new(image, x, y)
    local obj = {}
    setmetatable(obj, Chocolate)

    obj.image = image
    obj.x = x
    obj.y = y

    obj.originalX = x
    obj.originalY = y

    obj.width = image:getWidth()
    obj.height = image:getHeight()

    obj.dragging = false
    obj.slot = nil

    return obj
end

function Chocolate:update(dt)
    if self.dragging then
        local mouseX, mouseY = love.mouse.getPosition()
        self.x = mouseX - self.width / 2
        self.y = mouseY - self.height / 2
    end
end

function Chocolate:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.image, self.x, self.y)
end

function Chocolate:isMouseOver(mx, my)
    return mx > self.x and
           mx < self.x + self.width and
           my > self.y and
           my < self.y + self.height
end

return Chocolate

