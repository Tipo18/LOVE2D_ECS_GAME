-- main.lua
-- Trying to create a ECS system from scratch in love2D

local love = require "love"

-- love.load -> love.update -> love.draw

local world = {
    gamestate = "menu" -- menu / running / paused
}

local frame = 1
local frametimer = 0
local walking = false

local time = 0

local entities = {}

local components = {}

local systems = {
}

local function player_sprite()
    if walking then
        local quad = love.graphics.newQuad(
            (frame - 1) * 64, 0,       -- x and y offset of the current frame
            64, 64,                    -- width and height of the frame
            player_walking:getWidth(), -- width of the whole sprite sheet
            player_walking:getHeight() -- height of the whole sprite sheet
        )
        love.graphics.draw(player_walking, quad, components[1].xpos, components[1].ypos)
    else
        love.graphics.draw(player_idle, components[1].xpos, components[1].ypos)
    end
end

local function renderSystem()
    for _, entity in ipairs(entities) do
        if entity.display then
            local affichage = "fill"
            if entity.end_door or entity.spawn then
                affichage = "line"
            end
            local index = entity.index
            if index == 1 then
                player_sprite()
            else
                love.graphics.rectangle(affichage, components[index].xpos, components[index].ypos,
                    components[index].xsize,
                    components[index].ysize)
            end
        end
    end
end

local function inputSystem()
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
end

-- S de colission complet
local function collisionPlatformSystem(dt)
    local block_move = false
    for _, entity in ipairs(entities) do
        if entity.wall then
            if components[1].xpos + math.floor(components[1].xvelocity * dt + 0.5) < components[entity.index].xpos + components[entity.index].xsize and
                components[1].xpos + math.floor(components[1].xvelocity * dt + 0.5) + components[1].xsize > components[entity.index].xpos and
                components[1].ypos + math.floor(components[1].yvelocity * dt + 0.5) < components[entity.index].ypos + components[entity.index].ysize and
                components[1].ypos + math.floor(components[1].yvelocity * dt + 0.5) + components[1].ysize > components[entity.index].ypos then
                block_move = true
                -- Calculate the overlap (penetration depth) on the X axis
                local overlapX1 = (components[1].xpos + math.floor(components[1].xvelocity * dt + 0.5) + components[1].xsize) -
                    components[entity.index].xpos
                local overlapX2 = (components[entity.index].xpos + components[entity.index].xsize) -
                    (components[1].xpos + math.floor(components[1].xvelocity * dt + 0.5))

                -- Take the smaller positive overlap value (to resolve in the correct direction)
                local penetrationX = math.min(overlapX1, overlapX2)

                -- Calculate the overlap (penetration depth) on the Y axis
                local overlapY1 = (components[1].ypos + math.floor(components[1].yvelocity * dt + 0.5) + components[1].ysize) -
                    components[entity.index].ypos
                local overlapY2 = (components[entity.index].ypos + components[entity.index].ysize) -
                    (components[1].ypos + math.floor(components[1].yvelocity * dt + 0.5))

                -- Take the smaller positive overlap value (to resolve in the correct direction)
                local penetrationY = math.min(overlapY1, overlapY2)
                if penetrationX < penetrationY then
                    -- Resolve X-axis collision
                    components[1].xvelocity = 0                                                  -- Stop horizontal movement
                    if overlapX1 < overlapX2 then
                        components[1].xpos = components[entity.index].xpos - components[1].xsize -- Push left
                    else
                        components[1].xpos = components[entity.index].xpos + components[entity.index]
                            .xsize -- Push right
                    end
                else
                    components[1].yvelocity = 0 -- Stop vertical movement
                    -- Resolve Y-axis collision
                    if overlapY1 < overlapY2 then
                        components[1].ypos = components[entity.index].ypos - components[1].ysize            -- Push up
                    else
                        components[1].ypos = components[entity.index].ypos + components[entity.index].ysize -- Push down
                    end
                end
            end
        end
    end
end


local function platformeCheckSystem()
    local verif_on_no_plat = 0
    for _, entity in ipairs(entities) do
        if entity.platforme then
            if components[1].xpos < components[entity.index].xpos + components[entity.index].xsize and
                components[1].xpos + components[1].xsize > components[entity.index].xpos and
                components[1].ypos < components[entity.index].ypos + components[entity.index].ysize and
                components[1].ypos + components[1].ysize > components[entity.index].ypos then
                if components[1].ypos + components[1].ysize <= components[entity.index].ypos + 10 then
                    entities[1].onground = true
                    components[1].yvelocity = 0
                    components[1].ypos = components[entity.index].ypos - components[1].ysize
                    verif_on_no_plat = entity.index
                end
            end
        end
    end
    if verif_on_no_plat == 0 then
        entities[1].onground = false
    end
end

local function fallingSystem(dt)
    if entities[1].onground == false then
        components[1].yvelocity = components[1].yvelocity + 1000 * dt
        components[1].yvelocity = math.min(components[1].yvelocity, 700)
        components[1].coyotetimer = components[1].coyotetimer + dt
    else
        components[1].yvelocity = 0
        components[1].coyotetimer = 0
    end
end

