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
        local network = require ("network")

	display.setStatusBar(display.HiddenStatusBar)
	local x=display.contentWidth/2
        local y=display.contentHeight/2
	
        local bg
        local bgCSlider
        local line 
        local nextButtonImage
        local nextButton
        local segment1a
        local segment2a
        local segment3a
        local segment4a
        local segment5a
        local segment6a
        local segment7a
        local handlerUp
        local questionUp
        local answerUp
        
        local initCS14
        local updateTransitionClouds
        local releaseOnTransition
        local moveNextScreenTimer
        local onTransition = true
    
        local db
        local dbPath = system.pathForFile("happyUpDB", system.DocumentsDirectory)
        
		local currentReminder
		
		local options = {
            alert = "¡Entrena tu felicidad!",
            badge = 1,
            sound = "alarm.caf",
            custom = { msg = "bar" }
        }

	------------------
	-- Groups
	------------------
	local cloudGroup = display.newGroup()
	local localGroup = display.newGroup()
        
	------------------
	-- Functions
	------------------

        local function networkListener( event )
            if ( event.isError ) then
                native.showAlert( "HappyUp", "Network Error", { "Ok" } )
                exit()
          end
        end
        
        -- Save the reminder when the next button is pressed
        function saveReminder ()
            
            local q
            
            local t = os.date("!%FT%XZ")

            -- Current questionnarire row must be created in the database
            q = "INSERT INTO f_reminder VALUES ('" .. t .. "', " .. answerUpNum .. ");"
            if not(db:exec(q) == sqlite3.OK) then
                native.showAlert( "HappyUp", "Error creating the row for the new reminder", { "Ok" } )
                exit()
            end
            
            -- Get the user id and password of the server
            for row in db:nrows("SELECT * FROM f_user WHERE usr_id=0") do
                user_server_id = row.usr_server_id
                user_server_password = row.usr_server_password
            end

            postData = "id=" .. user_server_id .. "&passwd=" .. user_server_password .. "&time=" .. t .. "&grade=" .. answerUpNum
            
            local params = {}
            local headers = {}
            headers["Cache-control"] = "no-cache"
            params.headers = headers
            --params.body = postData
 
            network.request( "http://database.socientize.eu/happyup/createreminder?"..postData, "POST", networkListener, params)
			--network.request( "http://database.socientize.eu/happyup/createreminder", "POST", networkListener, params)
        end
        
        local touchedNextButton = function ( event )
            if event.phase == "ended" then
        
                -- Save the current reminder
                saveReminder()
                    
                -- Remove items from the screen
                moveBelowCircularSlider14()
                        
                -- Close database
                if db:isopen() then
                    db:close()
                end
            end
	end
        
       -- Do the necessary to move to the next screen
        function moveNextScreen ()
           
            -- Cancel and release timers
            if not(releaseOnTransition == nil) then
                -- Check whether it is different to nil
                timer.cancel(releaseOnTransition); releaseOnTransition = nil;
            end
            if not(initCS14 == nil) then
                -- Check whether it is different to nil
                timer.cancel(initCS14); initCS14 = nil;
            end
            if not(updateTransitionClouds == nil) then
                -- Check whether it is different to nil
                timer.cancel(updateTransitionClouds); updateTransitionClouds = nil;
            end
            if not(moveNextScreenTimer == nil) then
                -- Check whether it is different to nil
                timer.cancel(moveNextScreenTimer); moveNextScreenTimer = nil;
            end
            
            local paramNew
            
			local notificationID1
			local notificationID2
			local notificationID3
	        
			if not db:isopen() then
                db = sqlite3.open(dbPath)
            end
			
			for row in db:nrows("SELECT * FROM f_prov WHERE p_id=0") do
		        currentReminder = row.p_currentReminder
		        notificationID1 = row.p_notificationID1
				notificationID2 = row.p_notificationID2
				notificationID3 = row.p_notificationID3
		    end
			
			if (currentReminder % 3) == 0 then
				system.cancelNotification()
			elseif  (currentReminder % 3) == 1 then	
				system.cancelNotification()
				
				if (notificationID2 < os.time()) then
					currentReminder = currentReminder + 1
				else
					options.custom.msg = "UTC Notification"
                    local time = notificationID2 - os.time()
					notificationID = system.scheduleNotification( time, options )
				end
				
				if (notificationID3 < os.time()) then
					currentReminder = currentReminder + 1
				else
					options.custom.msg = "UTC Notification"
                    local time = notificationID3 - os.time()
					notificationID = system.scheduleNotification( time, options )
				end	
			elseif  (currentReminder % 3) == 2 then	
				system.cancelNotification()
				
				if (notificationID3 < os.time()) then
					currentReminder = currentReminder + 1
				else
					options.custom.msg = "UTC Notification"
                    local time = notificationID3 - os.time()
					notificationID = system.scheduleNotification( time, options )
				end
			end
			
			local q = "UPDATE f_prov SET p_currentReminder="..currentReminder.." WHERE p_id=0;"
		    if not(db:exec(q) == sqlite3.OK) then
		        native.showAlert( "HappyUp", "Error updating the current reminder in the database", { "Ok" } )
		        exit()
		    end
			
			db:close()
			
			if (currentReminder % 3) == 0 then
