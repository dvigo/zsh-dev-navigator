# zsh-dev-navigator

A minimal **Zsh plugin** that lets you quickly jump into your development directories with a single command.  
`dev` acts as a smart replacement for `cd`, allowing you to navigate into project folders instantly with **recursive autocompletion** — and even open them directly in **VS Code**.

---

## ⚡ Quick Start

```bash
dev api-server
# → cd ~/dev/api-server
```

Or open the project in your configured editor:

```bash
dev -o api-server
# → Opens ~/dev/api-server in your configured editor (default: VS Code)
```

Create a new project directory:

```bash
dev -c new-project
# → Creates ~/dev/new-project and navigates to it
```

Create a new project with git repository:

```bash
dev -cg new-project
# → Creates ~/dev/new-project, initializes git, and navigates to it
```

Execute a file (with confirmation):

```bash
dev script.sh
# → Asks for confirmation, then executes ~/dev/script.sh
```

Open a file in editor:

```bash
dev -o config.json
# → Opens ~/dev/config.json in your configured editor
```

---

## ✨ Features

- ⚡ Quickly `cd` into any development project with a simple command.  
- 📁 Smart **recursive autocompletion** for subfolders.  
- 🧭 Defaults to your base development folder when no argument is provided.  
- 🪄 Optional **flags** to extend functionality — e.g., open projects directly in your **preferred editor**.  
- 🆕 **Create new project directories** on-the-fly with the `-c` flag.
- 🔧 **Initialize git repositories** automatically with the `-cg` flag.  
- ⚙️ **Configurable** base directory and default editor via configuration file.  
- 🤖 **Auto git init** option to initialize git repositories with `-c` flag automatically.
- 📄 **File execution support** with confirmation prompts for executable files.
- 📝 **File editing** with `-o` flag to open files directly in your configured editor.
- 🧠 **Intelligent file/directory detection** based on file extensions.
- 🆕 **File creation** with automatic parent directory creation.
- 🔄 **Fallback mode** for users without fzf installed.  
- 🔍 **Fuzzy finder integration** (fzf) for interactive project selection when no argument is provided.  
- 🎯 Support for **multiple editors**: VS Code, Cursor, Windsurf, Sublime Text, Vim, and more.  

---

## 📦 Installation

### **Oh My Zsh**

1. Clone the plugin into your Oh My Zsh custom plugins folder:

   ```bash
   git clone https://github.com/dvigo/zsh-dev-navigator.git ~/.oh-my-zsh/custom/plugins/zsh-dev-navigator
   ```

2. Enable it in your `~/.zshrc`:

   ```bash
   plugins=(... zsh-dev-navigator)
   ```

3. Reload Zsh:

   ```bash
   source ~/.zshrc
   ```

---

## 🎥 Demo

**Basic usage:**  
```bash
dev api-server
```

**Result:**  
```
📂 Moved to: ~/dev/api-server
```

**Autocompletion:**  
Start typing and press `<TAB>` to explore all projects and subfolders:

```
dev fr<TAB>
# frontend-app
# frontend-utils
# frontend-tests
```

**Open in your preferred editor:**  
```bash
dev -o frontend-app
# → Opens ~/dev/frontend-app in your configured editor (e.g., Cursor, VS Code, etc.)
```

**Interactive project selection with fuzzy finder:**  
```bash
dev
# → Opens fzf interface to select from available projects
# → Press ESC to navigate to the root dev folder
```

**Create new project:**  
```bash
dev -c new-project
# → Creates ~/dev/new-project and navigates to it
```

**Create new project with git:**  
```bash
dev -cg new-project
# → Creates ~/dev/new-project, initializes git, and navigates to it
```

---

## ⚙️ Configuration

The plugin uses a configuration file located in the plugin directory. You can customize the following settings:

### Configuration File

The plugin includes a `config` file with the following options:

```bash
# Development directory - where your projects are located
# This can be an absolute path or use ~ for home directory
dev_directory = ~/dev

# Default editor to use with the -o flag
# Supported editors: code, cursor, windsurf, subl, vim, nvim, emacs, atom, webstorm, idea, pycharm
editor = code

# Automatically initialize git repository when creating new directories with -c flag
# Set to true to enable automatic git init, false to disable
auto_git_init = false
```

### Customizing Settings

1. **Development Directory**: Change the `dev_directory` setting to point to your projects folder:
   ```bash
   dev_directory = ~/Development
   dev_directory = /path/to/your/projects
   ```

2. **Default Editor**: Set your preferred editor for the `-o` flag:
   ```bash
   editor = cursor        # Cursor editor
   editor = windsurf      # Windsurf editor  
   editor = code          # VS Code
   editor = subl          # Sublime Text
   editor = vim           # Vim
   editor = nvim          # Neovim
   ```

