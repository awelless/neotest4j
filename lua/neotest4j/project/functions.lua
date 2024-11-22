---Creates a function that finds a root of the current project.
---@param dir string a current working directory.
---@return string
local function find_project_root(dir)
    local files = require('neotest.lib').files
    local find_root_function = files.match_root_pattern('settings.gradle.kts', 'settings.gradle')
    return find_root_function(dir)
end

---Indicates whether the file is a test file.
---@param file_path string
---@return boolean
local function is_test_file(file_path)
    return file_path:match('%.java$') ~= nil
end

return {
    find_project_root = find_project_root,
    is_test_file = is_test_file,
}
