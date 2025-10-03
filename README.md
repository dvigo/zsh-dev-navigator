# zsh-dev-navigator

A minimal **Zsh plugin** that lets you quickly jump into your development directories with a single command.  
`dev` acts as a smart replacement for `cd`, allowing you to navigate into project folders instantly with **recursive autocompletion**.

---

## ⚡ Quick Start

```bash
dev api-server
# → cd ~/Development/api-server
```

---

## ✨ Features

- ⚡ Quickly `cd` into any development project with a simple command.  
- 📁 Smart **recursive autocompletion** for subfolders.  
- 🧭 Defaults to your base development folder when no argument is provided.  
- 🪄 Minimal and lightning-fast — perfect for daily workflows.

---

## 📦 Installation

### **Oh My Zsh**

1. Clone the plugin into your Oh My Zsh custom plugins folder:

   ```bash
   git clone https://github.com/youruser/zsh-dev-navigator.git ~/.oh-my-zsh/custom/plugins/zsh-dev-navigator
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
📂 Moved to: ~/Development/api-server
```

**Autocompletion:**  
Start typing and press `<TAB>` to explore all projects and subfolders:

```
dev fr<TAB>
# frontend-app
# frontend-utils
# frontend-tests
```

---

## ⚙️ Configuration

Inside the plugin file, set the base directory where all your projects live:

```bash
DEV_BASE_DIR="$HOME/Development"
```

Change this to match your setup, for example:

```bash
DEV_BASE_DIR="$HOME/dev"
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
# → cd ~/Development/dashboard-ui

dev api-server/routes
# → cd ~/Development/api-server/routes

dev
# → cd ~/Development
```

---

## 📌 Autocompletion

The `dev` command includes powerful autocompletion for all subdirectories inside your base development folder.  

Just type part of a project name and press `<TAB>` to complete it.

---

## 🔧 Roadmap

- [ ] Add optional flags for editor integration (VS Code, JetBrains, etc.).
- [ ] Add fuzzy search for project names.
- [ ] Add aliases or shortcuts per project.

---

## 📜 License

GNU General Public License v3.0 — See [LICENSE](LICENSE) for details.
