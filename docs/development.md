# Development Guide

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Development Setup](#development-setup)
- [Code Organization](#code-organization)
- [Testing](#testing)
- [Code Style](#code-style)
- [Adding Features](#adding-features)
- [Debugging](#debugging)
- [CI/CD](#cicd)

## Architecture Overview

### Component Responsibilities

| Component | Location | Purpose |
|-----------|----------|---------|
| **Commands** | `commands/` | Register Neovim user commands, bridge user actions to plugin logic |
| **Core** | `core/` | Business logic for project generation |
| **UI** | `ui/` | Layout, component rendering, focus management, user input |
| **Metadata** | `metadata/` | Fetch and cache Spring Initializr metadata from start.spring.io |
| **Telescope** | `telescope/` | Dependency picker integration |
| **Utils** | `utils/` | Reusable helpers (HTTP, file, URL, window, message) |
| **Algo** | `algo/` | Data structures (HashSet) and generic algorithms |
| **Styles** | `styles/` | Highlight configuration and theme integration |

## Development Setup

### 1. Clone the Repository

```bash
git clone https://github.com/jkeresman01/spring-initializr.nvim.git
cd spring-initializr.nvim
```

### 2. Install Dependencies

#### Plugin Dependencies

```lua
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
-- In your Neovim config
vim.opt.rtp:prepend("~/path/to/spring-initializr.nvim")
require('spring-initializr').setup()
```

Or with lazy.nvim:

```lua
{
  dir = "~/path/to/spring-initializr.nvim",
  dependencies = { ... },
  config = function()
    require('spring-initializr').setup()
  end
}
```

## Code Organization

> [!IMPORTANT]
> Code should follow clean code principles. Commit messages and PR messages must follow git naming conventions: imperative mood, up to 80 chars.

### Naming Conventions

> [!NOTE]
> These conventions are enforced by `scripts/check-naming.sh`.

**Files:**
- Utils must end with `_utils.lua` (e.g., `file_utils.lua`, `http_utils.lua`)
- Styles must be in `styles/` directory

### Module Structure

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

### Function Documentation

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

### Managing Module Dependencies

> [!WARNING]
> Avoid tight coupling by passing entire modules. Pass only what's needed.

**Bad - Tight Coupling:**
```lua
function M.enable_navigation(main_ui)
    buffer_manager.register_close_key(comp, main_ui)  -- Entire module
end
```

**Good - Loose Coupling:**
```lua
function M.enable_navigation(close_fn)
    buffer_manager.register_close_key(comp, close_fn)  -- Just the function
end
```

### Error Handling

```lua
-- Use pcall for potentially failing operations
local ok, result = pcall(vim.json.decode, output)
if not ok then
    return nil, "Failed to parse JSON"
end
```

### Async Operations

> [!TIP]
> Use `vim.schedule` for UI updates from async contexts.

```lua
Job:new({
    command = "curl",
    args = { ... },
    on_exit = function(j)
        vim.schedule(function()
            update_ui(j:result())
        end)
    end,
}):start()
```

## Testing

### Running Tests

```bash
# Run all tests
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests" +q
```

### Test Structure (Arrange-Act-Assert)

```lua
describe("Module Name", function()
    it("does something", function()
        -- Arrange
        local input = "test"
        local expected = "TEST"

        -- Act
        local result = my_function(input)

        -- Assert
        assert.are.equal(expected, result)
    end)
end)
```

### Test Coverage Areas

| Priority | Area | Status |
|----------|------|--------|
| 1 | Algo (HashSet) | Fully tested |
| 2 | Utils | Needs tests |
| 3 | Core logic | Needs tests |
| 4 | UI components | Needs tests |

## Code Style

### Formatting

```bash
make fmt
# Or: stylua lua/ --config-path=.stylua.toml
```

### Linting

```bash
make lint
# Or: luacheck lua/ --globals vim
```

### Pre-Commit Checks

> [!IMPORTANT]
> Always run this before committing:

```bash
make pr-ready
```

## Adding Features

### New Utility Module

1. Create the file (`lua/spring-initializr/utils/my_utils.lua`)
2. Write tests (`tests/utils/my_utils_spec.lua`)
3. Run `make pr-ready`

### New UI Component

1. Create the component module in `ui/`
2. Register with focus manager: `focus.register(popup)`
3. Integrate into layout

### New Command

```lua
-- In commands/commands.lua
local CMD = {
    MY_NEW_COMMAND = "MyNewCommand",
}

function M.register_cmd_my_new_command()
    vim.api.nvim_create_user_command(CMD.MY_NEW_COMMAND, function()
        my_module.do_something()
    end, { desc = "Does something" })
end
```

## Debugging

### Using the Logging API

```lua
local log = require("spring-initializr.trace.log")

log.trace("Entering function")
log.debug("Processing item:", item)
log.info("Operation completed")
log.warn("Deprecated API used")
log.error("Failed to connect:", err)
log.fatal("Critical failure")

-- Formatted logging
log.fmt_info("Fetching metadata from %s", url)
log.fmt_debug("Processing %d dependencies", count)
```

### Enable Logging

```lua
vim.g.spring_initializr_log_file = true
vim.g.spring_initializr_log_level = "debug"
```

View logs:
```bash
tail -f ~/.local/share/nvim/spring-initializr.log
```

### Common Issues

> [!TIP]
> **UI not updating?** Wrap updates in `vim.schedule`.

> [!TIP]
> **Focus not working?** Check component registration with `focus.register(my_component)`.

> [!TIP]
> **Metadata not loading?** Test with `curl -s https://start.spring.io/metadata/client`.

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

## CI/CD

### GitHub Actions Workflows

| Workflow | Purpose |
|----------|---------|
| **Format** | Checks Stylua formatting |
| **Lint** | Runs Luacheck and naming conventions |
| **Spell Check** | Uses cspell (config in `.cspell.json`) |
| **Test** | Runs Plenary tests |

### Pre-Push Checklist

- [ ] Code formatted: `make fmt`
- [ ] Code linted: `make lint`
- [ ] Tests pass
- [ ] Documentation updated
- [ ] Commit messages are clear
- [ ] No debug code left

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make changes and test
4. Format and lint: `make pr-ready`
5. Commit with clear messages: `git commit -m "Add feature X (#123)"`
6. Push and open a pull request

## Resources

- [Neovim Lua Guide](https://neovim.io/doc/user/lua-guide.html)
- [NUI.nvim Documentation](https://github.com/MunifTanjim/nui.nvim)
- [Plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [Spring Initializr API](https://docs.spring.io/initializr/docs/current/reference/html/)
