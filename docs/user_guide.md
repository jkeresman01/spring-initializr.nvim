# spring-initializr.nvim API Documentation

## Table of Contents

- [Commands](#commands)
- [Setup](#setup)
- [Configuration](#configuration)
- [API Reference](#api-reference)
- [UI Components](#ui-components)
- [Keybindings](#keybindings)

## Commands

### `:SpringInitializr`

Opens the Spring Initializr TUI interface for configuring a new Spring Boot project.

**Usage:**
```vim
:SpringInitializr
```

### `:SpringGenerateProject`

Generates and downloads a Spring Boot project to the current working directory based on the configured selections.

**Usage:**
```vim
:SpringGenerateProject
```

## Setup

### Basic Setup

```lua
require('spring-initializr').setup()
```

### With Keybindings

```lua
require('spring-initializr').setup()

vim.keymap.set("n", "<leader>si", "<CMD>SpringInitializr<CR>", 
  { desc = "Open Spring Initializr" })
vim.keymap.set("n", "<leader>sg", "<CMD>SpringGenerateProject<CR>", 
  { desc = "Generate Spring Boot Project" })
```

## Configuration

The plugin currently works with default settings and doesn't require additional configuration. All options are selected through the interactive UI.

## API Reference

### Module: `spring-initializr`

#### `setup()`

Initializes the plugin and registers user commands.

**Returns:** `nil`

**Example:**
```lua
require('spring-initializr').setup()
```

### Module: `spring-initializr.core.core`

#### `generate_project()`

Generates a Spring Boot project based on current UI selections.

**Returns:** `nil`

**Side Effects:**
- Downloads a ZIP file from start.spring.io
- Extracts it to the current working directory
- Shows notification messages

### Module: `spring-initializr.metadata.metadata`

#### `fetch_metadata(callback)`

Fetches Spring Initializr metadata from the remote endpoint.

**Parameters:**
- `callback` (function): Called with `(data, err)` when fetch completes
  - `data` (table|nil): Parsed metadata object
  - `err` (string|nil): Error message if fetch failed

**Example:**
```lua
local metadata = require('spring-initializr.metadata.metadata')

metadata.fetch_metadata(function(data, err)
  if err then
    print("Error: " .. err)
    return
  end
  
  -- Use metadata
  print(vim.inspect(data.type.values))
end)
```

### Module: `spring-initializr.telescope.telescope`

#### `pick_dependencies(opts, on_done)`

Opens a Telescope picker for selecting Spring Boot dependencies.

**Parameters:**
- `opts` (table, optional): Telescope picker options
- `on_done` (function, optional): Callback to execute after selection

**Example:**
```lua
local picker = require('spring-initializr.telescope.telescope')

picker.pick_dependencies({}, function()
  print("Dependencies selected!")
end)
```

#### `selected_dependencies`

Table containing the IDs of all selected dependencies.

**Type:** `table<string>`

### Module: `spring-initializr.algo.hashset`

Provides a hash set implementation with pluggable key functions.

#### `new(opts)`

Creates a new hash set.

**Parameters:**
- `opts` (table, optional):
  - `key_fn` (function): Function to compute keys from values
    - Default: identity function for primitives

**Returns:** `Set` instance

**Example:**
```lua
local HashSet = require('spring-initializr.algo.hashset')

-- Primitive values
local set = HashSet.new()
set:add("value")

-- Tables with custom key function
local deps = HashSet.new({
  key_fn = function(dep) return dep.id:lower() end
})
deps:add({ id = "Web", name = "Spring Web" })
```

#### `from_list(list, opts)`

Creates a hash set from a list.

**Parameters:**
- `list` (table): Array-like list of values
- `opts` (table, optional): Same as `new(opts)`

**Returns:** `Set` instance

#### Set Methods

##### `add(value)`

Adds a value to the set.

**Returns:** `boolean` - true if added, false if already present

##### `remove(value)`

Removes a value from the set.

**Returns:** `boolean` - true if removed, false if not present

##### `has(value)`

Checks if value exists in the set.

**Returns:** `boolean`

##### `has_key(key)`

Checks membership by key (bypasses key_fn).

**Returns:** `boolean`

##### `get(key)`

Gets stored value by key.

**Returns:** `any|nil`

##### `toggle(value)`

Toggles presence of a value.

**Returns:** `boolean` - true if added, false if removed

##### `size()`

Returns number of elements.

**Returns:** `integer`

##### `is_empty()`

Checks if set is empty.

**Returns:** `boolean`

##### `clear()`

Removes all elements.

##### `to_list()`

Returns values as an array.

**Returns:** `table`

##### `iter()`

Returns iterator over stored values.

**Returns:** `function` - Iterator for use in for-loops

**Example:**
```lua
for value in set:iter() do
  print(value)
end
```

##### `union(other)`

Adds all elements from another set (in-place).

**Parameters:**
- `other` (Set): Another set instance

##### `intersection(other)`

Returns new set with common elements.

**Parameters:**
- `other` (Set): Another set instance

**Returns:** `Set` - New set instance

##### `difference(other)`

Returns new set with elements only in this set.

**Parameters:**
- `other` (Set): Another set instance

**Returns:** `Set` - New set instance

## UI Components

### Focus Management

The UI uses a focus management system that allows navigation between components.

**Navigation Keys:**
- `<Tab>` - Focus next component
- `<S-Tab>` - Focus previous component

### Radio Buttons

Radio button groups for selecting single options (Project Type, Language, etc.).

**Keys:**
- `j` / `k` - Move selection down/up
- `<CR>` - Confirm selection

### Input Fields

Text input fields for entering project details (Group, Artifact, etc.).

**Keys:**
- Normal text editing in insert mode
- `<CR>` - Submit value

### Dependency Picker

Button that opens Telescope for dependency selection.

**Keys:**
- `<CR>` - Open Telescope picker

## Keybindings

### Default Keybindings (User-Defined)

These are recommended keybindings you can set in your config:

```lua
vim.keymap.set("n", "<leader>si", "<CMD>SpringInitializr<CR>")
vim.keymap.set("n", "<leader>sg", "<CMD>SpringGenerateProject<CR>")
```

### UI Navigation

| Key | Action |
|-----|--------|
| `<Tab>` | Navigate to next field |
| `<S-Tab>` | Navigate to previous field |
| `j` | Move down in radio options |
| `k` | Move up in radio options |
| `<CR>` | Confirm selection or submit field |

## Utilities

### Module: `spring-initializr.utils.url_utils`

#### `urlencode(str)`

URL-encodes a string.

**Parameters:**
- `str` (string): String to encode

**Returns:** `string` - Encoded string

#### `encode_query(params)`

Encodes a table into a URL query string.

**Parameters:**
- `params` (table): Key-value pairs

**Returns:** `string` - Query string (e.g., "key1=value1&key2=value2")

### Module: `spring-initializr.utils.message_utils`

#### `show_info_message(msg)`

Shows an info-level notification.

#### `show_warn_message(msg)`

Shows a warning-level notification.

#### `show_error_message(msg)`

Shows an error-level notification.

#### `show_debug_message(msg)`

Shows a debug-level notification.

### Module: `spring-initializr.utils.window_utils`

#### `get_winid(comp)`

Extracts window ID from a component.

**Parameters:**
- `comp` (table): Component with `winid` or `popup.winid`

**Returns:** `number|nil` - Window ID

#### `safe_close(winid)`

Safely closes a window if valid.

**Parameters:**
- `winid` (number): Window ID to close

### Module: `spring-initializr.utils.http_utils`

#### `download_file(url, output_path, on_success, on_error)`

Downloads a file using curl.

**Parameters:**
- `url` (string): URL to download
- `output_path` (string): Destination file path
- `on_success` (function): Success callback
- `on_error` (function): Error callback

### Module: `spring-initializr.utils.file_utils`

#### `unzip(zip_path, destination, on_done)`

Extracts a ZIP file and removes it after extraction.

**Parameters:**
- `zip_path` (string): Path to ZIP file
- `destination` (string): Target directory
- `on_done` (function): Callback when complete

## Dependencies

### Required

- **Neovim** >= 0.9
- **plenary.nvim** - Lua utilities
- **nui.nvim** - UI components
- **telescope.nvim** - Fuzzy finder

### System Requirements

- `curl` - For downloading metadata and projects
- `unzip` - For extracting project archives

## Metadata Structure

The Spring Initializr metadata has the following structure:

```lua
{
  type = {
    values = {
      { id = "gradle-project", name = "Gradle Project" },
      { id = "maven-project", name = "Maven Project" },
      -- ...
    }
  },
  language = {
    values = {
      { id = "java", name = "Java" },
      { id = "kotlin", name = "Kotlin" },
      { id = "groovy", name = "Groovy" }
    }
  },
  bootVersion = {
    values = {
      { id = "3.2.0", name = "3.2.0" },
      -- ...
    }
  },
  packaging = {
    values = {
      { id = "jar", name = "Jar" },
      { id = "war", name = "War" }
    }
  },
  javaVersion = {
    values = {
      { id = "21", name = "21" },
      { id = "17", name = "17" },
      -- ...
    }
  },
  dependencies = {
    values = {
      {
        name = "Developer Tools",
        values = {
          { id = "devtools", name = "Spring Boot DevTools" },
          -- ...
        }
      },
      -- More groups...
    }
  }
}
```

## Error Handling

The plugin handles errors gracefully and displays notifications for:

- Metadata fetch failures
- Download errors
- Invalid selections
- Network issues

All errors are displayed using `vim.notify` with appropriate log levels.

## State Management

The plugin maintains state in the following locations:

### UI State (`spring-initializr.ui.init.state`)

```lua
{
  layout = nil,              -- NUI Layout instance
  outer_popup = nil,         -- Main popup window
  metadata = nil,            -- Fetched metadata
  selections = {             -- User selections
    project_type = "",
    language = "",
    boot_version = "",
    groupId = "",
    artifactId = "",
    name = "",
    description = "",
    packageName = "",
    packaging = "",
    java_version = "",
    dependencies = {}
  }
}
```

### Metadata State (`spring-initializr.metadata.metadata.state`)

```lua
{
  metadata = nil,    -- Cached metadata
  loaded = false,    -- Whether metadata is loaded
  error = nil,       -- Last error message
  loading = false,   -- Loading in progress
  callbacks = {}     -- Pending callbacks
}
```

## Extending the Plugin

### Adding Custom Utilities

Utility modules follow a naming convention: all files in `lua/spring-initializr/utils/` must end with `_utils.lua`.

### Creating Custom UI Components

UI components can be registered with the focus manager:

```lua
local focus = require('spring-initializr.ui.focus')

-- Register your component
focus.register(my_component)
```

### Custom Highlight Groups

The plugin uses these highlight groups:

- `NormalFloat` - Popup background
- `FloatBorder` - Border color
- `NuiMenuSel` - Selected menu item

Override them in your colorscheme or after the plugin loads.

## License

This plugin is licensed under the GNU General Public License v3.0.

## Author

Josip Keresman ([@jkeresman01](https://github.com/jkeresman01))
