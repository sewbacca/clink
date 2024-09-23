---@meta

---@class clink._argmatcher
_G._argmatcher = {}

--- v1.0.0 or newer
---
--- This adds a new argument position with the matches given by
--- <span class="arg">choices</span>.  Arguments can be a string, a string
--- linked to another parser by the concatenation operator, a table of
--- arguments, or a function that returns a table of arguments.  See
--- <a href="#argumentcompletion">Argument Completion</a> for more information.
--- ```lua
--- local my_parser = clink.argmatcher("make_color_shape")
--- :addarg("red", "green", "blue")             -- 1st argument is a color
--- :addarg("circle", "square", "triangle")     -- 2nd argument is a shape
--- ```
---@param ... string|table # choices
---@return clink._argmatcher
function _argmatcher:addarg(...) end

--- v1.3.3 or newer
---
--- This is the same as <a href="#_argmatcher:addarg">_argmatcher:addarg</a>
--- except that this disables sorting the matches.
---@param ... string|table # choices
---@return clink._argmatcher
function _argmatcher:addargunsorted(...) end

--- v1.2.38 or newer
---
--- Adds descriptions for arg matches and/or flag matches.  Descriptions are
--- displayed for their associated args or flags whenever possible completions
--- are listed, for example by the <code><a href="#rlcmd-complete">complete</a></code>
--- or <code><a href="#rlcmd-clink-select-complete">clink-select-complete</a></code>
--- or <code><a href="#rlcmd-possible-completions">possible-completions</a></code>
--- commands.</p><p class="desc">
--- Any number of descriptions tables may be passed to the function, and each
--- table must use one of the following schemes:
--- <ul>
--- <li>One or more string values that are args or flags, and a
--- <code>description</code> field that is the associated description string.
--- <li>Key/value pairs where each key is an arg or flag, and its value is
--- either a description string or a table containing an optional arguments
--- string and a description string.  If an arguments string is provided, it is
--- appended to the arg or flag string when listing possible completions.  For
--- example, <code>["--user"] = { " name", "Specify username"}</code> gets
--- printed as:</p><p class="desc">
--- <pre style="border-radius:initial;border:initial;background-color:black"><code class="plaintext" style="background-color:black">
--- <span style="color:#c0c0c0">--user</span> <span style="color:#808000">name</span>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#00ffff">Specify username</span>
--- </code></pre>
--- </ul></p><p class="desc">
--- ```lua
--- local foo = clink.argmatcher("foo")
--- foo:addflags("-h", "--help", "--user")
--- foo:addarg("info", "set")
--- -- Example using first scheme and one table per description:
--- foo:adddescriptions(
---    { "-h", "--help",   description = "Show help" },
---    { "--user",         description = "Specify user name" },
---    { "info",           description = "Prints information" },
---    { "set",            description = "Show or change settings" },
--- )
--- -- Example using second scheme and just one table:
--- foo:adddescriptions( {
---    ["-h"]              = "Show help",
---    ["--help"]          = "Show help",
---    ["--user"]          = { " name", "Specify user name" },
---    ["info"]            = { "Prints information" },
---    ["set"]             = { " var[=value]", "Show or change settings" },
--- } )
--- ```
---@param ... table # descriptions
---@return clink._argmatcher
---@overload fun(): clink._argmatcher
function _argmatcher:adddescriptions(...) end

--- v1.0.0 or newer
---
--- This adds flag matches.  Flags are separate from arguments:  When listing
--- possible completions for an empty word, only arguments are listed.  But when
--- the word being completed starts with the first character of any of the
--- flags, then only flags are listed.  See
--- <a href="#argumentcompletion">Argument Completion</a> for more information.
--- ```lua
--- local my_parser = clink.argmatcher("git")
--- :addarg({ "add", "status", "commit", "checkout" })
--- :addflags("-a", "-g", "-p", "--help")
--- ```
---@param ... string # flags
---@return clink._argmatcher
function _argmatcher:addflags(...) end

--- v1.3.3 or newer
---
--- This is the same as <a href="#_argmatcher:addflags">_argmatcher:addflags</a>
--- except that this also disables sorting for flags.
---@param ... string # flags
---@return clink._argmatcher
function _argmatcher:addflagsunsorted(...) end

--- v1.3.13 or newer
---
--- This makes the rest of the line be parsed as a separate command, after the
--- argmatcher reaches the end of its defined argument positions.  You can use
--- it to "chain" from one parser to another.</p><p class="desc">
--- For example, <code>cmd.exe program arg</code> is example of a line where one
--- command can have another command within it.  <code>:chaincommand()</code>
--- enables <code>program arg</code> to be parsed separately.  If
--- <code>program</code> has an argmatcher, then it takes over and parses the
--- rest of the input line.</p><p class="desc">
--- An example that chains in a linked argmatcher:
--- ```lua
--- clink.argmatcher("program"):addflags("/x", "/y")
--- clink.argmatcher("cmd"):addflags(
---    "/c" .. clink.argmatcher():chaincommand(),
---    "/k" .. clink.argmatcher():chaincommand()
--- ):nofiles()
--- -- Consider the following input:
--- --    cmd /c program /
--- -- "cmd" is colored as an argmatcher.
--- -- "/c" is colored as a flag (by the "cmd" argmatcher).
--- -- "program" is colored as an argmatcher.
--- -- "/" generates completions "/x" and "/y".
--- ```
---@return clink._argmatcher
function _argmatcher:chaincommand() end

--- v1.3.3 or newer
---
--- This hides the specified flags when displaying possible completions (the
--- flags are still recognized).</p><p class="desc">
--- This is intended for use when there are several synonyms for a flag, so that
--- input coloring and linked argmatchers work, without cluttering the possible
--- completion list.
--- ```lua
--- local dirs = clink.argmatcher():addarg(clink.dirmatches)
--- local my_parser = clink.argmatcher("mycommand")
--- :addflags("-a", "--a", "--al", "--all",
---          "-d"..dirs, "--d"..dirs, "--di"..dirs, "--dir"..dirs)
--- :hideflags("--a", "--al", "--all",      -- Only "-a" is displayed.
---           "-d", "--d", "--di")         -- Only "--dir" is displayed.
--- ```
---@param ... string # flags
---@return clink._argmatcher
function _argmatcher:hideflags(...) end

--- v0.4.9 or newer
---
--- This makes the parser loop back to argument position
--- <span class="arg">index</span> when it runs out of positional sets of
--- arguments (if <span class="arg">index</span> is omitted it loops back to
--- argument position 1).
--- ```lua
--- clink.argmatcher("xyzzy")
--- :addarg("zero", "cero")     -- first arg can be zero or cero
--- :addarg("one", "uno")       -- second arg can be one or uno
--- :addarg("two", "dos")       -- third arg can be two or dos
--- :loop(2)    -- fourth arg loops back to position 2, for one or uno, and so on
--- ```
---@param index integer
---@return clink._argmatcher
---@overload fun(): clink._argmatcher
function _argmatcher:loop(index) end

--- v1.0.0 or newer
---
--- This makes the parser prevent invoking <a href="#matchgenerators">match
--- generators</a>.  You can use it to "dead end" a parser and suggest no
--- completions.
---@return clink._argmatcher
function _argmatcher:nofiles() end

--- v1.3.10 or newer
---
--- Resets the argmatcher to an empty state.  All flags, arguments, and settings
--- are cleared and reset back to a freshly-created state.</p><p class="desc">
--- See <a href="#adaptive-argmatchers">Adaptive Argmatchers</a> for more
--- information.
---@return clink._argmatcher
function _argmatcher:reset() end

--- v1.1.18 or newer
---
--- This registers a function that gets called for each word the argmatcher
--- handles, to classify the word as part of coloring the input text.  See
--- <a href="#classifywords">Coloring the Input Text</a> for more information.
---@param func function
---@return clink._argmatcher
function _argmatcher:setclassifier(func) end

--- v1.3.10 or newer
---
--- This registers a function that gets called the first time the argmatcher is
--- used in each edit line session.  See
--- <a href="#adaptive-argmatchers">Adaptive Argmatchers</a> for more
--- information.
---@param func function
---@return clink._argmatcher
function _argmatcher:setdelayinit(func) end

--- v1.3.12 or newer
---
--- When <span class="arg">endofflags</span> is a string, it is a special flag
--- that signals the end of flags.  When <span class="arg">endflags</span> is
--- true or nil, then "<code>--</code>" is used as the end of flags string.
--- Otherwise, the end of flags string is cleared.
---@param endofflags string|boolean
---@return clink._argmatcher
---@overload fun(): clink._argmatcher
function _argmatcher:setendofflags(endofflags) end

--- v1.0.0 or newer
---
--- This is almost never needed, because <code>:addflags()</code> automatically
--- identifies flag prefix characters.</p><p class="desc">
--- However, any flags generated by functions can't influence the automatic
--- flag prefix character(s) detection.  So in some cases it may be necessary to
--- directly set the flag prefix.</p><p class="desc">
--- <strong>Note:</strong> <code>:setflagprefix()</code> behaves differently in
--- different versions of Clink:
--- <table>
--- <tr><th>Version</th><th>Description</th></tr>
--- <tr><td>v1.0.0 through v1.1.3</td><td>Sets the flag prefix characters.</td></tr>
--- <tr><td>v1.1.4 through v1.2.35</td><td>Only sets flag prefix characters in an argmatcher created using the deprecated <a href="#clink.arg.register_parser">clink.arg.register_parser()</a> function.  Otherwise it has no effect.</td></tr>
--- <tr><td>v1.2.36 through v1.3.8</td><td>Does nothing.</td></tr>
--- <tr><td>v1.3.9 onward</td><td>Adds flag prefix characters, in addition to the ones automatically identified.</td></tr>
--- </table>
--- ```lua
--- local function make_flags()
---    return { '-a', '-b', '-c' }
--- end
--- 
--- clink.argmatcher('some_command')
--- :addflags(make_flags)   -- Only a function is added, so flag prefix characters cannot be determined automatically.
--- :setflagprefix('-')     -- Force '-' to be considered as a flag prefix character.
--- ```
---@param ... string # prefixes
---@return clink._argmatcher
---@overload fun(): clink._argmatcher
function _argmatcher:setflagprefix(...) end

--- v1.3.12 or newer
---
--- When <span class="arg">anywhere</span> is false, flags are only recognized
--- until an argument is encountered.  Otherwise they are recognized anywhere
--- (which is the default).
---@param anywhere boolean
---@return clink._argmatcher
function _argmatcher:setflagsanywhere(anywhere) end

---@class clink.builder
_G.builder = {}

--- v1.0.0 or newer
---
--- Adds a match.</p><p class="desc">
--- The <span class="arg">match</span> argument is the match string to add.</p><p class="desc">
--- The <span class="arg">type</span> argument is the optional match type, or
--- "none" if omitted (see below for the possible match types).</p><p class="desc">
--- Alternatively, the <span class="arg">match</span> argument can be a table
--- with the following scheme:
--- ```lua
--- {
---    match           = "..."    -- [string] The match text.
---    display         = "..."    -- [string] OPTIONAL; alternative text to display when listing possible completions.
---    description     = "..."    -- [string] OPTIONAL; a description for the match.
---    type            = "..."    -- [string] OPTIONAL; the match type.
---    appendchar      = "..."    -- [string] OPTIONAL; character to append after the match.
---    suppressappend  = t_or_f   -- [boolean] OPTIONAL; whether to suppress appending a character after the match.
--- }
--- ```
---@param match string|table
---@param type string
---@return boolean
---@overload fun(match: string|table): boolean
function builder:addmatch(match, type) end

--- v1.0.0 or newer
---
--- This is the equivalent of calling <a href="#builder:addmatch">builder:addmatch()</a>
--- in a for-loop. Returns the number of matches added and a boolean indicating
--- if all matches were added successfully.</p><p class="desc">
--- The <span class="arg">matches</span> argument can be a table of match
--- strings, or a table of tables describing the matches.</p><p class="desc">
--- The <span class="arg">type</span> argument is used as the type when a match
--- doesn't explicitly include a type, and is "none" if omitted.
--- ```lua
--- builder:addmatches({"abc", "def"}) -- Adds two matches of type "none"
--- builder:addmatches({"abc", "def"}, "file") -- Adds two matches of type "file"
--- builder:addmatches({
---    -- Same table scheme per entry here as in builder:addmatch()
---    { match="remote/origin/master", type="word" },
---    { match="remote/origin/topic", type="word" }
--- })
--- ```
---@param matches table
---@param type string
---@return integer
---@return boolean
---@overload fun(matches: table): integer, boolean
function builder:addmatches(matches, type) end

--- v1.3.9 or newer
---
--- Returns whether the match builder is empty.  It is empty when no matches
--- have been added yet.
---@return boolean
function builder:isempty() end

--- v1.1.2 or newer
---
--- Sets character to append after matches.  For example the <code>set</code>
--- match generator uses this to append "=" when completing matches, so that
--- completing <code>set USER</code> becomes <code>set USERDOMAIN=</code>
--- (rather than <code>set USERDOMAIN&nbsp;</code>).
---@param append string
---@overload fun()
function builder:setappendcharacter(append) end

--- v1.4.19 or newer
---
--- Forces quoting rules to be applied to matches even if they aren't filenames.
function builder:setforcequoting() end

--- v1.3.3 or newer
---
--- Turns off sorting the matches.
function builder:setnosort() end

--- v1.1.2 or newer
---
--- Sets whether to suppress appending anything after the match except a
--- possible closing quote.  For example the env var match generator uses this.
---@param state boolean
---@overload fun()
function builder:setsuppressappend(state) end

--- v1.1.2 or newer
---
--- Sets whether to suppress quoting for the matches.  Set to 0 for normal
--- quoting, or 1 to suppress quoting, or 2 to suppress end quotes.  For example
--- the env var match generator sets this to 1 to overcome the quoting that
--- would normally happen for "%" characters in filenames.
---@param state integer
---@overload fun()
function builder:setsuppressquoting(state) end

--- v1.3.37 or newer
---
--- Forces the generated matches to be used only once.</p><p class="desc">
--- Normally Clink tries to reuse the most recently generated list of matches,
--- if possible.  It is an optimization, to avoid doing potentally expensive
--- work multiple times in a row to generate the same list of matches when
--- nothing has changed.  Normally the optimization is beneficial, and typing
--- more letters in a word can simply filter the existing list of matches.</p><p class="desc">
--- But sometimes an argument may have special syntax.  For example, an email
--- address argument might want to generate matches for names until the word
--- contains a <code>@</code>, and then it might want to generate matches for
--- domain names.  The optimization interferes with situations where parsing the
--- word produces a completely different list of possible matches.</p><p class="desc">
--- Making the generated matches volatile ensures matches are generated anew
--- each time completion is invoked.
function builder:setvolatile() end

---@class clink
_G.clink = {}

---@class clink.arg
_G.clink.arg = {}

--- v1.0.0 or newer
---
--- Creates and returns a new argument matcher parser object.  Use
--- <a href="#_argmatcher:addarg">:addarg()</a> and etc to add arguments, flags,
--- other parsers, and more.  See <a href="#argumentcompletion">Argument
--- Completion</a> for more information.</p><p class="desc">
--- If one <span class="arg">command</span> is provided and there is already an
--- argmatcher for it, then this returns the existing parser rather than
--- creating a new parser.  Using :addarg() starts at arg position 1, making it
--- possible to merge new args and etc into the existing parser.</p><p class="desc">
--- In Clink v1.3.38 and higher, if a <span class="arg">command</span> is a
--- fully qualified path, then it is only used when the typed command expands to
--- the same fully qualified path.  This makes it possible to create one
--- argmatcher for <code>c:\general\program.exe</code> and another for
--- <code>c:\special\program.exe</code>.  For example, aliases may be used to
--- make both programs runnable, or the system PATH might be changed temporarily
--- while working in a particular context.</p><p class="desc">
--- <strong>Note:</strong>  Merging <a href="#linked-parsers">linked
--- argmatchers</a> only merges the first argument position.  The merge is
--- simple, but should be sufficient for common simple cases.
---@param priority integer
---@param ... string # commands
---@return clink._argmatcher
---@overload fun(...: string): clink._argmatcher
function clink.argmatcher(priority, ...) end

--- v1.1.49 or newer
---
--- Creates and returns a new word classifier object.  Define on the object a
--- <code>:classify()</code> function which gets called in increasing
--- <span class="arg">priority</span> order (low values to high values) when
--- classifying words for coloring the input.  See
--- <a href="#classifywords">Coloring the Input Text</a> for more information.
---@param priority integer
---@return table
---@overload fun(): table
function clink.classifier(priority) end

--- v1.1.18 or newer
---
--- You can use this function in an argmatcher to supply directory matches.
--- This automatically handles Readline tilde completion.
--- ```lua
--- -- Make "cd" generate directory matches (no files).
--- clink.argmatcher("cd")
--- :addflags("/d")
--- :addarg({ clink.dirmatches })
--- ```
---@param word string
---@return table
function clink.dirmatches(word) end

--- v1.1.18 or newer
---
--- You can use this function in an argmatcher to supply file matches.  This
--- automatically handles Readline tilde completion.</p><p class="desc">
--- Argmatchers default to matching files, so it's unusual to need this
--- function.  However, some exceptions are when a flag needs to accept file
--- matches but other flags and arguments don't, or when matches need to include
--- more than files.
--- ```lua
--- -- Make "foo --file" generate file matches, but other flags and args don't.
--- -- And the third argument can be a file or $stdin or $stdout.
--- clink.argmatcher("foo")
--- :addflags(
---    "--help",
---    "--file"..clink.argmatcher():addarg({ clink.filematches })
--- )
--- :addarg({ "one", "won" })
--- :addarg({ "two", "too" })
--- :addarg({ clink.filematches, "$stdin", "$stdout" })
--- ```
---@param word string
---@return table
function clink.filematches(word) end

--- v1.0.0 or newer
---
--- Creates and returns a new match generator object.  Define on the object a
--- <code>:generate()</code> function which gets called in increasing
--- <span class="arg">priority</span> order (low values to high values) when
--- generating matches for completion.  See
--- <a href="#matchgenerators">Match Generators</a> for more information.
---@param priority integer
---@return table
---@overload fun(): table
function clink.generator(priority) end

--- v1.1.48 or newer
---
--- Returns up to two strings indicating who Clink thinks will currently handle
--- ANSI escape codes.</p><p class="desc">
--- The first returned string is the "current" handler.  This can change based
--- on the <code><a href="#terminal_emulation">terminal.emulation</a></code>
--- setting.</p><p class="desc">
--- Starting in v1.4.26 a second string can be returned which indicating the
--- "native" handler.  This is what Clink has detected as the terminal host and
--- is not affected by the `terminal.emulation` setting.</p><p class="desc">
--- The returned strings will always be <code>"unknown"</code> until the first
--- edit prompt (see <a href="#clink.onbeginedit">clink.onbeginedit()</a>).</p><p class="desc">
--- These can be useful in choosing what kind of ANSI escape codes to use, but
--- are a best guess and are not necessarily 100% reliable.</p><p class="desc">
--- <table>
--- <tr><th>Return</th><th>Description</th></tr>
--- <tr><td>"unknown"</td><td>Clink doesn't know.</td></tr>
--- <tr><td>"clink"</td><td>Clink is emulating ANSI support.  256 color and 24 bit color escape
--- codes are mapped to the nearest of the 16 basic colors.</td></tr>
--- <tr><td>"conemu"</td><td>Clink thinks ANSI escape codes will be handled by ConEmu.</td></tr>
--- <tr><td>"ansicon"</td><td>Clink thinks ANSI escape codes will be handled by ANSICON.</td></tr>
--- <tr><td>"winterminal"</td><td>Clink thinks ANSI escape codes will be handled by Windows
--- Terminal.</td></tr>
--- <tr><td>"wezterm"</td><td>Clink thinks ANSI escape codes will be handled by WezTerm.</td></tr>
--- <tr><td>"winconsole"</td><td>Clink thinks ANSI escape codes will be handled by the default
--- console support in Windows, but Clink detected a terminal replacement that won't support 256
--- color or 24 bit color.</td></tr>
--- <tr><td>"winconsolev2"</td><td>Clink thinks ANSI escape codes will be handled by the default
--- console support in Windows, or it might be handled by a terminal replacement that Clink
--- wasn't able to detect.</td></tr>
--- </table>
---@return string
function clink.getansihost() end

--- v1.3.12 or newer
---
--- Finds the argmatcher registered to handle a command, if any.</p><p class="desc">
--- When <span class="arg">find</span> is a string it is interpreted as the
--- name of a command, and this looks up the argmatcher for the named command.</p><p class="desc">
--- When <span class="arg">find</span> is a <a href="#line_state">line_state</a>
--- this looks up the argmatcher for the command line.</p><p class="desc">
--- If no argmatcher is found, this returns nil.
---@param find string|clink.line_state
---@return clink._argmatcher|nil
function clink.getargmatcher(find) end

