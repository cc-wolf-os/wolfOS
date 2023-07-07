--- log4l.lua
-- A small enhanced logging module for Lua.
-- @licence MIT
-- @autor Sammy L. Koch (1Turtle)
-- @version 1.0

local wrap = require("cc.strings").wrap

local log4l = {}
local meta = {
    __index = function(self, key)
        return function(...)
            return log4l[key](self, ...)
        end
    end
}

--- Returns the current timestamp
function log4l.getTime(logger)
    local stamp = os.date("!*t")
    stamp.hour = stamp.hour + logger.utc
    return ("%02d:%02d:%02d"):format(stamp.hour, stamp.min, stamp.sec)
end

-- Returns the current date
function log4l.getDate(logger)
    local stamp = os.date("!*t")
    stamp.hour = stamp.hour + logger.utc
    return ("%04d-%02d-%02d-%02d-%02d-%02d"):format(stamp.year, stamp.month, stamp.day, stamp.hour, stamp.min, stamp.sec)
end

local function splitter(str)
    local lines = {}
    local i = 1
    for line in str:gmatch("[^\r\n]+") do
        lines[i] = line
        i = i + 1
    end
    return lines
end

--- Adds an generic entry to the log.
-- Will automatically format the given string and split it up to multible lines.
function log4l.genericEntry(logger, flag, str, ...)
    str = str:format(...)
    str = '[' .. ((logger.utc == 0) and "utc:" or '') .. ("%s|%s] "):format(logger.getTime(), flag or "???") .. str
    
    -- Add line that marks a new day
    local current_date = logger.getDate():sub(1, 10)
    if logger.last_entry ~= current_date then
        logger.last_entry = current_date
        local w, _ = logger.term.getSize()
        local date = logger.getDate()
        local cutting_line = " == " .. date .. ' ' .. ('='):rep(w-5-#date-1) .. '\n'
        str = cutting_line .. str
    end

    local lines = splitter(str)

    logger.term.setBackgroundColor(colors.black)

    local w, h = logger.term.getSize()
    for _,line in ipairs(lines) do
        local _, y = logger.term.getCursorPos()

        local splits = wrap(line, w)

        if logger.file then
            logger.file.writeLine(line)
        end
        for _, part in ipairs(splits) do
            if y > h then
                logger.term.scroll(1)
                y = h
            end

            logger.term.setCursorPos(1, y)
            logger.term.clearLine()
            logger.term.write(part)
            y = y+1
        end
        logger.term.setCursorPos(1, y)
    end

    if logger.file then
        logger.file.flush()
    end
end

--- Adds an error entry.
function log4l.error(logger, str, ...)
    local isColor = logger.term.isColor()
    logger.term.setTextColor(isColor and colors.red or colors.white)
    logger.genericEntry("ERROR", str, ...)
end

--- Adds an fatal entry. Will include an stacktrace.
function log4l.fatal(logger, str, ...)
    local stacktrace = ''
    for i, layer in ipairs{debug.traceback()} do
        stacktrace = layer .. '\n'
    end

    local isColor = logger.term.isColor()
    logger.term.setTextColor(isColor and colors.purple or colors.white)
    logger.genericEntry("FATAL", str .. '\n \n' .. stacktrace, ...)
end

--- Adds an warning entry.
function log4l.warn(logger, str, ...)
    local isColor = logger.term.isColor()
    logger.term.setTextColor(isColor and colors.orange or colors.white)
    logger.genericEntry("warn", str, ...)
end

--- Adds an info entry.
function log4l.info(logger, str, ...)
    logger.term.setTextColor(colors.white)
    logger.genericEntry("info", str, ...)
end

--- Closes the logger
function log4l.close(logger, dont_keep)
    if logger.file then
        if not dont_keep then
            logger.info("Log file generated at '%s'", logger.file_name)
        end
        logger.file.close()
        if dont_keep then
            fs.delete(logger.file_name)
            local source = fs.getDir(logger.file_name)
            if #(fs.list(source)) == 0 then
                fs.delete(source)
            end
        end
    end
end

return {
    --- Creates a new logging instance
    new = function(folder, utc, term_mirror)
        local logger = {
            utc = utc,
            term = term_mirror or window.create(term.native(), 1, 1, 51, 19, false)
        }

        logger.last_entry = log4l.getDate(logger):sub(1, 10)
        if folder then
            logger.file_name = fs.combine(folder, log4l.getDate(logger)..".log")
            logger.file = fs.open(logger.file_name, 'a')
        end

        local _, y = logger.term.getCursorPos()
        logger.term.setCursorPos(1, y)

        setmetatable(logger, meta)

        return logger
    end
}