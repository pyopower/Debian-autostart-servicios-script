#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color

PAGE_SIZE=10

list_services_paginated() {
    services=("$@")
    total_services=${#services[@]}
    total_pages=$(( (total_services + PAGE_SIZE - 1) / PAGE_SIZE ))
    current_page=1

    while true; do
        clear
        echo -e "${CYAN}Página $current_page de $total_pages${NC}"
        start_index=$(( (current_page - 1) * PAGE_SIZE ))
        end_index=$(( start_index + PAGE_SIZE - 1 ))
        if [ $end_index -ge $total_services ]; then
            end_index=$(( total_services - 1 ))
        fi

        for i in $(seq $start_index $end_index); do
            echo -e "${YELLOW}$((i + 1)). ${services[$i]}${NC}"
        done

        echo -e "${GREEN}n. Siguiente página${NC}"
        echo -e "${GREEN}p. Página anterior${NC}"
        echo -e "${GREEN}q. Salir de la lista${NC}"
        
        read -p "Elige una opción: " option
        case $option in
            n)
                if [ $current_page -lt $total_pages ]; then
                    current_page=$(( current_page + 1 ))
                fi
                ;;
            p)
                if [ $current_page -gt 1 ]; then
                    current_page=$(( current_page - 1 ))
                fi
                ;;
            q)
                break
                ;;
            *)
                if [[ $option =~ ^[0-9]+$ ]] && [ $option -ge 1 ] && [ $option -le $total_services ]; then
                    selected_service=${services[$((option - 1))]}
                    break
                fi
                ;;
        esac
    done

    echo "$selected_service"
}

list_active_non_autostart_services() {
    echo -e "${BLUE}Listando servicios activos no habilitados para inicio automático:${NC}"
    active_services=$(systemctl list-units --type=service --state=running --no-pager | awk '{print $1}' | tail -n +2)
    enabled_services=$(systemctl list-unit-files --type=service --state=enabled --no-pager | awk '{print $1}' | tail -n +2)
    active_non_autostart_services=($(echo "$active_services" | grep -Fxv -f <(echo "$enabled_services")))

    list_services_paginated "${active_non_autostart_services[@]}"
}

list_autostart_services() {
    echo -e "${BLUE}Listando servicios habilitados para inicio automático:${NC}"
    enabled_services=($(systemctl list-unit-files --type=service --state=enabled --no-pager | awk '{print $1}' | tail -n +2))

    list_services_paginated "${enabled_services[@]}"
}

enable_service() {
    selected_service=$(list_active_non_autostart_services)
    if [ -n "$selected_service" ]; then
        sudo systemctl enable "$selected_service"
        sudo systemctl start "$selected_service"
        echo -e "${GREEN}Servicio $selected_service habilitado y arrancado.${NC}"
    fi
}

disable_service() {
    selected_service=$(list_autostart_services)
    if [ -n "$selected_service" ]; then
        sudo systemctl disable "$selected_service"
        sudo systemctl stop "$selected_service"
        echo -e "${RED}Servicio $selected_service deshabilitado y detenido.${NC}"
    fi
}

while true; do
    echo -e "${CYAN}Elige una opción:${NC}"
    echo -e "${YELLOW}1. Listar servicios activos no habilitados para inicio automático${NC}"
    echo -e "${YELLOW}2. Listar servicios habilitados para inicio automático${NC}"
    echo -e "${YELLOW}3. Habilitar un servicio${NC}"
    echo -e "${YELLOW}4. Deshabilitar un servicio${NC}"
    echo -e "${YELLOW}5. Salir${NC}"
    read -p "Opción: " option

    case $option in
        1)
            list_active_non_autostart_services
            ;;
        2)
            list_autostart_services
            ;;
        3)
            enable_service
            ;;
        4)
            disable_service
            ;;
        5)
            echo -e "${GREEN}Saliendo...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Opción no válida, por favor intenta de nuevo.${NC}"
            ;;
    esac
done