--- v1.4.0 or newer
---
--- Returns the default popup colors in a table with the following scheme:
--- ```lua
--- {
--- items   = "...",    -- The SGR parameters for the items color.
--- desc    = "...",    -- The SGR parameters for the description color.
--- }
--- ```
---@return table
function clink.getpopuplistcolors() end

--- v1.1.44 or newer
---
--- Returns the current Clink session id.</p><p class="desc">
--- This is needed when using
--- <a href="https://www.lua.org/manual/5.2/manual.html#pdf-io.popen">io.popen()</a>
--- (or similar functions) to invoke <code>clink history</code> or <code>clink
--- info</code> while Clink is installed for autorun.  The popen API spawns a
--- new CMD.exe, which gets a new Clink instance injected, so the history or
--- info command will use the new session unless explicitly directed to use the
--- calling session.
--- ```lua
--- local c = os.getalias("clink")
--- local r = io.popen(c.." --session "..clink.getsession().." history")
--- ```
---@return string
function clink.getsession() end

--- v0.4.9 or newer
---
--- This API correctly converts UTF8 strings to lowercase, with international
--- linguistic awareness.
--- ```lua
--- clink.lower("Hello World") -- returns "hello world"
--- clink.lower("ÁÈÏõû")       -- returns "áèïõû"
--- ```
---@param text string
---@return string
function clink.lower(text) end

--- v1.2.50 or newer
---
--- Registers <span class="arg">func</span> to be called after every editing
--- command (key binding).
---@param func function
function clink.onaftercommand(func) end

--- v1.1.11 or newer
---
--- Registers <span class="arg">func</span> to be called when Clink's edit
--- prompt is activated.  The function receives no arguments and has no return
--- values.</p><p class="desc">
--- Starting in v1.3.18 <span class="arg">func</span> may optionally return a
--- string.  If a string is returned, it is executed as a command line without
--- showing a prompt and without invoking the input line editor.</p><p class="desc">
--- <strong>Note:</strong>  Be very careful if you return a string; this has the
--- potential to interfere with the user's ability to use CMD.  Mistakes in the
--- command string can have the potential to cause damage to the system very
--- quickly.  It is also possible for a script to cause an infinite loop, and
--- therefore <kbd>Ctrl</kbd>-<kbd>Break</kbd> causes the next string to be
--- ignored.
---@param func function
function clink.onbeginedit(func) end

--- v1.3.12 or newer
---
--- Registers <span class="arg">func</span> to be called when the command word
--- changes in the edit line.</p><p class="desc">
--- The function receives 2 arguments:  the <a href="#line_state">line_state</a>
--- for the command, and a table with the following scheme:
--- ```lua
--- {
---    command =   -- [string] The command.
---    quoted  =   -- [boolean] Whether the command is quoted in the command line.
---    type    =   -- [string] "unrecognized", "executable", or "command" (a CMD command name).
---    file    =   -- [string] The file that would be executed, or an empty string.
--- }
--- ```
---@param func function
function clink.oncommand(func) end

--- v1.1.12 or newer
---
--- Registers <span class="arg">func</span> to be called when Clink is about to
--- display matches.  See <a href="#filteringthematchdisplay">Filtering the
--- Match Display</a> for more information.
--- ```lua
--- local function my_filter(matches, popup)
---    local new_matches = {}
---    for _,m in ipairs(matches) do
---        if m.match:find("[0-9]") then
---            -- Ignore matches with one or more digits.
---        else
---            -- Keep the match, and also add * prefix to directory matches.
---            if m.type:find("^dir") then
---                m.display = "*"..m.match
---            end
---            table.insert(new_matches, m)
---        end
---    end
---    return new_matches
--- end
--- 
--- function my_match_generator:generate(line_state, match_builder)
---    ...
---    clink.ondisplaymatches(my_filter)
--- end
--- ```
---@param func function
function clink.ondisplaymatches(func) end

--- v1.1.20 or newer
---
--- Registers <span class="arg">func</span> to be called when Clink's edit
--- prompt ends.  The function receives a string argument containing the input
--- text from the edit prompt.</p><p class="desc">
--- <strong>Breaking Change in v1.2.16:</strong>  The ability to replace the
--- user's input has been moved to a separate
--- <a href="#clink.onfilterinput">onfilterinput</a> event.
---@param func function
function clink.onendedit(func) end

--- v1.2.16 or newer
---
--- Registers <span class="arg">func</span> to be called after Clink's edit
--- prompt ends (it is called after the <a href="#clink.onendedit">onendedit</a>
--- event).  The function receives a string argument containing the input text
--- from the edit prompt.  The function returns up to two values.  If the first
--- is not nil then it's a string that replaces the edit prompt text.  If the
--- second is not nil and is false then it stops further onfilterinput handlers
--- from running.</p><p class="desc">
--- Starting in v1.3.13 <span class="arg">func</span> may return a table of
--- strings, and each is executed as a command line.</p><p class="desc">
--- <strong>Note:</strong>  Be very careful if you replace the text; this has
--- the potential to interfere with or even ruin the user's ability to enter
--- command lines for CMD to process.
---@param func function
function clink.onfilterinput(func) end

--- v1.1.41 or newer
---
--- Registers <span class="arg">func</span> to be called after Clink generates
--- matches for completion.  See <a href="#filteringmatchcompletions">
--- Filtering Match Completions</a> for more information.
---@param func function
function clink.onfiltermatches(func) end

--- v1.1.21 or newer
---
--- Registers <span class="arg">func</span> to be called when Clink is injected
--- into a CMD process.  The function is called only once per session.
---@param func function
function clink.oninject(func) end

--- v1.4.18 or newer
---
--- Registers <span class="arg">func</span> to be called after an editing
--- command (key binding) makes changes in the input line.</p><p class="desc">
--- The function receives one argument, a <span class="arg">line</span> string
--- which contains the new contents of the input line.</p><p class="desc">
--- The function has no return values.</p><p class="desc">
--- Here is a script that demonstrates a lighthearted example of how this could
--- be used.  Any time the input line contains "marco" it replaces the prompt
--- with "POLO!".
--- ```lua
--- local has_marco
--- local polo = clink.promptfilter(-1)
--- 
--- function polo:filter()
---    if has_marco then
---        return "\x1b[44;96mPOLO!\x1b[m ", false
---    end
--- end
--- 
--- local function onbeginedit()
---    has_marco = nil
--- end
--- 
--- local function oninputlinechanged(line)
---    local new_marco = line:find("marco") and true
---    if has_marco ~= new_marco then
---        has_marco = new_marco
---        clink.refilterprompt()
---    end
--- end
--- 
--- clink.onbeginedit(onbeginedit)
--- clink.oninputlinechanged(oninputlinechanged)
--- 
--- function clink.oninputlinechanged(func)
---    _add_event_callback("oninputlinechanged", func)
--- end
--- ```
---@param func function
function clink.oninputlinechanged(func) end

--- v1.3.18 or newer
---
--- Registers <span class="arg">func</span> to be called after the
--- <a href="#clink.onbeginedit">onbeginedit</a> event but before the input line
--- editor starts.  If <span class="arg">func</span> returns a string, it is
--- executed as a command line without showing a prompt.  The input line editor
--- is skipped, and the <a href="#clink.onendedit">onendedit</a> and
--- <a href="#clink.onfilterinput">onfilterinput</a> events happen immediately.</p><p class="desc">
--- <strong>Note:</strong>  Be very careful when returning a string; this can
--- interfere with the user's ability to use CMD.  Mistakes in the command
--- string can have potential to cause damage to the system very quickly.  It is
--- also possible for a script to cause an infinite loop, and therefore
--- <kbd>Ctrl</kbd>-<kbd>Break</kbd> skips the next
--- <a href="#clink.onprovideline">onprovideline</a> event, allowing the user
--- to regain control.
---@param func function
function clink.onprovideline(func) end

--- v1.3.37 or newer
---
--- This parses the <span class="arg">line</span> string into a table of
--- commands, with one <a href="#line_state">line_state</a> for each command
--- parsed from the line string.</p><p class="desc">
--- The returned table of tables has the following scheme:
--- ```lua
--- local commands = clink.parseline("echo hello & echo world")
--- -- commands[1].line_state corresponds to "echo hello".
--- -- commands[2].line_state corresponds to "echo world".
--- ```
---@param line string
---@return table
function clink.parseline(line) end

--- v1.2.17 or newer
---
--- Displays a popup list and returns the selected item.  May only be used
--- within a <a href="#luakeybindings">luafunc: key binding</a> or inside a
--- function registered with
--- <a href="#clink.onfiltermatches">clink.onfiltermatches()</a>.</p><p class="desc">
--- <span class="arg">title</span> is required and captions the popup list.</p><p class="desc">
--- <span class="arg">items</span> is a table of strings to display.</p><p class="desc">
--- <span class="arg">index</span> optionally specifies the default item (or 1
--- if omitted).</p><p class="desc">
--- <span class="arg">del_callback</span> optionally specifies a callback
--- function to be called when <kbd>Del</kbd> is pressed.  The function receives
--- the index of the selected item.  If the function returns true then the item
--- is deleted from the popup list.  This requires Clink v1.3.41 or higher.</p><p class="desc">
--- The function returns one of the following:
--- <ul>
--- <li>nil if the popup is canceled or an error occurs.
--- <li>Three values:
--- <ul>
--- <li>string indicating the <code>value</code> field from the selected item
--- (or the <code>display</code> field if no value field is present).
--- <li>boolean which is true if the item was selected with <kbd>Shift</kbd> or
--- <kbd>Ctrl</kbd> pressed.
--- <li>integer indicating the index of the selected item in the original
--- <span class="arg">items</span> table.
--- </ul>
--- </ul></p><p class="desc">
--- Alternatively, the <span class="arg">items</span> argument can be a table of
--- tables with the following scheme:
--- ```lua
--- {
---    {
---        value       = "...",   -- Required; this is returned if the item is chosen.
---        display     = "...",   -- Optional; displayed instead of value.
---        description = "...",   -- Optional; displayed in a dimmed color in a second column.
---    },
---    ...
--- }
--- ```
---@param title string
---@param items table
---@param index integer
---@param del_callback function
---@return string
---@return boolean
---@return integer
---@overload fun(title: string, items: table, index: integer): string, boolean, integer
---@overload fun(title: string, items: table, del_callback: function): string, boolean, integer
---@overload fun(title: string, items: table): string, boolean, integer
function clink.popuplist(title, items, index, del_callback) end

--- v1.2.11 or newer
---
--- This works like
--- <a href="https://www.lua.org/manual/5.2/manual.html#pdf-print">print()</a>,
--- but this supports ANSI escape codes and Unicode.</p><p class="desc">
--- If the special value <code>NONL</code> is included anywhere in the argument
--- list then the usual trailing newline is omitted.  This can sometimes be
--- useful particularly when printing certain ANSI escape codes.</p><p class="desc">
--- <strong>Note:</strong>  In Clink versions before v1.2.11 the
--- <code>clink.print()</code> API exists (undocumented) but accepts exactly one
--- string argument and is therefore not fully compatible with normal
--- <a href="https://www.lua.org/manual/5.2/manual.html#pdf-print">print()</a>
--- syntax.  If you use fewer or more than 1 argument or if the argument is not
--- a string, then first checking the Clink version (e.g.
--- <a href="#clink.version_encoded">clink.version_encoded</a>) can avoid
--- runtime errors.
--- ```lua
--- clink.print("\x1b[32mgreen\x1b[m \x1b[35mmagenta\x1b[m")
--- -- Outputs "green" in green, a space, and "magenta" in magenta.
--- 
--- local a = "hello"
--- local world = 73
--- clink.print("a", a, "world", world)
--- -- Outputs "a       hello   world   73".
--- 
--- clink.print("hello", NONL)
--- clink.print("world")
--- -- Outputs "helloworld".
--- ```
---@param ... any
function clink.print(...) end

--- v1.2.10 or newer
---
--- Creates a coroutine to run the <span class="arg">func</span> function in the
--- background.  Clink will automatically resume the coroutine repeatedly while
--- input line editing is idle.  When the <span class="arg">func</span> function
--- completes, Clink will automatically refresh the prompt by triggering prompt
--- filtering again.</p><p class="desc">
--- A coroutine is only created the first time each prompt filter calls this API
--- during a given input line session.  Subsequent calls reuse the
--- already-created coroutine.  (E.g. pressing <kbd>Enter</kbd> ends an input
--- line session.)</p><p class="desc">
--- The API returns nil until the <span class="arg">func</span> function has
--- finished.  After that, the API returns whatever the
--- <span class="arg">func</span> function returned.  The API returns one value;
--- if multiple return values are needed, return them in a table.</p><p class="desc">
--- If the <code><a href="#prompt_async">prompt.async</a></code> setting is
--- disabled, then the coroutine runs to completion immediately before
--- returning.  Otherwise, the coroutine runs during idle while editing the
--- input line.  The <span class="arg">func</span> function receives one
--- argument: true if it's running in the background, or false if it's running
--- immediately.</p><p class="desc">
--- See <a href="#asyncpromptfiltering">Asynchronous Prompt Filtering</a> for
--- more information.</p><p class="desc">
--- <strong>Note:</strong> each prompt filter can have at most one prompt
--- coroutine.
---@generic T
---@param func function
---@return T?
function clink.promptcoroutine(func) end

--- v1.0.0 or newer
---
--- Creates and returns a new promptfilter object that is applied in increasing
--- <span class="arg">priority</span> order (low values to high values).  Define
--- on the object a <code>:filter()</code> function that takes a string argument
--- which contains the filtered prompt so far.  The function can return nil to
--- have no effect, or can return a new prompt string.  It can optionally stop
--- further prompt filtering by also returning false.  See
--- <a href="#customisingtheprompt">Customizing the Prompt</a> for more
--- information.
--- ```lua
--- local foo_prompt = clink.promptfilter(80)
--- function foo_prompt:filter(prompt)
---    -- Insert the date at the beginning of the prompt.
---    return os.date("%a %H:%M").." "..prompt
--- end
--- ```
---@param priority integer
---@return table
---@overload fun(): table
function clink.promptfilter(priority) end

--- v1.3.9 or newer
---
--- Reclassify the input line text again and refresh the input line display.
function clink.reclassifyline() end

--- v1.3.38 or newer
---
--- This reports the input line coloring word classification to use for a
--- command word.  The return value can be passed into
--- <a href="#word_classifications:classifyword">word_classifications:classifyword()</a>
--- as its <span class="arg">word_class</span> argument.</p><p class="desc">
--- This is intended for advanced input line coloring purposes.  For example if
--- a script uses <a href="#clink.onfilterinput">clink.onfilterinput()</a> to
--- modify the input text, then it can use this function inside a custom
--- <a href="#classifier_override_line">classifier</a> to look up the color
--- appropriate for the modified input text.</p><p class="desc">
--- The <span class="arg">line</span> is optional and may be an empty string or
--- omitted.  When present, it is parsed to check if it would be processed as a
--- <a href="#directory-shortcuts">directory shortcut</a>.</p><p class="desc">
--- The <span class="arg">word</span> is a string indicating the word to be
--- analyzed.</p><p class="desc">
--- The <span class="arg">quoted</span> is optional.  When true, it indicates
--- the word is quoted and any <code>^</code> characters are taken as-is,
--- rather than treating them as the usual CMD escape character.</p><p class="desc">
--- The possible return values for <span class="arg">word_class</span> are:</p><p class="desc">
--- <table>
--- <tr><th>Code</th><th>Classification</th><th>Clink Color Setting</th></tr>
--- <tr><td><code>"x"</code></td><td>Executable; used for the first word when it is not a command or doskey alias, but is an executable name that exists.</td><td><code><a href="#color_executable">color.executable</a></code></td></tr>
--- <tr><td><code>"u"</code></td><td>Unrecognized; used for the first word when it is not a command, doskey alias, or recognized executable name.</td><td><code><a href="#color_unrecognized">color.unrecognized</a></code></td></tr>
--- <tr><td><code>"o"</code></td><td>Other; used for file names and words that don't fit any of the other classifications.</td><td><code><a href="#color_input">color.input</a></code></td></tr>
--- </table></p><p class="desc">
--- The possible return values for <span class="arg">ready</span> are:</p><p class="desc">
--- <ul>
--- <li>True if the analysis has completed.</li>
--- <li>False if the analysis has not yet completed (and the returned word class
--- may be a temporary placeholder).</li>
--- </ul></p><p class="desc">
--- The return value for <span class="arg">file</span> is the fully qualified
--- path to the found executable file, if any, or nil.</p><p class="desc">
--- <strong>Note:</strong>  This always returns immediately, and it uses a
--- background thread to analyze the <span class="arg">word</span> asynchronously.
--- When the background thread finishes analyzing the word, Clink automatically
--- redisplays the input line, giving classifiers a chance to call this function
--- again and get the final <span class="arg">word_class</span> result.
---@param line string
---@param word string
---@param quoted boolean
---@return string
---@return boolean
---@return string
---@overload fun(line: string, word: string): string, boolean, string
---@overload fun(word: string, quoted: boolean): string, boolean, string
---@overload fun(word: string): string, boolean, string
function clink.recognizecommand(line, word, quoted) end

--- v1.4.0 or newer
---
--- Call this with <span class="arg">refilter</span> either nil or true to make
--- Clink automatically rerun prompt filters after the terminal is resized.  The
--- previous value is returned.</p><p class="desc">
--- On Windows the terminal is resized while the console program in the terminal
--- (such as CMD) continues to run.  If a console program writes to the terminal
--- while the resize is happening, then the terminal display can become garbled.
--- So Clink waits until the terminal has stayed the same size for at least 1.5
--- seconds, and then it reruns the prompt filters.</p><p class="desc">
--- <strong>Use this with caution:</strong>  if the prompt filters have not been
--- designed efficiently, then rerunning them after resizing the terminal could
--- cause responsiveness problems.  Also, if the terminal is resized again while
--- the prompt filters are being rerun, then the terminal display may become
--- garbled.
---@param refilter boolean
---@return boolean
function clink.refilterafterterminalresize(refilter) end

--- v1.2.46 or newer
---
--- Invoke the prompt filters again and refresh the prompt.</p><p class="desc">
--- Note: this can potentially be expensive; call this only infrequently.
function clink.refilterprompt() end

--- v1.2.29 or newer
---
--- Reloads Lua scripts and Readline config file at the next prompt.
function clink.reload() end

--- v1.3.5 or newer
---
--- By default, a coroutine is canceled if it doesn't complete before an edit
--- line ends.  In some cases it may be necessary for a coroutine to run until
--- it completes, even if it spans multiple edit lines.</p><p class="desc">
--- <strong>Note:</strong>  Use with caution.  This can potentially cause
--- performance problems or cause prompt filtering to experience delays.
---@param coroutine thread
function clink.runcoroutineuntilcomplete(coroutine) end

--- v1.3.1 or newer
---
--- Overrides the interval at which a coroutine is resumed.  All coroutines are
--- automatically added with an interval of 0 by default, so calling this is
--- only needed when you want to change the interval.</p><p class="desc">
--- Coroutines are automatically resumed while waiting for input while editing
--- the input line.</p><p class="desc">
--- If a coroutine's interval is less than 5 seconds and the coroutine has been
--- alive for more than 5 seconds, then the coroutine is throttled to run no
--- more often than once every 5 seconds (regardless how much total time is has
--- spent running).  Throttling is meant to prevent long-running coroutines from
--- draining battery power, interfering with responsiveness, or other potential
--- problems.
---@param coroutine thread
---@param interval number
---@overload fun(coroutine: thread)
function clink.setcoroutineinterval(coroutine, interval) end

--- v1.3.1 or newer
---
--- Sets a name for the coroutine.  This is purely for diagnostic purposes.
---@param coroutine thread
---@param name string
function clink.setcoroutinename(coroutine, name) end

--- v1.2.47 or newer
---
--- Creates and returns a new suggester object.  Suggesters are consulted in the
--- order their names are listed in the
--- <code><a href="#autosuggest.strategy">autosuggest.strategy</a></code>
--- setting.</p><p class="desc">
--- Define on the object a <code>:suggest()</code> function that takes a
--- <a href="#line_state">line_state</a> argument which contains the input line,
--- and a <a href="#matches">matches</a> argument which contains the possible
--- completions.  The function can return nil to give the next suggester a
--- chance, or can return a suggestion (or an empty string) to stop looking for
--- suggestions.</p><p class="desc">
--- In Clink v1.2.51 and higher, the function may return a suggestion and an
--- offset where the suggestion begins in the line.  This is useful if the
--- suggester wants to be able to insert the suggestion using the original
--- casing.  For example if you type "set varn" and a history entry is "set
--- VARNAME" then returning <code>"set VARNAME", 1</code> or
--- <code>"VARNAME", 5</code> can accept "set VARNAME" instead of "set varnAME".</p><p class="desc">
--- See <a href="#customisingsuggestions">Customizing Suggestions</a> for more
--- information.
--- ```lua
--- local doskeyarg = clink.suggester("doskeyarg")
--- function doskeyarg:suggest(line, matches)
---    if line:getword(1) == "doskey" and
---            line:getline():match("[ \t][^ \t/][^ \t]+=") and
---            not line:getline():match("%$%*") then
---        -- If the line looks like it defines a macro and doesn't yet add all
---        -- arguments, suggest adding all arguments.
---        if line:getline():sub(#line:getline()) == " " then
---            return "$*"
---        else
---            return " $*"
---        end
---    end
--- end
--- ```
---@param name string
---@return table
function clink.suggester(name) end

