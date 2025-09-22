

function addTaskInChecklist(){
    local REDMINE_TICKET_CHECKLISTS_URL=$(getRedmineCheckListsURL)

    testApiRequest

    while true; do
        echo -e "${magenta}Descreva a tarefa: ${reset}"
        local CHECKLIST_SUBJECT
        read CHECKLIST_SUBJECT
        
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
            echo -e "${vermelho}ERRO: Falha ao tentar criar checklist. ${reset}"
            sleep 3
            return 1
        fi

        echo ""
        echo -e "${laranja}TecnoMine Attendant:${reset}"
        echo ""
        echo -e "${verde}O checklist foi criado com sucesso! ${reset}"
        echo ""
        echo -e "${roxo}Assunto: $CHECKLIST_SUBJECT ${reset}"
        echo ""
        echo -e "${magenta}Deseja criar outro checklist? (S/n) ${reset}"
        read -k 1 CREATE_NEW_CHECKLIST
        
        setopt NULL_GLOB
        if [[ "$CREATE_NEW_CHECKLIST" == "n" ]]; then
            break
        fi

        continue
    done
}

function seeChecklist() {
    local REDMINE_TICKET_CHECKLISTS_URL=$(getRedmineCheckListsURL)

    testApiRequest

    ALL_INFO_CHECKLISTS=$(curl -s -H "X-Redmine-API-Key: $REDMINE_API_KEY" \
                    "$REDMINE_TICKET_CHECKLISTS_URL" \
                    | jq .)

    if [[ -z "$ALL_INFO_CHECKLISTS" ]]; then
        echo -e "${vermelho}ERRO: Não foi possível listar os tickets. ${reset}"
        sleep 3
        return 1
    fi

    echo ""
    echo -e "${laranja}TecnoMine Attendant:${reset}"
    echo ""
    echo -e "${rosa}Lista de Tarefas:${reset}"
    echo ""

    # printf '%s' "$CHECKLISTS" | jq -r '.checklists[] | "\(.id) \(.subject) \(.is_done)"'

    printf '%s' "$ALL_INFO_CHECKLISTS" | jq -r '.checklists[] | "\(.id)\t\(.subject)\t\(.is_done)"' | while IFS=$'\t' read -r id subject is_done; do
        echo -e "Assunto: $subject"
        echo -e "Finalizado: $is_done"
        echo ""
    done
}
