-- main.lua
-- Trying to create a ECS system from scratch in love2D

local love = require "love"

-- love.load -> love.update -> love.draw

-- Lua est dynamiquement typé et ses tableaux sont flexibles

-- index / joueur / display / xpos / ypos
local entities = {}

local composants = {}

local systems = {
}

local function renderSystem(entities)
    for _, entity in ipairs(entities) do
        if entity[3] then
            local index = entity[1]
            love.graphics.rectangle("fill", composants[index][3], composants[index][4], 100, 100)
        end
    end
end

function love.load()
    love.window.setTitle("LOVE2D GAME")
    love.window.setMode(1200, 900, { resizable = false })
    table.insert(entities, { 1, true, true, true, true })
    table.insert(composants, { true, true, 50, 40 })
end

function love.update()
    if love.keyboard.isDown("q") then
        love.event.quit()
    end
end

function love.draw()
    renderSystem(entities)
end
