#!/bin/bash

# Interactive MCP Server Setup for Claude Desktop with Clear Instructions
# This script provides a checkbox-style interface for MCP server selection

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration
ENV_FILE="$HOME/.claude_mcp_env"
BACKUP_DIR="$HOME/.claude_backups"
TEMP_JSON="/tmp/claude_mcp_config.json"

# Server definitions with categories
declare -a CORE_SERVERS=(
    "context7:Context7 - Library documentation access (SuperClaude --c7):false"
    "sequential:Sequential - Multi-step reasoning (SuperClaude --seq):false"
    "magic:Magic - AI-generated UI components (SuperClaude --magic):false"
    "puppeteer:Puppeteer - Browser automation (SuperClaude --pup):false"
)

declare -a ADDITIONAL_SERVERS=(
    "n8n:n8n - Workflow automation:false"
    "clickup:ClickUp - Project management:false"
    "orsanova-docs:OrsaNova Docs - Website documentation:false"
    "n8n-workflows-docs:n8n Workflows Docs - Documentation:false"
    "clickup-docs:ClickUp Docs - Documentation:false"
)

# Function to print colored output
print_header() { echo -e "${BLUE}$1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${CYAN}ℹ $1${NC}"; }

# Function to add environment variable
add_env_var() {
    local var_name="$1"
    local var_value="$2"
    
    touch "$ENV_FILE"
    
    if [[ -f "$ENV_FILE" ]]; then
        grep -v "^export $var_name=" "$ENV_FILE" > "${ENV_FILE}.tmp" 2>/dev/null || true
        mv "${ENV_FILE}.tmp" "$ENV_FILE"
    fi
    
    echo "export $var_name=\"$var_value\"" >> "$ENV_FILE"
    print_success "Added $var_name to environment"
}

# Function to get user input
get_input() {
    local prompt="$1"
    local var_name="$2"
    local is_secret="${3:-false}"
    local value=""
    
    while [[ -z "$value" ]]; do
        if [[ "$is_secret" == "true" ]]; then
            read -s -p "$(echo -e "${YELLOW}$prompt: ${NC}")" value
            echo
        else
            read -p "$(echo -e "${YELLOW}$prompt: ${NC}")" value
        fi
        
        if [[ -z "$value" ]]; then
            print_error "Value cannot be empty. Please try again."
        fi
    done
    
    add_env_var "$var_name" "$value"
}

# Function to toggle server selection
toggle_server() {
    local server_array="$1"
    local index="$2"
    
    if [[ "$server_array" == "CORE" ]]; then
        local server_info="${CORE_SERVERS[$index]}"
        local server_id="${server_info%%:*}"
        local server_desc="${server_info#*:}"
        server_desc="${server_desc%:*}"
        local selected="${server_info##*:}"
        
        if [[ "$selected" == "true" ]]; then
            CORE_SERVERS[$index]="$server_id:$server_desc:false"
        else
            CORE_SERVERS[$index]="$server_id:$server_desc:true"
        fi
    else
        local server_info="${ADDITIONAL_SERVERS[$index]}"
        local server_id="${server_info%%:*}"
        local server_desc="${server_info#*:}"
        server_desc="${server_desc%:*}"
        local selected="${server_info##*:}"
        
        if [[ "$selected" == "true" ]]; then
            ADDITIONAL_SERVERS[$index]="$server_id:$server_desc:false"
        else
            ADDITIONAL_SERVERS[$index]="$server_id:$server_desc:true"
        fi
    fi
}

