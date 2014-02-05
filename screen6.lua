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
        require("movieclip")
        local Wrapper = require("wrapper")

	display.setStatusBar(display.HiddenStatusBar)
	local x=display.contentWidth/2
        local y=display.contentHeight/2
	
        local bg
        local logo
        local bgCSlider
        local bgCSlider2
        local bgCSlider3
        local button1
	local button2
	local button3
	local tutorialText
	local tutorialText2
	local tutorialText3
        local arrowsUp
	local arrowsDown
        local csTutorial
        local nextButton
        
        local onTransition = false
    
        local currentScreen = 1
        
        local beginX = 0
        local endX = 0
        
	------------------
	-- Groups
	------------------
	local localGroup = display.newGroup()
	
	------------------
	-- Functions
	------------------
	
	-- Function to handle the pressing of next button
	local touchedNextButton = function ( event )
		if event.phase == "ended" then
                    -- Cancel and release timers
                    if not(updateArrows == nil) then
                        -- Check whether it is different to nil
                        timer.cancel(updateArrows); updateArrows = nil;
                    end
                    if not(updateCS == nil) then
                        -- Check whether it is different to nil
                        timer.cancel(updateCS); updateCS = nil;
                    end
                    
                    local paramNew = {currentStep=param.currentStep, currentQuestionnaire=param.currentQuestionnaire}
                    director:changeScene( paramNew, "screen2", "fade" )
		end
	end
    
        -- Function for moving from screen 1 to the 2 of the tutorial
        function moveScreen2 ()
            
            currentScreen = 2
            onTransition= true
        
            transition.to( bgCSlider, { time=500, x=-x, onComplete=function () button1:stopAtFrame(1) button2:stopAtFrame(2) onTransition=false end})
            transition.to( tutorialText, { time=500, x=-x})
            transition.to( bgCSlider2, { time=500, x=x})
            transition.to( tutorialText2, { time=500, x=x})
            transition.to( arrowsUp, { time=500, x=arrowsUp.x-2*x})
            transition.to( arrowsDown, { time=500, x=arrowsDown.x-2*x})
            transition.to( csTutorial, { time=500, x=csTutorial.x-2*x})
        end
        
        -- Function for moving from screen 2 to the 3 of the tutorial
        function moveScreen3 ()
            
            currentScreen = 3
            onTransition= true
            
            transition.to( bgCSlider2, { time=500, x=-x, onComplete=function () button2:stopAtFrame(1) button3:stopAtFrame(2) onTransition=false end})
            transition.to( tutorialText2, { time=500, x=-x})
            transition.to( arrowsUp, { time=500, x=arrowsUp.x-2*x})
            transition.to( arrowsDown, { time=500, x=arrowsDown.x-2*x})
            transition.to( csTutorial, { time=500, x=csTutorial.x-2*x})
            transition.to( bgCSlider3, { time=500, x=x})
            transition.to( tutorialText3, { time=500, x=x})
            
            -- Tutorial completed, so show the next button
            nextButton.alpha = 1
        end
        
        -- Function for moving from screen 2 to the 1 of the tutorial
        function moveScreen1 ()
            
            currentScreen = 1
            onTransition= true
            
            transition.to( bgCSlider2, { time=500, x=3*x})
            transition.to( tutorialText2, { time=500, x=3*x})
            transition.to( arrowsUp, { time=500, x=arrowsUp.x+2*x})
            transition.to( arrowsDown, { time=500, x=arrowsDown.x+2*x})
            transition.to( csTutorial, { time=500, x=csTutorial.x+2*x})
            transition.to( bgCSlider, { time=500, x=x, onComplete=function () button2:stopAtFrame(1) button1:stopAtFrame(2) onTransition=false end})
            transition.to( tutorialText, { time=500, x=x})
        end
        
        -- Function for moving from screen 3 to the 2 of the tutorial
        function moveScreen2FromRight ()
            
            currentScreen = 2
            onTransition= true
            
            transition.to( bgCSlider3, { time=500, x=3*x})
            transition.to( tutorialText3, { time=500, x=3*x})
            transition.to( bgCSlider2, { time=500, x=x, onComplete=function () button3:stopAtFrame(1) button2:stopAtFrame(2) onTransition=false end})
            transition.to( tutorialText2, { time=500, x=x})
            transition.to( arrowsUp, { time=500, x=arrowsUp.x+2*x})
            transition.to( arrowsDown, { time=500, x=arrowsDown.x+2*x})
            transition.to( csTutorial, { time=500, x=csTutorial.x+2*x})
        end
        
        -- Function to handle the change of the "screens" of the tutorial because of the swipe movement
        function checkSwipeDirection()

            -- Check the direction of the swipe
            if ((beginX > endX) and (onTransition == false)) then
                -- Moving to the right
                if (currentScreen == 1) then
                    -- Move from first screen of the tutorial to the second one
                    moveScreen2()
                elseif (currentScreen == 2) then
                    -- Move from second screen of the tutorial to the third one
                    moveScreen3 ()
                end
            elseif ((beginX < endX) and (onTransition == false)) then
                -- Moving to the left
                if (currentScreen == 2) then
                    -- Move from second screen of the tutorial to the first one
                    moveScreen1()
                elseif (currentScreen == 3) then
                    -- Move from third screen of the tutorial to the second one
                    moveScreen2FromRight ()
                end
            end
        end

        -- Function to handle the touch events
        function swipe(event)
            if event.phase == "began" then
                beginX = event.x
            end

            if event.phase == "ended"  then
                endX = event.x
                checkSwipeDirection();
            end
        end

	------------------
	-- Components
	------------------
	
	-- Load the background
	bg = display.newImage("multimedia/background/background.jpg")
	logo = display.newImage("multimedia/logo.png")
	
        -- Load the background of the circular slider
	bgCSlider = display.newImage("multimedia/circular_slider_14/white_circular_slider_14.png")
	bgCSlider2 = display.newImage("multimedia/circular_slider_14/white_circular_slider_14.png")
	bgCSlider3 = display.newImage("multimedia/circular_slider_14/white_circular_slider_14.png")
	
	tutorialText = Wrapper:newParagraph({
            text = "¡Bienvenido! Con happyUp podrás conocer tu nivel de felicidad, aprender a mejorarlo y compartirlo con tus amigos en redes sociales",
            width = 200,
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

	-- Necessary to do some settings since it is created everytime
        tutorialText:setTextColor({88, 88, 90})
        tutorialText:setReferencePoint(display.CenterReferencePoint)
        
	tutorialText2 = Wrapper:newParagraph({
            text = "Hay siempre dos preguntas: una arriba y otra abajo; para contestarlas, pulsar sobre los segmentos o mover los indicadores sobre ellos",
            width = 190,
            height = 200, 			-- fontSize will be calculated automatically if set 
            font = "Prime", 	-- make sure the selected font is installed on your system
            fontSize = 20,			
            lineSpace = 2,
            alignment  = "center",
	
            -- Parameters for auto font-sizing
            fontSizeMin = 20,
            fontSizeMax = 30,
            incrementSize = 2
        })

	-- Necessary to do some settings since it is created everytime
        tutorialText2:setTextColor({88, 88, 90})
        tutorialText2:setReferencePoint(display.CenterReferencePoint)
        
	tutorialText3 = Wrapper:newParagraph({
            text = "Ya estás listo para rellenar el cuestionario. ¡Comprueba tu nivel de felicidad!",
            width = 200,
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
            
        -- Necessary to do some settings since it is created everytime
        tutorialText3:setTextColor({88, 88, 90})
        tutorialText3:setReferencePoint(display.CenterReferencePoint)
        
	arrowsUp = movieclip.newAnim{"multimedia/tutorial/arrows/up0.png", "multimedia/tutorial/arrows/up1.png", "multimedia/tutorial/arrows/up2.png", "multimedia/tutorial/arrows/up3.png", "multimedia/tutorial/arrows/up4.png", "multimedia/tutorial/arrows/up5.png", "multimedia/tutorial/arrows/up6.png", "multimedia/tutorial/arrows/up7.png"}
        arrowsUp:stopAtFrame(1)
        arrowsDown = movieclip.newAnim{"multimedia/tutorial/arrows/down0.png", "multimedia/tutorial/arrows/down1.png", "multimedia/tutorial/arrows/down2.png", "multimedia/tutorial/arrows/down3.png", "multimedia/tutorial/arrows/down4.png", "multimedia/tutorial/arrows/down5.png", "multimedia/tutorial/arrows/down6.png", "multimedia/tutorial/arrows/down7.png"}
        arrowsDown:stopAtFrame(1)
        
        csTutorial = movieclip.newAnim{"multimedia/tutorial/cstutorial1.png", "multimedia/tutorial/cstutorial2.png", "multimedia/tutorial/cstutorial3.png", "multimedia/tutorial/cstutorial4.png", "multimedia/tutorial/cstutorial5.png", "multimedia/tutorial/cstutorial6.png", "multimedia/tutorial/cstutorial7.png", "multimedia/tutorial/cstutorial8.png"}
        csTutorial:stopAtFrame(1)
        
	button1 = movieclip.newAnim{"multimedia/tutorial/option_not_active.png", "multimedia/tutorial/option_active.png"}
        button1:stopAtFrame(2)
        button2 = movieclip.newAnim{"multimedia/tutorial/option_not_active.png", "multimedia/tutorial/option_active.png"}
        button2:stopAtFrame(1)
        button3 = movieclip.newAnim{"multimedia/tutorial/option_not_active.png", "multimedia/tutorial/option_active.png"}
        button3:stopAtFrame(1)
        
        
        nextButton = ui.newButton{
		default = "multimedia/next_active.png",
		over = "multimedia/next_pressed.png",
		onRelease = touchedNextButton,
		id = "nextbutton",
		text = "",
		font = "Times New Roman",
		size = 20
	}
	
        ------------------
	-- Running on load
	------------------
        -- Hide the next button until last screen of the tutorial is reached
	nextButton.alpha = 0
        
        -- Add a listener for the swiping
        Runtime:addEventListener("touch", swipe)
    
        -- Timers to control when to play the movieclip for the circular slider (once it reaches its position in the screen)
        updateArrows = timer.performWithDelay (150, function () arrowsUp:nextFrame() arrowsDown:nextFrame() end, -1)
        updateCS = timer.performWithDelay (550, function () csTutorial:nextFrame() end, -1)
        
        logo:scale(0.7, 0.7)
    
        ------------------
	-- Inserts
	------------------
        localGroup:insert(bg)
	localGroup:insert(logo)
	localGroup:insert(bgCSlider)
	localGroup:insert(bgCSlider2)
	localGroup:insert(bgCSlider3)
	localGroup:insert(button1)
	localGroup:insert(button2)
	localGroup:insert(button3)
	localGroup:insert(tutorialText)
	localGroup:insert(tutorialText2)
	localGroup:insert(tutorialText3)
        localGroup:insert(arrowsUp)
	localGroup:insert(arrowsDown)
        localGroup:insert(csTutorial)
    
        localGroup:insert(nextButton)
	
	------------------
	-- Positions
	------------------
	bg.x = x
	bg.y = y
	logo.x = x
	logo.y = 45
	bgCSlider.x = x
	bgCSlider.y = y
        bgCSlider2.x = 3*x
	bgCSlider2.y = y
        bgCSlider3.x = 3*x
	bgCSlider3.y = y
        
        tutorialText.x = x
        tutorialText.y = y
	tutorialText2.x = 3*x
        tutorialText2.y = y
	tutorialText3.x = 3*x
        tutorialText3.y = y
	
	arrowsUp.x = x-110+2*x
        arrowsUp.y = y-110
        arrowsDown.x = x+110+2*x
        arrowsDown.y = y+110
        csTutorial.x = x+2*x
        csTutorial.y = y
    
        button1.x = x-20
        button1.y = y+175
        button2.x = x
        button2.y = y+175
        button3.x = x+20
        button3.y = y+175
        
	nextButton.x = display.contentWidth-40
	nextButton.y = display.contentHeight-40
	
	return localGroup
	
end