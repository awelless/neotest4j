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

    for _, v in ipairs { ... } do
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

---Creates a gradle test filter for the position.
---@param root_dir string
---@param position table see neotest.Position
---@return string
local function build_test_filter(root_dir, position)
    local type = position.type
    if type == 'test' then
        return position.id
    end

    -- 'namespace', 'file' and 'dir'.

    ---@type string
    local path = position.path

    local _, prefix_end = path:find('^' .. root_dir .. '/src/test/java/')
    if prefix_end == nil then
        -- The path doesn't start with the root_dir. Running all tests possible.
        return '*'
    end

    local relative_path = path:sub(prefix_end + 1)

    if type == 'file' then
        local extension_start = relative_path:find('%.java$')

        if extension_start == nil then
            -- The file extension is unfamiliar. Running all tests possible.
            return '*'
        end

        relative_path = relative_path:sub(0, extension_start - 1)
    end

    local package_class_name = relative_path:gsub('/', '.')
    return package_class_name
end

---Builds a spec to run the tests.
---@param args table see neotest.RunArgs
---@return table see neotest.RunSpec
function Gradle:build_run_test_command(args)
    local log = require('neotest.logging')

    local position = args.tree:data()
    local filter = build_test_filter(self._root_dir, position)

    log.trace('Test position: ', position)
    log.trace('Test filter: ', filter)

    return build_command_spec(self, 'test', '--tests', filter, '--rerun')
end

return Gradle