# Function to display server selection interface
show_selection_interface() {
    clear
    print_header "════════════════════════════════════════════════════════════════"
    print_header "           Interactive MCP Server Setup for Claude"
    print_header "════════════════════════════════════════════════════════════════"
    echo
    
    echo -e "${WHITE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}                        SELECTION INSTRUCTIONS${NC}"
    echo -e "${WHITE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}• Type a number (1-9) + ENTER to toggle that server on/off${NC}"
    echo -e "${YELLOW}• Type 'a' + ENTER to select ALL SuperClaude core servers (1-4)${NC}"
    echo -e "${YELLOW}• Type 'c' + ENTER to clear all selections${NC}"
    echo -e "${YELLOW}• Type 's' + ENTER to show current selections${NC}"
    echo -e "${YELLOW}• Press ENTER alone to continue with selected servers${NC}"
    echo -e "${YELLOW}• Type 'q' + ENTER to quit${NC}"
    echo -e "${WHITE}═══════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${CYAN}💡 EXAMPLE: To select Context7, type: ${WHITE}1${NC} ${CYAN}then press ${WHITE}ENTER${NC}"
    echo -e "${CYAN}💡 QUICK START: Type ${WHITE}a${NC} ${CYAN}+ ENTER to select all core servers${NC}"
    echo
    
    # Show SuperClaude Core Servers
    echo -e "${WHITE}SuperClaude Core Servers (Recommended):${NC}"
    for i in "${!CORE_SERVERS[@]}"; do
        local server_info="${CORE_SERVERS[$i]}"
        local server_id="${server_info%%:*}"
        local server_desc="${server_info#*:}"
        server_desc="${server_desc%:*}"
        local selected="${server_info##*:}"
        
        local checkbox="[ ]"
        local color="$NC"
        if [[ "$selected" == "true" ]]; then
            checkbox="[${GREEN}✓${NC}]"
            color="$GREEN"
        fi
        
        echo -e "  ${WHITE}Type '${PURPLE}$((i+1))${WHITE}' + ENTER:${NC} $checkbox ${color}$server_desc${NC}"
    done
    
    echo
    # Show Additional Servers
    echo -e "${WHITE}Additional Servers:${NC}"
    for i in "${!ADDITIONAL_SERVERS[@]}"; do
        local server_info="${ADDITIONAL_SERVERS[$i]}"
        local server_id="${server_info%%:*}"
        local server_desc="${server_info#*:}"
        server_desc="${server_desc%:*}"
        local selected="${server_info##*:}"
        
        local checkbox="[ ]"
        local color="$NC"
        if [[ "$selected" == "true" ]]; then
            checkbox="[${GREEN}✓${NC}]"
            color="$GREEN"
        fi
        
        local display_num=$((i+${#CORE_SERVERS[@]}+1))
        echo -e "  ${WHITE}Type '${PURPLE}$display_num${WHITE}' + ENTER:${NC} $checkbox ${color}$server_desc${NC}"
    done
    
    echo
    
    # Show current selections summary
    local selected_count=0
    local selected_names=""
    
    for server_info in "${CORE_SERVERS[@]}"; do
        local selected="${server_info##*:}"
        if [[ "$selected" == "true" ]]; then
            local server_id="${server_info%%:*}"
            selected_names="$selected_names $server_id"
            ((selected_count++))
        fi
    done
    
    for server_info in "${ADDITIONAL_SERVERS[@]}"; do
        local selected="${server_info##*:}"
        if [[ "$selected" == "true" ]]; then
            local server_id="${server_info%%:*}"
            selected_names="$selected_names $server_id"
            ((selected_count++))
        fi
    done
    
    if [[ $selected_count -gt 0 ]]; then
        echo -e "${WHITE}🎯 Current Selection ($selected_count servers):${NC}${GREEN}$selected_names${NC}"
    else
        echo -e "${WHITE}🎯 Current Selection:${NC} ${YELLOW}No servers selected${NC}"
    fi
    echo
}

# Function to handle server selection
handle_selection() {
    while true; do
        show_selection_interface
        
        read -p "$(echo -e "${WHITE}➤ Type your choice and press ENTER: ${NC}")" choice
        
        case "$choice" in
            # Core servers (1-4)
            [1-4])
                local index=$((choice-1))
                toggle_server "CORE" "$index"
                ;;
            # Additional servers (5-9)
            [5-9])
                local index=$((choice-${#CORE_SERVERS[@]}-1))
                if [[ $index -ge 0 && $index -lt ${#ADDITIONAL_SERVERS[@]} ]]; then
                    toggle_server "ADDITIONAL" "$index"
                else
                    print_error "Invalid selection: '$choice'"
                    echo -e "${YELLOW}Please choose a number from 1-9, then press ENTER.${NC}"
                    sleep 2
                fi
                ;;
            # Quick actions
            a|A)
                for i in "${!CORE_SERVERS[@]}"; do
                    local server_info="${CORE_SERVERS[$i]}"
                    local server_id="${server_info%%:*}"
                    local server_desc="${server_info#*:}"
                    server_desc="${server_desc%:*}"
                    CORE_SERVERS[$i]="$server_id:$server_desc:true"
                done
                ;;
            c|C)
                for i in "${!CORE_SERVERS[@]}"; do
                    local server_info="${CORE_SERVERS[$i]}"
                    local server_id="${server_info%%:*}"
                    local server_desc="${server_info#*:}"
                    server_desc="${server_desc%:*}"
                    CORE_SERVERS[$i]="$server_id:$server_desc:false"
                done
                for i in "${!ADDITIONAL_SERVERS[@]}"; do
                    local server_info="${ADDITIONAL_SERVERS[$i]}"
                    local server_id="${server_info%%:*}"
                    local server_desc="${server_info#*:}"
                    server_desc="${server_desc%:*}"
                    ADDITIONAL_SERVERS[$i]="$server_id:$server_desc:false"
                done
                ;;
            s|S)
                show_selection_interface
                echo
                print_info "Current selections shown above. Press ENTER to continue..."
                read
                ;;
            # Continue with selections
            "")
                local has_selections=false
                for server_info in "${CORE_SERVERS[@]}" "${ADDITIONAL_SERVERS[@]}"; do
                    local selected="${server_info##*:}"
                    if [[ "$selected" == "true" ]]; then
                        has_selections=true
                        break
                    fi
                done
                
                if [[ "$has_selections" == "false" ]]; then
                    print_error "Please select at least one server before pressing Enter."
                    echo -e "${YELLOW}Type a number (1-9) + ENTER to select servers, then press ENTER alone to continue.${NC}"
                    sleep 3
                else
                    break
                fi
                ;;
            # Quit
            q|Q)
                print_info "Setup cancelled."
                exit 0
                ;;
            *)
                print_error "Invalid choice: '$choice'"
                echo -e "${YELLOW}Please type a number (1-9), 'a', 'c', 's', or 'q', then press ENTER.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Function to collect credentials for selected servers
collect_credentials() {
    local needs_n8n_creds=false
    local needs_clickup_creds=false
    
    # Check what credentials are needed
    for server_info in "${CORE_SERVERS[@]}" "${ADDITIONAL_SERVERS[@]}"; do
        local server_id="${server_info%%:*}"
        local selected="${server_info##*:}"
        
        if [[ "$selected" == "true" ]]; then
            case "$server_id" in
                "n8n")
                    needs_n8n_creds=true
                    ;;
                "clickup")
                    needs_clickup_creds=true
                    ;;
            esac
        fi
    done
    
    # Collect credentials
    if [[ "$needs_n8n_creds" == "true" ]]; then
        echo
        print_header "🔐 Setting up n8n credentials..."
        get_input "Enter N8N_API_URL (e.g., https://your-n8n-instance.com)" "N8N_API_URL" false
        get_input "Enter N8N_API_KEY" "N8N_API_KEY" true
    fi
    
    if [[ "$needs_clickup_creds" == "true" ]]; then
        echo
        print_header "🔐 Setting up ClickUp credentials..."
        get_input "Enter CLICKUP_API_KEY" "CLICKUP_API_KEY" true
    fi
}

