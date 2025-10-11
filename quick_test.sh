#!/bin/zsh

# =============================================================================
# ZSH Dev Navigator - Enhanced Quick Test Script
# =============================================================================
# Comprehensive test script to verify all plugin functionality
# 
# Usage: ./quick_test.sh
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

# Get the directory where this script is located
SCRIPT_DIR="${0:A:h}"

# Load the plugin directly from the current directory
if [ -f "$SCRIPT_DIR/zsh-dev-navigator.plugin.zsh" ]; then
    echo -e "${BLUE}Loading plugin from current directory...${NC}"
    source "$SCRIPT_DIR/zsh-dev-navigator.plugin.zsh"
else
    echo -e "${RED}Error: Plugin file not found in current directory${NC}"
    exit 1
fi

# =============================================================================
# Helper Functions
# =============================================================================

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_test() {
    echo -e "${YELLOW}Testing: $1${NC}"
    ((TOTAL_TESTS++))
}

print_success() {
    echo -e "${GREEN}✓ PASS: $1${NC}"
    ((TESTS_PASSED++))
}

print_failure() {
    echo -e "${RED}✗ FAIL: $1${NC}"
    ((TESTS_FAILED++))
}

print_info() {
    echo -e "${BLUE}ℹ INFO: $1${NC}"
}

# Verify function is loaded
if ! typeset -f dev >/dev/null 2>&1; then
    echo -e "${RED}Error: 'dev' function not loaded${NC}"
    exit 1
fi

print_info "Plugin loaded successfully!"

# Verify config file exists
if [ ! -f "$SCRIPT_DIR/config" ]; then
    echo -e "${RED}Error: Config file not found${NC}"
    exit 1
fi

print_info "Config file found"

# Create a simple test environment
TEST_DIR="/tmp/dev-nav-quick-test"
echo -e "${BLUE}Creating test environment at $TEST_DIR${NC}"

# Clean up any existing test directory
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

# Create test files and directories
mkdir -p "$TEST_DIR/existing-project"
mkdir -p "$TEST_DIR/nested-project/subdir"

# Create executable test script
cat > "$TEST_DIR/test-script.sh" << 'EOF'
#!/bin/bash
echo "Test script executed successfully!"
echo "Current directory: $(pwd)"
EOF
chmod +x "$TEST_DIR/test-script.sh"

# Create test script that accepts arguments
cat > "$TEST_DIR/test-args.sh" << 'EOF'
#!/bin/bash
echo "Script executed with arguments"
echo "Total arguments: $#"
for arg in "$@"; do
    echo "Arg: $arg"
done
EOF
chmod +x "$TEST_DIR/test-args.sh"

# Create test files
cat > "$TEST_DIR/config.json" << 'EOF'
{"name": "test-config", "version": "1.0.0"}
EOF

cat > "$TEST_DIR/README.md" << 'EOF'
# Test Project
This is a test markdown file.
EOF

# Update plugin config temporarily
ORIGINAL_CONFIG=""
if [ -f "$SCRIPT_DIR/config" ]; then
    ORIGINAL_CONFIG=$(grep -E '^\s*dev_directory\s*=' "$SCRIPT_DIR/config" | cut -d '=' -f2- | xargs)
    cp "$SCRIPT_DIR/config" "$SCRIPT_DIR/config.backup"
    sed -i.tmp "s|dev_directory = .*|dev_directory = $TEST_DIR|" "$SCRIPT_DIR/config"
    
    # Reload plugin with new config
    source "$SCRIPT_DIR/zsh-dev-navigator.plugin.zsh"
    print_info "Updated config to use test directory"
fi

# =============================================================================
# Test Functions
# =============================================================================

test_basic_navigation() {
    print_header "Basic Navigation Tests"
    
    print_test "Navigate to existing directory"
    cd /tmp
    if echo "" | dev existing-project 2>/dev/null && [ "$(pwd)" = "$TEST_DIR/existing-project" ]; then
        print_success "Directory navigation works"
    else
        print_failure "Directory navigation failed"
    fi
    
    print_test "Navigate to nested directory"
    cd /tmp
    if echo "" | dev nested-project/subdir 2>/dev/null && [ "$(pwd)" = "$TEST_DIR/nested-project/subdir" ]; then
        print_success "Nested directory navigation works"
    else
        print_failure "Nested directory navigation failed"
    fi
    
    print_test "Navigate to root dev directory"
    cd /tmp
    if echo "" | dev 2>/dev/null && [ "$(pwd)" = "$TEST_DIR" ]; then
        print_success "Root directory navigation works"
    else
        print_failure "Root directory navigation failed"
    fi
}

