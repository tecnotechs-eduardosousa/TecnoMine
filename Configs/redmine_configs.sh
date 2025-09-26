function getTicketNumber() {
    local CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    if [[ -z "$CURRENT_BRANCH" ]]; then 
        echo -e "${vermelho}ERRO: Não foi possível verificar a branch atual. ${reset}"
        sleep 2
        return 1
    fi

    if [[ ! "$CURRENT_BRANCH" =~ ticket-[0-9]+ ]]; then
        echo -e "${vermelho}ERRO: A branch atual não é de um Ticket. ${reset}"
        echo -e "${amarelo}AVISO: É necessário que a branch selecionada esteja no padrão 'ticket-12345' ${reset}"
        sleep 2
        return 1
    fi

    local TICKET_NUMBER=$(echo "$CURRENT_BRANCH" | grep -oP '(?<=ticket-)[0-9]+')

    if [[ -z "$TICKET_NUMBER" ]]; then 
        echo -e "${vermelho}ERRO: Não foi possível verificar o número do ticket. ${reset}"
        sleep 2
        return 1
    fi

    echo "$TICKET_NUMBER"
}



function getIssueData() {
    local API_RESPONSE=$(callRedmineAPI)

    if [[ -z "$API_RESPONSE" ]]; then
        echo -e "${vermelho}ERRO: Não há nenhuma resposta da API.${reset}"
        sleep 2
        return 1
    fi

    local ISSUE=$(echo "$API_RESPONSE" | jq '.issue | del(.journals)' )

    if [[ -z "$ISSUE" ]]; then
        echo -e "${vermelho}ERRO: Não foi possível achar as informações deste Ticket. ${reset}"
        sleep 2
        return 1
    fi

    echo "$ISSUE"
}

function getJournalsData() {
    local API_RESPONSE=$(callRedmineAPI)

    if [[ -z "$API_RESPONSE" ]]; then
        echo -e "${vermelho}ERRO: Não há nenhuma resposta da API.${reset}"
        sleep 2
        return 1
    fi

    local JOURNALS=$(echo "$API_RESPONSE" | jq '.issue.journals')

    if [[ -z "$JOURNALS" ]]; then
        echo -e "${vermelho}ERRO: Não foi possível achar as informações deste Ticket. ${reset}"
        sleep 2
        return 1
    fi

    echo "$JOURNALS"
}

function getMajorAnalyzingDevelopingStatusId() {
    local RESPONSE=$(curl -s -H "X-Redmine-API-Key: $REDMINE_API_KEY" "$ALL_REDMINE_STATUSES")

    if [[ -z "$RESPONSE" ]]; then
        echo -e "${vermelho}ERRO: Não foi possível encontrar as situações do Ticket via RedMine. ${reset}"
        sleep 2
        return 1
    fi

    local SANITIZED_RESPONSE=$(sanitizeResponseFromASCII "$RESPONSE")

    local STATUS_NAME="EM ANÁLISE / DEV."

    local STATUS_ID=$(echo "$SANITIZED_RESPONSE" | jq -r --arg name "$STATUS_NAME" '.issue_statuses[] | select(.name==$name) | .id')

    echo "$STATUS_ID"
}

function getMajorAwaitingAnalysisDevelopmentStatusId() {
    local RESPONSE=$(curl -s -H "X-Redmine-API-Key: $REDMINE_API_KEY" "$ALL_REDMINE_STATUSES")

    if [[ -z "$RESPONSE" ]]; then
        echo -e "${vermelho}ERRO: Não foi possível encontrar as situações do Ticket via RedMine. ${reset}"
        sleep 2
        return 1
    fi

    local SANITIZED_RESPONSE=$(sanitizeResponseFromASCII "$RESPONSE")

    local STATUS_NAME="AGUARDANDO ANÁLISE / DEV."

    local STATUS_ID=$(echo "$SANITIZED_RESPONSE" | jq -r --arg name "$STATUS_NAME" '.issue_statuses[] | select(.name==$name) | .id')

    echo "$STATUS_ID"
}

function getMajorAvailableForInternalTesting() {
    local RESPONSE=$(curl -s -H "X-Redmine-API-Key: $REDMINE_API_KEY" "$ALL_REDMINE_STATUSES")

    if [[ -z "$RESPONSE" ]]; then
        echo -e "${vermelho}ERRO: Não foi possível encontrar as situações do Ticket via RedMine. ${reset}"
        sleep 2
        return 1
    fi

    local SANITIZED_RESPONSE=$(sanitizeResponseFromASCII "$RESPONSE")

    local STATUS_NAME="DISPONÍVEL EM TESTE INTERNO"

    local STATUS_ID=$(echo "$SANITIZED_RESPONSE" | jq -r --arg name "$STATUS_NAME" '.issue_statuses[] | select(.name==$name) | .id')

    echo "$STATUS_ID"
}


