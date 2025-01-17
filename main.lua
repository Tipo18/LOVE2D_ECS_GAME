-- main.lua
-- Trying to create a ECS system from scratch in love2D
-- love.load -> love.update -> love.draw

local love = require "love"

function load_music()
    local success, backgroundMusic = pcall(function()
        local music = love.audio.newSource("assets/musics/track.wav", "stream")
        music:setLooping(true)
        music:setVolume(0.5)
        music:play()
        return music
    end)
    if not success then
        print("Failed to load music: " .. tostring(backgroundMusic))
        backgroundMusic = nil
    end
end

function love.load()
    love.window.setTitle("REST ROOM")
    love.window.setMode(1000, 1000, { resizable = false })
    regularTexte = love.graphics.setNewFont("assets/fonts/PixelifySans-Regular.ttf", 40)
    tittleTexte = love.graphics.setNewFont("assets/fonts/PixelifySans-Bold.ttf", 100)
    shader = love.graphics.newShader("assets/shaders/shader.glsl")
    load_music()
    player_idle = love.graphics.newImage("assets/sprites/orange/idle.png")
    player_walking = love.graphics.newImage("assets/sprites/orange/walking.png")

    world = {
        game_state = "menu", -- menu / intro / running / transition / paused / end
        level = -0,
        frame = 1,
        frame_timer = 0,
        shader_time = 0,
        swictch_screen_delay = 0,
    }

    walking = false
    entities = {}
    components = {}
    systems = {}

    startx = 0
    starty = O
end

local function walking_sprite_animation()
    if walking then
        local quad = love.graphics.newQuad((world.frame - 1) * 64, 0, 64, 64, player_walking:getWidth(),
            player_walking:getHeight())
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
                walking_sprite_animation()
            else
                love.graphics.rectangle(affichage, components[index].xpos, components[index].ypos,
                    components[index].xsize,
                    components[index].ysize)
            end
        end
    end
end