test_file_handling() {
    print_header "File Handling Tests"
    
    cd "$TEST_DIR"
    
    print_test "File execution with confirmation (yes)"
    if echo "y" | dev test-script.sh 2>/dev/null | grep -q "Test script executed successfully"; then
        print_success "File execution with confirmation works"
    else
        print_failure "File execution with confirmation failed"
    fi
    
    print_test "File execution cancellation (no)"
    if echo "n" | dev test-script.sh 2>/dev/null | grep -q "File execution cancelled"; then
        print_success "File execution cancellation works"
    else
        print_failure "File execution cancellation failed"
    fi
    
    print_test "File opening in editor with -o flag"
    if dev -o config.json 2>/dev/null | grep -q "Opened file in"; then
        print_success "File opening with -o flag works"
    else
        print_failure "File opening with -o flag failed"
    fi
    
    print_test "Create new file with -o flag"
    if echo "y" | dev -o new-file.txt 2>/dev/null | grep -q "Created and opened file"; then
        print_success "New file creation with -o flag works"
    else
        print_failure "New file creation with -o flag failed"
    fi
    
    print_test "File execution with arguments"
    local output=$(echo "y" | dev test-args.sh -ac --verbose 2>/dev/null)
    if echo "$output" | grep -q "Script executed with arguments" && \
       echo "$output" | grep -q "Total arguments: 2" && \
       echo "$output" | grep -q "Arg: -ac" && \
       echo "$output" | grep -q "Arg: --verbose"; then
        print_success "File execution with arguments works"
    else
        print_failure "File execution with arguments failed"
    fi
    
    print_test "File execution with interactive argument input"
    local output=$(printf "y\n-x --test\n" | dev test-args.sh 2>/dev/null)
    if echo "$output" | grep -q "Enter arguments" && \
       echo "$output" | grep -q "Executing with arguments: -x --test" && \
       echo "$output" | grep -q "Script executed with arguments" && \
       echo "$output" | grep -q "Total arguments: 2" && \
       echo "$output" | grep -q "Arg: -x" && \
       echo "$output" | grep -q "Arg: --test"; then
        print_success "Interactive argument input works"
    else
        print_failure "Interactive argument input failed"
    fi
}

test_directory_creation() {
    print_header "Directory Creation Tests"
    
    cd "$TEST_DIR"
    
    print_test "Create new directory with -c flag"
    if echo "" | dev -c new-test-project 2>/dev/null && [ -d "$TEST_DIR/new-test-project" ]; then
        print_success "Directory creation with -c flag works"
    else
        print_failure "Directory creation with -c flag failed"
    fi
    
    print_test "Create directory with git init using -cg flag"
    if echo "" | dev -cg git-test-project 2>/dev/null && [ -d "$TEST_DIR/git-test-project/.git" ]; then
        print_success "Directory creation with git init works"
    else
        print_failure "Directory creation with git init failed"
    fi
    
    print_test "Prevent -c flag usage with files"
    if echo "" | dev -c test-script.sh 2>&1 | grep -q "Cannot use -c or -cg flags with files"; then
        print_success "Prevention of -c flag with files works"
    else
        print_failure "Prevention of -c flag with files failed"
    fi
    
    print_test "Prevent -cg flag usage with files"
    if echo "" | dev -cg config.json 2>&1 | grep -q "Cannot use -c or -cg flags with files"; then
        print_success "Prevention of -cg flag with files works"
    else
        print_failure "Prevention of -cg flag with files failed"
    fi
}

test_intelligent_detection() {
    print_header "Intelligent Detection Tests"
    
    cd "$TEST_DIR"
    
    print_test "File detection by extension"
    if echo "n" | dev new-script.sh 2>/dev/null | grep -q "File does not exist"; then
        print_success "File detection by extension works"
    else
        print_failure "File detection by extension failed"
    fi
    
    print_test "Directory suggestion for names without extension"
    if echo "" | dev non-existent-project 2>&1 | grep -q "Use -c flag to create"; then
        print_success "Directory suggestion works"
    else
        print_failure "Directory suggestion failed"
    fi
}

test_editor_integration() {
    print_header "Editor Integration Tests"
    
    cd "$TEST_DIR"
    
    print_test "Open existing directory in editor"
    if dev -o existing-project 2>/dev/null | grep -q "Opened in"; then
        print_success "Directory opening in editor works"
    else
        print_failure "Directory opening in editor failed"
    fi
    
    print_test "Combined directory creation and editor opening"
    if echo "" | dev -c -o editor-test-project 2>/dev/null && [ -d "$TEST_DIR/editor-test-project" ]; then
        print_success "Combined -c -o flags work"
    else
        print_failure "Combined -c -o flags failed"
    fi
}

# =============================================================================
# Run All Tests
# =============================================================================

print_header "ZSH Dev Navigator - Enhanced Quick Tests"

test_basic_navigation
test_file_handling
test_directory_creation
test_intelligent_detection
test_editor_integration

# =============================================================================
# Results and Cleanup
# =============================================================================

print_header "Test Results Summary"

echo -e "${BLUE}Total Tests: $TOTAL_TESTS${NC}"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All tests passed! The plugin is working correctly.${NC}"
    exit_code=0
else
    echo -e "\n${RED}❌ Some tests failed. Please review the output above.${NC}"
    exit_code=1
fi

# Cleanup
print_info "Cleaning up test environment..."

# Restore original config
if [ -f "$SCRIPT_DIR/config.backup" ]; then
    mv "$SCRIPT_DIR/config.backup" "$SCRIPT_DIR/config"
    print_info "Restored original config"
fi

# Remove temp files
rm -f "$SCRIPT_DIR/config.tmp"

# Remove test directory
if [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
    print_info "Test directory removed"
fi

print_info "Cleanup completed"

# Final message
if [ $exit_code -eq 0 ]; then
    echo -e "\n${GREEN}✅ Plugin is ready to use!${NC}"
else
    echo -e "\n${YELLOW}⚠️  Please check the failed tests and fix any issues.${NC}"
fi

exit $exit_code