local function deplacementSystem(dt)
    local block_xmove = false
    local block_ymove = false
    for _, entity in ipairs(entities) do
        if entity.wall then
            if components[1].xpos + math.floor(components[1].xvelocity * dt + 0.5) < components[entity.index].xpos + components[entity.index].xsize and
                components[1].xpos + math.floor(components[1].xvelocity * dt + 0.5) + components[1].xsize > components[entity.index].xpos and
                components[1].ypos + math.floor(components[1].yvelocity * dt + 0.5) < components[entity.index].ypos + components[entity.index].ysize and
                components[1].ypos + math.floor(components[1].yvelocity * dt + 0.5) + components[1].ysize > components[entity.index].ypos then
                local overlapX1 = (components[1].xpos + math.floor(components[1].xvelocity * dt + 0.5) + components[1].xsize) -
                    components[entity.index].xpos
                local overlapX2 = (components[entity.index].xpos + components[entity.index].xsize) -
                    (components[1].xpos + math.floor(components[1].xvelocity * dt + 0.5))
                local penetrationX = math.min(overlapX1, overlapX2)

                local overlapY1 = (components[1].ypos + math.floor(components[1].yvelocity * dt + 0.5) + components[1].ysize) -
                    components[entity.index].ypos
                local overlapY2 = (components[entity.index].ypos + components[entity.index].ysize) -
                    (components[1].ypos + math.floor(components[1].yvelocity * dt + 0.5))

                local penetrationY = math.min(overlapY1, overlapY2)
                if penetrationX < penetrationY then
                    components[1].xvelocity = 0
                    block_xmove = true
                    if overlapX1 < overlapX2 then
                        components[1].xpos = components[entity.index].xpos - components[1].xsize
                    else
                        components[1].xpos = components[entity.index].xpos + components[entity.index].xsize
                    end
                else
                    components[1].yvelocity = 0
                    block_ymove = true
                    if overlapY1 < overlapY2 then
                        components[1].ypos = components[entity.index].ypos - components[1].ysize            -- Push up
                    else
                        components[1].ypos = components[entity.index].ypos + components[entity.index].ysize -- Push down
                    end
                end
            end
        end
    end

    if components[1].xvelocity ~= 0 then
        walking = true
    else
        walking = false
    end

    if not block_xmove then
        components[1].xpos = components[1].xpos + math.floor(components[1].xvelocity * dt + 0.5)
        components[1].xvelocity = 0
    end
    if not block_ymove then
        components[1].ypos = components[1].ypos + math.floor(components[1].yvelocity * dt + 0.5)
    end
end

local function frameUpdate(dt)
    frametimer = frametimer + dt
    if frametimer > 0.1 then
        if frame == 1 then
            frame = 2
        else
            frame = 1
        end
        frametimer = 0
    end
end

local function gamestart()
    local it_index = 1
    -- joueur
    table.insert(entities,
        { index = it_index, player = true, spawn = false, end_door = false, platforme = false, wall = false, display = true, xpos = true, ypos = true, xvelocity = true, yvelocity = true, xsize = true, ysize = true, onground = true, coyotetimer = true, })
    table.insert(components,
        { xpos = 20, ypos = 1000 - 64, xsize = 64, ysize = 64, xvelocity = 250, yvelocity = 0, isonground = true, coyotetimer = 0 })
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

    table.insert(entities,
        { index = it_index, player = false, spawn = false, end_door = false, platforme = false, wall = true, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
    table.insert(components, { xpos = 550, ypos = 500, xsize = 20, ysize = 80 })
    it_index = it_index + 1

    table.insert(entities,
        { index = it_index, player = false, spawn = false, end_door = false, platforme = false, wall = true, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
    table.insert(components, { xpos = 700, ypos = 700, xsize = 20, ysize = 80 })
    it_index = it_index + 1

    world.gamestate = "running"
end

function love.load()
    love.window.setTitle("LOVE2D GAME")
    love.window.setMode(1000, 1000, { resizable = false })
    love.graphics.setBackgroundColor(0.5, 0.5, 0.5)

    shader = love.graphics.newShader("assets/shaders/shader.glsl")

    success, backgroundMusic = pcall(function()
        local music = love.audio.newSource("assets/musics/track.wav", "stream")
        -- music:setLooping(true)
        -- music:setVolume(0.5)
        -- music:play()
        return music
    end)

    if not success then
        print("Failed to load music: " .. tostring(backgroundMusic))
        backgroundMusic = nil
    end

    player_idle = love.graphics.newImage("assets/sprites/orange/idle.png")
    player_walking = love.graphics.newImage("assets/sprites/orange/walking.png")
end

function love.update(dt)
    dt = math.min(dt, 0.033)
    time = time + dt
    shader:send("time", time)
    if world.gamestate == "menu" then
        if love.keyboard.isDown("return") then
            gamestart()
        end
    end
    if world.gamestate == "running" then
        inputSystem()
        platformeCheckSystem()
        fallingSystem(dt)
        deplacementSystem(dt)
        frameUpdate(dt)
    end
end

function love.draw()
    -- love.graphics.setShader(shader)
    -- love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    -- love.graphics.setShader()
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

-- systeme de colision et plateforme

-- ecran titre
-- faire une intro ecrite
-- niveau aléatoire intéressants
-- faire un menu pause
--
-- fin ecrite ou scenete
-- transition entre les niveaux
-- definition du nombre de niveau à faire pour finir
