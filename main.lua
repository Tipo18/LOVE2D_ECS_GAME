-- main.lua
-- Trying to create a ECS system from scratch in love2D

local love = require "love"

-- love.load -> love.update -> love.draw

-- Lua est dynamiquement typé et ses tableaux sont flexibles

local world = {
    gamestate = "menu" -- menu / running / paused
}

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
            -- print(index)
            love.graphics.rectangle("fill", composants[index][1], composants[index][2], composants[index][3],
                composants[index][4])
        end
    end
end

local function deplacementSystem(entities)
    for _, entity in ipairs(entities) do
        if entity[2] then
            local index = entity[1]
            if love.keyboard.isDown("right") then
                composants[index][1] = composants[index][1] + 10
            end
            if love.keyboard.isDown("left") then
                composants[index][1] = composants[index][1] - 10
            end
            if love.keyboard.isDown("up") then
                composants[index][2] = composants[index][2] - 10
            end
            if love.keyboard.isDown("down") then
                composants[index][2] = composants[index][2] + 10
            end
        end
    end
end

local function gamestart()
    world.gamestate = "running"
    table.insert(entities, { 1, true, true, true, true, true, true })
    table.insert(composants, { 50, 40, 50, 100 })
    table.insert(entities, { 2, false, true, true, true, true, true })
    table.insert(composants, { 200, 100, 50, 100 })
end

function love.load()
    love.window.setTitle("LOVE2D GAME")
    love.window.setMode(1200, 900, { resizable = false })
    -- gamestart()
end

function love.update()
    if world.gamestate == "menu" then
        if love.keyboard.isDown("return") then
            gamestart()
        end
    end
    if world.gamestate == "running" then
        deplacementSystem(entities)
    end
    print("update")
end

function love.draw()
    if world.gamestate == "menu" then
        love.graphics.setNewFont(30)
        local text = "Press Enter to start"
        local width = love.graphics.getWidth()
        local height = love.graphics.getHeight()
        love.graphics.print(text, width/2 - love.graphics.getFont():getWidth(text)/2, height*(3/5))
    end
    if world.gamestate == "running" then
        renderSystem(entities)
    end
end
