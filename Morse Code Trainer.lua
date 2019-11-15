-- Changelog --
-- 2019-11-13: First version considered done

-- References --
-- https://en.wikipedia.org/wiki/Morse_code

-- Minimum requirements: TI Nspire CX (color resulution 318x212)

platform.apilevel = '2.4'
local appversion = "191113" -- Made by: Fredrik Ekelöf, fredrik.ekelof@gmail.com

-- !All positions and sizes uses hand held unit as reference!
-- !Program will scale relative to size on held unit!

-- App layout configuration
local padding = 8 -- Empty space between borders and working area

-- Font size configuration. Availible sizes are 7,9,10,11,12,16,24.
local fntioset = 24 -- I/O font size
local fntlblset = 9 -- Label font size
local fntbtnset = 12 -- Button font size

-- Colors
local bgcolor = 0x36454F -- Background, dark bluegrey
local errorcolor = 0xF02600 -- Error text, dark red

-- Morsecode variabels
local morsecode = {". -","- . . .","- . - .","- . .",".",". . - .","- - .",". . . .",". .",". - - -","- . -",". - . .","- -","- .","- - -",". - - .","- - . -",". - .",". . .","-",". . -",". . . -",". - -","- . . -","- . - -","- - . .",". - - - -",". . - - -",". . . - -",". . . . -",". . . . .","- . . . .","- - . . .","- - - . .","- - - - .","- - - - -"}
local morseflash = {"1100111111000000","111111001100110011000000","1111110011001111110011000000","11111100110011000000","11000000","110011001111110011000000","111111001111110011000000","11001100110011000000","110011000000","11001111110011111100111111000000","111111001100111111000000","110011111100110011000000","11111100111111000000","1111110011000000","1111110011111100111111000000","1100111111001111110011000000","11111100111111001100111111000000","11001111110011000000","1100110011000000","111111000000","11001100111111000000","110011001100111111000000","110011111100111111000000","1111110011001100111111000000","11111100110011111100111111000000","1111110011111100110011000000","1100111111001111110011111100111111000000","110011001111110011111100111111000000","11001100110011111100111111000000","1100110011001100111111000000","110011001100110011000000","1111110011001100110011000000","11111100111111001100110011000000","111111001111110011111100110011000000","1111110011111100111111001111110011000000","11111100111111001111110011111100111111000000"}
local letter ={"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0"}
local letterstr = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"

-- Variabels for internal use
local fntio,fntlbl,fntbtn = fntioset,fntlblset,fntbtnset -- Font size variabels used by functions
local errorcode = false -- Initial value for flagging answer as incorrect
local errormessage = "" -- Initial value for error message prompt
local escrst = 0 -- Tracks how many times Esc key has been pressed
local esccounter = 0 -- Timer for Esc key press reset
local enterpress = false -- Tracks if Enter key is being pressed
local entercounter = 0 -- Timer for check button blue flash when pressing Enter key
local correctstat = 0 -- Inistial value for statistics
local totalstat = 0 -- Initial value for statistics
local random = math.random(36) -- Generates initial random number
local checkmode = 1 -- Preloads "code to letter" at program launch
local outputtext = morsecode[random] -- Initial value for "question" output text at program launch
local inputtext = "" -- Initial value for "answer" output text at program launch
local morseflashdigit = 1 -- Variabel to be used for converting morse binary code to a flashing light

-- Mouse movement button tracking variabels
local optbtn_ctl_click = false -- Tracks if code to letter button is being clicked
local optbtn_ctl_hover = false -- Tracks if mouse hovers over code to letter button
local optbtn_ltc_click = false -- Tracks if letter to code button is being clicked
local optbtn_ltc_hover = false -- Tracks if mouse hovers over letter to code button
local optbtn_ftl_click = false -- Tracks if flash to letter button is being clicked
local optbtn_ftl_hover = false -- Tracks if mouse hovers over flash to letter button
local btncheckclick = false -- Tracks if check button is being clicked
local btncheckhover = false -- Tracks if mouse hovers over check button