# Function to generate JSON configuration
generate_json() {
    print_header "📝 Generating MCP Configuration..."
    
    # Get selected servers
    local selected_servers=""
    for server_info in "${CORE_SERVERS[@]}" "${ADDITIONAL_SERVERS[@]}"; do
        local server_id="${server_info%%:*}"
        local selected="${server_info##*:}"
        
        if [[ "$selected" == "true" ]]; then
            selected_servers="$selected_servers $server_id"
        fi
    done
    
    cat > "$TEMP_JSON" << 'EOF'
{
  "mcpServers": {
EOF

    local first=true
    for server in $selected_servers; do
        if [[ "$first" == "false" ]]; then
            echo "," >> "$TEMP_JSON"
        fi
        first=false
        
        case "$server" in
            "context7")
                cat >> "$TEMP_JSON" << 'EOF'
    "context7": {
      "command": "npx",
      "args": ["mcp-remote", "https://gitmcp.io/upstash/context7"],
      "description": "Context7 for library documentation access (SuperClaude --c7)"
    }
EOF
                ;;
            "sequential")
                cat >> "$TEMP_JSON" << 'EOF'
    "sequential": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "description": "Sequential thinking for multi-step reasoning (SuperClaude --seq)"
    }
EOF
                ;;
            "magic")
                cat >> "$TEMP_JSON" << 'EOF'
    "magic": {
      "command": "npx",
      "args": ["-y", "@magicuidesign/mcp@latest"],
      "description": "Magic UI design for AI-generated components (SuperClaude --magic)"
    }
