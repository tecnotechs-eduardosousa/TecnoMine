
menu_principal=(
"3) Tempo Estimado do Ticket"
"2) Checklist do Ticket"
"1) Situação do Ticket"
)

situacao_menu=(
"7) DISPONÍVEL EM TESTE INTERNO e DESENVOLVIMENTO CONCLUIDO"
"6) FEEDBACK e ANÁLISE CONCLUIDA"
"5) AGUARDANDO ANÁLISE/DEV e AGUARDANDO DESENVOLVIMENTO"
"4) AGUARDANDO ANÁLISE/DEV e AGUARDANDO ANÁLISE"
"3) AGUARDANDO ANÁLISE/DEV e TEMPORARIAMENTE SUSPENSO (Outro Motivo)"
"2) EM ANÁLISE/DEV e EM DESENVOLVIMENTO"
"1) EM ANÁLISE/DEV e EM ANÁLISE"
)

checklist_menu=(
"2) Visualizar Tarefas"
"1) Adicionar Tarefa"
)

tempo_menu=(
"2) Tempo em Desenvolvimento"
"1) Tempo em Análise"
)

function tecnomine(){    
    local branch=$(git branch --show-current)

    if [[ -z "$branch" ]]; then
        echo -e "${vermelho}ERRO: Não foi possível verificar a branch atual.${reset}"
        sleep 2
        tput reset
        return 1
    fi 

    echo ""
    figlet -f slant -c "TecnoMine" | lolcat -F 0.25 -p 20 -S 27

    while true; do
        selection=$(printf '%s\n' "${menu_principal[@]}" \
            | fzf --prompt="Selecione uma opção: " \
                --height=40% \
                --border)

        case $selection in
            "1) Situação do Ticket")
                sub_option_selected=$(printf '%s\n' "${situacao_menu[@]}" \
                    | fzf --prompt="Selecione uma opção: " \
                        --height=40% \
                        --border)
                ;;
            "2) Checklist do Ticket")
                sub_option_selected=$(printf '%s\n' "${checklist_menu[@]}" \
                    | fzf --prompt="Selecione uma opção: " \
                        --height=40% \
                        --border)
                ;;
            "3) Tempo Estimado do Ticket")
                sub_option_selected=$(printf '%s\n' "${tempo_menu[@]}" \
                    | fzf --prompt="Selecione uma opção: " \
                        --height=40% \
                        --border)
                ;;
            *)
                echo -e "${vermelho} Opção inválida! O programa será encerrado. ${reset}"
                sleep 1
                tput reset
                return 1
                ;;
        esac
        
        case $sub_option_selected in
            "1) EM ANÁLISE/DEV e EM ANÁLISE") setTicketToAnalyzing
            break ;;
            "2) EM ANÁLISE/DEV e EM DESENVOLVIMENTO") setTicketToDeveloping
            break ;;
            "3) AGUARDANDO ANÁLISE/DEV e TEMPORARIAMENTE SUSPENSO (Outro Motivo)") setTicketToHalted
            break ;;
            "4) AGUARDANDO ANÁLISE/DEV e AGUARDANDO ANÁLISE") setTicketToAwaitingAnalysis
            break ;;
            "5) AGUARDANDO ANÁLISE/DEV e AGUARDANDO DESENVOLVIMENTO") setTicketToAwaitingDevelopment
            break ;;
            "6) FEEDBACK e ANÁLISE CONCLUIDA") setTicketToFeedbackAndFinishedAnalysis
            break ;;
            "7) DISPONÍVEL EM TESTE INTERNO e DESENVOLVIMENTO CONCLUIDO") setTicketToAvailableForTestAndFinishedDevelopment
            break ;;
            "1) Adicionar Tarefa") addTaskInChecklist
             break ;;
            "2) Visualizar Tarefas") seeChecklist
             break ;;
            "1) Tempo em Análise") getAnalyzingTicketTime
             break ;;
            "2) Tempo em Desenvolvimento") getDevelopingTicketTime
             break ;;
            *)
                echo -e "${vermelho} Opção inválida! O programa será encerrado. ${reset}"
                sleep 1
                tput reset
                return 1
                ;;
        esac

        return 0
    done
}