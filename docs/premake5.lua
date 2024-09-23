-- Copyright (c) 2012 Martin Ridgers
-- License: http://opensource.org/licenses/MIT

--------------------------------------------------------------------------------
local function starts_with(str, start)
    return string.sub(str, 1, string.len(start)) == start
end

--------------------------------------------------------------------------------
local function make_weblink(name, div)
    local tag = div and "div" or "span"
    if name then
        return '<'..tag..' class="wlink"><a href="#'..name..'"><svg width=16 height=16><use href="#wicon"/></a><span class="wfix">.</span></'..tag..'>'
    else
        return '<'..tag..' class="wlink"><svg width=16 height=16 style="display:none"/></'..tag..'>'
    end
end

--------------------------------------------------------------------------------
local function markdown_file(source_path, out)
    print("  << " .. source_path)

    local base_name = source_path:match('([^/\\]+)$')

    local tmp_name = '.build\\docs\\tmp.'..base_name..'.md'
    local tmp = io.open(tmp_name, "w")
    for line in io.lines(source_path) do
        local inc_file = line:match("#INCLUDE %[(.*)%]")
        if inc_file then
            for inc_line in io.lines(inc_file) do
                tmp:write(inc_line.."\n")
            end
        else
            line = line:gsub("%$%(BEGINDIM%)", "<div style='opacity:0.5'>")
            line = line:gsub("%$%(ENDDIM%)", "</div>")
            tmp:write(line .. "\n")
        end
    end
    tmp:close()

    local out_file = '.build\\docs\\'..base_name..'.html'
    os.execute('marked -o '..out_file..' < '..tmp_name)

    local line_reader = io.lines(out_file)
    for line in line_reader do
        out:write(line .. "\n")
    end
end

--------------------------------------------------------------------------------
local function generate_file(source_path, out, weblinks)
    print("  << " .. source_path)
    local docver = _OPTIONS["docver"] or clink_git_name:upper()
    local last_name
    for line in io.open(source_path, "r"):lines() do
        local include = line:match("%$%(INCLUDE +([^)]+)%)")
        if include then
            generate_file(include, out, weblinks)
        else
            local md = line:match("%$%(MARKDOWN +([^)]+)%)")
            if md then
                markdown_file(md, out)
            else
                line = line:gsub("%$%(CLINK_VERSION%)", docver)
                line = line:gsub("<br>", "&lt;br&gt;")
                line = line:gsub("<!%-%- NEXT PASS INCLUDE (.*) %-%->", "$(INCLUDE %1)")

                local n, hopen, hclose
                if weblinks then
                    n = line:match('^<p><a name="([^"]+)"')
                    hopen, hclose = line:match('^( *<h[0-9][^>]*>)(.+)$')
                    if n then
                        last_name = n
                    end
                    if hopen and not last_name then
                        last_name = hopen:match('id="([^"]+)"')
                    end
                end
                if hopen then
                    out:write(hopen)
                    out:write(make_weblink(last_name, true--[[div]]))
                    out:write(hclose .. "\n")
                else
                    out:write(line .. "\n")
                end

                if hopen then
                    last_name = nil
                end
            end
        end
    end
end

