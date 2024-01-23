-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local composer = require("composer")
local scene = composer.newScene()

local physics = require("physics")
physics.start()
physics.setGravity(0,0)

math.randomseed(os.time())

local lives = 3
local score = 0
local died = false

local asteroidsTable = {}

local ship
local gameLoopTimer
local livesText
local scoreText

local backGroup 
local mainGroup 
local uiGroup 

local explosionSound
local fireSound
local musicTrack

--[[
local background = display.newImageRect(backGroup, "asset/image/background.png", 800,1400)
background.x = display.contentCenterX
background.y = display.contentCenterY

ship = display.newImageRect(mainGroup, "asset/image/jet.png", 98,79)
ship.x = display.contentCenterX
ship.y = display.contentHeight - 100
physics.addBody(ship, {radius = 30, isSensor=true})
ship.myName = "ship"

-- Display lives and score
livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 36 )
scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36 )
]]
display.setStatusBar(display.HiddenStatusBar)

local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

local function createAsteroid()
    local asteroidSeed = math.random(3)
    local newAsteroid
    if (asteroidSeed == 1) then
        newAsteroid = display.newImageRect(mainGroup, "asset/image/a.png", 102,85)
    elseif (asteroidSeed == 2) then
        newAsteroid = display.newImageRect(mainGroup, "asset/image/b.png", 102,85)
    elseif (asteroidSeed == 3) then 
        newAsteroid = display.newImageRect(mainGroup, "asset/image/c.png", 102,85)
    end
    table.insert(asteroidsTable, newAsteroid)
    physics.addBody( newAsteroid, "dynamic", { radius=40, bounce=0.8 } )
    newAsteroid.myName = "asteroid"

    local whereFrom = math.random(3)
    if ( whereFrom == 1 ) then
        -- From the left
        newAsteroid.x = -60
        newAsteroid.y = math.random( 500 )
        newAsteroid:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
    elseif ( whereFrom == 2 ) then
        -- From the top
        newAsteroid.x = math.random( display.contentWidth )
        newAsteroid.y = -60
        newAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    elseif ( whereFrom == 3 ) then
        -- From the right
        newAsteroid.x = display.contentWidth + 60
        newAsteroid.y = math.random( 500 )
        newAsteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    end
    newAsteroid:applyTorque( math.random( -6,6 ) )
end

local function fireLaser()

    audio.play(fireSound)

    local newLaser = display.newImageRect(mainGroup, "asset/image/beam.png", 14,40)
    physics.addBody(newLaser, "dynamic", {isSensor=true})
    newLaser.isBullet = true
    newLaser.myName = "laser"
    newLaser.x = ship.x
    newLaser.y = ship.y
    newLaser:toBack()
    transition.to( newLaser, { y=-40, time=500,
    onComplete = function() display.remove( newLaser ) end
    } ) 
end



local function dragShip (event)

    local ship = event.target
    local phase = event.phase
    if ("began" == phase) then
        display.currentStage:setFocus(ship)
        ship.touchOffsetX = event.x - ship.x
    elseif ("moved" == phase) then
        ship.x = event.x - ship.touchOffsetX
    elseif ("ended" == phase or "cancelled" == phase) then
        display.currentStage:setFocus(nil)
    end

    return true
end



local function gameLoop()
    createAsteroid()
    for i = #asteroidsTable, 1, -1 do
        local thisAsteroid = asteroidsTable[i]
 
        if ( thisAsteroid.x < -100 or
             thisAsteroid.x > display.contentWidth + 100 or
             thisAsteroid.y < -100 or
             thisAsteroid.y > display.contentHeight + 100 )
        then
            display.remove( thisAsteroid )
            table.remove( asteroidsTable, i )
        end
    end
end



local function restoreShip()
    ship.isBodyActive = false
    ship.x = display.contentCenterX
    ship.y = display.contentHeight - 100

    transition.to( ship, {alpha = 1, time=4000,
        onComplete = function()
            ship.isBodyActive = true
            died = false
        end
    })
end

local function endGame()
    composer.setVariable("finalScore", score)
    composer.gotoScene("highscores", {time=800, effect="crossFade"} )
end

local function onCollision(event)
    if (event.phase == "began" ) then
        local obj1 = event.object1
        local obj2 = event.object2

        if ( (obj1.myName == "laser" and obj2.myName == "asteroid" ) or
             (obj1.myName == "asteroid" and obj2.myName == "laser" ) )
        then
            -- remove the laser and t he asteroid
            display.remove(obj1)
            display.remove(obj2)

            -- play the explosion sound
            audio.play(explosionSound)

            for i = #asteroidsTable, 1,-1 do
                if (asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2) then
                    table.remove( asteroidsTable, i)
                    break
                end
            end
            -- Increase score
            score = score + 100
            scoreText.text = "Score: "..score
        
        elseif ( ( obj1.myName == "ship" and obj2.myName == "asteroid") or 
                (obj1.myName == "asteroid" and obj2.myName == "ship" ))
        then
            if ( died == false) then
                died = true

                audio.play(explosionSound)
                -- Update lives
                lives = lives - 1
                livesText.text = "Lives: "..lives

                if ( lives == 0 ) then 
                    display.remove (ship)
                    timer.performWithDelay(2000, endGame)
                else
                    ship.alpha = 0
                    timer.performWithDelay(1000, restoreShip )
                end 
            end
        end
    end
end


-----------------------------------------
-- scene event functions
-----------------------------------------

function scene:create(event)
    local sceneGroup = self.view
    physics.pause()
    -- Set up display groups
    backGroup = display.newGroup()  -- Display group for the background image
    sceneGroup:insert( backGroup )  -- Insert into the scene's view group
    
    mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
    sceneGroup:insert( mainGroup )  -- Insert into the scene's view group
    
    uiGroup = display.newGroup()    -- Display group for UI objects like the score
    sceneGroup:insert( uiGroup )    -- Insert into the scene's view group
    -- Load the background
    local background = display.newImageRect( backGroup, "asset/image/background.png", 800, 1400 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY


    ship = display.newImageRect(mainGroup, "asset/image/jet.png", 98,79)
    ship.x = display.contentCenterX
    ship.y = display.contentHeight - 100
    physics.addBody(ship, {radius = 30, isSensor=true})
    ship.myName = "ship"

    -- Display lives and score
    livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 36 )
    scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36 )
    ship:addEventListener( "tap", fireLaser )
    ship:addEventListener("touch", dragShip)
    explosionSound = audio.loadSound("asset/audio/explosion.wav")
    fireSound = audio.loadSound("asset/audio/fire.wav")
    musicTrack = audio.loadStream("asset/audio/80s-Space-Game_Looping.wav")

end
--show()
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        physics.start()
        
        Runtime: addEventListener("collision", onCollision)
        gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
        -- start the music
        audio.play(musicTrack, {channel = 1, loops = -1})
    end
end

--hide()
function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        timer.cancel(gameLoopTimer)
    
    elseif (phase == "did" ) then
        Runtime: removeEventListener("collision", onCollision)
        physics.pause()
        audio.stop(1)
        composer.removeScene("game")
    end
end

-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
    audio.dispose(explosionSound)
    audio.dispose(fireSound)
    audio.dispose(musicTrack)
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
