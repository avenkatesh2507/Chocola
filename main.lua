require "heartSlot"
require "chocolate"
local utils = require "utils"


local chocolates = {}
local heartSlots = {}
local draggingChocolate = nil
local SNAP_RADIUS = 60


local bgImage
local heartBoxImage
local shareCode = ""
local loadInput = ""
local noteText = ""
local typingNote = false
local typingLoadBox = false
local copiedTimer = 0
local copiedDuration = 2


function love.load()

    chocolates = {}
    heartSlots = {}
    chocolateImages = {}

    bgImage = love.graphics.newImage("assets/bg-valentine.png")
    heartBoxImage = love.graphics.newImage("assets/heartbox.png")

    for i = 1, 15 do
        chocolateImages[i] = love.graphics.newImage("assets/Chocolate " .. i .. ".png")
    end

  
    for i = 1, 15 do
        local x = 50 + ((i - 1) % 5) * 70
        local y = 400 + math.floor((i - 1) / 5) * 70
        table.insert(chocolates, Chocolate:new(chocolateImages[i], x, y))
    end

   
    local boxX, boxY = 600, 140
    local centerX = boxX + 200
    local centerY = boxY + 200

    local positions = {
        {centerX - 100, centerY - 140},
        {centerX + 100, centerY - 140},

        {centerX - 160, centerY - 60},
        {centerX - 50,  centerY - 80},
        {centerX + 50,  centerY - 80},
        {centerX + 160, centerY - 60},

        {centerX - 100, centerY + 20},
        {centerX,       centerY + 25},
        {centerX + 100, centerY + 20},

        {centerX - 50,  centerY + 90},
        {centerX + 50,  centerY + 90},

        {centerX,       centerY + 145}
    }

    for _, pos in ipairs(positions) do
        table.insert(heartSlots, HeartSlot:new(pos[1], pos[2]))
    end
end


function love.update(dt)
    for _, choco in ipairs(chocolates) do
        choco:update(dt)
    end

    if copiedTimer > 0 then
        copiedTimer = copiedTimer - dt
    end
end


function love.draw()

    love.graphics.setColor(1,1,1)
    if bgImage then love.graphics.draw(bgImage, 0, 0) end
    if heartBoxImage then love.graphics.draw(heartBoxImage, 600, 140) end


    for _, slot in ipairs(heartSlots) do
        slot:draw()
    end

    for _, choco in ipairs(chocolates) do
        if choco ~= draggingChocolate then
            choco:draw()
        end
    end
    if draggingChocolate then
        draggingChocolate:draw()
    end

    love.graphics.setColor(0.8,0.3,0.3)
    love.graphics.rectangle("fill", 50, 40, 160, 40)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Reset", 95, 52)


    love.graphics.setColor(0.8,0.2,0.4)
    love.graphics.rectangle("fill", 50, 100, 160, 40)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Generate Code", 65, 112)

    if copiedTimer > 0 then
        love.graphics.setColor(0,0.6,0)
        love.graphics.print("Copied to Clipboard!", 60, 145)
    end


    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("line", 50, 160, 400, 50)
    love.graphics.setColor(0,0,0)
    love.graphics.print("Your Share Code:", 60, 165)
    love.graphics.print(shareCode, 60, 185)

    if typingLoadBox then
        love.graphics.setColor(1,0.95,0.95)
        love.graphics.rectangle("fill", 50, 240, 400, 50)
    end

    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("line", 50, 240, 400, 50)
    love.graphics.setColor(0,0,0)
    love.graphics.print("Paste Code Here:", 60, 245)
    love.graphics.print(loadInput, 60, 265)

    love.graphics.setColor(0.2,0.6,0.8)
    love.graphics.rectangle("fill", 50, 310, 160, 40)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Load Box", 95, 322)

    if typingNote then
        love.graphics.setColor(1,0.9,0.9)
        love.graphics.rectangle("fill", 600, 560, 400, 60)
    end

    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("line", 600, 560, 400, 60)
    love.graphics.setColor(0,0,0)
    love.graphics.print("Note: " .. noteText, 620, 580)
end


