#!/bin/bash

################################################################################
# PRD to Technical Design Document (TDD) Generator
# 
# This script orchestrates the transformation of Product Requirements Documents
# into comprehensive Technical Design Documents with interactive feedback loops.
#
# Usage: ./scripts/generate-tdd.sh [OPTIONS]
# Options:
#   --prd-file <path>      Path to PRD document
#   --output <path>        Output directory for TDD (default: ./docs/tdds/)
#   --feature-name <name>  Feature name for document naming
#   --skip-confirmation    Skip interactive confirmations
#   --help                 Display this help message
#
# Requirements:
#   - git
#   - find
#   - Bash 4.0+
#   - jq (optional, for JSON parsing)
################################################################################

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Configuration
PRD_FILE=""
OUTPUT_DIR="./docs/tdds"
FEATURE_NAME=""
SKIP_CONFIRMATION=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="${SCRIPT_DIR}/.claude/skills/prd-to-tdd"
TDD_TEMPLATE="${SKILL_DIR}/SKILL.md"
CONTEXT_FILE=""
TDD_OUTPUT=""

################################################################################
# Utility Functions
################################################################################

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_step() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

confirm() {
    local prompt="$1"
    if [ "$SKIP_CONFIRMATION" = true ]; then
        return 0
    fi
    
    while true; do
        read -p "$(echo -e ${YELLOW}$prompt${NC} (y/n): )" -n 1 -r
        echo
        case $REPLY in
            [Yy]) return 0 ;;
            [Nn]) return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

show_help() {
    head -n 19 "$0" | tail -n +3
}

validate_prerequisites() {
    print_header "Validating Prerequisites"
    
    # Check required tools
    local missing_tools=()
    for tool in git find; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        exit 1
    fi
    print_step "All required tools present"
    
    # Check skill file exists
    if [ ! -f "$TDD_TEMPLATE" ]; then
        print_error "Skill template not found at $TDD_TEMPLATE"
        exit 1
    fi
    print_step "PRD-to-TDD skill template located"
    
    # Check git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
    print_step "Git repository verified"
}

validate_prd_input() {
    print_header "Validating PRD Input"
    
    if [ -z "$PRD_FILE" ]; then
        print_error "No PRD file specified"
        echo "Checking for PRD in common locations..."
        
        local prd_candidates=(
            "PRD.md"
            "prd.md"
            "docs/PRD.md"
            "docs/prd.md"
            "requirements/PRD.md"
        )
        
        for candidate in "${prd_candidates[@]}"; do
            if [ -f "$candidate" ]; then
                PRD_FILE="$candidate"
                print_step "Found PRD at: $PRD_FILE"
                break
            fi
        done
    fi
    
    if [ -z "$PRD_FILE" ]; then
        read -p "Enter path to PRD file: " PRD_FILE
    fi
    
    if [ ! -f "$PRD_FILE" ]; then
        print_error "PRD file not found: $PRD_FILE"
        exit 1
    fi
    
    print_step "PRD file validated"
    print_info "PRD Location: $PRD_FILE"
    print_info "PRD Size: $(wc -c < "$PRD_FILE") bytes"
}

extract_feature_name() {
    print_header "Extracting Feature Information"
    
    if [ -z "$FEATURE_NAME" ]; then
        # Try to extract from PRD title or first heading
        FEATURE_NAME=$(grep -m 1 "^#" "$PRD_FILE" | sed 's/^[#\s]*//; s/\s*$//' || echo "")
    fi
    
    if [ -z "$FEATURE_NAME" ]; then
        read -p "Enter feature name (for document naming): " FEATURE_NAME
    fi
    
    if [ -z "$FEATURE_NAME" ]; then
        FEATURE_NAME="feature_$(date +%s)"
    fi
    
    # Convert to valid filename
    FEATURE_NAME=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_-')
    
    print_step "Feature name: $FEATURE_NAME"
}

