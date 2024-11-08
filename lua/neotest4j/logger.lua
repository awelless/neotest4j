return {
    --- @param text string
    log = function (text)
        local file = assert(io.open('~/neotest4j_log.txt', 'w'))
        file:write(text)
        file:close()
    end
}
