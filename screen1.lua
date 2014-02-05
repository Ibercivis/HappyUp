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
        require "sqlite3"
	
	display.setStatusBar(display.HiddenStatusBar)
	local x=display.contentWidth/2
        local y=display.contentHeight/2
	
	local bg
        local cs
        local logo
        
        local auxButton
	local halo
    
        local playCS

        local db
        local dbPath = system.pathForFile("happyUpDB", system.DocumentsDirectory)
        local result
	
	local moveBigStars 
        local moveSmallStars 
	local touchedAuxButton
        local moveToCenter
        local spinHalo
    
	------------------
	-- Groups
	------------------
	local localGroup = display.newGroup()
	
	------------------
	-- Functions
	------------------

        -- Code to show Alert Box if applicationOpen event occurs
        -- (This shouldn't happen, but the code is here to prove the fact)
        function onSystemEvent( event )
	
            if "applicationOpen" == event.type then
                native.showAlert( "Open via custom url", event.url, { "OK" } )
            end
        end

        -- Add the System callback event
        Runtime:addEventListener( "system", onSystemEvent )
        
        -- Function to keep the Big stars moving in the background
        moveBigStars = function ( obj )
            
            obj.y = -y-200
            transition.to( obj, { time=60000, y=obj.y+2*display.contentHeight+400, onComplete=moveBigStars} )
            
        end

        -- Function to keep the small stars moving in the background
        moveSmallStars = function ( obj )
            
            obj.y = -y-200
            transition.to( obj, { time=90000, y=obj.y+2*display.contentHeight+400, onComplete=moveSmallStars} )
            
        end
	
	moveToCenter = function ()
            
            local timeAux = math.random(2000, 2200)
            
            transition.to( cs, { time=timeAux, alpha=1} )
            transition.to( logo, { time=timeAux, alpha=1} )
            
            transition.to( galaxy, { time=400000, y=display.contentHeight-70})
            transition.to( big_stars, { time=30000, y=big_stars.y+display.contentHeight+200, onComplete=moveBigStars})
            transition.to( big_stars_dup, { time=60000, y=big_stars_dup.y+2*display.contentHeight+400, onComplete=moveBigStars})
            transition.to( small_stars, { time=45000, y=small_stars.y+display.contentHeight+200, onComplete=moveSmallStars})
            transition.to( small_stars_dup, { time=90000, y=small_stars_dup.y+2*display.contentHeight+400, onComplete=moveSmallStars})
            
            -- Timer to control when to play the movieclip for the circular slider (once it reaches its position in the screen)
            playCS = timer.performWithDelay (timeAux-500, function () cs:play{loop=1} end, 1)
            
        end
	
	touchedAuxButton = function ( event )
		if event.phase == "ended" then
                    local paramNew = {currentStep=param.currentStep, currentQuestionnaire=param.currentQuestionnaire}
                    
                    -- Cancel and release timers
                    if not(playCS == nil) then
                        -- Check whether it is different to nil
                        timer.cancel(playCS); playCS = nil;
                    end
                    if not(spinHalo == nil) then
                        -- Check whether it is different to nil
                        timer.cancel(spinHalo); spinHalo = nil;
                    end
                    
                    if ((param.currentQuestionnaire == 0) and (param.currentStep == 0)) then
                        -- First time questionnaire is run, so display the tutorial
                        director:changeScene( paramNew, "screen6", "fade" )
                    else
                        -- Not necessary to display the tutorial
                        if not (param.currentStep == 22) then
                            director:changeScene( paramNew, "screen2", "fade" )
                        else 
                            -- Questionnaire already finished, waiting time
                            
                            -- Check whether time from last notification has already passed
                            local lastNotificationTime
                            
                            -- Open the database
                            db = sqlite3.open(dbPath)
                            for row in db:nrows("SELECT * FROM f_prov WHERE p_id=0") do
                                lastNotificationTime = row.p_time
                            end
                            db:close() 
                
                            if (lastNotificationTime < os.time()) then
                                -- Last Notification Time has been reached, so allow questionnaire again and cancel notifications
                
                                -- Check whether currentReminder is ok (if notifications have been ignored currentReminder won't be multiple of 3, so change it)
                                local currentReminder
                                -- Open the database
                                db = sqlite3.open(dbPath)
                                for row in db:nrows("SELECT * FROM f_prov WHERE p_id=0") do
                                    currentReminder = row.p_currentReminder
                                end
                                if not (currentReminder % 3 == 0) then
                                    -- Update the current questionnaire number in the database, so the tutorial is skipped next time
                                    if (currentReminder % 3 == 1) then
                                        currentReminder = currentReminder + 2
                                    else 
                                        currentReminder = currentReminder + 1
                                    end
                                    local q = "UPDATE f_prov SET p_currentReminder="..currentReminder.." WHERE p_id=0;"
                                    if not(db:exec(q) == sqlite3.OK) then
                                        native.showAlert( "HappyUp", "Error updating the current reminder in the database", { "Ok" } )
                                        exit()
                                    end
                                end
                                db:close()
                    
                                system.cancelNotification()
    
                                if (param.currentStep == 22) then
                                    parameters = {currentStep=0, currentQuestionnaire=param.currentQuestionnaire}
                                else
                                    parameters = {currentStep=param.currentStep, currentQuestionnaire=param.currentQuestionnaire}
                                end
                                director:changeScene(parameters, "screen2")
                            else
                                -- Last Notification Time has not been reached, so display the happiness result
                                -- Open the database to get the result
                                db = sqlite3.open(dbPath)
    
                                for row in db:nrows("SELECT * FROM f_questionnaire WHERE qst_id=" .. param.currentQuestionnaire) do
                                    result = row.qst_7shs
                                end
    
                                db:close()
                
                                result = math.floor((result+5)/201*100)
                  
                                paramNew = {currentStep=param.currentStep, currentQuestionnaire=param.currentQuestionnaire, finalResult=result, socialNetworks=true} 
                                director:changeScene( paramNew, "screen3", "fade" )
                            end
                        end
                    end
		end
	end

	------------------
	-- Components
	------------------
	
	-- Load the background
	bg = display.newImage("multimedia/black_bg/black_bg.png")
	
	galaxy = display.newImage("multimedia/black_bg/galaxy.png")
	big_stars = display.newImage("multimedia/black_bg/big_stars.png")
	big_stars_dup = display.newImage("multimedia/black_bg/big_stars.png")
	small_stars = display.newImage("multimedia/black_bg/small_stars.png")
	small_stars_dup = display.newImage("multimedia/black_bg/small_stars.png")
	
	cs = movieclip.newAnim{"multimedia/circular_slider_black/cs0.png", "multimedia/circular_slider_black/cs1.png", "multimedia/circular_slider_black/cs2.png", "multimedia/circular_slider_black/cs3.png", "multimedia/circular_slider_black/cs4.png", "multimedia/circular_slider_black/cs5.png", "multimedia/circular_slider_black/cs6.png", "multimedia/circular_slider_black/cs7.png", "multimedia/circular_slider_black/cs8.png", "multimedia/circular_slider_black/cs9.png", "multimedia/circular_slider_black/cs10.png", "multimedia/circular_slider_black/cs11.png", "multimedia/circular_slider_black/cs12.png", "multimedia/circular_slider_black/cs13.png", "multimedia/circular_slider_black/cs14.png"}
        cs:stopAtFrame(1)
    
	-- Load the logo
	logo = display.newImage("multimedia/black_bg/logo_intro.png")
	
	auxButton = ui.newButton{
		default = "multimedia/buttons/next.png",
		over = "multimedia/buttons/next_over.png",
		onRelease = touchedAuxButton,
		id = "auxbutton",
		text = "",
		font = "Times New Roman",
		size = 20
	}

	halo = display.newImage("multimedia/halo.png")
	
	------------------
	-- Inserts
	------------------
        localGroup:insert(bg)
    
	localGroup:insert(galaxy)
	localGroup:insert(big_stars)
	localGroup:insert(big_stars_dup)
	localGroup:insert(small_stars)
        localGroup:insert(small_stars_dup)
    
	localGroup:insert(cs)
	localGroup:insert(logo)
	
	localGroup:insert(auxButton)
        localGroup:insert(halo)
    
        ------------------
	-- Positions
	------------------
        bg.x = x
	bg.y = y
	cs.x = x

        cs.y = y
        cs.alpha = 0
	logo.x = x	

        logo.y = y
        logo.alpha = 0
	
	galaxy.x = x
        galaxy.y = 30
        big_stars.x = x
        big_stars.y = y
        big_stars_dup.x = x
	big_stars_dup.y = -y-200
        small_stars.x = x
        small_stars.y = y
        small_stars_dup.x = x
	small_stars_dup.y = -y-200
	
	auxButton.x = x
        auxButton.y = display.contentHeight-50
	halo.x = x
        halo.y = display.contentHeight-50
	spinHalo = timer.performWithDelay (5, function () halo:rotate(2) end, -1)
    
	------------------
	-- Running on load
	------------------
	moveToCenter()
        
	return localGroup
	
end