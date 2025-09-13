#!/usr/bin/env bash

# Script to automatically detect and set optimal display settings for Sway
# This script finds the best resolution and maximum refresh rate for each output

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if we're in a Sway session
check_sway_session() {
    if [ -z "$WAYLAND_DISPLAY" ]; then
        print_error "WAYLAND_DISPLAY is not set. Make sure you're running this in a Wayland session."
        exit 1
    fi
    
    if [ -z "$SWAYSOCK" ]; then
        print_warning "SWAYSOCK not set, trying to find it automatically..."
        # Try to find the Sway socket
        local sway_sock=$(find /tmp -name "sway-ipc.*" 2>/dev/null | head -1)
        if [ -n "$sway_sock" ]; then
            export SWAYSOCK="$sway_sock"
            print_status "Found Sway socket: $SWAYSOCK"
        else
            print_error "Could not find Sway socket. Make sure Sway is running."
            exit 1
        fi
    fi
}

# Function to check if swaymsg is available and working
check_sway() {
    if ! command -v swaymsg &> /dev/null; then
        print_error "swaymsg not found. Make sure Sway is installed."
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        print_error "jq not found. Please install jq for JSON parsing."
        exit 1
    fi
    
    # Test if swaymsg can connect
    if ! swaymsg -t get_version &> /dev/null; then
        print_error "Cannot connect to Sway. Make sure you're running this script from within a Sway session."
        print_error "Current WAYLAND_DISPLAY: ${WAYLAND_DISPLAY:-'not set'}"
        print_error "Current SWAYSOCK: ${SWAYSOCK:-'not set'}"
        exit 1
    fi
}

# Function to debug outputs
debug_outputs() {
    print_status "Debugging output information..."
    
    # Raw output from swaymsg
    print_status "Raw swaymsg output:"
    swaymsg -t get_outputs 2>&1 || true
    echo
    
    # Parsed with jq
    print_status "Parsed output names:"
    swaymsg -t get_outputs | jq -r '.[] | .name' 2>/dev/null || true
    echo
    
    # Check active status
    print_status "Output details:"
    swaymsg -t get_outputs | jq -r '.[] | "\(.name): active=\(.active), current_mode=\(.current_mode.width)x\(.current_mode.height)@\(.current_mode.refresh)Hz"' 2>/dev/null || true
    echo
}

