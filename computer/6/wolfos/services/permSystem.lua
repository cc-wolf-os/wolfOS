local permLevels = {
    ucv = 1,
    ace = 2,
    AdmSYS = 4,
    System = 8
}
local level = 8

return function(serviceLogger)
    serviceLogger.info("wolfos.services.permSystem started")
    serviceLogger.info("[permSystem] current level: "..tostring(level))
    local perm = {}
    function perm.getCurentLevel()
        return level
    end
end