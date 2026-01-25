# Development Guide - spring-initializr.nvim

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Development Setup](#development-setup)
- [Code Organization](#code-organization)
- [Testing](#testing)
- [Code Style](#code-style)
- [Adding Features](#adding-features)
- [Debugging](#debugging)

## Architecture Overview

### High-Level Design

### Component Responsibilities

1. **Commands** (`commands/`)
   - Register Neovim user commands
   - Bridge between user actions and plugin logic

2. **Core** (`core/`)
   - Business logic for project generation

3. **UI** (`ui/`)
   - Layout and component rendering
   - Focus management and navigation
   - User input handling

4. **Metadata** (`metadata/`)
   - Fetch and cache Spring Initializr metadata
   - Async HTTP requests to start.spring.io

5. **Telescope** (`telescope/`)
   - Dependency picker integration
   - Manages selected dependencies state

6. **Utils** (`utils/`)
   - Reusable utility functions
   - HTTP, file, URL, window, and message helpers

7. **Algo** (`algo/`)
   - Data structures (HashSet)
   - Generic algorithms

8. **Styles** (`styles/`)
   - Highlight configuration
   - Theme integration
## Development Setup

### 1. Clone the Repository

```bash
git clone https://github.com/jkeresman01/spring-initializr.nvim.git
cd spring-initializr.nvim
```

### 2. Install Dependencies

#### Plugin Dependencies

Install these in your Neovim:

```lua
-- In your plugin manager
{
  'nvim-lua/plenary.nvim',
  'MunifTanjim/nui.nvim',
  'nvim-telescope/telescope.nvim'
}
```

#### Development Tools

```bash
# Lua formatting
cargo install stylua --locked --version 0.20.0

# Lua linting
sudo apt-get install luarocks
sudo luarocks install luacheck
```

### 3. Local Development

Load the plugin locally:

```lua
-- In your Neovim config (e.g., ~/.config/nvim/init.lua)
vim.opt.rtp:prepend("~/path/to/spring-initializr.nvim")

require('spring-initializr').setup()
```

Or use a plugin manager's local plugin support:

```lua
-- With lazy.nvim
{
  dir = "~/path/to/spring-initializr.nvim",
  dependencies = { ... },
  config = function()
    require('spring-initializr').setup()
  end
}
```

## Code Organization && Guideline

Code should follow clean code principle.
Commit messages, PR messages must follow git naming convention
Imperative, up to 80 chars, notice how git behaves the same when 
you revert smth: Revert some commit.

### Naming Conventions

#### File Naming

- **Utils**: Must end with `_utils.lua` (enforced by `scripts/check-naming.sh`)
  - `file_utils.lua`
  - `http_utils.lua`
  - `file.lua`
  - `http.lua`

- **Styles**: Must be in `styles/` directory
  - `styles/highlights.lua`
  - `utils/highlights.lua`

#### Module Structure

Each module follows this pattern:

```lua
---------------------------------------------------------------------------
-- Copyright header
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Module description
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Dependencies
---------------------------------------------------------------------------
local dependency = require('module')

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------
local CONSTANT_NAME = "value"

---------------------------------------------------------------------------
-- Module table
---------------------------------------------------------------------------
local M = {}

---------------------------------------------------------------------------
-- Private functions
---------------------------------------------------------------------------
local function private_function()
    -- Implementation
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------
function M.public_function()
    -- Implementation
end

---------------------------------------------------------------------------
-- Exports
---------------------------------------------------------------------------
return M
```

### Code Style Guidelines

#### 1. Function Documentation

```lua
----------------------------------------------------------------------------
--
-- Brief description of what the function does.
--
-- @param  param1  type    Description
-- @param  param2  type    Description
--
-- @return type            Description
--
----------------------------------------------------------------------------
function M.example_function(param1, param2)
    -- Implementation
end
```

#### 2. Single Responsibility Principle

Break large functions into smaller, focused functions:

```lua
-- Bad: One large function
function M.generate_project()
    local params = { ... }
    local url = SPRING_DOWNLOAD_URL .. "?" .. encode_query(params)
    local zip_path = vim.fn.getcwd() .. "/spring-init.zip"
    http_utils.download_file(url, zip_path, function()
        zip_utils.unzip(zip_path, vim.fn.getcwd(), function()
            ui.close()
            message_utils.show_info_message("Done")
        end)
    end, function()
        message_utils.show_error_message("Failed")
    end)
end

-- Good: Multiple focused functions
local function collect_params()
    -- ...
end

local function make_download_url(params)
    -- ...
end

local function notify_success()
    -- ...
end

local function extract_zip_to_dest(zip_path, dest)
    -- ...
end

function M.generate_project()
    local params = collect_params()
    local url = make_download_url(params)
    -- ... rest of orchestration
end
```

#### 3. Error Handling

Always handle errors gracefully:

```lua
-- Use pcall for potentially failing operations
local ok, result = pcall(vim.json.decode, output)
if not ok then
    return nil, "Failed to parse JSON"
end

-- Provide meaningful error messages
if not data then
    message_utils.show_error_message("Failed to load metadata: " .. (err or "unknown"))
    return
end
```

#### 4. Async Operations

Use vim.schedule for UI updates from async contexts:

```lua
Job:new({
    command = "curl",
    args = { ... },
    on_exit = function(j)
        vim.schedule(function()
            -- Safe to update UI here
            update_ui(j:result())
        end)
    end,
}):start()
```

### Managing Module Dependencies and Coupling

When passing dependencies between modules, follow these principles to maintain loose coupling:

#### Bad: Tight Coupling (Passing Entire Module)

```lua
-- In ui/init.lua
local function activate_ui()
    focus_manager.enable_navigation(M)  -- Passing entire module
end

-- In focus_manager.lua
function M.enable_navigation(main_ui)
    for _, comp in ipairs(M.focusables) do
        buffer_manager.register_close_key(comp, main_ui)  -- Passing entire module
    end
end

-- In buffer_manager.lua
function M.register_close_key(comp, main_ui)
    comp:map("n", "q", function()
        main_ui.close()  -- Depends on module structure
    end, { noremap = true, nowait = true })
end
```

**Problems with this approach:**
- `focus_manager` and `buffer_manager` depend on the entire `ui/init` module structure
- Unclear what parts of the module are actually needed
- Increases risk of circular dependencies
- Violates the Dependency Inversion Principle

#### Good: Loose Coupling (Passing Only What's Needed)

```lua
-- In ui/init.lua
local function activate_ui()
    M.state.layout:mount()
    M.state.is_open = true
    focus_manager.enable_navigation(M.close)  -- Pass only the function
    dependencies_display.update_display()
    buffer_utils.setup_close_on_buffer_delete(
        focus_manager.focusables,
        M.state.outer_popup,
        M.close
    )
    focus_manager.focus_first()
end
```

```lua
-- In focus_manager.lua
function M.enable_navigation(close_fn)
    for _, comp in ipairs(M.focusables) do
        map_navigation_keys(comp)
        buffer_manager.register_close_key(comp, close_fn)  -- Pass function
    end
end
```

```lua
-- In buffer_manager.lua
function M.register_close_key(comp, close_fn)
    comp:map("n", "q", function()
        close_fn()  -- Call the function directly
    end, { noremap = true, nowait = true })
end
```

```lua
-- In dependencies/dependencies_display.lua
function M.create_display(close_fn)
    local popup = Popup(display_popup_config())
    M.state.dependencies_panel = popup
    buffer_manager.register_close_key(popup, close_fn)
    return popup
end
```

**Benefits of this approach:**

1. **Loose Coupling**: Modules only depend on what they actually need (a close function)
2. **Clear Interface**: The function signature clearly shows what's required
4. **Better Encapsulation**: Implementation details of `ui/init` remain hidden
5. **Follows Dependency Inversion Principle**: Depending on abstractions (functions) not concrete modules
```

### Using the Logging API

Import the logging module in any file:
```lua
local log = require("spring-initializr.trace.log")
```

#### Basic Logging
```lua
-- Simple messages
log.trace("Entering function")
log.debug("Processing item")
log.info("Operation completed")
log.warn("Deprecated API used")
log.error("Failed to connect")
log.fatal("Critical system failure")

-- Multiple arguments (will be concatenated with spaces)
log.debug("User ID:", user_id, "Status:", status)

-- Logging tables (automatically uses vim.inspect)
log.debug("Configuration:", { host = "localhost", port = 8080 })
```

#### Formatted Logging

Use the `fmt_*` variants for string formatting:
```lua
log.fmt_info("Fetching metadata from %s", url)
log.fmt_debug("Processing %d dependencies", count)
log.fmt_error("HTTP error: %d - %s", status_code, error_message)
```

### Log Output Format

#### Console Output
```
[DEBUG] metadata/metadata.lua:123 - Fetching metadata from https://start.spring.io/...
[INFO] ui/init.lua:45 - UI activated successfully
[ERROR] utils/http_utils.lua:67 - Download failed with exit code: 1
```

#### File Output
```
[2025-01-15 14:32:01] [DEBUG] metadata/metadata.lua:123 - Fetching metadata from https://start.spring.io/...
[2025-01-15 14:32:02] [INFO] ui/init.lua:45 - UI activated successfully
[2025-01-15 14:32:05] [ERROR] utils/http_utils.lua:67 - Download failed with exit code: 1
```

## Testing

### Running Tests

```bash
# Run all tests
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests" +q

# Or from within Neovim
:lua require('plenary.busted').run()
```

### Test Structure

Tests use the Arrange-Act-Assert pattern:

```lua
describe("Module Name", function()
    it("does something", function()
        -- Arrange: Set up test data
        local input = "test"
        local expected = "TEST"
        
        -- Act: Execute the function
        local result = my_function(input)
        
        -- Assert: Verify the result
        assert.are.equal(expected, result)
    end)
end)
```

### Writing Tests

Create test files in `tests/` matching the module structure:

```lua
-- tests/utils/url_utils_spec.lua
local url_utils = require('spring-initializr.utils.url_utils')

describe("url_utils", function()
    describe("urlencode", function()
        it("encodes special characters", function()
            -- Arrange
            local input = "hello world"
            
            -- Act
            local result = url_utils.urlencode(input)
            
            -- Assert
            assert.are.equal("hello%20world", result)
        end)
    end)
end)
```

### Test Coverage Areas

Priority test areas:
1. Algo (HashSet) - fully tested
2. Utils - needs tests
3. Core logic - needs tests
4. UI components - needs tests

## Code Style

### Formatting

Format code with Stylua:

```bash
# Format all files
make fmt

# Or directly
stylua lua/ --config-path=.stylua.toml
```

Configuration (`.stylua.toml`):

```toml
column_width = 100
indent_type = "Spaces"
indent_width = 4
quote_style = "AutoPreferDouble"
```

### Linting

Lint code with Luacheck:

```bash
# Lint all files
make lint

# Or directly
luacheck lua/ --globals vim
```

Configuration (`.luacheckrc`):

```lua
files = { "lua/" }
std = "luajit"
globals = { "vim" }
codes = true
```

### Pre-Commit Checks

Before committing:

```bash
make pr-ready
```

This runs both formatting and linting.

## Adding Features

### Adding a New Utility Module

1. Create the file:

```lua
-- lua/spring-initializr/utils/my_utils.lua
local M = {}

function M.my_function()
    -- Implementation
end

return M
```

2. Write tests:

```lua
-- tests/utils/my_utils_spec.lua
local my_utils = require('spring-initializr.utils.my_utils')

describe("my_utils", function()
    it("works", function()
        assert.is_true(my_utils.my_function())
    end)
end)
```

3. Run tests and lint:

```bash
make pr-ready
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests" +q
```

### Adding a New UI Component

1. Create the component module:

```lua
-- lua/spring-initializr/ui/my_component.lua
local Popup = require('nui.popup')
local focus = require('spring-initializr.ui.focus')

local M = {}

function M.create_component()
    local popup = Popup({ ... })
    focus.register(popup)
    return popup
end

return M
```

2. Integrate into layout:

```lua
-- lua/spring-initializr/ui/layout.lua
local my_component = require('spring-initializr.ui.my_component')

-- In create_left_panel or create_right_panel
table.insert(children, my_component.create_component())
```

### Adding a New Command

1. Define the command:

```lua
-- lua/spring-initializr/commands/commands.lua
local CMD = {
    -- ...
    MY_NEW_COMMAND = "MyNewCommand",
}

function M.register_cmd_my_new_command()
    vim.api.nvim_create_user_command(CMD.MY_NEW_COMMAND, function()
        my_module.do_something()
    end, { desc = "Does something cool" })
end

function M.register()
    -- ...
    M.register_cmd_my_new_command()
end
```

## Debugging

### Enable Debug Messages

```lua
-- In your config
vim.o.cmdheight = 2  -- More space for messages
vim.lsp.set_log_level("debug")

-- Use debug messages
local message_utils = require('spring-initializr.utils.message_utils')
message_utils.show_debug_message("Debug info: " .. vim.inspect(data))
```

### View Messages

```vim
:messages        " View message history
:messages clear  " Clear messages
```

### Inspect Variables

```lua
-- Print to messages
print(vim.inspect(variable))

-- Notify with details
vim.notify(vim.inspect(data), vim.log.levels.INFO)
```

### Debug UI Components

```lua
-- Check window validity
if vim.api.nvim_win_is_valid(winid) then
    print("Window is valid")
end

-- Check buffer
if vim.api.nvim_buf_is_valid(bufnr) then
    print("Buffer is valid")
end

-- Get buffer lines
local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
print(vim.inspect(lines))
```

### Debug Async Operations

```lua
Job:new({
    command = "curl",
    args = { ... },
    on_exit = function(j, return_val)
        print("Exit code:", return_val)
        print("stdout:", vim.inspect(j:result()))
        print("stderr:", vim.inspect(j:stderr_result()))
    end,
}):start()
```

### Common Issues

#### Issue: UI not updating

**Solution**: Wrap updates in `vim.schedule`:

```lua
vim.schedule(function()
    update_ui()
end)
```

#### Issue: Focus not working

**Solution**: Check component registration:

```lua
-- Ensure component is registered
focus.register(my_component)

-- Check focusables list
print(vim.inspect(focus.focusables))
```

#### Issue: Metadata not loading

**Solution**: Check curl output:

```bash
curl -s https://start.spring.io/metadata/client
```


### Troubleshooting with Logs

#### Scenario 1: Metadata Not Loading

Enable debug logging and check the log file:
```bash
# In Neovim config
vim.g.spring_initializr_log_file = true
vim.g.spring_initializr_log_level = "debug"

# Open the log file
tail -f ~/.local/share/nvim/spring-initializr.log
```

Look for lines like:
```
[DEBUG] metadata/metadata.lua:X - fetch_metadata called
[INFO] metadata/metadata.lua:X - Fetching metadata from https://start.spring.io/...
[ERROR] metadata/metadata.lua:X - Network request failed
```

#### Scenario 2: Dependency Picker Issues
```lua
-- Add trace logging to see the flow
vim.g.spring_initializr_log_level = "trace"
```

You'll see detailed logs like:
```
[TRACE] telescope/telescope.lua:X - Recording dependency selection: web
[TRACE] telescope/telescope.lua:X - Adding dependency to set
[DEBUG] telescope/telescope.lua:X - Total dependencies selected: 1
```

#### Scenario 3: UI Navigation Problems
```bash
# Enable trace level to see every focus change
vim.g.spring_initializr_log_level = "trace"
```

Logs will show:
```
[TRACE] focus_manager.lua:X - Focusing next component
[DEBUG] focus_manager.lua:X - Current focus: 2/5
[TRACE] focus_manager.lua:X - Registering focusable component
```

### Performance Considerations

- Logging has **zero performance impact** when disabled (`use_console = false` and `use_file = false`)
- Log level filtering happens before message formatting, so debug/trace calls are cheap at higher levels
- File I/O is synchronous but buffered by the OS

### Best Practices for Adding Logs

1. **Log at appropriate levels**:
```lua
   log.trace("Loop iteration", i)          -- Very detailed
   log.debug("Variable value:", value)     -- Diagnostic info
   log.info("Operation completed")         -- Important milestones
   log.warn("Unexpected condition")        -- Warnings
   log.error("Operation failed:", err)     -- Errors
```

2. **Include context**:
```lua
   -- Bad
   log.error("Failed")
   
   -- Good
   log.error("Failed to download file from", url, ":", err)
```

3. **Use formatted logging for readability**:
```lua
   -- Easier to read
   log.fmt_debug("Processing %d/%d items", current, total)
```

4. **Log entry and exit of critical functions**:
```lua
   function M.critical_operation()
       log.info("Starting critical operation")
       -- ... logic ...
       log.info("Critical operation completed successfully")
   end
```

5. **Log state transitions**:
```lua
   log.debug("State transition: loading=false, loaded=true")
   M.state.loading = false
   M.state.loaded = true
```

### Programmatic Log Control

You can change log levels at runtime:
```lua
local log = require("spring-initializr.trace.log")

-- Enable debug logging temporarily
log.set_level("debug")
perform_operation()

-- Restore to warn
log.set_level("warn")

-- Check current level
print("Current log level:", log.get_level())
```

### Disabling Logs in Production

For end users, logging should be disabled by default (which it is). Users can opt-in:
```lua
-- Default (no logging)
require('spring-initializr').setup()

-- User enables logging for troubleshooting
vim.g.spring_initializr_log_file = true
vim.g.spring_initializr_log_level = "info"
require('spring-initializr').setup()
```

## CI/CD

### GitHub Actions Workflows

The project uses four workflows:

1. **Format** (`.github/workflows/format.yml`)
   - Checks Stylua formatting
   - Runs on push/PR to main

2. **Lint** (`.github/workflows/lint.yml`)
   - Runs Luacheck
   - Checks naming conventions
   - Runs on push/PR to main

3. **Spell Check** (`.github/workflows/spell-check.yml`)
   - Uses cspell
   - Config in `.cspell.json`

4. **Test** (`.github/workflows/test.yml`)
   - Runs Plenary tests
   - Ensures tests pass

### Pre-Push Checklist

Before pushing:

- [ ] Code formatted: `make fmt`
- [ ] Code linted: `make lint`
- [ ] Tests pass: Run test suite
- [ ] Documentation updated
- [ ] Commit messages are clear
- [ ] No console.log or debug code left

## Contributing Workflow

1. **Fork** the repository
2. **Clone** your fork
3. **Create** a feature branch:
   ```bash
   git checkout -b feature/my-feature
   ```
4. **Make** your changes
5. **Test** your changes
6. **Format** and **lint**:
   ```bash
   make pr-ready
   ```
7. **Commit** with clear messages:
   ```bash
   git commit -m "Add feature X (#123)"
   ```
8. **Push** to your fork
9. **Open** a pull request

## Resources

- [Neovim Lua Guide](https://neovim.io/doc/user/lua-guide.html)
- [NUI.nvim Documentation](https://github.com/MunifTanjim/nui.nvim)
- [Plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [Spring Initializr API](https://docs.spring.io/initializr/docs/current/reference/html/)

## Getting Help

- Open an issue for bugs
- Start a discussion for questions
- Join the Neovim community
- Check existing PRs and issues
