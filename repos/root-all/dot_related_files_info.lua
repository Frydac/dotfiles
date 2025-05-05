local from_expr = require('related_files').pargen_from_expression

-- for files we don't know the namespace for, e.g. external libraries that are in the same directory
local function create_basic_pargens_and_relations()
    local pargens = {
        from_expr("c", "{parent}/{name}.c"),
        from_expr("h", "{parent}/{name}.h"),
        from_expr("cpp", "{parent}/{name}.cpp"),
        from_expr("hpp", "{parent}/{name}.hpp")
    }

    local relations = {
        { "h", "c" },
        { "h", "cpp" },
        { "hpp", "cpp" },
    }

    return pargens, relations
end

local function create_ruby_pargens_and_relations()
    local pargens = {
        from_expr("source", "{parent}/ruby/{namespace}/{name}.rb"),
        from_expr("test", "{parent}/test/ruby/{namespace}/{name}_tests.rb"),

        -- these are mainly used for init snippets
        from_expr("story", "{parent}/story/{namespace}/{name}.rb"),
        from_expr("script", "{parent}/script/{namespace}/{name}.rb"),
        from_expr("release", "{parent}/release/{namespace}/{name}.rb"),
        from_expr("qc", "{parent}/qc/{namespace}/{name}.rb"),
    }

    local relations = {
        { "source", "test" }
    }

    return pargens, relations
end

local function create_auro_pargens_and_relations()
    local access = { "private", "protected", "public" }
    local c_versions = { "c89", "c99", "c11", "c17", "c23" }
    local c_exts = { "h", "c" }
    local cpp_versions = { "cpp98", "cpp03", "cpp11", "cpp14", "cpp17", "cpp20", "cpp23" }
    local cpp_exts = { "hpp", "cpp" }

    -- define parsing expressions from which parsers and generators are
    -- creeated for each 'related file type'
    local function create_pargens()
        local pargens = {}

        for _, acc in ipairs(access) do
            -- c sources and headers
            for _, c_v in ipairs(c_versions) do
                for _, ext in ipairs(c_exts) do
                    local pargen_name = acc .. "_" .. c_v .. "_" .. ext
                    local pargen_expression = "{parent}/" .. c_v .. "/" .. acc .. "/{namespace}/{name}." .. ext
                    table.insert(pargens, from_expr(pargen_name, pargen_expression))
                end
            end

            -- cpp sources and headers
            for _, cpp_v in ipairs(cpp_versions) do
                for _, ext in ipairs(cpp_exts) do
                    local pargen_name = acc .. "_" .. cpp_v .. "_" .. ext
                    local pargen_expression = "{parent}/" .. cpp_v .. "/" .. acc .. "/{namespace}/{name}." .. ext
                    table.insert(pargens, from_expr(pargen_name, pargen_expression))
                end
            end

            -- tests without version
            do
                local pargen_name = acc .. "_test"
                local pargen_expression = "{parent}/test/" .. acc .. "/{namespace}/{name}_tests.cpp"
                table.insert(pargens, from_expr(pargen_name, pargen_expression))
            end

            -- tests with cpp version
            for _, cpp_v in ipairs(cpp_versions) do
                local pargen_name = acc .. "_" .. cpp_v .. "_test"
                local pargen_expression = "{parent}/test/" .. cpp_v .. "/" .. acc .. "/{namespace}/{name}_tests.cpp"
                table.insert(pargens, from_expr(pargen_name, pargen_expression))
            end
        end


        -- asd files
        do
            local pargen_name = 'asd'
            local pargen_expression = "{parent}/asd/{namespace}/{name}.asd"
            table.insert(pargens, from_expr(pargen_name, pargen_expression))
        end

        return pargens
    end

    local function create_relations()
        local relations = {}

        local function add_relations_for_c_headers_with_newer_c_source_versions(acc, c_v_header_ix)
            local c_v_header = c_versions[c_v_header_ix]
            for c_v_source_ix = c_v_header_ix + 1, #c_versions do
                local c_v_source = c_versions[c_v_source_ix]
                local new_relations = {
                    acc .. "_" .. c_v_header .. "_h",
                    acc .. "_" .. c_v_source .. "_c",
                }
                table.insert(relations, new_relations)
            end
        end

        -- map/relate same access specifier to same access specifier
        for _, acc in ipairs(access) do
            for c_v_ix, c_v in ipairs(c_versions) do

                -- map identical C versions
                do
                    local new_relations = {
                        acc .. "_" .. c_v .. "_h",
                        acc .. "_" .. c_v .. "_c",
                        acc .. "_test",
                    }
                    table.insert(relations, new_relations)
                end

                -- map C headers to C++ sources
                -- each C header version can map to all C++ source versions, C++ versioned tests
                for _, cpp_v in ipairs(cpp_versions) do
                    local new_relations = {
                        acc .. "_" .. c_v .. "_h",
                        acc .. "_" .. cpp_v .. "_cpp",
                        acc .. "_" .. cpp_v .. "_test",
                    }
                    table.insert(relations, new_relations)
                end

                -- match older c headers with newer c sources
                add_relations_for_c_headers_with_newer_c_source_versions(acc, c_v_ix)
            end

            for _, cpp_v in ipairs(cpp_versions) do
                -- map identical cpp versions, with versionless tests
                do
                    local new_relations = {
                        acc .. "_" .. cpp_v .. "_hpp",
                        acc .. "_" .. cpp_v .. "_cpp",
                        acc .. "_test"
                    }
                    table.insert(relations, new_relations)
                end

                -- map identical cpp versions, with identical cpp versions tests
                do
                    -- NOTE: we are duplicating hpp<>cpp relations here from the last loop, maybe think of better ways to define relations that takes this into account?
                    local new_relations = {
                        acc .. "_" .. cpp_v .. "_hpp",
                        acc .. "_" .. cpp_v .. "_cpp",
                        acc .. "_" .. cpp_v .. "_test"
                    }
                    table.insert(relations, new_relations)
                end
            end
        end

        -- map public header to protected/private source and test
        do
            local from_public_access = { "private", "protected" }
            for _, cpp_v in ipairs(cpp_versions) do
                for _, acc in ipairs(from_public_access) do
                    local new_relations = {
                        "public_" .. cpp_v .. "_hpp",
                        acc .. "_" .. cpp_v .. "_cpp",
                        acc .. "_" .. cpp_v .. "_test"
                    }
                    table.insert(relations, new_relations)
                end
            end
            for c_v_ix, c_v in ipairs(c_versions) do
                for _, acc in ipairs(from_public_access) do
                    do
                        local new_relations = {
                            "public_" .. c_v .. "_h",
                            acc .. "_" .. c_v .. "_c",
                        }
                        table.insert(relations, new_relations)
                    end

                    -- Add mappings from C headers to newer C versions
                    do
                        local c_v_header_ix = c_v_ix
                        local c_v_header = c_versions[c_v_header_ix]
                        for c_v_source_ix = c_v_header_ix + 1, #c_versions do
                            local c_v_source = c_versions[c_v_source_ix]
                            local new_relations = {
                                "public_" .. c_v_header .. "_h",
                                acc .. "_" .. c_v_source .. "_c",
                            }
                            table.insert(relations, new_relations)
                        end
                    end

                    -- Also add mappings for cpp sources from C headers
                    for _, cpp_v in ipairs(cpp_versions) do
                        local new_relations = {
                            "public_" .. c_v .. "_h",
                            acc .. "_" .. cpp_v .. "_cpp"
                        }
                        table.insert(relations, new_relations)
                    end
                end
            end
            -- TODO: to cpp versioned tests from c headers
        end

        -- map protected header to private source and test
        do
            local from_protected_access = { "private" }
            for _, cpp_v in ipairs(cpp_versions) do
                for _, acc in ipairs(from_protected_access) do
                    local new_relations = {
                        "protected_" .. cpp_v .. "_hpp",
                        acc .. "_" .. cpp_v .. "_cpp",
                        acc .. "_" .. cpp_v .. "_test"
                    }
                    table.insert(relations, new_relations)
                end
            end
            for c_v_ix, c_v in ipairs(c_versions) do
                for _, acc in ipairs(from_protected_access) do
                    do
                        local new_relations = {
                            "protected_" .. c_v .. "_h",
                            acc .. "_" .. c_v .. "_c",
                        }
                        table.insert(relations, new_relations)
                    end

                    -- Add mappings from C headers to newer C versions
                    do
                        local c_v_header_ix = c_v_ix
                        local c_v_header = c_versions[c_v_header_ix]
                        for c_v_source_ix = c_v_header_ix + 1, #c_versions do
                            local c_v_source = c_versions[c_v_source_ix]
                            local new_relations = {
                                "protected_" .. c_v_header .. "_h",
                                acc .. "_" .. c_v_source .. "_c",
                            }
                            table.insert(relations, new_relations)
                        end
                    end

                    -- Also add mappings for cpp sources from C headers
                    for _, cpp_v in ipairs(cpp_versions) do
                        local new_relations = {
                            "protected_" .. c_v .. "_h",
                            acc .. "_" .. cpp_v .. "_cpp"
                        }
                        table.insert(relations, new_relations)
                    end
                end
            end
            -- TODO:
        end

        do
            local new_relations = {}
            new_relations[1] = 'public_c89_h'
            new_relations[4] = 'asd'
            table.insert(relations, new_relations)
        end

        return relations
    end

    return create_pargens(), create_relations()