--- v1.2.7 or newer
---
--- This overrides how Clink translates slashes in completion matches, which is
--- normally determined by the
--- <code><a href="#match_translate_slashes">match.translate_slashes</a></code>
--- setting.</p><p class="desc">
--- This is reset every time match generation is invoked, so use a generator to
--- set this.</p><p class="desc">
--- The <span class="arg">mode</span> specifies how to translate slashes when
--- generators add matches:
--- <table>
--- <tr><th>Mode</th><th>Description</th></tr>
--- <tr><td><code>0</code></td><td>No translation.</td></tr>
--- <tr><td><code>1</code></td><td>Translate using the system path separator (backslash on Windows).</td></tr>
--- <tr><td><code>2</code></td><td>Translate to slashes (<code>/</code>).</td></tr>
--- <tr><td><code>3</code></td><td>Translate to backslashes (<code>\</code>).</td></tr>
--- </table></p><p class="desc">
--- If <span class="arg">mode</span> is omitted, then the function returns the
--- current slash translation mode without changing it.</p><p class="desc">
--- Note:  Clink always generates file matches using the system path separator
--- (backslash on Windows), regardless what path separator may have been typed
--- as input.  Setting this to <code>0</code> does not disable normalizing typed
--- input paths when invoking completion; it only disables translating slashes
--- in custom generators.
--- ```lua
--- -- This example affects all match generators, by using priority -1 to
--- -- run first and returning false to let generators continue.
--- -- To instead affect only one generator, call clink.translateslashes()
--- -- in its :generate() function and return true.
--- local force_slashes = clink.generator(-1)
--- function force_slashes:generate()
---    clink.translateslashes(2)  -- Convert to slashes.
---    return false               -- Allow generators to continue.
--- end
--- ```
---@param mode integer
---@return integer
---@overload fun(): integer
function clink.translateslashes(mode) end

--- v1.1.5 or newer
---
--- This API correctly converts UTF8 strings to uppercase, with international
--- linguistic awareness.
--- ```lua
--- clink.upper("Hello World") -- returns "HELLO WORLD"
--- clink.lower("áèïÕÛ")       -- returns "ÁÈÏÕÛ"
--- ```
---@param text string
---@return string
function clink.upper(text) end

--- v1.1.10 or newer
---
--- The commit part of the Clink version number.
--- For v1.2.3.<strong>a0f14d</strong> the commit part is a0f14d.
---@type string
_G.clink.version_commit = ""

--- v1.1.10 or newer
---
--- The Clink version number encoded as a single integer following the format
--- <span class="arg">Mmmmpppp</span> where <span class="arg">M</span> is the
--- major part, <span class="arg">m</span> is the minor part, and
--- <span class="arg">p</span> is the patch part of the version number.</p><p class="desc">
--- For example, Clink v95.6.723 would be <code>950060723</code>.</p><p class="desc">
--- This format makes it easy to test for feature availability by encoding
--- version numbers from the release notes.
---@type integer
_G.clink.version_encoded = 0

--- v1.1.10 or newer
---
--- The major part of the Clink version number.
--- For v<strong>1</strong>.2.3.a0f14d the major version is 1.
---@type integer
_G.clink.version_major = 0

--- v1.1.10 or newer
---
--- The minor part of the Clink version number.
--- For v1.<strong>2</strong>.3.a0f14d the minor version is 2.
---@type integer
_G.clink.version_minor = 0

--- v1.1.10 or newer
---
--- The patch part of the Clink version number.
--- For v1.2.<strong>3</strong>.a0f14d the patch version is 3.
---@type integer
_G.clink.version_patch = 0

---@class clink.console
_G.console = {}

--- v1.2.5 or newer
---
--- Returns the count of visible character cells that would be consumed if the
--- <span class="arg">text</span> string were output to the console, accounting
--- for any ANSI escape codes that may be present in the text.</p><p class="desc">
--- Note: backspace characters and line endings are counted as visible character
--- cells and will skew the resulting count.
---@param text string
---@return integer
function console.cellcount(text) end

--- v1.3.42 or newer
---
--- Checks whether input is available.</p><p class="desc">
--- The optional <span class="arg">timeout</span> is the number of seconds to
--- wait for input to be available (use a floating point number for fractional
--- seconds).  The default is 0 seconds, which returns immediately if input is
--- not available.</p><p class="desc">
--- If input is available before the <span class="arg">timeout</span> is
--- reached, the return value is true.  Use
--- <a href="#console.readinput">console.readinput()</a> to read the available
--- input.</p><p class="desc">
--- <strong>Note:</strong> Mouse input is not supported.
--- ```lua
--- if console.checkinput() then
---    local key = console.readinput() -- Returns immediately since input is available.
---    if key == "\x03" or key == "\x1b[27;27~" or key == "\x1b" then
---        -- Ctrl-C or ESC was pressed.
---    end
--- end
--- ```
---@param timeout number
---@return boolean
---@overload fun(): boolean
function console.checkinput(timeout) end

--- v1.1.21 or newer
---
--- Searches downwards (forwards) for a line containing the specified text
--- and/or attributes, starting at line <span class="arg">starting_line</span>.
--- The matching line number is returned, or 0 if no matching line is found.</p><p class="desc">
--- This behaves the same as
--- <a href="#console.findprevline">console.findprevline()</a> except that it
--- searches in the opposite direction.
---@param starting_line integer
---@param text string
---@param mode string
---@param attr integer | integer[]
---@param mask string
---@return integer
---@overload fun(starting_line: integer, text: string, mode: string, attr: integer | integer[]): integer
---@overload fun(starting_line: integer, text: string, mode: string, mask: string): integer
---@overload fun(starting_line: integer, text: string, mode: string): integer
---@overload fun(starting_line: integer, text: string, attr: integer | integer[], mask: string): integer
---@overload fun(starting_line: integer, text: string, attr: integer | integer[]): integer
---@overload fun(starting_line: integer, text: string, mask: string): integer
---@overload fun(starting_line: integer, text: string): integer
---@overload fun(starting_line: integer, mode: string, attr: integer | integer[], mask: string): integer
---@overload fun(starting_line: integer, mode: string, attr: integer | integer[]): integer
---@overload fun(starting_line: integer, mode: string, mask: string): integer
---@overload fun(starting_line: integer, mode: string): integer
---@overload fun(starting_line: integer, attr: integer | integer[], mask: string): integer
---@overload fun(starting_line: integer, attr: integer | integer[]): integer
---@overload fun(starting_line: integer, mask: string): integer
---@overload fun(starting_line: integer): integer
function console.findnextline(starting_line, text, mode, attr, mask) end

--- v1.1.21 or newer
---
--- Searches upwards (backwards) for a line containing the specified text and/or
--- attributes, starting at line <span class="arg">starting_line</span>.  The
--- matching line number is returned, or 0 if no matching line is found, or -1
--- if an invalid regular expression is provided.</p><p class="desc">
--- You can search for text, attributes, or both.  Include the
--- <span class="arg">text</span> argument to search for text, and include
--- either the <span class="arg">attr</span> or <span class="arg">attrs</span>
--- argument to search for attributes.  If both text and attribute(s) are
--- passed, then the attribute(s) must be found within the found text.  If only
--- attribute(s) are passed, then they must be found anywhere in the line.  See
--- <a href="#console.linehascolor">console.linehascolor()</a> for more
--- information about the color codes.</p><p class="desc">
--- The <span class="arg">mode</span> argument selects how the search behaves.
--- To use a regular expression, pass "regex".  To use a case insensitive
--- search, pass "icase".  These can be combined by separating them with a
--- comma.  The regular expression syntax is the ECMAScript syntax described
--- <a href="https://docs.microsoft.com/en-us/cpp/standard-library/regular-expressions-cpp">here</a>.</p><p class="desc">
--- Any trailing whitespace is ignored when searching.  This especially affects
--- the <code>$</code> (end of line) regex operator.</p><p class="desc">
--- <span class="arg">mask</span> is optional and can be "fore" or "back" to
--- only match foreground or background colors, respectively.</p><p class="desc">
--- <strong>Note:</strong> Although most of the arguments are optional, the
--- order of provided arguments is important.</p><p class="desc">
--- For more information, see <a href="#findlineexample">this example</a> of
--- using this in some <a href="#luakeybindings">luafunc: macros</a>.
---@param starting_line integer
---@param text string
---@param mode string
---@param attr integer | integer[]
---@param mask string
---@return integer
---@overload fun(starting_line: integer, text: string, mode: string, attr: integer | integer[]): integer
---@overload fun(starting_line: integer, text: string, mode: string, mask: string): integer
---@overload fun(starting_line: integer, text: string, mode: string): integer
---@overload fun(starting_line: integer, text: string, attr: integer | integer[], mask: string): integer
---@overload fun(starting_line: integer, text: string, attr: integer | integer[]): integer
---@overload fun(starting_line: integer, text: string, mask: string): integer
---@overload fun(starting_line: integer, text: string): integer
---@overload fun(starting_line: integer, mode: string, attr: integer | integer[], mask: string): integer
---@overload fun(starting_line: integer, mode: string, attr: integer | integer[]): integer
---@overload fun(starting_line: integer, mode: string, mask: string): integer
---@overload fun(starting_line: integer, mode: string): integer
---@overload fun(starting_line: integer, attr: integer | integer[], mask: string): integer
---@overload fun(starting_line: integer, attr: integer | integer[]): integer
---@overload fun(starting_line: integer, mask: string): integer
---@overload fun(starting_line: integer): integer
function console.findprevline(starting_line, text, mode, attr, mask) end

--- v1.4.28 or newer
---
--- Returns the current cursor column and row in the console screen buffer.
--- The row is between 1 and <a href="#console.getnumlines">console.getnumlines()</a>.
--- The column is between 1 and <a href="#console.getwidth">console.getwidth()</a>.
--- ```lua
--- local x, y = console.getcursorpos()
--- ```
---@return integer
---@return integer
function console.getcursorpos() end

--- v1.1.20 or newer
---
--- Returns the number of visible lines of the console screen buffer.
---@return integer
function console.getheight() end

--- v1.1.20 or newer
---
--- Returns the text from line number <span class="arg">line</span>, from 1 to
--- <a href="#console.getnumlines">console.getnumlines()</a>.</p><p class="desc">
--- Any trailing whitespace is stripped before returning the text.
---@param line integer
---@return string
function console.getlinetext(line) end

--- v1.1.20 or newer
---
--- Returns the total number of lines in the console screen buffer.
---@return integer
function console.getnumlines() end

--- v1.1.32 or newer
---
--- Returns the console title text.
---@return string
function console.gettitle() end

--- v1.1.20 or newer
---
--- Returns the current top line (scroll position) in the console screen buffer.
---@return integer
function console.gettop() end

--- v1.1.20 or newer
---
--- Returns the width of the console screen buffer in characters.
---@return integer
function console.getwidth() end

--- v1.1.20 or newer
---
--- Returns whether line number <span class="arg">line</span> uses only the
--- default text color.
---@param line integer
---@return boolean
function console.islinedefaultcolor(line) end

--- v1.1.21 or newer
---
--- Returns whether line number <span class="arg">line</span> contains the DOS
--- color code <span class="arg">attr</span>, or any of the DOS color codes in
--- <span class="arg">attrs</span> (either an integer or a table of integers
--- must be provided, but not both).  <span class="arg">mask</span> is optional
--- and can be "fore" or "back" to only match foreground or background colors,
--- respectively.</p><p class="desc">
--- The low 4 bits of the color code are the foreground color, and the high 4
--- bits of the color code are the background color.  This refers to the default
--- 16 color palette used by console windows.  When 256 color or 24-bit color
--- ANSI escape codes have been used, the closest of the 16 colors is used.</p><p class="desc">
--- To build a color code, add the corresponding Foreground color and the
--- Background color values from this table:</p><p class="desc">
--- <table><tr><th align="center">Foreground</th><th align="center">Background</th><th>Color</th></tr>
--- <tr><td align="center">0</td><td align="center">0</td><td><div class="colorsample" style="background-color:#000000">&nbsp;</div> Black</td></tr>
--- <tr><td align="center">1</td><td align="center">16</td><td><div class="colorsample" style="background-color:#000080">&nbsp;</div> Dark Blue</td></tr>
--- <tr><td align="center">2</td><td align="center">32</td><td><div class="colorsample" style="background-color:#008000">&nbsp;</div> Dark Green</td></tr>
--- <tr><td align="center">3</td><td align="center">48</td><td><div class="colorsample" style="background-color:#008080">&nbsp;</div> Dark Cyan</td></tr>
--- <tr><td align="center">4</td><td align="center">64</td><td><div class="colorsample" style="background-color:#800000">&nbsp;</div> Dark Red</td></tr>
--- <tr><td align="center">5</td><td align="center">80</td><td><div class="colorsample" style="background-color:#800080">&nbsp;</div> Dark Magenta</td></tr>
--- <tr><td align="center">6</td><td align="center">96</td><td><div class="colorsample" style="background-color:#808000">&nbsp;</div> Dark Yellow</td></tr>
--- <tr><td align="center">7</td><td align="center">112</td><td><div class="colorsample" style="background-color:#c0c0c0">&nbsp;</div> Gray</td></tr>
--- <tr><td align="center">8</td><td align="center">128</td><td><div class="colorsample" style="background-color:#808080">&nbsp;</div> Dark Gray</td></tr>
--- <tr><td align="center">9</td><td align="center">144</td><td><div class="colorsample" style="background-color:#0000ff">&nbsp;</div> Bright Blue</td></tr>
--- <tr><td align="center">10</td><td align="center">160</td><td><div class="colorsample" style="background-color:#00ff00">&nbsp;</div> Bright Green</td></tr>
--- <tr><td align="center">11</td><td align="center">176</td><td><div class="colorsample" style="background-color:#00ffff">&nbsp;</div> Bright Cyan</td></tr>
--- <tr><td align="center">12</td><td align="center">192</td><td><div class="colorsample" style="background-color:#ff0000">&nbsp;</div> Bright Red</td></tr>
--- <tr><td align="center">13</td><td align="center">208</td><td><div class="colorsample" style="background-color:#ff00ff">&nbsp;</div> Bright Magenta</td></tr>
--- <tr><td align="center">14</td><td align="center">224</td><td><div class="colorsample" style="background-color:#ffff00">&nbsp;</div> Bright Yellow</td></tr>
--- <tr><td align="center">15</td><td align="center">240</td><td><div class="colorsample" style="background-color:#ffffff">&nbsp;</div> White</td></tr>
--- </table>
---@param line integer
---@param attr integer
---@param attrs integer[]
---@param mask string
---@return boolean
---@overload fun(line: integer, attr: integer, attrs: integer[]): boolean
---@overload fun(line: integer, attr: integer, mask: string): boolean
---@overload fun(line: integer, attr: integer): boolean
---@overload fun(line: integer, attrs: integer[], mask: string): boolean
---@overload fun(line: integer, attrs: integer[]): boolean
---@overload fun(line: integer, mask: string): boolean
---@overload fun(line: integer): boolean
function console.linehascolor(line, attr, attrs, mask) end

--- v1.2.5 or newer
---
--- Returns the input <span class="arg">text</span> with ANSI escape codes
--- removed, and the count of visible character cells that would be consumed
--- if the text were output to the console.</p><p class="desc">
--- Note: backspace characters and line endings are counted as visible character
--- cells and will skew the resulting count.
---@param text string
---@return string
---@return integer
function console.plaintext(text) end

--- v1.2.29 or newer
---
--- Reads one key sequence from the console input.  If no input is available, it
--- waits until input becomes available.</p><p class="desc">
--- This returns the full key sequence string for the pressed key.
--- For example, <kbd>A</kbd> is <code>"A"</code> and <kbd>Home</kbd> is
--- <code>"\027[A"</code>, etc.  Nil is returned when an interrupt occurs by
--- pressing <kbd>Ctrl</kbd>-<kbd>Break</kbd>.</p><p class="desc">
--- See <a href="#discoverkeysequences">Discovering Key Sequences</a> for
--- information on how to find the key sequence for a key.</p><p class="desc">
--- In Clink v1.3.42 and higher, passing true for
--- <span class="arg">no_cursor</span> avoids modifying the cursor visibility or
--- position.</p><p class="desc">
--- <strong>Note:</strong> Mouse input is not supported.
---@param no_cursor boolean
---@return string | nil
function console.readinput(no_cursor) end

--- v1.1.40 or newer
---
--- Uses the provided Lua string patterns to collect text from the current
--- console screen and returns a table of matching text snippets.  The snippets
--- are ordered by distance from the input line.</p><p class="desc">
--- For example <span class="arg">candidate_pattern</span> could specify a
--- pattern that identifies words, and <span class="arg">accept_pattern</span>
--- could specify a pattern that matches words composed of hexadecimal digits.
--- ```lua
--- local matches = console.screengrab(
---        "[^%w]*(%w%w[%w]+)",   -- Words with 3 or more letters are candidates.
---        "^%x+$")               -- A candidate containing only hexadecimal digits is a match.
--- ```
---@param candidate_pattern string
---@param accept_pattern string
---@return table
function console.screengrab(candidate_pattern, accept_pattern) end

--- v1.1.20 or newer
---
--- Scrolls the console screen buffer and returns the number of lines scrolled
--- up (negative) or down (positive).</p><p class="desc">
--- The <span class="arg">mode</span> specifies how to scroll:
--- <table>
--- <tr><th>Mode</th><th>Description</th></tr>
--- <tr><td>"line"</td><td>Scrolls by <span class="arg">amount</span> lines;
--- negative is up and positive is down.</td></tr>
--- <tr><td>"page"</td><td>Scrolls by <span class="arg">amount</span> pages;
--- negative is up and positive is down.</td></tr>
--- <tr><td>"end"</td><td>Scrolls to the top if <span class="arg">amount</span>
--- is negative, or to the bottom if positive.</td></tr>
--- <tr><td>"absolute"</td><td>Scrolls to line <span class="arg">amount</span>,
--- from 1 to <a href="#console.getnumlines">console.getnumlines()</a>.</td></tr>
--- </table>
---@param mode string
---@param amount integer
---@return integer
function console.scroll(mode, amount) end

--- v1.1.32 or newer
---
--- Sets the console title text.
---@param title string
function console.settitle(title) end

--- v0.0.1 or newer
---
--- This function opens a file named by <span class="arg">filename</span>, in
--- the mode specified in the string <span class="arg">mode</span>.  It returns
--- a new file handle, or, in case of errors, nil plus an error message and
--- error number.</p><p class="desc">
--- The <span class="arg">mode</span> string can be any of the following:
--- <ul>
--- <li><code>"r"</code>: read mode (the default);
--- <li><code>"w"</code>: write mode;
--- <li><code>"wx"</code>: write mode, but fail if the file already exists (requires v1.3.18 or higher);
--- <li><code>"a"</code>: append mode;
--- <li><code>"r+"</code>: update mode, all previous data is preserved;
--- <li><code>"w+"</code>: update mode, all previous data is erased;
--- <li><code>"w+x"</code>: update mode, all previous data is erased, but fail if the file already exists (requires v1.3.18 or higher);
--- <li><code>"a+"</code>: append update mode, previous data is preserved, writing is only allowed at the end of file.
--- </ul></p><p class="desc">
--- The <span class="arg">mode</span> string can also have a <code>'b'</code> at
--- the end to open the file in binary mode.</p><p class="desc">
--- The <code>'x'</code> modes are Clink extensions to Lua.
---@param filename string
---@param mode string
---@return file*
---@overload fun(filename: string): file*
function io.open(filename, mode) end