-- Screen properties
local scr = platform.window -- Shortcut
local scrwh,scrht = scr:width(),scr:height() -- Stores screen dimensions

-- Images used for push buttons
local buttonblue = image.new(_R.IMG.buttonblue)
local buttongreylight = image.new(_R.IMG.buttongreylight)
local buttonwhite = image.new(_R.IMG.buttonwhite)
local buttonred = image.new(_R.IMG.buttonred)

-- Images used for option buttons
local radiobuttonchecked = image.new(_R.IMG.radiobuttonchecked)
local radiobuttoncheckedgrey = image.new(_R.IMG.radiobuttoncheckedgrey)
local radiobuttonunchecked = image.new(_R.IMG.radiobuttonunchecked)
local radiobuttonuncheckedgrey = image.new(_R.IMG.radiobuttonuncheckedgrey)

function on.construction()

    timer.start(1/5) -- Starts timer with 5 ticks per second

    -- Sets the seed for the random number generator
    math.randomseed(timer.getMilliSecCounter())

    -- Sets background colour
    scr:setBackgroundColor(bgcolor)

    -- Defines option button optbtnxxx = optionbutton(ID,"label text",xpos,ypos,width,height)
    -- Position xy ref is bottom right corner
    optbtn_ctl = optionbutton(1,"Code To Letter",296,8,12,12)
    optbtn_ltc = optionbutton(2,"Letter To Code",192,8,12,12)
    optbtn_ftl = optionbutton(3,"Flash To Letter",86,8,12,12)

    -- Defines push buttons, btnname = pushbutton(ID,"label text",xpos,ypos,width,height)
    -- Position xy ref is bottom right corner
    btncheck = pushbutton(4,"Check",120,26,64,24)

end

-- Shortcut for update/refresh screen
function scrupdate()

    return scr:invalidate()

end

function on.timer() -- Updates screen 5 times per second

    scrupdate() -- Refreshes screen

    -- Generates number sequence to be used in flashing light
    if checkmode == 3 then

        -- Checks morse flash string length
        local morseflashmax = string.len(morseflash[random])

        -- Ticks up though digit positions in morse flash string
        if morseflashdigit < morseflashmax then
            morseflashdigit = morseflashdigit + 1
        elseif  morseflashdigit >= morseflashmax then
            morseflashdigit = 1
        end

    end

end

function on.resize()

    -- Fetches new screen dimensions when window resizes
    scrwh,scrht = scr:width(),scr:height() -- Stores updated screen dimensions

    -- Adjusts font size to screen size
    if scrwh >= 318 then
        fntio = fntioset*scrwh/318
        fntlbl = fntlblset*scrwh/318
        fntbtn = fntbtnset*scrwh/318
    else --Sets minimum font to 7
        fntio = 7
        fntlbl = 7
        fntbtn = 7
    end

end

-- Menu Start --
function menubar(menuoption)

    -- Sets training moode from toolpalette commands
    checkmodeswitch(menuoption)

end

menu = {
    {"Training Mode",
        {"Code To Letter",function() menubar(1) end},
        {"Letter To Code",function() menubar(2) end},
        {"Flash To Letter",function() menubar(3) end},
    },
}
toolpalette.register(menu)
-- Menu End --

function on.charIn(char)

    -- Resets error message
    errorcode = false
    errormessage = ""

    -- Avoids program crash caused by these characters. For some reason they seems to slip through not equal statement.
    if char == "%" or char == "(" or char == "[" then
        char = ""
    end

    -- Prints letter in "code to letter" and "flash to letter" mode
    if checkmode == 1 or checkmode == 3 then
        local letterfind = string.find(letterstr,string.upper(char)) -- Checks if character is a valid letter. Why does "." dot, "$" and "^" pass as valid characters?
        if letterfind ~= nil then -- Confirms character is a valid letter
            inputtext = string.upper(char) -- Prints letter
        end
    end

    -- Prints short and long symbol in letter to code mode. Only ".", "(-)" negative and "-" minus are valid characters. Note empty space in end of input string.
    if checkmode == 2 then
        if char == "." then -- Dot is accepted
            inputtext = inputtext..". "
        elseif char == "-" then -- "-" minus is accepted
            inputtext = inputtext.."- "
        elseif char == string.uchar(8722) then -- "(-)" negative is accepted
            inputtext = inputtext.."- "
        end
    end

