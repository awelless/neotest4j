---@class Gradle
---@field _root_dir string private
---@field _executable string private
local Gradle = {}

---Resolves an executable command to run gradle.
---@param root_dir string
---@return string
local function get_gradle_executable(root_dir)
    local files = require('neotest.lib').files

    local gradlew_path = root_dir .. files.sep .. 'gradlew'
    local wrapper_exists = files.exists(gradlew_path)

    if wrapper_exists then
        return gradlew_path
    else
        return 'gradle'
    end
end

function Gradle:new(root_dir)
    local g = {
        _root_dir = root_dir,
        _executable = get_gradle_executable(root_dir),
    }

    setmetatable(g, self)
    self.__index = self
    return g
end

---Returns a path to a directory where the test results are stored.
---@return string
function Gradle:get_test_results_dir()
    local files = require('neotest.lib').files
    local process = require('neotest.lib').process

    local command = { self._executable, '--project-dir', self._root_dir, 'properties', '--property', 'testResultsDir' }

    local code, out = process.run(command, { stdout = true })
    if code ~= 0 then
        error('Failed to get testResultsDir. Error code: ' .. code .. '. Output: ' .. out)
    end

    for _, line in pairs(vim.split(out.stdout, '\n')) do
        if line:match('testResultsDir: ') then
            return line:gsub('testResultsDir: ', '') .. files.sep .. 'test'
        end
    end

    error('testResultsDir property was not found')
end

---Builds a spec to run the tests.
---@param args table see neotest.RunArgs
---@return table see neotest.RunSpec
function Gradle:build_run_test_command(args)
    return { self._executable, '--project-dir', self._root_dir, 'test' }
end

return Gradle
