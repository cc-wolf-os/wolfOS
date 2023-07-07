local IO_OPEN_OG = io.open

return function(serviceLogger)
    serviceLogger.info("wolfos.services.fileSystem started")




    return function()
        serviceLogger.info("wolfos.services.fileSystem stopping")
        _G.io.open = IO_OPEN_OG
    end
end