end

function on.enterKey()

    -- Triggers check button blue flash
    entercounter = timer.getMilliSecCounter()+200
    enterpress = true

    -- Checks input value. Same functionallity as pressing check button.
    if checkmode == 1 then -- Code to letter mode
        check_ctl()
    elseif checkmode == 2 then -- Letter to code mode
        check_ltc()
    elseif checkmode == 3 then -- Flash to letter mode
        check_ftl()
    end

end

function on.escapeKey()

    -- Clears all values when Esc is being pressed quickly two times
    esccounter = timer.getMilliSecCounter()+500
    escrst = escrst+1

    -- Makes reset
    if escrst == 2 then
        reset()
        escrst = 0 -- Resets counter
    end

end

function on.backspaceKey()

    if checkmode == 1 or checkmode == 3 then -- Removes character
        inputtext = inputtext:usub(0,-2)
    elseif checkmode == 2 then -- Removes "end space" and character
        inputtext = inputtext:usub(0,-3)
    end

end

function on.clearKey()

    inputtext = ""

end

function on.tabKey()

    -- Switches training mode
    if checkmode == 1 then
        checkmodeswitch(2)
    elseif checkmode == 2 then
        checkmodeswitch(3)
    elseif checkmode == 3 then
        checkmodeswitch(1)
    end

end

function on.backtabKey()

    -- Switches training mode
    if checkmode == 1 then
        checkmodeswitch(3)
    elseif checkmode == 2 then
        checkmodeswitch(1)
    elseif checkmode == 3 then
        checkmodeswitch(2)
    end

end

-- Switches check mode
function checkmodeswitch(cm)

    -- Resets statistics
    reset()
    random = randomgen()

    if cm == 1 then
        outputtext = morsecode[random]
        checkmode = 1
    elseif cm == 2 then
        outputtext = letter[random]
        checkmode = 2
    elseif cm == 3 then
        checkmode = 3
    end

end

-- Generates new random number
function randomgen()

    local randomold = random
    local randomnew = math.random(36)

    -- Verifies the same number does not show up two times in a row
    while randomnew == randomold do
        randomnew = math.random(36)
    end

    return randomnew

end

