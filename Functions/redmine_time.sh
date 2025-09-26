
function parse_data() {
    local INPUT="$1"

    local IS_GNU=$((date --version >/dev/null 2>&1) && echo 0 || echo 1)
    if [[ $IS_GNU -eq 0 ]]; then
        date -d "$INPUT" +%s
    else 
        date -j -f "%Y-%m-%dT%H:%M:%SZ" "$INPUT" +%s
    fi
}

function getAnalyzingTicketTime(){
    local JOURNALS=$(getJournalsData)

    if [[ -z "$JOURNALS" ]]; then
        echo -e "${vermelho}ERRO: Não foi possível verificar o histórico do Ticket.${reset}"
        sleep 2
        tput reset
        return 1
    fi

    SITUATIONS_HISTORY=()
    
    while IFS= read -r line; do
        [[ -n "$line" ]] && SITUATIONS_HISTORY+=("$line")
    done < <(echo "$JOURNALS" | jq -r '
                .[] |
                .created_on as $time |
                .details[]? |
                select(.name=="Situação de Desenvolvimento" or .name=="4") |
                "\($time) \(.old_value) -> \(.new_value)"
            ')

    if [[ ${#SITUATIONS_HISTORY[@]} -eq 0 ]]; then
        echo "${vermelho}ERRO: Não foi possível extrair o histórico de situações.${reset}"
        echo "Verifique se existe o campo 'Situação de Desenvolvimento' nos journals."
        sleep 2
        tput reset
        return 1
    fi

    local ANALYZING_TIME=()
    local CHANGED_TIMES=()
    
    # Processar o histórico para encontrar as transições
    for line in "${SITUATIONS_HISTORY[@]}"; do
        timestamp=$(echo "$line" | cut -d' ' -f1)
        transition=$(echo "$line" | cut -d' ' -f2-)
        
        if [[ "$transition" == *"-> EM ANÁLISE" ]]; then
            ANALYZING_TIME+=("$timestamp")
        elif [[ "$transition" == "EM ANÁLISE -> "* ]]; then
            CHANGED_TIMES+=("$timestamp")
        fi
    done
    
    # Calcular os tempos decorridos
    local TOTAL_SECONDS=0
    local COUNT=0
    
    local MAX_CHANGED_TIMES_INDEX=${#CHANGED_TIMES[@]}
    for ((i=1; i<=MAX_CHANGED_TIMES_INDEX; i++)); do
        if [[ $i -le ${#ANALYZING_TIME[@]} ]]; then
            local START_TIME="${ANALYZING_TIME[$i]}"
            local END_TIME="${CHANGED_TIMES[$i]}"
            
            # Converter para timestamp Unix
            local START_UNIX=$(parse_data "$START_TIME")
            local END_UNIX=$(parse_data "$END_TIME")
            
            if [[ -n "$START_UNIX" && -n "$END_UNIX" ]]; then
                local diff=$((END_UNIX - START_UNIX))
                TOTAL_SECONDS=$((TOTAL_SECONDS + diff))
                COUNT=$((COUNT + 1))
            fi
        fi
    done
    
    if [[ $COUNT -gt 0 ]]; then
        # Converter total de segundos para horas (com decimais)
        local TOTAL_IN_HOURS=$(echo "scale=2; $TOTAL_SECONDS / 3600" | bc)
        
        if [[ "$TOTAL_IN_HOURS" -le 0 ]]; then
            echo -e "${amarelo}AVISO: O tempo total em análise é menor ou igual a zero. ${reset}"
            return 1
        fi

        echo "Total de transições: $COUNT"
        echo "Tempo total: ${TOTAL_IN_HOURS} horas"

        echo ""

        local SEND_ANALYSIS_TIME
        echo -ne "${laranja}Deseja enviar o tempo gasto em análise? (S/n) ${reset}"
        read -k 1 SEND_ANALYSIS_TIME
        echo ""


        if [[ "$SEND_ANALYSIS_TIME" == [Ss] ]]; then
            sendAnalyzingTicketTime "$TOTAL_IN_HOURS"
        else 
            return 1
        fi

    else
        echo -e "${vermelho}Nenhuma transição de 'EM ANÁLISE' encontrada. ${reset}"
    fi
}

function sendAnalyzingTicketTime() {
    local TOTAL_IN_HOURS="$1"

    local HAS_COMMENTARY
    echo ""
    echo -ne "${laranja}Deseja comentar algo? (S/n) ${reset}"
    read -k 1 HAS_COMMENTARY
    echo ""

    local COMMENTARY

    if [[ "$HAS_COMMENTARY" == [Ss] ]]; then
        echo -e "${azul}Digite o comentário: ${reset}"
        read -r COMMENTARY
    fi 

    local REDMINE_TICKET_ESTIMATED_TIME_URL=$(getRedmineEstimatedTimeURL)

    if [[ -z "$REDMINE_TICKET_ESTIMATED_TIME_URL" ]]; then
        echo -e "${vermelho}ERRO: Não foi possível encontrar a seção de tempo estimado deste Ticket. ${reset}"
        sleep 2
        tput reset
        return 1
    fi

    ANALYSIS_TIME=$(curl -s -X POST "$REDMINE_TICKET_ESTIMATED_TIME_URL" \
                    -H "Content-Type: application/json" \
                    -H "X-Redmine-API-Key: $REDMINE_API_KEY" \
                    -d "{
                        \"time_entry\": {
                            \"hours\": \"$TOTAL_IN_HOURS\",
                            \"activity_id\": \"$ANALYSIS_ACTIVITY_ID\",
                            \"comments\": \"$COMMENTARY\"
                        }
                    }")

    if [[ -z "$ANALYSIS_TIME" ]]; then
        echo -e "${vermelho}ERRO: Não foi possível enviar o tempo de análise para o Ticket.${reset}"
        sleep 2
        tput reset
        return 1
    fi

    local TICKET_NUMBER=$(getTicketNumber)

    echo -e "${verde}✅ Enviado o tempo de análise para o Ticket #$TICKET_NUMBER!"
}



function getDevelopingTicketTime(){
    local JOURNALS=$(getJournalsData)

    if [[ -z "$JOURNALS" ]]; then
        echo -e "${vermelho}ERRO: Não foi possível verificar o histórico do Ticket.${reset}"
        sleep 2
        tput reset
        return 1
    fi

    SITUATIONS_HISTORY=()
    
    while IFS= read -r line; do
        [[ -n "$line" ]] && SITUATIONS_HISTORY+=("$line")
    done < <(echo "$JOURNALS" | jq -r '
                .[] |
                .created_on as $time |
                .details[]? |
                select(.name=="Situação de Desenvolvimento" or .name=="4") |
                "\($time) \(.old_value) -> \(.new_value)"
            ')

    if [[ ${#SITUATIONS_HISTORY[@]} -eq 0 ]]; then
        echo "{$vermelho}ERRO: Não foi possível extrair o histórico de situações.${reset}"
        echo "Verifique se existe o campo 'Situação de Desenvolvimento' nos journals."
        sleep 2
        tput reset
        return 1
    fi

    local DEVELOPING_TIME=()
    local CHANGED_TIMES=()
    
    # Processar o histórico para encontrar as transições
    for line in "${SITUATIONS_HISTORY[@]}"; do
        timestamp=$(echo "$line" | cut -d' ' -f1)
        transition=$(echo "$line" | cut -d' ' -f2-)
        
        if [[ "$transition" == *"-> EM DESENVOLVIMENTO" ]]; then
            DEVELOPING_TIME+=("$timestamp")
        elif [[ "$transition" == "EM DESENVOLVIMENTO -> "* ]]; then
            CHANGED_TIMES+=("$timestamp")
        fi
    done

    # Calcular os tempos decorridos
    local TOTAL_SECONDS=0
    local COUNT=0
    
    local MAX_CHANGED_TIMES_INDEX=${#CHANGED_TIMES[@]}
    for ((i=1; i<=MAX_CHANGED_TIMES_INDEX; i++)); do
        if [[ $i -le ${#DEVELOPING_TIME[@]} ]]; then
            local START_TIME="${DEVELOPING_TIME[$i]}"
            local END_TIME="${CHANGED_TIMES[$i]}"
            
            # Converter para timestamp Unix
            local START_UNIX=$(parse_data "$START_TIME")
            local END_UNIX=$(parse_data "$END_TIME")
            
            if [[ -n "$START_UNIX" && -n "$END_UNIX" ]]; then
                local diff=$((END_UNIX - START_UNIX))
                TOTAL_SECONDS=$((TOTAL_SECONDS + diff))
                COUNT=$((COUNT + 1))
            fi
        fi
    done
    
    if [[ $COUNT -gt 0 ]]; then
        # Converter total de segundos para horas (com decimais)
        local TOTAL_IN_HOURS=$(echo "scale=2; $TOTAL_SECONDS / 3600" | bc)

        if [[ "$TOTAL_IN_HOURS" -le 0 ]]; then
            echo -e "${amarelo}AVISO: O tempo total de desenvolvimento é menor ou igual a zero.${reset}"
            return 1
        fi
        
        echo "Total de transições: $COUNT"
        echo "Tempo total: ${TOTAL_IN_HOURS} horas"

        local SEND_DEVELOPING_TIME
        echo -ne "${laranja}Deseja enviar o tempo gasto em desenvolvimento? (S/n)${reset}"
        read -k 1 SEND_DEVELOPING_TIME
        echo ""

        if [[ "$SEND_DEVELOPING_TIME" == [Ss] ]]; then
            sendDevelopingTicketTime "$TOTAL_IN_HOURS"
        else 
            return 1
        fi

    else
        echo -e "${vermelho}Nenhuma transição de 'EM DESENVOLVIMENTO' encontrada.${reset}"
    fi
}

function sendDevelopingTicketTime() {
    local TOTAL_IN_HOURS="$1"

    local HAS_COMMENTARY
    echo ""
    echo -ne "${laranja}Deseja comentar algo? (S/n)${reset}"
    read -k 1 HAS_COMMENTARY
    echo "" 

    local COMMENTARY

    if [[ "$HAS_COMMENTARY" == [[Ss]] ]]; then
        echo -e "${azul}Digite o comentário:${reset}"
        read COMMENTARY
    fi 

    local REDMINE_TICKET_ESTIMATED_TIME_URL=$(getRedmineEstimatedTimeURL)

    if [[ -z "$REDMINE_TICKET_ESTIMATED_TIME_URL" ]]; then
        echo -e "${vermelho}ERRO: Não foi possível encontrar a seção de tempo estimado deste Ticket.${reset}"
        sleep 2
        tput reset
        return 1
    fi

    DEVELOPMENT_TIME=$(curl -s -X POST "$REDMINE_TICKET_ESTIMATED_TIME_URL" \
                    -H "Content-Type: application/json" \
                    -H "X-Redmine-API-Key: $REDMINE_API_KEY" \
                    -d "{
                        \"time_entry\": {
                            \"hours\": \"$TOTAL_IN_HOURS\",
                            \"activity_id\": \"$DEVELOPMENT_ACTIVITY_ID\",
                            \"comments\": \"$COMMENTARY\"
                        }
                    }")

    if [[ -z "$DEVELOPMENT_TIME" ]]; then
        echo -e "${vermelho}ERRO: Não foi possível enviar o tempo em desenvolvimento para o Ticket.${reset}"
        sleep 2
        tput reset
        return 1
    fi

    local TICKET_NUMBER=$(getTicketNumber)

    echo -e "${verde}✅ Enviado o tempo em desenvolvimento para o Ticket #$TICKET_NUMBER!${reset}"
}