3. **Custom Editor Path**: You can also specify a full path to a custom editor:
   ```bash
   editor = /usr/local/bin/my-custom-editor
   ```

4. **Automatic Git Initialization**: Enable automatic `git init` when creating directories with `-c`:
   ```bash
   auto_git_init = true   # Always initialize git with -c flag
   auto_git_init = false  # Only initialize git with -cg flag (default)
   ```

---

## 🖊️ Usage

Basic syntax:

```bash
dev <project-name>
```

Examples:

```bash
dev dashboard-ui
# → cd ~/dev/dashboard-ui

dev api-server/routes
# → cd ~/dev/api-server/routes

dev
# → cd ~/dev
```

Open a project in your configured editor:

```bash
dev -o api-server
# → Opens the project in your configured editor (Cursor, VS Code, etc.)
```

Create a new project directory:

```bash
dev -c new-project
# → Creates ~/dev/new-project and navigates to it
```

Create a new project with git repository:

```bash
dev -cg new-project
# → Creates ~/dev/new-project, initializes git, and navigates to it
```

**Note**: If you have `auto_git_init = true` in your config, then `dev -c new-project` will also initialize git automatically.

Combine flags:

```bash
dev -c -o new-app
# → Creates ~/dev/new-app and opens it in your configured editor

dev -cg -o new-git-project
# → Creates ~/dev/new-git-project, initializes git, and opens it in your editor
```

---

## 📄 File Handling

The plugin now supports working with files in addition to directories:

### File Execution
When targeting a file, the plugin will ask for confirmation before execution:

```bash
dev script.sh
# → Target is a file: ~/dev/script.sh
# → Do you want to execute this file? [y/N]: y
# → Executes the file and navigates to its directory
```

### File Editing
Use the `-o` flag to open files directly in your configured editor:

```bash
dev -o config.json
# → Opens ~/dev/config.json in your editor
# → Navigates terminal to ~/dev/ directory
```

### Creating New Files
The plugin intelligently detects when you're trying to work with files and offers to create them:

**With `-o` flag (create and edit):**
```bash
dev -o new-config.json
# → File does not exist: ~/dev/new-config.json
# → Do you want to create this file? [y/N]: y
# → Created and opened file in your editor
```

**Without flags (create and optionally execute):**
```bash
dev new-script.sh
# → File does not exist: ~/dev/new-script.sh
# → Do you want to create this file? [y/N]: y
# → File created: ~/dev/new-script.sh
# → Do you want to execute this file? [y/N]: n
```

### Files in Subdirectories
The plugin automatically creates parent directories when needed:

```bash
dev -o src/components/Header.jsx
# → Creates src/components/ directory if it doesn't exist
# → Creates and opens Header.jsx in your editor
```

### Intelligent Detection
The plugin automatically detects whether you're working with files or directories:

**Files (with extensions):**
- `script.sh`, `config.json`, `README.md` → Treated as files
- Offers creation, execution, or editing options

**Directories (without extensions):**
- `my-project`, `frontend-app`, `api-server` → Treated as directories  
- Suggests using `-c` flag for creation

### Restrictions
- **Creation flags (`-c`, `-cg`) cannot be used with files**
- **fzf selection with `-c`/`-cg` shows only directories**
- **Autocompletion with `-c`/`-cg` shows only directories**

---

## 📌 Autocompletion

The `dev` command includes powerful autocompletion for all subdirectories inside your base development folder.  

Just type part of a project name and press `<TAB>` to complete it.

## 🔍 Fuzzy Finder Integration

When you run `dev` without any arguments, the plugin provides different interfaces based on availability:

### With fzf (Enhanced Experience)
If **fzf** is installed, you get an interactive selection interface:

- Browse through all your projects with fuzzy search
- Use arrow keys or type to filter projects
- Press **Enter** to navigate to the selected project
- Press **ESC** to navigate to the root development folder instead

### Without fzf (Fallback Mode)
If **fzf** is not available, the plugin shows a list and prompts for input:

```bash
dev
# → Available projects in ~/dev:
# → api-server
# → config.json
# → frontend-app
# → script.sh
# → Enter project/file name (or press Enter for root directory): new-file.txt
```

### Smart Filtering
The interface adapts based on the flags used:
- **Regular navigation**: Shows both files and directories
- **With `-c` or `-cg`**: Shows only directories (prevents file creation conflicts)

---

## 🔧 Roadmap

- [x] Add flag to create new project directories.  
- [x] Add flag to open projects directly in editors.  
- [x] Add support for multiple editors (VS Code, Cursor, Windsurf, Sublime, Vim, etc.).  
- [x] Add fuzzy search for project names with fzf integration.  
- [x] Add configuration file system for customizable settings.  
- [ ] Add aliases or shortcuts per project.  
- [ ] Add project templates for new directory creation.  

---

## 📜 License

GNU General Public License v3.0 — See [LICENSE](LICENSE) for details.