EOF
                ;;
            "puppeteer")
                cat >> "$TEMP_JSON" << 'EOF'
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"],
      "description": "Puppeteer for browser automation and testing (SuperClaude --pup)"
    }
EOF
                ;;
            "n8n")
                cat >> "$TEMP_JSON" << 'EOF'
    "n8n": {
      "command": "npx",
      "args": ["n8n-mcp"],
      "env": {
        "MCP_MODE": "stdio",
        "LOG_LEVEL": "error",
        "DISABLE_CONSOLE_OUTPUT": "true",
        "N8N_API_URL": "${N8N_API_URL}",
        "N8N_API_KEY": "${N8N_API_KEY}"
      },
      "description": "n8n workflow automation integration"
    }
EOF
                ;;
            "clickup")
                cat >> "$TEMP_JSON" << 'EOF'
    "clickup": {
      "command": "uvx",
      "args": ["--from", "git+https://github.com/DiversioTeam/clickup-mcp.git", "clickup-mcp"],
      "env": {
        "CLICKUP_API_KEY": "${CLICKUP_API_KEY}"
      },
      "description": "ClickUp project management integration"
    }
EOF
                ;;
            "orsanova-docs")
                cat >> "$TEMP_JSON" << 'EOF'
    "orsanova-docs": {
      "command": "npx",
      "args": ["mcp-remote", "https://gitmcp.io/OITApps/orsanova-website"],
      "description": "OrsaNova website documentation access"
    }
EOF
                ;;
            "n8n-workflows-docs")
                cat >> "$TEMP_JSON" << 'EOF'
    "n8n-workflows-docs": {
      "command": "npx",
      "args": ["mcp-remote", "https://gitmcp.io/Zie619/n8n-workflows"],
      "description": "n8n workflows documentation"
    }
EOF
                ;;
            "clickup-docs")
                cat >> "$TEMP_JSON" << 'EOF'
    "clickup-docs": {
      "command": "npx",
      "args": ["mcp-remote", "https://gitmcp.io/DiversioTeam/clickup-mcp"],
      "description": "ClickUp MCP documentation"
    }
EOF
                ;;
        esac
    done
    
    cat >> "$TEMP_JSON" << 'EOF'
  }
}
EOF

    print_success "JSON configuration generated with $(echo $selected_servers | wc -w) servers"
    
    # Show preview
    echo
    print_info "Configuration preview:"
    echo -e "${CYAN}$(cat "$TEMP_JSON")${NC}"
    echo
    
    read -p "$(echo -e "${YELLOW}Does this configuration look correct? (y/n): ${NC}")" confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        print_info "Setup cancelled. You can run the script again to make changes."
        exit 0
    fi
}

