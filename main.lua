local bump = require 'bump'

padding = 20
ball_size = 10
speed = 100
paddle_speed = 500
keyboard_speed = 500
hud_height = 50
players = {}

local ballBumpFilter = function(item, other)
  return 'bounce'
end

function love.load()
  love.window.setFullscreen(true)
  width, height = love.graphics.getDimensions()
  height = height - hud_height
  world = bump.newWorld()

  local player_1 = {
    x = padding,
    y = height / 2,
    width = 5,
    height = 100,
    score = 0
  }
  table.insert(players, player_1)

  local player_2 = {
    x = width - padding - 5, -- paddle_width
    y = height / 2,
    width = 5,
    height = 50,
    score = 0
  }
  table.insert(players, player_2)

  local player_3 = {
    x = padding * 2,
    y = height / 2,
    width = 5,
    height = 200
  }
  table.insert(players, player_3)

  for i, player in ipairs(players) do
    world:add(player, player.x, player.y, player.width, player.height)
  end

  -- add invisible top & bottom walls
  local top_wall = {x = 0, y = 0}
  local bottom_wall = {x = 0, y = height}
  world:add(top_wall, 0,0, width, 1)
  world:add(bottom_wall, 0,height, width, 1)

  ball = {
    x = width/2,
    y = height/2,
    dx = -5 * speed,
    dy = 2 * speed
  }
  world:add(ball, ball.x, ball.y, ball_size, ball_size)  

  local joysticks = love.joystick.getJoysticks()
  joystick_1 = joysticks[1]
  joystick_2 = joysticks[2]
end

function love.update(dt)
  local actualX, actualY, cols, len = world:move(ball, ball.x + dt * ball.dx, ball.y + dt * ball.dy, ballBumpFilter)
  ball.x = actualX
  ball.y = actualY
  if #cols > 0 then
    local norm = cols[1].normal
      print(norm.x, norm.y)
      if norm.x == 1 or norm.x == -1 then
        ball.dx = -ball.dx
      end
      if norm.y == 1 or norm.y == -1 then
        ball.dy = -ball.dy
      end
  end

  -- someone lost/won, start over
  if ball.x < 0 or ball.x > width then
    if ball.x < 0 then
      players[2].score = players[2].score + 1
    else
      players[1].score = players[1].score + 1
    end
    ball.x = width / 2
  end

  local min = 0
  local max = height
  if joystick_1 then
    players[1].y = clamp(players[1].y + paddle_speed * dt * joystick_1:getGamepadAxis("lefty"), min, height - players[3].height)
    world:move(players[1], players[1].x, players[1].y)
  end
  if joystick_2 then
    players[3].y = clamp(players[3].y + paddle_speed * dt * joystick_2:getGamepadAxis("lefty"), min, height - players[3].height)
    world:move(players[3], players[3].x, players[3].y)
  end
  if love.keyboard.isDown('up') then
    players[2].y = clamp(players[2].y - keyboard_speed * dt, min, height - players[2].height)
    world:move(players[2], players[2].x, players[2].y)
  end
  if love.keyboard.isDown('down') then
    players[2].y = clamp(players[2].y + keyboard_speed * dt, min, height - players[2].height)
    world:move(players[2], players[2].x, players[2].y)
  end
end

function love.draw()
  for i, player in ipairs(players) do
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
  end
  love.graphics.rectangle("fill", ball.x, ball.y, ball_size, ball_size)
  love.graphics.print(players[1].score, padding, height + 5)
  love.graphics.print(players[2].score, width - padding - 50, height + 5)
end

function love.keyreleased(key)
   if key == "escape" then
      love.event.quit()
   end
end

function clamp(val, min, max)
  if val < min then
    return min
  end
  if val > max then
    return max
  end
  return val
end