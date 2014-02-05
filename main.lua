local launchArgs = ...

display.setStatusBar( display.HiddenStatusBar )

--====================================================================--
-- DIRECTOR CLASS SAMPLE
--====================================================================--

--[[

 - Version: 1.3
 - Made by Ricardo Rauber Pereira @ 2010
 - Blog: http://rauberlabs.blogspot.com/
 - Mail: ricardorauber@gmail.com

******************
 - INFORMATION
******************

  - This is a little sample of what Director Class does.
  - If you like Director Class, please help us donating at my blog, so I could
	keep doing it for free. http://rauberlabs.blogspot.com/

--]]

--====================================================================--
-- IMPORT DIRECTOR CLASS
--====================================================================--


local director = require("director")
require "sqlite3"
local network = require ("network")
require("movieclip")

local path
local parameters
local newDB = false
local currentReminder

local bg
local cs
local loadingCS

local db
local dbPath = system.pathForFile("happyUpDB", system.DocumentsDirectory)

local checkFile 
local getParameters
local downloadListener
local notificationListener
local main

--====================================================================--
-- CREATE A MAIN GROUP
--====================================================================--

local mainGroup = display.newGroup()

--====================================================================--
-- MAIN FUNCTION
--====================================================================--

-- Function that check that the file is properly formed, otherwise download it
checkFile = function ()
    
    local path = system.pathForFile ("happyUpDB", system.DocumentsDirectory)
    
    local file = io.open (path, "r")
    
    if file then
        -- Get the whole file content
        local content = file:read("*a")
        io.close(file)
        
        if (string.len(content) < 5) then
            -- File corrupt
            native.showAlert( "HappyUp", "Database corrupted", { "Ok" } )
            exit()
            
            return false
        end
    else return false
    end
    
    return true
end

-- Function to get info about the status of the questionnaire and, hence, of the application
getParameters = function ()
    
    -- Open the database
    db = sqlite3.open(dbPath)
    
    for row in db:nrows("SELECT * FROM f_prov WHERE p_id=0") do
        parameters = {currentStep=row.p_currentStep, currentQuestionnaire=row.p_currentQuestionnaire}
        currentReminder = row.p_currentReminder
    end
    
    db:close()    
end

