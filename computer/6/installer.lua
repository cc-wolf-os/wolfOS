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


-- Registry/ DB setup
local propane = require("/wolfos.libs.propaneDB")("db")
logger.info("making registry")
local reg = propane.new("/wolfos/registry")
        :newTable("boot")
        :setValue("boot","debugInfoW",25)
        :setValue("boot","debugInfoH",15)
        :setValue("boot","debugInfoEnabled",true)
        :setValue("boot","logo","logo")
        :save()

logger.info("making program List")
local progs = propane.new("/wolfos/programList")
        :newTable("system")
        :setValue("system","ReggEdit",{path="/wolfos/programs/reg.lua",type="program",args="",icon="\xA7"})
        :setValue("system","launchpad",{type="SYSINTERNL",args="",icon="\x93"})
        :setValue("system","shell",{path="shell",type="program",args="",icon="\x99"})
        :newTable("craftOS")
        :save()



local file = fs.open("/wolfos/baseprogs.json", 'r')
local progsLs = textutils.unserialiseJSON(file.readAll())
for index, value in ipairs(progsLs) do
    progs:setValue("craftOS",value,{path=value,type="program",args="",icon=string.sub(value, 1, 1)})
end

progs:save()

logger.info("making filesystem perms db")
local FS = propane.new("/wolfos/FS")
        :newTable("files")
        :setValue('files',"/wolfos/programList",{permFlag=12})
        :setValue('files',"/wolfos/registry",{permFlag=12})
        :setValue('files',"/wolfos/FS",{permFlag=12})
        :newTable("folders")
        :setValue('folders',"/wolfos/libs",{permFlag=12})
        :setValue('folders',"/wolfos/programs",{permFlag=12})
        :setValue('folders',"/wolfos/assets",{permFlag=10})
        :setValue('folders',"/wolfos/services",{permFlag=8})
        :save()


logger.close()