function on.paint(gc)

    -- Calculates correct answers in percent
    local correctstatprct = 0
    if totalstat ~= 0 then -- Avoiding divide by zero
        correctstatprct = 100*correctstat/totalstat
    end

    -- Generates statistics strings to be printed
    local totalstatstr = "Total: "..totalstat
    local correctstatstr = "Correct: "..correctstat.." - "..string.format("%.1f",correctstatprct).."%"

    -- Prints buttons
    optbtn_ctl:paint(gc)
    optbtn_ltc:paint(gc)
    optbtn_ftl:paint(gc)
    btncheck:paint(gc)

    -- Prints warning if program is running in not supported split screen
    if scrht/scrwh < 0.65 or scrht/scrwh > 0.69 or scrht < 212 then -- Prints warning for incorrect screen split
        gc:setColorRGB(errorcolor)
        gc:drawString("Screen ratio not supported!",0,20,"top")
    end

    -- Text color
    gc:setColorRGB(0xFFFFFF)

    -- Prints statistics
    gc:setFont("sansserif","r",fntlbl)
    local corstatwh,corstatht = gc:getStringWidth(correctstatstr),gc:getStringHeight(correctstatstr)
    gc:drawString(correctstatstr,padding,padding,"top") -- Prints correct answers in top left corner
    local totstatwh,totstatht = gc:getStringWidth(totalstatstr),gc:getStringHeight(totalstatstr)
    gc:drawString(totalstatstr,scrwh-totstatwh-padding,padding,"top") -- Prints total questions in top right corver

    -- Prints app version at bottom of page
    gc:setFont("sansserif","r",7)
    gc:drawString("Version: "..appversion,0,scrht,"bottom")

    -- Prints output questions
    if checkmode == 1 or checkmode == 2 then
        gc:setFont("sansserif","b",fntio)
        local outpwh,outpht = gc:getStringWidth(outputtext),gc:getStringHeight(outputtext)
        gc:drawString(outputtext,scrwh/2-outpwh/2,2*padding+corstatht,"top") -- Center screen below statistics
    end

    -- Prints out flashing light
    if checkmode == 3 then

        -- Generates digit that shall be flashing
        local morseflashstr = string.sub(morseflash[random],morseflashdigit,morseflashdigit)

        -- Flash rate depends on timer setting. Dot is 1 time unit. Dash is 3 time units.
        if morseflashstr == "1" then -- White flash
            gc:setColorRGB(0xFFFFFF)
            gc:fillArc(scrwh/2-42*scrwh/318/2,2*padding+corstatht,42*scrwh/318,42*scrwh/318,0,360)
        else -- No flash
            gc:setColorRGB(0x666666)
            gc:drawArc(scrwh/2-42*scrwh/318/2,2*padding+corstatht,42*scrwh/318,42*scrwh/318,0,360)
        end

    end

    -- Prints input answer
    gc:setFont("sansserif","b",fntio)
    gc:setColorRGB(0xFFFFFF)
    local inpwh,inpht = gc:getStringWidth(inputtext),gc:getStringHeight(inputtext)
    gc:drawString(inputtext,scrwh/2-inpwh/2,3*padding+corstatht+inpht,"top") -- Center screen below output

    -- Prints error message if answer is incorrect
    if errorcode == true then
        gc:setColorRGB(errorcolor)
        gc:setFont("sansserif","r",fntlbl)
        local errortext = errormessage.." is incorrect"
        local errwh,errht = gc:getStringWidth(errortext),gc:getStringHeight(errortext)
        gc:drawString(errortext,scrwh/2-errwh/2,3*padding+corstatht+2*inpht,"top")
    end

end

-- Checks string size outside of paint function
function getstrsize(str,style,size,gc)

    gc:setFont("sansserif",style,size)
    local strwh,strht = gc:getStringWidth(str),gc:getStringHeight(str)
    return strwh,strht

end

-- Class defines option button properties and actions
optionbutton = class()

function optionbutton:init(id,lbl,xpos,ypos,wh,ht)

    self.id = id
    self.lbl = lbl
    self.x = xpos
    self.y = ypos
    self.wh = wh
    self.ht = ht
    self.selected = false

end

