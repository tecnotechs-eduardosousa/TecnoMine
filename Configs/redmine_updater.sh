TECNOMINE_REPO_URL="https://github.com/tecnotechs-eduardosousa/TecnoMine.git"

PROJECT_NAME="$(basename "$TECNOMINE_REPO_URL" .git)"

PROJECT_INSTALLED_DIR="$HOME/$PROJECT_NAME"

ROUTINES_DIR="$PROJECT_INSTALLED_DIR/Routines"

DAILY_UPDATE_CHECKER_FILE="$ROUTINES_DIR/tecnomine_daily_update_checker.txt"

function dailyUpdateCheckerRoutine() {
    if [[ ! -d "$PROJECT_INSTALLED_DIR" ]]; then
        tput reset
        print_header "TECNOMINE ATTENDANT" 60 "${laranja}"
        print_error "O projeto não foi instalado neste sistema."
        echo ""
        print_info "Para instalar, execute: ${bold}installTecnoMine${reset}"
        echo ""
        sleep 2
        tput reset
        return 1
    fi

    mkdir -p "$ROUTINES_DIR"

    touch "$DAILY_UPDATE_CHECKER_FILE"

    TODAY_DATE=$(date +%F)

    DAILY_UPDATE_CHECKER_LOG="Efetuado Verificação de Atualizações na data: $TODAY_DATE"

    if [ "$(tail -n 1 "$DAILY_UPDATE_CHECKER_FILE")" = "$DAILY_UPDATE_CHECKER_LOG" ]; then
        tput reset 
        return 0
    fi  

    git -C "$PROJECT_INSTALLED_DIR" fetch origin main

    tput reset

    local LOCAL_MAIN=$(git -C "$PROJECT_INSTALLED_DIR" rev-parse main 2>/dev/null || echo "")
    local REMOTE_MAIN=$(git -C "$PROJECT_INSTALLED_DIR" rev-parse origin/main 2>/dev/null || echo "")

    if [ -z "$LOCAL_MAIN" ] || [ -z "$REMOTE_MAIN" ]; then
        tput reset
        echo "$DAILY_UPDATE_CHECKER_LOG" > "$DAILY_UPDATE_CHECKER_FILE"
        return 0
    fi

    if [ "$LOCAL_MAIN" = "$REMOTE_MAIN" ]; then
        tput reset
        echo "$DAILY_UPDATE_CHECKER_LOG" > "$DAILY_UPDATE_CHECKER_FILE"
        return 0
    fi

    print_box "🎉 Há atualizações disponíveis para o TecnoMine!" "${verde}"
    echo ""

    local USER_WILL_UPDATE
    print_prompt "Deseja atualizar agora? (S/n)"
    read -r USER_WILL_UPDATE
    echo ""

    if [[ "$USER_WILL_UPDATE" == [Ss] || "$USER_WILL_UPDATE" == "" ]]; then
        tput reset
        if updateTecnoMine; then
            echo "$DAILY_UPDATE_CHECKER_LOG" > "$DAILY_UPDATE_CHECKER_FILE"
        fi
    else    
        print_info "Atualização adiada. Você pode atualizar manualmente com ${bold}checkForTecnoMineUpdates${reset}"
        echo ""
        echo "$DAILY_UPDATE_CHECKER_LOG" > "$DAILY_UPDATE_CHECKER_FILE"
        sleep 1
        return 0
    fi
}

