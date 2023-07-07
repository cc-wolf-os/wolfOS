local basalt = require("/wolfos.libs.basalt")
local propane = require("/wolfos.libs.propaneDB")("db")
local progs = propane.load("/wolfos/programList")
local log4l = require("/wolfos.libs.log4l")
local pretty = require "cc.pretty"
local logger = log4l.new("/wolfos/logs/desktop", 7 --[[Time shift (here, +2 utc)]], nil)

local mainFrame = basalt.createFrame()
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

local prog = innr:addProgram():setSize(tw-3,th-3):setPosition(2, 2)
local pwrBtn = sidebar
        :addButton()
        :setText("\x99")
        :setSize(1,1)
        :setPosition(1, th-2)
        :setForeground(colors.red)

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

local function WM_Task()
    logger.info("WM_start")
    
    
    local W = nil
    while true do
        if #WM.WindowsWaitingForAdding > 0 then
            W = WM.WindowsWaitingForAdding[1]
            if W then
                logger.info(pretty.render(pretty.pretty(W)))
                logger.info(tostring(W.id))
                local w = mainFrame:addFrame():setPosition(2, 1):setSize(tw-2, th-1):hide()
                local lable = w:addLabel()
                        :setText(W.id)
                        :setForeground(colors.white)
                        :setPosition(2,1)
                menubar:addItem(W.about.icon:gsub("%\xC2", ""),colors.gray,colors.lightGray)
                local bi = menubar:getItemCount()
                menubar:selectItem(bi)
                local prg = w:addProgram():setSize(tw-3,th-3):setPosition(2, 2)
                local wndo = windowMan.Window(W.about,w,bi)
                prg:execute(RunProgram(W.about.path))
                WM:ready(W.id,wndo,1)
                --W[]
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