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
    local failure = testcase.failure

    if failure == nil then
        return 'passed'
    end

    return 'failed'
end

--- @param report table
--- @return table<neotest4j.JunitResultKey, string>
local function process_report(report)
    local results = {}

    local testsuite = report.testsuite

    for _, testcase in pairs(testsuite.testcase) do
        local key = new_result_key(testcase._attr.classname, testcase._attr.name)
        results[key] = retrieve_result(testcase)
    end

    return results
end

return function(spec, result, tree)
    local junit_results = {}

    local test_results_dir = spec.context.test_results_dir
    local test_results = find_test_result_files(test_results_dir)

    for _, path in ipairs(test_results) do
        local junit_report = parse_file(path)
        vim.tbl_extend('error', { junit_results, process_report(junit_report) } )
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