--------------------------------------------------------------------------------
local function parse_doc_tags_impl(out, file)
    print("Parse tags: "..file)

    local line_reader = io.lines(file)
    local prefix = "///"
    local desc_num = 1
    local show_num = 1
    local seen_show

    -- Reads a tagged line, extracting its key and value; '/// key: value'
    local function read_tagged()
        local line = line_reader()
        if not line then
            return line
        end

        local left, right = line:find("^"..prefix.."%s+")
        if not left then
            if line == prefix then
                right = #line
            else
                return nil
            end
        end

        line = line:sub(right + 1)
        local _, right, tag, value = line:find("^-([a-z]+):")
        if tag then
            if tag == "show" then
                tag = tag..show_num
                seen_show = true
            end
            _, right, value = line:sub(right + 1):find("^%s*(.+)")
            if value == nil then
                value = ""
            end
        else
            if seen_show then
                desc_num = desc_num + 1
                show_num = show_num + 1
                seen_show = nil
            end
            tag = "desc"..desc_num
            _, _, value = line:find("^%s*(.+)")
            if not value then
                value = ""
            end
        end

        return tag, value
    end

    -- Finds '/// name: ...' tagged lines. Denotes opening of a odocument block.
    local function parse_tagged(line)
        prefix = "///"
        local left, right = line:find("^///%s+-name:%s+")
        if not left then
            prefix = "---"
            left, right = line:find("^---%s+-name:%s+")
        end

        if not left then
            return
        end

        line = line:sub(right + 1)
        local _, _, name, group = line:find("^((.+)[.:].+)$")
        if not group then
            group = "[other]"
            name = line
        end

        desc_num = 1
        show_num = 1
        seen_show = nil

        return group, name
    end

    for line in line_reader do
        local desc = {}

        local group, name = parse_tagged(line)
        if name then
            for tag, value in read_tagged do
                local desc_tag = desc[tag] or {}
                if value == "" and tag:sub(1, 4) == "desc" then
                    if #desc_tag > 0 then
                        desc_tag[#desc_tag] = desc_tag[#desc_tag]..'</p><p class="desc">'
                    end
                else
                    if tag == "deprecated" then
                        group = "Deprecated"
                    end
                    table.insert(desc_tag, value)
                end
                desc[tag] = desc_tag
            end

            desc.name = { name }
            desc.desc_num = desc_num

            out[group] = out[group] or {}
            table.insert(out[group], desc)
        end
    end
end

--------------------------------------------------------------------------------
local function parse_doc_tags(out, glob)
    local files = os.matchfiles(glob)
    for _, file in ipairs(files) do
        parse_doc_tags_impl(out, file)
    end
end

--------------------------------------------------------------------------------
local function bold_name(args)
    local result = {}
    if args then
        for i,v in pairs(args) do
            v = v:gsub('^([[]*)([^:]*):', '%1<span class="arg_name">%2</span>:')
            table.insert(result, v)
        end
    end
    return result
end

--------------------------------------------------------------------------------

---@class Entry : { [integer]: FunctionDef }
---@field name string
---@field type string
---@field descr string[]
---@field show string[]
---@field version string?
---@field deprecated true | string?
---@field classname string?

---@class FunctionDef
---@field generic string?
---@field params { name: string, type: string, comment: string? }[]
---@field paramlist string[]
---@field signature string
---@field returns { type: string, comment: string? }

local function trim(item)
    return (item:gsub("^%s*", ""):gsub("%s*$", ""))
end

--- Builds all combinations of possible overloads using square bracket optionals.
local function buildOverloads(cur, i, paramList, acc)
    local param = paramList[i]
    if not param then
        acc[#acc+1] = cur
    elseif not param.optional then
        cur[#cur+1] = param
        return buildOverloads(cur, i + 1, paramList, acc)
    else
        local alt = {}
        for j = 1, #cur do
            alt[j] = cur[j]
        end
        cur[#cur+1] = param
        buildOverloads(cur, i + 1, paramList, acc)
        buildOverloads(alt, i + 1, paramList, acc)
    end
end

--- Formats entries which are easier to write
---@param groups Group[]
---@return Entry[]
local function formatEntries(groups)
    local classes = {
        -- Sometimes the class is called argmatcher
        argmatcher = "clink._argmatcher"
    }

    for _, group in ipairs(groups) do
        if (not _G[group.name] or group.name == 'path') and group.name ~= 'Deprecated' and group.name ~= '[other]' then
            local class = group.name == 'clink' and group.name or 'clink.'..group.name
            classes[group.name] = class
        end
    end

    ---@type Entry[]
    local result = {}
    for _, group in ipairs(groups) do
        table.sort(group, function(a, b) return a.name[1] < b.name[1] end)
        if classes[group.name] then
            result[#result+1] = {
                name = group.name,
                classname = classes[group.name],
                type = 'class',
                descr = {},
                show = {},
            } --[[@as Entry]]

            if group.name == 'clink' then
                -- Add clink.arg as a class to prevent later undefined field `arg` warnings
                result[#result+1] = {
                    name = 'clink.arg',
                    classname = 'clink.arg',
                    type = 'class',
                    descr = {},
                    show = {}
                }
            end
        end
        for _, doc_tag in ipairs(group) do
            local name = doc_tag.name[1]

            local function linkTypes(item)
                if item == 'self' then
                    return 'clink.'..name:match "^[^%.:]*"
                elseif item == 'file' then
                    return 'file*'
                elseif item == 'coroutine' then
                    return 'thread'
                elseif item == 'iterator' then
                    return 'fun(): string'
                elseif classes[item] then
                    return classes[item]
                end
                return item
            end

            --- Replaces any type found in string with correct classname
            local function parseTypes(str)
                if type(str) ~= 'string' then error("Expected string, got "..type(str), 2) end
                str = str:gsub('<a%s+href="#[^"]+">([^<]*)</a>', '%1')
                str = str:gsub('[%a_][%w_]*', linkTypes)
                -- "table of Xs" is just "X[]"
                str = str:gsub('table of ([%w_]-)s', '%1[]')
                return str
            end

            ---@type Entry
            local entry = {
                name = table.concat(doc_tag.name),
                deprecated = doc_tag.deprecated and doc_tag.deprecated[1] or group.name == 'Deprecated' or nil,
                descr = doc_tag.desc1 or {},
                show = doc_tag.show1 or {},
                type = not doc_tag.var and 'function' or doc_tag.var[1],
                version = doc_tag.ver and doc_tag.ver[1],
            }

            entry.deprecated = entry.deprecated and #entry.deprecated > 0 and entry.deprecated or nil

            -- There is really only one function using generics
            local ret, returnFromFunc = table.concat(doc_tag.ret or {}, ", "):gsub('return value from func', 'T')
            local generic = returnFromFunc > 0 and 'T' or nil

            local params = {}
            for _, arg in ipairs(doc_tag.arg or {}) do
                local optional = arg:match "%b[]"
                if optional then
                    arg = optional:sub(2, -2)
                end
                local paramname, type = arg:match "^([^:]+):?([^:]-)$"
                type = parseTypes(type)
                local comment = paramname:match"([^%.]*)%.%.%."
                if comment then
                    paramname = "..."
                    comment = #comment > 0 and comment or nil
                end
                type = #type > 0 and type or 'any'
                params[#params+1] = {
                    name = paramname,
                    comment = comment,
                    type = type,
                    optional = optional and true or false
                }
            end

            local returnTypeDoc = {}
            if #ret > 0 then
                ret = parseTypes(ret)
                local nextOptional
                for t in ret:gmatch "[^,]+" do
                    local actual = trim(t:gsub("[][]", ""))
                    local comment, returnType = actual:match "^([^:]-):?([^:]+)$"
                    local optional = nextOptional or t:find "^%["

                    returnTypeDoc[#returnTypeDoc+1] = {
                        comment = comment,
                        type = returnType..(optional and '?' or ''),
                    }

                    nextOptional = t:find "%[%s*$"
                end
            end

            local overloads = {}
            buildOverloads({}, 1, params, overloads)

            local simpleReturnList do
                local returnTypeList = {}
                for _, item in ipairs(returnTypeDoc) do
                    returnTypeList[#returnTypeList+1] = item.type
                end
                simpleReturnList = table.concat(returnTypeList, ', ')
            end

            for i, overload in ipairs(overloads) do
                ---@type FunctionDef
                local def = {
                    paramlist = {},
                    params = {},
                    returns = returnTypeDoc,
                    signature = "",
                    generic = generic
                }
                local typedList = {}
                for _, param in ipairs(overload) do
                    def.params[#def.params+1] = param
                    def.paramlist[#def.paramlist+1] = param.name
                    typedList[#typedList+1] = param.name..": "..param.type
                end

                def.signature = string.format("fun(%s)%s", table.concat(typedList, ', '), #returnTypeDoc > 0 and ": "..simpleReturnList or '')

                entry[#entry+1] = def
            end

            result[#result+1] = entry
        end
    end

    return result
end

---@class Group : { [integer]: Item }
---@field name string

---@class Item
---@field name string[]
---@field ret string[]
---@field desc1 string[]
---@field show1 string[]
---@field arg string[]
---@field ver string[]
---@field var string[]
---@field deprecated string[]?


local DEFAULT_VAR = {
    string = '""',
    integer = '0',
    table = '{}',
}

---@param groups Group[]
local function do_lua_definitions(groups)
    local def = assert(io.open('docs/clink-defs.lua', 'w'))
    local function emit(...)
        for _, item in ipairs { ... } do
            def:write(tostring(item))
        end
        def:write '\n'
    end

    local function emitf(fmt, ...)
        if type(fmt) ~= 'string' then error("Expected string, got "..type(fmt), 2) end
        emit(fmt:format(...))
    end

    local formatted = formatEntries(groups)

    emit("---@meta\n")
    for _, entry in ipairs(formatted) do
        if entry.version then
            emitf("--- v%s or newer\n---", entry.version)
        elseif entry.deprecated then
            emit "---@deprecated"
            if type(entry.deprecated) == 'string' then
                emitf("---@see %s", entry.deprecated:gsub(':', '.'))
            end
        end

        for _, line in ipairs(entry.descr) do
            emitf("--- %s", line)
        end

        if #entry.show > 0 then
            emit "--- ```lua"
            for _, line in ipairs(entry.show) do
                emitf("--- %s", line:gsub("&[^;]*;", ''))
            end
            emit "--- ```"
        end

        local first = entry[1]

        if entry.type == 'class' then
            emitf("---@class %s", entry.classname)
            emitf("_G.%s = {}", entry.name)
        elseif entry.type == 'function' then
            if first.generic then
                emitf("---@generic %s", first.generic)
            end

            for _, param in ipairs(first.params) do
                emitf("---@param %s %s%s", param.name, param.type, param.comment and ' # '..param.comment or '')
            end

            for _, ret in ipairs(first.returns) do
                emitf("---@return %s%s", ret.type, ret.commant and ' # '..ret.comment or '')
            end

            for i = 2, #entry do
                local overload = entry[i]
                emitf("---@overload %s", overload.signature)
            end
            emitf("function %s(%s) end", entry.name, table.concat(first.paramlist, ', '))
        else
            emitf("---@type %s", entry.type)
            emitf("_G.%s = %s", entry.name, DEFAULT_VAR[entry.type])
        end

        emit()
    end
end

--------------------------------------------------------------------------------
local function do_docs()
    local tmp_path = ".build/docs/clink_tmp"
    out_path = ".build/docs/clink.html"

    os.execute("1>nul 2>nul md .build\\docs")

    -- Collect document tags from source and output them as HTML.
    local doc_tags = {}
    parse_doc_tags(doc_tags, "clink/**.lua")
    parse_doc_tags(doc_tags, "clink/lua/**.cpp")

    local groups = {}
    for group_name, group_table in pairs(doc_tags) do
        group_table.name = group_name
        table.insert(groups, group_table)
    end

    local compare_groups = function (a, b)
        local a_deprecated = (a.name == "Deprecated")
        local b_deprecated = (b.name == "Deprecated")
        if a_deprecated or b_deprecated then
            if not a_deprecated then
                return true
            else
                return false
            end
        end
        local a_other = (a.name == "[other]" and true) or false
        local b_other = (b.name == "[other]" and true) or false
        if a_other or b_other then
            if not a_other then
                return true
            else
                return false
            end
        end
        return a.name < b.name
    end

    table.sort(groups, compare_groups)

    local ok, err = xpcall(do_lua_definitions, debug.traceback, groups)
    if not ok then
        error(err)
    end

    local api_html = io.open(".build/docs/api_html", "w")
    api_html:write('<h3 id="lua-api-groups">API groups</h3>')
    api_html:write('<svg style="display:none" xmlns="http://www.w3.org/2000/svg"><defs><symbol id="wicon" viewBox="0 0 16 16" fill="currentColor">')
    api_html:write('<path d="M4.715 6.542 3.343 7.914a3 3 0 1 0 4.243 4.243l1.828-1.829A3 3 0 0 0 8.586 5.5L8 6.086a1.002 1.002 0 0 0-.154.199 2 2 0 0 1 .861 3.337L6.88 11.45a2 2 0 1 1-2.83-2.83l.793-.792a4.018 4.018 0 0 1-.128-1.287z"/>')
    api_html:write('<path d="M6.586 4.672A3 3 0 0 0 7.414 9.5l.775-.776a2 2 0 0 1-.896-3.346L9.12 3.55a2 2 0 1 1 2.83 2.83l-.793.792c.112.42.155.855.128 1.287l1.372-1.372a3 3 0 1 0-4.243-4.243L6.586 4.672z"/>')
    api_html:write('</symbol></defs></svg>')
    api_html:write('<p/><div class="toc">')
    for _, group in ipairs(groups) do
        local italon = ""
        local italoff = ""
        if group.name == "Deprecated" then
            italon = "<em>"
            italoff = "</em>"
            api_html:write('<p/>')
        end
        api_html:write('<div class="H1"><a href="#'..group.name..'">')
        api_html:write(italon..group.name..italoff)
        api_html:write('</a></div>')
    end
    api_html:write('</div>')
    for _, group in ipairs(groups) do
        table.sort(group, function (a, b) return a.name[1] < b.name[1] end)

        local class group_class = "group"
        if group.name == "Deprecated" then
            group_class = group_class.." deprecated"
        end

        api_html:write('<div class="'..group_class..'">')
        api_html:write('<h5 class="group_name">'..make_weblink(group.name)..'<a name="'..group.name..'">'..group.name..'</a></h5>')

        for _, doc_tag in ipairs(group) do
            api_html:write('<div class="function">')

            local name = doc_tag.name[1]
            local arg = table.concat(bold_name(doc_tag.arg), ", ")
            local ret = (doc_tag.ret or { "nil" })[1]
            local var = (doc_tag.var or { nil })[1]
            local version = (doc_tag.ver or { nil })[1]
            local deprecated = (doc_tag.deprecated or { nil })[1]

            if not version and not deprecated then
                error('function "'..name..'" has neither -ver nor -deprecated.')
            end

            api_html:write('<div class="header">')
                if version then
                    if not version:find(' ') then
                        version = version..' and newer'
                    end
                    version = '<br/><div class="version">v'..version..'</div>'
                else
                    version = ''
                end
                api_html:write(' <div class="name">'..make_weblink(name)..'<a name="'..name..'">'..name..'</a></div>')
                if var then
                    api_html:write(' <div class="signature">'..var..' variable'..version..'</div>')
                else
                    if #arg > 0 then
                        arg = ' '..arg..' '
                    end
                    api_html:write(' <div class="signature">('..arg..') : '..ret..version..'</div>')
                end
            api_html:write('</div>') -- header

            api_html:write('<div class="body">')
                if deprecated then
                    api_html:write('<p class="desc"><strong>Deprecated; don\'t use this.</strong>')
                    if deprecated ~= "" then
                        api_html:write(' See <a href="#'..deprecated..'">'..deprecated..'</a> for more information.')
                    end
                    api_html:write('</p>')
                end
                for n = 1, doc_tag.desc_num, 1 do
                    local desc = table.concat(doc_tag["desc"..n] or {}, " ")
                    local show = table.concat(doc_tag["show"..n] or {}, "\n")
                    api_html:write('<p class="desc">'..desc..'</p>')
                    if #show > 0 then
                        api_html:write('<pre class="language-lua"><code>'..show..'</code></pre>')
                    end
                end
            api_html:write("</div>") -- body

            api_html:write("</div>") -- function
            api_html:write("<hr/>\n")
        end

        api_html:write("</div>") -- group
    end
    api_html:close()

    -- Expand out template.
    print("")
    print(">> " .. out_path)
    local tmp_file = io.open(tmp_path, "w")
    generate_file("docs/clink.html", tmp_file)
    tmp_file:close()

    -- Generate table of contents from H1 and H2 tags.
    local toc = io.open(".build/docs/toc_html", "w")
    for line in io.open(tmp_path, "r"):lines() do
        local tag, id, text = line:match('^ *<(h[12]) id="([^"]*)">(.*)</h')
        if tag then
            if text:match("<svg") then
                text = text:match("^<span.+/span>(.+)$")
            end
            toc:write('<div><a class="'..tag..'" href="#'..id..'">'..text..'</a></div>\n')
        end
    end
    toc:close()

    -- Expand out final documentation.
    local out_file = io.open(out_path, "w")
    generate_file(tmp_path, out_file, true--[[weblinks]])
    out_file:close()
    print("")
end



--------------------------------------------------------------------------------
newaction {
    trigger = "docs",
    description = "Clink: Generate Clink's documentation",
    execute = do_docs,
}
