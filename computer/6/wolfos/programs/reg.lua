local basalt = require("/wolfos.libs.basalt")
local propane = require("/wolfos.libs.propaneDB")("db")
local db = propane.load("/wolfos/registry")
basalt.logging = true

local mainFrame = basalt.createFrame()
if not mainFrame then
    error("major problem",5)
end
local treeView = mainFrame:addTreeview():setSize("{parent.w/2}","{parent.h}"):setForeground(colors.orange):setBackground(colors.black)
local rootNode = treeView:getRoot()

local MainNode = rootNode:addChild("registry"):setExpanded(true)
for name, table in pairs(db.db) do
    local ctgryND = MainNode:addChild(name)
    for key, value in pairs(table) do
        ctgryND:addChild(key..": "..tostring(value))
    end
end


local pretty = require "cc.pretty"
basalt.log(pretty.pretty(MainNode.getChildren()))


basalt.autoUpdate()