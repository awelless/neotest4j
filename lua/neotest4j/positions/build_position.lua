--- @param captured_nodes table
--- @return string
local function get_node_type(captured_nodes)
    if captured_nodes['test.name'] then
        return 'test'
    end
    if captured_nodes['namespace.name'] then
        return 'namespace'
    end

    error('Invalid node: ' .. vim.inspect(captured_nodes))
end

--- @param node any
--- @param source string
--- @return string
local function get_node_text(node, source)
    return vim.treesitter.get_node_text(node, source)
end

--- Returns a package name if captured_nodes is a top class in a file.
--- @param source string
--- @param captured_nodes table
--- @return string | nil
local function get_package_name(source, captured_nodes)
    local package_name = captured_nodes['package.name']

    return package_name and get_node_text(package_name, source) or nil
end

--- @param file_path string
--- @param source string
--- @param captured_nodes table
--- @return nil | table | table[]
return function (file_path, source, captured_nodes)
    local type = get_node_type(captured_nodes)

    local package_name = get_package_name(source, captured_nodes)
    local package_name_prefix = package_name and package_name .. '.' or ''

    local name = get_node_text(captured_nodes[type .. '.name'], source)

    local definition = captured_nodes[type .. '.definition']

    return {
        type = type,
        path = file_path,
        name = package_name_prefix .. name,
        range = { definition:range() },
    }
end
