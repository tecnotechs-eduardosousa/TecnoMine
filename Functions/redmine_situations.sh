
function setTicketToAnalyzing() {
    testApiRequest

    local REDMINE_TICKET_URL=$(getRedmineTicketURL)

    if [[ -z "$REDMINE_TICKET_URL" ]]; then 
        print_error "Não foi possível encontrar o Ticket no RedMine."
        sleep 2
        return 1
    fi

    show_loading "Atualizando situação do ticket" 1

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
        echo ""
        print_error "Falha ao tentar atualizar a situação do Ticket. (Código: $NEW_STATUS)"
        sleep 2
        return 1
    fi

    local TICKET_NUMBER=$(getTicketNumber)

    echo ""
    print_header "STATUS ATUALIZADO" 70 "${verde}"
    print_success "O Ticket #$TICKET_NUMBER foi definido como em análise!"
    echo ""
    print_label "Situação Principal" "EM ANÁLISE / DEV" "$cinza" "$azul"
    print_label "Situação Desenvolvimento" "EM ANÁLISE" "$cinza" "$azul"
    echo ""
    print_separator 70
    echo ""
}

function setTicketToAwaitingAnalysis() {
    testApiRequest

    local REDMINE_TICKET_URL=$(getRedmineTicketURL)

    if [[ -z "$REDMINE_TICKET_URL" ]]; then 
        print_error "Não foi possível encontrar o Ticket no RedMine."
        sleep 2
        return 1
    fi

    show_loading "Atualizando situação do ticket" 1

    NEW_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$REDMINE_TICKET_URL" \
                    -H "Content-Type: application/json" \
                    -H "X-Redmine-API-Key: $REDMINE_API_KEY" \
                    -d "{
                        \"issue\": {
                            \"status_id\": $MAJOR_AWAITING_ANALYSIS_DEVELOPMENT_ID,
                            \"custom_fields\": [
                                {\"id\": $CUSTOM_FIELD_STATUS_DEVELOPMENT_ID, \"value\": \"$SECONDARY_AWAITING_ANALYSYS_STATUS_VALUE\"}
                            ]
                        }
                    }")

    if [[ -z "$NEW_STATUS" || "$NEW_STATUS" -ne 204 ]]; then
        print_error "Falha ao tentar atualizar a situação do Ticket. (Código: $NEW_STATUS)"
        sleep 3
        return 1
    fi

    local TICKET_NUMBER=$(getTicketNumber)

    echo ""
    print_header "STATUS ATUALIZADO" 70 "${verde}"
    print_success "O Ticket #$TICKET_NUMBER foi definido como em aguardando análise!"
    echo ""
    print_label "Situação Principal" "AGUARDANDO ANÁLISE / DEV" "$cinza" "$azul"
    print_label "Situação Desenvolvimento" "AGUARDANDO ANÁLISE" "$cinza" "$azul"
    echo ""
    print_separator 70
    echo ""
}

function setTicketToFeedbackAndFinishedAnalysis() {
    testApiRequest

    local REDMINE_TICKET_URL=$(getRedmineTicketURL)

    if [[ -z "$REDMINE_TICKET_URL" ]]; then 
        print_error "Não foi possível encontrar o Ticket no RedMine."
        sleep 2
        return 1
    fi

    show_loading "Atualizando situação do ticket" 1

    NEW_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$REDMINE_TICKET_URL" \
                    -H "Content-Type: application/json" \
                    -H "X-Redmine-API-Key: $REDMINE_API_KEY" \
                    -d "{
                        \"issue\": {
                            \"status_id\": $MAJOR_FEEDBACK,
                            \"custom_fields\": [
                                {\"id\": $CUSTOM_FIELD_STATUS_DEVELOPMENT_ID, \"value\": \"$SECONDARY_FINISHED_ANALYSIS_STATUS_VALUE\"}
                            ]
                        }
                    }")

    if [[ -z "$NEW_STATUS" || "$NEW_STATUS" -ne 204 ]]; then
        print_error "Falha ao tentar atualizar a situação do Ticket. (Código: $NEW_STATUS)"
        sleep 3
        return 1
    fi

    local TICKET_NUMBER=$(getTicketNumber)

    echo ""
    print_header "STATUS ATUALIZADO" 70 "${verde}"
    print_success "O Ticket #$TICKET_NUMBER foi definido como feedback!"
    echo ""
    print_label "Situação Principal" "FEEDBACK" "$cinza" "$azul"
    print_label "Situação Desenvolvimento" "ANÁLISE CONCLUIDA" "$cinza" "$azul"
    echo ""
    print_separator 70
    echo ""
}

function setTicketToDeveloping() {
    testApiRequest

    local REDMINE_TICKET_URL=$(getRedmineTicketURL)

    if [[ -z "$REDMINE_TICKET_URL" ]]; then 
        print_error "Não foi possível encontrar o Ticket no RedMine."
        sleep 2
        return 1
    fi

    show_loading "Atualizando situação do ticket" 1

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
        echo ""
        print_error "Falha ao tentar atualizar a situação do Ticket. (Código: $NEW_STATUS)"
        sleep 2
        return 1
    fi

    local TICKET_NUMBER=$(getTicketNumber)

    echo ""
    print_header "STATUS ATUALIZADO" 70 "${verde}"
    print_success "O Ticket #$TICKET_NUMBER foi definido como em desenvolvimento! ${icon_rocket}"
    echo ""
    print_label "Situação Principal" "EM ANÁLISE / DEV" "$cinza" "$amarelo"
    print_label "Situação Desenvolvimento" "EM DESENVOLVIMENTO" "$cinza" "$amarelo"
    echo ""
    print_separator 70
    echo ""
}

