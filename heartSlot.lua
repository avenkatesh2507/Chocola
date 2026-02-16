SLOT_SIZE = 60

HeartSlot = {}
HeartSlot.__index = HeartSlot

function HeartSlot:new(x, y)
    local self = setmetatable({}, HeartSlot)
    self.x = x
    self.y = y
    self.width = SLOT_SIZE
    self.height = SLOT_SIZE
    self.chocolate = nil
    self.occupied = false
    return self
end

function HeartSlot:draw()
    love.graphics.setColor(0.45, 0.26, 0.07)
    love.graphics.circle("fill", self.x + SLOT_SIZE/2, self.y + SLOT_SIZE/2, SLOT_SIZE/2)
    if self.chocolate then
        love.graphics.setColor(1, 1, 1)
        self.chocolate:draw()
    end
end

function HeartSlot:isEmpty()
    return self.chocolate == nil
end

return HeartSlot
