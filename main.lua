-- main.lua
-- Trying to create a ECS system from scratch in love2D

local love = require "love"

-- love.load -> love.update -> love.draw

function love.load()
    love.window.setTitle("LOVE2D GAME")
    love.window.setMode(1200, 900, { resizable = false })
end

function love.update()
    if love.keyboard.isDown("q") then
        love.event.quit()
    end
end

function love.draw()
    love.graphics.rectangle("fill", 100, 100, 50, 50)
end
