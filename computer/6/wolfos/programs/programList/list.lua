local basalt = require("/wolfos.libs.basalt")
basalt.logging = true
local propane = require("/wolfos.libs.propaneDB")("db")

local mainFrame = basalt.createFrame()
if not mainFrame then
    error("major problem",5)
end
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
    
                end) 
            end
        end
    end
end

basalt.autoUpdate()