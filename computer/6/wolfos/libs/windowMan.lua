

local expect = require "cc.expect"



local function MakeWM()
    local wm = {
        activeWindows = {},
        WindowsWaitingForAdding = {},
    }
    function wm:remove(id)
        expect.expect(1,id,"string")
    end
    function wm:ready(id,window,idx)
        table.remove(self.WindowsWaitingForAdding,idx)
        
        
        self.activeWindows[id] = window
        return self
    end
    
    function wm:new(id,about)
        expect.expect(1,id,"string")
        self.WindowsWaitingForAdding[#self.WindowsWaitingForAdding+1] = {about=about,id=id}
        return self
    end
    function wm:sel(id)
        for key, value in pairs(self.activeWindows) do
            value:sel(id)
        end
        
    end

    
    return wm
end

local function Window(about,frame,index)
    local window = {
        about= about,
        frame= frame,
        index= index
    }
    function window:sel(i)
        if i == self.index then
            self.frame:show()
        else
            self.frame:hide()
        end
    end

    return window
end

return {MakeWM=MakeWM,Window=Window}