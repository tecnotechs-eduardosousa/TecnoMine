
typeset -g IS_GNU_DATE=""

function init_date_parser() {
    if [[ -z "$IS_GNU_DATE" ]]; then
        IS_GNU_DATE=$((date --version >/dev/null 2>&1) && echo 0 || echo 1)
    fi
}

function parse_data() {
    local INPUT="$1"
    
    init_date_parser
    
    if [[ $IS_GNU_DATE -eq 0 ]]; then
        date -d "$INPUT" +%s
    else 
        date -j -f "%Y-%m-%dT%H:%M:%SZ" "$INPUT" +%s
    fi
}

function parse_data_fast() {
    local INPUT="$1"
    
    init_date_parser
    
    if [[ $IS_GNU_DATE -eq 0 ]]; then
        date -d "$INPUT" +%s
    else 
        date -j -f "%Y-%m-%dT%H:%M:%SZ" "$INPUT" +%s
    fi
}

function getAnalyzingTicketTime(){
    show_loading "Analisando histórico do ticket" 1
    
    local JOURNALS=$(getJournalsData)

    if [[ -z "$JOURNALS" ]]; then
        echo ""
        print_error "Não foi possível verificar o histórico do Ticket."
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
        echo ""
        print_error "Não foi possível extrair o histórico de situações."
        print_info "Verifique se existe o campo 'Situação de Desenvolvimento' nos journals."
        sleep 2
        tput reset
        return 1
    fi

    local ANALYZING_TIME=()
    local CHANGED_TIMES=()
    
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
            
            [[ -z "$START_TIME" || -z "$END_TIME" ]] && continue
            
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
        if [[ $TOTAL_SECONDS -le 0 ]]; then
            echo ""
            print_warning "O tempo total em análise é menor ou igual a zero."
            return 1
        fi
        
        # Converter total de segundos para horas (com decimais)
        local TOTAL_IN_HOURS=$(echo "scale=2; $TOTAL_SECONDS / 3600" | bc 2>&1)
        
        if [[ -z "$TOTAL_IN_HOURS" ]] || [[ "$TOTAL_IN_HOURS" == *"error"* ]]; then
            echo ""
            print_error "Erro ao calcular o tempo total em análise."
            print_info "TOTAL_SECONDS: $TOTAL_SECONDS"
            return 1
        fi
        
        if ! [[ "$TOTAL_IN_HOURS" =~ ^-?[0-9]*\.?[0-9]+$ ]]; then
            echo ""
            print_error "Tempo calculado inválido: '$TOTAL_IN_HOURS'"
            return 1
        fi

        local TICKET_NUMBER=$(getTicketNumber)
        
        echo ""
        print_header "TEMPO EM ANÁLISE - TICKET #${TICKET_NUMBER}" 70 "${azul}"
        print_label "Transições detectadas" "$COUNT" "$cinza" "$branco"
        print_label "Tempo total calculado" "$(format_time_duration $TOTAL_IN_HOURS)" "$cinza" "$verde"
        echo ""
        print_separator 70 "${cinza}"
        echo ""

        local SEND_ANALYSIS_TIME
        print_prompt "Deseja enviar o tempo gasto em análise? (S/n)"
        read -k 1 SEND_ANALYSIS_TIME
        echo ""

        if [[ "$SEND_ANALYSIS_TIME" == [Ss] ]]; then
            sendAnalyzingTicketTime "$TOTAL_IN_HOURS"
        else 
            print_info "Operação cancelada."
            return 1
        fi

    else
        echo ""
        print_warning "Nenhuma transição de 'EM ANÁLISE' encontrada."
    fi
}