-- Listener for the download event
downloadListener = function (event)
    if (event.isError) then
        native.showAlert( "HappyUp", "Network Error", { "Ok" } )
        exit()
    end
    
    -- Check if the database exists
    path = system.pathForFile("happyUpDB", system.DocumentsDirectory)
        
    local dbFile = io.open( path )
 
    if dbFile then
        -- It exists, so remove the new one
        -- Check the file is properly formed, otherwise download it
        local fileOk = checkFile ()
        
        if fileOk then
            local results, reason = os.remove( system.pathForFile("happyUpDBTmp", system.DocumentsDirectory) )
        else 
            local results, reason = os.remove( system.pathForFile("happyUpDB", system.DocumentsDirectory) )
            newDB = true
        end
    else
        newDB = true
    end
    
    if newDB then
        local results, reason = os.rename( system.pathForFile("happyUpDBTmp", system.DocumentsDirectory),
            system.pathForFile("happyUpDB", system.DocumentsDirectory) )
        
        -- Prevent http caching
        local headers = {}
        headers["Cache-control"] = "no-cache"
        local params = {}
        params.headers = headers
    
        -- Open the database
        db = sqlite3.open(dbPath)
    
        -- Setup the tables if they do not exist 
	local q = "CREATE TABLE IF NOT EXISTS f_reminder (rmnd_date TEXT PRIMARY KEY, rmnd_grade INTEGER NOT NULL);"
        if not(db:exec(q) == sqlite3.OK) then
            native.showAlert( "HappyUp", "Error creating reminder table", { "Ok" } )
            exit()
        end
        
	q = "CREATE TABLE IF NOT EXISTS f_questionnaire (qst_diener INTEGER NOT NULL, qst_health INTEGER NOT NULL, qst_job INTEGER NOT NULL, qst_love INTEGER NOT NULL,"
        q = q .. "qst_step1 REAL NOT NULL, qst_step2 REAL NOT NULL, qst_step3 REAL NOT NULL, qst_step4 REAL NOT NULL, qst_step5 REAL NOT NULL, qst_step6 REAL NOT NULL, qst_step7 REAL NOT NULL, qst_7shs REAL NOT NULL, qst_id INTEGER PRIMARY KEY);"       
        if not(db:exec(q) == sqlite3.OK) then
            native.showAlert( "HappyUp", "Error creating questionnaire table", { "Ok" } )
            exit()
        end
    
	q = "CREATE TABLE IF NOT EXISTS f_prov (p_id INTEGER PRIMARY KEY, p_question1 INTEGER, p_question2 INTEGER, p_question3 INTEGER, p_question4 INTEGER, p_question5 INTEGER, p_question6 INTEGER, p_question7 INTEGER,"
        q = q .. " p_question8 INTEGER, p_question9 INTEGER, p_question10 INTEGER, p_question11 INTEGER, p_question12 INTEGER, p_question13 INTEGER, p_question14 INTEGER, p_question15 INTEGER, p_question16 INTEGER, p_question17 INTEGER,"
        q = q .. " p_question18 INTEGER, p_question19 INTEGER, p_question20 INTEGER, p_question21 INTEGER, p_question22 INTEGER, p_question23 INTEGER, p_question24 INTEGER, p_question25 INTEGER, p_question26 INTEGER, p_question27 INTEGER,"
        q = q .. " p_question28 INTEGER, p_question29 INTEGER, p_question30 INTEGER, p_question31 INTEGER, p_question32 INTEGER, p_question33 INTEGER, p_question34 INTEGER, p_question35 INTEGER, p_question36 INTEGER, p_question37 INTEGER,"
        q = q .. " p_question38 INTEGER, p_question39 INTEGER, p_question40 INTEGER, p_currentStep INTEGER, p_currentQuestionnaire INTEGER, p_currentReminder INTEGER, p_time INTEGER, p_notificationID1, p_notificationID2, p_notificationID3);"       
        if not(db:exec(q) == sqlite3.OK) then
            native.showAlert( "HappyUp", "Error creating provisional table", { "Ok" } )
            exit()
        end
    
        q = "INSERT INTO f_prov VALUES (0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,0,"..os.time()..",NULL,NULL,NULL);"
        if not(db:exec(q) == sqlite3.OK) then
            native.showAlert( "HappyUp", "Error filling provisional table", { "Ok" } )
            exit()
        end
    
	q = "CREATE TABLE IF NOT EXISTS f_user (usr_id INTEGER PRIMARY KEY, usr_age INTEGER, usr_gender TEXT, usr_postal_code INTEGER, usr_server_id INTEGER, usr_server_password INTEGER);"       
        if not(db:exec(q) == sqlite3.OK) then
            native.showAlert( "HappyUp", "Error creating user table", { "Ok" } )
            exit()
        end			

        q = "INSERT INTO f_user VALUES (0,NULL,NULL,NULL,NULL,NULL);"
        if not(db:exec(q) == sqlite3.OK) then
            native.showAlert( "HappyUp", "Error filling user table", { "Ok" } )
            exit()
        end
    
        db:close()

	network.request( "http://database.socientize.eu/happyup/createuser", "GET", networkListener, params)
    else
        -- Get the user id to be inserted in the database
        getParameters()
        if not(loadingCS == nil) then
            -- Check whether it is different to nil
            timer.cancel(loadingCS); loadingCS = nil;
        end
        director:changeScene(parameters, "screen1")
    end
end

