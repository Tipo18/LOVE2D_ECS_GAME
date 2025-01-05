-- main.lua
-- Trying to create a ECS system from scratch in love2D

local love = require "love"

-- love.load -> love.update -> love.draw
-- Lua est dynamiquement typé et ses tableaux sont flexibles

local world = {
    gamestate = "menu" -- menu / running / paused
}

-- index / joueur / display / xpos / ypos / xsiz / ysiz / recttype / blocking / finish door / lastmove
local entities = {}

-- xpos / ypos / xsiz / ysiz / rect type / lastmove
local components = {}

local systems = {
}

local function renderSystem()
    for _, entity in ipairs(entities) do
        if entity.display then
            local affichage = "fill"
            if entity.end_door then
                affichage = "line"
            end
            if entity.spawn then
                affichage = "line"
            end
            local index = entity.index
            love.graphics.rectangle(affichage, components[index].xpos, components[index].ypos,
                components[index].xsize,
                components[index].ysize)
        end
    end
end

local function deplacementSystem(dt)
    -- 1 forcement joueur et que lui qui bouge
    if love.keyboard.isDown("right") then
        components[1].xvelocity = 300
    end
    if love.keyboard.isDown("left") then
        components[1].xvelocity = -300
    end
    function love.keypressed(key)
        if key == "space" and entities[1].onground then
            print(entities[1].onground)
            components[1].yvelocity = -500
            entities[1].onground = false
        end
    end

    if entities[1].onground == false then
        components[1].yvelocity = components[1].yvelocity + 750 * dt
    end

    -- movement
    components[1].xpos = components[1].xpos + math.floor(components[1].xvelocity * dt + 0.5)
    components[1].ypos = components[1].ypos + math.floor(components[1].yvelocity * dt + 0.5)
    components[1].xvelocity = 0

    if components[1].ypos + components[1].ysize >= 1000 then
        entities[1].onground = true
        components[1].yvelocity = 0
        components[1].ypos = 1000 - components[1].ysize
    end
end


-- local function approxCheckCollision(indexe1, indexe2)
--     local distance = math.sqrt((composants[indexe1][1] - composants[indexe2][1]) ^ 2 +
--         (composants[indexe1][2] - composants[indexe2][2]) ^ 2)
--     if distance < (composants[indexe1][3] + composants[indexe2][3] + composants[indexe1][4] + composants[indexe2][4]) / 2 then
--         return true
--     else
--         return false
--     end
-- end

-- local function trueCheckCollision(index1, index2)
--     if composants[index1][1] < composants[index2][1] + composants[index2][3] and
--         composants[index1][1] + composants[index1][3] > composants[index2][1] and
--         composants[index1][2] < composants[index2][2] + composants[index2][4] and
--         composants[index1][2] + composants[index1][4] > composants[index2][2] then
--         return true
--     else
--         return false
--     end
-- end

-- local function annulLastmvoe()
--     if composants[1][6] == "x" then
--         composants[1][1] = composants[1][1] - 5
--     elseif composants[1][6] == "-x" then
--         composants[1][1] = composants[1][1] + 5
--     elseif composants[1][6] == "y" then
--         composants[1][2] = composants[1][2] + 5
--     elseif composants[1][6] == "-y" then
--         composants[1][2] = composants[1][2] - 5
--     else
--         print("error joueur lastmove")
--     end
-- end

-- local function collisionSystem()
--     for _, entity in ipairs(entities) do
--         if entity[9] then
--             if approxCheckCollision(1, entity[1]) then
--                 if trueCheckCollision(1, entity[1]) then
--                     annulLastmvoe()
--                 end
--             end
--         end
--         if entity[10] then
--             if approxCheckCollision(1, entity[1]) then
--                 if trueCheckCollision(1, entity[1]) then
--                     print("colision porte")
--                 end
--             end
--         end
--     end
-- end

-- index / joueur / display / xpos / ypos / xsiz / ysiz / recttype / blocking / finish door / lastmove
-- -- xpos / ypos / xsiz / ysiz / rect type / lastmove

local function gamestart()
    local it_index = 1
    -- joueur
    table.insert(entities,
        { index = it_index, player = true, spawn = false, end_door = false, platforme = false, wall = false, display = true, xpos = true, ypos = true, xvelocity = true, yvelocity = true, xsize = true, ysize = true, onground = true, })
    table.insert(components,
        { xpos = 20, ypos = 1000 - 40, xsize = 20, ysize = 40, xvelocity = 250, yvelocity = 0, isonground = true })
    it_index = it_index + 1
    -- spawn
    table.insert(entities,
        { index = it_index, player = false, spawn = true, end_door = false, platforme = false, wall = false, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
    table.insert(components, { xpos = 30, ypos = 1000 - 50, xsize = 30, ysize = 50 })
    it_index = it_index + 1
    -- end_door
    table.insert(entities,
        { index = it_index, player = false, spawn = false, end_door = true, platforme = false, wall = false, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
    table.insert(components, { xpos = 800, ypos = 1000 - 50, xsize = 30, ysize = 50 })
    it_index = it_index + 1
    world.gamestate = "running"
end

function love.load()
    love.window.setTitle("LOVE2D GAME")
    love.window.setMode(1000, 1000, { resizable = false })
end

function love.update(dt)
    dt = math.min(dt, 0.033)
    if world.gamestate == "menu" then
        if love.keyboard.isDown("return") then
            gamestart()
        end
    end
    if world.gamestate == "running" then
        deplacementSystem(dt)
        -- collisionSystem()
    end
end

function love.draw()
    if world.gamestate == "menu" then
        love.graphics.setNewFont(30)
        local text = "Press Enter to start"
        local width = love.graphics.getWidth()
        local height = love.graphics.getHeight()
        love.graphics.print(text, width / 2 - love.graphics.getFont():getWidth(text) / 2, height * (3 / 5))
    end
    if world.gamestate == "running" then
        renderSystem()
    end
end