end

local basic_pargens, basic_relations = create_basic_pargens_and_relations()
local auro_pargens, auro_relations = create_auro_pargens_and_relations()
local ruby_pargens, ruby_relations = create_ruby_pargens_and_relations()

local function array_concat(tbl1, tbl2)
    local tbl_out = {}
    for i = 1, #tbl1 do
        tbl_out[i] = tbl1[i]
    end
    for i = 1, #tbl2 do
        tbl_out[i + #tbl1] = tbl2[i]
    end
    return tbl_out
end

-- luajit style varargs
local function array_concat_multi(...)
    local result = {}
    for i=1, select("#",...) do
        result = array_concat(result, select(i,...))
    end
    return result
end

-- local pargens = array_concat(basic_pargens, auro_pargens)
-- local relations = array_concat(basic_relations, auro_relations)
--
-- pargens = array_concat(pargens, ruby_pargens)
-- relations = array_concat(relations, ruby_relations)

local pargens = array_concat_multi(basic_pargens, auro_pargens, ruby_pargens)
local relations = array_concat_multi(basic_relations, auro_relations, ruby_relations)

-- local vlog = require("vlog")
-- if vlog then
--     vlog.info("pargens")
--     vlog.info(pargens)
--     vlog.info("relations")
--     vlog.info(relations)
-- else
--     print("no vlog :(")
-- end


return {
    pargens = pargens,
    relations = relations
    -- pargens = basic_pargens,
    -- relations = basic_relations
    -- pargens = auro_pargens,
    -- relations = auro_relations
}
