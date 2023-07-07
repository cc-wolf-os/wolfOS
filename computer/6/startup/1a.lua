term.clear()
term.setCursorPos(1, 1)
shell.setDir("/")
local bigfont = require("/wolfos.libs.bigfont")
bigfont.bigPrint("Wolf OS")
local tw,th = term.getSize()
local basalt = {}
local guih = {}
local nft = require "cc.image.nft"
local propane = require("/wolfos.libs.propaneDB")("db")
local registry = propane.load("/wolfos/registry")
local log4l = require("/wolfos.libs.log4l")
local window_manager = {}
local windowman = {}
local services = {}



string.lpad = function(str, len, char)

    if char == nil then char = ' ' end
    return str .. string.rep(char, len - #str)
end
string.rpad = function(str, len, char)

    if char == nil then char = ' ' end
    return string.rep(char, len - #str) .. str
end


local debugWindow = window.create(term.current(), 2, 1, registry:getValue("boot","debugInfoW"), registry:getValue("boot","debugInfoH"))
local logger = log4l.new("/wolfos/logs/boot", 7 --[[Time shift (here, +2 utc)]], debugWindow)
local serviceLogger = log4l.new("/wolfos/logs/system/services", 7 --[[Time shift (here, +2 utc)]], nil)
debugWindow.h = registry:getValue("boot","debugInfoH")

debugWindow.setVisible(registry:getValue("boot","debugInfoEnabled"))

local tasks = {
    function() logger.info("loading Basalt... \x7F")
        if not fs.exists("/wolfos/libs/basalt.lua") then
            logger.warn("Basalt is missing,installing...")
            shell.run("wget run https://basalt.madefor.cc/install.lua packed /wolfos/libs/basalt.lua")
            logger.info("installed Basalt...")
        end
        
        
        logger.info("loaded Basalt... \x2F")
        basalt = require("/wolfos.libs.basalt")
    end,
    function() logger.info("loading xml parser... \x7F")
        if not fs.exists("/wolfos/libs/xml.lua") then
            logger.warn("xml parser is missing,installing...")
            shell.run("wget https://raw.githubusercontent.com/Pyroxenium/Basalt/master/Basalt/libraries/xmlParser.lua /wolfos/libs/xml.lua")
            logger.info("installed xml parser...")
        end
        logger.info("loading xml parser... \x2F")
    end,
    function() logger.info("loading archive... \x7F")
        if not fs.exists("/wolfos/libs/LibDeflate.lua") then
            logger.warn("LibDeflate is missing,installing...")
            shell.run("wget https://raw.githubusercontent.com/cc-wolf-os/CC-Archive/master/LibDeflate.lua /wolfos/libs/LibDeflate.lua")
            logger.info("installed LibDeflate...")
        end
        if not fs.exists("/wolfos/libs/archive.lua") then
            logger.warn("archive lib is missing,installing...")
            shell.run("wget https://raw.githubusercontent.com/cc-wolf-os/CC-Archive/master/archive.lua /wolfos/libs/archive.lua")
            logger.info("installed archive lib...")
        end
        logger.info("loading archive... \x2F")
    end,
    function() 
        windowman = require("/wolfos.libs.windowMan")
        logger.info("window manager loaded... \x2F")
    end,
    function() 
        window_manager = require("/wolfos.libs.window")
        logger.info("libs loaded... \x2F")
    end,
    function() 
        logger.info("loading pallete... \x7F")
        local GNOME = {
            ["black"]     = 0x111111,
            ["blue"]      = 0x2A7BDE,
            ["brown"]     = 0xA2734C,
            ["cyan"]      = 0x2AA1B3,
            ["gray"]      = 0x5E5C64,
            ["green"]     = 0x26A269,
            ["lightBlue"] = 0x33C7DE,
            ["lightGray"] = 0xD0CFCC,
            ["lime"]      = 0x33D17A,
            ["magenta"]   = 0xC061CB,
            ["orange"]    = 0xD06018,
            ["pink"]      = 0xF66151,
            ["purple"]    = 0xA347BA,
            ["red"]       = 0xC01C28,
            ["white"]     = 0xFFFFFF,
            ["yellow"]    = 0xF3F03E
        }
        --local colorI = log4l.new("/wolfos/logs", 7 --[[Time shift (here, +2 utc)]], nil)
        for color, code in pairs(GNOME) do
            term.setPaletteColor(colors[color], code)
            --colorI.info("#"..tostring(string.sub(string.format("%x", code),1,-1)).."  "..color)
        end
        --colorI.close()
        logger.info("loading pallete... \x2F")
    end,
    function()
        logger.info("starting services...")
        local serv = {
            "permSystem",
            "fileSystem"
        }
        for index, value in ipairs(serv) do
            logger.info("starting service "..value.."...")
            services[value] = require("/wolfos.services."..value)(serviceLogger)
        end
    end
}





local function logo()
    --local image = assert(nft.load("/wolfos/assets/wolf.nft"))
    local image = assert(nft.parse(require("/wolfos.assets.specs").logoT))
    local cx,cy = term.getCursorPos()
    local tw,th = term.getSize()
    nft.draw(image, (tw/2)-5,(th/2)-4)
    term.setCursorPos(cx,cy)
end


sleep(0.5)

term.clear()
term.setCursorPos(1, 1)
logo()
term.setCursorPos(1, th-2)
term.blit("\x9C","0","f")
for c=1,tw-2,1 do
    term.blit("\x8C","0","f")
end
term.blit("\x93","f","0")
print()
term.blit("\x95","0","f")

for c=1,tw-2,1 do
    term.blit("\x7f","1","f")
end
term.blit("\x95","f","0")
print()
term.blit("\x8D","0","f")
for c=1,tw-2,1 do
    term.blit("\x8C","0","f")
end
term.blit("\x8E","0","f")



term.setCursorPos(2, th-1)
local timeP = 50/((tw-2)/4)

local taskA = math.floor((tw-2)/#tasks)
local taskRM = ((tw-2) - (taskA*#tasks))
logger.info("taskRM>"..tostring(taskRM))
logger.info("taskW>"..tostring(tw-2))
logger.info("taskA>"..tostring(taskA))
logger.info("tasks len>"..tostring(#tasks))
logger.info("task Area used>"..tostring(taskA*#tasks).."/"..tostring(tw-2))

local timeA = tw-2
local timeP = 3/(timeA)
for c=1,#tasks,1 do
    logger.info("Task "..tostring(c)..">")
    tasks[c]()
    term.setCursorPos(2+(taskA*(c-1)), th-1)
    term.blit(string.lpad("",taskA,"\x7f"),string.lpad("",taskA,"e"),string.lpad("",taskA,"1"))
    sleep(0.05)
end

term.blit(string.lpad("",taskRM,"\x7f"),string.lpad("",taskRM,"e"),string.lpad("",taskRM,"e"))


term.setCursorPos(2, th-1)
for c=1,timeA,1 do
    term.blit("\x7f","1","1")
    sleep(timeP)
end

--_G.window_manager =window_manager
_G.registry = registry
_G.windowMan = windowman
_G.WM = windowman.MakeWM()
_G.debugWindow= debugWindow


debugWindow.setVisible(false)
term.clear()
term.setCursorPos(1, 1)

local shld = require("/wolfos.libs.shield")
local shield = shld.shield
local ok,err = pcall(function()shell.run("test.lua")end)
local function logoF()
    --local image = assert(nft.load("/wolfos/assets/wolf.nft"))
    local image = assert(nft.parse(require("/wolfos.assets.specs").logoF))
    local cx,cy = term.getCursorPos()
    local tw,th = term.getSize()
    nft.draw(image, (tw/2)-5,(th/2)-4)
    term.setCursorPos(cx,cy)
end
local function logoP()
    --local image = assert(nft.load("/wolfos/assets/wolf.nft"))
    local image = assert(nft.parse(require("/wolfos.assets.specs").logoP))
    local cx,cy = term.getCursorPos()
    local tw,th = term.getSize()
    nft.draw(image, (tw/2)-5,(th/2)-4)
    term.setCursorPos(cx,cy)
end

if not ok then
    shield(function()
            term.clear()
            term.setCursorPos(1, 1)
            debugWindow.reposition(1,1,30,30)
            --debugWindow.clear()
            debugWindow.setVisible(true)
            logger.info("oh, snap")
            logger.fatal("wolf os has crashed")
            logger.error(tostring(err))
            logoF()


            read()
        end
    )
end
shield(function()
        logoP()
        sleep(2)
        logger.close()
        serviceLogger.close()
        --os.reboot()
    end
)