#!/usr/bin/env bash
# ============================================================
#  AI Mind Migrate — Cross-Platform AI Coding Assistant
#  Context / Rules / Memory Migration Tool
# ============================================================
#  Usage:
#    bash migrate.sh detect            — Scan for AI memory files
#    bash migrate.sh migrate <target>  — Migrate to target platform
#    bash migrate.sh export-canonical  — Export canonical YAML
#    bash migrate.sh list              — List supported platforms
# ============================================================

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# ── Supported Platforms ─────────────────────────────────────
declare -A PLATFORM_FILES=(
  ["claude-code"]="CLAUDE.md .claude/CLAUDE.md CLAUDE.local.md"
  ["codex"]="AGENTS.md AGENTS.override.md"
  ["copilot"]=".github/copilot-instructions.md"
  ["cursor"]="AGENTS.md"
  ["windsurf"]=".windsurfrules"
  ["gemini"]="GEMINI.md"
  ["aider"]="CONVENTIONS.md"
  ["cline"]=".clinerules"
  ["roo"]=".roorules"
  ["workbuddy"]=".workbuddy/memory/MEMORY.md"
  ["codebuddy"]="CODEBUDDY.md .codebuddy/CODEBUDDY.md"
  ["trae"]=".trae/rules/project_rules.md"
  ["lingma"]=".lingma/rules/*.md"
  ["augment"]=".augment-guidelines"
  ["qcode"]="AGENTS.md"
)

declare -A PLATFORM_DIRS=(
  ["claude-code"]=".claude/rules"
  ["copilot"]=".github/instructions"
  ["cursor"]=".cursor/rules"
  ["windsurf"]=".windsurf/rules"
  ["cline"]=".clinerules"
  ["roo"]=".roo/rules"
  ["codebuddy"]=".codebuddy/rules"
  ["trae"]=".trae/rules"
  ["lingma"]=".lingma/rules"
  ["augment"]=".augment/rules"
)

declare -A PLATFORM_NAMES=(
  ["claude-code"]="Claude Code"
  ["codex"]="OpenAI Codex"
  ["copilot"]="GitHub Copilot"
  ["cursor"]="Cursor"
  ["windsurf"]="Windsurf"
  ["gemini"]="Gemini CLI"
  ["aider"]="Aider"
  ["cline"]="Cline"
  ["roo"]="Roo Code"
  ["workbuddy"]="WorkBuddy"
  ["codebuddy"]="CodeBuddy"
  ["trae"]="Trae"
  ["lingma"]="TONGYI Lingma"
  ["augment"]="Augment Code"
  ["qcode"]="Qoder/QCode"
)

# ── Helper Functions ────────────────────────────────────────
info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*"; }
header(){ echo -e "\n${BOLD}${CYAN}$*${NC}\n"; }

