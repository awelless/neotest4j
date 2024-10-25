local lib = require('neotest.lib')
local xml = lib.xml

local function find_test_result_files(base_dir)
    local filter = function(name, _, _)
        return name:find('\\.xml$') ~= nil
    end

    return lib.files.find(base_dir, { filter_dir = filter })
end

local function parse_file(path)
    local content = lib.files.read(path)
    return xml.parse(content)
end

return function(spec, result, tree)
    local results = {}

    local test_results_dir = spec.context.test_results_dir
    local test_results = find_test_result_files(test_results_dir)

    for _, path in ipairs(test_results) do
        local junit_report = parse_file(path)
        -- TODO process the report.
    end

    return result
end
