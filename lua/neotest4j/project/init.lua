---@class Project
---@field _root_dir string private
local Project = {}

---Creates a new project instance.
---@param root_dir string
---@return Project
function Project:new(root_dir)
    local p = {
        _root_dir = root_dir,
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

return Project
