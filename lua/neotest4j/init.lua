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

return {
    name = 'neotest4j',
    root = require('neotest4j.project.functions').find_project_root,
    filter_dir = filter_dir,
    is_test_file = require('neotest4j.project.functions').is_test_file,
    discover_positions = require('neotest4j.positions.discover_positions'),
    build_spec = function(args)
        local gradle = require('neotest4j.gradle')
        local tree = args.tree

        local logger = require('neotest4j.logger')
        logger.log('Args: ' .. vim.inspect(args))

        return {
            command = gradle.build_run_test_command(tree),
            context = {
                test_results_dir = gradle.get_test_results_dir(tree),
            },
        }
    end,
    results = require('neotest4j.collect_test_results'),
}