# Function to get the highest refresh rate for a given resolution
get_max_refresh_rate() {
    local output="$1"
    local resolution="$2"
    
    print_status "Getting refresh rates for $output at $resolution..."
    
    # Get all available modes for this output and resolution
    local modes=$(swaymsg -t get_outputs | jq -r --arg output "$output" --arg res "$resolution" '
        .[] | select(.name == $output) | 
        .modes[] | select(.width + "x" + .height == $res) | 
        .refresh' 2>/dev/null)
    
    if [ -z "$modes" ]; then
        print_warning "No modes found for $output at $resolution, using 60Hz fallback"
        echo "60"
        return
    fi
    
    # Find the maximum refresh rate
    local max_refresh=$(echo "$modes" | sort -n | tail -1)
    print_status "Available refresh rates: $(echo "$modes" | tr '\n' ' ')"
    print_status "Maximum refresh rate: ${max_refresh}Hz"
    
    echo "$max_refresh"
}

# Function to get the optimal resolution (prefer current resolution)
get_optimal_resolution() {
    local output="$1"
    
    print_status "Getting optimal resolution for $output..."
    
    # Get the current resolution
    local current_res=$(swaymsg -t get_outputs | jq -r --arg output "$output" '
        .[] | select(.name == $output) | 
        .current_mode.width + "x" + .current_mode.height' 2>/dev/null)
    
    if [ -n "$current_res" ] && [ "$current_res" != "nullxnull" ]; then
        print_status "Using current resolution: $current_res"
        echo "$current_res"
        return
    fi
    
    # Fallback to first available mode
    local first_mode=$(swaymsg -t get_outputs | jq -r --arg output "$output" '
        .[] | select(.name == $output) | 
        .modes[0].width + "x" + .modes[0].height' 2>/dev/null)
    
    if [ -n "$first_mode" ] && [ "$first_mode" != "nullxnull" ]; then
        print_status "Using first available mode: $first_mode"
        echo "$first_mode"
    else
        print_error "No resolution found for $output"
        echo ""
    fi
}

# Function to get all available modes for debugging
show_available_modes() {
    local output="$1"
    
    print_status "Available modes for $output:"
    swaymsg -t get_outputs | jq -r --arg output "$output" '
        .[] | select(.name == $output) | 
        .modes[] | "  \(.width)x\(.height)@\(.refresh)Hz"' 2>/dev/null || true
}

# Function to configure a single output
configure_output() {
    local output="$1"
    print_status "Configuring output: $output"
    
    # Show available modes
    show_available_modes "$output"
    
    # Get optimal resolution
    local resolution=$(get_optimal_resolution "$output")
    if [ -z "$resolution" ]; then
        print_error "Could not determine resolution for $output"
        return 1
    fi
    
    # Get maximum refresh rate for this resolution
    local max_refresh=$(get_max_refresh_rate "$output" "$resolution")
    
    # Set the output with optimal settings
    local mode="${resolution}@${max_refresh}Hz"
    print_status "Setting mode: $mode"
    
    if swaymsg "output $output mode $mode" 2>/dev/null; then
        print_success "Successfully set $output to $mode"
        return 0
    else
        print_warning "Failed to set $output to $mode, trying without refresh rate"
        if swaymsg "output $output mode $resolution" 2>/dev/null; then
            print_success "Successfully set $output to $resolution"
            return 0
        else
            print_error "Failed to configure $output"
            return 1
        fi
    fi
}

# Function to show current settings
show_current_settings() {
    print_status "Current output settings:"
    swaymsg -t get_outputs | jq -r '.[] | "  \(.name): \(.current_mode.width)x\(.current_mode.height)@\(.current_mode.refresh)Hz"' 2>/dev/null || true
}

# Main function
main() {
    print_status "Starting display configuration..."
    
    # Check if we're in a Sway session
    check_sway_session
    
    # Check dependencies
    check_sway
    
    # Debug outputs first
    debug_outputs
    
    # Show current settings before changes
    print_status "Current settings before configuration:"
    show_current_settings
    echo
    
    # Get all connected outputs (try different approaches)
    local outputs=""
    
    # First try: active outputs only
    outputs=$(swaymsg -t get_outputs | jq -r '.[] | select(.active == true) | .name' 2>/dev/null)
    print_status "Active outputs: $(echo "$outputs" | tr '\n' ' ')"
    
    if [ -z "$outputs" ]; then
        print_warning "No active outputs found, trying all outputs..."
        # Second try: all outputs
        outputs=$(swaymsg -t get_outputs | jq -r '.[] | .name' 2>/dev/null)
        print_status "All outputs: $(echo "$outputs" | tr '\n' ' ')"
    fi
    
    if [ -z "$outputs" ]; then
        print_error "No outputs found at all!"
        print_error "This might indicate:"
        print_error "1. No displays are connected"
        print_error "2. Graphics drivers are not working properly"
        print_error "3. Sway is not detecting displays"
        print_error "4. You might need to restart Sway"
        exit 1
    fi
    
    print_status "Found outputs: $(echo "$outputs" | tr '\n' ' ')"
    echo
    
    # Configure each output
    local success_count=0
    local total_count=0
    
    while IFS= read -r output; do
        if [ -n "$output" ]; then
            total_count=$((total_count + 1))
            if configure_output "$output"; then
                success_count=$((success_count + 1))
            fi
            echo
        fi
    done <<< "$outputs"
    
    # Show final results
    print_status "Configuration complete! ($success_count/$total_count outputs configured successfully)"
    echo
    show_current_settings
    
    if [ $success_count -eq $total_count ]; then
        print_success "All outputs configured successfully!"
        exit 0
    else
        print_warning "Some outputs failed to configure. Check the output above for details."
        exit 1
    fi
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Automatically configure Sway displays with optimal resolution and refresh rate."
        echo
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --current      Show current display settings only"
        echo "  --modes        Show available modes for all outputs"
        echo "  --debug        Show detailed debugging information"
        echo
        echo "Requirements:"
        echo "  - Must be run from within a Sway session"
        echo "  - jq package must be installed"
        echo
        exit 0
        ;;
    --current)
        check_sway_session
        check_sway
        show_current_settings
        exit 0
        ;;
    --modes)
        check_sway_session
        check_sway
        print_status "Available modes for all outputs:"
        swaymsg -t get_outputs | jq -r '.[] | "\(.name):" as $name | .modes[] | "  \($name) \(.width)x\(.height)@\(.refresh)Hz"' 2>/dev/null
        exit 0
        ;;
    --debug)
        check_sway_session
        check_sway
        debug_outputs
        exit 0
        ;;
    "")
        main
        ;;
    *)
        print_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
