--- @param parents table[]
--- @return string
local function calculate_namespace_prefix(parents)
    if #parents == 0 then
        return ''
    end

    local namespace_names = {}

    for i, node in ipairs(parents) do
        namespace_names[i] = node.name
    end

    return table.concat(namespace_names, '.') .. '.'
end

--- @param position table
--- @param parents table[]
--- @return string
return function (position, parents)
    local log = require('neotest.logging')

    local namespace_prefix = calculate_namespace_prefix(parents)
    local position_name = position.name
    local position_id = namespace_prefix .. position_name

    log.trace('Position:', position, 'Position id:', position_id)

    return position_id
end
