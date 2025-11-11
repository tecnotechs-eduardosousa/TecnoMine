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
        echo -e "${vermelho}ERRO: Não foi possível encontrar as situações do Ticket via RedMine. ${reset}" >&2
        sleep 2
        return 1
    fi

    local SANITIZED_RESPONSE=$(sanitizeResponseFromASCII "$RESPONSE")
    
    if [[ $? -ne 0 ]] || [[ -z "$SANITIZED_RESPONSE" ]]; then
        echo -e "${vermelho}ERRO: Falha ao processar a resposta da API (resposta inválida). ${reset}" >&2
        sleep 2
        return 1
    fi

    local STATUS_NAME="EM ANÁLISE / DEV."

    local STATUS_ID=$(echo "$SANITIZED_RESPONSE" | jq -r --arg name "$STATUS_NAME" '.issue_statuses[] | select(.name==$name) | .id')

    echo "$STATUS_ID"
}

function getMajorAwaitingAnalysisDevelopmentStatusId() {
    local RESPONSE=$(curl -s -H "X-Redmine-API-Key: $REDMINE_API_KEY" "$ALL_REDMINE_STATUSES")

    if [[ -z "$RESPONSE" ]]; then
        echo -e "${vermelho}ERRO: Não foi possível encontrar as situações do Ticket via RedMine. ${reset}" >&2
        sleep 2
        return 1
    fi

    local SANITIZED_RESPONSE=$(sanitizeResponseFromASCII "$RESPONSE")
    
    if [[ $? -ne 0 ]] || [[ -z "$SANITIZED_RESPONSE" ]]; then
        echo -e "${vermelho}ERRO: Falha ao processar a resposta da API (resposta inválida). ${reset}" >&2
        sleep 2
        return 1
    fi

    local STATUS_NAME="AGUARDANDO ANÁLISE / DEV."

    local STATUS_ID=$(echo "$SANITIZED_RESPONSE" | jq -r --arg name "$STATUS_NAME" '.issue_statuses[] | select(.name==$name) | .id')

    echo "$STATUS_ID"
}

function getMajorFeedbackStatusId() {
    local RESPONSE=$(curl -s -H "X-Redmine-API-Key: $REDMINE_API_KEY" "$ALL_REDMINE_STATUSES")

    if [[ -z "$RESPONSE" ]]; then
        echo -e "${vermelho}ERRO: Não foi possível encontrar as situações do Ticket via RedMine. ${reset}" >&2
        sleep 2
        return 1
    fi

    local SANITIZED_RESPONSE=$(sanitizeResponseFromASCII "$RESPONSE")
    
    if [[ $? -ne 0 ]] || [[ -z "$SANITIZED_RESPONSE" ]]; then
        echo -e "${vermelho}ERRO: Falha ao processar a resposta da API (resposta inválida). ${reset}" >&2
        sleep 2
        return 1
    fi

    local STATUS_NAME="FEEDBACK"

    local STATUS_ID=$(echo "$SANITIZED_RESPONSE" | jq -r --arg name "$STATUS_NAME" '.issue_statuses[] | select(.name==$name) | .id')

    echo "$STATUS_ID"
}

