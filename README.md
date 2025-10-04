# zsh-dev-navigator

A minimal **Zsh plugin** that lets you quickly jump into your development directories with a single command.  
`dev` acts as a smart replacement for `cd`, allowing you to navigate into project folders instantly with **recursive autocompletion** — and even open them directly in **VS Code**.

---

## ⚡ Quick Start

```bash
dev api-server
# → cd ~/dev/api-server
```

Or open the project in VS Code:

```bash
dev -o api-server
# → Opens ~/dev/api-server in VS Code
```

Create a new project directory:

```bash
dev -c new-project
# → Creates ~/dev/new-project and navigates to it
```

---

## ✨ Features

- ⚡ Quickly `cd` into any development project with a simple command.  
- 📁 Smart **recursive autocompletion** for subfolders.  
- 🧭 Defaults to your base development folder when no argument is provided.  
- 🪄 Optional **flags** to extend functionality — e.g., open projects directly in **VS Code**.  
- 🆕 **Create new project directories** on-the-fly with the `-c` flag.  
- ⚙️ Configurable base directory via an environment variable.  

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

**Open in VS Code:**  
```bash
dev -o frontend-app
# → Opens ~/dev/frontend-app in VS Code and navigates to it
```

**Create new project:**  
```bash
dev -c new-project
# → Creates ~/dev/new-project and navigates to it
```

---

## ⚙️ Configuration

By default, the plugin uses:

```bash
DEV_BASE_DIR="${ZSH_DEV_NAVIGATOR_DIR:-$HOME/dev}"
```

- If `$ZSH_DEV_NAVIGATOR_DIR` is set, that path will be used as the base projects folder.
- Otherwise, it defaults to `$HOME/dev`.

You can change this in your `~/.zshrc`:

```bash
export ZSH_DEV_NAVIGATOR_DIR="$HOME/Development"
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

Open a project in VS Code:

```bash
dev -o api-server
# → Opens the project in VS Code and navigates to it
```

Create a new project directory:

```bash
dev -c new-project
# → Creates ~/dev/new-project and navigates to it
```

Combine flags:

```bash
dev -c -o new-app
# → Creates ~/dev/new-app and opens it in VS Code
```

---

## 📌 Autocompletion

The `dev` command includes powerful autocompletion for all subdirectories inside your base development folder.  

Just type part of a project name and press `<TAB>` to complete it.

---

## 🔧 Roadmap

- [x] Add flag to create new project directories.  
- [x] Add flag to open projects directly in VS Code.  
- [ ] Add support for more editors (JetBrains, Sublime, etc.).  
- [x] Add fuzzy search for project names.  
- [ ] Add aliases or shortcuts per project.

---

## 📜 License

GNU General Public License v3.0 — See [LICENSE](LICENSE) for details.
