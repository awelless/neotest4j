local find_project_root = require('neotest.lib').files.match_root_pattern('settings.gradle.kts', 'settings.gradle')

---@param root string
---@return string
local function get_gradle_executable(root)
    local lib = require('neotest.lib')

    local gradlew_path = root .. lib.files.sep .. 'gradlew'
    local wrapper_exists = lib.files.exists(gradlew_path)

    if wrapper_exists then
        return gradlew_path
    else
        return 'gradle'
    end
end

---@param tree table see neotest.Tree
---@return string
local function get_test_results_dir(tree)
    local lib = require('neotest.lib')

    local position = tree:data()

    local root = find_project_root(position.path)
    local executable = get_gradle_executable(root)

    local command = { executable, '--project-dir', root, 'properties', '--property', 'testResultsDir' }

    local code, out = lib.process.run(command, { stdout = true })
    if code ~= 0 then
        error('Failed to get testResultsDir. Error code: ' .. code .. '. Output: ' .. out)
    end

    for _, line in pairs(vim.split(out.stdout, '\n')) do
        if line:match('testResultsDir: ') then
            return line:gsub('testResultsDir: ', '') .. lib.files.sep .. 'test'
        end
    end

    error('testResultsDir property was not found')
end

---@param tree table see neotest.Tree
---@return string[]
local function build_run_test_command(tree)
    local position = tree:data()

    local root = find_project_root(position.path)
    local executable = get_gradle_executable(root)

    return { executable, '--project-dir', root, 'test' }
end

return {
    find_project_root = find_project_root,
    build_run_test_command = build_run_test_command,
    get_test_results_dir = get_test_results_dir,
}
