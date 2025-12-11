<div align="center">

  <h1>spring-initializr.nvim</h1>

[![Mentioned in Awesome Neovim](https://awesome.re/mentioned-badge.svg)](https://github.com/rockerBOO/awesome-neovim)

  <h4>The easiest way to generate Spring Boot projects</h4>
  <h6><i>A Neovim plugin that lets you build and download fully configured Spring Boot projects inside the editor.</i></h6>
  

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim 0.10](https://img.shields.io/badge/Neovim%200.10-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)

</div>

> [!NOTE]
> The UI has been significantly improved since this initial demo video. See the Preview section below for current screenshots.

[![asciicast](https://asciinema.org/a/723220.svg)](https://asciinema.org/a/723220)


## Preview ##
<img width="1547" height="861" alt="image" src="https://github.com/user-attachments/assets/30ef3673-4eb2-4b6b-978b-048d0e11f836" />

<img width="1467" height="842" alt="image" src="https://github.com/user-attachments/assets/2f99c130-d704-4501-a7fd-84105731e2c0" />

<img width="1519" height="856" alt="image" src="https://github.com/user-attachments/assets/0b3b55a0-37f6-4ee7-96e3-0f9950e91947" />



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
│       ├── trace/
│       ├── utils/
│       └── init.lua
├── scripts/
└── tests/
```

> [!IMPORTANT]
>
> Requires **Neovim 0.9+**  
> Dependencies:
> - `nui.nvim`
> - `plenary.nvim`
> - `telescope.nvim`

## :star: <a name="installation"></a> Installation 

> [!TIP]
> If you want to add instructions for your plugin manager of preference
> please raise a [**ISSUE_REQUEST**].


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

## Commands

These are the user commands you can call from the cmdline:

### :SpringInitializr

The `:SpringInitializr` command will open a UI window pointing to all the useful operations
this plugin can provide.

> [!TIP]
> _See [`commands.lua`](./lua/spring-initalizr/commands/commands.lua) for more info_.

### :SpringGenerateProject

The `:SpringGenerateProject` command will scaffold a new Spring Boot Project with selections from the UI to your current working directory.

> [!TIP]
> _See [`commands.lua`](./lua/spring-initalizr/commands/commands.lua) for more info_.

> [!IMPORTANT]
> This is the list of planned commands that will be available soon:
>
> - `:SpringInitalizrHistory`
> - `:SpringInitalizrHealth`
> - `:SpringInitalizrLog`
> - `:SpringPreviewProject`

## Setup :gear: <a name="setup"></a>

To enable the plugin you must call `setup()`:

```lua
require('project').setup()
```

Minimal setup and keybindings:

```lua
require("spring-initializr").setup()

vim.keymap.set("n", "<leader>si", "<CMD>SpringInitializr<CR>")
vim.keymap.set("n", "<leader>sg", "<CMD>SpringGenerateProject<CR>")
```

| Keybinding   | Action                                  |
|--------------|-----------------------------------------|
| `<leader>si` | Open Spring Initializr TUI              |
| `<leader>sg` | Generate project to current directory   |
| `<Tab>`      | Navigate forward between fields         |
| `<S-Tab>`    | Navigate backward                       |
| `<Ctrl-r>`   | Reset the form (selections && deps)     |
| `<Ctrl-b>`   | Open dependency picker                  |
| `j` / `k`    | Move between radio options              |
| `j` / `k`    | Move between selected dependencies      |
| `<CR>`       | Confirm field selection or submit       |
| `dd`         | Remove selected dependency              |
| `q`          | Close Spring Initializr TUI             |


## Contributing

> [!IMPORTANT]
> Contributions are very welcome

You can help by:

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

## 🧱 Supporters Wall

**Kevin Lopez**  
_First Donation 💛_ - Thanks Kevin we appreciate it a lot

> “Hey bro thanks a lot for your spring plugin on nvim, I loved it - that was exactly what I was looking for. The best for your project, I'll come back later :D Greetings from Mexico!”  
> - **Kevin Lopez**


## License

This project is licensed under the terms of the [GNU General Public License v3.0](./LICENSE).


<div align="center">
  
  [![Buy Me a Coffee](https://img.shields.io/badge/-Buy%20Me%20a%20Coffee-yellow?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/jkeresman)
  
</div>