function getRemainingAnalyzingTicketTime() {
    show_loading "Analisando histórico do ticket" 1
    
    local JOURNALS=$(getJournalsData)

    if [[ -z "$JOURNALS" ]]; then
        echo ""
        print_error "Não foi possível verificar o histórico do Ticket."
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
        echo ""
        print_error "Não foi possível extrair o histórico de situações."
        print_info "Verifique se existe o campo 'Situação de Desenvolvimento' nos journals."
        sleep 2
        tput reset
        return 1
    fi

    local ANALYZING_TIME=()
    local CHANGED_TIMES=()
    
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
            
            [[ -z "$START_TIME" || -z "$END_TIME" ]] && continue
            
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
        if [[ $TOTAL_SECONDS -le 0 ]]; then
            echo ""
            print_warning "O tempo total em análise é menor ou igual a zero."
            return 1
        fi
        
        # Converter total de segundos para horas (com decimais)
        local TOTAL_IN_HOURS=$(echo "scale=2; $TOTAL_SECONDS / 3600" | bc 2>&1)
        
        if [[ -z "$TOTAL_IN_HOURS" ]] || [[ "$TOTAL_IN_HOURS" == *"error"* ]]; then
            echo ""
            print_error "Erro ao calcular o tempo total em análise."
            print_info "TOTAL_SECONDS: $TOTAL_SECONDS"
            return 1
        fi
        
        if ! [[ "$TOTAL_IN_HOURS" =~ ^-?[0-9]*\.?[0-9]+$ ]]; then
            echo ""
            print_error "Tempo calculado inválido: '$TOTAL_IN_HOURS'"
            return 1
        fi

        show_loading "Verificando tempo já enviado" 1
        
        local REDMINE_TICKET_ESTIMATED_TIME_URL=$(getRedmineEstimatedTimeURL)

        if [[ -z "$REDMINE_TICKET_ESTIMATED_TIME_URL" ]]; then
            echo ""
            print_error "Não foi possível encontrar a seção de tempo estimado deste Ticket."
            sleep 2
            tput reset
            return 1
        fi
        
        local TIME_ENTRIES=$(curl -s -H "X-Redmine-API-Key: $REDMINE_API_KEY" "$REDMINE_TICKET_ESTIMATED_TIME_URL")
        
        if [[ -z "$TIME_ENTRIES" ]]; then
            echo ""
            print_error "Não foi possível obter os tempos já registrados."
            sleep 2
            tput reset
            return 1
        fi
        
        local LOGGED_HOURS=$(echo "$TIME_ENTRIES" | jq -r --arg activity_id "$ANALYSIS_ACTIVITY_ID" '
            .time_entries[] | 
            select(.activity.id == ($activity_id | tonumber)) | 
            .hours' | awk '{sum += $1} END {print sum}')
        
        if [[ -z "$LOGGED_HOURS" || "$LOGGED_HOURS" == "null" ]]; then
            LOGGED_HOURS="0"
        fi
        
        # Calcular o tempo restante
        local REMAINING_HOURS=$(echo "scale=2; $TOTAL_IN_HOURS - $LOGGED_HOURS" | bc 2>&1)
        
        if [[ -z "$REMAINING_HOURS" ]] || [[ "$REMAINING_HOURS" == *"error"* ]]; then
            echo ""
            print_error "Erro ao calcular o tempo restante."
            return 1
        fi
        
        local REMAINING_POSITIVE=$(echo "$REMAINING_HOURS > 0" | bc)
        
        local TICKET_NUMBER=$(getTicketNumber)

        echo ""
        print_header "TEMPO EM ANÁLISE - TICKET #${TICKET_NUMBER}" 70 "${azul}"
        print_label "Transições detectadas" "$COUNT" "$cinza" "$branco"
        print_label "Tempo total calculado" "$(format_time_duration $TOTAL_IN_HOURS)" "$cinza" "$verde"
        print_label "Tempo já enviado" "$(format_time_duration $LOGGED_HOURS)" "$cinza" "$amarelo"
        print_label "Tempo restante" "$(format_time_duration $REMAINING_HOURS)" "$cinza" "$ciano"
        echo ""
        print_separator 70 "${cinza}"
        echo ""

        if [[ $REMAINING_POSITIVE -eq 0 ]]; then
            print_warning "Não há tempo restante para enviar."
            echo ""
            print_info "Todo o tempo de análise já foi registrado no Redmine."
            return 0
        fi

        local SEND_REMAINING_TIME
        print_prompt "Deseja enviar o tempo restante em análise? (S/n)"
        read -k 1 SEND_REMAINING_TIME
        echo ""

        if [[ "$SEND_REMAINING_TIME" == [Ss] ]]; then
            sendAnalyzingTicketTime "$REMAINING_HOURS"
        else 
            print_info "Operação cancelada."
            return 1
        fi

    else
        echo ""
        print_warning "Nenhuma transição de 'EM ANÁLISE' encontrada."
    fi
}

function sendAnalyzingTicketTime() {
    local TOTAL_IN_HOURS="$1"

    local HAS_COMMENTARY
    echo ""
    print_prompt "Deseja adicionar um comentário? (S/n)"
    read -k 1 HAS_COMMENTARY
    echo ""

    local COMMENTARY

    if [[ "$HAS_COMMENTARY" == [Ss] ]]; then
        echo ""
        print_info "Digite o comentário:"
        echo ""
        read -r COMMENTARY
    fi 

    show_loading "Enviando tempo para o Redmine" 1

    local REDMINE_TICKET_ESTIMATED_TIME_URL=$(getRedmineEstimatedTimeURL)

    if [[ -z "$REDMINE_TICKET_ESTIMATED_TIME_URL" ]]; then
        echo ""
        print_error "Não foi possível encontrar a seção de tempo estimado deste Ticket."
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
        echo ""
        print_error "Não foi possível enviar o tempo de análise para o Ticket."
        sleep 2
        tput reset
        return 1
    fi

    local TICKET_NUMBER=$(getTicketNumber)

    echo ""
    print_success "Tempo de análise enviado com sucesso para o Ticket #$TICKET_NUMBER! ${icon_celebrate}"
    echo ""
}



function getDevelopingTicketTime(){
    show_loading "Analisando histórico do ticket" 1
    
    local JOURNALS=$(getJournalsData)

    if [[ -z "$JOURNALS" ]]; then
        echo ""
        print_error "Não foi possível verificar o histórico do Ticket."
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
        echo ""
        print_error "Não foi possível extrair o histórico de situações."
        print_info "Verifique se existe o campo 'Situação de Desenvolvimento' nos journals."
        sleep 2
        tput reset
        return 1
    fi

    local DEVELOPING_TIME=()
    local CHANGED_TIMES=()
    
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
            
            [[ -z "$START_TIME" || -z "$END_TIME" ]] && continue
            
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
        if [[ $TOTAL_SECONDS -le 0 ]]; then
            echo ""
            print_warning "O tempo total de desenvolvimento é menor ou igual a zero."
            return 1
        fi
        
        # Converter total de segundos para horas (com decimais)
        local TOTAL_IN_HOURS=$(echo "scale=2; $TOTAL_SECONDS / 3600" | bc 2>&1)

        if [[ -z "$TOTAL_IN_HOURS" ]] || [[ "$TOTAL_IN_HOURS" == *"error"* ]]; then
            echo ""
            print_error "Erro ao calcular o tempo total de desenvolvimento."
            print_info "TOTAL_SECONDS: $TOTAL_SECONDS"
            return 1
        fi
        
        # Validate that TOTAL_IN_HOURS is a valid number
        if ! [[ "$TOTAL_IN_HOURS" =~ ^-?[0-9]*\.?[0-9]+$ ]]; then
            echo ""
            print_error "Tempo calculado inválido: '$TOTAL_IN_HOURS'"
            return 1
        fi
        
        local TICKET_NUMBER=$(getTicketNumber)
        
        echo ""
        print_header "TEMPO EM DESENVOLVIMENTO - TICKET #${TICKET_NUMBER}" 70 "${amarelo}"
        print_label "Transições detectadas" "$COUNT" "$cinza" "$branco"
        print_label "Tempo total calculado" "$(format_time_duration $TOTAL_IN_HOURS)" "$cinza" "$verde"
        echo ""
        print_separator 70 "${cinza}"
        echo ""

        local SEND_DEVELOPING_TIME
        print_prompt "Deseja enviar o tempo gasto em desenvolvimento? (S/n)"
        read -k 1 SEND_DEVELOPING_TIME
        echo ""

        if [[ "$SEND_DEVELOPING_TIME" == [Ss] ]]; then
            sendDevelopingTicketTime "$TOTAL_IN_HOURS"
        else 
            print_info "Operação cancelada."
            return 1
        fi

    else
        echo ""
        print_warning "Nenhuma transição de 'EM DESENVOLVIMENTO' encontrada."
    fi
}

function getRemainingDevelopingTicketTime() {
    show_loading "Analisando histórico do ticket" 1
    
    local JOURNALS=$(getJournalsData)

    if [[ -z "$JOURNALS" ]]; then
        echo ""
        print_error "Não foi possível verificar o histórico do Ticket."
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
        echo ""
        print_error "Não foi possível extrair o histórico de situações."
        print_info "Verifique se existe o campo 'Situação de Desenvolvimento' nos journals."
        sleep 2
        tput reset
        return 1
    fi

    local DEVELOPING_TIME=()
    local CHANGED_TIMES=()
    
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
            
            [[ -z "$START_TIME" || -z "$END_TIME" ]] && continue
            
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
        if [[ $TOTAL_SECONDS -le 0 ]]; then
            echo ""
            print_warning "O tempo total de desenvolvimento é menor ou igual a zero."
            return 1
        fi
        
        # Converter total de segundos para horas (com decimais)
        local TOTAL_IN_HOURS=$(echo "scale=2; $TOTAL_SECONDS / 3600" | bc 2>&1)

        if [[ -z "$TOTAL_IN_HOURS" ]] || [[ "$TOTAL_IN_HOURS" == *"error"* ]]; then
            echo ""
            print_error "Erro ao calcular o tempo total de desenvolvimento."
            print_info "TOTAL_SECONDS: $TOTAL_SECONDS"
            return 1
        fi
        
        if ! [[ "$TOTAL_IN_HOURS" =~ ^-?[0-9]*\.?[0-9]+$ ]]; then
            echo ""
            print_error "Tempo calculado inválido: '$TOTAL_IN_HOURS'"
            return 1
        fi
        
        show_loading "Verificando tempo já enviado" 1
        
        local REDMINE_TICKET_ESTIMATED_TIME_URL=$(getRedmineEstimatedTimeURL)

        if [[ -z "$REDMINE_TICKET_ESTIMATED_TIME_URL" ]]; then
            echo ""
            print_error "Não foi possível encontrar a seção de tempo estimado deste Ticket."
            sleep 2
            tput reset
            return 1
        fi
        
        local TIME_ENTRIES=$(curl -s -H "X-Redmine-API-Key: $REDMINE_API_KEY" "$REDMINE_TICKET_ESTIMATED_TIME_URL")
        
        if [[ -z "$TIME_ENTRIES" ]]; then
            echo ""
            print_error "Não foi possível obter os tempos já registrados."
            sleep 2
            tput reset
            return 1
        fi
        
        local LOGGED_HOURS=$(echo "$TIME_ENTRIES" | jq -r --arg activity_id "$DEVELOPMENT_ACTIVITY_ID" '
            .time_entries[] | 
            select(.activity.id == ($activity_id | tonumber)) | 
            .hours' | awk '{sum += $1} END {print sum}')
        
        if [[ -z "$LOGGED_HOURS" || "$LOGGED_HOURS" == "null" ]]; then
            LOGGED_HOURS="0"
        fi
        
        local REMAINING_HOURS=$(echo "scale=2; $TOTAL_IN_HOURS - $LOGGED_HOURS" | bc 2>&1)
        
        if [[ -z "$REMAINING_HOURS" ]] || [[ "$REMAINING_HOURS" == *"error"* ]]; then
            echo ""
            print_error "Erro ao calcular o tempo restante."
            return 1
        fi
        
        local REMAINING_POSITIVE=$(echo "$REMAINING_HOURS > 0" | bc)
        
        local TICKET_NUMBER=$(getTicketNumber)

        echo ""
        print_header "TEMPO EM DESENVOLVIMENTO - TICKET #${TICKET_NUMBER}" 70 "${amarelo}"
        print_label "Transições detectadas" "$COUNT" "$cinza" "$branco"
        print_label "Tempo total calculado" "$(format_time_duration $TOTAL_IN_HOURS)" "$cinza" "$verde"
        print_label "Tempo já enviado" "$(format_time_duration $LOGGED_HOURS)" "$cinza" "$amarelo"
        print_label "Tempo restante" "$(format_time_duration $REMAINING_HOURS)" "$cinza" "$ciano"
        echo ""
        print_separator 70 "${cinza}"
        echo ""

        if [[ $REMAINING_POSITIVE -eq 0 ]]; then
            print_warning "Não há tempo restante para enviar."
            echo ""
            print_info "Todo o tempo de desenvolvimento já foi registrado no Redmine."
            return 0
        fi

        local SEND_REMAINING_TIME
        print_prompt "Deseja enviar o tempo restante em desenvolvimento? (S/n)"
        read -k 1 SEND_REMAINING_TIME
        echo ""

        if [[ "$SEND_REMAINING_TIME" == [Ss] ]]; then
            sendDevelopingTicketTime "$REMAINING_HOURS"
        else 
            print_info "Operação cancelada."
            return 1
        fi

    else
        echo ""
        print_warning "Nenhuma transição de 'EM DESENVOLVIMENTO' encontrada."
    fi
}

function sendDevelopingTicketTime() {
    local TOTAL_IN_HOURS="$1"

    local HAS_COMMENTARY
    echo ""
    print_prompt "Deseja adicionar um comentário? (S/n)"
    read -k 1 HAS_COMMENTARY
    echo "" 

    local COMMENTARY

    if [[ "$HAS_COMMENTARY" == [Ss] ]]; then
        echo ""
        print_info "Digite o comentário:"
        echo ""
        read COMMENTARY
    fi 

    local REDMINE_TICKET_ESTIMATED_TIME_URL=$(getRedmineEstimatedTimeURL)

    if [[ -z "$REDMINE_TICKET_ESTIMATED_TIME_URL" ]]; then
        echo ""
        print_error "Não foi possível encontrar a seção de tempo estimado deste Ticket."
        sleep 2
        tput reset
        return 1
    fi

    show_loading "Enviando tempo de desenvolvimento" 1

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
        echo ""
        print_error "Não foi possível enviar o tempo em desenvolvimento para o Ticket."
        sleep 2
        tput reset
        return 1
    fi

    local TICKET_NUMBER=$(getTicketNumber)

    echo ""
    print_success "Tempo de desenvolvimento enviado para o Ticket #$TICKET_NUMBER! ${icon_celebrate}"
    echo ""
}