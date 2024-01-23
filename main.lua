local composer = require("composer")

display.setStatusBar(display.HiddenStatusBar)

math.randomseed(os.time())

audio.reserveChannels(1)
-- Reduce the overall volume of the channel
audio.setVolume( 0.5, { channel=1 } )

composer.gotoScene("menu")