function love.mousepressed(x, y, button)

    if button ~= 1 then return end

    if x > 50 and x < 210 and y > 40 and y < 80 then
        resetBoard()
        return
    end

    if x > 50 and x < 210 and y > 100 and y < 140 then
        shareCode = generateShareCode()
        love.system.setClipboardText(shareCode)
        copiedTimer = copiedDuration
        return
    end

    if x > 50 and x < 210 and y > 310 and y < 350 then
        loadShareCode(loadInput)
        return
    end

    typingLoadBox = (x > 50 and x < 450 and y > 240 and y < 290)
    typingNote = (x > 600 and x < 1000 and y > 560 and y < 620)

    for _, choco in ipairs(chocolates) do
        if choco:isMouseOver(x, y) then
            draggingChocolate = choco
            choco.dragging = true
            break
        end
    end
end

function love.mousereleased(x, y, button)


    if button ~= 1 or not draggingChocolate then return end

    local placed = false

    if draggingChocolate.slot then
        draggingChocolate.slot.chocolate = nil
        draggingChocolate.slot.occupied = false
        draggingChocolate.slot = nil
    end

    for _, slot in ipairs(heartSlots) do
        if not slot.occupied and
           utils.distance(
                draggingChocolate.x + draggingChocolate.width/2,
                draggingChocolate.y + draggingChocolate.height/2,
                slot.x + slot.width/2,
                slot.y + slot.height/2
           ) < SNAP_RADIUS then

            draggingChocolate.x = slot.x + (slot.width - draggingChocolate.width)/2
            draggingChocolate.y = slot.y + (slot.height - draggingChocolate.height)/2

            slot.chocolate = draggingChocolate
            slot.occupied = true
            draggingChocolate.slot = slot
            placed = true
            break
        end
    end

    if not placed then
        draggingChocolate.x = draggingChocolate.originalX
        draggingChocolate.y = draggingChocolate.originalY
    end

    draggingChocolate.dragging = false
    draggingChocolate = nil
end

function love.textinput(text)

    if typingNote then
        noteText = noteText .. text
    elseif typingLoadBox then
        loadInput = loadInput .. text
    end
end

function love.keypressed(key)

    if key == "backspace" then
        if typingNote then
            noteText = noteText:sub(1, -2)
        elseif typingLoadBox then
            loadInput = loadInput:sub(1, -2)
        end
    end

    if key == "v" and (love.keyboard.isDown("lctrl") or 
                       love.keyboard.isDown("rctrl") or
                       love.keyboard.isDown("lgui") or 
                       love.keyboard.isDown("rgui")) then

        local clipboardText = love.system.getClipboardText()

        if typingLoadBox then
            loadInput = loadInput .. clipboardText
        elseif typingNote then
            noteText = noteText .. clipboardText
        end
    end
end


function generateShareCode()

    local placements = {}

    for i, slot in ipairs(heartSlots) do
        if slot.chocolate then
            for j, choco in ipairs(chocolates) do
                if choco == slot.chocolate then
                    table.insert(placements, i .. ":" .. j)
                end
            end
        end
    end

    return table.concat(placements, ";") .. "#" .. noteText
end

function loadShareCode(code)
    resetBoard()

    local placementPart, notePart = code:match("([^#]*)#?(.*)")
    noteText = notePart or ""

    for pair in string.gmatch(placementPart, "[^;]+") do
        local slotIndex, chocoIndex = pair:match("(%d+):(%d+)")
        slotIndex = tonumber(slotIndex)
        chocoIndex = tonumber(chocoIndex)

        if heartSlots[slotIndex] and chocolates[chocoIndex] then
            local slot = heartSlots[slotIndex]
            local choco = chocolates[chocoIndex]

            choco.x = slot.x + (slot.width - choco.width)/2
            choco.y = slot.y + (slot.height - choco.height)/2

            slot.chocolate = choco
            slot.occupied = true
            choco.slot = slot
        end
    end
end

function resetBoard()
    for _, slot in ipairs(heartSlots) do
        slot.chocolate = nil
        slot.occupied = false
    end

    for _, choco in ipairs(chocolates) do
        choco.x = choco.originalX
        choco.y = choco.originalY
        choco.slot = nil
    end

    noteText = ""
    loadInput = ""
    shareCode = ""
end
