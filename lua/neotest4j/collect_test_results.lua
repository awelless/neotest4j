local function find_test_result_files(base_dir)
    local files = require('neotest.lib').files

    local filter = function(name, _, _)
        return name:find('%.xml$') ~= nil
    end

    return files.find(base_dir, { filter_dir = filter })
end

--- @param path string
--- @return table
local function parse_file(path)
    local files = require('neotest.lib').files
    local xml = require('neotest.lib').xml

    local content = files.read(path)
    return xml.parse(content)
end

--- @param class_name string
--- @param method_name string
--- @return string
local function new_result_key(class_name, method_name)
    return class_name:gsub('%$', '.') .. '.' .. method_name:gsub('%(.*%)', '')
end

--- @param testcase table a junit use case table
--- @return table see neotest.Result
local function convert_to_result(testcase)
    local types = require('neotest.types')

    if testcase.failure ~= nil then
        return {
            status = types.ResultStatus.failed,
            short = testcase.failure._attr.message,
        }
    end

    if testcase.skipped ~= nil then
        return {
            status = types.ResultStatus.skipped,
            short = 'The test was skipped.',
        }
    end

    return {
        status = types.ResultStatus.passed,
        short = 'The test was passed.',
    }
end

--- @param report table
--- @param results table<string, table> Modified in-place!
local function process_report(report, results)
    local testsuite = report.testsuite
    if testsuite == nil or testsuite.testcase == nil then
        return
    end

    -- If there is only one testcase, it's returned as an object table.
    local testcases = #testsuite.testcase > 1 and testsuite.testcase or { testsuite.testcase }

    for _, testcase in pairs(testcases) do
        local key = new_result_key(testcase._attr.classname, testcase._attr.name)
        results[key] = convert_to_result(testcase)
    end
end

---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return table<string, neotest.Result>
return function(spec, result, tree)
    local log = require('neotest.logging')

    ---@type Project
    local project = spec.context.project

    local test_results_dir = project:get_test_results_dir()
    local test_results = find_test_result_files(test_results_dir)

    local results = {}

    for _, path in ipairs(test_results) do
        local junit_report = parse_file(path)
        process_report(junit_report, results)
    end

    log.trace('Test results:', results)

    return results
end