function setTicketToAwaitingDevelopment() {
    testApiRequest

    local REDMINE_TICKET_URL=$(getRedmineTicketURL)

    if [[ -z "$REDMINE_TICKET_URL" ]]; then 
        print_error "Não foi possível encontrar o Ticket no RedMine."
        sleep 2
        return 1
    fi

    show_loading "Atualizando situação do ticket" 1

    NEW_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$REDMINE_TICKET_URL" \
                    -H "Content-Type: application/json" \
                    -H "X-Redmine-API-Key: $REDMINE_API_KEY" \
                    -d "{
                        \"issue\": {
                            \"status_id\": $MAJOR_AWAITING_ANALYSIS_DEVELOPMENT_ID,
                            \"custom_fields\": [
                                {\"id\": $CUSTOM_FIELD_STATUS_DEVELOPMENT_ID, \"value\": \"$SECONDARY_AWAITING_DEVELOPMENT_STATUS_VALUE\"}
                            ]
                        }
                    }")

    if [[ -z "$NEW_STATUS" || "$NEW_STATUS" -ne 204 ]]; then
        print_error "Falha ao tentar atualizar a situação do Ticket. (Código: $NEW_STATUS)"
        sleep 3
        return 1
    fi

    local TICKET_NUMBER=$(getTicketNumber)

    echo ""
    print_header "STATUS ATUALIZADO" 70 "${verde}"
    print_success "O Ticket #$TICKET_NUMBER foi definido como em desenvolvimento! ${icon_rocket}"
    echo ""
    print_label "Situação Principal" "AGUARDANDO ANÁLISE / DEV" "$cinza" "$amarelo"
    print_label "Situação Desenvolvimento" "AGUARDANDO DESENVOLVIMENTO" "$cinza" "$amarelo"
    echo ""
    print_separator 70
    echo ""
}

function setTicketToAvailableForTestAndFinishedDevelopment() {
    testApiRequest

    local REDMINE_TICKET_URL=$(getRedmineTicketURL)

    if [[ -z "$REDMINE_TICKET_URL" ]]; then 
        print_error "Não foi possível encontrar o Ticket no RedMine."
        sleep 2
        return 1
    fi

    show_loading "Atualizando situação do ticket" 1

    NEW_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$REDMINE_TICKET_URL" \
                    -H "Content-Type: application/json" \
                    -H "X-Redmine-API-Key: $REDMINE_API_KEY" \
                    -d "{
                        \"issue\": {
                            \"status_id\": $MAJOR_AVAILABLE_FOR_INTERNAL_TESTING,
                            \"custom_fields\": [
                                {\"id\": $CUSTOM_FIELD_STATUS_DEVELOPMENT_ID, \"value\": \"$SECONDARY_FINISHED_DEVELOPMENT_STATUS_VALUE\"}
                            ]
                        }
                    }")

    if [[ -z "$NEW_STATUS" || "$NEW_STATUS" -ne 204 ]]; then
        echo ""
        print_error "Falha ao tentar atualizar a situação do Ticket. (Código: $NEW_STATUS)"
        sleep 2
        return 1
    fi

    local TICKET_NUMBER=$(getTicketNumber)

    echo ""
    print_header "STATUS ATUALIZADO" 70 "${verde}"
    print_success "O Ticket #$TICKET_NUMBER foi definido como disponível em teste interno! ${icon_celebrate}"
    echo ""
    print_label "Situação Principal" "DISPONÍVEL EM TESTE INTERNO" "$cinza" "$verde"
    print_label "Situação Desenvolvimento" "DESENVOLVIMENTO CONCLUÍDO" "$cinza" "$verde"
    echo ""
    print_separator 70
    echo ""
}

function setTicketToHalted() {
    testApiRequest

    local REDMINE_TICKET_URL=$(getRedmineTicketURL)

    if [[ -z "$REDMINE_TICKET_URL" ]]; then 
        print_error "Não foi possível encontrar o Ticket no RedMine."
        sleep 2
        return 1
    fi

    show_loading "Atualizando situação do ticket" 1

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
                print_error "Falha ao tentar atualizar a situação do Ticket. (Código: $NEW_STATUS)"
        sleep 3
        return 1
    fi

    local TICKET_NUMBER=$(getTicketNumber)

    echo ""
    print_header "STATUS ATUALIZADO" 70 "${verde}"
    print_success "O Ticket #$TICKET_NUMBER foi definido como temporariamente suspenso!"
    echo ""
    print_label "Situação Principal" "AGUARDANDO ANÁLISE / DEV." "$cinza" "$verde"
    print_label "Situação Desenvolvimento" "TEMPORARIAMENTE SUSPENSO (Outro Motivo)" "$cinza" "$verde"
    echo ""
    print_separator 70
    echo ""
}



