---Filter directories when searching for test files
---@param _ string a name of a directory.
---@param rel_path string a path to the directory, relative to the root.
---@param root string the root directory of the project.
---@return boolean
local function filter_dir(_, rel_path, root)
    local Project = require('neotest4j.project')
    local p = Project:new(root)
    return p:filter_dir(rel_path)
end

---Builds a spec to run the tests.
---@param args table see neotest.RunArgs
---@return table see neotest.RunSpec
local function build_spec(args)
    local tree = args.tree
    local path = tree:data().path
    local root_dir = require('neotest4j.project.functions').find_project_root(path)

    local Project = require('neotest4j.project')
    local p = Project:new(root_dir)

    return {
        command = p:build_run_test_command(args),
        context = {
            project = p,
        },
    }
end

return {
    name = 'neotest4j',
    root = require('neotest4j.project.functions').find_project_root,
    filter_dir = filter_dir,
    is_test_file = require('neotest4j.project.functions').is_test_file,
    discover_positions = require('neotest4j.positions.discover_positions'),
    build_spec = build_spec,
    results = require('neotest4j.collect_test_results'),
}
