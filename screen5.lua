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
        require "sqlite3"

	display.setStatusBar(display.HiddenStatusBar)
	local x=display.contentWidth/2
        local y=display.contentHeight/2
	
	local db
        local dbPath = system.pathForFile("happyUpDB", system.DocumentsDirectory)
        
        local bg
        local logo
        local bgCSlider
        local bgCSlider1
        local bgCSlider2
        local bgCSlider3
        local button0
	local button1
	local button2
	local button3
	local introText
	local quoteText
        local exerciseTitle
	local exerciseText
	local remainderText
        local nextButton
        
        local currentScreen = 0
        
        local onTransition = false

        local quote
        local author
        local comment
        local exercise
        local colon
        local remainderNumbers = { }
        local arrowUp
        local arrowDown
        
        local beginX = 0
        local endX = 0
        
        local options = {
            alert = "¡Entrena tu felicidad!",
            badge = 1,
            sound = "alarm.caf",
            custom = { msg = "bar" }
        }

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
                    
                    -- Get the time inserted for the remainder
                    local remainder_hour = 10*remainderNumbers[1].value + remainderNumbers[2].value
                    local remainder_minutes = 10*remainderNumbers[3].value + remainderNumbers[4].value
                    
                    -- Get the current time
                    local t = os.date( '*t' )  -- get table of current date and time
                    
                    -- Calculate the difference
                    local hour_difference = remainder_hour - t.hour
                    local minute_difference = remainder_minutes - t.min
            
                    time = (hour_difference*60 + minute_difference)*60

                    -- Add badge paramter if not "none"
                    if badge ~= "none" then
                        options.badge = badge
                    end
	
                    options.custom.msg = "UTC Notification"
                    
					-- Open the database
                    db = sqlite3.open(dbPath)

                    time = time + 24*7*60*60
                    notificationID = system.scheduleNotification( time, options )
					local foreseenTime = os.time() + time
            --native.showAlert( "HappyUp", "Notification ID 1 "..notificationID, { "Ok" } )
					local q = "UPDATE f_prov SET p_notificationID1=".. foreseenTime .." WHERE p_id=0;"
                    if not(db:exec(q) == sqlite3.OK) then
                        native.showAlert( "HappyUp", "Error updating the notification ID 1", { "Ok" } )
                        exit()
                    end

                    time = time + 24*7*60*60
                    foreseenTime = os.time() + time
					notificationID2 = system.scheduleNotification( time, options )
                    q = "UPDATE f_prov SET p_notificationID2=".. foreseenTime .." WHERE p_id=0;"
                    if not(db:exec(q) == sqlite3.OK) then
                        native.showAlert( "HappyUp", "Error updating the notification ID 2", { "Ok" } )
                        exit()
                    end

                    time = time + 24*7*60*60
                    foreseenTime = os.time() + time
					notificationID3 = system.scheduleNotification( time, options )
					q = "UPDATE f_prov SET p_notificationID3=".. foreseenTime .." WHERE p_id=0;"
                    if not(db:exec(q) == sqlite3.OK) then
                        native.showAlert( "HappyUp", "Error updating the notification ID 3", { "Ok" } )
                        exit()
                    end
					
                    startTime = os.time( ( os.date( '*t' ) ) )  -- get current time in seconds
                    running = true

                    local auxTime = os.time()+23*24*60*60
                    q = "UPDATE f_prov SET p_time=".. auxTime .." WHERE p_id=0;"
                    if not(db:exec(q) == sqlite3.OK) then
                        native.showAlert( "HappyUp", "Error updating the current step", { "Ok" } )
                        exit()
                    end
                    
					db:close() 
 
                    local paramNew = {currentStep=param.currentStep, currentQuestionnaire=param.currentQuestionnaire, finalResult=param.finalResult, socialNetworks=true}
                    director:changeScene( paramNew, "screen3", "fade" )
		end
	end
    
        -- Function for moving from intro screen to the first one of the training
        function moveScreen1 ()
            
            currentScreen = 1
            onTransition= true
        
            transition.to( bgCSlider, { time=500, x=-x, onComplete=function () button0:stopAtFrame(1) button1:stopAtFrame(2) onTransition=false end})
            transition.to( introText, { time=500, x=-x})
            transition.to( bgCSlider1, { time=500, x=x})
            transition.to( quoteText, { time=500, x=x})
            transition.to( authorText, { time=500, x=x})
            transition.to( commentText, { time=500, x=x})
        end
        
        -- Function for moving from screen 1 to the 2 of the training
        function moveScreen2 ()
            
            currentScreen = 2
            onTransition= true
        
            transition.to( bgCSlider1, { time=500, x=-x, onComplete=function () button1:stopAtFrame(1) button2:stopAtFrame(2) onTransition=false end})
            transition.to( quoteText, { time=500, x=-x})
            transition.to( authorText, { time=500, x=-x})
            transition.to( commentText, { time=500, x=-x})
            transition.to( bgCSlider2, { time=500, x=x})
            transition.to( exerciseTitle, { time=500, x=x})
            transition.to( exerciseText, { time=500, x=x})
        end
        
        -- Function for moving from screen 2 to the 3 of the training
        function moveScreen3 ()
            
            currentScreen = 3
            onTransition= true
        
            transition.to( bgCSlider2, { time=500, x=-x, onComplete=function () button2:stopAtFrame(1) button3:stopAtFrame(2) onTransition=false end})
            transition.to( exerciseTitle, { time=500, x=-x})
            transition.to( exerciseText, { time=500, x=-x})
            transition.to( bgCSlider3, { time=500, x=x})
            transition.to( remainderText, { time=500, x=x})
            transition.to( colon, { time=500, x=x})
            transition.to( remainderNumbers[1], { time=500, x=remainderNumbers[1].x-2*x})
            transition.to( remainderNumbers[2], { time=500, x=remainderNumbers[2].x-2*x})
            transition.to( remainderNumbers[3], { time=500, x=remainderNumbers[3].x-2*x})
            transition.to( remainderNumbers[4], { time=500, x=remainderNumbers[4].x-2*x})
            transition.to( arrowUp, { time=500, x=arrowUp.x-2*x})
            transition.to( arrowDown, { time=500, x=arrowDown.x-2*x})
                    
            -- Training completed, so show the next button
            nextButton.alpha = 1
        end
        
        -- Function for moving from screen 1 to the intro one of the training
        function moveScreen0 ()
            
            currentScreen = 0
            onTransition= true
        
            transition.to( bgCSlider1, { time=500, x=3*x})
            transition.to( quoteText, { time=500, x=3*x})
            transition.to( authorText, { time=500, x=3*x})
            transition.to( commentText, { time=500, x=3*x})
            transition.to( bgCSlider, { time=500, x=x, onComplete=function () button1:stopAtFrame(1) button0:stopAtFrame(2) onTransition=false end})
            transition.to( introText, { time=500, x=x})
        end
        
        -- Function for moving from screen 2 to the 1 of the training
        function moveScreen1FromRight ()
            
            currentScreen = 1
            onTransition= true
         
            transition.to( bgCSlider2, { time=500, x=3*x})
            transition.to( exerciseTitle, { time=500, x=3*x})
            transition.to( exerciseText, { time=500, x=3*x})
            transition.to( bgCSlider1, { time=500, x=x, onComplete=function () button2:stopAtFrame(1) button1:stopAtFrame(2) onTransition=false end})
            transition.to( quoteText, { time=500, x=x})
            transition.to( authorText, { time=500, x=x})
            transition.to( commentText, { time=500, x=x})
        end
        
        -- Function for moving from screen 3 to the 2 of the training
        function moveScreen2FromRight ()
            
            currentScreen = 2
            onTransition= true
        
            transition.to( bgCSlider3, { time=500, x=3*x})
            transition.to( remainderText, { time=500, x=3*x})
            transition.to( colon, { time=500, x=3*x})
            transition.to( remainderNumbers[1], { time=500, x=remainderNumbers[1].x+2*x})
            transition.to( remainderNumbers[2], { time=500, x=remainderNumbers[2].x+2*x})
            transition.to( remainderNumbers[3], { time=500, x=remainderNumbers[3].x+2*x})
            transition.to( remainderNumbers[4], { time=500, x=remainderNumbers[4].x+2*x})
            transition.to( arrowUp, { time=500, x=arrowUp.x+2*x})
            transition.to( arrowDown, { time=500, x=arrowDown.x+2*x})
            transition.to( bgCSlider2, { time=500, x=x, onComplete=function () button3:stopAtFrame(1) button2:stopAtFrame(2) onTransition=false end})
            transition.to( exerciseTitle, { time=500, x=x})
            transition.to( exerciseText, { time=500, x=x})
        end
        
        -- Function to handle the change of the "screens" of the tutorial because of the swipe movement
        function checkSwipeDirection()

            -- Check the direction of the swipe
            if ((beginX > endX) and (onTransition == false)) then
                -- Moving to the right
                if (currentScreen == 0) then
                    -- Move from intro screen of the tutorial to the first one
                    moveScreen1()
                elseif(currentScreen == 1) then
                    -- Move from first screen of the tutorial to the second one
                    moveScreen2()
                elseif (currentScreen == 2) then
                    -- Move from second screen of the tutorial to the third one
                    moveScreen3 ()
                end
            elseif ((beginX < endX) and (onTransition == false)) then
                -- Moving to the left
                if (currentScreen == 1) then
                    -- Move from first screen of the tutorial to the intro one
                    moveScreen0()
                elseif(currentScreen == 2) then
                    -- Move from second screen of the tutorial to the first one
                    moveScreen1FromRight()
                elseif (currentScreen == 3) then
                    -- Move from third screen of the tutorial to the second one
                    --moveScreen2FromRight ()
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
        
        -- Function that opens the database, gets the lowest level and the proper training, and eventually close the database
        function getTraining ()
            
            -- Open the database
            db = sqlite3.open(dbPath)
            
            -- Find the lowest step
            local lowerStep = {1, 1}
            for row in db:nrows("SELECT * FROM f_questionnaire WHERE qst_id=" .. param.currentQuestionnaire) do
                lowerStep[2] = row.qst_step1
            
                -- Create an array with the values of the steps
                local auxArray = {} 
                auxArray[2] = row.qst_step2
                auxArray[3] = row.qst_step3
                auxArray[4] = row.qst_step4
                auxArray[5] = row.qst_step5
                auxArray[6] = row.qst_step6
                auxArray[7] = row.qst_step7
                
                -- Look for the lowest step
                for i = 2, 7, 1 do
                    if (auxArray[i] < lowerStep[2]) then
                        lowerStep[1] = i
                        lowerStep[2] = auxArray[i]
                    end
                end
            end
            
            if (lowerStep[2] < 34) then
                -- Level improvable
                q = [[SELECT * FROM f_training WHERE trng_result=']] .. "improvable" .. [[' AND trng_step=]] .. lowerStep[1]
            else
                -- Level acceptable
                q = [[SELECT * FROM f_training WHERE trng_result=']] .. "acceptable" .. [[' AND trng_step=]] .. lowerStep[1]
            end
            
            for row in db:nrows(q) do
                quote = [["]] .. row.trng_quote .. [["]]
                author = row.trng_author
                comment = row.trng_comment
                exercise = row.trng_exercise
            end

            -- Close database
            db:close()
        end
        
        -- Function to handle the touching of the numbers of the postal code
	function remainderNumbersNumberTouched (event)
	
            -- Display the digit not being updated as not selected (+11)
            remainderNumbers[arrowUp.currentNumber]:stopAtFrame(remainderNumbers[arrowUp.currentNumber].value+11)

            -- Move the arrows to the same x-position of the number touched and let the arrow know which one it is
            arrowUp.x = event.target.x
            arrowDown.x = event.target.x
            arrowUp.currentNumber = event.target.number

            -- Display the digit being updated as selected (+1)
            remainderNumbers[arrowUp.currentNumber]:stopAtFrame(remainderNumbers[arrowUp.currentNumber].value+1)
        end
        
        -- Function to handle the touching of the upper arrow
	function arrowUpTouched (event)
	
            --if (event.phase == "ended") then
                -- Check whether the number is nine, then switch it to zero. If not, update the value
                -- in the array and the digit being displayed. Field currentNumber from arrowUp stores the digit to be updated.
                -- +1 when updating the frame because the frame array starts with zero in the position 1
                if ((remainderNumbers[arrowUp.currentNumber].value == 9) or ((arrowUp.currentNumber == 3) and (remainderNumbers[3].value == 5)) 
                    or ((arrowUp.currentNumber == 2) and (remainderNumbers[2].value == 3) and (remainderNumbers[1].value == 2))
                    or ((arrowUp.currentNumber == 1) and (remainderNumbers[2].value > 3) and (remainderNumbers[1].value == 1))
                    or ((arrowUp.currentNumber == 1) and (remainderNumbers[2].value < 4) and (remainderNumbers[1].value == 2))) then
                    remainderNumbers[arrowUp.currentNumber].value = 0
                else
                    remainderNumbers[arrowUp.currentNumber].value = remainderNumbers[arrowUp.currentNumber].value + 1
                end
                    
                remainderNumbers[arrowUp.currentNumber]:stopAtFrame(remainderNumbers[arrowUp.currentNumber].value+1)
                    
                nextButton.alpha = 1
            --end
        end
    
        -- Function to handle the touching of the down arrow
	function arrowDownTouched (event)
	
            --if (event.phase == "ended") then
                -- Check whether the number is zero, then switch to the corresponding one. If not, update the value
                -- in the array and the digit being displayed. Field currentNumber from arrowUp stores the digit to be updated.
                -- +1 when updating the frame because the frame array starts with zero in the position 1
                if (remainderNumbers[arrowUp.currentNumber].value == 0) then
                    -- Check the time inserted will be possible
                    if (arrowUp.currentNumber == 3) then
                        -- Minute Dozens
                        remainderNumbers[arrowUp.currentNumber].value = 5
                    elseif ((arrowUp.currentNumber == 2) and (remainderNumbers[1].value == 2)) then
                        -- Hour units
                        remainderNumbers[arrowUp.currentNumber].value = 3
                    elseif ((arrowUp.currentNumber == 1) and (remainderNumbers[2].value > 3)) then
                        -- Hour dozens
                        remainderNumbers[arrowUp.currentNumber].value = 1
                    elseif ((arrowUp.currentNumber == 1) and (remainderNumbers[2].value < 4)) then
                        -- Hour dozens
                        remainderNumbers[arrowUp.currentNumber].value = 2
                    else
                        remainderNumbers[arrowUp.currentNumber].value = 9
                    end
                else
                    remainderNumbers[arrowUp.currentNumber].value = remainderNumbers[arrowUp.currentNumber].value - 1
                end
                        
                remainderNumbers[arrowUp.currentNumber]:stopAtFrame(remainderNumbers[arrowUp.currentNumber].value+1)
                        
                nextButton.alpha = 1
            --end
        end
    
	------------------
	-- Components
	------------------
        
        -- Find the lower level
        getTraining ()
            
	-- Load the background
	bg = display.newImage("multimedia/background/background.jpg")
        logo = display.newImage("multimedia/logo.png")
	
        -- Load the background of the circular slider
	bgCSlider = display.newImage("multimedia/circular_slider_14/white_circular_slider_14.png")
	bgCSlider1 = display.newImage("multimedia/circular_slider_14/white_circular_slider_14.png")
	bgCSlider2 = display.newImage("multimedia/circular_slider_14/white_circular_slider_14.png")
	bgCSlider3 = display.newImage("multimedia/circular_slider_14/white_circular_slider_14.png")
	
	introText = Wrapper:newParagraph({
            text = "Te proponemos entrenar durante 21 días para poder mejorar tu felicidad. Un ejercicio, acompañado de una cita y un comentario para motivarte, te ayudarán antes de volver a medir tu felicidad.",
            width = 190,
            height = 200, 			-- fontSize will be calculated automatically if set 
            font = "Prime", 	-- make sure the selected font is installed on your system
            fontSize = 18,			
            lineSpace = 2,
            alignment  = "center",
	
            -- Parameters for auto font-sizing
            fontSizeMin = 18,
            fontSizeMax = 30,
            incrementSize = 2
        })
        introText:setTextColor({88, 88, 90})
        introText:setReferencePoint(display.CenterReferencePoint)
        
	quoteText = Wrapper:newParagraph({
            text = quote,
            width = 170,
            height = 80, 			-- fontSize will be calculated automatically if set 
            font = "Prime", 	-- make sure the selected font is installed on your system
            fontSize = 18,			
            lineSpace = 2,
            alignment  = "center",
	
            -- Parameters for auto font-sizing
            fontSizeMin = 14,
            fontSizeMax = 20,
            incrementSize = 2
        })
        quoteText:setTextColor({88, 88, 90})
        quoteText:setReferencePoint(display.CenterReferencePoint)
        authorText = display.newText(author,0,0,"Prime",16)
        authorText:setTextColor({164, 164, 164})
        authorText:setReferencePoint(display.CenterReferencePoint)
	commentText = Wrapper:newParagraph({
            text = comment,
            width = 180,
            height = 90, 			-- fontSize will be calculated automatically if set 
            font = "Prime", 	-- make sure the selected font is installed on your system
            fontSize = 18,			
            lineSpace = 2,
            alignment  = "center",
	
            -- Parameters for auto font-sizing
            fontSizeMin = 14,
            fontSizeMax = 20,
            incrementSize = 2
        })
        commentText:setTextColor({88, 88, 90})
        commentText:setReferencePoint(display.CenterReferencePoint)
        
        exerciseTitle = display.newText("Ejercicio",0,0,"Prime",16)
        exerciseTitle:setTextColor({164, 164, 164})
        exerciseTitle:setReferencePoint(display.CenterReferencePoint) 
	exerciseText = Wrapper:newParagraph({
            text = exercise,
            width = 190,
            height = 200, 			-- fontSize will be calculated automatically if set 
            font = "Prime", 	-- make sure the selected font is installed on your system
            fontSize = 18,			
            lineSpace = 2,
            alignment  = "center",
	
            -- Parameters for auto font-sizing
            fontSizeMin = 18,
            fontSizeMax = 30,
            incrementSize = 2
        })
        exerciseText:setTextColor({88, 88, 90})
        exerciseText:setReferencePoint(display.CenterReferencePoint)
        
	remainderText = Wrapper:newParagraph({
            text = "¿A qué hora prefieres el recordatorio semanal?",
            width = 200,
            height = 100, 			-- fontSize will be calculated automatically if set 
            font = "Prime", 	-- make sure the selected font is installed on your system
            fontSize = 18,			
            lineSpace = 2,
            alignment  = "center",
	
            -- Parameters for auto font-sizing
            fontSizeMin = 18,
            fontSizeMax = 18,
            incrementSize = 2
        })
        remainderText:setTextColor({88, 88, 90})
        remainderText:setReferencePoint(display.CenterReferencePoint)
        
	button0 = movieclip.newAnim{"multimedia/tutorial/option_not_active.png", "multimedia/tutorial/option_active.png"}
        button0:stopAtFrame(2)
        button1 = movieclip.newAnim{"multimedia/tutorial/option_not_active.png", "multimedia/tutorial/option_active.png"}
        button1:stopAtFrame(1)
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
	
	colon = display.newImage("multimedia/profile/colon.png")
        
        -- The attribute number is used to identify the number when touched and the event listener function is launched
        remainderNumbers[1] = movieclip.newAnim{"multimedia/profile/0s.png", "multimedia/profile/1s.png", "multimedia/profile/2s.png", "multimedia/profile/3s.png", "multimedia/profile/4s.png", "multimedia/profile/5s.png", "multimedia/profile/6s.png", "multimedia/profile/7s.png", "multimedia/profile/8s.png", "multimedia/profile/9s.png", "multimedia/profile/0.png", "multimedia/profile/1.png", "multimedia/profile/2.png", "multimedia/profile/3.png", "multimedia/profile/4.png", "multimedia/profile/5.png", "multimedia/profile/6.png", "multimedia/profile/7.png", "multimedia/profile/8.png", "multimedia/profile/9.png"}
        remainderNumbers[1].number = 1
        remainderNumbers[1]:addEventListener("tap", remainderNumbersNumberTouched)
        remainderNumbers[1]:stopAtFrame(1)
        remainderNumbers[1].value = 0
        remainderNumbers[2] = movieclip.newAnim{"multimedia/profile/0s.png", "multimedia/profile/1s.png", "multimedia/profile/2s.png", "multimedia/profile/3s.png", "multimedia/profile/4s.png", "multimedia/profile/5s.png", "multimedia/profile/6s.png", "multimedia/profile/7s.png", "multimedia/profile/8s.png", "multimedia/profile/9s.png", "multimedia/profile/0.png", "multimedia/profile/1.png", "multimedia/profile/2.png", "multimedia/profile/3.png", "multimedia/profile/4.png", "multimedia/profile/5.png", "multimedia/profile/6.png", "multimedia/profile/7.png", "multimedia/profile/8.png", "multimedia/profile/9.png"}
        remainderNumbers[2].number = 2
        remainderNumbers[2]:addEventListener("tap", remainderNumbersNumberTouched)
        remainderNumbers[2]:stopAtFrame(11)
        remainderNumbers[2].value = 0
        remainderNumbers[3] = movieclip.newAnim{"multimedia/profile/0s.png", "multimedia/profile/1s.png", "multimedia/profile/2s.png", "multimedia/profile/3s.png", "multimedia/profile/4s.png", "multimedia/profile/5s.png", "multimedia/profile/6s.png", "multimedia/profile/7s.png", "multimedia/profile/8s.png", "multimedia/profile/9s.png", "multimedia/profile/0.png", "multimedia/profile/1.png", "multimedia/profile/2.png", "multimedia/profile/3.png", "multimedia/profile/4.png", "multimedia/profile/5.png", "multimedia/profile/6.png", "multimedia/profile/7.png", "multimedia/profile/8.png", "multimedia/profile/9.png"}
        remainderNumbers[3].number = 3
        remainderNumbers[3]:addEventListener("tap", remainderNumbersNumberTouched)
        remainderNumbers[3]:stopAtFrame(11)
        remainderNumbers[3].value = 0
        remainderNumbers[4] = movieclip.newAnim{"multimedia/profile/0s.png", "multimedia/profile/1s.png", "multimedia/profile/2s.png", "multimedia/profile/3s.png", "multimedia/profile/4s.png", "multimedia/profile/5s.png", "multimedia/profile/6s.png", "multimedia/profile/7s.png", "multimedia/profile/8s.png", "multimedia/profile/9s.png", "multimedia/profile/0.png", "multimedia/profile/1.png", "multimedia/profile/2.png", "multimedia/profile/3.png", "multimedia/profile/4.png", "multimedia/profile/5.png", "multimedia/profile/6.png", "multimedia/profile/7.png", "multimedia/profile/8.png", "multimedia/profile/9.png"}
        remainderNumbers[4].number = 4
        remainderNumbers[4]:addEventListener("tap", remainderNumbersNumberTouched)
        remainderNumbers[4]:stopAtFrame(11)
        remainderNumbers[4].value = 0
        
        arrowUp = display.newImage("multimedia/profile/arrow_up.png")
        arrowUp:addEventListener("tap", arrowUpTouched)
        arrowDown = display.newImage("multimedia/profile/arrow_down.png")
        arrowDown:addEventListener("tap", arrowDownTouched)
	
        ------------------
	-- Running on load
	------------------
        -- Hide the next button until last screen of the tutorial is reached
	nextButton.alpha = 0
        
        -- Add a listener for the swiping
        Runtime:addEventListener("touch", swipe)
    
        logo:scale(0.7, 0.7)
    
        ------------------
	-- Inserts
	------------------
        localGroup:insert(bg)
	localGroup:insert(logo)
	localGroup:insert(bgCSlider)
	localGroup:insert(bgCSlider1)
	localGroup:insert(bgCSlider2)
	localGroup:insert(bgCSlider3)
        localGroup:insert(button0)
        localGroup:insert(button1)
	localGroup:insert(button2)
	localGroup:insert(button3)
	localGroup:insert(introText)
	localGroup:insert(quoteText)
        localGroup:insert(exerciseTitle)
	localGroup:insert(exerciseText)
	localGroup:insert(remainderText)
	
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
        bgCSlider1.x = 3*x
	bgCSlider1.y = y
        bgCSlider2.x = 3*x
	bgCSlider2.y = y
        bgCSlider3.x = 3*x
	bgCSlider3.y = y
        
 	introText.x = x
        introText.y = y
        quoteText.x = 3*x
        quoteText.y = y-60
        authorText.x = 3*x
        authorText.y = y-10
        commentText.x = 3*x
        commentText.y = y+50
        exerciseTitle.x = 3*x
        exerciseTitle.y = y+210
	exerciseText.x = 3*x
        exerciseText.y = y
	remainderText.x = 3*x
        remainderText.y = y-55  
	
	button0.x = x-30
        button0.y = y+175
        button1.x = x-10
        button1.y = y+175
        button2.x = x+10
        button2.y = y+175
        button3.x = x+30
        button3.y = y+175
        
        colon.x = 3*x
        colon.y = y+25
        remainderNumbers[1].x = 3*x-70
        remainderNumbers[1].y = y+25
        remainderNumbers[2].x = 3*x-30
        remainderNumbers[2].y = y+25
        remainderNumbers[3].x = 3*x+30
        remainderNumbers[3].y = y+25
        remainderNumbers[4].x = 3*x+70
        remainderNumbers[4].y = y+25
        
        arrowUp.x = 3*x-70
        arrowUp.y = y-25
        arrowDown.x = 3*x-70
        arrowDown.y = y+75
        arrowUp.currentNumber = 1
        
	nextButton.x = display.contentWidth-40
	nextButton.y = display.contentHeight-40
	
	return localGroup
	
end