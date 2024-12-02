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

    local project = require('neotest4j.project'):new(root_dir)

    return {
        command = project:build_run_test_command(args),
        context = {
            project = project,
        },
    }
end

---Parses test results.
---@param spec table see neotest.RunSpec
---@param _ table see neotest.StrategyResult
---@param _ table neotest.Tree
---@return table<string, table> see neotest.Result
local function results(spec, _, _)
    ---@type Project
    local project = spec.context.project
    return project:collect_test_results()
end

return {
    name = 'neotest4j',
    root = require('neotest4j.project.functions').find_project_root,
    filter_dir = filter_dir,
    is_test_file = require('neotest4j.project.functions').is_test_file,
    discover_positions = require('neotest4j.project.functions').discover_tests,
    build_spec = build_spec,
    results = results,
}
