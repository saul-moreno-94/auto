#!/bin/bash

# Colores para resaltar
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # Sin color

# Mostrar banner
function show_banner() {
    echo -e "${GREEN}"
    echo "███╗   ██╗ █████╗ ██╗   ██╗ █████╗ ██████╗ "
    echo "████╗  ██║██╔══██╗╚██╗ ██╔╝██╔══██╗██╔══██╗"
    echo "██╔██╗ ██║███████║ ╚████╔╝ ███████║██████╔╝"
    echo "██║╚██╗██║██╔══██║  ╚██╔╝  ██╔══██║██╔══██╗"
    echo "██║ ╚████║██║  ██║   ██║   ██║  ██║██║  ██║"
    echo "╚═╝  ╚═══╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝"
    echo "████████╗ ██████╗  ██████╗ ██╗     ███████╗"
    echo "╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝"
    echo "   ██║   ██║   ██║██║   ██║██║     ███████╗"
    echo "   ██║   ██║   ██║██║   ██║██║     ╚════██║"
    echo "   ██║   ╚██████╔╝╚██████╔╝███████╗███████║"
    echo "   ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝"
    echo -e "${NC}"
}

# Función para mostrar información del sistema
function system_info() {
    echo -e "${GREEN}### Información del sistema ###${NC}"
    echo "Hostname: $(hostname)"
    echo "Usuario: $(whoami)"
    echo "Distribución: $(lsb_release -d | cut -f2)"
    echo "Kernel: $(uname -r)"
}

# Función para mostrar información de la CPU
function cpu_info() {
    echo -e "${GREEN}### Información de la CPU ###${NC}"
    lscpu | grep -E 'Model name|CPU MHz|Socket' | sed 's/^/  /'
}

# Función para mostrar información de la RAM
function ram_info() {
    echo -e "${GREEN}### Memoria RAM ###${NC}"
    free -h | grep Mem | awk '{print "Total: "$2" - Usada: "$3" - Libre: "$4}'
}

# Función para mostrar almacenamiento
function disk_info() {
    echo -e "${GREEN}### Almacenamiento ###${NC}"
    df -h --output=source,size,used,avail | grep '^/'
}

# Función para mostrar interfaces de red
function network_info() {
    echo -e "${GREEN}### Interfaces de Red ###${NC}"
    ip -brief addr show | awk '{print $1, $3}'
}

# Función para mostrar procesos en ejecución
function process_info() {
    echo -e "${GREEN}### Procesos en ejecución ###${NC}"
    ps aux --sort=-%mem | head -n 10
}

# Función para mostrar servicios activos
function services_info() {
    echo -e "${GREEN}### Servicios Activos ###${NC}"
    systemctl list-units --type=service --state=running | head -n 10
}

# Función principal para el menú
function main_menu() {
    while true; do
        show_banner
        echo -e "\n${YELLOW}--- Menú de Información del Sistema ---${NC}"
        echo "1) Información del sistema"
        echo "2) CPU"
        echo "3) RAM"
        echo "4) Almacenamiento"
        echo "5) Red"
        echo "6) Procesos"
        echo "7) Servicios"
        echo "8) Exportar informe"
        echo "9) Salir"
        read -p "Seleccione una opción: " choice

        case $choice in
            1) system_info ;;
            2) cpu_info ;;
            3) ram_info ;;
            4) disk_info ;;
            5) network_info ;;
            6) process_info ;;
            7) services_info ;;
            8) export_report ;;
            9) echo -e "${RED}Saliendo...${NC}"; exit 0 ;;
            *) echo -e "${RED}Opción no válida.${NC}" ;;
        esac
    done
}

# Función para exportar el informe a un archivo
function export_report() {
    file="system_report_$(date +%Y%m%d_%H%M%S).txt"
    {
        system_info
        cpu_info
        ram_info
        disk_info
        network_info
        process_info
        services_info
    } > "$file"
    echo -e "${GREEN}Informe guardado en $file${NC}"
}

# Ejecutar el menú principal
main_menu
