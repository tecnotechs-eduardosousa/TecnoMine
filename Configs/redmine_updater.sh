TECNOMINE_REPO_URL="https://github.com/tecnotechs-eduardosousa/TecnoMine.git"

PROJECT_NAME="$(basename "$TECNOMINE_REPO_URL" .git)"

PROJECT_INSTALLED_DIR="$HOME/$PROJECT_NAME"

ROUTINES_DIR="$PROJECT_INSTALLED_DIR/Routines"

DAILY_UPDATE_CHECKER_FILE="$ROUTINES_DIR/tecnomine_daily_update_checker.txt"

function dailyUpdateCheckerRoutine() {
    if [[ ! -d "$PROJECT_INSTALLED_DIR" ]]; then
        tput reset
        echo -e "${laranja}TecnoMine Attendant:${reset}"
        echo ""
        echo -e "${vermelho}ERRO: O projeto não foi instalado neste sistema.${reset}"
        echo ""
        echo -e "${laranja}Caso deseje instalar, execute o seguinte comando: 'installTecnoMine'.${reset}"
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

    git -C "$PROJECT_INSTALLED_DIR" checkout main

    git -C "$PROJECT_INSTALLED_DIR" fetch origin main

    tput reset

    local TECNOMINE_HAS_NEW_UPDATES=$(git -C "$PROJECT_INSTALLED_DIR" rev-list --count HEAD..origin/main)

    if [ "$TECNOMINE_HAS_NEW_UPDATES" = 0 ]; then
        tput reset
        echo "$DAILY_UPDATE_CHECKER_LOG" > "$DAILY_UPDATE_CHECKER_FILE"
        return 0
    fi

    echo -e "${laranja}Há atualizações disponíveis para o TecnoMine.${reset}"
    echo ""

    local USER_WILL_UPDATE
    echo -ne "${laranja}Deseja atualizar? (S/n)${reset}"
    read -k 1 USER_WILL_UPDATE
    echo ""

    if [[ "$USER_WILL_UPDATE" == [Ss] ]]; then
        tput reset
        updateTecnoMine
        echo "$DAILY_UPDATE_CHECKER_LOG" > "$DAILY_UPDATE_CHECKER_FILE"
    else    
        return 0
    fi
}

function checkForTecnoMineUpdates() {
    if [[ ! -d "$PROJECT_INSTALLED_DIR" ]]; then
        tput reset
        echo -e "${laranja}TecnoMine Attendant:${reset}"
        echo ""
        echo -e "${vermelho}ERRO: O projeto não foi instalado neste sistema.${reset}"
        echo ""
        echo -e "${laranja}Caso deseje instalar, execute o seguinte comando: 'installTecnoMine'.${reset}"
        echo ""
        sleep 2
        tput reset
        return 1
    fi

    git -C "$PROJECT_INSTALLED_DIR" checkout main

    git -C "$PROJECT_INSTALLED_DIR" fetch origin main

    tput reset

    local TECNOMINE_HAS_NEW_UPDATES=$(git -C "$PROJECT_INSTALLED_DIR" rev-list --count HEAD..origin/main)

    if [ "$TECNOMINE_HAS_NEW_UPDATES" = 0 ]; then
        echo -e "${laranja}TecnoMine Attendant:${reset}"
        echo ""
        echo -e "O TecnoMine já está na sua versão mais recente."
        echo ""
        sleep 1
        return 0
    fi

    updateTecnoMine
}

function updateTecnoMine() {
    echo -e "${laranja}TecnoMine Attendant:${reset}"
    echo ""
    echo -e "${laranja}Atualizando $PROJECT_NAME...${reset}"
    echo ""

    git -C "$PROJECT_INSTALLED_DIR" pull origin main

    echo ""
    echo -e "${verde}$PROJECT_NAME foi atualizado com sucesso!"

    sleep 2
    tput reset
    return 0
}

dailyUpdateCheckerRoutine