local permLevels = {
    ucv = 1,
    ace = 2,
    AdmSYS = 4,
    System = 8
}
local level = 8
local log4l = require("/wolfos.libs.log4l")
local propane = require("/wolfos.libs.propaneDB")("db")
local db = propane.load("/wolfos/perms")
local sha1 = require("/wolfos.libs.otp")("sha1")
local logger = log4l.new("/wolfos/logs/perms", 0 --[[Time shift (here, +2 utc)]], nil)
return function(serviceLogger)
    serviceLogger.info("wolfos.services.permSystem started")
    serviceLogger.info("[permSystem] current level: "..tostring(level))
    local perm = {}
    function perm.getCurentLevel()
        return level
    end
    function perm.upgrade(creds)
        local atmpt = db:getValue("users",creds.user,false)
        if atmpt then
            if atmpt.psw == creds.psw then
                if bit.band(atmpt.permFlag,level) then
                    local oldlevel = level
                    level =atmpt.permFlag
                    logger.info("perms.upgrade user upgaded to "..creds.user.." with level "..tostring(level).." from "..tostring(oldlevel))
                else
                    logger.warn("failed perm.upgrade atempt using: "..creds.user..", incompatable users")
                end
                
            else
                logger.warn("failed perm.upgrade atempt using: "..creds.user..", incorect pasword")
            end
        else
            logger.error("failed perm.upgrade atempt using: "..creds.user..", user non existant")
        end
    end
    function perm.makeCreds(username,pasword)
        return {
            user = username,
            psw = sha1.sha1(pasword)
        }
    end



    
    _G.perm = perm
    return function()
        serviceLogger.info("wolfos.services.permSystem stopping")
        logger.close()
        _G.perm = nil
    end
end