discover_repository_context() {
    print_header "Discovering Repository Context"
    
    CONTEXT_FILE=$(mktemp)
    
    {
        echo "# Repository Context Analysis"
        echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo ""
        
        echo "## 1. Repository Metadata"
        echo "- Remote URL: $(git config --get remote.origin.url 2>/dev/null || echo 'N/A')"
        echo "- Current Branch: $(git rev-parse --abbrev-ref HEAD)"
        echo "- Latest Commit: $(git log -1 --format='%h - %s' 2>/dev/null || echo 'N/A')"
        echo ""
        
        echo "## 2. Directory Structure"
        echo '```'
        find . -maxdepth 3 -type d ! -path '*/\.*' ! -path '*/node_modules/*' ! -path '*/.git/*' 2>/dev/null | head -50 | sort
        echo '```'
        echo ""
        
        echo "## 3. Technology Stack Detection"
        echo "### Package Management & Dependencies"
        find . -maxdepth 2 -type f \( -name "package.json" -o -name "requirements.txt" -o -name "go.mod" \
            -o -name "pom.xml" -o -name "build.gradle" -o -name "Cargo.toml" -o -name "mix.exs" \
            -o -name "Gemfile" \) 2>/dev/null | while read -r file; do
            echo "- Found: $file"
        done
        echo ""
        
        echo "### Configuration Files"
        find . -maxdepth 2 -type f \( -name "*.env*" -o -name "docker*" -o -name "*.yml" -o -name "*.yaml" \
            ! -path '*/node_modules/*' ! -path '*/.git/*' \) 2>/dev/null | head -20 | while read -r file; do
            echo "- $file"
        done
        echo ""
        
        echo "## 4. Architecture Patterns"
        echo "### Source Directory Layout"
        find ./src -type d 2>/dev/null | head -20 | sed 's/^/  /' || \
        find . -maxdepth 2 -type d \( -name "src" -o -name "lib" -o -name "app" -o -name "services" \) 2>/dev/null | while read -r dir; do
            echo "  Found: $dir"
        done
        echo ""
        
        echo "### Design Patterns in Codebase"
        find . -type f \( -name "*controller*" -o -name "*service*" -o -name "*repository*" \
            -o -name "*model*" -o -name "*entity*" \) ! -path '*/node_modules/*' ! -path '*/.git/*' 2>/dev/null | head -20 | while read -r file; do
            echo "- $file"
        done
        echo ""
        
        echo "## 5. Recent Architecture Decisions"
        echo '```'
        git log --oneline --all --grep="architecture\|design\|refactor" 2>/dev/null | head -20 || echo "No matching commits found"
        echo '```'
        echo ""
        
        echo "## 6. Lock Files & Versions"
        find . -maxdepth 2 -type f \( -name "*.lock" -o -name "*.sum" \) 2>/dev/null | while read -r file; do
            echo "- $file (size: $(wc -l < "$file") lines)"
        done
        echo ""
        
        echo "## 7. Documentation Index"
        find . -name "*.md" \( -path "*/docs/*" -o -name "ARCHITECTURE*" -o -name "DESIGN*" -o -name "ADR*" \) 2>/dev/null | while read -r file; do
            echo "- $file"
        done
        echo ""
        
        echo "## 8. File Type Distribution"
        echo '```'
        find . ! -path '*/\.*' ! -path '*/node_modules/*' ! -path '*/.git/*' -type f 2>/dev/null | \
            sed 's/.*\.//' | sort | uniq -c | sort -rn | head -15
        echo '```'
        
    } > "$CONTEXT_FILE"
    
    print_step "Repository context discovered"
    print_info "Context saved to: $CONTEXT_FILE"
}

display_context_summary() {
    print_header "Repository Context Summary"
    echo ""
    head -n 50 "$CONTEXT_FILE"
    echo ""
    echo -e "${YELLOW}... (showing first 50 lines, see full context in context file)${NC}"
}

