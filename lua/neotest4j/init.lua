local lib = require('neotest.lib')

local test_query = [[
    ;; Test class
    (class_declaration
        name: (identifier) @namespace.name
    ) @namespace.definition

    ;; @Test and @ParameterizedTest functions
    (method_declaration
        (modifiers
          (marker_annotation
              name: (identifier) @annotation
                  (#any-of? @annotation "Test" "ParameterizedTest")
              )
        )
        name: (identifier) @test.name
    ) @test.definition
]]

local find_root = lib.files.match_root_pattern('settings.gradle.kts', 'settings.gradle')

local function get_gradle_executable(root)
    local gradlew_path = root .. lib.files.sep .. 'gradlew'
    local wrapper_exists = lib.files.exists(gradlew_path)

    if wrapper_exists then
        return gradlew_path
    else
        return 'gradle'
    end
end

local function get_test_results_dir(executable, root)
    local command = { executable, '--project-dir', root, 'properties', '--property', 'testResultsDir' }

    local code, out = lib.process.run(command, { stdout = true })
    if code ~= 0 then
        return 'error'
    end

    for _, line in pairs(vim.split(out.stdout, '\n')) do
        if line:match('testResultsDir: ') then
            return line:gsub('testResultsDir: ', '') .. lib.files.sep .. 'test'
        end
    end

    return 'error'
end

return {
    name = 'neotest4j',
    root = find_root,
    filter_dir = function(name, rel_path, root)
        -- TODO do something better here.
        return true
    end,
    is_test_file = function(file_path)
        if file_path:find('AppTest.java$') or file_path:find('AppTest1.java$') then
            return true
        end
        -- TODO do something better here.
        return false
    end,
    discover_positions = function(file_path)
        return lib.treesitter.parse_positions(file_path, test_query, {})
    end,
    build_spec = function(args)
        local position = args.tree:data()
        local root = find_root(position.path)
        local executable = get_gradle_executable(root)

        local command = { executable, '--project-dir', root, 'test' }
        -- TODO add test filter.

        local test_results_dir = get_test_results_dir(executable, root)

        return { command = command, context = { test_results_dir = test_results_dir } }
    end,
    results = require('neotest4j.collect_test_results'),
}