--- v1.1.42 or newer
---
--- Runs <span class="arg">command</span> and returns two file handles:  a file
--- handle for reading output from the command, and a file handle for writing
--- input to the command.</p><p class="desc">
--- <span class="arg">mode</span> can be "t" for text mode (the default if
--- omitted) or "b" for binary mode.</p><p class="desc">
--- If the function fails it returns nil, an error message, and an error number.</p><p class="desc">
--- <fieldset><legend>Warning</legend>
--- This can result in deadlocks unless the command fully reads all of its input
--- before writing any output.  This is because Lua uses blocking IO to read and
--- write file handles.  If the write buffer fills (or the read buffer is empty)
--- then the write (or read) will block and can only become unblocked if the
--- command correspondingly reads (or writes).  But the other command can easily
--- experience the same blocking IO problem on its end, resulting in a deadlock:
--- process 1 is blocked from writing more until process 2 reads, but process 2
--- can't read because it is blocked from writing until process 1 reads.
--- </fieldset>
--- ```lua
--- local r,w = io.popenrw("fzf.exe --height 40%")
--- 
--- w:write("hello\n")
--- w:write("world\n")
--- w:close()
--- 
--- while (true) do
---    local line = r:read("*line")
---    if not line then
---        break
---    end
---    print(line)
--- end
--- r:close()
--- ```
---@param command string
---@param mode string
---@return file*
---@return file*
---@overload fun(command: string): file*, file*
function io.popenrw(command, mode) end

--- v1.2.10 or newer
---
--- This behaves similar to
--- <a href="https://www.lua.org/manual/5.2/manual.html#pdf-io.popen">io.popen()</a>
--- except that it only supports read mode and when used in a coroutine it
--- yields until the command has finished.</p><p class="desc">
--- The <span class="arg">command</span> argument is the command to run.</p><p class="desc">
--- The <span class="arg">mode</span> argument is the optional mode to use.  It
--- can contain "r" (read mode) and/or either "t" for text mode (the default if
--- omitted) or "b" for binary mode.  Write mode is not supported, so it cannot
--- contain "w".</p><p class="desc">
--- This runs the specified command and returns a read file handle for reading
--- output from the command.  It yields until the command has finished and the
--- complete output is ready to be read without blocking.</p><p class="desc">
--- In v1.3.31 and higher, it may also return a function.  If the second return
--- value is a function then it can be used to get the exit status for the
--- command.  The function returns the same values as
--- <a href="https://www.lua.org/manual/5.2/manual.html#pdf-os.execute">os.execute()</a>.
--- The function may be used only once, and it closes the read file handle, so
--- if the function is used then do not use <code>file:close()</code>.  Or, if
--- the second return value is not a function, then the exit status may be
--- retrieved from calling <code>file:close()</code> on the returned file handle.</p><p class="desc">
--- <strong>Compatibility Note:</strong> when <code>io.popen()</code> is used in
--- a coroutine, it is automatically redirected to <code>io.popenyield()</code>.
--- This means on success the second return value from <code>io.popen()</code>
--- in a coroutine may not be nil as callers might normally expect.</p><p class="desc">
--- <strong>Note:</strong> if the
--- <code><a href="#prompt_async">prompt.async</a></code> setting is disabled,
--- or while a <a href="#transientprompts">transient prompt filter</a> is
--- executing, or if used outside of a coroutine, then this behaves like
--- <a href="https://www.lua.org/manual/5.2/manual.html#pdf-io.popen">io.popen()</a>
--- instead.
--- ```lua
--- local file = io.popenyield("git status")
--- 
--- while (true) do
---    local line = file:read("*line")
---    if not line then
---        break
---    end
---    do_things_with(line)
--- end
--- file:close()
--- ```
---@param command string
---@param mode string
---@return file*
---@return function (see remarks below)
---@overload fun(command: string): file*, function (see remarks below)
function io.popenyield(command, mode) end

--- v1.3.18 or newer
---
--- This is the same as <a href="#io.open">io.open()</a>, but adds an optional
--- <code>deny</code> argument that specifies the type of sharing allowed.</p><p class="desc">
--- This function opens a file named by <span class="arg">filename</span>, in
--- the mode specified in the string <span class="arg">mode</span>.  It returns
--- a new file handle, or, in case of errors, nil plus an error message and
--- error number.</p><p class="desc">
--- The <span class="arg">mode</span> string can be any of the following:
--- <ul>
--- <li><code>"r"</code>: read mode (the default);
--- <li><code>"w"</code>: write mode;
--- <li><code>"wx"</code>: write mode, but fail if the file already exists;
--- <li><code>"a"</code>: append mode;
--- <li><code>"r+"</code>: update mode, all previous data is preserved;
--- <li><code>"w+"</code>: update mode, all previous data is erased;
--- <li><code>"w+x"</code>: update mode, all previous data is erased, but fail if the file already exists;
--- <li><code>"a+"</code>: append update mode, previous data is preserved, writing is only allowed at the end of file.
--- </ul></p><p class="desc">
--- The <span class="arg">mode</span> string can also have a <code>'b'</code> at
--- the end to open the file in binary mode.</p><p class="desc">
--- The <span class="arg">deny</span> string can be any of the following:
--- <ul>
--- <li><code>"r"</code> denies read access;
--- <li><code>"w"</code> denies write access;
--- <li><code>"rw"</code> denies read and write access;
--- <li><code>""</code> permits read and write access (the default).
--- </ul>
---@param filename string
---@param mode string
---@param deny string
---@return file*
---@overload fun(filename: string, mode: string): file*
---@overload fun(filename: string, deny: string): file*
---@overload fun(filename: string): file*
function io.sopen(filename, mode, deny) end

--- v1.3.41 or newer
---
--- This function truncates the <span class="arg">file</span> previously opened
--- by <a href="#io.open">io.open()</a> or <a href="#io.sopen">io.sopen()</a>.
--- When used on a pipe or other file handle that doesn't refer to an actual
--- file, the behavior is undefined.</p><p class="desc">
--- If successful, the return value is true. If an error occurs, the return value 
--- is false, an error message, and an error code.
---@param file file*
---@return boolean
function io.truncate(file) end

---@class clink.line_state
_G.line_state = {}

--- v1.0.0 or newer
---
--- Returns the offset to the start of the delimited command in the line that's
--- being effectively edited. Note that this may not be the offset of the first
--- command of the line unquoted as whitespace isn't considered for words.
--- ```lua
--- -- Given the following line; abc&123
--- -- where commands are separated by & symbols.
--- line_state:getcommandoffset() == 5
--- ```
---@return integer
function line_state:getcommandoffset() end

--- v1.2.27 or newer
---
--- Returns the index of the command word. Usually the index is 1, but if a
--- redirection symbol occurs before the command name then the index can be
--- greater than 1.
--- ```lua
--- -- Given the following line; >x abc
--- -- the first word is "x" and is an argument to the redirection symbol,
--- -- and the second word is "abc" and is the command word.
--- line_state:getcommandwordindex() == 2
--- ```
---@return integer
function line_state:getcommandwordindex() end

--- v1.0.0 or newer
---
--- Returns the position of the cursor.
---@return integer
function line_state:getcursor() end

--- v1.0.0 or newer
---
--- Returns the last word of the line. This is the word that matches are being
--- generated for.</p><p class="desc">
--- <strong>Note:</strong>  The returned word omits any quotes.  This helps
--- generators naturally complete <code>"foo\"ba</code> to
--- <code>"foo\bar"</code>.  The raw word including quotes can be obtained using
--- the <code>offset</code> and <code>length</code> fields from
--- <a href="#line_state:getwordinfo">line_state:getwordinfo()</a> to extract a
--- substring from the line returned by
--- <a href="#line_state:getline">line_state:getline()</a>.
--- ```lua
--- line_state:getword(line_state:getwordcount()) == line_state:getendword()
--- ```
---@return string
function line_state:getendword() end

--- v1.0.0 or newer
---
--- Returns the current line in its entirety.
---@return string
function line_state:getline() end

--- v1.0.0 or newer
---
--- Returns the word of the line at <span class="arg">index</span>.</p><p class="desc">
--- <strong>Note:</strong>  The returned word omits any quotes.  This helps
--- generators naturally complete <code>"foo\"ba</code> to
--- <code>"foo\bar"</code>.  The raw word including quotes can be obtained using
--- the <code>offset</code> and <code>length</code> fields from
--- <a href="#line_state:getwordinfo">line_state:getwordinfo()</a> to extract a
--- substring from the line returned by
--- <a href="#line_state:getline">line_state:getline()</a>.</p><p class="desc">
--- <strong>However:</strong>  During
--- <code><a href="#the-getwordbreakinfo-function">generator:getwordbreakinfo()</a></code>
--- functions the returned word includes quotes, otherwise word break offsets
--- could be garbled.
---@param index integer
---@return string
function line_state:getword(index) end

--- v1.0.0 or newer
---
--- Returns the number of words in the current line.
---@return integer
function line_state:getwordcount() end

--- v1.0.0 or newer
---
--- Returns a table of information about the Nth word in the line.</p><p class="desc">
--- Note:  The length refers to the substring in the line; it omits leading and
--- trailing quotes, but <em><strong>includes</strong></em> embedded quotes.
--- <a href="#line_state:getword">line_state:getword()</a> conveniently strips
--- embedded quotes to help generators naturally complete <code>"foo\"ba</code>
--- to <code>"foo\bar"</code>.</p><p class="desc">
--- The table returned has the following scheme:
--- ```lua
--- local t = line_state:getwordinfo(word_index)
--- -- t.offset     [integer] Offset where the word starts in the line_state:getline() string.
--- -- t.length     [integer] Length of the word (includes embedded quotes).
--- -- t.quoted     [boolean] Indicates whether the word is quoted.
--- -- t.delim      [string] The delimiter character, or an empty string.
--- -- t.alias      [boolean | nil] true if the word is a doskey alias, otherwise nil.
--- -- t.redir      [boolean | nil] true if the word is a redirection arg, otherwise nil.
--- ```
---@param index integer
---@return table
function line_state:getwordinfo(index) end

---@class clink.log
_G.log = {}

--- v1.4.15 or newer
---
--- Returns the file name of the current session's log file.
---@return string | nil
function log.getfile() end

--- v1.1.3 or newer
---
--- Writes info <span class="arg">message</span> to the Clink log file.  Use
--- this sparingly, or it could cause performance problems or disk space
--- problems.</p><p class="desc">
--- In v1.4.10 and higher, the optional <span class="arg">level</span> number
--- tells which stack level to log as the source of the log message (default is
--- 1, the function calling <code>log.info</code>).
---@param message string
---@param level integer
---@overload fun(message: string)
function log.info(message, level) end

---@class clink.matches
_G.matches = {}

--- v1.2.47 or newer
---
--- Returns the number of available matches.
---@return integer
function matches:getcount() end

--- v1.2.47 or newer
---
--- Returns the match text for the <span class="arg">index</span> match.
---@param index integer
---@return string
function matches:getmatch(index) end

--- v1.2.47 or newer
---
--- Returns the longest common prefix of the available matches.
---@return string
function matches:getprefix() end

--- v1.2.47 or newer
---
--- Returns the match type for the <span class="arg">index</span> match.
---@param index integer
---@return string
function matches:gettype(index) end

--- v1.4.1 or newer
---
--- This abbreviates parent directories in <span class="arg">path</span> to the
--- shortest string that uniquely identifies the directory.  The drive, if
--- present, is never abbreviated.  By default, the first and last names in the
--- string are not abbreviated.</p><p class="desc">
--- For performance reasons, UNC paths and paths on remote or removeable drives
--- are never abbreviated.</p><p class="desc">
--- The return value is the resulting path after abbreviation.</p><p class="desc">
--- If an optional <span class="arg">decide</span> function is provided then
--- it is called once for each directory name in <span class="arg">path</span>,
--- and it can control which directories get abbreviated.  The
--- <span class="arg">decide</span> function receives one argument: the path to
--- the directory that may be abbreviated.  The function can return true to try
--- to abbreviate the directory, or false to prevent abbreviating the directory,
--- or nil to allow the default behavior (don't abbreviate the first or last
--- directory names).</p><p class="desc">
--- If an optional <span class="arg">transform</span> function is provided then
--- it is called once for each directory name in the resulting string.  The
--- <span class="arg">transform</span> function receives two arguments: the
--- string to be appended, and a boolean indicating whether it has been
--- abbreviated.  The function can adjust the string, and should return a string
--- to appended.  If it returns nil, the string is appended as-is.  This is
--- intended to be able to apply ANSI escape color codes, for example to
--- highlight special directories or to show which directory names have been
--- abbreviated.</p><p class="desc">
--- This function can potentially take some time to complete, but it can be
--- called in a coroutine and yields appropriately.  It is the caller's
--- responsibility to ensure that any <span class="arg">decide</span> or
--- <span class="arg">transform</span> functions are either very fast, yield
--- appropriately, or are not used from a coroutine.
--- ```lua
--- -- Suppose only the following directories exist in the D:\xyz directory:
--- --  - D:\xyz\bag
--- --  - D:\xyz\bookkeeper
--- --  - D:\xyz\bookkeeping
--- --  - D:\xyz\box
--- --  - D:\xyz\boxes
--- --  - D:\xyz\nonrepo
--- --  - D:\xyz\repo
--- 
--- os.abbreviatepath("d:\\xyz")                        -- returns "d:\\xyz"
--- os.abbreviatepath("d:\\xyz\\bag")                   -- returns "d:\\xyz\\bag"
--- os.abbreviatepath("d:\\xyz\\bag\\subdir")           -- returns "d:\\xyz\\ba\\subdir"
--- os.abbreviatepath("d:\\xyz\\bookkeeper")            -- returns "d:\\xyz\\bookkeeper"
--- os.abbreviatepath("d:\\xyz\\bookkeeper\\subdir")    -- returns "d:\\xyz\\bookkeepe\\subdir"
--- os.abbreviatepath("d:\\xyz\\bookkeeping\\file")     -- returns "d:\\xyz\\bookkeepi\\file"
--- os.abbreviatepath("d:\\xyz\\box\\subdir")           -- returns "d:\\xyz\\box\\subdir"
--- os.abbreviatepath("d:\\xyz\\boxes\\file")           -- returns "d:\\xyz\\boxe\\file"
--- 
--- -- Examples with a `decide` function.
--- 
--- local function not_git_dir(dir)
---    if os.isdir(path.join(dir, ".git")) then
---        return false -- Don't abbreviate git repo directories.
---    end
--- end
--- 
--- os.abbreviatepath("d:\\xyz\\nonrepo\\subdir", not_git_dir)  -- returns "d:\\xyz\\n\\subdir"
--- os.abbreviatepath("d:\\xyz\\repo\\subdir", not_git_dir)     -- returns "d:\\xyz\\repo\\subdir"
--- 
--- -- Example with a `decide` function and a `transform` function.
--- 
--- local function do_all(dir)
---    return true
--- end
--- 
--- local function dim_abbrev(name, abbrev)
---    if abbrev then
---        return "\027[38m"..name.."\027[m" -- Use dark gray text.
---    else
---        return name
---    end
--- end
--- 
--- os.abbreviatepath("d:\\xyz\\bag", do_all, dim_abbrev)
--- -- returns "c:\\\027[38mx\027[m\\\027[38mba\027[m"
--- 
--- -- Relative paths work as well.
--- 
--- os.chdir("d:\\xyz")
--- os.abbreviatesetcurrentdir("bag\\subdir", true)     -- returns "ba\\s" (if "subdir" is unique)
--- ```
---@param path string
---@param decide function
---@param transform function
---@return string
---@overload fun(path: string, decide: function): string
---@overload fun(path: string, transform: function): string
---@overload fun(path: string): string
function os.abbreviatepath(path, decide, transform) end

--- v1.0.0 or newer
---
--- Changes the current directory to <span class="arg">path</span> and returns
--- whether it was successful.
--- If unsuccessful it returns false, an error message, and the error number.
---@param path string
---@return boolean
function os.chdir(path) end

--- v1.2.30 or newer
---
--- This returns the number of seconds since the program started.</p><p class="desc">
--- Normally, Lua's os.clock() has millisecond precision until the program has
--- been running for almost 25 days, and then it suddenly breaks and starts
--- always returning -0.001 seconds.</p><p class="desc">
--- Clink's version of os.clock() has microsecond precision until the program
--- has been running for many weeks.  It maintains at least millisecond
--- precision until the program has been running for many years.</p><p class="desc">
--- It was necessary to replace os.clock() in order for
--- <a href="#asyncpromptfiltering">asynchronous prompt filtering</a> to
--- continue working when CMD has been running for more than 25 days.
---@return number
function os.clock() end

--- v1.0.0 or newer
---
--- Copies the <span class="arg">src</span> file to the
--- <span class="arg">dest</span> file.
--- If unsuccessful it returns false, an error message, and the error number.
---@param src string
---@param dest string
---@return boolean
function os.copy(src, dest) end

--- v1.1.42 or newer
---
--- Creates a uniquely named file, intended for use as a temporary file.  The
--- name pattern is "<em>location</em> <code>\</code> <em>prefix</em>
--- <code>_</code> <em>processId</em> <code>_</code> <em>uniqueNum</em>
--- <em>extension</em>".</p><p class="desc">
--- <span class="arg">prefix</span> optionally specifies a prefix for the file
--- name and defaults to "tmp".</p><p class="desc">
--- <span class="arg">ext</span> optionally specifies a suffix for the file name
--- and defaults to "" (if <span class="arg">ext</span> starts with a period "."
--- then it is a filename extension).</p><p class="desc">
--- <span class="arg">path</span> optionally specifies a path location in which
--- to create the file.  The default is the system TEMP directory.</p><p class="desc">
--- <span class="arg">mode</span> optionally specifies "t" for text mode (line
--- endings are translated) or "b" for binary mode (untranslated IO).  The
--- default is "t".</p><p class="desc">
--- When successful, the function returns a file handle and the file name.
--- If unsuccessful it returns nil, an error message, and the error number.</p><p class="desc">
--- <strong>Note:</strong> Be sure to delete the file when finished, or it will
--- be leaked.
---@param prefix string
---@param ext string
---@param path string
---@param mode string
---@return file*
---@return string
---@overload fun(prefix: string, ext: string, path: string): file*, string
---@overload fun(prefix: string, ext: string, mode: string): file*, string
---@overload fun(prefix: string, ext: string): file*, string
---@overload fun(prefix: string, path: string, mode: string): file*, string
---@overload fun(prefix: string, path: string): file*, string
---@overload fun(prefix: string, mode: string): file*, string
---@overload fun(prefix: string): file*, string
---@overload fun(ext: string, path: string, mode: string): file*, string
---@overload fun(ext: string, path: string): file*, string
---@overload fun(ext: string, mode: string): file*, string
---@overload fun(ext: string): file*, string
---@overload fun(path: string, mode: string): file*, string
---@overload fun(path: string): file*, string
---@overload fun(mode: string): file*, string
---@overload fun(): file*, string
function os.createtmpfile(prefix, ext, path, mode) end

--- v1.2.20 or newer
---
--- This works like
--- <a href="https://www.lua.org/manual/5.2/manual.html#pdf-print">print()</a>
--- but writes the output via the OS <code>OutputDebugString()</code> API.</p><p class="desc">
--- This function has no effect if the
--- <code><a href="#lua_debug">lua.debug</a></code> Clink setting is off.
--- ```lua
--- clink.debugprint("my variable = "..myvar)
--- ```
---@param ... any
function os.debugprint(...) end

--- v1.4.1 or newer
---
--- This expands any abbreviated directory components in
--- <span class="arg">path</span>.</p><p class="desc">
--- The return value is nil if <span class="arg">path</span> couldn't be
--- expanded.  It can't be expanded if it is a UNC path or a remote drive, or if
--- it is already expanded, or if there are no matches for one of the directory
--- components.</p><p class="desc">
--- Otherwise three values are returned.  First, a string containing the
--- expanded part of <span class="arg">path</span>.  Second, a string containing
--- the rest of <span class="arg">path</span> that wasn't expanded.  Third, a
--- boolean indicating whether <span class="arg">path</span> was able to expand
--- uniquely.
--- ```lua
--- -- Suppose only the following directories exist in the D: drive:
--- --  - D:\bag
--- --  - D:\bookkeeper
--- --  - D:\bookkeeping
--- --  - D:\box
--- --  - D:\boxes
--- 
--- expanded, remaining, unique = os.expandabbreviatedpath("d:\\b\\file")
--- -- returns "d:\\b", "\\file", false         -- Ambiguous.
--- 
--- expanded, remaining, unique = os.expandabbreviatedpath("d:\\ba\\file")
--- -- returns "d:\\bag", "\\file", true        -- Unique; only "bag" can match "ba".
--- 
--- expanded, remaining, unique = os.expandabbreviatedpath("d:\\bo\\file")
--- -- returns "d:\\bo", "\\file", false        -- Ambiguous.
--- 
--- expanded, remaining, unique = os.expandabbreviatedpath("d:\\boo\\file")
--- -- returns "d:\\bookkeep", "\\file", false  -- Ambiguous; "bookkeep" is longest common part matching "boo".
--- 
--- expanded, remaining, unique = os.expandabbreviatedpath("d:\\box\\file")
--- -- returns "d:\\box", "\\file", false       -- Ambiguous; "box" is an exact match.
--- 
--- expanded, remaining, unique = os.expandabbreviatedpath("d:\\boxe\\file")
--- -- returns "d:\\boxes", "\\file", true      -- Unique; only "boxes" can match "boxe".
--- 
--- expanded, remaining, unique = os.expandabbreviatedpath("d:\\boxes\\file")
--- -- returns nil                              -- Is already expanded.
--- ```
---@param path string
---@return nil | string
---@return string
---@return boolean
function os.expandabbreviatedpath(path) end

