
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function gotoGame()
	composer.gotoScene("game")
end

local function gotoHighScores()
	composer.gotoScene("highscores")
end
local musicTrack

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local background = display.newImageRect(sceneGroup, "asset/image/background.png", 800, 1400)
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	local title = display.newImageRect(sceneGroup, "asset/image/title.png", 500,80)
	title.x = display.contentCenterX
	title.y = 200
	local otherText = display.newText( sceneGroup, "I love 5am club", display.contentCenterX, 500, native.systemFont, 50 )
    otherText:setFillColor( 0.82, 0.86, 1 )
	local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, 700, native.systemFont, 44 )
    playButton:setFillColor( 0.82, 0.86, 1 )
 
    local highScoresButton = display.newText( sceneGroup, "High Scores", display.contentCenterX, 810, native.systemFont, 44 )
    highScoresButton:setFillColor( 0.75, 0.78, 1 )
	playButton:addEventListener( "tap", gotoGame )
    highScoresButton:addEventListener( "tap", gotoHighScores )
	musicTrack = audio.loadStream("asset/audio/Escape_Looping.wav")
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		-- Start the music!
		audio.play( musicTrack, { channel=1, loops=-1 } )

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		audio.stop(1)
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
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
