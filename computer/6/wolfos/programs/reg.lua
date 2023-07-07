local basalt = require("/wolfos.libs.basalt")
basalt.logging = true

local mainFrame = basalt.createFrame()
if not mainFrame then
    error("major problem",5)
end
local treeView = mainFrame:addTreeview():setSize("{parent.w/2}","{parent.h}"):setForeground(colors.orange):setBackground(colors.black)
local rootNode = treeView:getRoot()
rootNode:setText("reistry")
local MainNode = rootNode:addChild("registry"):setExpanded(true)


MainNode:setExpandable(true)

local childNode2 = rootNode:addChild("Child Node 2"):setExpanded(true)
local bootNd = MainNode:addChild("boot"):setExpanded(true)
childNode2:addChild("weeewee")
local pretty = require "cc.pretty"
basalt.log(pretty.pretty(MainNode.getChildren()))


basalt.autoUpdate()