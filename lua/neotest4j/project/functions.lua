---Creates a function that finds a root of the current project.
---@param dir string a current working directory.
---@return string
local function find_project_root(dir)
    local log = require('neotest.logging')
    local files = require('neotest.lib').files

    local find_root_function = files.match_root_pattern('settings.gradle.kts', 'settings.gradle')
    local root_dir = find_root_function(dir)

    log.info('Root directory:', root_dir)

    return root_dir
end

---Indicates whether the file is a test file.
---@param file_path string
---@return boolean
local function is_test_file(file_path)
    local log = require('neotest.logging')

    local test_file = file_path:match('%.java$') ~= nil
    log.debug('Filtering test file:', file_path, 'Is test file:', tostring(test_file))
    return test_file
end

return {
    find_project_root = find_project_root,
    is_test_file = is_test_file,
    discover_tests = require('neotest4j.junit.discover_tests'),
}
