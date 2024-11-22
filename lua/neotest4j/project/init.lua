---@class Project
---@field _root_dir string private
---@field _build_system Gradle private
local Project = {}

---Creates a new project instance.
---@param root_dir string
---@return Project
function Project:new(root_dir)
    local Gradle = require('neotest4j.gradle')

    local p = {
        _root_dir = root_dir,
        _build_system = Gradle:new(root_dir),
    }

    setmetatable(p, self)
    self.__index = self
    return p
end

---Returns a root directory of the project.
---@return string
function Project:get_root_dir()
    return self._root_dir
end

---Returns whether a dir is a test dir.
---@param rel_path string path to a directory, relative to the project root.
---@return boolean
function Project:filter_dir(rel_path)
    return rel_path == 'src' or rel_path == 'src/test' or rel_path:match('^src/test/java')
end

---Builds a spec to run the tests.
---@param args table see neotest.RunArgs
---@return table see neotest.RunSpec
function Project:build_run_test_command(args)
    return self._build_system:build_run_test_command(args)
end

---Returns a path to a directory where the test results are stored.
---@return string
function Project:get_test_results_dir()
    return self._build_system:get_test_results_dir()
end

return Project
