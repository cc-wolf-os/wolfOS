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




local basalt = require("/wolfos.libs.basalt")
local propane = require("/wolfos.libs.propaneDB")("db")
local progs = propane.load("/wolfos/programList")
local log4l = require("/wolfos.libs.log4l")
local pretty = require "cc.pretty"
local logger = log4l.new("/wolfos/logs/desktop", 7 --[[Time shift (here, +2 utc)]], nil)
local regdb = propane.load("/wolfos/registry")


local mainFrame = basalt.createFrame()

local gNOME = {}
for color, code in pairs(GNOME) do
    term.setPaletteColor(colors[color], code)
    gNOME[colors[color]] = code
    mainFrame:setPalette(color,code)
end

--mainFrame:setPalette(gNOME)


local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

if not mainFrame then
    logger.fatal("major problem")
    error("major")
end

local tw,th = term.getSize()
local innr = mainFrame:addFrame():setPosition(2, 1):setSize(tw-2, th-1)
local popupAlert = mainFrame:addFrame()
        :setSize(20, 12)
        :setPosition(35, 5)
        :setShadow(colors.black)
        :setBorder(colors.lightGray, "left", "right", "bottom"):hide()
mainFrame:setImportant(popupAlert)
popupAlert:addLabel()
        :setText("alert")
        :setSize("{parent.w}", 1)
        :setPosition(1, 1)
        :setForeground(colors.white)
popupAlert:addButton()
    :setSize(1, 1)
    :setText("X")
    :setForeground(colors.red)
    :setPosition("{parent.w-1}", 1)
    :onClick(function(self)
        logger.info("CLOSE")
        self:remove()
    end)
WM:new("LaunchPad",progs:getValue("system","launchpad")):ready("lp",windowMan.Window(progs:getValue("system","launchpad"),innr,1),1)
logger.info("launchpad load")

local sidebar = mainFrame:addFrame():setPosition(1, 1):setSize(1, th-1)
local sidebarR = mainFrame:addFrame():setPosition("{parent.w-1}", 1):setSize(1, th-1)

local prog = innr:addProgram():setSize(tw-2,th-2):setPosition(1, 2)
local pwrBtn = sidebar
        :addButton()
        :setText("\x99")
        :setSize(1,1)
        :setPosition(1, th-2)
        :setForeground(colors.red)
        :onClick(function(self)
            error("quit",0)
        end)

local function customProgram()
    shell.run("/wolfos/programs/programList/list.lua")
end
local function RunProgram(program,args)
    return function()
        shell.run(program,args)
    end
end

local menubar = mainFrame:addMenubar():setScrollable():setSelectionColor(colors.gray,colors.orange) -- we create a menubar in our main frame.
    :setSize(tw,1)
    :setForeground(colors.blue)
    
    :setPosition(1, th)
    :addItem("\x93\x94 ",colors.gray,colors.lightGray)
    :setSpace(0)
    --:onChange(function(self, val)
    --    logger.info(val)
    --    logger.info(pretty.pretty(self:getItemIndex())..tostring(self:getItemIndex()),"SPAM")
    --    WM:sel(self:getItemIndex())
    --    logger.info(tostring(menubar:getItemIndex()).." "..val) -- here we open the sub frame based on the table index
    --end)
    :onSelect(function (self,event,item)
        logger.info(pretty.render(pretty.pretty(self:getItemIndex())..tostring(self:getItemIndex())))
        WM:sel(self:getItemIndex())
        logger.info(tostring(self:getItemIndex()).." "..pretty.render(pretty.pretty(item)).." "..pretty.render(pretty.pretty(event))) -- here we open the sub frame based on the table index
    end)

local function launch_Window(W)
    local Q= false
    logger.info(pretty.render(pretty.pretty(W)))
    logger.info(tostring(W.id))
    local wnd = mainFrame:addFrame():setPosition(2, 1):setSize(tw-2, th-1):hide()
    
    local lable = wnd:addLabel()
            :setText(W.id)
            :setForeground(colors.white)
            :setPosition(2,1)
    menubar:addItem(W.about.icon:gsub("%\xC2", ""),colors.gray,colors.lightGray)
    local bi = menubar:getItemCount()
    local prg = wnd:addProgram():setSize(tw-2,th-2):setPosition(1, 2)
    local wndo = windowMan.Window(W.about,wnd,bi)
    prg:execute(RunProgram(W.about.path))
    local WID = tostring(uuid())
    logger.info(type(W.id.." "..WID))
    if regdb:getValue("debug","showWIDs") then
        lable:setText(tostring(W.id.." "..WID))
    end

    local function quit(self)
        if not Q then
            --Q = true
            --prg:stop()
            logger.info("CLOSE "..WID)
            --self:getParent():remove()
            menubar:removeItem(menubar:getItemIndex())
            --w:remove()
            menubar:selectItem(1)
            --wnd:hide()
            WM:sel(1)
            WM:remove(W.id..WID)
            
        end
    end
    --prg:onDone(quit)
    wnd:addButton()
        :setSize(1, 1)
        :setText("X")
        :setForeground(colors.red)
        :setPosition("{parent.w-1}", 1)
        :onClick(quit)

    WM:ready(W.id..WID,wndo,1)
    --W[]
end

local function WM_Task()
    logger.info("WM_start")
    
    
    local W = nil
    while true do
        if #WM.WindowsWaitingForAdding > 0 then
            W = WM.WindowsWaitingForAdding[1]
            if W then
                launch_Window(W)
            else
                table.remove(WM.WindowsWaitingForAdding,1)
            end
        else
            sleep(0.1)
        end
        
    end
end
local WM_Tread = mainFrame:addThread()

--prog:execute("/rom/programs/shell.lua")
--prog:execute("shell")
prog:execute(customProgram)
--parallel.waitForAll(function() window_manager.wm:run() end,basalt.autoUpdate)
WM:new("shell",progs:getValue("system","shell"))
WM:new("ReggEdit",progs:getValue("system","ReggEdit"))
WM_Tread:start(WM_Task)
menubar:selectItem(1)

basalt.autoUpdate()