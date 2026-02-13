#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# TecnoMine - Color & Visual Configuration
# ═══════════════════════════════════════════════════════════════

# ANSI Color Codes (256-color support)
export vermelho='\033[38;5;196m'      # Bright Red - Errors
export verde='\033[38;5;46m'          # Bright Green - Success
export azul='\033[38;5;39m'           # Bright Blue - Info
export amarelo='\033[38;5;226m'       # Bright Yellow - Warnings
export laranja='\033[38;5;214m'       # Orange - Prompts/Attendant
export roxo='\033[38;5;135m'          # Purple - Details
export rosa='\033[38;5;213m'          # Pink - Headers
export magenta='\033[38;5;201m'       # Magenta - Questions
export ciano='\033[38;5;51m'          # Cyan - Highlights
export cinza='\033[38;5;246m'         # Gray - Secondary text
export branco='\033[38;5;231m'        # White - Primary text
export reset='\033[0m'                # Reset all formatting

# Text Styles
export bold='\033[1m'
export dim='\033[2m'
export italic='\033[3m'
export underline='\033[4m'
export blink='\033[5m'
export reverse='\033[7m'

# Background Colors
export bg_verde='\033[48;5;46m'
export bg_vermelho='\033[48;5;196m'
export bg_azul='\033[48;5;39m'
export bg_cinza='\033[48;5;240m'

# Status Colors (Semantic)
export color_success="${verde}"
export color_error="${vermelho}"
export color_warning="${amarelo}"
export color_info="${azul}"
export color_prompt="${magenta}"

# Icons (Unicode symbols)
export icon_success="✓"
export icon_error="✗"
export icon_warning="⚠"
export icon_info="ℹ"
export icon_question="?"
export icon_arrow="→"
export icon_bullet="•"
export icon_check="☑"
export icon_uncheck="☐"
export icon_clock="⏱"
export icon_rocket="🚀"
export icon_thinking="🤔"
export icon_celebrate="🎉"

# Box Drawing Characters
export box_tl="╔"
export box_tr="╗"
export box_bl="╚"
export box_br="╝"
export box_h="═"
export box_v="║"
export box_ml="╠"
export box_mr="╣"

# Visual Functions
function print_header() {
    local text="$1"
    local width=${2:-60}
    local color="${3:-$ciano}"
    
    echo -e "\n${color}${box_tl}$(printf "${box_h}%.0s" $(seq 1 $((width-2))))${box_tr}"
    printf "${box_v} %-$((width-4))s ${box_v}\n" "$text"
    echo -e "${box_bl}$(printf "${box_h}%.0s" $(seq 1 $((width-2))))${box_br}${reset}\n"
}

function print_separator() {
    local width=${1:-60}
    local color="${2:-$cinza}"
    echo -e "${color}$(printf "─%.0s" $(seq 1 $width))${reset}"
}

function print_success() {
    echo -e "${verde}${icon_success}${reset} ${bold}$1${reset}"
}

function print_error() {
    echo -e "${vermelho}${icon_error} ERRO:${reset} $1"
}

function print_warning() {
    echo -e "${amarelo}${icon_warning} AVISO:${reset} $1"
}

function print_info() {
    echo -e "${azul}${icon_info}${reset} $1"
}

function print_prompt() {
    echo -ne "${magenta}${icon_question}${reset} $1 "
}

function print_label() {
    local label="$1"
    local value="$2"
    local label_color="${3:-$cinza}"
    local value_color="${4:-$branco}"
    
    printf "${label_color}%-25s${reset} ${value_color}%s${reset}\n" "$label:" "$value"
}

