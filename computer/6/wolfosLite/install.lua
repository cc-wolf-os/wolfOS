local tos = [[WolfOS is not intended for use in any nuclear facility,on aircraft, or for automation]]
if not fs.exists("prime.lua") then
    local components = {
        "borderBox",
        "button",
        "centerLabel",
        "checkSelectionBox",
        "drawImage",
        "drawText",
        "horizontalLine",
        "inputBox",
        "interval",
        "keyAction",
        "keyCombo",
        "label",
        "progressBar",
        "scrollBox",
        "selectionBox",
        "textBox",
        "timeout",
    }
    local function get(b)local c,d=http.checkURL(b)if not c then printError(d or"Invalid URL.")return end;write("Connecting to "..b.."... ")local e=http.get(b,nil,true)if not e then print("Failed.")return nil end;print("Success.")local f=e.readAll()e.close()return f or""end
    local res = get("https://raw.githubusercontent.com/MCJack123/PrimeUI/master/util.lua")
    if not res then return end
    res = res:gsub('-- DO NOT COPY THIS LINE\nreturn PrimeUI',"")
    local file, err = fs.open("/prime.lua", "wb")
    if not file then
        printError("Cannot save file: " .. err)
        return
    end
    file.write(res.."\n")
    for i,c in ipairs(components) do
        local res = get("https://raw.githubusercontent.com/MCJack123/PrimeUI/master/"..c..".lua")
        if not res then return end
        res = res:gsub('local PrimeUI = require "util"',""):gsub('local expect = require "cc.expect".expect',"")
        file.write("--component "..tostring(i)..", "..c.."\n"..res.."\n")
    end
    


    file.write('return PrimeUI')
    file.close()
end
local PrimeUI = require ".prime"
PrimeUI.clear()
PrimeUI.label(term.current(), 3, 2, "Installing WolfOS")
PrimeUI.horizontalLine(term.current(), 3, 3, #("Installing WolfOS") + 2)
PrimeUI.borderBox(term.current(), 4, 6, 40, 10)
local scroller = PrimeUI.scrollBox(term.current(), 4, 6, 40, 10, 9000, true, true)
PrimeUI.drawText(scroller, tos, true)
PrimeUI.button(term.current(), 3, 18, "Next", "done")
--PrimeUI.keyAction(keys.enter, "done")
PrimeUI.run()

PrimeUI.clear()
PrimeUI.label(term.current(), 3, 2, "Installing WolfOS")
PrimeUI.horizontalLine(term.current(), 3, 3, #("Installing WolfOS") + 2)
PrimeUI.borderBox(term.current(), 4, 6, 40, 10)
local scroller = PrimeUI.scrollBox(term.current(), 4, 6, 40, 10, 9000, true, true)
local entries = {
    ["WolfOS-Desktop"] = false,
    ["WolfOS-Core"] = "R",
    ["WolfOS-Clasic"] = false,
    ["Item 5"] = false
}
PrimeUI.checkSelectionBox(scroller, 1, 1, 40, 10, entries)
PrimeUI.button(term.current(), 3, 18, "Next", "done")
--PrimeUI.keyAction(keys.enter, "done")
PrimeUI.run()

if entries["WolfOS-Clasic"] then
    PrimeUI.clear()
    PrimeUI.label(term.current(), 3, 2, "Installing WolfOS")
    PrimeUI.horizontalLine(term.current(), 3, 3, #("Installing WolfOS") + 2)
    PrimeUI.borderBox(term.current(), 4, 6, 40, 10)
    local scroller = PrimeUI.scrollBox(term.current(), 4, 6, 40, 10, 9000, true, true)
    PrimeUI.drawText(scroller, [[Are you shure that you want to install WolfOS Clasic?
    WolfOS Clasic is very buggy.]], true)
    PrimeUI.button(term.current(), 3, 18, "Install", "done")
    PrimeUI.button(term.current(), 3, 18, "Nevermind", "done")
    --PrimeUI.keyAction(keys.enter, "done")
    local I = PrimeUI.run()
    if I == "Nevermind" then
        return 0
    end
    --TODO run wolfos clasic installer

    return 1
end