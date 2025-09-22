

function setTicketToAnalyzing() {
    testApiRequest

    local REDMINE_TICKET_URL=$(getRedmineTicketURL)

    if [[ -z "$REDMINE_TICKET_URL" ]]; then 
        echo -e "${vermelho}ERRO: Não foi possível encontrar o Ticket no RedMine. ${reset}"
        sleep 2
        return 1
    fi

    NEW_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$REDMINE_TICKET_URL" \
                    -H "Content-Type: application/json" \
                    -H "X-Redmine-API-Key: $REDMINE_API_KEY" \
                    -d "{
                        \"issue\": {
                            \"status_id\": $MAJOR_ANALYZING_DEVELOPING_ID,
                            \"custom_fields\": [
                                {\"id\": $CUSTOM_FIELD_STATUS_DEVELOPMENT_ID, \"value\": \"$SECONDARY_ANALYZING_STATUS_VALUE\"}
                            ]
                        }
                    }")

    if [[ -z "$NEW_STATUS" || "$NEW_STATUS" -ne 204 ]]; then
        echo -e "${vermelho}ERRO {$NEW_STATUS}: Falha ao tentar atualizar a situação do Ticket. ${reset}"
        sleep 3
        return 1
    fi

    local TICKET_NUMBER=$(getTicketNumber)

    echo ""
    echo -e "${laranja}TecnoMine Attendant:${reset}"
    echo ""
    echo -e "${verde}O Ticket #$TICKET_NUMBER foi definido como em análise! ${reset}"
    echo ""
    echo -e "Situação Definida: EM ANÁLISE / DEV."
    echo -e "Situação de Desenvolvimento: EM ANÁLISE"
    echo ""
}




function setTicketToDeveloping() {
    testApiRequest

    local REDMINE_TICKET_URL=$(getRedmineTicketURL)

    if [[ -z "$REDMINE_TICKET_URL" ]]; then 
        echo -e "${vermelho}ERRO: Não foi possível encontrar o Ticket no RedMine. ${reset}"
        sleep 2
        return 1
    fi

    NEW_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$REDMINE_TICKET_URL" \
                    -H "Content-Type: application/json" \
                    -H "X-Redmine-API-Key: $REDMINE_API_KEY" \
                    -d "{
                        \"issue\": {
                            \"status_id\": $MAJOR_ANALYZING_DEVELOPING_ID,
                            \"custom_fields\": [
                                {\"id\": $CUSTOM_FIELD_STATUS_DEVELOPMENT_ID, \"value\": \"$SECONDARY_DEVELOPING_STATUS_VALUE\"}
                            ]
                        }
                    }")

    if [[ -z "$NEW_STATUS" || "$NEW_STATUS" -ne 204 ]]; then
        echo -e "${vermelho}ERRO {$NEW_STATUS}: Falha ao tentar atualizar a situação do Ticket. ${reset}"
        sleep 3
        return 1
    fi

    local TICKET_NUMBER=$(getTicketNumber)

    echo ""
    echo -e "${laranja}TecnoMine Attendant:${reset}"
    echo ""
    echo -e "${verde}O Ticket #$TICKET_NUMBER foi definido como em desenvolvimento! ${reset}"
    echo ""
    echo -e "Situação Definida: EM ANÁLISE / DEV."    
    echo -e "Situação de Desenvolvimento: EM DESENVOLVIMENTO"
    echo ""
}



function setTicketToHalted() {
    testApiRequest

    local REDMINE_TICKET_URL=$(getRedmineTicketURL)

    if [[ -z "$REDMINE_TICKET_URL" ]]; then 
        echo -e "${vermelho}ERRO: Não foi possível encontrar o Ticket no RedMine. ${reset}"
        sleep 2
        return 1
    fi

    NEW_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$REDMINE_TICKET_URL" \
                    -H "Content-Type: application/json" \
                    -H "X-Redmine-API-Key: $REDMINE_API_KEY" \
                    -d "{
                        \"issue\": {
                            \"status_id\": $MAJOR_AWAITING_ANALYSIS_DEVELOPMENT_ID,
                            \"custom_fields\": [
                                {\"id\": $CUSTOM_FIELD_STATUS_DEVELOPMENT_ID, \"value\": \"$SECONDARY_HALTED_STATUS_VALUE\"}
                            ]
                        }
                    }")

    if [[ -z "$NEW_STATUS" || "$NEW_STATUS" -ne 204 ]]; then
        echo -e "${vermelho}ERRO {$NEW_STATUS}: Falha ao tentar atualizar a situação do Ticket. ${reset}"
        sleep 3
        return 1
    fi

    local TICKET_NUMBER=$(getTicketNumber)

    echo ""
    echo -e "${laranja}TecnoMine Attendant:${reset}"
    echo ""
    echo -e "${verde}O Ticket #$TICKET_NUMBER foi definido como temporariamente suspenso! ${reset}"
    echo ""
    echo -e "Situação Definida: AGUARDANDO ANÁLISE / DEV."
    echo -e "Situação de Desenvolvimento: TEMPORARIAMENTE SUSPENSO (Outro Motivo)"    
    echo ""
}



