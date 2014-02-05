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
        local number
        local nextButtonImage
        local nextButton
        local infoButton
        local segment1a
        local segment2a
        local segment3a
        local segment4a
        local segment5a
        local segment6a
        local segment7a
        local segment1d
        local segment2d
        local segment3d
        local segment4d
        local segment5d
        local segment6d
        local segment7d
        local handlerUp
        local handlerDown
        local questionUpText
        local questionDownText
        local questionUp
        local questionDown
        local answerUpNum
        local answerDownNum
        local answerUp
        local answerDown
        local manImage
        local womanImage
        local arrowUp
        local arrowDown
        local foreignPC
        local foreignPCText
	
        local currentStepA
        local currentStepD
        
        local initCS14
        local updateTransitionClouds
        local releaseOnTransition
        local moveNextScreenTimer
        local onTransition = true
    
        local gender = ""
        local age = { }
        local postalCode = { }
        
        local db
        local dbPath = system.pathForFile("happyUpDB", system.DocumentsDirectory)
        
	------------------
	-- Groups
	------------------
	local cloudGroup = display.newGroup()
	local localGroup = display.newGroup()
        
	------------------
	-- Functions
	------------------

        -- Calculate the age inserted
        function calculateAge ()
            
            return 10*age[1].value + age[2].value
        end

        -- Calculate the postal code inserted
        function calculatePC ()
            
            local postalCodeNum = 0
        
            for i = 1, 5, 1 do
                postalCodeNum = 10*postalCodeNum + postalCode[i].value
            end
            
            return postalCodeNum
        end

        -- Save the result when the next button is pressed
        function saveResult ()
            
            local q
        
            if (param.currentStep < 19) then
        
                if (param.currentStep == 8) then
                    -- This value must be interpreted at the reverse, so invert the value
                    if (answerUpNum == 7) then
                        answerUpNum = 1
                    elseif (answerUpNum == 6) then
                        answerUpNum = 2
                    elseif (answerUpNum == 5) then
                        answerUpNum = 3
                    elseif (answerUpNum == 3) then
                        answerUpNum = 5
                    elseif (answerUpNum == 2) then
                        answerUpNum = 6
                    elseif (answerUpNum == 1) then
                        answerUpNum = 7
                    end
                end
        
                -- Prepare the number of the question to be saved properly
                local questionNum = 2*param.currentStep-1
                if (param.currentStep == 18) then
                    -- It is a profile question, it is saved directly in the final questionnaire
                    q = "UPDATE f_questionnaire SET qst_job="..answerUpNum.." WHERE qst_id="..param.currentQuestionnaire..";"
                else 
                    q = "UPDATE f_prov SET p_question"..questionNum.."="..answerUpNum.." WHERE p_id=0;"
                end
                
                -- Execute the query to save the result of the upper question
                if not(db:exec(q) == sqlite3.OK) then
                    native.showAlert( "HappyUp", "Error saving the results in the database", { "Ok" } )
                    exit()
                end
        
                questionNum = 2*param.currentStep
                
                if (param.currentStep == 17) then
                    -- It is a profile question, it is saved directly in the final questionnaire
                    q = "UPDATE f_questionnaire SET qst_health="..answerDownNum.." WHERE qst_id="..param.currentQuestionnaire..";"
                elseif (param.currentStep == 18) then
                    -- It is a profile question, it is saved directly in the final questionnaire
                    q = "UPDATE f_questionnaire SET qst_love="..answerDownNum.." WHERE qst_id="..param.currentQuestionnaire..";"
                else 
                    q = "UPDATE f_prov SET p_question"..questionNum.."="..answerDownNum.." WHERE p_id=0;"
                end
            elseif (param.currentStep == 19) then
                q = "UPDATE f_user SET usr_age="..calculateAge().." WHERE usr_id=0;"
            elseif (param.currentStep == 20) then
                if (gender == "man") then
                    q = [[UPDATE f_user SET usr_gender='man' WHERE usr_id=0;]]
                else
                    q = [[UPDATE f_user SET usr_gender='woman' WHERE usr_id=0;]]
                end
            else
                if (foreignPC.value == "selected") then
                    q = "UPDATE f_user SET usr_postal_code=1 WHERE usr_id=0;"
                else
                    q = "UPDATE f_user SET usr_postal_code="..calculatePC().." WHERE usr_id=0;"
                end
            end
            
            -- Execute the query
            if not(db:exec(q) == sqlite3.OK) then
                native.showAlert( "HappyUp", "Error saving the results in the database", { "Ok" } )
                exit()
            end
        end
        
        local function networkListener( event )
            if ( event.isError ) then
                native.showAlert( "HappyUp", "Network Error", { "Ok" } )
                exit()
            end
        end
        
	-- Calculate the final result when the questionnaire is completed
        function calculateResult ()
            
            local step1
            local step2
            local step3
            local step4
            local step5
            local step6
            local step7
            local scale7shq
            local diener
            local love
            local health
            local job
            local user_server_id
            local user_server_password
            local age
            local gender
            local postal_code
        
            -- Get the temporary results and do the calculations
            for row in db:nrows("SELECT * FROM f_prov WHERE p_id=0") do
                -- Calculate the value of every step
                -- Average of upperQuestions multiplicated by the range of the step minus the absolute value of minus the range of the step
                step1 = (row.p_question1+row.p_question3)/2*1-math.abs((row.p_question2+row.p_question4)/2-1)
                step2 = (row.p_question5+row.p_question7)/2*2-math.abs((row.p_question6+row.p_question8)/2-2)
                step3 = (row.p_question9+row.p_question11)/2*3-math.abs((row.p_question10+row.p_question12)/2-3)
                step4 = (row.p_question13+row.p_question15)/2*4-math.abs((row.p_question14+row.p_question16)/2-4)
                step5 = (row.p_question17+row.p_question19)/2*5-math.abs((row.p_question18+row.p_question20)/2-5)
                step6 = (row.p_question21+row.p_question23)/2*6-math.abs((row.p_question22+row.p_question24)/2-6)
                step7 = (row.p_question25+row.p_question27)/2*7-math.abs((row.p_question26+row.p_question28)/2-7)
            
                -- Final result is the addition of the whole previous steps
                scale7shq = step1 + step2 + step3 + step4 + step5 + step6 + step7
            
                -- For Diener scale add the corresponding five question results
                diener = row.p_question29+row.p_question30+row.p_question31+row.p_question32+row.p_question33
            end
            
            -- Saves everything 
            -- Update the current questionnaire number in the database
            local q = "UPDATE f_questionnaire SET qst_diener="..diener..", qst_step1="..step1..", qst_step2="..step2..", qst_step3="..step3
            q = q..", qst_step4="..step4..", qst_step5="..step5..", qst_step6="..step6..", qst_step7="..step7..", qst_7shs="..scale7shq.." WHERE qst_id="..param.currentQuestionnaire..";"
            if not(db:exec(q) == sqlite3.OK) then
                native.showAlert( "HappyUp", "Error saving the calculated results", { "Ok" } )
                exit()
            end
            
            -- Get the profile answers
            for row in db:nrows("SELECT * FROM f_questionnaire WHERE qst_id="..param.currentQuestionnaire) do
                love = row.qst_love
                health = row.qst_health
                job = row.qst_job
            end
            
            -- Get the user id and password of the server
            for row in db:nrows("SELECT * FROM f_user WHERE usr_id=0") do
                user_server_id = row.usr_server_id
                user_server_password = row.usr_server_password
                age = row.usr_age       
                gender = row.usr_gender
                postal_code = row.usr_postal_code
            end
            
            postData = "id=" .. user_server_id .. "&passwd=" .. user_server_password .. "&step1=" .. step1 .. "&step2=" .. step2 .. "&step3=" .. step3 .. "&step4=" .. step4 .. "&step5=" 
            postData = postData .. step5 .. "&step6=" .. step6 .. "&step7=" .. step7 .. "&scale7shq=" .. scale7shq .. "&diener=" .. diener .. "&love=" .. love .. "&health=" .. health .. "&job=" .. job
            
            local params = {}
            local headers = {}
            headers["Cache-control"] = "no-cache"
            params.headers = headers
            --params.body = postData
 
            network.request( "http://database.socientize.eu/happyup/createquestionnaire?"..postData, "POST", networkListener, params)
 
            if (param.currentQuestionnaire == 1) then
                -- First time, send also user data
                postData = "id=" .. user_server_id .. "&passwd=" .. user_server_password .. "&age=" .. age .. "&gender=" .. gender .. "&postal_code=" .. postal_code
                
                params = {}
                params.headers = headers
                --params.body = postData
 
	            network.request( "http://database.socientize.eu/happyup/modifyuser?"..postData, "POST", networkListener, params)

                --network.request( "http://database.socientize.eu/happyup/modifyuser", "POST", networkListener, params)

            end
            
            return math.floor((scale7shq+5)/201*100)
        end
        
        local touchedNextButton = function ( event )
		if event.phase == "ended" then
        
                    -- Save the current result
                    saveResult()
                    
                    -- Check if the questionnaire has been completed
                    if (param.currentStep == 21) or ((param.currentStep == 18) and (param.currentQuestionnaire > 1)) then
                                    
                        result = calculateResult()
            
                        param.currentStep = 22

                        -- Remove items from the screen
                        moveBelowCircularSlider14()
                        
                        -- Update the current questionnaire number in the database
                        q = "UPDATE f_prov SET p_currentStep="..param.currentStep.." WHERE p_id=0;"
                        if not(db:exec(q) == sqlite3.OK) then
                            native.showAlert( "HappyUp", "Error updating the current step in the database", { "Ok" } )
                            exit()
                        end
                        
                        -- Close database
                        if db:isopen() then
                            db:close()
                        end
                    else 
                        -- End not reached, next question, so initialize the components
                        param.currentStep = param.currentStep + 1
                        
                        -- Update the current questionnaire number in the database
                        q = "UPDATE f_prov SET p_currentStep="..param.currentStep.." WHERE p_id=0;"
                        if not(db:exec(q) == sqlite3.OK) then
                            native.showAlert( "HappyUp", "Error updating the current step", { "Ok" } )
                            exit()
                        end
                        
                        -- Move the position of the number when the number needs two digits
                        if (param.currentStep == 10) then
                            number.x = 30
                            over20.x = 77
                        elseif (param.currentStep == 20) then
                            number.x = 40
                            over20.x = 87
                        end
                        number:stopAtFrame(param.currentStep)
                        
                        nextButton.alpha = 0
                        
                        moveBelowCircularSlider14()
                    end
		end
	end
        
        local touchedInfoButton = function ( event )
		if event.phase == "ended" then

                    -- Close database
                    if db:isopen() then
                        db:close()
                    end
                    
                    moveNextScreen (6)
		end
	end
    
        -- Do the necessary to move to the next screen
        function moveNextScreen (screen)
           
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
            
            local paramNew = {currentStep=param.currentStep, currentQuestionnaire=param.currentQuestionnaire, finalResult=result, socialNetworks=false}
            if (screen == 3) then
                -- No effect for the transition
                director:changeScene( paramNew, "screen3", "none" )
            else
                -- Screen 6 (tutorial), do effect
                director:changeScene( paramNew, "screen6", "flip" )
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
        
        -- Function to move handler of the below part
        function moveHandlerDown (step)
            
            if (step == 0) then
                handlerDown.x = x+135
                handlerDown.y = y+20
            elseif (step == 1) then
                handlerDown.x = x+125
                handlerDown.y = 292
            elseif (step == 2) then
                handlerDown.x = x+85
                handlerDown.y = 343
            elseif (step == 3) then
                handlerDown.x = x+33
                handlerDown.y = 368
            elseif (step == 4) then
                handlerDown.x = x-33
                handlerDown.y = 368
            elseif (step == 5) then
                handlerDown.x = x-85
                handlerDown.y = 340
            elseif (step == 6) then
                handlerDown.x = x-120
                handlerDown.y = 292
            elseif (step == 7) then
                handlerDown.x = x-132
                handlerDown.y = y+19
            end 
        end
        
        function newQuestionUp ()
            
            -- Set the question text and execute the query
            
            -- Choose the qst_id
            local queryAux
            if (param.currentStep < 15) then
                queryAux = param.currentStep+5
            elseif (param.currentStep == 15) then
                queryAux = 1
            elseif (param.currentStep == 16) then
                queryAux = 3
            elseif (param.currentStep == 17) then
                queryAux = 5
            elseif (param.currentStep == 18) then
                queryAux = 25
            elseif (param.currentStep == 19) then
                queryAux = 21
            elseif (param.currentStep == 20) then
                queryAux = 22
            else
                queryAux = 23
            end
            
            -- Execute the query
            for row in db:nrows("SELECT * from f_question where qst_id=" .. queryAux) do
                questionUpText = row.qst_question
            end
           
            questionUp:removeSelf()
            if (param.currentStep > 18) then
                questionUp = Wrapper:newParagraph({
                    text = questionUpText,
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
            elseif  (param.currentStep == 11) then
                questionUp = Wrapper:newParagraph({
                    text = questionUpText,
                    width = 180,
                    height = 25, 			-- fontSize will be calculated automatically if set 
                    font = "Prime", 	-- make sure the selected font is installed on your system
                    fontSize = 15,			
                    lineSpace = 2,
                    alignment  = "center",
	
                    -- Parameters for auto font-sizing
                    fontSizeMin = 15,
                    fontSizeMax = 15,
                    incrementSize = 2
                })
            elseif  (param.currentStep == 14) then
                questionUp = Wrapper:newParagraph({
                    text = questionUpText,
                    width = 180,
                    height = 25, 			-- fontSize will be calculated automatically if set 
                    font = "Prime", 	-- make sure the selected font is installed on your system
                    fontSize = 14,			
                    lineSpace = 2,
                    alignment  = "center",
	
                    -- Parameters for auto font-sizing
                    fontSizeMin = 14,
                    fontSizeMax = 14,
                    incrementSize = 2
                })
            else
                questionUp = Wrapper:newParagraph({
                    text = questionUpText,
                    width = 220,
                    height = 100, 			-- fontSize will be calculated automatically if set 
                    font = "Prime", 	-- make sure the selected font is installed on your system
                    fontSize = 15,			
                    lineSpace = 2,
                    alignment  = "center",
	
                    -- Parameters for auto font-sizing
                    fontSizeMin = 15,
                    fontSizeMax = 15,
                    incrementSize = 2
                })
            end
            questionUp:setTextColor({88, 88, 90})
            questionUp:setReferencePoint(display.CenterReferencePoint)
            questionUp.x = x
        end
        
        function newQuestionDown ()
            
            -- Set the question text and execute the query
            
            -- Choose the qst_id
            local queryAux
            if (param.currentStep < 15) then
                queryAux = 20
            elseif (param.currentStep == 15) then
                queryAux = 2
            elseif (param.currentStep == 16) then
                queryAux = 4
            elseif (param.currentStep == 17) then
                queryAux = 24
            elseif (param.currentStep == 18) then
                queryAux = 26
            end

            -- Execute the query
            for row in db:nrows("SELECT * from f_question where qst_id=" .. queryAux) do
                questionDownText = row.qst_question
            end
        
            questionDown:removeSelf()
            if (param.currentStep == 11) then
                questionDown = Wrapper:newParagraph({
                    text = questionDownText,
                    width = 180,
                    height = 25, 			-- fontSize will be calculated automatically if set 
                    font = "Prime", 	-- make sure the selected font is installed on your system
                    fontSize = 15,			
                    lineSpace = 2,
                    alignment  = "center",
	
                    -- Parameters for auto font-sizing
                    fontSizeMin = 15,
                    fontSizeMax = 15,
                    incrementSize = 2
                })
            elseif  (param.currentStep == 14) then
                questionDown = Wrapper:newParagraph({
                    text = questionDownText,
                    width = 180,
                    height = 25, 			-- fontSize will be calculated automatically if set 
                    font = "Prime", 	-- make sure the selected font is installed on your system
                    fontSize = 14,			
                    lineSpace = 2,
                    alignment  = "center",
	
                    -- Parameters for auto font-sizing
                    fontSizeMin = 14,
                    fontSizeMax = 14,
                    incrementSize = 2
                })
            else 
                questionDown = Wrapper:newParagraph({
                    text = questionDownText,
                    width = 220,
                    height = 100, 			-- fontSize will be calculated automatically if set 
                    font = "Prime", 	-- make sure the selected font is installed on your system
                    fontSize = 15,			
                    lineSpace = 2,
                    alignment  = "center",
	
                    -- Parameters for auto font-sizing
                    fontSizeMin = 15,
                    fontSizeMax = 15,
                    incrementSize = 2
                })
            end
        
            questionDown:setTextColor({88, 88, 90})
            questionDown:setReferencePoint(display.CenterReferencePoint)
            questionDown.x = x
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
        
        -- Function to update the down answer to be displayed
        -- It also update the value to be saved for the answer
        function newAnswerDown (newAnswer, numericalAnswer)
    
            -- Need to be removed and created again because it is not possible to 
            -- update the text otherwise
            answerDown:removeSelf()
            answerDown = Wrapper:newParagraph({
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
            answerDown:setTextColor({0,192,171})
            answerDown:setReferencePoint(display.CenterReferencePoint)
            answerDown.x = x
            answerDown.y = y+50
        
            answerDownNum = numericalAnswer
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
                    if (param.currentStep<15) then
                        newAnswerUp("Completamente", event.target.step)
                    elseif ((param.currentStep>=15) and (param.currentStep<18)) then
                        newAnswerUp("Totalmente de acuerdo", event.target.step)
                    elseif (param.currentStep>=18) then
                        newAnswerUp("Genial", event.target.step)
                    end
            
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
                        if (param.currentStep<15) then
                            newAnswerUp("Mucho", event.target.step)
                        elseif ((param.currentStep>=15) and (param.currentStep<18)) then
                            newAnswerUp("De acuerdo", event.target.step)
                        elseif (param.currentStep>=18) then
                            newAnswerUp("Muy bien", event.target.step)
                        end
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
                        if (param.currentStep<15) then
                            newAnswerUp("Bastante", event.target.step)
                        elseif ((param.currentStep>=15) and (param.currentStep<18)) then
                            newAnswerUp("Ligeramente de acuerdo", event.target.step)
                        elseif (param.currentStep>=18) then
                            newAnswerUp("Bien", event.target.step)
                        end
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
                        if (param.currentStep<15) then
                            newAnswerUp("Algo", event.target.step)
                        elseif ((param.currentStep>=15) and (param.currentStep<18)) then
                            newAnswerUp("Ni de acuerdo ni en desacuerdo", event.target.step)
                        elseif (param.currentStep>=18) then
                            newAnswerUp("Normal", event.target.step)
                        end
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
                        if (param.currentStep<15) then
                            newAnswerUp("Poco", event.target.step)
                        elseif ((param.currentStep>=15) and (param.currentStep<18)) then
                            newAnswerUp("Ligeramente en desacuerdo", event.target.step)
                        elseif (param.currentStep>=18) then
                            newAnswerUp("Regular", event.target.step)
                        end
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
                        if (param.currentStep<15) then
                            newAnswerUp("Muy poco", event.target.step)
                        elseif ((param.currentStep>=15) and (param.currentStep<18)) then
                            newAnswerUp("En desacuerdo", event.target.step)
                        elseif (param.currentStep>=18) then
                            newAnswerUp("Mal", event.target.step)
                        end
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
                        if (param.currentStep<15) then
                            newAnswerUp("Nada en absoluto", event.target.step)
                        elseif ((param.currentStep>=15) and (param.currentStep<18)) then
                            newAnswerUp("Totalmente en desacuerdo", event.target.step)
                        elseif (param.currentStep>=18) then
                            newAnswerUp("Muy mal", event.target.step)
                        end
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
                moveHandlerDown (currentStepD)
                
                -- Make visible the next button in case both questions have been answered
                if ((currentStepA > 0) and (currentStepD > 0)) then
                    nextButton.alpha = 1
                end
            end
        end
        
        -- Function to handle the touching of any segment of the below part
	function segmentdTouched (event)
                
            if (onTransition == false) then
                
                if ((event.phase == "began") or (event.phase == "moved")) then
                    transition.to (questionDown, {time=250, alpha=0.1})
                    transition.to (answerDown, {time=250, alpha=1})
                end
                
		-- Go backwards (from 7 to 1) so segments can be disabled one by one in case of descreasing the number
		if (event.target.step == 7) then
                    -- Update the answer, set it properly according to the question
                    if (param.currentStep<15) then
                        newAnswerDown("Completamente", event.target.step)
                    elseif ((param.currentStep>=15) and (param.currentStep<17)) then
                        newAnswerDown("Totalmente de acuerdo", event.target.step)
                    elseif (param.currentStep>=17) then
                        newAnswerDown("Genial", event.target.step)
                    end

                    if (currentStepD<7) then
                        -- The segment is white so fill it out with colour 
                        segment7d:nextFrame()
                    end
                elseif (currentStepD >= 7) then
                    -- Hide the following segment, since it should not be visible
                    segment7d:previousFrame()
                end
    
                if (event.target.step >= 6) then
                    
                    if (event.target.step == 6) then
                        -- Update the answer, set it properly according to the question
                        if (param.currentStep<15) then
                            newAnswerDown("Mucho", event.target.step)
                        elseif ((param.currentStep>=15) and (param.currentStep<17)) then
                            newAnswerDown("De acuerdo", event.target.step)
                        elseif (param.currentStep>=17) then
                            newAnswerDown("Muy bien", event.target.step)
                        end
                   end
            
                    if (currentStepD<6) then
                        -- The segment is white so fill it out with colour 
                        segment6d:nextFrame()
                    end
                elseif (currentStepD >= 6) then
                    -- Hide the following segment, since it should not be visible
                    segment6d:previousFrame()
                end
                
                if (event.target.step >= 5) then
                    
                    if (event.target.step == 5) then
                        -- Update the answer, set it properly according to the question
                        if (param.currentStep<15) then
                            newAnswerDown("Bastante", event.target.step)
                        elseif ((param.currentStep>=15) and (param.currentStep<17)) then
                            newAnswerDown("Ligeramente de acuerdo", event.target.step)
                        elseif (param.currentStep>=17) then
                            newAnswerDown("Bien", event.target.step)
                        end
                    end
            
                    if (currentStepD<5) then
                        -- The segment is white so fill it out with colour 
                        segment5d:nextFrame()
                    end
                elseif (currentStepD >= 5) then
                    -- Hide the following segment, since it should not be visible
                    segment5d:previousFrame()
                end
	
		if (event.target.step >= 4) then
                    
                    if (event.target.step == 4) then
                        -- Update the answer, set it properly according to the question
                        if (param.currentStep<15) then
                            newAnswerDown("Algo", event.target.step)
                        elseif ((param.currentStep>=15) and (param.currentStep<17)) then
                            newAnswerDown("Ni de acuerdo ni en desacuerdo", event.target.step)
                        elseif (param.currentStep>=17) then
                            newAnswerDown("Normal", event.target.step)
                        end
                    end
            
                    if (currentStepD<4) then
                        -- The segment is white so fill it out with colour 
                        segment4d:nextFrame()
                    end
	        elseif (currentStepD >= 4) then
                    -- Hide the following segment, since it should not be visible
                    segment4d:previousFrame()
                end
	
                if (event.target.step >= 3) then
                    
                    if (event.target.step == 3) then
                        -- Update the answer, set it properly according to the question
                        if (param.currentStep<15) then
                            newAnswerDown("Poco", event.target.step)
                        elseif ((param.currentStep>=15) and (param.currentStep<17)) then
                            newAnswerDown("Ligeramente en desacuerdo", event.target.step)
                        elseif (param.currentStep>=17) then
                            newAnswerDown("Regular", event.target.step)
                        end
                    end
            
                    if (currentStepD<3) then
                        -- The segment is white so fill it out with colour 
                        segment3d:nextFrame()
                    end
                elseif (currentStepD >= 3) then
                    -- Hide the following segment, since it should not be visible
                    segment3d:previousFrame()
                end
        
                if ((event.target.step >= 2)) then
                    
                    if (event.target.step == 2) then
                        -- Update the answer, set it properly according to the question
                        if (param.currentStep<15) then
                            newAnswerDown("Muy poco", event.target.step)
                        elseif ((param.currentStep>=15) and (param.currentStep<17)) then
                            newAnswerDown("En desacuerdo", event.target.step)
                        elseif (param.currentStep>=17) then
                            newAnswerDown("Mal", event.target.step)
                        end
                    end
            
                    if (currentStepD<2) then
                        -- The segment is white so fill it out with colour 
                        segment2d:nextFrame()
                    end
                elseif (currentStepD >= 2) then
                    -- Hide the following segment, since it should not be visible
                    segment2d:previousFrame()
                end

                if (event.target.step >= 1) then
                    
                    if (event.target.step == 1) then
                        -- Update the answer, set it properly according to the question
                        if (param.currentStep<15) then
                            newAnswerDown("Nada en absoluto", event.target.step)
                        elseif ((param.currentStep>=15) and (param.currentStep<17)) then
                            newAnswerDown("Totalmente en desacuerdo", event.target.step)
                        elseif (param.currentStep>=17) then
                            newAnswerDown("Muy mal", event.target.step)
                        end
                    end
            
                    if (currentStepD<1) then 
                        -- The segment is not visible yet, so make it visible 
                        segment1d:nextFrame()
                   end 
                end
        
                -- Downdate the current step A
                currentStepD = event.target.step
                
                -- Update the handlers (down handler is updated in order to keep it above upper segments and handler)
                moveHandlerUp (currentStepA)
                moveHandlerDown (currentStepD)
                
                -- Make visible the next button in case both questions have been answered
                if ((currentStepA > 0) and (currentStepD > 0)) then
                    nextButton.alpha = 1
                end
            end
	end
    
        -- Function to handle the touching of the numbers of the age
	function ageNumberTouched (event)
	
            -- Display the digit not being updated as not selected (+11)
            age[arrowUp.currentNumber]:stopAtFrame(age[arrowUp.currentNumber].value+11)

            -- Move the arrows to the same x-position of the number touched and let the arrow know which one it is
            arrowUp.x = event.target.x
            arrowDown.x = event.target.x
            arrowUp.currentNumber = event.target.number
        
            -- Display the digit being updated as selected (+1)
            age[arrowUp.currentNumber]:stopAtFrame(age[arrowUp.currentNumber].value+1)
        end
	
	-- Function to handle the touching of the numbers of the postal code
	function postalCodeNumberTouched (event)
	
            -- Display the digit not being updated as not selected (+11)
            postalCode[arrowUp.currentNumber]:stopAtFrame(postalCode[arrowUp.currentNumber].value+11)

            -- Move the arrows to the same x-position of the number touched and let the arrow know which one it is
            arrowUp.x = event.target.x
            arrowDown.x = event.target.x
            arrowUp.currentNumber = event.target.number

            -- Display the digit being updated as selected (+1)
            postalCode[arrowUp.currentNumber]:stopAtFrame(postalCode[arrowUp.currentNumber].value+1)
        end
    
	-- Function to handle the touching of the man for the gender
	function manTouched (event)
	
            -- Move to the frame of the selected man and the deselected woman
            manImage:stopAtFrame(2)
            womanImage:stopAtFrame(1)
            gender = "man"
        
            nextButton.alpha = 1
        end
    
	-- Function to handle the touching of the woman for the gender
	function womanTouched (event)
	
            -- Move to the frame of the selected woman and the deselected man
            manImage:stopAtFrame(1)
            womanImage:stopAtFrame(2)
            gender = "woman"
        
            nextButton.alpha = 1
        end
    
	-- Function to handle the touching of the living abroad button
	function foreignPCTouched (event)
	
            if (event.phase == "ended") then
                -- Move to the appropriate frame
                if (foreignPC.value == "selected") then
                    foreignPC.value = "not_selected"
                    foreignPC:stopAtFrame(1)
                     if ((calculatePC() > 999) and (calculatePC() < 53000)) then
                        -- Valid Postal Code, so allow to pass to the next screen
                        nextButton.alpha = 1
                    else
                        nextButton.alpha = 0
                    end
                else 
                    foreignPC.value = "selected"
                    foreignPC:stopAtFrame(2)
                    nextButton.alpha = 1
                end
            end
        end

	-- Function to handle the touching of the upper arrow
	function arrowUpTouched (event)
	
            if (event.phase == "ended") then
                -- Operate with the corresponding array depending on the current step, that is, the current screen
                -- For every step:
                -- Check whether the number is nine, then switch it to zero. If not, update the value
                -- in the array and the digit being displayed. Field currentNumber from arrowUp stores the digit to be updated.
                -- +1 when updating the frame because the frame array starts with zero in the position 1
                if (param.currentStep == 19) then
                    if (age[arrowUp.currentNumber].value == 9) then
                        age[arrowUp.currentNumber].value = 0
                    else
                        age[arrowUp.currentNumber].value = age[arrowUp.currentNumber].value + 1
                    end
                    
                    -- Display the updated digit
                    age[arrowUp.currentNumber]:stopAtFrame(age[arrowUp.currentNumber].value+1)
                    
                    if (calculateAge() > 5) then
                        -- Valid age, allow to pass to the next screen
                        nextButton.alpha = 1
                    else
                        -- Not valid age, not allow to pass to the next screen
                        nextButton.alpha = 0
                    end
                else 
                    if (postalCode[arrowUp.currentNumber].value == 9) then
                        postalCode[arrowUp.currentNumber].value = 0
                    else
                        postalCode[arrowUp.currentNumber].value = postalCode[arrowUp.currentNumber].value + 1
                    end
                        
                    postalCode[arrowUp.currentNumber]:stopAtFrame(postalCode[arrowUp.currentNumber].value+1)
                        
                    if ((calculatePC() > 999) and (calculatePC() < 53000)) then
                        -- Valid Postal Code, so allow to pass to the next screen
                        nextButton.alpha = 1
                    elseif (foreignPC.value == "not_selected") then
                        -- Not valid Postal Code, so not allow to pass to the next screen
                        nextButton.alpha = 0
                    end
                end
            end
        end
    
        -- Function to handle the touching of the down arrow
	function arrowDownTouched (event)
	
            if (event.phase == "ended") then
                -- Operate with the corresponding array depending on the current step, that is, the current screen
                -- For every step:
                -- Check whether the number is zero, then switch it to 9. If not, update the value
                -- in the array and the digit being displayed. Field currentNumber from arrowUp stores the digit to be updated.
                -- +1 when updating the frame because the frame array starts with zero in the position 1
                if (param.currentStep == 19) then
                    if (age[arrowUp.currentNumber].value == 0) then
                        age[arrowUp.currentNumber].value = 9
                    else
                        age[arrowUp.currentNumber].value = age[arrowUp.currentNumber].value - 1
                    end
                    
                    -- Display the updated digit
                    age[arrowUp.currentNumber]:stopAtFrame(age[arrowUp.currentNumber].value+1)
                    
                    if (calculateAge() > 5) then
                        -- Valid age, allow to pass to the next screen
                        nextButton.alpha = 1
                    else
                        -- Not valid age, not allow to pass to the next screen
                        nextButton.alpha = 0
                    end
                else 
                    if (postalCode[arrowUp.currentNumber].value == 0) then
                        postalCode[arrowUp.currentNumber].value = 9
                    else
                        postalCode[arrowUp.currentNumber].value = postalCode[arrowUp.currentNumber].value - 1
                    end
                        
                    postalCode[arrowUp.currentNumber]:stopAtFrame(postalCode[arrowUp.currentNumber].value+1)
                        
                    if ((calculatePC() > 999) and (calculatePC() < 53000)) then
                        -- Valid Postal Code, so allow to pass to the next screen
                        nextButton.alpha = 1
                    elseif (foreignPC.value == "not_selected") then
                        -- Not valid Postal Code, so not allow to pass to the next screen
                        nextButton.alpha = 0
                    end
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
            
            if (param.currentStep<19) then
                transition.to( questionUp, { time=timeAux, y=questionUp.y+400} )
            else
                transition.to( questionUp, { time=timeAux, y=questionUp.y+400} )
            end
            transition.to( segment1a, { time=timeAux, y=segment1a.y+400} )
            transition.to( segment2a, { time=timeAux, y=segment2a.y+400} )
            transition.to( segment3a, { time=timeAux, y=segment3a.y+400} )
            transition.to( segment4a, { time=timeAux, y=segment4a.y+400} )
            transition.to( segment5a, { time=timeAux, y=segment5a.y+400} )
            transition.to( segment6a, { time=timeAux, y=segment6a.y+400} )
            transition.to( segment7a, { time=timeAux, y=segment7a.y+400} )
            transition.to( segment1d, { time=timeAux, y=segment1d.y+400} )
            transition.to( segment2d, { time=timeAux, y=segment2d.y+400} )
            transition.to( segment3d, { time=timeAux, y=segment3d.y+400} )
            transition.to( segment4d, { time=timeAux, y=segment4d.y+400} )
            transition.to( segment5d, { time=timeAux, y=segment5d.y+400} )
            transition.to( segment6d, { time=timeAux, y=segment6d.y+400} )
            transition.to( segment7d, { time=timeAux, y=segment7d.y+400} )
            transition.to( bgCSlider, { time=timeAux, y=bgCSlider.y+400} )
            
            if (param.currentStep<19) then
                -- Move questions, line and handlers for the common questions
                -- Set the releaseOnTransition in order to allow the segments receive events
                transition.to( questionDown, { time=timeAux, y=questionDown.y+400} )
                transition.to( line, { time=timeAux, y=line.y+400} )
                transition.to( handlerUp, { time=timeAux, y=handlerUp.y+400} )
                transition.to( handlerDown, { time=timeAux, y=handlerDown.y+400} )
                releaseOnTransition = timer.performWithDelay (timeAux, function () onTransition=false end, 1)
            elseif (param.currentStep == 19) then
                -- Age screen
                transition.to( age[1], { time=timeAux, y=age[1].y+400} )
                transition.to( age[2], { time=timeAux, y=age[2].y+400} )
                transition.to( arrowUp, { time=timeAux, y=arrowUp.y+400} )
                transition.to( arrowDown, { time=timeAux, y=arrowDown.y+400} )
            elseif (param.currentStep == 20) then
                -- Gender screen
                transition.to( manImage, { time=timeAux, y=manImage.y+400} )
                transition.to( womanImage, { time=timeAux, y=womanImage.y+400} )
            else
                -- Postal Code screen
                transition.to( postalCode[1], { time=timeAux, y=postalCode[1].y+400} )
                transition.to( postalCode[2], { time=timeAux, y=postalCode[2].y+400} )
                transition.to( postalCode[3], { time=timeAux, y=postalCode[3].y+400} )
                transition.to( postalCode[4], { time=timeAux, y=postalCode[4].y+400} )
                transition.to( postalCode[5], { time=timeAux, y=postalCode[5].y+400} )
                transition.to( arrowUp, { time=timeAux, y=arrowUp.y+400} )
                transition.to( arrowDown, { time=timeAux, y=arrowDown.y+400} )
                transition.to( foreignPC, { time=timeAux, y=foreignPC.y+400} )
                transition.to( foreignPCText, { time=timeAux, y=foreignPCText.y+400} )
            end
        
        end
        
        function initCircularSlider14 ()
    
            segment1a:stopAtFrame(1)
            segment2a:stopAtFrame(1)
            segment3a:stopAtFrame(1)
            segment4a:stopAtFrame(1)
            segment5a:stopAtFrame(1)
            segment6a:stopAtFrame(1)
            segment7a:stopAtFrame(1)
            segment1d:stopAtFrame(1)
            segment2d:stopAtFrame(1)
            segment3d:stopAtFrame(1)
            segment4d:stopAtFrame(1)
            segment5d:stopAtFrame(1)
            segment6d:stopAtFrame(1)
            segment7d:stopAtFrame(1)
            
            newQuestionUp ()
            
            if (param.currentStep<19) then
                questionUp.y = y-445
            else
                questionUp.y = y-460
            end
            segment1a.y = -190
            segment2a.y = -242
            segment3a.y = -279
            segment4a.y = -293
            segment5a.y = -279
            segment6a.y = -242
            segment7a.y = -190
            segment1d.y = -129
            segment2d.y = -78
            segment3d.y = -41
            segment4d.y = -27
            segment5d.y = -41
            segment6d.y = -78
            segment7d.y = -130
            bgCSlider.y = y-400
            
            
            if (param.currentStep<19) then
                -- Initialize elements for common questions
                currentStepA = 0
                currentStepD = 0
                moveHandlerUp (currentStepA)
                moveHandlerDown (currentStepD)
                
                newQuestionDown ()
                questionDown.y = y-345
                line.y = -125
                
                handlerUp.x = x-132
                handlerUp.y = -170
                handlerDown.x = x+135
                handlerDown.y = -140
            elseif (param.currentStep == 19) then
                -- Age screen
                age[1].y = y-370
                age[2].y = y-370
                arrowUp.x = x-20
                arrowUp.y = y-418
                arrowDown.x = x-20
                arrowDown.y = y-325
                arrowUp.currentNumber = 1
            elseif (param.currentStep == 20) then
                -- Gender screen
                manImage.y = y-370
                womanImage.y = y-370
            else
                -- Postal Code screen
                postalCode[1].y = y-380
                postalCode[2].y = y-380
                postalCode[3].y = y-380
                postalCode[4].y = y-380
                postalCode[5].y = y-380
                arrowUp.x = x-80
                arrowUp.y = y-428
                arrowDown.x = x-80
                arrowDown.y = y-335
                arrowUp.currentNumber = 1
                foreignPC.y = y-310
                foreignPCText.y = y-310
            end
            
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
            transition.to (questionDown, {time=300, alpha=1})
            transition.to (answerDown, {time=300, alpha=0})
            
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
            transition.to( segment1d, { time=timeAux, y=segment1d.y+430} )
            transition.to( segment2d, { time=timeAux, y=segment2d.y+430} )
            transition.to( segment3d, { time=timeAux, y=segment3d.y+430} )
            transition.to( segment4d, { time=timeAux, y=segment4d.y+430} )
            transition.to( segment5d, { time=timeAux, y=segment5d.y+430} )
            transition.to( segment6d, { time=timeAux, y=segment6d.y+430} )
            transition.to( segment7d, { time=timeAux, y=segment7d.y+430} )
            transition.to( bgCSlider, { time=timeAux, y=bgCSlider.y+430} )
            
            if (param.currentStep < 20) then
                -- Move down elements from common question screen
                transition.to( questionDown, { time=timeAux, y=questionDown.y+430} )
                transition.to( line, { time=timeAux, y=line.y+430} )
                
                transition.to( handlerUp, { time=timeAux, y=handlerUp.y+430} )
                transition.to( handlerDown, { time=timeAux, y=handlerDown.y+430} )
            elseif (param.currentStep == 20) then
                -- Move down elements from age screen
                transition.to( age[1], { time=timeAux, y=age[1].y+430} )
                transition.to( age[2], { time=timeAux, y=age[2].y+430} )
                transition.to( arrowUp, { time=timeAux, y=arrowUp.y+430} )
                transition.to( arrowDown, { time=timeAux, y=arrowDown.y+430} )
            elseif (param.currentStep == 21) then
                -- Move down elements from gender screen
                transition.to( manImage, { time=timeAux, y=manImage.y+430} )
                transition.to( womanImage, { time=timeAux, y=womanImage.y+430} )
            else
                -- Postal Code screen
                transition.to( postalCode[1], { time=timeAux, y=postalCode[1].y+430} )
                transition.to( postalCode[2], { time=timeAux, y=postalCode[2].y+430} )
                transition.to( postalCode[3], { time=timeAux, y=postalCode[3].y+430} )
                transition.to( postalCode[4], { time=timeAux, y=postalCode[4].y+430} )
                transition.to( postalCode[5], { time=timeAux, y=postalCode[5].y+430} )
                transition.to( arrowUp, { time=timeAux, y=arrowUp.y+430} )
                transition.to( arrowDown, { time=timeAux, y=arrowDown.y+430} )
                transition.to( foreignPC, { time=timeAux, y=foreignPC.y+430} )
                transition.to( foreignPCText, { time=timeAux, y=foreignPCText.y+430} )
            end
            
            if (param.currentStep == 22) then
                -- Move the remaining items
                transition.to( nextButtonImage, { time=timeAux, y=nextButtonImage.y+430} )
                transition.to( nextButton, { time=timeAux, y=nextButton.y+430} )
                transition.to( number, { time=timeAux, y=number.y+430} )
                transition.to( over20, { time=timeAux, y=over20.y+430} )
                
                -- Call the next screen function within 2,4 seconds
                moveNextScreenTimer = timer.performWithDelay (2400, moveNextScreen(3), 1)
            else    
                initCS14 = timer.performWithDelay (timeAux+100, initCircularSlider14, 1)
                updateTransitionClouds = timer.performWithDelay (3500, initTransitionClouds, 1)
            end
        end
	
        ------------------
	-- Components
	------------------
	
	-- Open the database
        db = sqlite3.open(dbPath)
        
        -- Update the currentStep first time application is used
	if (param.currentStep == 0) then
            param.currentStep = 1
            param.currentQuestionnaire = param.currentQuestionnaire + 1
            
            -- Update the current questionnaire number in the database, so the tutorial is skipped next time
            local q = "UPDATE f_prov SET p_currentStep="..param.currentStep.." WHERE p_id=0;"
            if not(db:exec(q) == sqlite3.OK) then
                native.showAlert( "HappyUp", "Error updating the current step", { "Ok" } )
                exit()
            end
            
            -- Update the current questionnaire number in the database
            q = "UPDATE f_prov SET p_currentQuestionnaire="..param.currentQuestionnaire.." WHERE p_id=0;"
            if not(db:exec(q) == sqlite3.OK) then
                native.showAlert( "HappyUp", "Error updating the number of the current questionnaire", { "Ok" } )
                exit()
            end
			
			-- Current questionnaire row must be created in the database
            q = "INSERT INTO f_questionnaire VALUES (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "..param.currentQuestionnaire..");"
            if not(db:exec(q) == sqlite3.OK) then
            	param.currentQuestionnaire = param.currentQuestionnaire + 1

	            -- Update the current questionnaire number in the database
	            q = "UPDATE f_prov SET p_currentQuestionnaire="..param.currentQuestionnaire.." WHERE p_id=0;"
	            if not(db:exec(q) == sqlite3.OK) then
	                native.showAlert( "HappyUp", "Error updating the number of the current questionnaire", { "Ok" } )
	                exit()
	            end

				-- Current questionnaire row must be created in the database
	            q = "INSERT INTO f_questionnaire VALUES (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "..param.currentQuestionnaire..");"
	            if not(db:exec(q) == sqlite3.OK) then
	            	native.showAlert( "HappyUp", "Error creating the row for the new questionnaire", { "Ok" } )
					exit()
	            end
	            
            end
			--native.showAlert( "HappyUp", "Current questionnaire "..param.currentQuestionnaire, { "Ok" } )
        end
	
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
        questionUp = display.newText("",-10,-10,10,1)
        questionDown = display.newText("",-10,-10,10,1)
        answerUp = display.newText("",-10,-10,10,1)
        answerDown = display.newText("",-10,-10,10,1)
        
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
	segment1d = movieclip.newAnim{"multimedia/circular_slider_14/1d_w.png", "multimedia/circular_slider_14/1d.png"}
	segment1d.step = 1
        segment1d:addEventListener("touch", segmentdTouched)
	segment2d = movieclip.newAnim{"multimedia/circular_slider_14/2d_w.png", "multimedia/circular_slider_14/2d.png"}
	segment2d.step = 2
        segment2d:addEventListener("touch", segmentdTouched)
	segment3d = movieclip.newAnim{"multimedia/circular_slider_14/3d_w.png", "multimedia/circular_slider_14/3d.png"}
	segment3d.step = 3
        segment3d:addEventListener("touch", segmentdTouched)
	segment4d = movieclip.newAnim{"multimedia/circular_slider_14/4d_w.png", "multimedia/circular_slider_14/4d.png"}
	segment4d.step = 4
        segment4d:addEventListener("touch", segmentdTouched)
        segment5d = movieclip.newAnim{"multimedia/circular_slider_14/5d_w.png", "multimedia/circular_slider_14/5d.png"}
	segment5d.step = 5
        segment5d:addEventListener("touch", segmentdTouched)
	segment6d = movieclip.newAnim{"multimedia/circular_slider_14/6d_w.png", "multimedia/circular_slider_14/6d.png"}
	segment6d.step = 6
        segment6d:addEventListener("touch", segmentdTouched)
	segment7d = movieclip.newAnim{"multimedia/circular_slider_14/7d_w.png", "multimedia/circular_slider_14/7d.png"}
	segment7d.step = 7
        segment7d:addEventListener("touch", segmentdTouched)
	
	handlerUp = display.newImage("multimedia/circular_slider_14/handlerUp.png")
	handlerDown = display.newImage("multimedia/circular_slider_14/handlerDown.png")
	
        -- The attribute number is used to identify the number when touched and the event listener function is launched
        age[1] = movieclip.newAnim{"multimedia/profile/0s.png", "multimedia/profile/1s.png", "multimedia/profile/2s.png", "multimedia/profile/3s.png", "multimedia/profile/4s.png", "multimedia/profile/5s.png", "multimedia/profile/6s.png", "multimedia/profile/7s.png", "multimedia/profile/8s.png", "multimedia/profile/9s.png", "multimedia/profile/0.png", "multimedia/profile/1.png", "multimedia/profile/2.png", "multimedia/profile/3.png", "multimedia/profile/4.png", "multimedia/profile/5.png", "multimedia/profile/6.png", "multimedia/profile/7.png", "multimedia/profile/8.png", "multimedia/profile/9.png"}
        age[1].number = 1
        age[1]:addEventListener("tap", ageNumberTouched)
        age[1]:stopAtFrame(1)
        age[1].value = 0
        age[2] = movieclip.newAnim{"multimedia/profile/0s.png", "multimedia/profile/1s.png", "multimedia/profile/2s.png", "multimedia/profile/3s.png", "multimedia/profile/4s.png", "multimedia/profile/5s.png", "multimedia/profile/6s.png", "multimedia/profile/7s.png", "multimedia/profile/8s.png", "multimedia/profile/9s.png", "multimedia/profile/0.png", "multimedia/profile/1.png", "multimedia/profile/2.png", "multimedia/profile/3.png", "multimedia/profile/4.png", "multimedia/profile/5.png", "multimedia/profile/6.png", "multimedia/profile/7.png", "multimedia/profile/8.png", "multimedia/profile/9.png"}
        age[2].number = 2
        age[2]:addEventListener("tap", ageNumberTouched)
        age[2]:stopAtFrame(11)
        age[2].value = 0
        
	-- The attribute number is used to identify the number when touched and the event listener function is launched
        postalCode[1] = movieclip.newAnim{"multimedia/profile/0s.png", "multimedia/profile/1s.png", "multimedia/profile/2s.png", "multimedia/profile/3s.png", "multimedia/profile/4s.png", "multimedia/profile/5s.png", "multimedia/profile/6s.png", "multimedia/profile/7s.png", "multimedia/profile/8s.png", "multimedia/profile/9s.png", "multimedia/profile/0.png", "multimedia/profile/1.png", "multimedia/profile/2.png", "multimedia/profile/3.png", "multimedia/profile/4.png", "multimedia/profile/5.png", "multimedia/profile/6.png", "multimedia/profile/7.png", "multimedia/profile/8.png", "multimedia/profile/9.png"}
        postalCode[1].number = 1
        postalCode[1]:addEventListener("tap", postalCodeNumberTouched)
        postalCode[1]:stopAtFrame(1)
        postalCode[1].value = 0
        postalCode[2] = movieclip.newAnim{"multimedia/profile/0s.png", "multimedia/profile/1s.png", "multimedia/profile/2s.png", "multimedia/profile/3s.png", "multimedia/profile/4s.png", "multimedia/profile/5s.png", "multimedia/profile/6s.png", "multimedia/profile/7s.png", "multimedia/profile/8s.png", "multimedia/profile/9s.png", "multimedia/profile/0.png", "multimedia/profile/1.png", "multimedia/profile/2.png", "multimedia/profile/3.png", "multimedia/profile/4.png", "multimedia/profile/5.png", "multimedia/profile/6.png", "multimedia/profile/7.png", "multimedia/profile/8.png", "multimedia/profile/9.png"}
        postalCode[2].number = 2
        postalCode[2]:addEventListener("tap", postalCodeNumberTouched)
        postalCode[2]:stopAtFrame(11)
        postalCode[2].value = 0
        postalCode[3] = movieclip.newAnim{"multimedia/profile/0s.png", "multimedia/profile/1s.png", "multimedia/profile/2s.png", "multimedia/profile/3s.png", "multimedia/profile/4s.png", "multimedia/profile/5s.png", "multimedia/profile/6s.png", "multimedia/profile/7s.png", "multimedia/profile/8s.png", "multimedia/profile/9s.png", "multimedia/profile/0.png", "multimedia/profile/1.png", "multimedia/profile/2.png", "multimedia/profile/3.png", "multimedia/profile/4.png", "multimedia/profile/5.png", "multimedia/profile/6.png", "multimedia/profile/7.png", "multimedia/profile/8.png", "multimedia/profile/9.png"}
        postalCode[3].number = 3
        postalCode[3]:addEventListener("tap", postalCodeNumberTouched)
        postalCode[3]:stopAtFrame(11)
        postalCode[3].value = 0
        postalCode[4] = movieclip.newAnim{"multimedia/profile/0s.png", "multimedia/profile/1s.png", "multimedia/profile/2s.png", "multimedia/profile/3s.png", "multimedia/profile/4s.png", "multimedia/profile/5s.png", "multimedia/profile/6s.png", "multimedia/profile/7s.png", "multimedia/profile/8s.png", "multimedia/profile/9s.png", "multimedia/profile/0.png", "multimedia/profile/1.png", "multimedia/profile/2.png", "multimedia/profile/3.png", "multimedia/profile/4.png", "multimedia/profile/5.png", "multimedia/profile/6.png", "multimedia/profile/7.png", "multimedia/profile/8.png", "multimedia/profile/9.png"}
        postalCode[4].number = 4
        postalCode[4]:addEventListener("tap", postalCodeNumberTouched)
        postalCode[4]:stopAtFrame(11)
        postalCode[4].value = 0
        postalCode[5] = movieclip.newAnim{"multimedia/profile/0s.png", "multimedia/profile/1s.png", "multimedia/profile/2s.png", "multimedia/profile/3s.png", "multimedia/profile/4s.png", "multimedia/profile/5s.png", "multimedia/profile/6s.png", "multimedia/profile/7s.png", "multimedia/profile/8s.png", "multimedia/profile/9s.png", "multimedia/profile/0.png", "multimedia/profile/1.png", "multimedia/profile/2.png", "multimedia/profile/3.png", "multimedia/profile/4.png", "multimedia/profile/5.png", "multimedia/profile/6.png", "multimedia/profile/7.png", "multimedia/profile/8.png", "multimedia/profile/9.png"}
        postalCode[5].number = 5
        postalCode[5]:addEventListener("tap", postalCodeNumberTouched)
        postalCode[5]:stopAtFrame(11)
        postalCode[5].value = 0
        
        foreignPC = movieclip.newAnim{"multimedia/profile/living_abroad_not_selected.png", "multimedia/profile/living_abroad_selected.png"}
        foreignPC:addEventListener("touch", foreignPCTouched)
        foreignPC:stopAtFrame(1)
        foreignPC.value = "not_selected"
        foreignPCText = display.newText("No resido en España",x,30,"Prime",12)
        foreignPCText:setReferencePoint(display.CenterReferencePoint)
        foreignPCText:setTextColor({0,192,171})
            
        manImage = movieclip.newAnim{"multimedia/profile/man.png", "multimedia/profile/man_s.png"}
        manImage:addEventListener("touch", manTouched)
        womanImage = movieclip.newAnim{"multimedia/profile/woman.png", "multimedia/profile/woman_s.png"}
        womanImage:addEventListener("touch", womanTouched)
	
        arrowUp = display.newImage("multimedia/profile/arrow_up.png")
        arrowUp:addEventListener("touch", arrowUpTouched)
        arrowDown = display.newImage("multimedia/profile/arrow_down.png")
        arrowDown:addEventListener("touch", arrowDownTouched)
	
	number = movieclip.newAnim{"multimedia/numbers/1.png", "multimedia/numbers/2.png", "multimedia/numbers/3.png", "multimedia/numbers/4.png", "multimedia/numbers/5.png", "multimedia/numbers/6.png", "multimedia/numbers/7.png", "multimedia/numbers/8.png", "multimedia/numbers/9.png", "multimedia/numbers/10.png", "multimedia/numbers/11.png", "multimedia/numbers/12.png", "multimedia/numbers/13.png", "multimedia/numbers/14.png", "multimedia/numbers/15.png", "multimedia/numbers/16.png", "multimedia/numbers/17.png", "multimedia/numbers/18.png", "multimedia/numbers/19.png", "multimedia/numbers/20.png", "multimedia/numbers/21.png"}
	number:stopAtFrame(param.currentStep)
	if (param.currentQuestionnaire == 0) or (param.currentQuestionnaire == 1) then
            over20 = display.newImage("multimedia/numbers/over21.png")
        else
            over20 = display.newImage("multimedia/numbers/over18.png")
        end
	
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
        
        infoButton = ui.newButton{
		default = "multimedia/info.png",
		over = "multimedia/info.png",
		onRelease = touchedInfoButton,
		id = "infobutton",
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
        currentStepD = 0
        
        -- Add the listener to close the database in case of application exit
        Runtime:addEventListener("system", onSystemEvent)
    
        ------------------
	-- Inserts
	------------------
        localGroup:insert(questionUp)
	localGroup:insert(questionDown)	
        localGroup:insert(answerUp)
	localGroup:insert(answerDown)
    
        localGroup:insert(line)
	localGroup:insert(segment1a)
	localGroup:insert(segment2a)
	localGroup:insert(segment3a)
	localGroup:insert(segment4a)
	localGroup:insert(segment5a)
	localGroup:insert(segment6a)
	localGroup:insert(segment7a)
	localGroup:insert(segment1d)
	localGroup:insert(segment2d)
	localGroup:insert(segment3d)
	localGroup:insert(segment4d)
	localGroup:insert(segment5d)
	localGroup:insert(segment6d)
	localGroup:insert(segment7d)
        
        localGroup:insert(age[1])
        localGroup:insert(age[2])
        localGroup:insert(postalCode[1])
        localGroup:insert(postalCode[2])
        localGroup:insert(postalCode[3])
        localGroup:insert(postalCode[4])
        localGroup:insert(postalCode[5])
        localGroup:insert(foreignPC)
        localGroup:insert(foreignPCText)
        localGroup:insert(manImage)
        localGroup:insert(womanImage)
        localGroup:insert(arrowUp)
        localGroup:insert(arrowDown)
        
        localGroup:insert(handlerUp)
	localGroup:insert(handlerDown)
        
        localGroup:insert(number)
        localGroup:insert(over20)
    
        localGroup:insert(nextButtonImage)
        localGroup:insert(nextButton)
        localGroup:insert(infoButton)
	
	------------------
	-- Positions
	------------------
	
	-- Set the position of the number according to whether the number needs 
        -- two digits or not
        if (param.currentStep < 10) then
            number.x = 10
            over20.x = 57
        elseif (param.currentStep == 20) then
            number.x = 40
            over20.x = 87
        else
            number.x = 30
            over20.x = 77
        end
        number.y = display.contentHeight-40
        over20.y = display.contentHeight-42
        
        -- Set x position for the segments, line and questions
        line.x = x
        line.y = -100
        handlerUp.y = -100
        handlerDown.y = -100
        segment1a.x = x-129 
        segment2a.x = x-105
        segment3a.x = x-59
        segment4a.x = x-2
        segment5a.x = x+57
        segment6a.x = x+103
        segment7a.x = x+127
        segment1d.x = x+127
        segment2d.x = x+104
        segment3d.x = x+58
        segment4d.x = x-1
        segment5d.x = x-59
        segment6d.x = x-105
        segment7d.x = x-130
    
        age[1].x = x-20
        age[1].y = -100
        age[2].x = x+20
        age[2].y = -100
        postalCode[1].x = x-80
        postalCode[1].y = -100
        postalCode[2].x = x-40
        postalCode[2].y = -100
        postalCode[3].x = x
        postalCode[3].y = -100
        postalCode[4].x = x+40
        postalCode[4].y = -100
        postalCode[5].x = x+80
        postalCode[5].y = -100
        foreignPC.x = x-55
        foreignPC.y = -100
        foreignPCText.x = x+15
        foreignPCText.y = -100
        womanImage.x = x-50
        womanImage.y = -100
        manImage.x = x+50
        manImage.y = -100
        arrowUp.y = -100
        arrowDown.y = -100
        
        -- Initialize the circular slider of 14 segments
        -- moving them from the upper part of the screen
        initCircularSlider14()
        
        -- Set the positions for the buttons
	nextButtonImage.x = display.contentWidth-40
	nextButtonImage.y = display.contentHeight-40
	nextButton.x = display.contentWidth-40
	nextButton.y = display.contentHeight-40
	infoButton.x = display.contentWidth-40
	infoButton.y = 40
	
	return localGroup
	
end