create_output_directory() {
    print_header "Preparing Output Directory"
    
    mkdir -p "$OUTPUT_DIR"
    TDD_OUTPUT="${OUTPUT_DIR}/TDD_${FEATURE_NAME}_$(date +%Y%m%d_%H%M%S).md"
    
    print_step "Output directory: $OUTPUT_DIR"
    print_step "TDD will be saved to: $TDD_OUTPUT"
}

generate_initial_tdd() {
    print_header "Generating Initial TDD Structure"
    
    {
        echo "# Technical Design Document: $FEATURE_NAME"
        echo ""
        echo "**Generated**: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo "**Feature**: $FEATURE_NAME"
        echo ""
        
        echo "## Document Status: DRAFT - REQUIRES HUMAN REVIEW"
        echo ""
        echo "This document was generated from a PRD and repository context analysis."
        echo "Review and refine each section during the feedback checkpoint process."
        echo ""
        
        echo "---"
        echo ""
        
        echo "## PRD Summary"
        echo ""
        echo "### Source PRD"
        echo '```'
        head -n 50 "$PRD_FILE"
        echo '```'
        if [ $(wc -l < "$PRD_FILE") -gt 50 ]; then
            echo ""
            echo "_Note: PRD has $(wc -l < "$PRD_FILE") lines. Full content should be reviewed separately._"
        fi
        echo ""
        
        echo "---"
        echo ""
        
        echo "## Repository Context"
        echo ""
        cat "$CONTEXT_FILE"
        echo ""
        
        echo "---"
        echo ""
        
        echo "## Technical Design (To Be Completed)"
        echo ""
        tail -n +20 "$TDD_TEMPLATE"
        
    } > "$TDD_OUTPUT"
    
    print_step "Initial TDD generated: $TDD_OUTPUT"
}

checkpoint_review() {
    local checkpoint=$1
    local prompt=$2
    
    echo ""
    print_header "CHECKPOINT $checkpoint: $prompt"
    echo ""
    echo -e "${YELLOW}Current TDD excerpt:${NC}"
    echo ""
    tail -n 30 "$TDD_OUTPUT"
    echo ""
    echo -e "${YELLOW}Review the generated content above.${NC}"
    echo ""
    
    read -p "$(echo -e ${CYAN}Enter any feedback/corrections (or press Enter to continue): ${NC})" feedback
    
    if [ -n "$feedback" ]; then
        echo ""
        echo "📝 Feedback noted: $feedback"
        echo ""
        echo "💡 Next steps:"
        echo "  1. Review the full TDD at: $TDD_OUTPUT"
        echo "  2. Update sections based on feedback"
        echo "  3. Re-run this script with --skip-confirmation to complete automation"
        echo ""
    fi
}

interactive_refinement() {
    print_header "Interactive TDD Refinement Process"
    
    echo ""
    echo "This process will guide you through key design decision points."
    echo "You can provide feedback at each checkpoint to refine the document."
    echo ""
    
    # Checkpoint 1: Architecture Review
    if confirm "Review architecture components and structure?"; then
        checkpoint_review "1" "Architecture Overview"
    fi
    
    # Checkpoint 2: Component Design
    if confirm "Review detailed component design?"; then
        checkpoint_review "2" "Component Specifications"
    fi
    
    # Checkpoint 3: Data Model
    if confirm "Review data model and schema?"; then
        checkpoint_review "3" "Data Model Design"
    fi
    
    # Checkpoint 4: API Specifications
    if confirm "Review API specifications?"; then
        checkpoint_review "4" "API Contracts"
    fi
    
    # Checkpoint 5: Security & Performance
    if confirm "Review security and performance considerations?"; then
        checkpoint_review "5" "Security & Scalability"
    fi
    
    # Checkpoint 6: Implementation Plan
    if confirm "Review implementation roadmap?"; then
        checkpoint_review "6" "Implementation Timeline"
    fi
}

