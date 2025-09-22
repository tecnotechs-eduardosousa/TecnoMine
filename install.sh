INSTALL_DIR="${HOME}"
TECNOMINE_REPO_URL="https://github.com/tecnotechs-eduardosousa/TecnoMine.git"

PROJECT_NAME="$(basename "$TECNOMINE_REPO_URL" .git)"

function findOperationalSystem() {
    echo "$(uname)"
}

function installDependencies() {
    OS=$(findOperationalSystem)

    if [[ "$OS" == "Darwin" ]]; then
        echo ""
        echo -e "${laranja}Sistema Operacional: 🍎 MacOS${reset}"
        echo ""

        if ! command -v brew &>/dev/null; then
            echo -e "${laranja}Instalando HomeBrew...${reset}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            export PATH="/opt/homebrew/bin:$PATH"
        fi

        echo ""
        echo -e "${laranja}Instalando figlet...${reset}"
        brew install figlet

        echo ""

        echo -e "${laranja}Instalando fuzzy-find...${reset}"
        brew install fzf

        echo ""

        echo -e "${laranja}Instalando toilet...${reset}"
        brew install toilet

        echo ""

        echo -e "${laranja}Instalando lolcat...${reset}"
        brew install lolcat
    elif [[ "$OS" == "Linux" ]]; then
        echo ""
        echo -e "${laranja}Sistema Operacional: 🐧 Linux${reset}"
        echo ""

        if command -v apt &>/dev/null || command -v apt-get &>/dev/null; then
            sudo apt update
            echo -e "${laranja}Instalando figlet...${reset}"
            sudo apt install -y figlet

            echo ""

            echo -e "${laranja}Instalando fuzzy-find...${reset}"
            sudo apt install fzf

            echo ""

            echo -e "${laranja}Instalando toilet...${reset}"
            sudo apt install toilet

            echo ""

            echo -e "${laranja}Instalando lolcat...${reset}"
            sudo apt install lolcat
        else 
        fi
    else 
        echo "${vermelho}Sistema não reconhecido: $OS${reset}"
        echo "${amarelo}Favor entre em contato para efetuar ajustes ou implementações para o seu sistema.${reset}"
        echo ""
        sleep 2 
        return 1
    fi
}

function installTecnoMine() {
    set -e
    setopt PIPEFAIL

    mkdir -p "$INSTALL_DIR"

    if [[ -d "$INSTALL_DIR/$PROJECT_NAME" ]]; then
        echo "${amarelo}TecnoMine já está instalado.${reset}"
        echo ""
        echo "O programa será encerrado."
        sleep 2
        tput reset
        return 1
    else
        echo -e "${laranja}Instalando $PROJECT_NAME para o seu sistema em $INSTALL_DIR...${reset}"
        echo ""
        git clone "$TECNOMINE_REPO_URL" "$INSTALL_DIR/$PROJECT_NAME"
        echo ""
        echo -e "${verde}TecnoMine foi instalado com sucesso!"
    fi

    installDependencies

    sleep 2
    tput reset
    echo "${laranja}Projeto instalado em: $INSTALL_DIR/$PROJECT_NAME${reset}"
    echo ""
    echo "${laranja}Para utilizar, crie e/ou acesse uma branch no formato 'ticket-12345' e digite 'tecnomine' no terminal.${reset}"
    return 0
}

function updateTecnoMine() {
    mkdir -p "$INSTALL_DIR"

    echo -e "${laranja}Atualizando $PROJECT_NAME...${reset}"
    echo ""
    git -C "$INSTALL_DIR/$PROJECT_NAME" pull
    echo ""
    echo -e "${verde}$PROJECT_NAME foi atualizado com sucesso!"

    sleep 2
    tput reset
    return 0
}