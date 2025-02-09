#!/bin/bash

# Colores para resaltar
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m' # Sin color

# Limpiar pantalla
clear

# Mostrar banner
function show_banner() {
    echo -e "${GREEN}"
    echo "███╗   ██╗ █████╗ ██╗   ██╗ █████╗ ██████╗ "
    echo "████╗  ██║██╔══██╗╚██╗ ██╔╝██╔══██╗██╔══██╗"
    echo "██╔██╗ ██║███████║ ╚████╔╝ ███████║██████╔╝"
    echo "██║╚██╗██║██╔══██║  ╚██╔╝  ██╔══██║██╔══██╗"
    echo "██║ ╚████║██║  ██║   ██║   ██║  ██║██║  ██║"
    echo "╚═╝  ╚═══╝╚═╝  ╚═╝   ╚═╝   ╚═╝╚═╝  ╚═╝"
    echo "████████╗ ██████╗  ██████╗ ██╗     ███████╗"
    echo "╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝"
    echo "   ██║   ██║   ██║██║   ██║██║     ███████╗"
    echo "   ██║   ██║   ██║██║   ██║██║     ╚════██║"
    echo "   ██║   ╚██████╔╝╚██████╔╝███████╗███████║"
    echo "   ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝"
    echo -e "${NC}"
}

# Función para mostrar reglas de iptables
function iptables_info() {
    clear
    show_banner
    echo -e "\n${CYAN}### Reglas de iptables ###${NC}\n"
    echo "┌────────────────────────────────────────────────────┐"
    sudo iptables -L -v -n | sed 's/^/│ /; s/$/ │/'
    echo "└────────────────────────────────────────────────────┘"
    echo -e "\n${YELLOW}Presione Enter para regresar al menú...${NC}"
    read -r
    clear
}

# Función para mostrar información de red
function network_info() {
    local ip_address=$(ip -o -f inet addr show wlp2s0 | awk '{print $4}')
    local network=$(echo $ip_address | awk -F'/' '{print $1}' | awk -F'.' '{print $1"."$2"."$3".0/24"}')
    clear
    show_banner
    echo -e "\n${CYAN}### Información de Red ###${NC}\n"
    echo "┌──────────────────────────────────────────────┐"
    printf "│ %-44s │\n" "IP: ${ip_address}"
    printf "│ %-44s │\n" "Red: ${network}"
    echo "└──────────────────────────────────────────────┘"
    echo -e "\n${YELLOW}Presione Enter para continuar...${NC}"
    read -r
    clear
    network_menu "$network"
}

# Función para el menú de red
function network_menu() {
    local network=$1
    while true; do
        clear
        show_banner
        echo -e "\n${BLUE}--- Menú de Red ---${NC}\n"
        echo "1) Escanear red con nmap"
        echo "2) Regresar al menú principal"
        read -p "Seleccione una opción: " choice

        case $choice in
            1) nmap_scan "$network" ;;
            2) clear; return ;;
            *) echo -e "${RED}Opción no válida.${NC}" ;;
        esac
    done
}

# Función para realizar un escaneo rápido con nmap
function nmap_scan() {
    local network=$1
    clear
    show_banner
    echo -e "\n${CYAN}### Escaneo rápido de la red ${network} ###${NC}\n"
    echo "┌────────────────────────────────────────────────────┐"
    local hosts=()
    local count=1
    sudo nmap -sn "$network" | while read -r line; do
        if [[ $line == *"Nmap scan report for"* ]]; then
            local ip=$(echo $line | awk '{print $5}')
            hosts+=("$ip")
            printf "│ %2d) %-40s │\n" "$count" "${CYAN}$ip${NC}"
            count=$((count + 1))
        elif [[ $line == *"MAC Address"* ]]; then
            local mac=$(echo $line | awk '{print $3}')
            local vendor=$(echo $line | awk '{print $4 " " $5}')
            printf "│     %-40s │\n" "$mac ($vendor)"
        fi
    done
    echo "└────────────────────────────────────────────────────┘"
    echo -e "\n${YELLOW}Seleccione un número para un escaneo detallado o presione Enter para regresar al menú...${NC}"
    read -r choice
    if [[ $choice =~ ^[0-9]+$ ]] && (( choice > 0 && choice <= ${#hosts[@]} )); then
        detailed_nmap_scan "${hosts[$((choice - 1))]}"
    fi
    clear
}

# Función para realizar un escaneo detallado con nmap
function detailed_nmap_scan() {
    local ip=$1
    clear
    show_banner
    echo -e "\n${CYAN}### Escaneo detallado de la IP ${ip} ###${NC}\n"
    echo "┌────────────────────────────────────────────────────┐"
    sudo nmap -A "$ip" | sed 's/^/│ /; s/$/ │/'
    echo "└────────────────────────────────────────────────────┘"
    echo -e "\n${YELLOW}Presione Enter para regresar al menú...${NC}"
    read -r
    clear
}

# Función principal para el menú
function main_menu() {
    while true; do
        clear
        show_banner
        echo -e "\n${BLUE}--- Menú de Información del Sistema ---${NC}\n"
        echo "1) Explorar reglas de iptables"
        echo "2) Información de red"
        echo "3) Salir"
        read -p "Seleccione una opción: " choice

        case $choice in
            1) iptables_info ;;
            2) network_info ;;
            3) echo -e "${RED}Saliendo...${NC}"; exit 0 ;;
            *) echo -e "${RED}Opción no válida.${NC}" ;;
        esac
    done
}

# Ejecutar el menú principal
main_menu