networkListener = function (event)
    if (event.isError) then
        native.showAlert( "HappyUp", "Network Error", { "Ok" } )
        exit()
    end
    
    -- Get the user id to be inserted in the database
    local ind,ind2 = string.find(event.response, "user:")
    if ind == nil then
        native.showAlert( "HappyUp", "Network Error", { "Ok" } )
        exit()
    else
        local indP, indP2 = string.find(event.response, "password:")
        local user = tonumber(string.sub(event.response, ind2+1, indP-1))
        local password = string.sub(event.response, indP2+1, indP2+20)
    
        -- Open the database
        db = sqlite3.open(dbPath)
    
        local q = [[UPDATE f_user SET usr_server_id=]] .. user .. [[, usr_server_password=']] .. password .. [[' WHERE usr_id=0;]]
    
        -- Execute the query
        if not(db:exec(q) == sqlite3.OK) then
            native.showAlert( "HappyUp", "Error saving user and password in the database", { "Ok" } )
            exit()
        end
        
        db:close()
    end  
    
    getParameters()
    if not(loadingCS == nil) then
        -- Check whether it is different to nil
        timer.cancel(loadingCS); loadingCS = nil;
    end
    director:changeScene(parameters, "screen1")
end

-------------------------------------------
-- Local Notification listener
-------------------------------------------
--
local notificationListener = function( event )
	
    if not(loadingCS == nil) then
        -- Check whether it is different to nil
        timer.cancel(loadingCS); loadingCS = nil;
    end
    bg:removeSelf()
    cs:removeSelf()
    
    getParameters()
    
	director:changeScene(parameters, "screen4")      
end

-- Code to show Alert Box if applicationOpen event occurs
-- (This shouldn't happen, but the code is here to prove the fact)
function onSystemEvent( event )
	
	if "applicationOpen" == event.type then
		native.showAlert( "Open via custom url", event.url, { "OK" } )
	end
end

-- Add the System callback event
Runtime:addEventListener( "system", onSystemEvent );

bg = display.newImage("Default.png")
mainGroup:insert(bg)
bg.x=display.contentWidth/2
bg.y=display.contentHeight/2
cs = movieclip.newAnim{"multimedia/circular_slider_black/cs0.png", "multimedia/circular_slider_black/cs1.png", "multimedia/circular_slider_black/cs2.png", "multimedia/circular_slider_black/cs3.png", "multimedia/circular_slider_black/cs4.png", "multimedia/circular_slider_black/cs5.png", "multimedia/circular_slider_black/cs6.png", "multimedia/circular_slider_black/cs7.png", "multimedia/circular_slider_black/cs8.png", "multimedia/circular_slider_black/cs9.png", "multimedia/circular_slider_black/cs10.png", "multimedia/circular_slider_black/cs11.png", "multimedia/circular_slider_black/cs12.png", "multimedia/circular_slider_black/cs13.png", "multimedia/circular_slider_black/cs14.png"}
cs:stopAtFrame(1)
mainGroup:insert(cs)
cs.x=display.contentWidth/2
cs.y=display.contentHeight/2
cs:stopAtFrame(1)
cs.alpha = 0.5
loadingCS = timer.performWithDelay (80, function () cs:nextFrame() end, -1)

main = function ()
	
	------------------
	-- Add the group from director class
	------------------
	mainGroup:insert(director.directorView)
	
	-- Prevent http caching
        local headers = {}
        headers["Cache-control"] = "no-cache"
        local params = {}
        params.headers = headers
	network.download ("http://database.socientize.eu/felicitometer", "GET", downloadListener, params, "happyUpDBTmp", system.DocumentsDirectory)
	
	------------------
	-- Return
	------------------
	
	return true
end

--====================================================================--
-- BEGIN
--====================================================================--

-------------------------------------------
-- Check LaunchArgs
-- These ares are only set on a cold start
-------------------------------------------
--
if launchArgs and launchArgs.notification then
	
	getParameters()
        if (currentReminder % 3 == 2) then
            native.showAlert( "HappyUp", "Vamos a ver el progreso que has conseguido con tu entrenamiento", { "Comprueba tu nivel de felicidad" } )
	else 
            native.showAlert( "HappyUp", launchArgs.notification.alert, { "Entrenar" } )
        end
    
	-- Need to call the notification listener since it won't get called if the
	-- the app was already closed.
	notificationListener( launchArgs.notification )
else
    main()
end

-- It's that easy! :-)