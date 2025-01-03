-- -- main.lua

local love = require "love"

local player = { x = 100, y = 100, speed = 200 }

local game = {
    state = {
        menu = true,
        paused = false,
        running = false,
    }
}

local fonts = {
    medium = {
        font = love.graphics.newFont(16),
        size = 16
    },
    large = {
        font = love.graphics.newFont(24),
        size = 24
    },
    massive = {
        font = love.graphics.newFont(60),
        size = 60
    }
}


-- Button class
local Button = {}
Button.__index = Button

function Button.new(text, callback, callbackArg, width, height)
    local self = setmetatable({}, Button)
    self.text = text
    self.callback = callback
    self.callbackArg = callbackArg
    self.width = width
    self.height = height
    self.hovered = false
    return self
end

function Button:draw(x, y, textXOffset, textYOffset)
    self.x = x
    self.y = y
    local color = self.hovered and { 0.8, 0.8, 0.8 } or { 0.7, 0.7, 0.7 }
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, self.width, self.height)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.text, x + textXOffset, y + textYOffset)
    love.graphics.setColor(1, 1, 1)
end

function Button:checkHover(mx, my)
    self.hovered = mx >= self.x and mx <= self.x + self.width and
        my >= self.y and my <= self.y + self.height
    return self.hovered
end

function Button:click()
    if self.callback then
        if self.callbackArg then
            self.callback(self.callbackArg)
        else
            self.callback()
        end
    end
end

local function button(text, callback, callbackArg, width, height)
    return Button.new(text, callback, callbackArg, width, height)
end

local buttons = {
    menu_state = {},
    ended_state = {}
}

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        if game.state["menu"] then
            for _, btn in pairs(buttons.menu_state) do
                if btn:checkHover(x, y) then
                    btn:click()
                    break
                end
            end
        elseif game.state["ended"] then
            for _, btn in pairs(buttons.ended_state) do
                if btn:checkHover(x, y) then
                    btn:click()
                    break
                end
            end
        end
    end
end

function love.mousemoved(x, y)
    if game.state["menu"] then
        for _, btn in pairs(buttons.menu_state) do
            btn:checkHover(x, y)
        end
    elseif game.state["ended"] then
        for _, btn in pairs(buttons.ended_state) do
            btn:checkHover(x, y)
        end
    end
end

local function changeGameState(state)
    game.state["menu"] = state == "menu"
    game.state["paused"] = state == "paused"
    game.state["running"] = state == "running"
    game.state["ended"] = state == "ended"
end

local function startNewGame()
    changeGameState("running")
end

function love.load()
    love.window.setTitle("LOVE2D GAME")
    love.window.setMode(1200, 900, { resizable = false })

    buttons.menu_state.play_game = button("Play Game", startNewGame, nil, 120, 40)
    buttons.menu_state.settings = button("Settings", nil, nil, 120, 40)
    buttons.menu_state.exit_game = button("Exit Game", love.event.quit, nil, 120, 40)

    -- these buttons will be on the game over screen
    buttons.ended_state.replay_game = button("Replay", startNewGame, nil, 100, 50)
    buttons.ended_state.menu = button("Menu", changeGameState, "menu", 100, 50)
    buttons.ended_state.exit_game = button("Quit", love.event.quit, nil, 100, 50)

    function love.update(dt)
        if game.state["running"] then
            if love.keyboard.isDown("right") then
                player.x = player.x + player.speed * dt
            end
            if love.keyboard.isDown("left") then
                player.x = player.x - player.speed * dt
            end
            if love.keyboard.isDown("down") then
                player.y = player.y + player.speed * dt
            end
            if love.keyboard.isDown("up") then
                player.y = player.y - player.speed * dt
            end
        end
    end

    function love.draw()
        love.graphics.setFont(fonts.medium.font)
        love.graphics.printf("FPS: " .. love.timer.getFPS(), fonts.medium.font, 10, love.graphics.getHeight() - 30,
            love.graphics.getWidth())

        if game.state["running"] then
            love.graphics.rectangle("fill", player.x, player.y, 50, 50)
        elseif game.state["menu"] then
            local centerX = love.graphics.getWidth() / 2
            local centerY = love.graphics.getHeight() / 2
            buttons.menu_state.play_game:draw(centerX - 60, centerY - 100, 17, 10)
            buttons.menu_state.settings:draw(centerX - 60, centerY - 50, 17, 10)
            buttons.menu_state.exit_game:draw(centerX - 60, centerY, 17, 10)
        end
    end
end
