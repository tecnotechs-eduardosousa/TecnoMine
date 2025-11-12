
menu_principal=(
"4) Tempo Restante Gasto no Ticket"
"3) Tempo Total Gasto no Ticket"
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

tempo_total_gasto=(
"2) Tempo em Desenvolvimento"
"1) Tempo em Análise"
)

tempo_restante=(
"2) Tempo Restante em Desenvolvimento"
"1) Tempo Restante em Análise"
)

function tecnomine(){    
    local branch=$(git branch --show-current)

    if [[ -z "$branch" ]]; then
        print_error "Não foi possível verificar a branch atual."
        sleep 2
        tput reset
        return 1
    fi 

    # Clear screen and show banner
    clear
    echo ""
    figlet -f slant -c "TecnoMine" | lolcat -F 0.25 -p 20 -S 27
    echo ""
    print_info "Branch atual: ${bold}${verde}$branch${reset}"
    echo ""
    print_separator 70 "$ciano"
    echo ""

    while true; do
        selection=$(printf '%s\n' "${menu_principal[@]}" \
            | fzf --prompt="❯ Selecione uma opção: " \
                --height=50% \
                --border=rounded \
                --border-label=" 🎯 Menu Principal " \
                --border-label-pos=3 \
                --color="border:cyan,label:cyan:bold,prompt:magenta:bold" \
                --pointer="▶" \
                --marker="✓")

        case $selection in
            "1) Situação do Ticket")
                sub_option_selected=$(printf '%s\n' "${situacao_menu[@]}" \
                    | fzf --prompt="❯ Selecione a situação: " \
                        --height=50% \
                        --border=rounded \
                        --border-label=" 📊 Situações do Ticket " \
                        --border-label-pos=3 \
                        --color="border:blue,label:blue:bold,prompt:magenta:bold" \
                        --pointer="▶" \
                        --marker="✓")
                ;;
            "2) Checklist do Ticket")
                sub_option_selected=$(printf '%s\n' "${checklist_menu[@]}" \
                    | fzf --prompt="❯ Gerenciar checklist: " \
                        --height=40% \
                        --border=rounded \
                        --border-label=" ✓ Checklist " \
                        --border-label-pos=3 \
                        --color="border:green,label:green:bold,prompt:magenta:bold" \
                        --pointer="▶" \
                        --marker="✓")
                ;;
            "3) Tempo Total Gasto no Ticket")
                sub_option_selected=$(printf '%s\n' "${tempo_total_gasto[@]}" \
                    | fzf --prompt="❯ Calcular tempo: " \
                        --height=40% \
                        --border=rounded \
                        --border-label=" ⏱ Tempo Total " \
                        --border-label-pos=3 \
                        --color="border:yellow,label:yellow:bold,prompt:magenta:bold" \
                        --pointer="▶" \
                        --marker="✓")
                ;;
            "4) Tempo Restante Gasto no Ticket")
                sub_option_selected=$(printf '%s\n' "${tempo_total_gasto[@]}" \
                    | fzf --prompt="❯ Calcular tempo restante: " \
                        --height=40% \
                        --border=rounded \
                        --border-label=" ⏱ Tempo Restante " \
                        --border-label-pos=3 \
                        --color="border:yellow,label:yellow:bold,prompt:magenta:bold" \
                        --pointer="▶" \
                        --marker="✓")
                ;;
            *)
                print_error "Opção inválida! O programa será encerrado."
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
             "1) Tempo Restante em Análise") getRemainingAnalyzingTicketTime
             break ;;
             "2) Tempo Restante em Desenvolvimento") getRemainingDevelopingTicketTime
             break ;;
            *)
                print_error "Opção inválida! O programa será encerrado."
                sleep 1
                tput reset
                return 1
                ;;
        esac

        echo ""
        print_success "Operação concluída com sucesso! ${icon_celebrate}"
        echo ""
        
        return 0
    done
}