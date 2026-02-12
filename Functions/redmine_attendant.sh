function tm_list_functions() {
    if command -v declare >/dev/null 2>&1; then
        declare -F 2>/dev/null | awk '{print $3}'
        return 0
    fi

    if command -v typeset >/dev/null 2>&1; then
        typeset -f 2>/dev/null | awk '/^[a-zA-Z_][a-zA-Z0-9_]* *\(\)/{print $1}'
        return 0
    fi
}

function tm_run() {
    local file="$1"
    local func="$2"
    local before after
    local tmp_before tmp_after

    if [[ -z "$TECNO_MINE_FILES" ]]; then
        print_error "TECNO_MINE_FILES não definido."
        return 1
    fi

    before=$(tm_list_functions)

    if [[ -f "$TECNO_MINE_FILES/$file" ]]; then
        source "$TECNO_MINE_FILES/$file"
    else
        print_error "Arquivo não encontrado: $file"
        return 1
    fi

    if ! declare -F "$func" >/dev/null; then
        print_error "Função não encontrada: $func"
        return 1
    fi

    "$func"

    after=$(tm_list_functions)
    tmp_before=$(mktemp)
    tmp_after=$(mktemp)

    printf "%s\n" $before | sort > "$tmp_before"
    printf "%s\n" $after | sort > "$tmp_after"

    comm -13 "$tmp_before" "$tmp_after" | while read -r fn; do
        unset -f "$fn"
    done

    rm -f "$tmp_before" "$tmp_after"
}

function tm_build_display_items() {
    local -a items=("$@")
    local -a display_items
    local i

    for ((i = 1; i <= ${#items}; i++)); do
        local label="${items[i]%%|*}"
        display_items+=("${i}) ${label}")
    done

    printf '%s\n' "${display_items[@]}"
}

function tm_fzf() {
    env -u FZF_DEFAULT_COMMAND \
        -u FZF_DEFAULT_OPTS \
        -u FZF_CTRL_T_COMMAND \
        -u FZF_ALT_C_COMMAND \
        -u FZF_TMUX \
        command fzf "$@"
}

function tm_fzf_select() {
    local list_label="$1"
    local branch="$2"
    shift 2
    local -a items=("$@")
    local display_lines
    local preview_cmd
    local seal_lines
    local min_height

    display_lines="$(tm_build_display_items "${items[@]}")"
    preview_cmd="zsh -lc 'source \"${TECNO_MINE_FILES}/Configs/redmine_visual.sh\"; print_mascot_seal'"
    seal_lines=$(print_mascot_seal | wc -l | tr -d ' ')
    min_height="${TM_MENU_MIN_HEIGHT:-$((seal_lines + 4))}"

    printf '%s\n' "$display_lines" \
        | tm_fzf --prompt="❯ Selecione uma opção: " \
            --height="${TM_MENU_HEIGHT:-60%}" \
            --min-height="$min_height" \
            --margin="${TM_MENU_MARGIN:-1,2}" \
            --layout=default \
            --no-sort \
            --tac \
            --border-label=" TecnoMine " \
            --border-label-pos=3  \
            --border=rounded \
            --list-label=" ${list_label} " \
            --list-label-pos=0 \
            --info=inline-right \
            --info-command="echo Branch atual: ${branch}" \
            --color="border:blue,label:blue:bold,prompt:blue:bold" \
            --pointer="▶" \
            --marker="✓" \
            --preview="$preview_cmd" \
            --preview-window="${TM_MENU_PREVIEW_POS:-left}:${TM_MENU_PREVIEW_SIZE:-40%}:${TM_MENU_PREVIEW_WRAP:-wrap}:noinfo" \
            --no-mouse
}

function tecnomine(){    
    local branch=$(git branch --show-current)

    if [[ -z "$branch" ]]; then
        print_error "Não foi possível verificar a branch atual."
        sleep 2
        tput reset
        return 1
    fi 

    local -A category_map
    category_map=(
        "Situação do Ticket" $'EM ANÁLISE/DEV e EM ANÁLISE|Functions/redmine_situations.sh|setTicketToAnalyzing\nEM ANÁLISE/DEV e EM DESENVOLVIMENTO|Functions/redmine_situations.sh|setTicketToDeveloping\nAGUARDANDO ANÁLISE/DEV e TEMPORARIAMENTE SUSPENSO (Outro Motivo)|Functions/redmine_situations.sh|setTicketToHalted\nAGUARDANDO ANÁLISE/DEV e AGUARDANDO ANÁLISE|Functions/redmine_situations.sh|setTicketToAwaitingAnalysis\nAGUARDANDO ANÁLISE/DEV e AGUARDANDO DESENVOLVIMENTO|Functions/redmine_situations.sh|setTicketToAwaitingDevelopment\nFEEDBACK e ANÁLISE CONCLUIDA|Functions/redmine_situations.sh|setTicketToFeedbackAndFinishedAnalysis\nDISPONÍVEL EM TESTE INTERNO e DESENVOLVIMENTO CONCLUIDO|Functions/redmine_situations.sh|setTicketToAvailableForTestAndFinishedDevelopment'
        "Checklist do Ticket" $'Adicionar Tarefa|Functions/redmine_checklists.sh|addTaskInChecklist\nVisualizar Tarefas|Functions/redmine_checklists.sh|seeChecklist'
        "Tempo Total Gasto no Ticket" $'Tempo em Análise|Functions/redmine_time.sh|getAnalyzingTicketTime\nTempo em Desenvolvimento|Functions/redmine_time.sh|getDevelopingTicketTime'
        "Tempo Restante Gasto no Ticket" $'Tempo Restante em Análise|Functions/redmine_time.sh|getRemainingAnalyzingTicketTime\nTempo Restante em Desenvolvimento|Functions/redmine_time.sh|getRemainingDevelopingTicketTime'
    )

    clear
    echo ""

    local -a categories
    categories=("${(@k)category_map}")
    local cat_selection
    cat_selection="$(tm_fzf_select "Menu Principal" "$branch" "${categories[@]}")"

    if [[ -z "$cat_selection" ]]; then
        print_error "Opção inválida! O programa será encerrado."
        sleep 1
        tput reset
        return 1
    fi

    local cat_index="${cat_selection%%)*}"
    local selected_category="${categories[$cat_index]}"
    local -a category_items
    category_items=("${(@f)category_map[$selected_category]}")

    local item_selection
    item_selection="$(tm_fzf_select "$selected_category" "$branch" "${category_items[@]}")"

    if [[ -z "$item_selection" ]]; then
        print_error "Opção inválida! O programa será encerrado."
        sleep 1
        tput reset
        return 1
    fi

    local item_index="${item_selection%%)*}"
    local selected_item="${category_items[$item_index]}"

    local selected_file
    local selected_func
    selected_file="$(echo "$selected_item" | awk -F'|' '{print $2}')"
    selected_func="$(echo "$selected_item" | awk -F'|' '{print $3}')"

    tm_run "$selected_file" "$selected_func"

    echo ""
    print_success "Operação concluída com sucesso! ${icon_celebrate}"
    echo ""
    
    return 0
}
