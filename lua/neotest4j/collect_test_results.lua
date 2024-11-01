local lib = require('neotest.lib')
local xml = lib.xml

local function find_test_result_files(base_dir)
    local filter = function(name, _, _)
        return name:find('\\.xml$') ~= nil
    end

    return lib.files.find(base_dir, { filter_dir = filter })
end

--- @param path string
--- @return table
local function parse_file(path)
    local content = lib.files.read(path)
    return xml.parse(content)
end

--- @param class_name string
--- @param method_name string
--- @return string
local function new_result_key(class_name, method_name)
    return class_name:gsub('%$', '.') .. '.' .. method_name:gsub('%(.*%)', '')
end

--- @param testcase table
--- @return string
local function retrieve_status(testcase)
    if testcase.failure ~= nil then
        return 'failed'
    end

    if testcase.skipped ~= nil then
        return 'skipped'
    end

    return 'passed'
end

--- @param report table
--- @param results table<string, table> Modified in-place!
local function process_report(report, results)
    local testsuite = report.testsuite
    -- If there is only one testcase, it's returned as an object table.
    local testcases = #testsuite.testcase > 1 and testsuite.testcase or { testsuite.testcase }

    for _, testcase in pairs(testcases) do
        local key = new_result_key(testcase._attr.classname, testcase._attr.name)
        results[key] = { status = retrieve_status(testcase) }
    end
end

---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return table<string, neotest.Result>
return function(spec, result, tree)
    local test_results_dir = spec.context.test_results_dir
    local test_results = find_test_result_files(test_results_dir)

    local results = {}

    for _, path in ipairs(test_results) do
        local junit_report = parse_file(path)
        process_report(junit_report, results)
    end

    return results
end