--- v1.2.5 or newer
---
--- Returns <span class="arg">value</span> with any <code>%name%</code>
--- environment variables expanded.  Names are case insensitive.  Special CMD
--- syntax is not supported (e.g. <code>%name:str1=str2%</code> or
--- <code>%name:~offset,length%</code>).</p><p class="desc">
--- Note: See <a href="#os.getenv">os.getenv()</a> for a list of special
--- variable names.
---@param value string
---@return string
function os.expandenv(value) end

--- v1.1.4 or newer
---
--- Returns command string for doskey alias <span class="arg">name</span>, or
--- nil if the named alias does not exist.
---@param name string
---@return string | nil
function os.getalias(name) end

--- v1.0.0 or newer
---
--- Returns doskey alias names in a table of strings.
---@return table
function os.getaliases() end

--- v1.1.17 or newer
---
--- Returns a table containing the battery status for the device, or nil if an
--- error occurs.  The returned table has the following scheme:
--- ```lua
--- local t = os.getbatterystatus()
--- -- t.level              [integer] The battery life from 0 to 100, or -1 if error or no battery.
--- -- t.acpower            [boolean] Whether the device is connected to AC power.
--- -- t.charging           [boolean] Whether the battery is charging.
--- -- t.batterysaver       [boolean] Whether Battery Saver mode is active.
--- ```
---@return table
function os.getbatterystatus() end

--- v1.2.32 or newer
---
--- This returns the text from the system clipboard, or nil if there is no text
--- on the system clipboard.
---@return string | nil
function os.getclipboardtext() end

--- v1.0.0 or newer
---
--- Returns the current directory.
---@return string
function os.getcwd() end

--- v1.3.37 or newer
---
--- Returns the drive type for the drive associated with the specified
--- <span class="arg">path</span>.</p><p class="desc">
--- Relative paths automatically use the current drive.  Absolute paths use the
--- specified drive.  UNC paths are always reported as remote drives.</p><p class="desc">
--- The possible drive types are:
--- <p><table>
--- <tr><th>Type</th><th>Description</th></tr>
--- <tr><td>"unknown"</td><td>The drive type could not be determined.</td></tr>
--- <tr><td>"invalid"</td><td>The drive type is invalid; for example, there is no volume mounted at the specified path.</td></tr>
--- <tr><td>"removable"</td><td>Floppy disk drive, thumb drive, flash card reader, CD-ROM, etc.</td></tr>
--- <tr><td>"fixed"</td><td>Hard drive, solid state drive, etc.</td></tr>
--- <tr><td>"ramdisk"</td><td>RAM disk.</td></tr>
--- <tr><td>"remote"</td><td>Remote (network) drive.</td></tr>
--- </table></p>
--- ```lua
--- local t = os.getdrivetype("c:")
--- if t == "remote" then
---    -- Network paths are often slow, and code may want to detect and skip them.
--- end
--- ```
---@param path string
---@return string
function os.getdrivetype(path) end

--- v1.0.0 or newer
---
--- Returns the value of the named environment variable, or nil if it doesn't
--- exist.</p><p class="desc">
--- Note: Certain environment variable names receive special treatment:</p><p class="desc">
--- <table>
--- <tr><th>Name</th><th>Special Behavior</th></tr>
--- <tr><td><code>"CD"</code></td><td>If %CD% is not set then a return value
--- is synthesized from the current working directory path name.</td></tr>
--- <tr><td><code>"CMDCMDLINE"</code></td><td>If %CMDCMDLINE% is not set then
--- this returns the command line that started the CMD process.</td></tr>
--- <tr><td><code>"ERRORLEVEL"</code></td><td>If %ERRORLEVEL% is not set and the
--- <code><a href="#cmd_get_errorlevel">cmd.get_errorlevel</a></code>
--- setting is enabled this returns the most recent exit code, just like the
--- <code>echo %ERRORLEVEL%</code> command displays.  Otherwise this returns
--- 0.</td></tr>
--- <tr><td><code>"HOME"</code></td><td>If %HOME% is not set then a return value
--- is synthesized from %HOMEDRIVE% and %HOMEPATH%, or from
--- %USERPROFILE%.</td></tr>
--- <tr><td><code>"RANDOM"</code></td><td>If %RANDOM% is not set then this
--- returns a random integer.</td></tr>
--- </table>
---@param name string
---@return string | nil
function os.getenv(name) end

--- v1.0.0 or newer
---
--- Returns all environment variables in a table with the following scheme:
--- ```lua
--- local t = os.getenvnames()
--- -- t[index].name        [string] The environment variable's name.
--- -- t[index].value       [string] The environment variable's value.
--- ```
---@return table
function os.getenvnames() end

--- v1.2.14 or newer
---
--- Returns the last command's exit code, if the
--- <code><a href="#cmd_get_errorlevel">cmd.get_errorlevel</a></code> setting is
--- enabled.  Otherwise it returns 0.
---@return integer
function os.geterrorlevel() end

--- v1.4.17 or newer
---
--- This tries to get a Windows file version info resource from the specified
--- file.  It tries to get translated strings in the closest available language
--- to the current user language configured in the OS.</p><p class="desc">
--- If successful, the returned table contains as many of the following fields
--- as were available in the file's version info resource.
--- ```lua
--- local info = os.getfileversion("c:/windows/notepad.exe")
--- -- info.filename            c:\windows\notepad.exe
--- -- info.filevernum          10.0.19041.1865
--- -- info.productvernum       10.0.19041.1865
--- -- info.fileflags
--- -- info.osplatform          Windows NT
--- -- info.osqualifier
--- -- info.comments
--- -- info.companyname         Microsoft Corporation
--- -- info.filedescription     Notepad
--- -- info.fileversion         10.0.19041.1 (WinBuild.160101.0800)
--- -- info.internalname        Notepad
--- -- info.legalcopyright      © Microsoft Corporation. All rights reserved.
--- -- info.legaltrademarks
--- -- info.originalfilename    NOTEPAD.EXE.MUI
--- -- info.productname         Microsoft® Windows® Operating System
--- -- info.productversion      10.0.19041.1
--- -- info.privatebuild
--- -- info.specialbuild
--- ```
---@param file string
---@return table | nil
function os.getfileversion(file) end

--- v1.1.42 or newer
---
--- Returns the full path name for <span class="arg">path</span>.
--- If unsuccessful it returns nil, an error message, and the error number.
---@param path string
---@return string
function os.getfullpathname(path) end

--- v1.0.0 or newer
---
--- Returns the fully qualified file name of the host process.  Currently only
--- CMD.EXE can host Clink.
---@return string
function os.gethost() end

--- v1.1.42 or newer
---
--- Returns the long path name for <span class="arg">path</span>.
--- If unsuccessful it returns nil, an error message, and the error number.
---@param path string
---@return string
function os.getlongpathname(path) end

--- v1.2.27 or newer
---
--- Returns the remote name associated with <span class="arg">path</span>, or an
--- empty string if it's not a network drive.
--- If unsuccessful it returns nil, an error message, and the error number.
---@param path string
---@return string
function os.getnetconnectionname(path) end

--- v1.1.41 or newer
---
--- Returns the CMD.EXE process ID. This is mainly intended to help with salting
--- unique resource names (for example named pipes).
---@return integer
function os.getpid() end

--- v1.1.2 or newer
---
--- Returns dimensions of the terminal's buffer and visible window. The returned
--- table has the following scheme:
--- ```lua
--- local info = os.getscreeninfo()
--- -- info.bufwidth        [integer] Width of the screen buffer.
--- -- info.bufheight       [integer] Height of the screen buffer.
--- -- info.winwidth        [integer] Width of the visible window.
--- -- info.winheight       [integer] Height of the visible window.
--- 
--- -- v1.4.28 and higher include the cursor position:
--- -- info.x               [integer] Current cursor column (from 1 to bufwidth).
--- -- info.y               [integer] Current cursor row (from 1 to bufheight).
--- ```
---@return table
function os.getscreeninfo() end

--- v1.1.42 or newer
---
--- Returns the 8.3 short path name for <span class="arg">path</span>.  This may
--- return the input path if an 8.3 short path name is not available.
--- If unsuccessful it returns nil, an error message, and the error number.
---@param path string
---@return string
function os.getshortpathname(path) end

--- v1.3.18 or newer
---
--- Returns the path of the system temporary directory.
--- If unsuccessful it returns nil, an error message, and the error number.
---@return string
function os.gettemppath() end

