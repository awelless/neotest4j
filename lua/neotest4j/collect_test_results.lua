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

--- @class neotest4j.JunitResultKey
--- @field classname string
--- @field name string

--- @param classname string
--- @param name string
--- @return neotest4j.JunitResultKey
local function new_result_key(classname, name)
    return {
        classname = classname,
        name = name,
    }
end

--- @param testcase table
--- @return string
local function retrieve_result(testcase)
    if testcase.failure ~= nil then
        return 'failed'
    end

    if testcase.skipped ~= nil then
        return 'skipped'
    end

    return 'passed'
end

--- @param report table
--- @return table<neotest4j.JunitResultKey, string>
local function process_report(report)
    local results = {}

    local testsuite = report.testsuite
    -- If there is only one testcase, it's returned as an object table.
    local testcases = #testsuite.testcase > 1 and testsuite.testcase or { testsuite.testcase }

    for _, testcase in pairs(testcases) do
        if testcase._attr == nil then
            error(vim.inspect(testsuite) .. '\n' .. vim.inspect(testcases) .. '\n' .. vim.inspect(testcase))
        end
        local key = new_result_key(testcase._attr.classname, testcase._attr.name)
        results[key] = retrieve_result(testcase)
    end

    return results
end

---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return table<string, neotest.Result>
local function collect_test_results(spec, result, tree)
    local junit_results = {}

    local test_results_dir = spec.context.test_results_dir
    local test_results = find_test_result_files(test_results_dir)

    for _, path in ipairs(test_results) do
        local junit_report = parse_file(path)
        for key, test_res in pairs(process_report(junit_report)) do
            junit_results[key] = test_res
        end
    end

    local results = {}

    for _, position in tree:iter() do
        if position.type == 'test' then
            local key = new_result_key(position.path, position.name)
            local test_result = junit_results[key]

            if test_result ~= nil then
                results[position.id] = { status = test_result }
            else
                results[position.id] = { status = 'skipped' }
            end
        end
    end

    return results
end

return collect_test_results
