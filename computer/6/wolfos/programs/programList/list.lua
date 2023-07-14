local basalt = require("/wolfos.libs.basalt")
basalt.logging = true
local propane = require("/wolfos.libs.propaneDB")("db")
local progs = propane.load("/wolfos/programList")

local mainFrame = basalt.createFrame()
if not mainFrame then
    error("major problem",5)
end

local Label = mainFrame:addLabel():setText("none"):setFontSize(2):setPosition("{(parent.w/2)+2}",1):setSize("{(parent.w/2)-3}",4):setTextAlign("center")
local launch = mainFrame:addButton():setText("launch"):setPosition("{(parent.w/2)+2}",4):setSize("{(parent.w/2)-3}",3):onClick(function(self,event,button,x,y)
    if(event=="mouse_click")and(button==1)then
      basalt.debug("Left mousebutton got clicked!")
    end
  end)

local treeView = mainFrame:addTreeview():setSize("{parent.w/2}","{parent.h}"):setForeground(colors.orange):setBackground(colors.black)
local rootNode = treeView:getRoot()
local progLst = {}

local progs = propane.load("/wolfos/programList")
for key, value in pairs(progs.db) do
    if key ~= "META" then  
        progLst[key] = rootNode:addChild(key)
        if key == "craftOS" then
            progLst[key]:setExpanded(false)
        else
            progLst[key]:setExpanded(true)
        end
        for Key, Value in pairs(value) do
            if Value.type ~= "SYSINTERNL" then
                local tmpNode = progLst[key]:addChild(Value.icon:gsub("%\xC2", "").." "..Key)
                tmpNode:onSelect(function(self)
                    basalt.log(Key)
                    Label:setText((Value.icon:gsub("%\xC2", "").." "..Key))
                    launch:remove()
                    launch = mainFrame:addButton():setText("launch"):setPosition("{(parent.w/2)+2}",4):setSize("{(parent.w/2)-3}",3):onClick(function(self,event,button,x,y)
                        if(event=="mouse_click")and(button==1)then
                            WM:new(Key,Value)
                        end
                      end)
    
                end) 
            end
        end
    end
end



basalt.autoUpdate()