generate_context_report() {
    local report_path="${OUTPUT_DIR}/CONTEXT_${FEATURE_NAME}_$(date +%Y%m%d_%H%M%S).md"
    cp "$CONTEXT_FILE" "$report_path"
    print_step "Context report saved: $report_path"
}

finalize_tdd() {
    print_header "Finalizing TDD Document"
    
    # Add metadata footer
    cat >> "$TDD_OUTPUT" << 'EOF'

---

## Document Metadata

**Generated By**: PRD-to-TDD Generator Script
**Template Version**: 1.0
**Last Updated**: $(date -u +%Y-%m-%dT%H:%M:%SZ)

### Review Checklist
- [ ] All PRD requirements are addressed
- [ ] Architecture aligns with existing patterns
- [ ] Component design is clear and implementable
- [ ] Data model is normalized and efficient
- [ ] API specifications are complete
- [ ] Security considerations are documented
- [ ] Performance targets are realistic
- [ ] Implementation timeline is achievable
- [ ] Risk assessment is comprehensive
- [ ] Team review and approval obtained

### Next Steps
1. Distribute TDD to team for review
2. Schedule architecture review meeting
3. Update ADRs (Architecture Decision Records) for major decisions
4. Create implementation tasks from roadmap
5. Establish monitoring and observability plan

---
EOF
    
    print_step "TDD document finalized"
}

display_summary() {
    print_header "Process Summary"
    
    echo ""
    echo -e "${GREEN}✓ PRD-to-TDD Generation Complete${NC}"
    echo ""
    echo "📄 Generated Documents:"
    echo "  - TDD: $TDD_OUTPUT"
    echo "  - Context Report: ${OUTPUT_DIR}/CONTEXT_${FEATURE_NAME}_*.md"
    echo ""
    echo "📊 Document Statistics:"
    echo "  - TDD Lines: $(wc -l < "$TDD_OUTPUT")"
    echo "  - PRD Lines: $(wc -l < "$PRD_FILE")"
    echo ""
    echo "🔍 Next Actions:"
    echo "  1. Review TDD at: $TDD_OUTPUT"
    echo "  2. Refine sections based on team feedback"
    echo "  3. Create GitHub issues for implementation tasks"
    echo "  4. Link to this document in ADRs and implementation plans"
    echo ""
    echo "📋 Checklist:"
    echo "  [ ] TDD reviewed by team"
    echo "  [ ] Architecture decisions approved"
    echo "  [ ] Implementation tasks created"
    echo "  [ ] Monitoring plan established"
    echo "  [ ] Security review completed"
    echo ""
}

cleanup() {
    # Clean up temporary files
    if [ -n "$CONTEXT_FILE" ] && [ -f "$CONTEXT_FILE" ]; then
        rm -f "$CONTEXT_FILE"
    fi
}

main() {
    print_header "PRD to Technical Design Document Generator"
    echo ""
    echo "This script transforms Product Requirements into comprehensive Technical Design Documents"
    echo "with interactive review checkpoints and repository context analysis."
    echo ""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --prd-file)
                PRD_FILE="$2"
                shift 2
                ;;
            --output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            --feature-name)
                FEATURE_NAME="$2"
                shift 2
                ;;
            --skip-confirmation)
                SKIP_CONFIRMATION=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Execute generation pipeline
    validate_prerequisites
    validate_prd_input
    extract_feature_name
    discover_repository_context
    display_context_summary
    create_output_directory
    generate_initial_tdd
    generate_context_report
    
    # Interactive refinement loop
    if [ "$SKIP_CONFIRMATION" = false ]; then
        interactive_refinement
    fi
    
    finalize_tdd
    display_summary
    cleanup
    
    echo -e "${GREEN}✓ Process completed successfully!${NC}"
    echo ""
}

trap cleanup EXIT
main "$@"