function print_status_badge() {
    local status="$1"
    local color
    
    case "${status,,}" in
        *"análise"*|*"analyzing"*)
            color="${azul}${bg_azul}"
            ;;
        *"desenvolvimento"*|*"developing"*)
            color="${amarelo}${bg_amarelo}"
            ;;
        *"conclu"*|*"done"*|*"finished"*)
            color="${verde}${bg_verde}"
            ;;
        *"aguardando"*|*"waiting"*)
            color="${laranja}${bg_laranja}"
            ;;
        *"suspen"*|*"halted"*)
            color="${vermelho}${bg_vermelho}"
            ;;
        *)
            color="${cinza}${bg_cinza}"
            ;;
    esac
    
    echo -e "${color} ${status} ${reset}"
}

function show_loading() {
    local message="$1"
    local duration="${2:-2}"
    
    echo -ne "${azul}${message}${reset} "
    
    for i in $(seq 1 $duration); do
        for spinner in '⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏'; do
            echo -ne "\b${spinner}"
            sleep 0.1
        done
    done
    echo -e "\b${icon_success}"
}

function print_box() {
    local text="$1"
    local color="${2:-$azul}"
    local padding=2
    
    # Calculate box width
    local text_length=${#text}
    local box_width=$((text_length + padding * 2 + 2))
    
    # Top border
    echo -e "${color}${box_tl}$(printf "${box_h}%.0s" $(seq 1 $((box_width-2))))${box_tr}${reset}"
    
    # Content
    printf "${color}${box_v}${reset} %s ${color}${box_v}${reset}\n" "$text"
    
    # Bottom border
    echo -e "${color}${box_bl}$(printf "${box_h}%.0s" $(seq 1 $((box_width-2))))${box_br}${reset}"
}

function print_progress_bar() {
    local current=$1
    local total=$2
    local width=${3:-40}
    
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    
    printf "\r[${verde}"
    printf "%${filled}s" | tr ' ' '█'
    printf "${cinza}"
    printf "%${empty}s" | tr ' ' '░'
    printf "${reset}] ${bold}%3d%%${reset}" $percentage
}

# Checklist formatting
function format_checklist_item() {
    local id="$1"
    local subject="$2"
    local is_done="$3"
    
    if [[ "$is_done" == "true" || "$is_done" == "1" ]]; then
        echo -e "  ${verde}${icon_check}${reset} ${dim}${subject}${reset} ${cinza}(#${id})${reset}"
    else
        echo -e "  ${cinza}${icon_uncheck}${reset} ${branco}${subject}${reset} ${cinza}(#${id})${reset}"
    fi
}

# Time formatting
function format_time_duration() {
    local hours="$1"
    
    if [[ -z "$hours" ]]; then
        echo -e "${bold}0m${reset}"
        return
    fi
    
    if [[ "$hours" == .* ]]; then
        hours="0$hours"
    fi
    
    if ! [[ "$hours" =~ ^-?[0-9]*\.?[0-9]+$ ]]; then
        echo -e "${bold}0m${reset}"
        return
    fi
    
    if [[ $(echo "$hours < 0" | bc 2>/dev/null) -eq 1 ]]; then
        echo -e "${bold}0m${reset}"
        return
    fi
    
    local h=$(echo "$hours" | cut -d'.' -f1)
    [[ -z "$h" || "$h" == "-" ]] && h=0
    
    local m=$(echo "scale=0; ($hours - $h) * 60 / 1" | bc 2>/dev/null)
    
    if [[ -z "$m" ]] || ! [[ "$m" =~ ^[0-9]+$ ]]; then
        m=0
    fi
    
    if [[ $h -gt 0 ]]; then
        echo -e "${bold}${h}h ${m}m${reset}"
    else
        echo -e "${bold}${m}m${reset}"
    fi
}

# Ticket summary card
function print_ticket_summary() {
    local ticket_num="$1"
    local status="$2"
    local dev_status="$3"
    
    print_header "TICKET #${ticket_num}" 70 "${ciano}"
    print_label "Status Principal" "$status" "$cinza" "$azul"
    print_label "Status Desenvolvimento" "$dev_status" "$cinza" "$verde"
    print_separator 70
}

function print_mascot_fox() {
    echo -e "${vermelho}
⠀⠀⠀⠀⠀⠀⠀⢀⣴⠀⢀⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⣴⣿⣣⣴⠟⢹⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢀⣿⣤⣾⣿⢟⣠⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⢀⣴⣿⡁⣿⠋⡴⠿⢋⣼⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⢸⣿⡿⠷⣭⣶⣿⣷⢨⣿⣿⣿⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⣸⣯⡞⣰⢟⠻⢿⡟⢀⣿⣿⣿⣿⣿⡁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢀⣼⢟⣠⢞⡥⠾⣷⡔⣦⣼⣿⡏⣹⣿⡏⠃⠀⠀⠀⠀⠀⢀⣀⣀⣤⣤⣤⣄⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠿⠷⠭⠀⠉⠀⠀⣽⡇⣼⣿⡿⠁⣼⠟⠇⢀⣀⣠⠤⠞⠛⣛⡛⠛⣿⣿⠿⠿⠿⠿⠷⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣼⡿⢱⣿⠟⣡⣴⣾⣿⣇⠀⢀⣠⣶⣿⣿⣿⣿⠒⠋⠐⠶⣿⣿⣷⣶⣤⣈⠙⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣼⣿⠁⣿⢣⣾⣿⡿⠛⠉⠙⣴⣿⠟⡋⠁⢀⣾⠟⠀⣀⣄⡴⠟⣋⣭⣭⣍⠛⠳⠀⢮⡹⣶⣤⣀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠸⢻⣧⠀⠃⣿⣿⣿⣇⣠⠖⣼⡿⢡⡞⢁⣴⡿⢋⣤⣾⠿⠿⢀⣾⡿⠋⠉⣿⢀⣾⠀⡄⢻⣾⣿⣿⣷⣦⡀⠀⠀⠀
⠀⠀⠀⠀⠀⠸⣿⣧⠀⢿⣿⣿⣿⢁⠀⣿⣧⡘⠛⢋⣡⣴⡿⠋⠀⣰⢂⣾⡟⠀⣴⣴⢟⣼⡟⢠⣿⡄⢻⣿⣿⣿⣿⡷⡄⠀⠀
⠀⠀⠀⠀⠀⠀⠙⠻⠧⠌⢿⣿⣿⠈⣦⠻⣿⣿⣿⣿⡿⠏⠀⠀⣰⣇⠸⣿⡇⠀⠛⢁⡾⠃⠀⢸⣿⣧⠘⣏⠻⣿⣿⣇⡀⠀⠀
⠀⠀⠀⠀⠀⠀⢀⣤⣿⣷⢆⣿⣿⢂⣿⡇⠀⠈⠉⠁⠀⠀⠀⢰⣿⣿⣄⠻⢿⣦⡀⠸⣇⠀⠀⠘⣿⣿⣷⣌⣷⣌⠙⡿⢹⡄⠀
⠀⠀⠀⣠⣤⣶⡿⠿⠛⣡⣾⢟⣵⠟⠁⠁⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⠓⠀⠉⠛⢦⡙⢧⡀⠀⠹⣿⠻⣿⣿⣿⢧⠀⢸⣿⠀
⠀⠀⢠⣿⠏⠀⠀⣠⣾⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⣷⣄⠀⠀⠀⢻⣾⡿⠀⠀⠈⠂⠀⠻⣿⡇⣧⣾⣿⠇
⠀⣠⣿⣿⠀⠀⢾⣿⡁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⡿⠋⠁⠀⠀⣠⣾⠟⠁⠀⠀⠀⠀⠀⠰⡌⣇⣼⣿⠟⠀
⠀⠻⣿⡃⠀⠀⢸⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣾⡿⠋⠀⠀⠀⣠⣾⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⡇⣠⣿⠏⠀⠀
⠀⠀⠀⠀⠀⠀⢸⣿⣿⡂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡿⠋⠀⠀⠀⢰⣾⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⠿⠋⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠴⠾⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    ${reset}"
}