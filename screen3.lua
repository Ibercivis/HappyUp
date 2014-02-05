module(..., package.seeall)

--====================================================================--
-- SCENE: Main Menu Screen
--====================================================================--

--[[

 - Version: [1.0]
 - Made by: Eduardo Lostal

--]]

new = function (param)

	------------------
	-- Requires and definitions
	------------------
	require("ui")
        local Wrapper = require("wrapper")
        local http = require("socket.http")
        local ltn12 = require("ltn12")
        require "sqlite3"

        local db
        local dbPath = system.pathForFile("happyUpDB", system.DocumentsDirectory)
    
	display.setStatusBar(display.HiddenStatusBar)
	local x=display.contentWidth/2
        local y=display.contentHeight/2
	
        local bg
        local bgOverlapped
    
	local galaxy
	local big_stars
	local big_stars_dup
	local small_stars
        local small_stars_dup
	local cs
	local phraseLevelText
	--local levelText
        local levelNumber
        
        local trainerText
	local yesText
        local noText
	
	local rightButton
        local leftButton
        local haloRight
        local haloLeft
        
        local initUpdateLevel
        local updateLevelTimer
        local initCSAndNumberDown
        local spinHalo
    
        local screenSocialNetworks = false
        local closeButton
        
	------------------
	-- Groups
	------------------
	local localGroup = display.newGroup()
        
	------------------
	-- Functions
	------------------
    
    	-------------------------------------------
        -- Local Notification listener
        -------------------------------------------
        --
        local notificationListener = function( event )
	
            local paramNew = {currentStep=param.currentStep, currentQuestionnaire=param.currentQuestionnaire}
            director:changeScene(paramNew, "screen4")
        
        end

        -- Code to show Alert Box if applicationOpen event occurs
        -- (This shouldn't happen, but the code is here to prove the fact)
        function onSystemEvent( event )
	
            if "applicationOpen" == event.type then
                native.showAlert( "Open via custom url", event.url, { "OK" } )
            end
        end

        -- Add the System callback event and notification listener
        Runtime:addEventListener( "system", onSystemEvent )
        Runtime:addEventListener( "notification", notificationListener )

        function closeWindow(event)
            native.cancelWebPopup() 
            transition.to( closeButton, { time=1200, alpha=0} )
            transition.to( trainerText, { time=1200, alpha=1} )
            transition.to( rightButton, { time=1200, alpha=1} )
            transition.to( leftButton, { time=1200, alpha=1} )
            transition.to( haloRight, { time=1200, alpha=1} )
            transition.to( haloLeft, { time=1200, alpha=1} )
        end
            
            
        local function callTW()
            transition.to( closeButton, { time=1200, alpha=1} )
            transition.to( trainerText, { time=1200, alpha=0} )
            transition.to( rightButton, { time=1200, alpha=0} )
            transition.to( leftButton, { time=1200, alpha=0} )
            transition.to( haloRight, { time=1200, alpha=0} )
            transition.to( haloLeft, { time=1200, alpha=0} )

            local message = "Mi nivel de felicidad es del " .. levelNumber.value .. " por ciento. Descargate happyUp para tu movil, testea tu nivel de felicidad y entrenalo."
            local theString = string.gsub(message, "( )", "%%20")
            native.showWebPopup( 15,20,display.contentWidth *.9 ,display.contentHeight *.8, "https://twitter.com/intent/tweet?text=" ..theString)            
        end
            
        local function callFB ()
            transition.to( closeButton, { time=1200, alpha=1} )
            transition.to( trainerText, { time=1200, alpha=0} )
            transition.to( rightButton, { time=1200, alpha=0} )
            transition.to( leftButton, { time=1200, alpha=0} )
            transition.to( haloRight, { time=1200, alpha=0} )
            transition.to( haloLeft, { time=1200, alpha=0} )

            local message = "Mi nivel de felicidad es del " .. levelNumber.value .. " por ciento. Descargate happyUp para tu movil, testea tu nivel de felicidad y entrenalo."
            local theString = string.gsub(message, "( )", "%%20")
            native.showWebPopup( 15,20,display.contentWidth *.9 ,display.contentHeight *.8, "http://www.facebook.com/dialog/feed?&display=touch&redirect_uri=http://www.ibercivis.net&app_id=450887954998255&link=http://felicicomlab.usj.es&caption=HappyUp&picture=http://felicicomlab.usj.es/wp-content/uploads/2012/02/logo-felicity.png&description="..theString, {urlRequest=popupListener})
        end
        
        function removeTimers ()
            -- Cancel and release timers
            if not(updateLevelTimer == nil) then
                -- Check whether it is different to nil
                timer.cancel(updateLevelTimer); updateLevelTimer = nil;
            end
            if not(initUpdateLevel == nil) then
                -- Check whether it is different to nil
                timer.cancel(initUpdateLevel); initUpdateLevel = nil;
            end
            if not(initCSAndNumberDown == nil) then
                -- Check whether it is different to nil
                timer.cancel(initCSAndNumberDown); initCSAndNumberDown = nil;
            end
            if not(spinHalo == nil) then
                -- Check whether it is different to nil
                timer.cancel(spinHalo); spinHalo = nil;
            end
        end
        
	local touchedRightButton = function ( event )

            if event.phase == "ended" then
                if (screenSocialNetworks == true) then
                    -- Go to the screen to share with Facebook
                    callFB ()
                else
                    -- Go to the screen of the training
                    removeTimers()
                    
                    local paramNew = {currentStep=param.currentStep, currentQuestionnaire=param.currentQuestionnaire, finalResult=param.finalResult}
                    director:changeScene( paramNew, "screen5", "downflip" )
                end
            end
	end
    
	local touchedLeftButton = function ( event )

            if (screenSocialNetworks == true) then
                callTW ()
            else
                -- Enable filling the questionnaire again
                -- Open the database
                db = sqlite3.open(dbPath)
                -- Update the currentStep to enable next time the questionnaire
                param.currentStep = 0
                -- Update the current questionnaire number in the database, so the tutorial is skipped next time
                local q = "UPDATE f_prov SET p_currentStep="..param.currentStep.." WHERE p_id=0;"
                if not(db:exec(q) == sqlite3.OK) then
                    native.showAlert( "HappyUp", "Error updating the current step", { "Ok" } )
                    exit()
                end
                db:close()
        
                showSocialNetworkPart()
            end
	end
        
	-- Function to show social network buttons instead of the current buttons
        function showSocialNetworkPart ()
            
            -- Update the corresponding images
            rightButton:removeSelf()
            rightButton = ui.newButton{
                default = "multimedia/buttons/facebook.png",
                over = "multimedia/buttons/facebook_over.png",
		onRelease = touchedRightButton,
		id = "rightButton",
		text = "",
		font = "Times New Roman",
		size = 20
            }
    
            leftButton:removeSelf()
            leftButton = ui.newButton{
		default = "multimedia/buttons/twitter.png",
                over = "multimedia/buttons/twitter_over.png",
		onRelease = touchedLeftButton,
		id = "leftButton",
		text = "",
		font = "Times New Roman",
		size = 20
            }
            
            trainerText:removeSelf()
            trainerText = Wrapper:newParagraph({
                text = "Gracias por utilizar happyUp. Comparte tu resultado en Twitter y Facebook.",
                width = 170,
                height = 85, 			-- fontSize will be calculated automatically if set 
                font = "Prime", 	-- make sure the selected font is installed on your system
                fontSize = 14,			
                lineSpace = 2,
                alignment  = "center",
	
                -- Parameters for auto font-sizing
                fontSizeMin = 14,
                fontSizeMax = 20,
                incrementSize = 2
            })
            trainerText:setReferencePoint(display.CenterReferencePoint)
        
            yesText.text = ""
            noText.text = ""
            
            rightButton.x = display.contentWidth-40
            rightButton.y = display.contentHeight-50
            leftButton.x = 40
            leftButton.y = display.contentHeight-50
            trainerText.x = x
            trainerText.y = display.contentHeight-50
        
            -- Set the flag to true
            screenSocialNetworks = true
	end
    
        -- Function to keep the Big stars moving in the background
        function moveBigStars ( obj )
            
            obj.y = -y-200
            transition.to( obj, { time=60000, y=obj.y+2*display.contentHeight+400, onComplete=moveBigStars} )
            
        end

        -- Function to keep the small stars moving in the background
        function moveSmallStars ( obj )
            
            obj.y = -y-200
            transition.to( obj, { time=90000, y=obj.y+2*display.contentHeight+400, onComplete=moveSmallStars} )
            
        end
    
        -- Function called by a timer to update properly the level and related items
        function updateLevel ()
            
            -- Update the number    
            levelNumber.value = levelNumber.value +1
            levelNumber.text = levelNumber.value .. "%"
            
            -- Update the segments
            if (math.fmod(levelNumber.value, 7) == 0) then
                cs:nextFrame()
            end
        
            if (levelNumber.value == param.finalResult) then
                transition.to( phraseLevelText, { time=timeAux, alpha=1} )
                transition.to( trainerText, { time=timeAux, alpha=1} ) 
                transition.to( yesText, { time=timeAux, alpha=1} ) 
                transition.to( noText, { time=timeAux, alpha=1} ) 
                transition.to( rightButton, { time=timeAux, alpha=1} ) 
                transition.to( leftButton, { time=timeAux, alpha=1} )
                transition.to( haloRight, { time=timeAux, alpha=1} ) 
                transition.to( haloLeft, { time=timeAux, alpha=1} )
            end
        end
        
        function initUpdateLevelFunction ()
            updateLevelTimer = timer.performWithDelay (35, updateLevel, param.finalResult) 
        end
	
	function moveToCenter ()
            
            local timeAux = math.random(1000, 1400)
            
            transition.to( cs, { time=timeAux, y=y} )
            transition.to( levelNumber, { time=timeAux, y=y} ) 
            transition.to( galaxy, { time=timeAux, y=30} )
            
            -- Timer to control when to play the movieclip for the circular slider (once it reaches its position in the screen)
            initUpdateLevel = timer.performWithDelay (timeAux+100, function () transition.to( galaxy, { time=400000, y=display.contentHeight-70}) initUpdateLevelFunction() end, 1)
        end
	
	function transitionToDark ()
            
            local timeAux = math.random(2000, 2500)
            
            transition.to( bgOverlapped, { time=timeAux, alpha=0} )
            transition.to( galaxy, { time=timeAux, alpha=1} )
            transition.to( big_stars, { time=timeAux, alpha=1} )
            transition.to( big_stars_dup, { time=timeAux, alpha=1} )
            transition.to( small_stars, { time=timeAux, alpha=1} )
            transition.to( small_stars_dup, { time=timeAux, alpha=1} )
            
            transition.to( big_stars, { time=30000, y=big_stars.y+display.contentHeight+200, onComplete=moveBigStars})
            transition.to( big_stars_dup, { time=60000, y=big_stars_dup.y+2*display.contentHeight+400, onComplete=moveBigStars})
            transition.to( small_stars, { time=45000, y=small_stars.y+display.contentHeight+200, onComplete=moveSmallStars})
            transition.to( small_stars_dup, { time=90000, y=small_stars_dup.y+2*display.contentHeight+400, onComplete=moveSmallStars})
            
            -- Timer to control when the CS and the result go down
            initCSAndNumberDown = timer.performWithDelay (timeAux-500, moveToCenter, 1)
        end
        
	------------------
	-- Components
	------------------
	
	-- Load the background
	bg = display.newImage("multimedia/black_bg/black_bg.png")
        bgOverlapped = display.newImage("multimedia/background/background.jpg")
	
	galaxy = display.newImage("multimedia/black_bg/galaxy.png")
	big_stars = display.newImage("multimedia/black_bg/big_stars.png")
	big_stars_dup = display.newImage("multimedia/black_bg/big_stars.png")
	small_stars = display.newImage("multimedia/black_bg/small_stars.png")
	small_stars_dup = display.newImage("multimedia/black_bg/small_stars.png")
	
	cs = movieclip.newAnim{"multimedia/circular_slider_black/cs0.png", "multimedia/circular_slider_black/cs1.png", "multimedia/circular_slider_black/cs2.png", "multimedia/circular_slider_black/cs3.png", "multimedia/circular_slider_black/cs4.png", "multimedia/circular_slider_black/cs5.png", "multimedia/circular_slider_black/cs6.png", "multimedia/circular_slider_black/cs7.png", "multimedia/circular_slider_black/cs8.png", "multimedia/circular_slider_black/cs9.png", "multimedia/circular_slider_black/cs10.png", "multimedia/circular_slider_black/cs11.png", "multimedia/circular_slider_black/cs12.png", "multimedia/circular_slider_black/cs13.png", "multimedia/circular_slider_black/cs14.png"}
        cs:stopAtFrame(1)
    
	phraseLevelText = display.newText("Tu nivel de felicidad es del",x,30,"Prime",24)
        phraseLevelText:setReferencePoint(display.CenterReferencePoint)
        levelNumber = display.newText("0%",x,y,"Prime",100)
        levelNumber:setReferencePoint(display.CenterReferencePoint)
        levelNumber.value = 0
	        
	trainerText = Wrapper:newParagraph({
            text = "¿Quieres mejorar tu nivel de felicidad?",
            width = 180,
            height = 200, 			-- fontSize will be calculated automatically if set 
            font = "Prime", 	-- make sure the selected font is installed on your system
            fontSize = 20,			
            lineSpace = 2,
            alignment  = "center",
	
            -- Parameters for auto font-sizing
            fontSizeMin = 20,
            fontSizeMax = 20,
            incrementSize = 2
        })
        trainerText:setReferencePoint(display.CenterReferencePoint)
	yesText = display.newText("Sí",0,0,"Prime",18)
        yesText:setReferencePoint(display.CenterReferencePoint)
	noText = display.newText("No",0,0,"Prime",18)
        noText:setReferencePoint(display.CenterReferencePoint)
	
        rightButton = ui.newButton{
		default = "multimedia/buttons/next.png",
		over = "multimedia/buttons/next_over.png",
		onRelease = touchedRightButton,
		id = "rightButton",
		text = "",
		font = "Times New Roman",
		size = 20
	}
    
        leftButton = ui.newButton{
		default = "multimedia/buttons/next.png",
		over = "multimedia/buttons/next_over.png",
		onRelease = touchedLeftButton,
		id = "leftButton",
		text = "",
		font = "Times New Roman",
		size = 20
	}
	
	haloRight = display.newImage("multimedia/halo.png")
        haloLeft = display.newImage("multimedia/halo.png")
	
	closeButton = display.newImage("multimedia/logo.png")
        closeButton:addEventListener("touch",closeWindow)
                        
	------------------
	-- Inserts
	------------------
        localGroup:insert(bg)
        localGroup:insert(bgOverlapped)
    
	localGroup:insert(galaxy)
	localGroup:insert(big_stars)
	localGroup:insert(big_stars_dup)
	localGroup:insert(small_stars)
        localGroup:insert(small_stars_dup)
    
	localGroup:insert(cs)
	localGroup:insert(phraseLevelText)
        localGroup:insert(levelNumber)
        
        localGroup:insert(trainerText)
        localGroup:insert(yesText)
	localGroup:insert(noText)
        
        localGroup:insert(rightButton)
	localGroup:insert(leftButton)
	localGroup:insert(haloRight)
	localGroup:insert(haloLeft)
        localGroup:insert(closeButton)
        
	------------------
	-- Positions
	------------------
        bg.x = x
	bg.y = y
        bgOverlapped.x = x
        bgOverlapped.y = y
	cs.x = x
        cs.y = -y
        
	galaxy.x = x
        galaxy.y = -170
        galaxy.alpha = 0
        big_stars.x = x
        big_stars.y = y
        big_stars.alpha = 0
        big_stars_dup.x = x
	big_stars_dup.y = -y-200
        big_stars_dup.alpha = 0
        small_stars.x = x
        small_stars.y = y
        small_stars.alpha = 0
        small_stars_dup.x = x
	small_stars_dup.y = -y-200
        small_stars.alpha = 0
    
        phraseLevelText.x = x
        phraseLevelText.y = 50
        phraseLevelText.alpha = 0
        levelNumber.x = x
        levelNumber.y = -y
        
	trainerText.x = x
	trainerText.y = display.contentHeight-50
	trainerText.alpha = 0
	yesText.x = display.contentWidth-40
	yesText.y = display.contentHeight-15
	yesText.alpha = 0
	noText.x = 40
	noText.y = display.contentHeight-15
	noText.alpha = 0
	
	rightButton.x = display.contentWidth-40
	rightButton.y = display.contentHeight-50
        rightButton.alpha = 0
	leftButton.x = 40
	leftButton.y = display.contentHeight-50
        leftButton.alpha = 0
        haloRight.x = display.contentWidth-40
        haloRight.y = display.contentHeight-50
        haloRight.alpha = 0
        haloLeft.x = 40
        haloLeft.y = display.contentHeight-50
        haloLeft.alpha = 0
        haloLeft:rotate(180)
	spinHalo = timer.performWithDelay (5, function () haloRight:rotate(2) haloLeft:rotate(2) end, -1)
        closeButton.x = x
        closeButton.y = display.contentHeight-40
        closeButton.alpha = 0
        closeButton.xScale = 0.7
        closeButton.yScale = 0.7
    
        ------------------
	-- Running on load
	------------------
        
        leftButton.xScale = -1
        
        -- Check if it must show the social network buttons
        if ((param.socialNetworks == true) or (param.finalResult >= 81)) then
            
            if param.finalResult >= 81 then
                -- Enable filling the questionnaire again
                -- Open the database
                db = sqlite3.open(dbPath)
                -- Update the currentStep to enable next time the questionnaire
                param.currentStep = 0
                -- Update the current questionnaire number in the database, so the tutorial is skipped next time
                local q = "UPDATE f_prov SET p_currentStep="..param.currentStep.." WHERE p_id=0;"
                if not(db:exec(q) == sqlite3.OK) then
                    native.showAlert( "HappyUp", "Error updating the current step", { "Ok" } )
                    exit()
                end
                db:close()
            end
        
            showSocialNetworkPart ()
            trainerText.alpha = 0
            rightButton.alpha = 0
            leftButton.alpha = 0
        end
    
        transitionToDark()
	
	return localGroup
	
end
