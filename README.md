<div align="center">

  <h1>spring-initializr.nvim</h1>
  <h4>The easiest way to generate Spring Boot projects</h4>

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim 0.10](https://img.shields.io/badge/Neovim%200.10-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)
![Work In Progress](https://img.shields.io/badge/Work%20In%20Progress-orange?style=for-the-badge)

</div>

---

## ✨ Why spring-initializr.nvim?

Spring Boot project generation traditionally means switching to your browser or running CLI tools — breaking your flow.

**spring-initializr.nvim** lets you create, customize, and download Spring Boot projects entirely within Neovim.

---

## 📽️ Demo

[![asciicast](https://asciinema.org/a/723220.svg)](https://asciinema.org/a/723220)

---

## 🔧 Features

✅ Full Spring Initializr metadata support  
✅ TUI-based UI for selecting project options  
✅ Fuzzy dependency selection with `telescope.nvim`  
✅ Tab and key-based navigation  
✅ Instant download and extraction to your current working directory  

---

## 📁 Project Structure

```bash
spring-initializr.nvim/
├── LICENSE
├── README.md
├── lua
│   └── spring-initializr
│       ├── commands
│       │   └── commands.lua           # Neovim user commands
│       ├── core
│       │   └── core.lua               # Project generation logic
│       ├── init.lua                   # Plugin entry point
│       ├── metadata
│       │   └── metadata.lua           # Metadata fetching and state
│       ├── telescope
│       │   └── telescope.lua          # Telescope-based dependency picker
│       ├── ui
│       │   ├── deps.lua               # Dependencies panel and buttons
│       │   ├── focus.lua              # Focus management across windows
│       │   ├── init.lua               # UI mount/unmount setup
│       │   ├── inputs.lua             # Input fields (groupId, artifactId, etc.)
│       │   ├── layout.lua             # Full UI layout builder
│       │   └── radios.lua             # Radio-style selectors
│       └── utils
│           ├── file.lua               # File utilities
│           ├── highlights.lua         # Highlight group setup
│           ├── http.lua               # Project downloader
│           ├── message.lua            # Logging helpers
│           ├── url.lua                # URL query encoding
│           └── window.lua             # Popup window helpers
```

## Functionalities :pick: <a name="functionalities"></a>

- [x] Select project type, language, version, packaging, Java version....
- [x] Dependency picker using Telescope

---

## Installation :star: <a name="installation"></a>

> Requires **Neovim 0.9+**  
> Dependencies:
> - `nui.nvim`
> - `plenary.nvim`
> - `telescope.nvim` (optional but recommended)

### Vim Plug <a name="vimplug"></a>

```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'jkeresman01/spring-initializr.nvim'
```

### Packer <a name="packer"></a>

```lua
use {
  'jkeresman01/spring-initializr.nvim',
  requires = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-telescope/telescope.nvim'
  }
}
```

---

## Commands :wrench: <a name="commands"></a>

```vim
:SpringInitializr             -- Launch the UI to configure project
:SpringGenerateProject        -- Download and extract Spring Boot project to current directory
```

---

## Setup :gear: <a name="setup"></a>

Basic setup and keybindings:

```lua
require("spring-initializr").setup()

vim.keymap.set("n", "<leader>si", "<CMD>SpringInitializr<CR>")
vim.keymap.set("n", "<leader>sg", "<CMD>SpringGenerateProject<CR>")
```

---

| Keybinding   | Action                                  |
|--------------|------------------------------------------|
| `<leader>si` | Open Spring Initializr TUI              |
| `<leader>sg` | Generate project to current directory   |
| `<Tab>`      | Navigate forward between fields         |
| `<S-Tab>`    | Navigate backward                       |
| `j` / `k`    | Move between radio options              |
| `<CR>`       | Confirm field selection or submit       |

---