function checkForTecnoMineUpdates() {
    if [[ ! -d "$PROJECT_INSTALLED_DIR" ]]; then
        tput reset
        print_header "TECNOMINE ATTENDANT" 60 "${laranja}"
        print_error "O projeto não foi instalado neste sistema."
        echo ""
        print_info "Para instalar, execute: ${bold}installTecnoMine${reset}"
        echo ""
        sleep 2
        tput reset
        return 1
    fi

    print_header "VERIFICANDO ATUALIZAÇÕES" 60 "${azul}"
    show_loading "Buscando atualizações do repositório" 2
    
    git -C "$PROJECT_INSTALLED_DIR" fetch origin main >/dev/null 2>&1

    tput reset

    local LOCAL_MAIN=$(git -C "$PROJECT_INSTALLED_DIR" rev-parse main 2>/dev/null || echo "")
    local REMOTE_MAIN=$(git -C "$PROJECT_INSTALLED_DIR" rev-parse origin/main 2>/dev/null || echo "")

    if [ -z "$LOCAL_MAIN" ] || [ -z "$REMOTE_MAIN" ]; then
        print_header "TECNOMINE ATTENDANT" 60 "${laranja}"
        print_error "Não foi possível verificar atualizações."
        echo ""
        sleep 1
        return 1
    fi

    if [ "$LOCAL_MAIN" = "$REMOTE_MAIN" ]; then
        print_header "TECNOMINE ATTENDANT" 60 "${verde}"
        print_success "O TecnoMine já está na sua versão mais recente!"
        echo ""
        print_label "Versão Atual" "$(git -C "$PROJECT_INSTALLED_DIR" rev-parse --short HEAD)" "$cinza" "$verde"
        echo ""
        sleep 1
        return 0
    fi

    updateTecnoMine
}

function updateTecnoMine() {
    print_header "${icon_rocket} ATUALIZANDO TECNOMINE" 60 "${azul}"
    
    local CURRENT_BRANCH=$(git -C "$PROJECT_INSTALLED_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
    local OLD_VERSION=$(git -C "$PROJECT_INSTALLED_DIR" rev-parse --short HEAD 2>/dev/null || echo "unknown")
    
    if [[ -n "$(git -C "$PROJECT_INSTALLED_DIR" status --porcelain 2>/dev/null)" ]]; then
        print_info "Salvando alterações locais temporariamente..."
        git -C "$PROJECT_INSTALLED_DIR" stash push -m "Auto-stash before TecnoMine update" >/dev/null 2>&1
    fi
    
    print_info "Alternando para branch ${bold}main${reset}..."
    if ! git -C "$PROJECT_INSTALLED_DIR" checkout main >/dev/null 2>&1; then
        echo ""
        print_error "Não foi possível alternar para a branch main."
        sleep 2
        tput reset
        return 1
    fi
    
    echo ""
    show_loading "Baixando atualizações" 1
    
    if git -C "$PROJECT_INSTALLED_DIR" pull origin main >/dev/null 2>&1; then
        local NEW_VERSION=$(git -C "$PROJECT_INSTALLED_DIR" rev-parse --short HEAD)
        
        tput reset
        print_header "${icon_celebrate} ATUALIZAÇÃO CONCLUÍDA" 60 "${verde}"
        
        print_label "Versão Anterior" "$OLD_VERSION" "$cinza" "$amarelo"
        print_label "Nova Versão" "$NEW_VERSION" "$cinza" "$verde"
        echo ""
        
        print_success "$PROJECT_NAME foi atualizado com sucesso!"
        echo ""
        
        if [ -n "$CURRENT_BRANCH" ] && [ "$CURRENT_BRANCH" != "main" ]; then
            print_info "Retornando para branch ${bold}$CURRENT_BRANCH${reset}..."
            git -C "$PROJECT_INSTALLED_DIR" checkout "$CURRENT_BRANCH" >/dev/null 2>&1
            
            if git -C "$PROJECT_INSTALLED_DIR" stash list | grep -q "Auto-stash before TecnoMine update"; then
                git -C "$PROJECT_INSTALLED_DIR" stash pop >/dev/null 2>&1
            fi
        fi
        
        sleep 2
        tput reset
        return 0
    else
        tput reset
        print_header "${icon_error} ERRO NA ATUALIZAÇÃO" 60 "${vermelho}"
        print_error "Não foi possível baixar as atualizações do $PROJECT_NAME."
        echo ""
        print_warning "Verifique sua conexão com a internet e tente novamente."
        echo ""
        
        if [ -n "$CURRENT_BRANCH" ] && [ "$CURRENT_BRANCH" != "main" ]; then
            git -C "$PROJECT_INSTALLED_DIR" checkout "$CURRENT_BRANCH" >/dev/null 2>&1
        fi
        
        sleep 2
        tput reset
        return 1
    fi
}

dailyUpdateCheckerRoutine