function optionbutton:paint(gc)

    -- Fetches string sizes of labels
    local btnlblwh,btnlblht = platform.withGC(getstrsize,self.lbl,"r",fntlbl)

    -- Properties for labels
    gc:setFont("sansserif","r",fntlbl)
    gc:setColorRGB(0xFFFFFF)
    gc:drawString(self.lbl,scrwh-self.x*scrwh/318,scrht-(self.ht+self.y+padding+3)*scrht/212,"top") -- Number three center label on icon, change value when needed

    -- Sets properties for "code to letter" radio button
    if checkmode == 1 and self.id == 1 then
        radiobuttonchecked = radiobuttonchecked:copy(self.wh*scrwh/318,self.ht*scrht/212)
        gc:drawImage(radiobuttonchecked,scrwh-(self.wh+self.x+padding)*scrwh/318,scrht-(self.ht+self.y+padding)*scrht/212)
        if optbtn_ctl_hover == true then
            radiobuttoncheckedgrey = radiobuttoncheckedgrey:copy(self.wh*scrwh/318,self.ht*scrht/212)
            gc:drawImage(radiobuttoncheckedgrey,scrwh-(self.wh+self.x+padding)*scrwh/318,scrht-(self.ht+self.y+padding)*scrht/212)
        end
    elseif self.id == 1 and checkmode ~= 1 then
        radiobuttonunchecked = radiobuttonunchecked:copy(self.wh*scrwh/318,self.ht*scrht/212)
        gc:drawImage(radiobuttonunchecked,scrwh-(self.wh+self.x+padding)*scrwh/318,scrht-(self.ht+self.y+padding)*scrht/212)
        if optbtn_ctl_hover == true then
            radiobuttonuncheckedgrey = radiobuttonuncheckedgrey:copy(self.wh*scrwh/318,self.ht*scrht/212)
            gc:drawImage(radiobuttonuncheckedgrey,scrwh-(self.wh+self.x+padding)*scrwh/318,scrht-(self.ht+self.y+padding)*scrht/212)
        end
    end

    -- Sets properties for "letter to code" radio button
    if checkmode == 2 and self.id == 2 then
        radiobuttonchecked = radiobuttonchecked:copy(self.wh*scrwh/318,self.ht*scrht/212)
        gc:drawImage(radiobuttonchecked,scrwh-(self.wh+self.x+padding)*scrwh/318,scrht-(self.ht+self.y+padding)*scrht/212)
        if optbtn_ltc_hover == true then
            radiobuttoncheckedgrey = radiobuttoncheckedgrey:copy(self.wh*scrwh/318,self.ht*scrht/212)
            gc:drawImage(radiobuttoncheckedgrey,scrwh-(self.wh+self.x+padding)*scrwh/318,scrht-(self.ht+self.y+padding)*scrht/212)
        end
    elseif self.id == 2 and checkmode ~= 2 then
        radiobuttonunchecked = radiobuttonunchecked:copy(self.wh*scrwh/318,self.ht*scrht/212)
        gc:drawImage(radiobuttonunchecked,scrwh-(self.wh+self.x+padding)*scrwh/318,scrht-(self.ht+self.y+padding)*scrht/212)
        if optbtn_ltc_hover == true then
            radiobuttonuncheckedgrey = radiobuttonuncheckedgrey:copy(self.wh*scrwh/318,self.ht*scrht/212)
            gc:drawImage(radiobuttonuncheckedgrey,scrwh-(self.wh+self.x+padding)*scrwh/318,scrht-(self.ht+self.y+padding)*scrht/212)
        end
    end

    -- Sets properties for "flash to letter" radio button
    if checkmode == 3 and self.id == 3 then
        radiobuttonchecked = radiobuttonchecked:copy(self.wh*scrwh/318,self.ht*scrht/212)
        gc:drawImage(radiobuttonchecked,scrwh-(self.wh+self.x+padding)*scrwh/318,scrht-(self.ht+self.y+padding)*scrht/212)
        if optbtn_ftl_hover == true then
            radiobuttoncheckedgrey = radiobuttoncheckedgrey:copy(self.wh*scrwh/318,self.ht*scrht/212)
            gc:drawImage(radiobuttoncheckedgrey,scrwh-(self.wh+self.x+padding)*scrwh/318,scrht-(self.ht+self.y+padding)*scrht/212)
        end
    elseif self.id == 3 and checkmode ~= 3 then
        radiobuttonunchecked = radiobuttonunchecked:copy(self.wh*scrwh/318,self.ht*scrht/212)
        gc:drawImage(radiobuttonunchecked,scrwh-(self.wh+self.x+padding)*scrwh/318,scrht-(self.ht+self.y+padding)*scrht/212)
        if optbtn_ftl_hover == true then
            radiobuttonuncheckedgrey = radiobuttonuncheckedgrey:copy(self.wh*scrwh/318,self.ht*scrht/212)
            gc:drawImage(radiobuttonuncheckedgrey,scrwh-(self.wh+self.x+padding)*scrwh/318,scrht-(self.ht+self.y+padding)*scrht/212)
        end
    end

end

function optionbutton:hover(mx,my)

    -- Returns true or false depending on mouse position. Within button areas function return true.
    return mx >= scrwh-(self.wh+self.x+padding)*scrwh/318 and mx <= scrwh-(self.wh+self.x+padding)*scrwh/318+self.wh*scrwh/318 and my >= scrht-(self.ht+self.y+padding)*scrht/212 and my <= scrht-(self.ht+self.y+padding)*scrht/212+self.ht*scrht/212