# Function to find and update Claude config
update_claude_config() {
    print_header "🔧 Updating Claude Desktop Configuration..."
    
    local config_paths=(
        "$HOME/.config/Claude/claude_desktop_config.json"
        "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
        "$HOME/.claude/claude_desktop_config.json"
        "$HOME/AppData/Roaming/Claude/claude_desktop_config.json"
    )
    
    local config_file=""
    for path in "${config_paths[@]}"; do
        if [[ -f "$path" ]]; then
            config_file="$path"
            break
        fi
    done
    
    if [[ -z "$config_file" ]]; then
        print_warning "Could not find Claude Desktop config file automatically."
        echo
        print_info "Please manually copy the configuration to your Claude Desktop settings."
        print_info "You can find the generated config at: $TEMP_JSON"
        echo
        print_info "Common locations for Claude Desktop config:"
        for path in "${config_paths[@]}"; do
            echo "  • $path"
        done
        return 1
    fi
    
    print_info "Found Claude config at: $config_file"
    
    # Create backup
    mkdir -p "$BACKUP_DIR"
    local backup_name="claude_desktop_config_$(date +%Y%m%d_%H%M%S).json"
    cp "$config_file" "$BACKUP_DIR/$backup_name"
    print_success "Config backed up to: $BACKUP_DIR/$backup_name"
    
    # Update config
    cp "$TEMP_JSON" "$config_file"
    print_success "Claude Desktop configuration updated successfully!"
    
    # Set permissions on env file
    chmod 600 "$ENV_FILE"
    print_success "Environment file permissions secured"
}

# Function to show final instructions
show_final_instructions() {
    clear
    print_header "🎉 MCP Server Setup Complete!"
    echo
    
    local selected_count=0
    local selected_servers=""
    for server_info in "${CORE_SERVERS[@]}" "${ADDITIONAL_SERVERS[@]}"; do
        local server_id="${server_info%%:*}"
        local selected="${server_info##*:}"
        
        if [[ "$selected" == "true" ]]; then
            selected_servers="$selected_servers $server_id"
            ((selected_count++))
        fi
    done
    
    print_success "Successfully configured $selected_count MCP servers"
    print_success "Environment file created: $ENV_FILE"
    echo
    
    print_info "Installed servers:$selected_servers"
    echo
    
    print_header "🚀 Next Steps:"
    echo "1. ${YELLOW}Load environment variables:${NC}"
    echo "   source $ENV_FILE"
    echo
    echo "2. ${YELLOW}Restart Claude Desktop${NC} for changes to take effect"
    echo
    echo "3. ${YELLOW}Test your SuperClaude setup:${NC}"
    
    for server in $selected_servers; do
        case "$server" in
            "context7")
                echo "   /analyze --code --c7 --think"
                ;;
            "sequential")
                echo "   /design --api --seq --persona-architect"
                ;;
            "magic")
                echo "   /build --react --magic --persona-frontend"
                ;;
            "puppeteer")
                echo "   /test --e2e --pup --persona-qa"
                ;;
        esac
    done
    
    echo
    print_header "💡 Tips:"
    echo "• Add 'source $ENV_FILE' to your shell profile (~/.bashrc, ~/.zshrc) for automatic loading"
    echo "• Use '/troubleshoot --introspect' in SuperClaude to debug any MCP issues"
    echo "• Check '$BACKUP_DIR' for configuration backups"
    echo
    
    print_success "Your MCP servers are ready to use with SuperClaude!"
}

# Main execution
main() {
    # Check prerequisites
    if ! command -v npx &> /dev/null; then
        print_error "npx (Node.js) is required but not installed."
        print_info "Please install Node.js from: https://nodejs.org/"
        exit 1
    fi
    
    # Interactive server selection
    handle_selection
    
    # Collect credentials for selected servers
    collect_credentials
    
    # Generate JSON configuration
    generate_json
    
    # Update Claude Desktop config
    update_claude_config
    
    # Show final instructions
    show_final_instructions
}

# Cleanup on exit
trap 'rm -f "$TEMP_JSON"' EXIT

# Run main function
main "$@"