--- v1.0.0 or newer
---
--- Collects directories matching <span class="arg">globpattern</span> and
--- returns them in a table of strings.</p><p class="desc">
--- <strong>Note:</strong> any quotation marks (<code>"</code>) in
--- <span class="arg">globpattern</span> are stripped.</p><p class="desc">
--- Starting in v1.3.1, when this is used in a coroutine it automatically yields
--- periodically.</p><p class="desc">
--- The optional <span class="arg">extrainfo</span> argument can return a table
--- of tables instead, where each sub-table corresponds to one directory and has
--- the following scheme:
--- ```lua
--- local t = os.globdirs(pattern, extrainfo)
--- -- Included when extrainfo is true or >= 1 (requires v1.1.7 or higher):
--- --   t[index].name      -- [string] The directory name.
--- --   t[index].type      -- [string] The match type (see below).
--- -- Included when extrainfo is 2 (requires v1.2.31 or higher):
--- --   t[index].size      -- [number] The file size, in bytes.
--- --   t[index].atime     -- [number] The access time, compatible with os.time().
--- --   t[index].mtime     -- [number] The modified time, compatible with os.time().
--- --   t[index].ctime     -- [number] The creation time, compatible with os.time().
--- ```
---@param globpattern string
---@param extrainfo integer|boolean
---@param flags table
---@return table
---@overload fun(globpattern: string, extrainfo: integer|boolean): table
---@overload fun(globpattern: string, flags: table): table
---@overload fun(globpattern: string): table
function os.globdirs(globpattern, extrainfo, flags) end

--- v1.0.0 or newer
---
--- Collects files and/or directories matching
--- <span class="arg">globpattern</span> and returns them in a table of strings.</p><p class="desc">
--- <strong>Note:</strong> any quotation marks (<code>"</code>) in
--- <span class="arg">globpattern</span> are stripped.</p><p class="desc">
--- Starting in v1.3.1, when this is used in a coroutine it automatically yields
--- periodically.</p><p class="desc">
--- The optional <span class="arg">extrainfo</span> argument can return a table
--- of tables instead, where each sub-table corresponds to one file or directory
--- and has the following scheme:
--- ```lua
--- local t = os.globfiles(pattern, extrainfo)
--- -- Included when extrainfo is true or >= 1 (requires v1.1.7 or higher):
--- --   t[index].name      -- [string] The file or directory name.
--- --   t[index].type      -- [string] The match type (see below).
--- -- Included when extrainfo is 2 (requires v1.2.31 or higher):
--- --   t[index].size      -- [number] The file size, in bytes.
--- --   t[index].atime     -- [number] The access time, compatible with os.time().
--- --   t[index].mtime     -- [number] The modified time, compatible with os.time().
--- --   t[index].ctime     -- [number] The creation time, compatible with os.time().
--- ```
---@param globpattern string
---@param extrainfo integer|boolean
---@param flags table
---@return table
---@overload fun(globpattern: string, extrainfo: integer|boolean): table
---@overload fun(globpattern: string, flags: table): table
---@overload fun(globpattern: string): table
function os.globfiles(globpattern, extrainfo, flags) end

--- v1.4.24 or newer
---
--- Collects files or directories matching <span class="arg">pattern</span> and
--- returns them in a table of strings.  This matches <code>**</code> patterns
--- <a href="https://git-scm.com/docs/gitignore#_pattern_format">the same as git
--- does</a>.  When <span class="arg">pattern</span> ends with <code>/</code>
--- this collects directories, otherwise it collects files.</p><p class="desc">
--- <strong>Note:</strong> any quotation marks (<code>"</code>) in
--- <span class="arg">pattern</span> are stripped.</p><p class="desc">
--- When this is used in a coroutine it automatically yields periodically.</p><p class="desc">
--- The optional <span class="arg">extrainfo</span> argument can return a table
--- of tables instead, where each sub-table corresponds to one file or directory
--- and has the following scheme:
--- ```lua
--- local t = os.globmatch(pattern, extrainfo)
--- -- Included when extrainfo is true or >= 1:
--- --   t[index].name      -- [string] The file or directory name.
--- --   t[index].type      -- [string] The match type (see below).
--- -- Included when extrainfo is 2:
--- --   t[index].size      -- [number] The file size, in bytes.
--- --   t[index].atime     -- [number] The access time, compatible with os.time().
--- --   t[index].mtime     -- [number] The modified time, compatible with os.time().
--- --   t[index].ctime     -- [number] The creation time, compatible with os.time().
--- ```
---@param pattern string
---@param extrainfo integer|boolean
---@param flags table
---@return table
---@overload fun(pattern: string, extrainfo: integer|boolean): table
---@overload fun(pattern: string, flags: table): table
---@overload fun(pattern: string): table
function os.globmatch(pattern, extrainfo, flags) end

--- v1.0.0 or newer
---
--- Returns whether <span class="arg">path</span> is a directory.
---@param path string
---@return boolean
function os.isdir(path) end

--- v1.0.0 or newer
---
--- Returns whether <span class="arg">path</span> is a file.
---@param path string
---@return boolean
function os.isfile(path) end

--- v1.3.14 or newer
---
--- Returns whether a <kbb>Ctrl</kbd>+<kbd>Break</kbd> has been received.
--- Scripts may use this to decide when to end work early.
---@return boolean
function os.issignaled() end

--- v1.4.17 or newer
---
--- Returns true if running as an administrator account.
---@return boolean
function os.isuseradmin() end

--- v1.0.0 or newer
---
--- Creates the directory <span class="arg">path</span> and returns whether it
--- was successful.
--- If unsuccessful it returns false, an error message, and the error number.
---@param path string
---@return boolean
function os.mkdir(path) end

--- v1.0.0 or newer
---
--- Moves the <span class="arg">src</span> file to the
--- <span class="arg">dest</span> file.
--- If unsuccessful it returns false, an error message, and the error number.
---@param src string
---@param dest string
---@return boolean
function os.move(src, dest) end

--- v1.3.12 or newer
---
--- Identifies whether <span class="arg">text</span> begins with a doskey alias,
--- and expands the doskey alias.</p><p class="desc">
--- Returns a table of strings, or nil if there is no associated doskey alias.
--- The return type is a table of strings because doskey aliases can be defined
--- to expand into multiple command lines:  one entry in the table per resolved
--- command line.  Most commonly, the table will contain one string.
---@param text string
---@return table|nil
function os.resolvealias(text) end

--- v1.0.0 or newer
---
--- Removes the directory <span class="arg">path</span> and returns whether it
--- was successful.
--- If unsuccessful it returns false, an error message, and the error number.
---@param path string
---@return boolean
function os.rmdir(path) end

--- v1.2.32 or newer
---
--- This sets the text onto the system clipboard, and returns whether it was
--- successful.
---@param string any
---@return boolean
function os.setclipboardtext(string) end

--- v1.0.0 or newer
---
--- Sets the <span class="arg">name</span> environment variable to
--- <span class="arg">value</span> and returns whether it was successful.
--- If unsuccessful it returns false, an error message, and the error number.
---@param name string
---@param value string
---@return boolean
function os.setenv(name, value) end

--- v1.3.16 or newer
---
--- Sleeps for the indicated duration, in seconds, with millisecond granularity.
--- ```lua
--- os.sleep(0.01)  -- Sleep for 10 milliseconds.
--- ```
---@param seconds number
function os.sleep(seconds) end

--- v1.2.31 or newer
---
--- Sets the access and modified times for <span class="arg">path</span>, and
--- returns whether it was successful.
--- If unsuccessful it returns false, an error message, and the error number.</p><p class="desc">
--- The second argument is <span class="arg">atime</span> and is a time to set
--- as the file's access time.  If omitted, the current time is used.  If
--- present, the value must use the same format as
--- <code><a href="https://www.lua.org/manual/5.2/manual.html#pdf-os.time">os.time()</a></code>.</p><p class="desc">
--- The third argument is <span class="arg">mtime</span> and is a time to set as
--- the file's modified time.  If omitted, the <span class="arg">atime</span>
--- value is used (or the current time).  If present, the value must use the
--- same format as <code>os.time()</code>.  In order to pass
--- <span class="arg">mtime</span> it is necessary to also pass
--- <span class="arg">atime</span>.
---@param path string
---@param atime number
---@param mtime number
---@return boolean
---@overload fun(path: string, atime: number): boolean
---@overload fun(path: string, mtime: number): boolean
---@overload fun(path: string): boolean
function os.touch(path, atime, mtime) end

--- v1.0.0 or newer
---
--- Deletes the file <span class="arg">path</span> and returns whether it was
--- successful.
--- If unsuccessful it returns false, an error message, and the error number.
---@param path string
---@return boolean
function os.unlink(path) end

---@class clink.path
_G.path = {}

--- v1.4.24 or newer
---
--- This compares the two strings <span class="arg">pattern</span> and
--- <span class="arg">string</span> and returns whether they are considered to
--- match.  This is like the Linux <code>fnmatch</code> function, with an
--- additional optional mode that can allow matching <code>**</code> patterns
--- <a href="https://git-scm.com/docs/gitignore#_pattern_format">the same as git
--- does</a>.</p><p class="desc">
--- The optional <span class="arg">flags</span> string may contain any of the
--- following characters to modify the behavior accordingly:
--- <ul>
--- <tr><th>Flag</th><th>Mnemonic</th><th>Description</th></tr>
--- <tr><td>"<code>e</code>"</td><td>NoEscape</td><td>Treat backslash in <span class="arg">pattern</span> as a normal character, rather than as an escape character.</td></tr>
--- <tr><td>"<code>p</code>"</td><td>PathName</td><td>Path separators in <span class="arg">string</span> are matched only by a slash <code>/</code> in <span class="arg">pattern</span> (unless the <code>*</code> flag is used; see below).</td></tr>
--- <tr><td>"<code>.</code>"</td><td>Period</td><td>A leading period <code>.</code> in <span class="arg">string</span> is matched only by a period <code>.</code> in <span class="arg">pattern</span>.  A leading period is one at the beginning of <span class="arg">string</span>, or immediately following a path separator when the <code>p</code> flag is used.</td></tr>
--- <tr><td>"<code>l</code>"</td><td>LeadingDir</td><td>Consider <span class="arg">pattern</span> to be matched if it completely matches <span class="arg">string</span>, or if it matches <span class="arg">string</span> up to a path separator.</td></tr>
--- <tr><td>"<code>c</code>"</td><td>NoCaseFold</td><td>Match with case sensitivity. By default it matches case-insensitively, because Windows is case-insensitive.</td></tr>
--- <tr><td>"<code>*</code>"</td><td>WildStar</td><td>Treat double-asterisks in <span class="arg">pattern</span> as matching path separators as well, the same as how git does (implies the <code>p</code> flag).</td></tr>
--- <tr><td>"<code>s</code>"</td><td>NoSlashFold</td><td>Treat slashes <code>/</code> in <span class="arg">pattern</span> as only matching slashes in <span class="arg">string</span>. By default slashes in <span class="arg">pattern</span> match both slash <code>/</code> and backslash <code>\</code> because Windows recognizes both as path separators.</td></tr>
--- </ul></p><p class="desc">
--- The <span class="arg">pattern</span> supports wildcards (<code>?</code> and
--- <code>*</code>), character classes (<code>[</code>...<code>]</code>), ranges
--- (<code>[</code>.<code>-</code>.<code>]</code>), and complementation
--- (<code>[!</code>...<code>]</code> and
--- <code>[!</code>.<code>-</code>.<code>]</code>).</p><p class="desc">
--- The <span class="arg">pattern</span> also supports the following character
--- classes:
--- <ul>
--- <li>"<code>[[:alnum:]]</code>": Matches any alphabetic character or digit a - z, or A - Z, or 0 - 9.
--- <li>"<code>[[:alpha:]]</code>": Matches any alphabetic character a - z or A - Z.
--- <li>"<code>[[:blank:]]</code>": Matches 0x20 (space) or 0x09 (tab).
--- <li>"<code>[[:cntrl:]]</code>": Matches 0x00 - 0x1F or 0x7F.
--- <li>"<code>[[:digit:]]</code>": Matches any of the digits 0 - 9.
--- <li>"<code>[[:graph:]]</code>": Matches any character that matches <code>[[:print:]]</code> but does not match <code>[[:space:]]</code>.
--- <li>"<code>[[:lower:]]</code>": Matches any lower case ASCII letter a - z.
--- <li>"<code>[[:print:]]</code>": Matches any printable character (e.g. 0x20 - 0x7E).
--- <li>"<code>[[:punct:]]</code>": Matches any character that matches <code>[[:print:]]</code> but does not match <code>[[:alnum:]]</code>, <code>[[:space:]]</code>, or <code>[[:alnum:]]</code>.
--- <li>"<code>[[:space:]]</code>": Matches 0x20 (space) or 0x09 - 0x0D (tab, linefeed, carriage return, etc).
--- <li>"<code>[[:xdigit:]]</code>": Matches any of the hexadecimal digits 0 - 9, A - F, or a - f.
--- <li>"<code>[[:upper:]]</code>": Matches any upper case ASCII letter A - Z.
--- </ul></p><p class="desc">
--- <strong>Note:</strong> At this time the character classes and
--- case-insensitivity operate on one byte at a time, so they do not fully
--- work as expected with non-ASCII characters.
---@param pattern string
---@param string string
---@param flags string
---@return boolean
---@overload fun(pattern: string, string: string): boolean
function path.fnmatch(pattern, string, flags) end

--- v1.1.0 or newer
---
--- ```lua
--- path.getbasename("/foo/bar.ext")    -- returns "bar"
--- path.getbasename("")                -- returns ""
--- ```
---@param path string
---@return string
function path.getbasename(path) end

--- v1.1.0 or newer
---
--- This is similar to <a href="#path.toparent">path.toparent()</a> but can
--- behave differently when the input path ends with a path separator.  This is
--- the recommended API for parsing a path into its component pieces, but is not
--- recommended for walking up through parent directories.
--- ```lua
--- path.getdirectory("foo")                -- returns nil
--- path.getdirectory("\\foo")              -- returns "\\"
--- path.getdirectory("c:foo")              -- returns "c:"
--- path.getdirectory("c:\\")               -- returns "c:\\"
--- path.getdirectory("c:\\foo")            -- returns "c:\\"
--- path.getdirectory("c:\\foo\\bar")       -- returns "c:\\foo"
--- path.getdirectory("\\\\foo\\bar")       -- returns "\\\\foo\\bar"
--- path.getdirectory("\\\\foo\\bar\\dir")  -- returns "\\\\foo\\bar"
--- path.getdirectory("")                   -- returns nil
--- 
--- -- These split the path components differently than path.toparent().
--- path.getdirectory("c:\\foo\\bar\\")         -- returns "c:\\foo\\bar"
--- path.getdirectory("\\\\foo\\bar\\dir\\")    -- returns "\\\\foo\\bar\\dir"
--- ```
---@param path string
---@return nil or string
function path.getdirectory(path) end

--- v1.1.0 or newer
---
--- ```lua
--- path.getdrive("e:/foo/bar")     -- returns "e:"
--- path.getdrive("foo/bar")        -- returns nil
--- path.getdrive("")               -- returns nil
--- ```
---@param path string
---@return nil or string
function path.getdrive(path) end

--- v1.1.0 or newer
---
--- ```lua
--- path.getextension("bar.ext")    -- returns ".ext"
--- path.getextension("bar")        -- returns ""
--- path.getextension("")           -- returns ""
--- ```
---@param path string
---@return string
function path.getextension(path) end

--- v1.1.0 or newer
---
--- ```lua
--- path.getname("/foo/bar.ext")    -- returns "bar.ext"
--- path.getname("")                -- returns ""
--- ```
---@param path string
---@return string
function path.getname(path) end

--- v1.1.5 or newer
---
--- Examines the extension of the path name.  Returns true if the extension is
--- listed in %PATHEXT%.  This caches the extensions in a map so that it's more
--- efficient than getting and parsing %PATHEXT% each time.
--- ```lua
--- path.isexecext("program.exe")   -- returns true
--- path.isexecext("file.doc")      -- returns false
--- path.isexecext("")              -- returns false
--- ```
---@param path string
---@return boolean
function path.isexecext(path) end

--- v1.1.0 or newer
---
--- If <span class="arg">right</span> is a relative path, this joins
--- <span class="arg">left</span> and <span class="arg">right</span>.</p><p class="desc">
--- If <span class="arg">right</span> is not a relative path, this returns
--- <span class="arg">right</span>.
--- ```lua
--- path.join("/foo", "bar")        -- returns "/foo\\bar"
--- path.join("", "bar")            -- returns "bar"
--- path.join("/foo", "")           -- returns "/foo\\"
--- path.join("/foo", "/bar/xyz")   -- returns "/bar/xyz"
--- ```
---@param left string
---@param right string
---@return string
function path.join(left, right) end

--- v1.1.0 or newer
---
--- Cleans <span class="arg">path</span> by normalising separators and removing
--- "." and ".." elements.  If <span class="arg">separator</span> is provided it
--- is used to delimit path elements, otherwise a system-specific delimiter is
--- used.
--- ```lua
--- path.normalise("a////b/\\/c/")  -- returns "a\\b\\c\\"
--- path.normalise("")              -- returns ""
--- ```
---@param path string
---@param separator string
---@return string
---@overload fun(path: string): string
function path.normalise(path, separator) end

--- v1.1.20 or newer
---
--- Splits the last path component from <span class="arg">path</span>, if
--- possible. Returns the result and the component that was split, if any.</p><p class="desc">
--- This is similar to <a href="#path.getdirectory">path.getdirectory()</a> but
--- can behave differently when the input path ends with a path separator.  This
--- is the recommended API for walking up through parent directories.
--- ```lua
--- local parent,child
--- parent,child = path.toparent("foo")                 -- returns "", "foo"
--- parent,child = path.toparent("\\foo")               -- returns "\\", "foo"
--- parent,child = path.toparent("c:foo")               -- returns "c:", "foo"
--- parent,child = path.toparent("c:\\"])               -- returns "c:\\", ""
--- parent,child = path.toparent("c:\\foo")             -- returns "c:\\", "foo"
--- parent,child = path.toparent("c:\\foo\\bar")        -- returns "c:\\foo", "bar"
--- parent,child = path.toparent("\\\\foo\\bar")        -- returns "\\\\foo\\bar", ""
--- parent,child = path.toparent("\\\\foo\\bar\\dir")   -- returns "\\\\foo\\bar", "dir"
--- parent,child = path.toparent("")                    -- returns "", ""
--- 
--- -- These split the path components differently than path.getdirectory().
--- parent,child = path.toparent("c:\\foo\\bar\\"")     -- returns "c:\\foo", "bar"
--- parent,child = path.toparent("\\\\foo\\bar\\dir\\") -- returns "\\\\foo\\bar", "dir"
--- ```
---@param path string
---@return string
---@return string
function path.toparent(path) end

---@class clink.rl
_G.rl = {}

--- v1.1.6 or newer
---
--- Undoes Readline tilde expansion.  See
--- <a href="#rl.expandtilde">rl.expandtilde()</a> for more information.
--- ```lua
--- rl.collapsetilde("C:\\Users\\yourusername\\Documents")
--- 
--- -- The return value depends on the expand-tilde configuration variable:
--- -- When "on", the function returns "C:\\Users\\yourusername\\Documents".
--- -- When "off", the function returns "~\\Documents".
--- 
--- -- Or when <span class="arg">force</span> is true, the function returns "~\Documents".
--- ```
---@param path string
---@param force boolean
---@return string
---@overload fun(path: string): string
function rl.collapsetilde(path, force) end

--- v1.3.41 or newer
---
--- This associates <span class="arg">description</span> with
--- <span class="arg">macro</span>, to be displayed in the
--- <code><a href="#rlcmd-clink-show-help">clink-show-help</a></code> and
--- <code><a href="#rlcmd-clink-what-is">clink-what-is</a></code> commands.</p><p class="desc">
--- This may be used to add a description for a
--- <a href="#luakeybindings">luafunc: key binding</a> macro, or for a keyboard
--- macro.</p><p class="desc">
--- The <span class="arg">macro</span> string should include quotes, just like
--- in <a href="#rl.setbinding">rl.setbinding()</a>.  If quotes are not present,
--- they are added automatically.
--- ```lua
--- rl.describemacro([["luafunc:mycommand"]], "Does whatever mycommand does")
--- rl.describemacro([["\e[Hrem "]], "Insert 'rem ' at the beginning of the line")
--- rl.setbinding([["\C-o"]], [["luafunc:mycommand"]])
--- rl.setbinding([["\C-r"]], [["\e[Hrem "]])
--- -- Press Alt-H to see the list of key bindings and descriptions.
--- ```
---@param macro string
---@param description string
function rl.describemacro(macro, description) end

--- v1.1.6 or newer
---
--- Performs Readline tilde expansion.</p><p class="desc">
--- When generating filename matches for a word, use the
--- <a href="#rl.expandtilde">rl.expandtilde()</a> and
--- <a href="#rl.collapsetilde">rl.collapsetilde()</a> helper functions to perform
--- tilde completion expansion according to Readline's configuration.</p><p class="desc">
--- An optional <span class="arg">whole_line</span> argument selects whether to
--- expand tildes everywhere in the input string (pass true), or to expand only
--- a tilde at the beginning of the input string (pass false or omit the
--- second argument).  See the Compatibility Note below for more information.</p><p class="desc">
--- Use <a href="#rl.expandtilde">rl.expandtilde()</a> to do tilde expansion
--- before collecting file matches (e.g. via
--- <a href="#os.globfiles">os.globfiles()</a>).  If it indicates that it expanded
--- the string, then use <a href="#rl.collapsetilde">rl.collapsetilde()</a> to put
--- back the tilde before returning a match.
--- ```lua
--- local result, expanded = rl.expandtilde("~\\Documents")
--- -- result is "C:\\Users\\yourusername\\Documents"
--- -- expanded is true
--- 
--- -- This dir_matches function demonstrates efficient use of rl.expandtilde()
--- -- and rl.collapsetilde() to generate directory matches from the file system.
--- function dir_matches(match_word, word_index, line_state)
---    -- Expand tilde before scanning file system.
---    local word = line_state:getword(word_index)
---    local expanded
---    word, expanded = rl.expandtilde(word)
--- 
---    -- Get the directory from 'word', and collapse tilde before generating
---    -- matches.  Notice that collapsetilde() only needs to be called once!
---    local root = path.getdirectory(word) or ""
---    if expanded then
---        root = rl.collapsetilde(root)
---    end
--- 
---    local matches = {}
---    for _, d in ipairs(os.globdirs(word.."*", true)) do
---        -- Join the filename with the input directory (might have a tilde).
---        local dir = path.join(root, d.name)
---        table.insert(matches, { match = dir, type = d.type })
---    end
---    return matches
--- end
--- ```
---@param path string
---@param whole_line boolean
---@return string
---@return boolean
---@overload fun(path: string): string, boolean
function rl.expandtilde(path, whole_line) end

--- v1.2.46 or newer
---
--- Returns the command or macro bound to <span class="arg">key</span>, and the
--- type of the binding.</p><p class="desc">
--- If nothing is bound to the specified key sequence, the returned binding will
--- be nil.</p><p class="desc">
--- The returned type can be <code>"function"</code>, <code>"macro"</code>, or
--- <code>"keymap"</code> (if <span class="arg">key</span> is an incomplete key
--- sequence).</p><p class="desc">
--- If an error occurs, only nil is returned.</p><p class="desc">
--- The <span class="arg">key</span> sequence string is the same format as from
--- <code>clink echo</code>.  See <a href="#discoverkeysequences">Discovering
--- Clink key sindings</a> for more information.</p><p class="desc">
--- An optional <span class="arg">keymap</span> may be specified as well.  If it
--- is omitted or nil, then the current keymap is searched.  Otherwise it may
--- refer to one of the three built in keymaps:
--- <table>
--- <tr><th>Keymap</th><th>Description</th></tr>
--- <tr><td><code>"emacs"</code></td><td>The Emacs keymap, which is the default keymap.</td></tr>
--- <tr><td><code>"vi"</code>, <code>"vi-move"</code>, or <code>"vi-command"</code></td><td>The VI command mode keymap.</td></tr>
--- <tr><td><code>"vi-insert"</code></td><td>The VI insertion mode keymap.</td></tr>
--- </table></p><p class="desc">
--- The return value can be passed as input to
--- <a href="#rl.setbinding">rl.setbinding()</a> or
--- <a href="#rl.invokecommand">rl.invokecommand()</a>.
--- ```lua
--- local b,t = rl.getbinding([["\e[H"]], "emacs")
--- if b then
---    print("Home is bound to "..b.." ("..t..") in emacs mode.")
--- else
---    print("Home is not bound in emacs mode.")
--- end
--- ```
---@param key string
---@param keymap string
---@return string
---@return string
---@overload fun(key: string): string, string
function rl.getbinding(key, keymap) end

--- v1.5.1 or newer
---
--- Returns key bindings and info for <span class="arg">command</span> in a
--- table with the following scheme:
--- ```lua
--- local t = rl.getcommandbindings("complete")
--- -- t.desc               [string] Description of the command.
--- -- t.category           [string] Category of the command.
--- -- t.keys               [table] Table of strings listing the key names that are bound to the command.
--- ```
---@param command string
---@param raw boolean
---@return table | nil
function rl.getcommandbindings(command, raw) end

--- v1.3.18 or newer
---
--- Returns the number of history items.
---@return integer
function rl.gethistorycount() end

--- v1.3.18 or newer
---
--- Returns a table of history items.</p><p class="desc">
--- The first history item is 1, and the last history item is
--- <a href="#rl.gethistorycount">rl.gethistorycount()</a>.  For best
--- performance, use <span class="arg">start</span> and
--- <span class="arg">end</span> to request only the range of history items that
--- will be needed.</p><p class="desc">
--- Each history item is a table with the following scheme:
--- ```lua
--- local h = rl.gethistoryitems(1, rl.gethistorycount())
--- -- h.line       [string] The item's command line string.
--- -- h.time       [integer or nil] The item's time, compatible with os.time().
--- ```
---@return integer
---@return integer
function rl.gethistoryitems() end

--- v1.2.16 or newer
---
--- Returns key bindings in a table with the following scheme:
--- ```lua
--- local t = rl.getkeybindings()
--- -- t[index].key         [string] Key name.
--- -- t[index].binding     [string] Command or macro bound to the key.
--- -- t[index].desc        [string] Description of the command.
--- -- t[index].category    [string] Category of the command.
--- ```
---@param raw boolean
---@param mode integer
---@return table
---@overload fun(raw: boolean): table
function rl.getkeybindings(raw, mode) end

--- v1.1.40 or newer
---
--- Returns two values:
--- <ul>
--- <li>The name of the last Readline command invoked by a key binding.
--- <li>The name of the last Lua function invoked by a key binding.
--- </ul></p><p class="desc">
--- If the last key binding invoked a Lua function, then the first return value
--- is an empty string unless the Lua function used
--- <a href="#rl.invokecommand">rl.invokecommand()</a> to also internally invoke
--- a Readline command.
--- If the last key binding did not invoke a Lua function, then the second
--- return value is an empty string.
--- ```lua
--- local last_rl_func, last_lua_func = rl.getlastcommand()
--- ```
---@return string
---@return function
function rl.getlastcommand() end

--- v1.3.4 or newer
---
--- Returns the color string associated with the match.</p><p class="desc">
--- The arguments are the same as in
--- <a href="#builder:addmatch">builder:addmatch()</a>.
---@param match string|table
---@param type string
---@return string
---@overload fun(match: string|table): string
function rl.getmatchcolor(match, type) end

--- v1.2.28 or newer
---
--- Returns information about the current prompt and input line.</p><p class="desc">
--- Note: the <span class="arg">promptline</span> and
--- <span class="arg">inputline</span> fields may be skewed if any additional
--- terminal output has occurred (for example if any
--- <a href="#https://www.lua.org/manual/5.2/manual.html#pdf-print">print()</a>
--- calls have happened, or if <code>rl.getpromptinfo()</code> is used inside a
--- <a href="#clink_onendedit">clink.onendedit()</a> event handler, or any other
--- output that the Readline library wouldn't know about).</p><p class="desc">
--- The returned table has the following scheme:
--- ```lua
--- local info = rl.getpromptinfo()
--- -- info.promptprefix              [string] The prompt string, minus the last line of the prompt string.
--- -- info.promptprefixlinecount     [integer] Number of lines in the promptprefix string.
--- -- info.prompt                    [string] The last line of the prompt string.
--- -- info.rprompt                   [string or nil] The right side prompt (or nil if none).
--- -- info.promptline                [integer] Console line on which the prompt starts.
--- -- info.inputline                 [integer] Console line on which the input text starts.
--- -- info.inputlinecount            [integer] Number of lines in the input text.
--- ```
---@return table
function rl.getpromptinfo() end

--- v1.1.6 or newer
---
--- Returns the value of the named Readline configuration variable as a string,
--- or nil if the variable name is not recognized.
---@param name string
---@return string | nil
function rl.getvariable(name) end

--- v1.2.50 or newer
---
--- Returns true when typing insertion mode is on.</p><p class="desc">
--- When the optional <span class="arg">insert</span> argument is passed, this
--- also sets typing insertion mode on or off accordingly.
---@param insert boolean
---@return boolean
---@overload fun(): boolean
function rl.insertmode(insert) end

--- v1.1.26 or newer
---
--- Invokes a Readline command named <span class="arg">command</span>.  May only
--- be used within a <a href="#luakeybindings">luafunc: key binding</a>.</p><p class="desc">
--- <span class="arg">count</span> is optional and defaults to 1 if omitted.</p><p class="desc">
--- Returns true if the named command succeeds, false if the named command
--- fails, or nil if the named command doesn't exist.</p><p class="desc">
--- Warning:  Invoking more than one Readline command in a luafunc: key binding
--- could have unexpected results, depending on which commands are invoked.
---@param command string
---@param count integer
---@return boolean | nil
---@overload fun(command: string): boolean | nil
function rl.invokecommand(command, count) end

--- v1.4.14 or newer
---
--- Returns whether the current input line exactly matches
--- <span class="arg">text</span>.  This can be useful in a coroutine that wants
--- to know whether the current input line has already changed, before it starts
--- a potentially slow operation to generate matches.
--- If the optional <span class="arg">to_cursor</span> is true, then only the
--- line up to the current cursor position is compared.
--- ```lua
--- local function matches_func(word, index, line_state, builder)
---     -- Delay match generation briefly, to allow coalescing typed letters into
---     -- a single query.  This can make auto-suggestions more responsive if the
---     -- match generation operation is slow, such as doing a network query.
---     local co, ismain = coroutine.running()
---     if not ismain then
---         local orig_line = line_state:getline()
---         orig_line = orig_line:sub(1, line_state:getcursor() - 1)
---         -- Yield for 0.2 seconds.
---         clink.setcoroutineinterval(co, 0.2)
---         coroutine.yield()
---         -- Reset the interval back to normal.
---         clink.setcoroutineinterval(co, 0)
---         -- If the input line changed during the 0.2 seconds, then don't generate
---         -- matches, and mark the matches as needing to be regenerated.
---         if not rl.islineequal(orig_line, true) then
---             builder:setvolatile()
---             return {}
---         end
---     end
--- 
---     -- Do something slow that generates matches.
---     local matches = {}
---     local f = io.popen("slow_operation.exe")
---     if f then
---         for l in f:lines() do
---             table.insert(matches, l)
---         end
---     end
---     return matches
--- end
--- ```
---@param text string
---@param to_cursor boolean
---@return boolean
---@overload fun(text: string): boolean
function rl.islineequal(text, to_cursor) end

--- v1.2.51 or newer
---
--- Returns true when the current input line is a history entry that has been
--- modified (i.e. has an undo list).</p><p class="desc">
--- This enables prompt filters to show a "modmark" of their own, as an
--- alternative to the modmark shown when the
--- <code><a href="#configmarkmodifiedlines">mark-modified-lines</a></code>
--- Readline config setting is enabled.</p><p class="desc">
--- The following sample illustrates a prompt filter that shows a "modified
--- line" indicator when the current line is a history entry and has been
--- modified.
--- ```lua
--- local p = clink.promptfilter(10)
--- local normal = "\x1b[m"
--- 
--- local function get_settings_color(name)
---    return "\x1b[" .. settings.get(name) .. "m"
--- end
--- 
--- function p:filter(prompt)
---    prompt = os.getcwd()
---    if rl.ismodifiedline() then
---        -- If the current line is a history entry and has been modified,
---        -- then show an indicator.
---        prompt = get_settings_color("color.modmark") .. "*" .. normal .. " " .. prompt
---    end
---    prompt = prompt .. "\n$ "
---    return prompt
--- end
--- 
--- local last_modmark = false
--- 
--- local function modmark_reset()
---    -- Reset the remembered state at the beginning of each edit line.
---    last_modmark = rl.ismodifiedline()
--- 
---    -- Turn off `mark-modified-lines` to avoid two modmarks showing up.
---    rl.setvariable("mark-modified-lines", "off")
--- end
--- 
--- local function modmark_refilter()
---    -- If the modmark state has changed, refresh the prompt.
---    if last_modmark ~= rl.ismodifiedline() then
---        last_modmark = rl.ismodifiedline()
---        clink.refilterprompt()
---    end
--- end
--- 
--- clink.onbeginedit(modmark_reset)
--- clink.onaftercommand(modmark_refilter)
--- ```
---@return boolean
function rl.ismodifiedline() end

--- v1.1.6 or newer
---
--- Returns a boolean value indicating whether the named Readline configuration
--- variable is set to true (on), or nil if the variable name is not recognized.
---@param name string
---@return boolean | nil
function rl.isvariabletrue(name) end

--- v1.4.8 or newer
---
--- Returns whether the <span class="arg">text</span> needs quotes to be parsed
--- correctly in a command line.
---@param text string
---@return boolean
function rl.needquotes(text) end

--- v1.2.46 or newer
---
--- Binds <span class="arg">key</span> to invoke
--- <span class="arg">binding</span>, and returns whether it was successful.</p><p class="desc">
--- The <span class="arg">key</span> sequence string is the same format as from
--- <code>clink echo</code>.  See <a href="#discoverkeysequences">Discovering
--- Clink key sindings</a> for more information.</p><p class="desc">
--- The <span class="arg">binding</span> is either the name of a Readline
--- command, a quoted macro string (just like in the .inputrc config file), or
--- nil to clear the key binding.</p><p class="desc">
--- An optional <span class="arg">keymap</span> may be specified as well.  If it
--- is omitted or nil, then the current keymap is searched.  Otherwise it may
--- refer to one of the three built in keymaps:
--- <table>
--- <tr><th>Keymap</th><th>Description</th></tr>
--- <tr><td><code>"emacs"</code></td><td>The Emacs keymap, which is the default keymap.</td></tr>
--- <tr><td><code>"vi"</code>, <code>"vi-move"</code>, or <code>"vi-command"</code></td><td>The VI command mode keymap.</td></tr>
--- <tr><td><code>"vi-insert"</code></td><td>The VI insertion mode keymap.</td></tr>
--- </table></p><p class="desc">
--- Using Lua's <code>[[</code>..<code>]]</code> string syntax conveniently lets
--- you simply copy the key string exactly from the <code>clink echo</code>
--- output, without needing to translate the quotes or backslashes.</p><p class="desc">
--- <strong>Note:</strong> This does not write the value into a config file.
--- Instead it updates the key binding in memory, temporarily overriding
--- whatever is present in any config files.  When config files are reloaded,
--- they may replace the key binding again.
--- ```lua
--- local old_space = rl.getbinding('" "')
--- function hijack_space(rl_buffer)
---    rl.invokecommand("clink-expand-line")   -- Expand envvars, etc in the line.
---    rl.invokecommand(old_space)             -- Then invoke whatever was previously bound to Space.
--- end
--- rl.setbinding([[" "]], [["luafunc:hijack_space"]])
--- 
--- -- The [[]] string syntax lets you copy key strings directly from 'clink echo'.
--- -- [["\e[H"]] is much easier than translating to "\"\\e[H\"", for example.
--- rl.setbinding([["\e[H"]], [[beginning-of-line]])
--- ```
---@param key string
---@param binding string | nil
---@param keymap string
---@return boolean
---@overload fun(key: string, binding: string | nil): boolean
function rl.setbinding(key, binding, keymap) end

--- v1.1.40 or newer
---
--- Provides an alternative set of matches for the current word.  This discards
--- any matches that may have already been collected and uses
--- <span class="arg">matches</span> for subsequent Readline completion commands
--- until any action that normally resets the matches (such as moving the cursor
--- or editing the input line).</p><p class="desc">
--- The syntax is the same as for
--- <a href="#builder:addmatches()">builder:addmatches()</a> with one addition:
--- You can add a <code>"nosort"</code> key to the
--- <span class="arg">matches</span> table to disable sorting the matches.</p><p class="desc">
--- <pre><code class="lua">local matches = {}<br/>matches["nosort"] = true<br/>rl.setmatches(matches)</code></pre></p><p class="desc">
--- This function may (only) be used by a
--- <a href="#luakeybindings">luafunc: key binding</a> to provide matches based
--- on some special criteria.  For example, a key binding could collect numbers
--- from the current screen buffer (such as issue numbers, commit hashes, line
--- numbers, etc) and provide them to Readline as matches, making it convenient
--- to grab a number from the screen and insert it as a command line argument.</p><p class="desc">
--- Match display filtering is also possible by using
--- <a href="#clink.ondisplaymatches">clink.ondisplaymatches()</a> after setting
--- the matches.</p><p class="desc">
--- <em>Example .inputrc key binding:</em>
--- <pre><code class="plaintext">M-n:            <span class="hljs-string">"luafunc:completenumbers"</span>       <span class="hljs-comment"># Alt+N</span></code></pre></p><p class="desc">
--- <em>Example Lua function:</em>
--- ```lua
--- function completenumbers()
---    local _,last_luafunc = rl.getlastcommand()
---    if last_luafunc ~= "completenumbers" then
---        -- Collect numbers from the screen (minimum of three digits).
---        -- The numbers can be any base up to hexadecimal (decimal, octal, etc).
---        local matches = console.screengrab("[^%w]*(%w%w[%w]+)", "^%x+$")
---        -- They're already sorted by distance from the input line.
---        matches["nosort"] = true
---        rl.setmatches(matches)
---    end
--- 
---    rl.invokecommand("old-menu-complete")
--- end
--- ```
---@param matches table
---@param type string
---@return integer
---@return boolean
---@overload fun(matches: table): integer, boolean
function rl.setmatches(matches, type) end

--- v1.1.46 or newer
---
--- Temporarily overrides the named Readline configuration variable to the
--- specified value.  The return value reports whether it was successful, or is
--- nil if the variable name is not recognized.</p><p class="desc">
--- <strong>Note:</strong> This does not write the value into a config file.
--- Instead it updates the variable in memory, temporarily overriding whatever
--- is present in any config files.  When config files are reloaded, they may
--- replace the value again.
---@param name string
---@param value string
---@return boolean
function rl.setvariable(name, value) end

---@class clink.rl_buffer
_G.rl_buffer = {}

--- v1.1.20 or newer
---
--- Advances the output cursor to the next line after the Readline input buffer
--- so that subsequent output doesn't overwrite the input buffer display.
function rl_buffer:beginoutput() end

--- v1.1.20 or newer
---
--- Starts a new undo group.  This is useful for grouping together multiple
--- editing actions into a single undo operation.
function rl_buffer:beginundogroup() end

--- v1.1.20 or newer
---
--- Dings the bell.  If the
--- <code><a href="#configbellstyle">bell-style</a></code> Readline variable is
--- <code>visible</code> then it flashes the cursor instead.
function rl_buffer:ding() end

--- v1.1.20 or newer
---
--- Ends an undo group.  This is useful for grouping together multiple
--- editing actions into a single undo operation.</p><p class="desc">
--- Note:  all undo groups are automatically ended when a key binding finishes
--- execution, so this function is only needed if a key binding needs to create
--- more than one undo group.
function rl_buffer:endundogroup() end

--- v1.2.35 or newer
---
--- Returns the anchor position of the currently selected text in the input
--- line, or nil if there is no selection.  The value can be from 1 to
--- rl_buffer:getlength() + 1.  It can exceed the length of the input line
--- because the anchor can be positioned just past the end of the input line.
---@return integer | nil
function rl_buffer:getanchor() end

--- v1.2.22 or newer
---
--- Returns any accumulated numeric argument (<kbd>Alt</kbd>+Digits, etc), or
--- nil if no numeric argument has been entered.
---@return integer | nil
function rl_buffer:getargument() end

--- v1.0.0 or newer
---
--- Returns the current input line.
---@return string
function rl_buffer:getbuffer() end

--- v1.1.20 or newer
---
--- Returns the cursor position in the input line.  The value can be from 1 to
--- rl_buffer:getlength() + 1.  It can exceed the length of the input line
--- because the cursor can be positioned just past the end of the input line.</p><p class="desc">
--- <strong>Note:</strong> In v1.1.20 through v1.2.31 this accidentally returned
--- 1 less than the actual cursor position.  In v1.2.32 and higher it returns
--- the correct cursor position.
---@return integer
function rl_buffer:getcursor() end

--- v1.1.20 or newer
---
--- Returns the length of the input line.
---@return integer
function rl_buffer:getlength() end

--- v1.1.20 or newer
---
--- Inserts <span class="arg">text</span> at the cursor position in the input
--- line.
---@param text string
function rl_buffer:insert(text) end

--- v1.1.41 or newer
---
--- Redraws the input line.
function rl_buffer:refreshline() end

--- v1.1.20 or newer
---
--- Removes text from the input line starting at cursor position
--- <span class="arg">from</span> up to but not including
--- <span class="arg">to</span>.</p><p class="desc">
--- If <span class="arg">from</span> is greater than <span class="arg">to</span>
--- then the positions are swapped before removing text.</p><p class="desc">
--- Note:  the input line is UTF8, and removing only part of a multi-byte
--- Unicode character may have undesirable results.
---@param from integer
---@param to integer
function rl_buffer:remove(from, to) end

--- v1.2.32 or newer
---
--- When <span class="arg">argument</span> is a number, it is set as the numeric
--- argument for use by Readline commands (as entered using
--- <kbd>Alt</kbd>+Digits, etc).  When <span class="arg">argument</span> is nil,
--- the numeric argument is cleared (having no numeric argument is different
--- from having 0 as the numeric argument).
---@param argument integer | nil
function rl_buffer:setargument(argument) end

--- v1.1.20 or newer
---
--- Sets the cursor position in the input line and returns the previous cursor
--- position.  <span class="arg">cursor</span> can be from 1 to
--- rl_buffer:getlength() + 1.  It can exceed the length of the input line
--- because the cursor can be positioned just past the end of the input line.</p><p class="desc">
--- Note:  the input line is UTF8, and setting the cursor position inside a
--- multi-byte Unicode character may have undesirable results.</p><p class="desc">
--- <strong>Note:</strong> In v1.1.20 through v1.2.31 this accidentally returned
--- 1 less than the actual cursor position.  In v1.2.32 and higher it returns
--- the correct cursor position.
---@param cursor integer
---@return integer
function rl_buffer:setcursor(cursor) end

---@class clink.settings
_G.settings = {}

--- v1.0.0 or newer
---
--- Adds a setting to the list of Clink settings and includes it in
--- <code>clink set</code>.  The new setting is named
--- <span class="arg">name</span> and has a default value
--- <span class="arg">default</span> when the setting isn't explicitly set.</p><p class="desc">
--- The type of <span class="arg">default</span> determines what kind of setting
--- is added:
--- <ul>
--- <li>Boolean; a boolean value adds a boolean setting.
--- <li>Integer; an integer value adds an integer setting.
--- <li>Enum; a table adds an enum setting.  The table defines the accepted
--- string values, and the first value is the default value.  The setting has an
--- integer value which corresponds to the position in the table of accepted
--- values.  The first position is 0, the second position is 1, etc.
--- <li>String; a string value adds a string setting.
--- <li>Color; when <span class="arg">name</span> begins with
--- <code>"color."</code> then a string value adds a color setting.
--- </ul></p><p class="desc">
--- <span class="arg">name</span> can't be more than 32 characters.</p><p class="desc">
--- <span class="arg">short_desc</span> is an optional quick summary description
--- and can't be more than 48 characters.</p><p class="desc">
--- <span class="arg">long_desc</span> is an optional long description.
--- ```lua
--- settings.add("myscript.myabc", true, "Boolean setting")
--- settings.add("myscript.mydef", 100, "Number setting")
--- settings.add("myscript.myghi", "abc", "String setting")
--- settings.add("myscript.myjkl", {"x","y","z"}, "Enum setting")
--- settings.add("color.mymno", "bright magenta", "Color setting")
--- ```
---@param name string
---@param default ...
---@param short_desc string
---@param long_desc string
---@return boolean
---@overload fun(name: string, default: ..., short_desc: string): boolean
---@overload fun(name: string, default: ..., long_desc: string): boolean
---@overload fun(name: string, default: ...): boolean
function settings.add(name, default, short_desc, long_desc) end

--- v1.0.0 or newer
---
--- Returns the current value of the <span class="arg">name</span> Clink
--- setting or nil if the setting does not exist.</p><p class="desc">
--- The return type corresponds to the setting type:
--- <ul>
--- <li>Boolean settings return a boolean value.
--- <li>Integer settings return an integer value.
--- <li>Enum settings return an integer value corresponding to a position in the
--- setting's table of accepted values.  The first position is 0, the second
--- position is 1, etc.
--- <li>String settings return a string.
--- <li>Color settings return a string.
--- </ul></p><p class="desc">
--- Color settings normally return the ANSI color code, suitable for use in an
--- ANSI escape sequence.  If the optional <span class="arg">descriptive</span>
--- parameter is true then the friendly color name is returned.
--- ```lua
--- print(settings.get("color.doskey"))         -- Can print "1;36"
--- print(settings.get("color.doskey", true))   -- Can print "bold cyan"
--- ```
---@param name string
---@param descriptive boolean
---@return boolean | string | integer | nil
---@overload fun(name: string): boolean | string | integer | nil
function settings.get(name, descriptive) end

--- v1.0.0 or newer
---
--- Sets the <span class="arg">name</span> Clink setting to
--- <span class="arg">value</span> and returns whether it was successful.</p><p class="desc">
--- The type of <span class="arg">value</span> depends on the type of the
--- setting.  Some automatic type conversions are performed when appropriate.</p><p class="desc">
--- <ul>
--- <li>Boolean settings convert string values
--- <code>"true"</code>/<code>"false"</code>,
--- <code>"yes"</code>/<code>"no"</code>, and
--- <code>"on"</code>/<code>"off"</code> into a boolean
--- <code>true</code>/<code>false</code>.  Any numeric values are converted to
--- <code>true</code>, even <code>0</code> (Lua considers 0 to be true, unlike
--- some other languages).
--- <li>Integer settings convert string values starting with a digit or minus
--- sign into an integer value.
--- <li>Enum settings convert the allowed string values into an integer value
--- corresponding to the position in the table of allowed values.  The first
--- position is 0, the second position is 1, etc.
--- <li>String settings convert boolean or number values into a corresponding
--- string value.
--- <li>Color settings convert boolean or number values into a corresponding
--- string value.
--- </ul></p><p class="desc">
--- Note: Beginning in Clink v1.2.31 this updates the settings file.  Prior to
--- that, it was necessary to separately use <code>clink set</code> to update
--- the settings file.
---@param name string
---@param value ...
---@return boolean
function settings.set(name, value) end

--- v1.3.41 or newer
---
--- Returns true if <span class="arg">a</code> sorts as "less than"
--- <span class="arg">b</code>.</p><p class="desc">
--- The <span class="arg">a_type</code> and <span class="arg">b_type</code> are
--- optional, and affect the sort order accordingly when present.</p><p class="desc">
--- This produces the same sort order as normally used for displaying matches.
--- This can be used for manually sorting a subset of matches when a match
--- builder has been told not to sort the list of matches.
--- ```lua
--- local files = {
---    { match="xyzFile", type="file" },
---    { match="abcFile", type="file" },
--- }
--- local other = {
---    { match="abc_branch", type="arg" },
---    { match="xyz_branch", type="arg" },
---    { match="mno_tag", type="alias" },
--- }
--- 
--- local function comparator(a, b)
---    return string.comparematches(a.match, a.type, b.match, b.type)
--- end
--- 
--- -- Sort files.
--- table.sort(files, comparator)
--- 
--- -- Sort branches and tags together.
--- table.sort(other, comparator)
--- 
--- match_builder:setnosort()           -- Disable automatic sorting.
--- match_builder:addmatches(files)     -- Add the sorted files.
--- match_builder:addmatches(other)     -- Add the branches and tags files.
--- 
--- -- The overall sort order ends up listing all the files in sorted
--- -- order, followed by branches and tags sorted together.
--- ```
---@param a string
---@param a_type string
---@param b string
---@param b_type string
---@return boolean
---@overload fun(a: string, a_type: string, b: string): boolean
---@overload fun(a: string, b: string, b_type: string): boolean
---@overload fun(a: string, b: string): boolean
function string.comparematches(a, a_type, b, b_type) end

--- v1.1.20 or newer
---
--- Performs a case insensitive comparison of the strings with international
--- linguistic awareness.  This is more efficient than converting both strings
--- to lowercase and comparing the results.
---@param a string
---@param b string
---@return boolean
function string.equalsi(a, b) end

--- v1.0.0 or newer
---
--- Splits <span class="arg">text</span> delimited by
--- <span class="arg">delims</span> (or by spaces if not provided) and returns a
--- table containing the substrings.</p><p class="desc">
--- The optional <span class="arg">quote_pair</span> can provide a beginning
--- quote character and an ending quote character.  If only one character is
--- provided it is used as both a beginning and ending quote character.
---@param text string
---@param delims string
---@param quote_pair string
---@return table
---@overload fun(text: string, delims: string): table
---@overload fun(text: string, quote_pair: string): table
---@overload fun(text: string): table
function string.explode(text, delims, quote_pair) end

--- v1.0.0 or newer
---
--- Returns a hash of the input <span class="arg">text</span>.
---@param text string
---@return integer
function string.hash(text) end

--- v1.1.20 or newer
---
--- Returns how many characters match at the beginning of the strings, or -1 if
--- the entire strings match.  This respects the
--- <code><a href="#match_ignore_case">match.ignore_case</a></code> and
--- <code><a href="#match_ignore_accent">match.ignore_accent</a></code> Clink
--- settings.
--- ```lua
--- string.matchlen("abx", "a")         -- returns 1
--- string.matchlen("abx", "aby")       -- returns 2
--- string.matchlen("abx", "abx")       -- returns -1
--- ```
---@param a string
---@param b string
---@return integer
function string.matchlen(a, b) end

---@class clink.unicode
_G.unicode = {}

--- v1.3.27 or newer
---
--- This converts <span class="arg">text</span> from the
--- <span class="arg">codepage</span> encoding to UTF8.</p><p class="desc">
--- When <span class="arg">codepage</span> is omitted, the current Active Code
--- Page is used.</p><p class="desc">
--- If the text cannot be converted, nil is returned.</p><p class="desc">
--- <strong>Note:</strong>  Clink uses UTF8 internally, and conversion to/from
--- other encodings is intended for use with file input/output or network
--- input/output.
---@param text string
---@param codepage integer
---@return string | nil
---@overload fun(text: string): string | nil
function unicode.fromcodepage(text, codepage) end

--- v1.3.26 or newer
---
--- Returns whether <span class="arg">text</span> is already normalized
--- according to the Unicode normalization <span class="arg">form</span>:</p><p class="desc">
--- <ul>
--- <li><code>1</code> is Unicode normalization form C, canonical composition.
--- Transforms each base character + combining characters into the precomposed
--- equivalent.  For example, A + umlaut becomes Ä.
--- <li><code>2</code> is Unicode normalization form D, canonical decomposition.
--- Transforms each precomposed character into base character + combining
--- characters.  For example, Ä becomes A + umlaut.
--- <li><code>3</code> is Unicode normalization form KC, compatibility
--- composition.  Transforms each base character + combining characters into the
--- precomposed equivalent, and transforms compatibility characters into their
--- equivalents.  For example, A + umlaut + ligature for "fi" becomes Ä + f + i.
--- <li><code>4</code> is Unicode normalization form KD, compatibility
--- decomposition.  Transforms each precomposed character into base character +
--- combining characters, and transforms compatibility characters to their
--- equivalents.  For example, Ä + ligature for "fi" becomes A + umlaut + f + i.
--- </ul></p><p class="desc">
--- If successful, true or false is returned.</p><p class="desc">
--- If unsuccessful, false and an error code are returned.
---@param form integer
---@param text string
---@return boolean
---@return integer?
function unicode.isnormalized(form, text) end

--- v1.3.26 or newer
---
--- This returns an iterator which steps through <span class="arg">text</span>
--- one Unicode codepoint at a time.  Each call to the iterator returns the
--- string for the next codepoint, the numeric value of the codepoint, and a
--- boolean indicating whether the codepoint is a combining mark.
--- ```lua
--- -- UTF8 sample string:
--- -- Index by codepoint:   1       2       3           4       5
--- -- Unicode character:    à       é       ᴆ           õ       û
--- local text            = "\xc3\xa0\xc3\xa9\xe1\xb4\x86\xc3\xb5\xc3\xbb"
--- -- Index by byte:        1   2   3   4   5   6   7   8   9   10  11
--- 
--- for str, value, combining in unicode.iter(text) do
---    -- Note that the default lua print() function is not fully aware
---    -- of Unicode, so clink.print() is needed to print Unicode text.
---    local bytes = ""
---    for i = 1, #str do
---        bytes = bytes .. string.format("\\x%02x", str:byte(i, i))
---    end
---    clink.print(str, value, combining, bytes)
--- end
--- 
--- -- The above prints the following:
--- --      à       224     false   \xc3\xa0
--- --      é       233     false   \xc3\xa9
--- --      ᴆ       7430    false   \xe1\xb4\x86
--- --      õ       245     false   \xc3\xb5
--- --      û       373     false   \xc3\xbb
--- ```
---@param text string
---@return  string
function unicode.iter(text) end

--- v1.3.26 or newer
---
--- Transforms the <span class="arg">text</span> according to the Unicode
--- normalization <span class="arg">form</span>:</p><p class="desc">
--- <ul>
--- <li><code>1</code> is Unicode normalization form C, canonical composition.
--- Transforms each base character + combining characters into the precomposed
--- equivalent.  For example, A + umlaut becomes Ä.
--- <li><code>2</code> is Unicode normalization form D, canonical decomposition.
--- Transforms each precomposed character into base character + combining
--- characters.  For example, Ä becomes A + umlaut.
--- <li><code>3</code> is Unicode normalization form KC, compatibility
--- composition.  Transforms each base character + combining characters into the
--- precomposed equivalent, and transforms compatibility characters into their
--- equivalents.  For example, A + umlaut + ligature for "fi" becomes Ä + f + i.
--- <li><code>4</code> is Unicode normalization form KD, compatibility
--- decomposition.  Transforms each precomposed character into base character +
--- combining characters, and transforms compatibility characters to their
--- equivalents.  For example, Ä + ligature for "fi" becomes A + umlaut + f + i.
--- </ul></p><p class="desc">
--- If successful, the resulting string is returned.</p><p class="desc">
--- If unsuccessful, both the original string and an error code are returned.
---@param form integer
---@param text string
---@return string
---@return integer?
function unicode.normalize(form, text) end

--- v1.3.27 or newer
---
--- This converts <span class="arg">text</span> from UTF8 to the
--- <span class="arg">codepage</span> encoding.</p><p class="desc">
--- When <span class="arg">codepage</span> is omitted, the current Active Code
--- Page is used.</p><p class="desc">
--- If the text cannot be converted, nil is returned.</p><p class="desc">
--- <strong>Note:</strong>  Clink uses UTF8 internally, and conversion to/from
--- other encodings is intended for use with file input/output or network
--- input/output.
---@param text string
---@param codepage integer
---@return string | nil
---@overload fun(text: string): string | nil
function unicode.tocodepage(text, codepage) end

---@class clink.word_classifications
_G.word_classifications = {}

--- v1.1.49 or newer
---
--- Applies an ANSI <a href="https://en.wikipedia.org/wiki/ANSI_escape_code#SGR">SGR escape code</a>
--- to some characters in the input line.</p><p class="desc">
--- <span class="arg">start</span> is where to begin applying the SGR code.</p><p class="desc">
--- <span class="arg">length</span> is the number of characters to affect.</p><p class="desc">
--- <span class="arg">color</span> is the SGR parameters sequence to apply (for example <code>"7"</code> is the code for reverse video, which swaps the foreground and background colors).</p><p class="desc">
--- By default the color is applied to the characters even if some of them are
--- already colored.  But if <span class="arg">overwrite</span> is
--- <code>false</code> each character is only colored if it hasn't been yet.</p><p class="desc">
--- See <a href="#classifywords">Coloring the Input Text</a> for more
--- information.</p><p class="desc">
--- Note: an input line can have up to 100 different unique color strings
--- applied, and then this stops applying new colors.  The counter gets reset
--- when the onbeginedit event is sent.
---@param start integer
---@param length integer
---@param color string
---@param overwrite boolean
---@overload fun(start: integer, length: integer, color: string)
function word_classifications:applycolor(start, length, color, overwrite) end

--- v1.1.18 or newer
---
--- This classifies the indicated word so that it can be colored appropriately.</p><p class="desc">
--- The <span class="arg">word_class</span> is one of the following codes:</p><p class="desc">
--- <table>
--- <tr><th>Code</th><th>Classification</th><th>Clink Color Setting</th></tr>
--- <tr><td><code>"a"</code></td><td>Argument; used for words that match a list of preset argument matches.</td><td><code><a href="#color_arg">color.arg</a></code> or <code><a href="#color_input">color.input</a></code></td></tr>
--- <tr><td><code>"c"</code></td><td>Shell command; used for CMD command names.</td><td><code><a href="#color_cmd">color.cmd</a></code></td></tr>
--- <tr><td><code>"d"</code></td><td>Doskey alias.</td><td><code><a href="#color_doskey">color.doskey</a></code></td></tr>
--- <tr><td><code>"f"</code></td><td>Flag; used for flags that match a list of preset flag matches.</td><td><code><a href="#color_flag">color.flag</a></code></td></tr>
--- <tr><td><code>"x"</code></td><td>Executable; used for the first word when it is not a command or doskey alias, but is an executable name that exists.</td><td><code><a href="#color_executable">color.executable</a></code></td></tr>
--- <tr><td><code>"u"</code></td><td>Unrecognized; used for the first word when it is not a command, doskey alias, or recognized executable name.</td><td><code><a href="#color_unrecognized">color.unrecognized</a></code></td></tr>
--- <tr><td><code>"o"</code></td><td>Other; used for file names and words that don't fit any of the other classifications.</td><td><code><a href="#color_input">color.input</a></code></td></tr>
--- <tr><td><code>"n"</code></td><td>None; used for words that aren't recognized as part of the expected input syntax.</td><td><code><a href="#color_unexpected">color.unexpected</a></code></td></tr>
--- <tr><td><code>"m"</code></td><td>Prefix that can be combined with another code (for the first word) to indicate the command has an argmatcher (e.g. <code>"mc"</code> or <code>"md"</code>).</td><td><code><a href="#color_argmatcher">color.argmatcher</a></code> or the other code's color</td></tr>
--- </table></p><p class="desc">
--- By default the classification is applied to the word even if the word has
--- already been classified.  But if <span class="arg">overwrite</span> is
--- <code>false</code> the word is only classified if it hasn't been yet.</p><p class="desc">
--- See <a href="#classifywords">Coloring the Input Text</a> for more
--- information.
---@param word_index integer
---@param word_class string
---@param overwrite boolean
---@overload fun(word_index: integer, word_class: string)
function word_classifications:classifyword(word_index, word_class, overwrite) end

--- v1.0.0 or newer
---
--- Breaks into the Lua debugger, if the
--- <code><a href="#lua_debug">lua.debug</a></code> setting is enabled.</p><p class="desc">
--- If <code>pause()</code> is used by itself, the debugger breaks on the line
--- after the pause call.</p><p class="desc">
--- The <span class="arg">message</span> argument can be a message the debugger
--- will display, for example to differentiate between multiple pause calls.</p><p class="desc">
--- The <span class="arg">lines</span> argument indicates how many lines to step
--- further before breaking into the debugger.  The default is nil, which breaks
--- on the line immediately following the pause call.  Passing an integer value
--- will step some number of lines before breaking (this will produce confusing
--- results and is discouraged).</p><p class="desc">
--- When the <span class="arg">force</span> argument is <code>true</code> then
--- it will break into the debugger even if the <code>poff</code> debugger
--- command has been used to turn off the pause command.
---@param message string
---@param lines integer
---@param force boolean
---@overload fun(message: string, lines: integer)
---@overload fun(message: string, force: boolean)
---@overload fun(message: string)
---@overload fun(lines: integer, force: boolean)
---@overload fun(lines: integer)
---@overload fun(force: boolean)
---@overload fun()
function pause(message, lines, force) end

---@deprecated
---@see _argmatcher.addarg
--- Adds one argument slot per table passed to it (as v0.4.9 did).</p><p class="desc">
--- <strong>Note:</strong> v1.3.10 and lower <code>:add_arguments()</code>
--- mistakenly added all arguments into the first argument slot.
function _argmatcher:add_arguments() end

---@deprecated
---@see _argmatcher.addflags
function _argmatcher:add_flags() end

---@return clink._argmatcher
function _argmatcher:be_precise() end

---@deprecated
---@see _argmatcher.nofiles
---@return clink._argmatcher
function _argmatcher:disable_file_matching() end

---@deprecated
---@see _argmatcher.addarg
--- Sets one argument slot per table passed to it (as v0.4.9 did).</p><p class="desc">
--- <strong>Note:</strong> v1.3.10 and lower <code>:add_arguments()</code>
--- mistakenly set all arguments into the first argument slot.
---@param ... string|table # choices
---@return clink._argmatcher
function _argmatcher:set_arguments(...) end

---@deprecated
---@see _argmatcher.addflags
--- <strong>Note:</strong>  The new API has no way to remove flags that were
--- previously added, so converting from <code>:set_flags()</code> to
--- <code>:addflags()</code> may require the calling script to reorganize how
--- and when it adds flags.
---@param ... string # flags
---@return clink._argmatcher
function _argmatcher:set_flags(...) end

---@deprecated
---@see builder.addmatch
--- This is a shim that lets clink.register_match_generator continue to work
--- for now, despite being obsolete.
---@param match string
---@return nil
function clink.add_match(match) end

--- v1.2.10 or newer
---
--- Prior to v1.3.1 this was undocumented, and coroutines had to be manually
--- added in order to be scheduled for resume while waiting for input.  Starting
--- in v1.3.1 this is no longer necessary, but it can still be used to override
--- the interval at which to resume the coroutine.
---@param coroutine thread
---@param interval number
---@overload fun(coroutine: thread)
function clink.addcoroutine(coroutine, interval) end

---@deprecated
---@see clink.argmatcher
--- Creates a new parser and adds <span class="arg">...</span> to it.
--- ```lua
--- -- Deprecated form:
--- local parser = clink.arg.new_parser(
---  { "abc", "def" },       -- arg position 1
---  { "ghi", "jkl" },       -- arg position 2
---  "--flag1", "--flag2"    -- flags
--- )
--- 
--- -- Replace with form:
--- local parser = clink.argmatcher()
--- :addarg("abc", "def")               -- arg position 1
--- :addarg("ghi", "jkl")               -- arg position 2
--- :addflags("--flag1", "--flag2")     -- flags
--- ```
---@param ... any
---@return table
function clink.arg.new_parser(...) end

---@deprecated
---@see clink.argmatcher
--- Adds <span class="arg">parser</span> to the argmatcher for
--- <span class="arg">cmd</span>.</p><p class="desc">
--- If there is already an argmatcher for <span class="arg">cmd</span> then the
--- two argmatchers are merged.  It is only a simple merge; a more sophisticated
--- merge would be much slower and use much more memory.  The simple merge
--- should be sufficient for common simple cases.</p><p class="desc">
--- <strong>Note:</strong> In v1.3.11, merging parsers should be a bit improved
--- compared to how v0.4.9 merging worked.  In v1.0 through v1.3.10, merging
--- parsers doesn't work very well.
--- ```lua
--- -- Deprecated form:
--- local parser1 = clink.arg.new_parser():set_arguments({ "abc", "def" }, { "old_second" })
--- local parser2 = clink.arg.new_parser():set_arguments({ "ghi", "jkl" }, { "new_second" })
--- clink.arg.register_parser("foo", parser1)
--- clink.arg.register_parser("foo", parser2)
--- -- In v0.4.9 that syntax only merged the first argument position, and "ghi" and
--- -- "jkl" ended up with no further arguments.  In v1.3.11 and higher that syntax
--- -- ends up with "ghi" and "jkl" having only "old_second" as a second argument.
--- 
--- -- Replace with new form:
--- clink.argmatcher("foo"):addarg(parser1)
--- clink.argmatcher("foo"):addarg(parser2)
--- -- In v1.3.11 and higher this syntax ends up with all 4 first argument strings
--- -- having both "old_second" and "new_second" as a second argument.
--- ```
---@param cmd string
---@param parser table
---@return table
function clink.arg.register_parser(cmd, parser) end

---@deprecated
---@see os.chdir
---@param path string
---@return boolean
function clink.chdir(path) end

--- This is no longer supported, and always returns an empty string.</p><p class="desc">
--- Returning an empty string works because in Clink v1.x and higher match
--- generators are no longer responsible for filtering matches.  The match
--- pipeline itself handles that internally now.
---@param text string
---@param matches table
---@return string
function clink.compute_lcd(text, matches) end

---@deprecated
---@see os.globdirs
--- The <span class="arg">case_map</span> argument is ignored, because match
--- generators are no longer responsible for filtering matches.  The match
--- pipeline itself handles that internally now.
---@param mask string
---@param case_map boolean
---@overload fun(mask: string)
function clink.find_dirs(mask, case_map) end

---@deprecated
---@see os.globfiles
--- The <span class="arg">case_map</span> argument is ignored, because match
--- generators are no longer responsible for filtering matches.  The match
--- pipeline itself handles that internally now.
---@param mask string
---@param case_map boolean
---@overload fun(mask: string)
function clink.find_files(mask, case_map) end

---@deprecated
---@see os.getaliases
function clink.get_console_aliases() end

---@deprecated
---@see os.getcwd
function clink.get_cwd() end

---@deprecated
---@see os.getcwd
---@return string
function clink.get_cwd() end

---@deprecated
---@see os.getenv
function clink.get_env() end

---@deprecated
---@see os.getenvnames
function clink.get_env_var_names() end

--- Always returns "clink"; this corresponds to the "clink" word in the
--- <code>$if clink</code> directives in Readline's .inputrc file.
function clink.get_host_process() end

--- This is no longer supported, and always returns an empty string.  If a
--- script needs to access matches it added, the script should keep track of the
--- matches itself.
---@param index integer
---@return string
function clink.get_match(index) end

---@deprecated
---@see rl.getvariable
function clink.get_rl_variable() end

---@deprecated
---@see os.getscreeninfo
--- <strong>Note:</strong> The field names are different between
--- <code>os.getscreeninfo()</code> and the v0.4.9 implementation of
--- <code>clink.get_screen_info</code>.
function clink.get_screen_info() end

---@deprecated
---@see settings.get
function clink.get_setting_int() end

---@deprecated
---@see settings.get
function clink.get_setting_str() end

---@deprecated
---@see os.isdir
function clink.is_dir() end

---@deprecated
---@see clink.generator
--- This returns true if <span class="arg">needle</span> is a prefix of
--- <span class="arg">candidate</span> with a case insensitive comparison.</p><p class="desc">
--- Normally in Clink v1.x and higher the <span class="arg">needle</span> will
--- be an empty string because match generators are no longer responsible for
--- filtering matches.  The match pipeline itself handles that internally now.
---@param needle string
---@param candidate string
---@return boolean
function clink.is_match(needle, candidate) end

---@deprecated
---@see rl.isvariabletrue
function clink.is_rl_variable_true() end

--- This is no longer supported, and always returns false.
---@param matches table
---@return boolean
function clink.is_single_match(matches) end

--- This is no longer supported, and always returns 0.  If a script needs to
--- know how many matches it added, the script should keep track of the count
--- itself.
---@return integer
function clink.match_count() end

---@deprecated
---@see clink.ondisplaymatches
--- A match generator can set this varible to a filter function that is called
--- before displaying matches.  It is reset every time match generation is
--- invoked.  The filter function receives table argument containing the matches
--- that are going to be displayed, and it returns a table filtered as required
--- by the match generator.</p><p class="desc">
--- See <a href="#filteringthematchdisplay">Filtering the Match Display</a> for
--- more information.
function clink.match_display_filter() end

---@deprecated
---@see clink.filematches
--- Globs files using <span class="arg">pattern</span> and adds results as
--- matches. If <span class="arg">full_path</span> is true then the path from
--- <span class="arg">pattern</span> is prefixed to the results (otherwise only
--- the file names are included). The last argument
--- <span class="arg">find_func</span> is the function to use to do the
--- globbing. If it's unspecified (or nil) Clink falls back to
--- <a href="#clink.find_files">clink.find_files</a>.</p><p class="desc">
--- <strong>Note:</strong> This exists for backward compatibility but
--- malfunctions with some inputs, in the same ways it did in v0.4.9.
---@param pattern string
---@param full_path boolean
---@param find_func function
---@overload fun(pattern: string, full_path: boolean)
---@overload fun(pattern: string, find_func: function)
---@overload fun(pattern: string)
function clink.match_files(pattern, full_path, find_func) end

---@deprecated
---@see builder.addmatches
--- This adds words that match the text.
---@param text string
---@param words table
function clink.match_words(text, words) end

---@deprecated
---@see builder.addmatch
--- This is only needed when using deprecated APIs.  It's automatically inferred
--- from the match types when using the current APIs.
---@param files boolean
---@overload fun()
function clink.matches_are_files(files) end

---@deprecated
---@see clink.promptfilter
--- Registers a prompt filter function.  The capabilities are the same as before
--- but the syntax is changed.
--- ```lua
--- -- Deprecated form:
--- function foo_prompt()
---  clink.prompt.value = "FOO "..clink.prompt.value.." >>"
---  --return true  -- Returning true stops further filtering.
--- end
--- clink.prompt.register_filter(foo_prompt, 10)
--- 
--- -- Replace with new form:
--- local foo_prompt = clink.promptfilter(10)
--- function foo_prompt:filter(prompt)
---  return "FOO "..prompt.." >>" --,false  -- Adding ,false stops further filtering.
--- end
--- ```
---@param filter_func function
---@param priority integer
---@return table
---@overload fun(filter_func: function): table
function clink.prompt.register_filter(filter_func, priority) end

---@deprecated
---@see string.explode
--- This function takes the string <span class="arg">str</span> which is quoted
--- by <span class="arg">ql</span> (the opening quote character) and
--- <span class="arg">qr</span> (the closing character) and splits it into parts
--- as per the quotes. A table of these parts is returned.
---@param str string
---@param ql string
---@param qr string
---@return table
function clink.quote_split(str, ql, qr) end

---@deprecated
---@see clink.generator
--- Registers a generator function for producing matches.  This behaves
--- similarly to v0.4.8, but not identically.  The Clink schema has changed
--- significantly enough that there is no direct 1:1 translation; generators are
--- called at a different time than before and have access to more information
--- than before.
--- ```lua
--- -- Deprecated form:
--- local function match_generator_func(text, first, last)
---  -- `text` is the word text.
---  -- `first` is the index of the beginning of the end word.
---  -- `last` is the index of the end of the end word.
---  -- `clink.add_match()` is used to add matches.
---  -- return true if handled, or false to let another generator try.
--- end
--- clink.register_match_generator(match_generator_func, 10)
--- 
--- -- Replace with new form:
--- local g = clink.generator(10)
--- function g:generate(line_state, match_builder)
---  -- `line_state` is a <a href="#line_state">line_state</a> object.
---  -- `match_builder:<a href="#builder:addmatch">addmatch</a>()` is used to add matches.
---  -- return true if handled, or false to let another generator try.
--- end
--- ```
---@param func function
---@param priority integer
function clink.register_match_generator(func, priority) end

--- This is no longer supported, and does nothing.
---@param index integer
---@param value string
function clink.set_match(index, value) end

---@deprecated
---@see clink.translateslashes
--- Controls how Clink will translate the path separating slashes for the
--- current path being completed. Values for <span class="arg">type</span> are;
--- <ul>
--- <li>-1 - no translation</li>
--- <li>0 - to backslashes</li>
--- <li>1 - to forward slashes</li>
--- </ul>
---@param type integer
function clink.slash_translation(type) end

---@deprecated
---@see string.explode
--- Splits the string <span class="arg">str</span> into pieces separated by
--- <span class="arg">sep</span>, returning a table of the pieces.
---@param str string
---@param sep string
---@return table
function clink.split(str, sep) end

---@deprecated
---@see builder.setsuppressappend
function clink.suppress_char_append() end

---@deprecated
---@see builder.setsuppressquoting
function clink.suppress_quoting() end

---@deprecated
---@see os.globfiles
--- Returns whether <span class="arg">path</span> has the hidden attribute set.
---@param path string
---@return boolean
function os.ishidden(path) end

---@deprecated
---@see line_state
--- This is an obsolete global variable that was set while running match
--- generators.  It has been superseded by the
--- <a href="#line_state">line_state</a> type parameter passed into match
--- generator functions when using the new
--- <a href="#clink.generator">clink.generator()</a> API.
---@type table
_G.rl_state = {}

