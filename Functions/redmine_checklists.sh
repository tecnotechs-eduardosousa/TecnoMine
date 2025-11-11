

function addTaskInChecklist(){
    local REDMINE_TICKET_CHECKLISTS_URL=$(getRedmineCheckListsURL)

    testApiRequest

    echo ""
    print_header "ADICIONAR NOVA TAREFA" 70 "${verde}"
    
    while true; do
        echo ""
        print_prompt "Descreva a tarefa:"
        echo ""
        local CHECKLIST_SUBJECT
        read CHECKLIST_SUBJECT
        
        if [[ -z "$CHECKLIST_SUBJECT" ]]; then
            print_warning "A descrição não pode estar vazia!"
            continue
        fi
        
        show_loading "Criando tarefa" 1
        
        NEW_CHECKLIST=$(curl -s -X POST "$REDMINE_TICKET_CHECKLISTS_URL" \
                        -H "Content-Type: application/json" \
                        -H "X-Redmine-API-Key: $REDMINE_API_KEY" \
                        -d "{
                            \"checklist\": {
                                \"subject\": \"$CHECKLIST_SUBJECT\",
                                \"is_done\": 0
                            }
                            }")

        if [[ -z "$NEW_CHECKLIST" ]]; then
            echo ""
            print_error "Falha ao tentar criar checklist."
            sleep 2
            return 1
        fi

        echo ""
        print_separator 70 "${verde}"
        echo ""
        print_success "Tarefa adicionada com sucesso!"
        echo ""
        print_label "Descrição" "$CHECKLIST_SUBJECT" "$cinza" "$roxo"
        echo ""
        print_separator 70 "${cinza}"
        echo ""
        print_prompt "Deseja criar outra tarefa? (S/n)"
        read -k 1 CREATE_NEW_CHECKLIST
        echo ""
        
        setopt NULL_GLOB

        if [[ "$CREATE_NEW_CHECKLIST" == [Ss] ]]; then
            continue
        else
            break
        fi
    done
}

function seeChecklist() {
    local REDMINE_TICKET_CHECKLISTS_URL=$(getRedmineCheckListsURL)

    testApiRequest

    show_loading "Carregando tarefas" 1
    
    ALL_INFO_CHECKLISTS=$(curl -s -H "X-Redmine-API-Key: $REDMINE_API_KEY" \
                    "$REDMINE_TICKET_CHECKLISTS_URL" \
                    | jq .)

    if [[ -z "$ALL_INFO_CHECKLISTS" ]]; then
        echo ""
        print_error "Não foi possível listar as tarefas."
        sleep 2
        return 1
    fi

    local TICKET_NUMBER=$(getTicketNumber)
    local total_tasks=$(echo "$ALL_INFO_CHECKLISTS" | jq '.checklists | length')
    local completed_tasks=$(echo "$ALL_INFO_CHECKLISTS" | jq '[.checklists[] | select(.is_done==true or .is_done==1)] | length')
    
    echo ""
    print_header "CHECKLIST - TICKET #${TICKET_NUMBER}" 70 "${verde}"
    
    if [[ "$total_tasks" -eq 0 ]]; then
        print_info "Nenhuma tarefa cadastrada ainda."
        echo ""
        return 0
    fi
    
    # Progress summary
    print_label "Total de Tarefas" "$total_tasks" "$cinza" "$branco"
    print_label "Concluídas" "$completed_tasks" "$cinza" "$verde"
    print_label "Pendentes" "$((total_tasks - completed_tasks))" "$cinza" "$amarelo"
    echo ""
    
    # Progress bar
    if [[ "$total_tasks" -gt 0 ]]; then
        print_progress_bar $completed_tasks $total_tasks 50
        echo ""
    fi
    
    echo ""
    print_separator 70 "${ciano}"
    echo ""
    
    # List all tasks with better formatting
    printf '%s' "$ALL_INFO_CHECKLISTS" | jq -r '.checklists[] | "\(.id)\t\(.subject)\t\(.is_done)"' | while IFS=$'\t' read -r id subject is_done; do
        format_checklist_item "$id" "$subject" "$is_done"
    done
    
    echo ""
    print_separator 70 "${cinza}"
    echo ""
}
