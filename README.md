<div align="center">

  <h1>spring-initializr.nvim</h1>
  <h6>The easiest way to generate Spring Boot projects with a modern TUI</h6>

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim 0.10](https://img.shields.io/badge/Neovim%200.10-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)
![Work In Progress](https://img.shields.io/badge/Work%20In%20Progress-orange?style=for-the-badge)

</div>

## Table of Contents

- [The problem](#problem)
- [The solution](#solution)
- [Repository structure](#repo)
- [Functionalities](#functionalities)
- [Installation](#installation)
    - [Vim-Plug](#vimplug)
    - [Packer](#packer)
- [Commands](#commands)
- [Setup](#setup)

---

## The problem :warning: <a name="problem"></a>

Creating Spring Boot projects normally requires navigating [start.spring.io](https://start.spring.io) or using CLI tools outside of Neovim. This interrupts developer flow and context.

---

## The solution :trophy: <a name="solution"></a>

[![asciicast](https://asciinema.org/a/723220.svg)](https://asciinema.org/a/723220)

**spring-initializr.nvim** brings Spring Boot project generation into Neovim with:

- A floating UI built using `nui.nvim`
- Fuzzy dependency selection with `telescope.nvim`
- Tab-based navigation
- Easy integration with your existing setup

---

## Repository structure :open_file_folder: <a name="repo"></a>

```bash
spring-initializr.nvim/
├── lua/
│   └── spring-initializr/
│       ├── init.lua         # Plugin entry point
│       ├── ui.lua           # UI layout and controls
│       ├── metadata.lua     # Metadata fetch and parsing
│       └── telescope.lua    # Dependency picker via Telescope
├── README.md
└── LICENSE
```


---

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

| Keybinding     | Action                                            |
|----------------|---------------------------------------------------|
| `<leader>si`   | Launch Spring Initializr UI                       |
| `<leader>sg`   | Generate Spring Boot project                      |  

---
