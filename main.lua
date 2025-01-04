-- main.lua
-- Trying to create a ECS system from scratch in love2D

local love = require "love"

-- love.load -> love.update -> love.draw

-- Lua est dynamiquement typé et ses tableaux sont flexibles

-- index / joueur / display / xpos / ypos / xsiz / ysiz
local entities = {}

-- xpos / ypos / xsiz / ysiz
local composants = {}

local systems = {
}

local function renderSystem(entities)
    for _, entity in ipairs(entities) do
        if entity[3] then
            local index = entity[1]
            print(index)
            love.graphics.rectangle("fill", composants[index][1], composants[index][2], composants[index][3],
                composants[index][4])
        end
    end
end

function love.load()
    love.window.setTitle("LOVE2D GAME")
    love.window.setMode(1200, 900, { resizable = false })
    table.insert(entities, { 1, true, true, true, true, true, true })
    table.insert(composants, { 50, 40, 50, 100 })
    table.insert(entities, { 2, true, true, true, true, true, true })
    table.insert(composants, { 200, 100, 50, 100 })
end

function love.update()
    if love.keyboard.isDown("q") then
        love.event.quit()
    end
end

function love.draw()
    renderSystem(entities)
end
