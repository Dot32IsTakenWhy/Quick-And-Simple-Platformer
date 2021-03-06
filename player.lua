function playerInitialise()
  player = {}
  player.x = 50
  player.y = 420
  player.xV = 0
  player.yV = 0
  player.balloon = 0 -- How inflated is the character? (this is edited when collecting coins)
  player.size = 20
  player.collision = 0
  player.canJump = true
  player.cyoteTime = 5 -- how many frames can the player jump after leaving a platform?
  player.checkpoint = 1
  player.coinCache = {}
  player.deaths = 0
  player.deathWatch = 0

  player.coins = 0
  for i=1, #map.coins do -- loops through coins and gives them an "alive" tag
  	map.coins[i][4] = "alive"
  	player.coinCache[i] = "alive"
  end

  player.mesh = love.graphics.newMesh({
    {0, 0},       --middle
    {-1, -1.5},   --top left
    {1, -1.5},    --top right
    {1, 1.5},     --bottom right
    {-1, 1.5},    --bottom left
    {-1, -1.5}    --top left
    },"fan")
end

function playerUpdate()
  player.xV = player.xV * 0.93
  player.x = player.x + player.xV
  player.yV = player.yV + 1
  player.y = player.y + player.yV
  player.balloon = player.balloon + (0-player.balloon)*0.2
  player.cyoteTime = player.cyoteTime - 1
  player.deathWatch = player.deathWatch + 1

  if player.cyoteTime < 0 then 
  	player.canJump = false
  end

  player.collision = 0
  if player.y > 600 - player.size * 1.5 then
		player.collision = 2
		player.canJump = true
		player.cyoteTime = 5
		player.y = player.y - player.yV
		player.yV = -player.yV*0.3
	end

  for i=player.checkpoint+1, #map.checkpoints do
  	if player.x > map.checkpoints[i][1]-50 and player.y > map.checkpoints[i][2] - 50 then 
  		player.checkpoint = i
  		player.balloon = player.balloon + 10
  		for i=1, #map.coins do -- loops through coins and gives them an "alive" tag
  			player.coinCache[i] = map.coins[i][4]
  		end
  	end
  end

  for i=1, #map do
	  if map[i][1] == "ground" then
	    if
	    (player.y + player.size * 1.5 > map[i][3] and player.y - player.size * 1.5 < map[i][3] + map[i][5])
	    and
	    (player.x + player.size > map[i][2] and player.x - player.size < map[i][4]+map[i][2])
	    then
	      player.collision = 1
	    	if (player.x - player.xV + player.size > map[i][2] and player.x - player.xV - player.size < map[i][4]+map[i][2]) then
		      if player.yV > 0 then
		      	player.collision = 2
		      	player.canJump = true
		      	player.cyoteTime = 5
		      else
		      	player.collision = -1
		      end
		      player.y = player.y - player.yV
		      player.yV = -player.yV*0.3
	    	end
	    	if player.yV > 0 then 
	    		player.y = player.y + 5
	    	else
	    		player.y = player.y - 5
	    	end
	    	if (player.y - player.yV + player.size * 1.5 > map[i][3] and player.y - player.yV - player.size * 1.5 < map[i][3] + map[i][5]) then
		      player.x = player.x -player.xV
		      player.xV = -player.xV*0.3
		      if player.collision == 2 then
		      	player.collision = 4
		      end
		      player.collision = 3

	    	end
	    	if player.yV > 0 then 
	    		player.y = player.y - 5
	    	else
	    		player.y = player.y + 5
	    	end
	    end
	  elseif map[i][1] == "lava" then
	  	if
	    (player.y + player.size * 1.5 > map[i][3] and player.y - player.size * 1.5 < map[i][3] + map[i][5])
	    and
	    (player.x + player.size > map[i][2] and player.x - player.size < map[i][4]+map[i][2])
	    then
	  		player.yV = player.yV * 0.45
	  		player.yV = player.yV - 1
	  		player.xV = player.xV * 0.5
	  		screen.state = 2
	  	end
	  end
  end

  for i=1, #map.coins do
  	if distanceBetween(player.x, player.y, map.coins[i][1], map.coins[i][2]) < 30 then 
  		if map.coins[i][4] == "alive" then
  			player.coins = player.coins + 1
  			player.balloon = player.balloon + 5
  			--screen.shake = 2
  			map.coins[i][4] = "dead"
  			--particleCall("coin")
  		end
  	end
  end

	if screen.state == 1 then
	  if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
	    player.xV = player.xV - 1.2
	  end
	  if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
	    player.xV = player.xV + 1.2
	  end
	  if love.keyboard.isDown("w") or love.keyboard.isDown("up") or love.keyboard.isDown("space") then
	    if player.canJump == true then --player.collision == 2 or player.collision == 4 then
	      player.yV = -15
	      screen.shake = 2
	      player.canJump = false
        --player.balloon = player.balloon + 5
	      --particleCall("jump")
	    end
	  end
	end
  if love.keyboard.isDown("r") then
    if player.deathWatch > 20 then
      playerDie()
      screen.state = 1
    end
  end
end

function playerDraw()
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.draw(player.mesh, player.x + screen.x + screen.shakeX, player.y + screen.y + screen.shakeY, nil--[[player.xV*0.7*math.pi/180]] ,player.size + player.balloon)
  if map.alpha < 1 then
  	love.graphics.print("\n\nY= "..player.y, love.graphics.getWidth()/8, 50)
  	love.graphics.print("\n\n\nX= "..player.x, love.graphics.getWidth()/8, 50)
  end
end

function distanceBetween(x1, y1, x2, y2)
  return math.sqrt((y2-y1)^2 + (x2-x1)^2)
end

function playerDie()
	player.x = map.checkpoints[player.checkpoint][1]
	player.y = map.checkpoints[player.checkpoint][2]
	player.xV = 0
  player.yV = 0
  player.balloon = 0
  player.size = 20
  player.collision = 0
  player.canJump = true
  player.cyoteTime = 5
  player.deaths = player.deaths + 1
  player.deathWatch = 0

  player.coins = 0
  for i=1, #map.coins do
  	map.coins[i][4] = player.coinCache[i]
  	if player.coinCache[i] == "dead" then 
  		player.coins = player.coins + 1
  	end
  end
end