--system.cancelNotification()
				
				native.showAlert( "HappyUp", "Vamos a medir tu nivel de felicidad otra vez", { "Ok" } )
				
				paramNew = {currentStep=0, currentQuestionnaire=param.currentQuestionnaire}
				director:changeScene(paramNew, "screen2")
			else
				
				native.showAlert( "HappyUp", "Continuamos con el entrenamiento", { "Ok" } )
				
				paramNew = {currentStep=param.currentStep, currentQuestionnaire=param.currentQuestionnaire}
				-- Screen 1 (initial), do effect
				director:changeScene( paramNew, "screen1", "flip" )
			end
        end
        
        -- Function to close the database in case of application exit
        function onSystemEvent (event)
            
            if event.type == "applicationExit" then
                if db and db:isopen() then
                    db:close()
                end
            end
        end
    
        -- Function to move handler of the upper part
        function moveHandlerUp (step)
            
            if (step == 0) then
                handlerUp.x = x-132
                handlerUp.y = y-10
            elseif (step == 1) then
                handlerUp.x = x-120
                handlerUp.y = 188
            elseif (step == 2) then
                handlerUp.x = x-85
                handlerUp.y = 140
            elseif (step == 3) then
                handlerUp.x = x-33
                handlerUp.y = 112
            elseif (step == 4) then
                handlerUp.x = x+33
                handlerUp.y = 112
            elseif (step == 5) then
                handlerUp.x = x+85
                handlerUp.y = 137
            elseif (step == 6) then
                handlerUp.x = x+125
                handlerUp.y = 188
            elseif (step == 7) then
                handlerUp.x = x+135
                handlerUp.y = y-10
            end 
        end
        
        -- Function to update the upper answer to be displayed
        -- It also update the value to be saved for the answer
        function newAnswerUp (newAnswer, numericalAnswer)
    
            -- Need to be removed and created again because it is not possible to 
            -- update the text otherwise
            answerUp:removeSelf()
            answerUp = Wrapper:newParagraph({
                text = newAnswer,
                width = 220,
                height = 100, 			-- fontSize will be calculated automatically if set 
                font = "Prime", 	-- make sure the selected font is installed on your system
                fontSize = 20,			
                lineSpace = 2,
                alignment  = "center",
	
                -- Parameters for auto font-sizing
                fontSizeMin = 12,
                fontSizeMax = 20,
                incrementSize = 2
            })
            
            -- Necessary to do some settings since it is created everytime
            answerUp:setTextColor({0,192,171})
            answerUp:setReferencePoint(display.CenterReferencePoint)
            answerUp.x = x
            answerUp.y = y - 45
        
            answerUpNum = numericalAnswer
        end
        
        -- Do the transition to hide the answer once the screen has been released
        function hideAnswers (event)
            if (event.phase == "ended") then
                transition.to (questionUp, {time=300, alpha=1})
                transition.to (answerUp, {time=300, alpha=0})
                transition.to (questionDown, {time=300, alpha=1})
                transition.to (answerDown, {time=300, alpha=0})
            end
        end
        
        -- Function to handle the touching of any segment of the upper part
	function segmentaTouched (event)
	
            if (onTransition == false) then
		if ((event.phase == "began") or (event.phase == "moved")) then
                    transition.to (questionUp, {time=250, alpha=0.1})
                    transition.to (answerUp, {time=250, alpha=1})
                end
                
		-- Go backwards (from 7 to 1) so segments can be disabled one by one in case of descreasing the number
		if (event.target.step == 7) then
                    
                    -- Set the proper answer according to the question
                    newAnswerUp("Completamente", event.target.step)
            
                    if (currentStepA<7) then
                        -- The segment is white so fill it out with colour 
                        segment7a:nextFrame()
                    end
                elseif (currentStepA >= 7) then
                    -- Hide the following segment, since it should not be visible
                    segment7a:previousFrame()
                end
                    
                if (event.target.step >= 6) then
                    
                    if (event.target.step == 6) then
                        -- Update the answer, set it properly according to the question
                        newAnswerUp("Mucho", event.target.step)
                    end
            
                    if (currentStepA<6) then
                        -- The segment is white so fill it out with colour 
                        segment6a:nextFrame()
                    end
                elseif (currentStepA >= 6) then
                    -- Hide the following segment, since it should not be visible
                    segment6a:previousFrame()
                end
                
                if (event.target.step >= 5) then
                    
                    if (event.target.step == 5) then
                        -- Update the answer, set it properly according to the question
                        newAnswerUp("Bastante", event.target.step)
                    end
            
                    if (currentStepA<5) then
                        -- The segment is white so fill it out with colour 
                        segment5a:nextFrame()
                    end
                elseif (currentStepA >= 5) then
                    -- Hide the following segment, since it should not be visible
                    segment5a:previousFrame()
                end

		if (event.target.step >= 4) then
                    
                    if (event.target.step == 4) then
                        -- Update the answer, set it properly according to the question
                        newAnswerUp("Algo", event.target.step)
                    end
            
                    if (currentStepA<4) then
                        -- The segment is white so fill it out with colour 
                        segment4a:nextFrame()
                    end
	        elseif (currentStepA >= 4) then
                    -- Hide the following segment, since it should not be visible
                    segment4a:previousFrame()
                end
                
                if (event.target.step >= 3) then
                    
                    if (event.target.step == 3) then
                        -- Update the answer, set it properly according to the question
                        newAnswerUp("Poco", event.target.step)
                    end
            
                    if (currentStepA<3) then
                        -- The segment is white so fill it out with colour 
                        segment3a:nextFrame()
                    end
                elseif (currentStepA >= 3) then
                    -- Hide the following segment, since it should not be visible
                    segment3a:previousFrame()
                end
        
                if ((event.target.step >= 2)) then
                    
                    if (event.target.step == 2) then
                        -- Update the answer, set it properly according to the question
                        newAnswerUp("Muy poco", event.target.step)
                    end
            
                    if (currentStepA<2) then
                        -- The segment is white so fill it out with colour 
                        segment2a:nextFrame()
                    end
                elseif (currentStepA >= 2) then
                    -- Hide the following segment, since it should not be visible
                    segment2a:previousFrame()
                end

                if (event.target.step >= 1) then
                    
                    if (event.target.step == 1) then
                        -- Update the answer, set it properly according to the question
                        newAnswerUp("Nada en absoluto", event.target.step)
                    end
            
                    if (currentStepA<1) then 
                        -- The segment is not visible yet, so make it visible 
                        segment1a:nextFrame()
                    end 
                end
        
                -- Update the current step A
                currentStepA = event.target.step
                
                -- Update the handlers (down handler is updated in order to keep it above upper segments and handler)
                moveHandlerUp (currentStepA)
                
                -- Make visible the next button in case both questions have been answered
                if (currentStepA > 0) then
                    nextButton.alpha = 1
                end
            end
        end
    
        function initTransitionClouds ()
            
            local auxXArray = { [1] = 0, [2] = 0, [3] = 0, [4] = 0}
            for i = 8, 11, 1 do
                
                local auxX = math.random(4)
                while (not(auxXArray[auxX] == 0)) do
                    auxX = math.fmod (auxX+1, 4)
                    if (auxX == 0) then
                        auxX = 4
                    end
                end
                
                auxXArray[auxX] = i
                localGroup[i].x = auxX*display.contentWidth/6
                if (not(i == 8)) then
                    localGroup[i].y = localGroup[i-1].y-80
                else
                    localGroup[i].y = -100
                end
            end
        end
        
        function moveToCenterCircularSlider14 ()
            
            local timeAux = math.random(1000, 1500)
            
            local subsetY
            local subset2Count = 0
            for i= 2, 7, 1 do
                
                subsetY = math.random(2)
                
                if (subsetY == 2) and (subset2Count < 3) then
                    transition.to( localGroup[i], { time=timeAux, y=math.random(320,470)} )
                    subset2Count = subset2Count + 1
                else
                    transition.to( localGroup[i], { time=timeAux, y=math.random(100)} )
                end
            end
            
            transition.to( questionUp, { time=timeAux, y=questionUp.y+400} )
            transition.to( segment1a, { time=timeAux, y=segment1a.y+400} )
            transition.to( segment2a, { time=timeAux, y=segment2a.y+400} )
            transition.to( segment3a, { time=timeAux, y=segment3a.y+400} )
            transition.to( segment4a, { time=timeAux, y=segment4a.y+400} )
            transition.to( segment5a, { time=timeAux, y=segment5a.y+400} )
            transition.to( segment6a, { time=timeAux, y=segment6a.y+400} )
            transition.to( segment7a, { time=timeAux, y=segment7a.y+400} )
            transition.to( bgCSlider, { time=timeAux, y=bgCSlider.y+400} )
            
            transition.to( line, { time=timeAux, y=line.y+400} )
            transition.to( handlerUp, { time=timeAux, y=handlerUp.y+400} )
            releaseOnTransition = timer.performWithDelay (timeAux, function () onTransition=false end, 1)
        end
        
        function initCircularSlider14 ()
    
            segment1a:stopAtFrame(1)
            segment2a:stopAtFrame(1)
            segment3a:stopAtFrame(1)
            segment4a:stopAtFrame(1)
            segment5a:stopAtFrame(1)
            segment6a:stopAtFrame(1)
            segment7a:stopAtFrame(1)

            questionUp.y = y-460
            
            segment1a.y = -190
            segment2a.y = -242
            segment3a.y = -279
            segment4a.y = -293
            segment5a.y = -279
            segment6a.y = -242
            segment7a.y = -190
            bgCSlider.y = y-400
            
            currentStepA = 0
            moveHandlerUp (currentStepA)
                
            line.y = -125
                
            handlerUp.x = x-132
            handlerUp.y = -170
            
            local auxXArray = { [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0}
            for i = 2, 7, 1 do
                
                local auxX = math.random(6)
                while (not(auxXArray[auxX] == 0)) do
                    auxX = math.fmod (auxX+1, 6)
                    if (auxX == 0) then
                        auxX = 6
                    end
                end
                
                auxXArray[auxX] = i
                localGroup[i].x = auxX*display.contentWidth/6
                localGroup[i].y = -100
            end
            
            moveToCenterCircularSlider14()
        end

        function moveBelowCircularSlider14 ()
            
            onTransition = true
            
            transition.to (questionUp, {time=300, alpha=1})
            transition.to (answerUp, {time=300, alpha=0})
            
            local timeAux = math.random(1000, 1500)
            
            for i= 2, 7, 1 do
                transition.to( localGroup[i], { time=timeAux, y=localGroup[i].y+500} )
            end
            
            for i= 8, 11, 1 do
                transition.to( localGroup[i], { time=2400, y=localGroup[i].y+900} )
            end
            
            transition.to( questionUp, { time=timeAux, y=questionUp.y+430} )
            transition.to( segment1a, { time=timeAux, y=segment1a.y+430} )
            transition.to( segment2a, { time=timeAux, y=segment2a.y+430} )
            transition.to( segment3a, { time=timeAux, y=segment3a.y+430} )
            transition.to( segment4a, { time=timeAux, y=segment4a.y+430} )
            transition.to( segment5a, { time=timeAux, y=segment5a.y+430} )
            transition.to( segment6a, { time=timeAux, y=segment6a.y+430} )
            transition.to( segment7a, { time=timeAux, y=segment7a.y+430} )
            transition.to( bgCSlider, { time=timeAux, y=bgCSlider.y+430} )
            
            transition.to( line, { time=timeAux, y=line.y+430} )
                
            transition.to( handlerUp, { time=timeAux, y=handlerUp.y+430} )
            
            -- Move the remaining items
            transition.to( nextButtonImage, { time=timeAux, y=nextButtonImage.y+430} )
            transition.to( nextButton, { time=timeAux, y=nextButton.y+430} )
            
            -- Call the next screen function within 2,4 seconds
            moveNextScreenTimer = timer.performWithDelay (2400, moveNextScreen(), 1)
        end
	
        ------------------
	-- Components
	------------------
	
		-- Open the database
        db = sqlite3.open(dbPath)
        
		for row in db:nrows("SELECT * FROM f_prov WHERE p_id=0") do
	        currentReminder = row.p_currentReminder
	    end
		
		currentReminder = currentReminder + 1
	    -- Update the current questionnaire number in the database, so the tutorial is skipped next time
	    local q = "UPDATE f_prov SET p_currentReminder="..currentReminder.." WHERE p_id=0;"
	    if not(db:exec(q) == sqlite3.OK) then
	        native.showAlert( "HappyUp", "Error updating the current step in the database", { "Ok" } )
	        exit()
	    end
		
	    for row in db:nrows("SELECT * FROM f_prov WHERE p_id=0") do
	        param.currentQuestionnaire=row.p_currentQuestionnaire
	        currentReminder = row.p_currentReminder
	    end

		--native.showAlert( "HappyUp", "Current questionnaire "..param.currentQuestionnaire, { "Ok" } )
		
	-- Load the background
	bg = display.newImage("multimedia/background/background.jpg")
	localGroup:insert(bg)
	bg.x = x
	bg.y = display.contentHeight/2
	
	-- Create the clouds to be in the background
        for i = 1, 6, 1 do
            -- Create the new item which is taken from multimedia folder
            local obj = display.newImage("multimedia/background/cloud"..i..".png");

            -- Add the item to the group
            localGroup:insert(obj)
        
            obj.x = math.random(350)
            obj.y = -100
	end
	
	-- Create the clouds to appear during the transition
        for i = 1, 4, 1 do
            -- Create the new item which is taken from multimedia folder
            local obj = display.newImage("multimedia/background/cloud"..i..".png");

            -- Add the item to the group
            localGroup:insert(obj)
        
            obj.x = math.random(300)
            if (not(i == 8)) then
                obj.y = localGroup[i+7-1].y-80
            else
                obj.y = -100
            end
	end
	
	-- Load the background of the circular slider
	bgCSlider = display.newImage("multimedia/circular_slider_14/white_circular_slider_14.png")
	localGroup:insert(bgCSlider)
	bgCSlider.x = x
	bgCSlider.y = display.contentHeight/2
    
	-- Initialize question and answer objects that will bre removed to create the paragraphs with the proper content
        questionUp = Wrapper:newParagraph({
            text = "¿En qué grado has completado tu tarea de entrenamiento?",
            width = 180,
            height = 25, 			-- fontSize will be calculated automatically if set 
            font = "Prime", 	-- make sure the selected font is installed on your system
            fontSize = 18,			
            lineSpace = 2,
            alignment  = "center",
	
            -- Parameters for auto font-sizing
            fontSizeMin = 18,
            fontSizeMax = 18,
            incrementSize = 2
        })
        questionUp:setTextColor({88, 88, 90})
        questionUp:setReferencePoint(display.CenterReferencePoint)
        
        answerUp = display.newText("",-10,-10,10,1)
        
        line = display.newImage("multimedia/background/line.png")
	
	-- The attribute step is used to identify the segment when touched and the event listener function is launched
	segment1a = movieclip.newAnim{"multimedia/circular_slider_14/1a_w.png", "multimedia/circular_slider_14/1a.png"}
        segment1a.step = 1
        segment1a:addEventListener("touch", segmentaTouched)
	segment2a = movieclip.newAnim{"multimedia/circular_slider_14/2a_w.png", "multimedia/circular_slider_14/2a.png"}
	segment2a.step = 2
        segment2a:addEventListener("touch", segmentaTouched)
	segment3a = movieclip.newAnim{"multimedia/circular_slider_14/3a_w.png", "multimedia/circular_slider_14/3a.png"}
	segment3a.step = 3
        segment3a:addEventListener("touch", segmentaTouched)
	segment4a = movieclip.newAnim{"multimedia/circular_slider_14/4a_w.png", "multimedia/circular_slider_14/4a.png"}
	segment4a.step = 4
        segment4a:addEventListener("touch", segmentaTouched)
	segment5a = movieclip.newAnim{"multimedia/circular_slider_14/5a_w.png", "multimedia/circular_slider_14/5a.png"}
	segment5a.step = 5
        segment5a:addEventListener("touch", segmentaTouched)
	segment6a = movieclip.newAnim{"multimedia/circular_slider_14/6a_w.png", "multimedia/circular_slider_14/6a.png"}
	segment6a.step = 6
        segment6a:addEventListener("touch", segmentaTouched)
	segment7a = movieclip.newAnim{"multimedia/circular_slider_14/7a_w.png", "multimedia/circular_slider_14/7a.png"}
	segment7a.step = 7
        segment7a:addEventListener("touch", segmentaTouched)
	
	handlerUp = display.newImage("multimedia/circular_slider_14/handlerUp.png")
	
	nextButtonImage = display.newImage("multimedia/next_disabled.png")
	
	nextButton = ui.newButton{
		default = "multimedia/next_active.png",
		over = "multimedia/next_pressed.png",
		onRelease = touchedNextButton,
		id = "nextbutton",
		text = "",
		font = "Times New Roman",
		size = 20
	}
        
	Runtime:addEventListener("touch",hideAnswers)

        ------------------
	-- Running on load
	------------------
        
	-- Set the next button as invisible until both questions are answered
	nextButton.alpha = 0
    
        -- Set initial value for the answers to zero
        currentStepA = 0
        
        -- Add the listener to close the database in case of application exit
        Runtime:addEventListener("system", onSystemEvent)
    
        ------------------
	-- Inserts
	------------------
        localGroup:insert(questionUp)
	localGroup:insert(answerUp)
    
        localGroup:insert(line)
	localGroup:insert(segment1a)
	localGroup:insert(segment2a)
	localGroup:insert(segment3a)
	localGroup:insert(segment4a)
	localGroup:insert(segment5a)
	localGroup:insert(segment6a)
	localGroup:insert(segment7a)
    
        localGroup:insert(handlerUp)
        
        localGroup:insert(nextButtonImage)
        localGroup:insert(nextButton)
	
	------------------
	-- Positions
	------------------
	
        -- Set x position for the segments, line and questions
        line.x = x
        line.y = -100
        handlerUp.y = -100
        segment1a.x = x-129 
        segment2a.x = x-105
        segment3a.x = x-59
        segment4a.x = x-2
        segment5a.x = x+57
        segment6a.x = x+103
        segment7a.x = x+127
        questionUp.x = x
    
        -- Initialize the circular slider of 14 segments
        -- moving them from the upper part of the screen
        initCircularSlider14()
        
        -- Set the positions for the buttons
	nextButtonImage.x = display.contentWidth-40
	nextButtonImage.y = display.contentHeight-40
	nextButton.x = display.contentWidth-40
	nextButton.y = display.contentHeight-40
	
	return localGroup
	
end