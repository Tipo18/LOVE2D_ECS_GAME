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
    if love.keyboard.isDown("space") then
        if entities[1].onground or components[1].coyotetimer <= 0.1 then
            components[1].yvelocity = -700
            entities[1].onground = false
            components[1].coyotetimer = components[1].coyotetimer + 1
        end
    end

    -- switch pour un fonctionnement avec platforme
    local verif_on_no_plat = 0
    for _, entity in ipairs(entities) do
        if entity.platforme then
            if components[1].xpos < components[entity.index].xpos + components[entity.index].xsize and
                components[1].xpos + components[1].xsize > components[entity.index].xpos and
                components[1].ypos < components[entity.index].ypos + components[entity.index].ysize and
                components[1].ypos + components[1].ysize > components[entity.index].ypos then
                if components[1].ypos + components[1].ysize <= components[entity.index].ypos + 20 then
                    entities[1].onground = true
                    components[1].yvelocity = 0
                    components[1].ypos = components[
                    entity.index].ypos - components[1].ysize
                    verif_on_no_plat = verif_on_no_plat + 1
                end
            end
        end
    end
    if verif_on_no_plat == 0 then
        entities[1].onground = false
    end

    if entities[1].onground == false then
        components[1].yvelocity = components[1].yvelocity + 1000 * dt
        components[1].yvelocity = math.min(components[1].yvelocity, 700)
        components[1].coyotetimer = components[1].coyotetimer + dt
    else
        components[1].yvelocity = 0
        components[1].coyotetimer = 0
    end

    -- movement
    components[1].xpos = components[1].xpos + math.floor(components[1].xvelocity * dt + 0.5)
    components[1].ypos = components[1].ypos + math.floor(components[1].yvelocity * dt + 0.5)
    components[1].xvelocity = 0
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
        { index = it_index, player = true, spawn = false, end_door = false, platforme = false, wall = false, display = true, xpos = true, ypos = true, xvelocity = true, yvelocity = true, xsize = true, ysize = true, onground = true, coyotetimer = true, })
    table.insert(components,
        { xpos = 20, ypos = 1000 - 40, xsize = 20, ysize = 40, xvelocity = 250, yvelocity = 0, isonground = true, coyotetimer = 0 })
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

    -- sol
    table.insert(entities,
        { index = it_index, player = false, spawn = false, end_door = false, platforme = true, wall = false, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
    table.insert(components, { xpos = 0, ypos = 999, xsize = 1000, ysize = 10 })
    it_index = it_index + 1

    -- platforme
    table.insert(entities,
        { index = it_index, player = false, spawn = false, end_door = false, platforme = true, wall = false, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
    table.insert(components, { xpos = 200, ypos = 850, xsize = 80, ysize = 20 })
    it_index = it_index + 1
    table.insert(entities,
        { index = it_index, player = false, spawn = false, end_door = false, platforme = true, wall = false, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
    table.insert(components, { xpos = 300, ypos = 700, xsize = 80, ysize = 20 })
    it_index = it_index + 1
    table.insert(entities,
        { index = it_index, player = false, spawn = false, end_door = false, platforme = true, wall = false, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
    table.insert(components, { xpos = 400, ypos = 550, xsize = 80, ysize = 20 })
    it_index = it_index + 1

    table.insert(entities,
        { index = it_index, player = false, spawn = false, end_door = false, platforme = true, wall = false, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
    table.insert(components, { xpos = 500, ypos = 400, xsize = 80, ysize = 20 })
    it_index = it_index + 1

    table.insert(entities,
        { index = it_index, player = false, spawn = false, end_door = false, platforme = true, wall = false, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
    table.insert(components, { xpos = 600, ypos = 250, xsize = 80, ysize = 20 })
    it_index = it_index + 1

    table.insert(entities,
        { index = it_index, player = false, spawn = false, end_door = false, platforme = true, wall = false, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
    table.insert(components, { xpos = 700, ypos = 100, xsize = 80, ysize = 20 })
    it_index = it_index + 1

    -- wall
    table.insert(entities,
        { index = it_index, player = false, spawn = false, end_door = false, platforme = false, wall = true, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
    table.insert(components, { xpos = 250, ypos = 1000 - 80, xsize = 20, ysize = 80 })
    it_index = it_index + 1


    -- tester que les bout soit a la fois platforme a la fois mur
    -- switching the game state
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
