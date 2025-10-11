# Testing Guide for zsh-dev-navigator

## 🧪 Enhanced Quick Tests

The `quick_test.sh` script provides comprehensive testing for all plugin functionalities. It creates a controlled test environment and validates every feature with detailed reporting.

## 🚀 Quick Start

```bash
# Run all tests (no installation required)
./quick_test.sh
```

## 📋 Test Categories

### 1. **Basic Navigation Tests**
- ✅ Navigate to existing directories
- ✅ Navigate to nested directories  
- ✅ Navigate to root dev directory
- ✅ Handle directory paths correctly

### 2. **File Handling Tests**
- ✅ File execution with confirmation prompt
- ✅ File execution cancellation
- ✅ File opening in editor with `-o` flag
- ✅ New file creation with `-o` flag
- ✅ File execution with arguments (flags and parameters)
- ✅ Interactive argument input (prompts for arguments if not provided)

### 3. **Directory Creation Tests**
- ✅ Create directories with `-c` flag
- ✅ Create directories with git init using `-cg` flag
- ✅ Prevent `-c` flag usage with files
- ✅ Prevent `-cg` flag usage with files

### 4. **Intelligent Detection Tests**
- ✅ File detection by extension
- ✅ Directory suggestion for names without extension
- ✅ Smart behavior based on file type

### 5. **Editor Integration Tests**
- ✅ Open directories in editor with `-o` flag
- ✅ Combined directory creation and editor opening (`-c -o`)
- ✅ File vs directory handling in editor

## 🏗️ Test Environment

The test suite creates a temporary environment:

```
~/dev-navigator-test/
├── existing-project/           # Test directory
├── nested-project/
│   └── subdir/                # Nested directory test
├── git-project/               # Pre-existing git repo
│   └── .git/
├── test-script.sh             # Executable shell script
├── test-python.py             # Executable Python script
├── config.json                # JSON configuration file
└── README.md                  # Markdown documentation
```

## 🔧 Manual Testing

For manual testing, you can use these commands:

### Basic Navigation
```bash
dev existing-project           # Navigate to directory
dev nested-project/subdir      # Navigate to nested directory
dev                           # Navigate to root (or use fzf)
```

### File Operations
```bash
dev test-script.sh            # Execute file (with confirmation)
dev -o config.json            # Open file in editor
dev -o README.md              # Open markdown in editor
```

### Directory Creation
```bash
dev -c new-project            # Create new directory
dev -cg new-git-project       # Create directory with git init
dev -c -o new-editor-project  # Create and open in editor
```

### Error Cases
```bash
dev -c test-script.sh         # Should fail (can't create over file)
dev -cg config.json           # Should fail (can't create over file)
dev non-existent              # Should fail (doesn't exist, no -c flag)
```

## 🎯 Expected Behaviors

### File Execution Flow
1. **Detection**: Plugin detects target is a file
2. **Confirmation**: Prompts "Do you want to execute this file? [y/N]:"
3. **Execution**: If yes, executes file and navigates to its directory
4. **Cancellation**: If no, shows "File execution cancelled"

### File Editor Flow  
1. **Detection**: Plugin detects target is a file with `-o` flag
2. **Editor**: Opens file in configured editor
3. **Navigation**: Navigates terminal to file's directory
4. **No Execution**: File is NOT executed

### Directory Creation Flow
1. **Validation**: Ensures target doesn't exist or `-c` flag is used
2. **Creation**: Creates directory structure
3. **Git Init**: If `-cg` flag or `auto_git_init = true`, initializes git
4. **Navigation**: Navigates to created directory

## 🐛 Troubleshooting

### Common Issues

**Test fails with "dev command not found":**
- Ensure plugin is installed in Oh My Zsh
- Check that plugin is enabled in `~/.zshrc`
- Reload zsh: `source ~/.zshrc`

**Config tests fail:**
- Verify config file exists and is readable
- Check file permissions on plugin directory
- Ensure no syntax errors in config file

**File execution tests fail:**
- Verify test files have execute permissions
- Check that shell can execute the test scripts
- Ensure proper shebang lines in test files

**fzf tests fail:**
- Install fzf if not present: `brew install fzf`
- Ensure fzf is in PATH
- Test fzf manually: `ls | fzf`

### Debug Mode

For detailed debugging, modify the test script:

```bash
# Add debug output
set -x

# Or run specific test functions
test_basic_navigation
test_file_handling
```

## 📊 Test Results

The test suite provides colored output:
- 🟢 **Green**: Passed tests
- 🔴 **Red**: Failed tests  
- 🟡 **Yellow**: Test descriptions
- 🔵 **Blue**: Section headers and info

Example output:
```
=== Test Results Summary ===
Total Tests: 15
Passed: 15
Failed: 0

🎉 All tests passed! The plugin is working correctly.
```

## 🔄 Continuous Testing

For development, you can run tests automatically:

```bash
# Watch for changes and re-run tests
while inotifywait -e modify zsh-dev-navigator.plugin.zsh; do
    ./test_suite.sh
done
```

## 📝 Adding New Tests

To add new test cases:

1. **Create test function** following the naming pattern `test_*`
2. **Use helper functions** for consistent output
3. **Clean up** any created resources
4. **Add to main runner** in `run_all_tests()`

Example test function:
```bash
test_new_feature() {
    print_header "Testing New Feature"
    
    print_test "Description of what we're testing"
    if dev new-command 2>/dev/null; then
        print_success "New feature works"
    else
        print_failure "New feature failed"
    fi
}
```