function getMajorAvailableForInternalTestingId() {
    local RESPONSE=$(curl -s -H "X-Redmine-API-Key: $REDMINE_API_KEY" "$ALL_REDMINE_STATUSES")

    if [[ -z "$RESPONSE" ]]; then
        echo -e "${vermelho}ERRO: Não foi possível encontrar as situações do Ticket via RedMine. ${reset}" >&2
        sleep 2
        return 1
    fi

    local SANITIZED_RESPONSE=$(sanitizeResponseFromASCII "$RESPONSE")
    
    if [[ $? -ne 0 ]] || [[ -z "$SANITIZED_RESPONSE" ]]; then
        echo -e "${vermelho}ERRO: Falha ao processar a resposta da API (resposta inválida). ${reset}" >&2
        sleep 2
        return 1
    fi

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

function getSecondaryFinishedAnalysisStatusName() {
    local STATUS_NAME="ANÁLISE CONCLUÍDA"

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
        echo -e "${vermelho}ERRO: A chave de API do RedMine não foi informada. ${reset}" >&2
        sleep 2
        return 1
    fi

    local REDMINE_TICKET_URL=$(getRedmineTicketURL)

    if [[ -z "$REDMINE_TICKET_URL" ]]; then 
        echo -e "${vermelho}ERRO: Não foi possível encontrar o Ticket no RedMine. ${reset}" >&2
        sleep 2
        return 1
    fi

    local RESPONSE=$(curl -s -H "X-Redmine-API-Key: $REDMINE_API_KEY" "$REDMINE_TICKET_URL")

    local SANITIZED_RESPONSE=$(sanitizeResponseFromASCII "$RESPONSE")
    
    if [[ $? -ne 0 ]] || [[ -z "$SANITIZED_RESPONSE" ]]; then
        echo -e "${vermelho}ERRO: Resposta da API não é um JSON válido. ${reset}" >&2
        sleep 2
        return 1
    fi
    
    echo "$SANITIZED_RESPONSE" | jq .
}

function sanitizeResponseFromASCII() {
    local RESPONSE="$1"

    if [[ -z "$RESPONSE" ]]; then
        echo -e "${vermelho}ERRO: Resposta vazia da API.${reset}" >&2
        return 1
    fi

    if echo "$RESPONSE" | grep -qi "^[[:space:]]*<html\|^[[:space:]]*<!DOCTYPE"; then
        echo -e "${vermelho}ERRO: API retornou HTML ao invés de JSON.${reset}" >&2
        echo -e "${amarelo}AVISO: O acesso pode estar bloqueado por firewall/cache (GoCache).${reset}" >&2
        echo -e "${amarelo}DICA: Verifique se você está conectado à VPN ou rede autorizada.${reset}" >&2
        return 2
    fi

    if ! echo "$RESPONSE" | grep -q "^[[:space:]]*[\[{]"; then
        echo -e "${vermelho}ERRO: Resposta não parece ser JSON válido.${reset}" >&2
        return 1
    fi

    local SANITIZED_RESPONSE=$(echo "$RESPONSE" | tr -d '\000-\037' | sed 's/^\xEF\xBB\xBF//')
    
    if echo "$SANITIZED_RESPONSE" | jq empty >/dev/null 2>&1; then
        echo "$SANITIZED_RESPONSE"
        return 0
    fi
    
    SANITIZED_RESPONSE=$(echo "$RESPONSE" | LC_ALL=C sed 's/[\x00-\x08\x0B\x0C\x0E-\x1F]//g' | sed 's/^\xEF\xBB\xBF//')
    
    if echo "$SANITIZED_RESPONSE" | jq empty >/dev/null 2>&1; then
        echo "$SANITIZED_RESPONSE"
        return 0
    fi
    
    if command -v iconv >/dev/null 2>&1; then
        SANITIZED_RESPONSE=$(echo "$RESPONSE" | iconv -c -f utf-8 -t utf-8 2>/dev/null | tr -d '\000-\037' | sed 's/^\xEF\xBB\xBF//')
        
        if echo "$SANITIZED_RESPONSE" | jq empty >/dev/null 2>&1; then
            echo "$SANITIZED_RESPONSE"
            return 0
        fi
    fi
    
    if command -v python3 >/dev/null 2>&1; then
        SANITIZED_RESPONSE=$(echo "$RESPONSE" | python3 -c "import sys, json; data=sys.stdin.read(); print(json.dumps(json.loads(data)))" 2>/dev/null)
        
        if [[ $? -eq 0 ]] && [[ -n "$SANITIZED_RESPONSE" ]]; then
            echo "$SANITIZED_RESPONSE"
            return 0
        fi
    fi
    
    echo -e "${vermelho}ERRO: Não foi possível sanitizar o JSON.${reset}" >&2
    return 1
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

MAJOR_FEEDBACK=$(getMajorFeedbackStatusId)
MAJOR_AVAILABLE_FOR_INTERNAL_TESTING=$(getMajorAvailableForInternalTestingId)

CUSTOM_FIELD_STATUS_DEVELOPMENT_ID=$(getCustomFieldStatusDevelopmentId)

SECONDARY_ANALYZING_STATUS_VALUE=$(getSecondaryAnalyzingStatusName)
SECONDARY_AWAITING_ANALYSYS_STATUS_VALUE=$(getSecondaryAwaitingAnalysisStatusName)
SECONDARY_FINISHED_ANALYSIS_STATUS_VALUE=$(getSecondaryFinishedAnalysisStatusName)

SECONDARY_DEVELOPING_STATUS_VALUE=$(getSecondaryDevelopingStatusName)
SECONDARY_AWAITING_DEVELOPMENT_STATUS_VALUE=$(getSecondaryAwaitingDevelopmentStatusName)
SECONDARY_FINISHED_DEVELOPMENT_STATUS_VALUE=$(getSecondaryFinishedDevelopment)

SECONDARY_HALTED_STATUS_VALUE=$(getSecondaryHaltedStatusName)

ANALYSIS_ACTIVITY_ID=$(getAnalysisActivityId)
DEVELOPMENT_ACTIVITY_ID=$(getDevelopmentActivityId)
