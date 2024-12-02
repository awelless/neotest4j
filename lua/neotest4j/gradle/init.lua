---@class Gradle
---@field _root_dir string private
---@field _executable table private
local Gradle = {}

---Resolves an executable command to run gradle.
---@param root_dir string
---@return string
local function get_gradle_executable(root_dir)
    local files = require('neotest.lib').files

    local gradlew_path = root_dir .. files.sep .. 'gradlew'
    local wrapper_exists = files.exists(gradlew_path)

    return wrapper_exists and gradlew_path or 'gradle'
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

---Builds a full command to run.
---@param gradle Gradle
---@param ... string a gradle command to run.
---@return string[]
local function build_command_spec(gradle, ...)
    local log = require('neotest.logging')

    local command = { gradle._executable, '--project-dir', gradle._root_dir }

    for _, v in ipairs {...} do
        table.insert(command, v)
    end

    log.info('Building gradle command:', table.concat(command, ' '))

    return command
end

---Returns a path to a directory where the test results are stored.
---@param gradle Gradle
---@return string
local function get_test_results_dir(gradle)
    local log = require('neotest.logging')
    local files = require('neotest.lib').files
    local process = require('neotest.lib').process

    local command = build_command_spec(gradle, 'properties', '--property', 'testResultsDir')

    local code, out = process.run(command, { stdout = true })
    if code ~= 0 then
        error('Failed to get testResultsDir. Error code: ' .. code .. '. Output: ' .. out)
    end

    for _, line in pairs(vim.split(out.stdout, '\n')) do
        if line:match('testResultsDir: ') then
            local test_results_dir = line:gsub('testResultsDir: ', '') .. files.sep .. 'test'
            log.debug('Using test results dir:', test_results_dir)
            return test_results_dir
        end
    end

    error('testResultsDir property was not found')
end

---Collect the results of executed tests.
---@return table<string, table> see neotest.Result
function Gradle:collect_test_results()
    local junit = require('neotest4j.junit')

    local test_results_dir = get_test_results_dir(self)
    return junit.collect_test_results(test_results_dir)
end

---Builds a spec to run the tests.
---@param _ table see neotest.RunArgs
---@return table see neotest.RunSpec
function Gradle:build_run_test_command(_)
    return build_command_spec(self, 'test', '--rerun')
end

return Gradle
