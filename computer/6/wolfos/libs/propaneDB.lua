--
-- Propane DB
local ver = "V-0.0.1"
--
--
local expect = require "cc.expect"




local db = {
    ver = ver
}


function newDB(dbi,filename)
    
    DB = {
        db = dbi,
        filename = filename  
    }
    function DB:save()
        local file = fs.open(self.filename, 'w')
        self.db.META.savedAt = math.floor(os.epoch("utc") / 1000)
        file.write(
            textutils.serializeJSON(self.db)
        )
        file.close()
        return self
    end

    function DB:newTable(name)
        if self.db[name] then
            return self
        end
        self.db[name] = {}

        return self
    end
    function DB:setValue(table,name,value)
        self.db[table][name] = value

        return self
    end
    function DB:getValue(table,name,altern)
        altern = altern or ""
        return self.db[table][name]
    end

    return DB
end

function db.load(filename)
    local file = fs.open(filename, 'r')
    return newDB(textutils.unserialiseJSON(file.readAll()),filename)
end
function db.new(filename)
    if fs.exists(filename) then
        return db.load(filename)
    end
    return newDB({
        META = {
            createdUsing = ver,
            createdAt = math.floor(os.epoch("utc") / 1000),
            savedAt = 0
        }
    },filename)
end



return function(module)
    expect.expect(1,module,"string")
    if module then
        if module == "ver" then
            return {ver=ver}
        elseif module == "db" then
            return db
        else
            error("unknown: "..module,1)
        end
    end
end