local function init1()
    local it_index = 1
    -- joueur
    table.insert(entities,
        { index = it_index, player = true, spawn = false, end_door = false, platforme = false, wall = false, display = true, xpos = true, ypos = true, xvelocity = true, yvelocity = true, xsize = true, ysize = true, onground = true, coyotetimer = true, })
    table.insert(components,
        { xpos = 20 + 120 / 2 - 68 / 2 - 4, ypos = 1000 - 64, xsize = 64, ysize = 64, xvelocity = 250, yvelocity = 0, isonground = true, coyotetimer = 0 })
    startx = 20 + 120 / 2 - 68 / 2 - 4
    starty = 1000 - 64
    it_index = it_index + 1
    -- spawn
    table.insert(entities,
        { index = it_index, player = false, spawn = true, end_door = false, platforme = false, wall = false, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
    table.insert(components, { xpos = 20 + 120 / 2 - 68 / 2, ypos = 1000 - 20 - 80, xsize = 68, ysize = 80 })
    it_index = it_index + 1
    -- end_door
    table.insert(entities,
        { index = it_index, player = false, spawn = false, end_door = true, platforme = false, wall = false, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
    table.insert(components, { xpos = 20 + 140 * 6 + 120 / 2 - 68 / 2, ypos = 1000 - 20 - 80, xsize = 68, ysize = 80 })
    it_index = it_index + 1

    local plateforme =
    {
        { 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 1, 1, 0, 0 },
        { 0, 1, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0 },
        { 1, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 1 },
        { 0, 0, 1, 0, 0, 0, 0 },
        { 1, 1, 1, 1, 1, 1, 1 }
    }
    local wall =
    {
        { 0, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 1, 0, 0, 0 },
        { 0, 0, 0, 0, 1, 0, 0, 0 },
        { 0, 0, 0, 0, 1, 0, 0, 0 },
        { 0, 0, 0, 0, 1, 0, 0, 0 },
        { 1, 0, 0, 0, 1, 0, 0, 1 },
        { 1, 0, 0, 0, 1, 0, 0, 1 },
    }
    for i = 1, 8 do
        for j = 1, 7 do
            if plateforme[i][j] == 1 then
                table.insert(entities,
                    { index = it_index, player = false, spawn = false, end_door = false, platforme = true, wall = true, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
                table.insert(components,
                    { xpos = 20 + (120 + 20) * (j - 1), ypos = (i - 1) * (120 + 20), xsize = 120, ysize = 20 })
                it_index = it_index + 1
            end
            if wall[j][i] == 1 then
                table.insert(entities,
                    { index = it_index, player = false, spawn = false, end_door = false, platforme = true, wall = true, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
                table.insert(components,
                    { xpos = (i - 1) * (120 + 20), ypos = 20 + (120 + 20) * (j - 1), xsize = 20, ysize = 120 })
                it_index = it_index + 1
            end
        end
    end
end

local function init2()
    local it_index = 1
    -- joueur
    table.insert(entities,
        { index = it_index, player = true, spawn = false, end_door = false, platforme = false, wall = false, display = true, xpos = true, ypos = true, xvelocity = true, yvelocity = true, xsize = true, ysize = true, onground = true, coyotetimer = true, })
    table.insert(components,
        { xpos = 20 + 120 / 2 - 68 / 2 - 4, ypos = (3 - 1) * (120 + 20) - 64, xsize = 64, ysize = 64, xvelocity = 250, yvelocity = 0, isonground = true, coyotetimer = 0 })
    startx = 20 + 120 / 2 - 68 / 2 - 4
    starty = (3 - 1) * (120 + 20) - 64
    it_index = it_index + 1
    -- spawn
    table.insert(entities,
        { index = it_index, player = false, spawn = true, end_door = false, platforme = false, wall = false, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
    table.insert(components, { xpos = 20 + 120 / 2 - 68 / 2, ypos = (3 - 1) * (120 + 20) - 80, xsize = 68, ysize = 80 })
    it_index = it_index + 1
    -- end_door
    table.insert(entities,
        { index = it_index, player = false, spawn = false, end_door = true, platforme = false, wall = false, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
    table.insert(components,
        { xpos = 20 + 140 * 6 + 120 / 2 - 68 / 2, ypos = (6 - 1) * (120 + 20) - 80, xsize = 68, ysize = 80 })
    it_index = it_index + 1

    local plateforme =
    {
        { 0, 0, 0, 1, 0, 0, 0 },
        { 1, 0, 0, 0, 1, 0, 0 },
        { 1, 1, 1, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 1, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 1 },
        { 0, 1, 0, 0, 0, 1, 0 },
        { 0, 0, 0, 1, 0, 0, 0 }
    }
    local wall =
    {
        { 0, 0, 0, 0, 1, 0, 0, 0 },
        { 1, 0, 0, 0, 0, 1, 0, 0 },
        { 0, 0, 0, 0, 0, 1, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0, 1 },
        { 0, 1, 0, 0, 0, 0, 1, 0 },
        { 0, 0, 0, 0, 0, 0, 0, 0 },
    }
    for i = 1, 8 do
        for j = 1, 7 do
            if plateforme[i][j] == 1 then
                table.insert(entities,
                    { index = it_index, player = false, spawn = false, end_door = false, platforme = true, wall = true, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
                table.insert(components,
                    { xpos = 20 + (120 + 20) * (j - 1), ypos = (i - 1) * (120 + 20), xsize = 120, ysize = 20 })
                it_index = it_index + 1
            end
            if wall[j][i] == 1 then
                table.insert(entities,
                    { index = it_index, player = false, spawn = false, end_door = false, platforme = true, wall = true, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
                table.insert(components,
                    { xpos = (i - 1) * (120 + 20), ypos = 20 + (120 + 20) * (j - 1), xsize = 20, ysize = 120 })
                it_index = it_index + 1
            end
        end
    end
end

local function init3()
    local it_index = 1
    -- joueur
    table.insert(entities,
        { index = it_index, player = true, spawn = false, end_door = false, platforme = false, wall = false, display = true, xpos = true, ypos = true, xvelocity = true, yvelocity = true, xsize = true, ysize = true, onground = true, coyotetimer = true, })
    table.insert(components,
        { xpos = 20 + (120 + 20) * 6 + 120 / 2 - 68 / 2 - 4, ypos = (8 - 1) * (120 + 20) - 100, xsize = 64, ysize = 64, xvelocity = 250, yvelocity = 0, isonground = true, coyotetimer = 0 })
    startx = 20 + (120 + 20) * 6 + 120 / 2 - 68 / 2 - 4
    starty = (8 - 1) * (120 + 20) - 100
    it_index = it_index + 1
    -- spawn
    table.insert(entities,
        { index = it_index, player = false, spawn = true, end_door = false, platforme = false, wall = false, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
    table.insert(components,
        { xpos = 20 + (140) * 6 + 120 / 2 - 68 / 2, ypos = (8 - 1) * (120 + 20) - 80, xsize = 68, ysize = 80 })
    it_index = it_index + 1
    -- end_door
    table.insert(entities,
        { index = it_index, player = false, spawn = false, end_door = true, platforme = false, wall = false, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
    table.insert(components,
        { xpos = 20 + 140 * 5 + 120 / 2 - 68 / 2, ypos = (2 - 1) * (120 + 20) - 80, xsize = 68, ysize = 80 })
    it_index = it_index + 1

    local plateforme =
    {
        { 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 1, 0 },
        { 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 1, 0 },
        { 0, 0, 0, 0, 0, 0, 1 }
    }
    local wall =
    {
        { 0, 0, 0, 0, 0, 0, 1, 0 },
        { 0, 0, 1, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 1, 0, 0, 0 },
        { 1, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 1, 0, 0, 0 },
        { 0, 0, 1, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0, 1 },
    }
    for i = 1, 8 do
        for j = 1, 7 do
            if plateforme[i][j] == 1 then
                table.insert(entities,
                    { index = it_index, player = false, spawn = false, end_door = false, platforme = true, wall = true, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
                table.insert(components,
                    { xpos = 20 + (120 + 20) * (j - 1), ypos = (i - 1) * (120 + 20), xsize = 120, ysize = 20 })
                it_index = it_index + 1
            end
            if wall[j][i] == 1 then
                table.insert(entities,
                    { index = it_index, player = false, spawn = false, end_door = false, platforme = true, wall = true, display = true, xpos = true, ypos = true, xsize = true, ysize = true })
                table.insert(components,
                    { xpos = (i - 1) * (120 + 20), ypos = 20 + (120 + 20) * (j - 1), xsize = 20, ysize = 120 })
                it_index = it_index + 1
            end
        end
    end
end

local function start_level()
    world.level = world.level + 1
    entities = {}
    components = {}
    if world.level == 1 then
        init1()
    elseif world.level == 2 then
        init2()
    elseif world.level == 3 then
        init3()
    end
    world.game_state = "running"
    world.swictch_screen_delay = 0
end

local function collisionPlatformDeplacementSysteme(dt)
    if not components[10] or not components[1].xvelocity or not components[1].yvelocity then
        return -- Skip processing if the player component is invalid
    end

    if components[1].ypos > 1000 then
        components[1].xpos = startx
        components[1].ypos = starty
    end

    local grav = 1050
    if components[1].yvelocity <= 0 then
        grav = grav * 2
    end

    local block_xmove = false
    local block_ymove = false

    local next_xpos = components[1].xpos + math.floor(components[1].xvelocity * dt + 0.5)
    local next_ypos = components[1].ypos + math.floor(components[1].yvelocity * dt + 0.5)

    for _, entity in ipairs(entities) do
        if entity.wall or entity.end_door then
            if entity.wall then
                if next_xpos < components[entity.index].xpos + components[entity.index].xsize and
                    next_xpos + components[1].xsize > components[entity.index].xpos and
                    next_ypos < components[entity.index].ypos + components[entity.index].ysize and
                    next_ypos + components[1].ysize > components[entity.index].ypos then
                    local overlapX1 = (next_xpos + components[1].xsize) - components[entity.index].xpos
                    local overlapX2 = (components[entity.index].xpos + components[entity.index].xsize) - next_xpos
                    local penetrationX = math.min(overlapX1, overlapX2)

                    local overlapY1 = (next_ypos + components[1].ysize) - components[entity.index].ypos
                    local overlapY2 = (components[entity.index].ypos + components[entity.index].ysize) - next_ypos
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
                            components[1].ypos = components[entity.index].ypos -
                                components[1]
                                .ysize
                        else
                            components[1].ypos = components[entity.index].ypos +
                                components[entity.index]
                                .ysize
                        end
                    end
                end
            else
                if next_xpos < components[entity.index].xpos + components[entity.index].xsize - 30 and
                    next_xpos + components[1].xsize > components[entity.index].xpos + 30 and
                    next_ypos < components[entity.index].ypos + components[entity.index].ysize - 30 and
                    next_ypos + components[1].ysize > components[entity.index].ypos + 30 then
                    components[1].xvelocity = 0
                    block_xmove = true
                    components[1].xvelocity = 0
                    block_xmove = true
                    components[1].xpos = components[entity.index].xpos + 2
                    components[1].ypos = components[entity.index].ypos + 80 - 64
                    -- transition
                    -- switch screen delay not fully working
                    world.swictch_screen_delay = 0
                    if world.level == 3 then
                        world.game_state = "end"
                    else
                        world.game_state = "transition"
                        start_level()
                        return
                    end
                end
            end
        end
    end
    walking = components[1].xvelocity ~= 0
    local verif_plat = 0
    if not block_xmove and not block_ymove then
        for _, entity in ipairs(entities) do
            if entity.platforme then
                if next_xpos < components[entity.index].xpos + components[entity.index].xsize and
                    next_xpos + components[1].xsize > components[entity.index].xpos and
                    next_ypos < components[entity.index].ypos + components[entity.index].ysize and
                    next_ypos + components[1].ysize >= components[entity.index].ypos then
                    entities[1].onground = true
                    components[1].yvelocity = 0
                    block_ymove = true
                    components[1].ypos = components[entity.index].ypos - components[1].ysize
                    verif_plat = entity.index
                end
            end
        end
    end

    entities[1].onground = verif_plat ~= 0

    if entities[1].onground == false then
        components[1].yvelocity = components[1].yvelocity + grav * dt
        components[1].yvelocity = math.min(components[1].yvelocity, 1400)
        components[1].coyotetimer = components[1].coyotetimer + dt
    else
        components[1].yvelocity = 0
        components[1].coyotetimer = 0
    end

    if not block_xmove then
        components[1].xpos = next_xpos
        components[1].xvelocity = 0
    end
    if not block_ymove then
        components[1].ypos = next_ypos
    end
end

local function frameUpdate(dt)
    world.frame_timer = world.frame_timer + dt
    if world.frame_timer > 0.1 then
        if world.frame == 1 then
            world.frame = 2
        else
            world.frame = 1
        end
        world.frame_timer = 0
    end
end

local function inputSystem()
    if love.keyboard.isDown("return") then
        if world.game_state == "menu" then
            world.game_state = "intro"
            world.swictch_screen_delay = 0
        elseif world.game_state == "intro" and world.swictch_screen_delay > 0.2 then
            start_level()
        end
    end

    if love.keyboard.isDown("p") then
        if world.game_state == "running" and world.swictch_screen_delay > 0.2 then
            world.game_state = "paused"
            world.swictch_screen_delay = 0
        elseif world.game_state == "paused" and world.swictch_screen_delay > 0.2 then
            world.game_state = "running"
            world.swictch_screen_delay = 0
        end
    end

    if world.game_state == "running" then
        if love.keyboard.isDown("right") then
            components[1].xvelocity = 300
        end
        if love.keyboard.isDown("left") then
            components[1].xvelocity = -300
        end
        if love.keyboard.isDown("space") then
            if entities[1].onground or components[1].coyotetimer <= 0.1 then
                components[1].yvelocity = -1100
                entities[1].onground = false
                components[1].coyotetimer = components[1].coyotetimer + 1
            end
        end
    end
end

function love.update(dt)
    dt = math.min(dt, 0.033)
    world.shader_time = world.shader_time + dt
    shader:send("time", world.shader_time)
    world.swictch_screen_delay = world.swictch_screen_delay + dt
    if not (world.game_state == "transition") then
        inputSystem()
        if world.game_state == "running" and world.swictch_screen_delay >= 0 then
            collisionPlatformDeplacementSysteme(dt)
            frameUpdate(dt)
        end
    end
end

function love.draw()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    love.graphics.setShader(shader)
    love.graphics.rectangle("fill", 0, 0, width, height)
    love.graphics.setShader()
    if world.game_state == "menu" then
        local text = "Press Enter to start / P to resume"
        love.graphics.setFont(regularTexte)
        love.graphics.print(text, width / 2 - love.graphics.getFont():getWidth(text) / 2, height * (4 / 5))

        text = "Rest Room"
        love.graphics.setFont(tittleTexte)
        love.graphics.print(text, width / 2 - love.graphics.getFont():getWidth(text) / 2, height * (2 / 5))
    elseif world.game_state == "intro" then
        local text = "after a long shift you're trying to go to the rest room but your a bit lost . . ."
        love.graphics.setFont(regularTexte)
        love.graphics.printf(text, 80, 450, 900, 'left')
    elseif world.game_state == "running" then
        if world.swictch_screen_delay > 0 then
            renderSystem()
        end
    elseif world.game_state == "paused" then
        print("paused")
        local text = "You didn't reach you goal yet, you'll have time to rest there"
        love.graphics.setFont(regularTexte)
        love.graphics.printf(text, 80, 650, 800, 'center')

        text = "Pause"
        love.graphics.setFont(tittleTexte)
        love.graphics.print(text, width / 2 - love.graphics.getFont():getWidth(text) / 2, height * (2 / 5))
    elseif world.game_state == "end" and world.swictch_screen_delay > 0.3 then
        local text = "well done you finaly reach the rest room, you now can truly enjoy your break"
        love.graphics.setFont(regularTexte)
        love.graphics.printf(text, 80, 475, 900, 'left')
    end
end
