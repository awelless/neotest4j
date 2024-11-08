return {
    name = 'neotest4j',
    root = require('neotest4j.gradle').find_project_root,
    filter_dir = function(name, rel_path, root)
        -- TODO do something better here.
        return true
    end,
    is_test_file = function(file_path)
        -- TODO do something better here.
        return true
    end,
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
