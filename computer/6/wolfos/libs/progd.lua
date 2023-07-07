local propane = require("/wolfos.libs.propaneDB")("db")
local progd = {}
function progd.load(cat)
    if cat == "system" then
        error("can not add arbitrary programs to system program table",3)
    elseif cat == "craftOS" then
        error("can not add arbitrary programs to craftOS program table",3)
    end
    local PDBW = {
        db =propane.load("/wolfos/programList"),
        cat = cat
    }
    function PDBW:addProgram(pname,path,icon,args)
        
    end


    return PDBW
end


return progd