function getSecondaryAnalyzingStatusName() {
    local STATUS_NAME="EM ANÁLISE"

    echo "$STATUS_NAME"
}

function getSecondaryAwaitingAnalysisStatusName() {
    local STATUS_NAME="AGUARDANDO ANÁLISE"

    echo "$STATUS_NAME"
}

function getSecondaryDevelopingStatusName() {
    local STATUS_NAME="EM DESENVOLVIMENTO"

    echo "$STATUS_NAME"
}

function getSecondaryAwaitingDevelopmentStatusName() {
    local STATUS_NAME="AGUARDANDO DESENVOLVIMENTO"

    echo "$STATUS_NAME"
}

function getSecondaryFinishedDevelopment() {
    local STATUS_NAME="DESENVOLVIMENTO CONCLUÍDO"

    echo "$STATUS_NAME"
}

function getSecondaryHaltedStatusName() {
    local HALTED_NAME="TEMPORARIAMENTE SUSPENSO (Outro Motivo)"

    echo "$HALTED_NAME"
}


function getCustomFieldStatusDevelopmentId() {
    local CUSTOM_FIELD_STATUS_DEVELOPMENT_ID="4"

    echo "$CUSTOM_FIELD_STATUS_DEVELOPMENT_ID"
}

function getAnalysisActivityId() {
    local ANALYSIS_ACTIVITY_ID="10"

    echo "$ANALYSIS_ACTIVITY_ID"
}

function getDevelopmentActivityId() {
    local DEVELOPMENT_ACTIVITY_ID="9"

    echo "$DEVELOPMENT_ACTIVITY_ID"
}



function callRedmineAPI() {
    if [[ -z "$REDMINE_API_KEY" ]]; then 
        echo -e "${vermelho}ERRO: A chave de API do RedMine não foi informada. ${reset}"
        sleep 2
        return 1
    fi

    local REDMINE_TICKET_URL=$(getRedmineTicketURL)

    if [[ -z "$REDMINE_TICKET_URL" ]]; then 
        echo -e "${vermelho}ERRO: Não foi possível encontrar o Ticket no RedMine. ${reset}"
        sleep 2
        return 1
    fi

    local RESPONSE=$(curl -s -H "X-Redmine-API-Key: $REDMINE_API_KEY" "$REDMINE_TICKET_URL")

    local SANITIZED_RESPONSE=$(sanitizeResponseFromASCII "$RESPONSE")
    
    echo "$SANITIZED_RESPONSE" | jq .
}

function sanitizeResponseFromASCII() {
    local RESPONSE="$1"

    if [[ -z "$RESPONSE" ]]; then
        echo -e "${vermelho}ERRO: Não foi passado nenhum JSON para sanitização. ${reset}"
        sleep 2
        return 1
    fi

    local SANITIZED_RESPONSE=$(echo "$RESPONSE" | tr -d '\000-\037')
    
    echo "$SANITIZED_RESPONSE"
}

function testApiRequest() {
    local RESPONSE=$(curl -s -w "\n%{http_code}" -H "X-Redmine-API-Key: $REDMINE_API_KEY" "$ALL_REDMINE_STATUSES")

    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

    if [[ "$HTTP_CODE" -ne 200 ]]; then
        echo -e "${vermelho}ERRO {$HTTP_CODE}: Não foi possível efetuar a requisição. ${reset}"
        sleep 2
        return 1
    fi
}

MAJOR_ANALYZING_DEVELOPING_ID=$(getMajorAnalyzingDevelopingStatusId)
MAJOR_AWAITING_ANALYSIS_DEVELOPMENT_ID=$(getMajorAwaitingAnalysisDevelopmentStatusId)

MAJOR_AVAILABLE_FOR_INTERNAL_TESTING=$(getMajorAvailableForInternalTesting)

CUSTOM_FIELD_STATUS_DEVELOPMENT_ID=$(getCustomFieldStatusDevelopmentId)

SECONDARY_ANALYZING_STATUS_VALUE=$(getSecondaryAnalyzingStatusName)
SECONDARY_AWAITING_ANALYSYS_STATUS_VALUE=$(getSecondaryAwaitingAnalysisStatusName)

SECONDARY_DEVELOPING_STATUS_VALUE=$(getSecondaryDevelopingStatusName)
SECONDARY_AWAITING_DEVELOPMENT_STATUS_VALUE=$(getSecondaryAwaitingDevelopmentStatusName)
SECONDARY_FINISHED_DEVELOPMENT_STATUS_VALUE=$(getSecondaryFinishedDevelopment)

SECONDARY_HALTED_STATUS_VALUE=$(getSecondaryHaltedStatusName)

ANALYSIS_ACTIVITY_ID=$(getAnalysisActivityId)
DEVELOPMENT_ACTIVITY_ID=$(getDevelopmentActivityId)
