fs.makeDir("/wolfos")
fs.makeDir("/wolfos/libs")
fs.makeDir("/wolfos/assets")
fs.makeDir("/wolfos/programs")
fs.makeDir("/wolfos/logs")
fs.makeDir("/wolfos/logs/install")

fs.makeDir("/wolfos/programs/programList")
if not fs.exists("/wolfos/libs/log4l.lua") then
        shell.run("wget https://gist.githubusercontent.com/1Turtle/1ca7ffdac7974498b3a2c89f9dad5521/raw/log4l.lua /wolfos/libs/log4l.lua")
end
local log4l = require("/wolfos.libs.log4l")
local logger = log4l.new("/wolfos/logs/install", 0 --[[Time shift (here, +2 utc)]], term.current())
logger.info("wolfos log4l install complete")
if not fs.exists("/wolfos/libs/otp.lua") then
        logger.info("installing otp")
        shell.run("wget https://raw.githubusercontent.com/badgeminer2dev/cc-lock/main/cc-lock/otp.lua /wolfos/libs/otp.lua")
        logger.info("installing otp complete")
end



local github_api = http.get("https://api.github.com/repos/cc-wolf-os/wolfOS/git/trees/main?recursive=1")
local list = textutils.unserialiseJSON(github_api.readAll())
local ls = {}
local len = 0
github_api.close()
for k,v in pairs(list.tree) do
    if v.type == "blob" and v.path:lower():find("computer/6/") and #(v.path:gsub("computer/6/","")) then
        ls["https://raw.githubusercontent.com/cc-wolf-os/wolfOS/main/"..v.path] = v.path:gsub("computer/6/","")
        len = len + 1
    end
end
local percent = 100/len
local finished = 0
logger.info("downloading "..tostring(len).." files")
local dbgmode = not settings.get("wolfosDebugInstaller",false)
for k,v in pairs(ls) do
    local web = http.get(k)
    if dbgmode then
        local file = fs.open("/"..v,"w")
        file.write(web.readAll())
        file.close()
    end
    
    web.close()
    finished = finished + 1
    logger.info(tostring(math.ceil(finished*percent)).."%%".."  "..tostring("downloading "..v))
end




-- Registry/ DB setup
local propane = require("/wolfos.libs.propaneDB")("db")
logger.info("making registry")
local reg = propane.new("/wolfos/registry")
        :newTable("boot")
        :setValue("boot","debugInfoW",25)
        :setValue("boot","debugInfoH",15)
        :setValue("boot","debugInfoEnabled",true)
        :setValue("boot","logo","logo")
        :newTable("debug")
        :setValue("debug","showWIDs",true)
        :save()

logger.info("making program List")
local progs = propane.new("/wolfos/programList")
        :newTable("system")
        :setValue("system","ReggEdit",{path="/wolfos/programs/reg.lua",type="program",args="",icon="\xA7"})
        :setValue("system","launchpad",{type="SYSINTERNL",args="",icon="\x93"})
        :setValue("system","shell",{path="shell",type="program",args="",icon="\x99"})
        :newTable("custom")
        :newTable("craftOS")
        :save()



local file = fs.open("/wolfos/baseprogs.json", 'r')
local progsLs = textutils.unserialiseJSON(file.readAll())
for index, value in ipairs(progsLs) do
    progs:setValue("craftOS",value,{path=value,type="program",args="",icon=string.sub(value, 1, 1)})
end

progs:save()


local sha1 = require("/wolfos.libs.otp")("sha1")
local util = require("/wolfos.libs.otp")("util")
logger.info("making perms db")

local adminpsw = ""
local adminPswConf = "e"
while adminpsw ~= adminPswConf do
        print("please enter a admin pasword,")
        print("you CAN NOT change this later")
        adminpsw = read("*") 
        print("and confirm")
        adminPswConf = read("*") 
end

local prms = propane.new("/wolfos/perms")
        :newTable("files")
        :setValue('files',"/wolfos/programList",{permFlag=12})
        :setValue('files',"/wolfos/registry",{permFlag=12})
        :setValue('files',"/wolfos/FS",{permFlag=12})
        :newTable("folders")
        :setValue('folders',"/wolfos/libs",{permFlag=12})
        :setValue('folders',"/wolfos/programs",{permFlag=12})
        :setValue('folders',"/wolfos/assets",{permFlag=10})
        :setValue('folders',"/wolfos/services",{permFlag=8})
        :newTable("users")
        :setValue("users","admin",{permFlag=7,psw=sha1.sha1(adminpsw)})
        :setValue("users","system",{permFlag=15,psw=sha1.sha1("wolfos_system_perms15")})
        :save()





logger.close()