<div align="center">

  <h1>spring-initializr.nvim</h1>
  <h4>The easiest way to generate Spring Boot projects</h4>
  <h6><i>A Neovim plugin that lets you build and download fully configured Spring Boot projects inside the editor.</i></h6>

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim 0.10](https://img.shields.io/badge/Neovim%200.10-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)

</div>


[![asciicast](https://asciinema.org/a/723220.svg)](https://asciinema.org/a/723220)


## Preview ##
<img width="1389" height="834" alt="image" src="https://github.com/user-attachments/assets/80756160-243a-4e9a-80ae-7a9ca95a0263" />


## 🔧 Features

- [x] Full Spring Initializr metadata support  
- [x] TUI-based UI for selecting project options  
- [x] Fuzzy dependency selection with `telescope.nvim`  
- [x] Tab and key-based navigation  


## 📁 Project Structure

```bash
spring-initializr.nvim/
├── LICENSE
├── lua/
│   └── spring-initializr/
│       ├── algo/
│       ├── commands/
│       ├── config/
│       ├── constants/
│       ├── core/
│       ├── metadata/
│       ├── styles/
│       ├── telescope/
│       ├── ui/
│       ├── dao/
│       ├── utils/
│       └── init.lua
├── scripts/
└── tests/
```

## :star: <a name="installation"></a> Installation 

> Requires **Neovim 0.9+**  
> Dependencies:
> - `nui.nvim`
> - `plenary.nvim`
> - `telescope.nvim`

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

### Lazy.nvim <a name="lazy"></a>

```lua
{
  'jkeresman01/spring-initializr.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    require('spring-initializr').setup()
  end
}
```

## Commands :wrench: <a name="commands"></a>

```vim
:SpringInitializr             -- Launch the UI to configure project
:SpringGenerateProject        -- Download and extract Spring Boot project to current directory
```

## Setup :gear: <a name="setup"></a>

Basic setup and keybindings:

```lua
require("spring-initializr").setup()

vim.keymap.set("n", "<leader>si", "<CMD>SpringInitializr<CR>")
vim.keymap.set("n", "<leader>sg", "<CMD>SpringGenerateProject<CR>")
```


| Keybinding   | Action                                  |
|--------------|-----------------------------------------|
| `<leader>si` | Open Spring Initializr TUI              |
| `<leader>q`  | Close Spring Initializr TUI             |
| `<leader>sg` | Generate project to current directory   |
| `<Tab>`      | Navigate forward between fields         |
| `<Ctrl-r>`   | Reset the form (selections && deps)     |
| `<S-Tab>`    | Navigate backward                       |
| `j` / `k`    | Move between radio options              |
| `<CR>`       | Confirm field selection or submit       |

## Contributing

Contributions are very welcome. You can help by:

- Picking up an existing issue.
    - Issues marked with the label `good first issue` are ideal if you're new to contributing.
- Opening a new **bug report** or **feature request** with clear details.
- Submitting a focused pull request that improves code, docs, or UX.

### How to get started
1. Fork the repo and clone your fork.
2. Create a topic branch: `git checkout -b feature/<short-name>` or `fix/<short-name>`.
3. Develop and test locally in Neovim:
   - Ensure dependencies are installed: `plenary.nvim`, `nui.nvim`, `telescope.nvim`.
   - Load the plugin and verify `:SpringInitializr` and `:SpringGenerateProject`.
4. Commit with clear messages and reference any related issues:  
   `git commit -m "Add toggle for X (#123)"`
5. Push and open a pull request against `main`.

### Filing issues
- Use the provided issue templates for bugs and features.
- For bugs, include Steps to Reproduce, Actual vs Expected Behavior, Environment, and logs if available.
- For features, describe the motivation, proposed solution, and alternatives considered.

If you are unsure where to start, open an issue to discuss an idea before coding.


## License

This project is licensed under the terms of the [GNU General Public License v3.0](./LICENSE).



<div align="center">
  
  [![Buy Me a Coffee](https://img.shields.io/badge/-Buy%20Me%20a%20Coffee-yellow?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/jkeresman)
  
</div>