end

-- Class defines push buttons properties and actions
pushbutton = class()

function pushbutton:init(id,lbl,xpos,ypos,wh,ht)

    self.id = id
    self.lbl = lbl
    self.x = xpos
    self.y = ypos
    self.wh = wh
    self.ht = ht
    self.selected = false

end

function pushbutton:paint(gc)

    -- Check button will flash for 200 ms
    if entercounter < timer.getMilliSecCounter() then
        enterpress = false
    end

    -- Resets Esc key button press after 500 ms
    if esccounter < timer.getMilliSecCounter()  then
        escrst = 0
    end

    -- Botton coloring
    if btncheckclick == true or enterpress == true then -- Makes button blue on mouse click and enter key press
        buttonblue = buttonblue:copy(self.wh*scrwh/318,self.ht*scrht/212)
        gc:drawImage(buttonblue,scrwh-(self.wh+self.x+padding)*scrwh/318,scrht-(self.ht+self.y+padding)*scrht/212)
        local btnlblwh,btnlblht = platform.withGC(getstrsize,self.lbl,"b",fntbtn)
        gc:setFont("sansserif","b",fntbtn)
        gc:setColorRGB(0xFFFFFF)
        gc:drawString(self.lbl,scrwh-(self.x+padding+self.wh/2)*scrwh/318-btnlblwh/2,scrht-(self.y+padding+self.ht/2)*scrht/212-btnlblht/2,"top")
    else  -- Normal mode, white button with black text
        buttonwhite = buttonwhite:copy(self.wh*scrwh/318,self.ht*scrht/212)
        gc:drawImage(buttonwhite,scrwh-(self.wh+self.x+padding)*scrwh/318,scrht-(self.ht+self.y+padding)*scrht/212)
        local btnlblwh,btnlblht = platform.withGC(getstrsize,self.lbl,"r",fntbtn)
        gc:setFont("sansserif","r",fntbtn)
        gc:setColorRGB(0x000000)
        gc:drawString(self.lbl,scrwh-(self.x+padding+self.wh/2)*scrwh/318-btnlblwh/2,scrht-(self.y+padding+self.ht/2)*scrht/212-btnlblht/2,"top")
    end
    if btncheckhover == true and btncheckclick == false then -- Makes check button gray on mouse hover
        buttongreylight = buttongreylight:copy(self.wh*scrwh/318,self.ht*scrht/212)
        gc:drawImage(buttongreylight,scrwh-(self.wh+self.x+padding)*scrwh/318,scrht-(self.ht+self.y+padding)*scrht/212)
        local btnlblwh,btnlblht = platform.withGC(getstrsize,self.lbl,"b",fntbtn)
        gc:setFont("sansserif","b",fntbtn)
        gc:setColorRGB(0x000000)
        gc:drawString(self.lbl,scrwh-(self.x+padding+self.wh/2)*scrwh/318-btnlblwh/2,scrht-(self.y+padding+self.ht/2)*scrht/212-btnlblht/2,"top")
    end

    -- Makes button red on errors
    if errorcode == true then
        buttonred = buttonred:copy(self.wh*scrwh/318,self.ht*scrht/212)
        gc:drawImage(buttonred,scrwh-(self.wh+self.x+padding)*scrwh/318,scrht-(self.ht+self.y+padding)*scrht/212)
        local btnlblwh,btnlblht = platform.withGC(getstrsize,self.lbl,"b",fntbtn)
        gc:setFont("sansserif","b",fntbtn)
        gc:setColorRGB(0xFFFFFF)
        gc:drawString(self.lbl,scrwh-(self.x+padding+self.wh/2)*scrwh/318-btnlblwh/2,scrht-(self.y+padding+self.ht/2)*scrht/212-btnlblht/2,"top")
    end

end

