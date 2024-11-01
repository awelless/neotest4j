local treesitter = require('neotest.lib.treesitter')

local query = [[
;; Top level test class
(
    (package_declaration
        (identifier) @package.name
    )

    (class_declaration
        name: (identifier) @namespace.name
    ) @namespace.definition
)
        
;; Nested test class
(class_declaration
    (modifiers
        (marker_annotation
            name: (identifier) @class.annotation
            (#eq? @class.annotation "Nested")
        )
    )
    name: (identifier) @namespace.name
) @namespace.definition

;; @Test and @ParameterizedTest methods
(method_declaration
    (modifiers
        (marker_annotation
            name: (identifier) @method.annotation
            (#any-of? @method.annotation "Test" "ParameterizedTest")
        )
    )
    name: (identifier) @test.name
) @test.definition
]]

--- @param file_path string
--- @return table
return function(file_path)
    return treesitter.parse_positions(file_path, query, {
        nested_tests = true,
        position_id = 'require("neotest4j.positions.generate_position_id")',
        build_position = 'require("neotest4j.positions.build_position")',
    })
end