# ── Detect Command ──────────────────────────────────────────
cmd_detect() {
  header "🔍 Scanning for AI Coding Assistant Memory Files"
  
  local found_any=false
  local found_platforms=()
  
  for platform in "${!PLATFORM_FILES[@]}"; do
    local name="${PLATFORM_NAMES[$platform]}"
    local files="${PLATFORM_FILES[$platform]}"
    local dir="${PLATFORM_DIRS[$platform]:-}"
    
    local found_files=()
    
    # Check primary files
    for pattern in $files; do
      # Handle glob patterns
      if [[ "$pattern" == *"*"* ]]; then
        for f in $pattern; do
          if [[ -f "$f" ]]; then
            found_files+=("$f")
          fi
        done
      else
        if [[ -f "$pattern" ]]; then
          found_files+=("$pattern")
        fi
      fi
    done
    
    # Check rules directories
    if [[ -n "$dir" ]] && [[ -d "$dir" ]]; then
      while IFS= read -r -d '' f; do
        found_files+=("$f")
      done < <(find "$dir" -name "*.md" -o -name "*.mdc" -o -name "*.txt" -print0 2>/dev/null)
    fi
    
    if [[ ${#found_files[@]} -gt 0 ]]; then
      ok "$name detected:"
      for f in "${found_files[@]}"; do
        local lines=0 chars=0
        if [[ -f "$f" ]]; then
          lines=$(wc -l < "$f" 2>/dev/null || echo 0)
          chars=$(wc -c < "$f" 2>/dev/null || echo 0)
        fi
        echo -e "  ${CYAN}$f${NC} (${lines} lines, ${chars} bytes)"
      done
      found_any=true
      found_platforms+=("$platform")
    fi
  done
  
  # Also check for extra files that don't match PLATFORM_FILES exactly
  local extra_files=()
  if [[ -f ".cursor/rules" ]]; then extra_files+=(".cursor/rules")
  elif [[ -d ".cursor/rules" ]]; then
    while IFS= read -r -d '' f; do
      extra_files+=("$f")
    done < <(find ".cursor/rules" -name "*.mdc" -o -name "*.md" -print0 2>/dev/null)
  fi
  
  # Check for Roo Code mode-specific directories
  if [[ -d ".roo" ]]; then
    for d in .roo/rules-*/; do
      if [[ -d "$d" ]]; then
        while IFS= read -r -d '' f; do
          extra_files+=("$f")
        done < <(find "$d" -name "*.md" -o -name "*.txt" -print0 2>/dev/null)
      fi
    done
  fi
  
  for f in "${extra_files[@]}"; do
    if [[ ! -f "$f" ]]; then continue; fi
    local lines=$(wc -l < "$f" 2>/dev/null || echo 0)
    local chars=$(wc -c < "$f" 2>/dev/null || echo 0)
    echo -e "  ${YELLOW}(extra)${NC} ${CYAN}$f${NC} (${lines} lines, ${chars} bytes)"
    found_any=true
  done
  
  if [[ "$found_any" == false ]]; then
    warn "No AI coding assistant memory files detected in this project."
    info "You can create a canonical format manually or let the AI analyze your project."
    return 1
  fi
  
  echo ""
  info "Detected platforms: ${found_platforms[*]}"
  echo "${found_platforms[*]}"
}

# ── List Command ────────────────────────────────────────────
cmd_list() {
  header "📋 Supported Platforms"
  
  printf "  %-15s %-25s %-30s\n" "Platform ID" "Name" "Primary File(s)"
  printf "  %-15s %-25s %-30s\n" "───────────" "────" "──────────────"
  
  for platform in claude-code codex copilot cursor windsurf gemini aider cline roo workbuddy codebuddy trae lingma augment qcode; do
    local name="${PLATFORM_NAMES[$platform]}"
    local files="${PLATFORM_FILES[$platform]}"
    # Show first file only for readability
    local first_file="${files%% *}"
    printf "  %-15s %-25s %-30s\n" "$platform" "$name" "$first_file"
  done
  
  echo ""
  info "Usage: bash migrate.sh migrate <platform-id>"
}

# ── Parse Source Files into Canonical JSON ──────────────────
parse_to_canonical() {
  local output_file="$1"
  
  info "Parsing detected files into canonical format..."
  
  # This is a simplified parser - the full parsing logic
  # is handled by the AI agent using the SKILL.md spec
  # Here we collect raw content for the AI to process
  
  echo '{' > "$output_file"
  echo '  "sources": [' >> "$output_file"
  
  local first=true
  for platform in "${!PLATFORM_FILES[@]}"; do
    local files="${PLATFORM_FILES[$platform]}"
    local dir="${PLATFORM_DIRS[$platform]:-}"
    
    for pattern in $files; do
      if [[ "$pattern" == *"*"* ]]; then
        for f in $pattern; do
          if [[ -f "$f" ]]; then
            add_source_entry "$output_file" "$f" "$platform" "$first"
            first=false
          fi
        done
      else
        if [[ -f "$pattern" ]]; then
          add_source_entry "$output_file" "$pattern" "$platform" "$first"
          first=false
        fi
      fi
    done
    
    if [[ -n "$dir" ]] && [[ -d "$dir" ]]; then
      while IFS= read -r -d '' f; do
        add_source_entry "$output_file" "$f" "$platform" "$first"
        first=false
      done < <(find "$dir" -name "*.md" -o -name "*.mdc" -o -name "*.txt" -print0 2>/dev/null)
    fi
  done
  
  echo '  ]' >> "$output_file"
  echo '}' >> "$output_file"
  
  ok "Canonical data collected in $output_file"
}

add_source_entry() {
  local output_file="$1"
  local filepath="$2"
  local platform="$3"
  local first="$4"
  
  if [[ "$first" != true ]]; then
    echo '    ,' >> "$output_file"
  fi
  
  local content
  content=$(cat "$filepath" 2>/dev/null | head -c 50000 || echo "")
  local escaped_content
  escaped_content=$(echo "$content" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))' 2>/dev/null || echo '""')
  
  echo -n "    {\"file\": \"$filepath\", \"platform\": \"$platform\", \"content\": $escaped_content}" >> "$output_file"
}

# ── Export Canonical Command ────────────────────────────────
cmd_export_canonical() {
  header "📦 Exporting Canonical Format"
  
  mkdir -p .ai-mind-migrate
  parse_to_canonical ".ai-mind-migrate/canonical.json"
  
  ok "Canonical format exported to .ai-mind-migrate/canonical.json"
  info "You can review and edit this file before migration."
}

# ── Migrate Command ─────────────────────────────────────────
cmd_migrate() {
  local target="${1:-}"
  
  if [[ -z "$target" ]]; then
    err "Please specify a target platform."
    info "Usage: bash migrate.sh migrate <platform-id>"
    info "Run 'bash migrate.sh list' to see available platforms."
    return 1
  fi
  
  # Validate target
  if [[ -z "${PLATFORM_NAMES[$target]:-}" ]]; then
    err "Unknown platform: $target"
    info "Run 'bash migrate.sh list' to see available platforms."
    return 1
  fi
  
  header "🚀 Migrating to ${PLATFORM_NAMES[$target]}"
  
  # Step 1: Collect source content
  mkdir -p .ai-mind-migrate
  parse_to_canonical ".ai-mind-migrate/canonical.json"
  
  # Step 2: The AI agent will handle the actual conversion
  # This script sets up the infrastructure; the AI follows SKILL.md rules
  info "Source content collected. The AI agent will now:"
  info "  1. Parse source files into canonical format"
  info "  2. Generate ${PLATFORM_NAMES[$target]}-specific files"
  info "  3. Place them in the correct directory structure"
  info ""
  info "Target platform: ${PLATFORM_NAMES[$target]}"
  info "Primary file: ${PLATFORM_FILES[$target]%% *}"
  if [[ -n "${PLATFORM_DIRS[$target]:-}" ]]; then
    info "Rules directory: ${PLATFORM_DIRS[$target]}"
  fi
  
  # Create target directories
  local main_file="${PLATFORM_FILES[$target]%% *}"
  local main_dir
  main_dir=$(dirname "$main_file")
  if [[ "$main_dir" != "." ]] && [[ "$main_dir" != "$main_file" ]]; then
    mkdir -p "$main_dir"
  fi
  
  local rules_dir="${PLATFORM_DIRS[$target]:-}"
  if [[ -n "$rules_dir" ]]; then
    mkdir -p "$rules_dir"
  fi
  
  ok "Directory structure prepared for ${PLATFORM_NAMES[$target]}"
}

# ── Main Entry Point ────────────────────────────────────────
main() {
  local command="${1:-help}"
  
  case "$command" in
    detect|scan)
      cmd_detect
      ;;
    list|platforms)
      cmd_list
      ;;
    export-canonical|export)
      cmd_export_canonical
      ;;
    migrate|convert)
      cmd_migrate "${2:-}"
      ;;
    help|--help|-h)
      header "AI Mind Migrate — Cross-Platform AI Context Migration"
      echo "Usage:"
      echo "  bash migrate.sh detect              Scan for AI memory files"
      echo "  bash migrate.sh list                List supported platforms"
      echo "  bash migrate.sh export-canonical    Export canonical format"
      echo "  bash migrate.sh migrate <target>    Migrate to target platform"
      echo ""
      echo "Examples:"
      echo "  bash migrate.sh detect"
      echo "  bash migrate.sh migrate cursor"
      echo "  bash migrate.sh migrate claude-code"
      echo "  bash migrate.sh migrate workbuddy"
      ;;
    *)
      err "Unknown command: $command"
      info "Run 'bash migrate.sh help' for usage."
      return 1
      ;;
  esac
}

main "$@"