function pushbutton:hover(mx,my)

    -- Returns true or false depending on mouse position. Within button areas function return true.
    return mx >= scrwh-(self.wh+self.x+padding)*scrwh/318 and mx <= scrwh-(self.wh+self.x+padding)*scrwh/318+self.wh*scrwh/318 and my >= scrht-(self.ht+self.y+padding)*scrht/212 and my <= scrht-(self.ht+self.y+padding)*scrht/212+self.ht*scrht/212

end

-- Tracks mouse movement
function on.mouseMove(mx,my)

    -- Sends command to make option button "code to letter" grey
    if optbtn_ctl:hover(mx,my) then
        optbtn_ctl_hover = true
    else
        optbtn_ctl_hover = false
    end

    -- Sends command to make option button "letter to code" grey
    if optbtn_ltc:hover(mx,my) then
        optbtn_ltc_hover = true
    else
        optbtn_ltc_hover = false
    end

    -- Sends command to make option button "flash to letter" grey
    if optbtn_ftl:hover(mx,my) then
        optbtn_ftl_hover = true
    else
        optbtn_ftl_hover = false
    end

    -- Sends command to make check button grey
    if btncheck:hover(mx,my) then
        btncheckhover = true
    else
        btncheckhover = false
    end

end

function on.mouseDown(mx,my)

    -- Sends command to use "code to letter" training mode
    if optbtn_ctl:hover(mx,my) then
        optbtn_ctl_click = true
        checkmodeswitch(1)
    end

    -- Sends command to use "letter to code" training mode
    if optbtn_ltc:hover(mx,my) then
        optbtn_ltc_click = true
        checkmodeswitch(2)
    end

    -- Sends command to use "flash to code" training mode
    if optbtn_ftl:hover(mx,my) then
        optbtn_ftl_click = true
        checkmodeswitch(3)
    end

    -- Check button, sends command to check input text on mouse click
    if btncheck:hover(mx,my) then
        btncheckclick = true
        if checkmode == 1 then
            check_ctl()
        elseif checkmode == 2 then
            check_ltc()
        elseif checkmode == 3 then
            check_ftl()
        end
    end

end

function on.mouseUp(mx,my)

    -- Sends command to make buttons white background when mouse button is released
    optbtn_ctl_click = false
    optbtn_ltc_click = false
    optbtn_ftl_click = false
    btncheckclick = false

end

-- Verifies answer in "code to letter" mode
function check_ctl()

    if inputtext == letter[random] then -- Correct answer, new question
        correctstat = correctstat+1
        totalstat = totalstat+1
        random = randomgen()
        inputtext = ""
        outputtext = morsecode[random]
    elseif inputtext == "" then -- Do nothing on empty answer
        errormessage = ""
        errorcode = false
    else -- Wrong answer
        errorcode = true
        errormessage = inputtext
        inputtext = ""
        totalstat = totalstat+1
    end

end

-- Verifies answer in "letter to code" mode
function check_ltc()

    -- Removes the last space in string
    inputtext = inputtext:usub(0,-2)

    if inputtext == morsecode[random] then -- Correct answer, new question
        correctstat = correctstat+1
        totalstat = totalstat+1
        random = randomgen()
        inputtext = ""
        outputtext = letter[random]
    elseif inputtext == "" then -- Do nothing on empty answer
        errormessage = ""
        errorcode = false
    else -- Wrong answer
        errorcode = true
        errormessage = inputtext
        inputtext = ""
        totalstat = totalstat+1
    end

end

-- Verifies answer in "flash to letter" mode
function check_ftl()

    if inputtext == letter[random] then -- Correct answer, new question
        correctstat = correctstat+1
        totalstat = totalstat+1
        random = randomgen()
        inputtext = ""
    elseif inputtext == "" then -- Do nothing on empty answer
        errormessage = ""
        errorcode = false
    else -- Wrong answer
        errorcode = true
        errormessage = inputtext
        inputtext = ""
        totalstat = totalstat+1
    end

end

-- Resets statistics
function reset()

    inputtext = ""
    correctstat = 0
    totalstat = 0
    errorcode = false

end