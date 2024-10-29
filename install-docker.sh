#!/bin/bash

#############################################
# Script de Instalación de Docker para Kali #
# Autor: Enrique Serrano                    #
# Versión: 1.0                              #
#############################################

# Colores para mensajes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Funciones de mensajes
print_message() { echo -e "${BLUE}[*]${NC} $1"; }
print_success() { echo -e "${GREEN}[✔]${NC} $1"; }
print_error() { echo -e "${RED}[✘]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }

# Función para verificar requisitos
check_requirements() {
    print_message "Verificando requisitos del sistema..."
    
    # Verificar usuario root
    if [ "$EUID" -ne 0 ]; then 
        print_error "Este script debe ejecutarse como root (sudo)"
        exit 1
    fi
    
    # Verificar RAM
    total_ram=$(free -g | awk '/^Mem:/{print $2}')
    if [ $total_ram -lt 4 ]; then
        print_warning "Se recomienda tener al menos 4GB de RAM. Tienes ${total_ram}GB"
        read -p "¿Deseas continuar anyway? (s/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Ss]$ ]]; then
            exit 1
        fi
    fi
    
    # Verificar conexión a internet
    if ! ping -c 1 google.com &> /dev/null; then
        print_error "No hay conexión a Internet"
        exit 1
    fi
}

# Función para instalar Docker Engine
install_docker_engine() {
    print_message "PASO 1: Instalando Docker Engine..."

    # Eliminar versiones antiguas si existen
    print_message "Removiendo versiones antiguas si existen..."
    apt remove -y docker docker-engine docker.io containerd runc &> /dev/null

    # Actualizar sistema
    print_message "Actualizando sistema..."
    apt update || {
        print_error "Error actualizando paquetes"
        exit 1
    }

    # Instalar dependencias
    print_message "Instalando dependencias..."
    apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release || {
        print_error "Error instalando dependencias"
        exit 1
    }

    # Añadir repositorio oficial de Docker
    print_message "Configurando repositorio de Docker..."
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Instalar Docker
    print_message "Instalando Docker Engine..."
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || {
        print_error "Error instalando Docker"
        exit 1
    }

    # Configurar Docker
    print_message "Configurando Docker..."
    systemctl start docker
    systemctl enable docker
    
    # Añadir usuario actual al grupo docker
    SUDO_USER=$(logname)
    usermod -aG docker $SUDO_USER
    
    print_success "Docker Engine instalado correctamente"
}

# Función para obtener la última versión de Docker Desktop
get_latest_docker_desktop() {
    print_message "Obteniendo última versión de Docker Desktop..."
    
    # Obtener la última versión desde la API de GitHub
    LATEST_VERSION=$(curl -s https://api.github.com/repos/docker/desktop/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
    
    if [ -z "$LATEST_VERSION" ]; then
        print_error "No se pudo obtener la última versión"
        exit 1
    fi
    
    # Limpiar el formato de la versión
    LATEST_VERSION=${LATEST_VERSION#desktop-}
    print_success "Última versión encontrada: $LATEST_VERSION"
    echo $LATEST_VERSION
}

# Función para instalar Docker Desktop
install_docker_desktop() {
    print_message "PASO 2: Instalando Docker Desktop..."
    
    # Obtener última versión
    VERSION=$(get_latest_docker_desktop)
    
    # Instalar dependencias
    print_message "Instalando dependencias..."
    apt install -y \
        gnome-terminal \
        wget \
        qemu-system \
        qemu-user \
        qemu-utils \
        kmod \
        init-system-helpers \
        pass \
        uidmap \
        python3-pip || {
        print_error "Error instalando dependencias"
        exit 1
    }

    # Descargar e instalar Docker Desktop
    print_message "Descargando Docker Desktop $VERSION..."
    TEMP_DEB="/tmp/docker-desktop.deb"
    wget -O $TEMP_DEB "https://desktop.docker.com/linux/main/amd64/docker-desktop-${VERSION}-amd64.deb" || {
        print_error "Error descargando Docker Desktop"
        rm -f $TEMP_DEB
        exit 1
    }

    print_message "Instalando Docker Desktop..."
    apt install -y $TEMP_DEB || {
        print_error "Error instalando Docker Desktop"
        rm -f $TEMP_DEB
        exit 1
    }

    rm -f $TEMP_DEB
}

# Función principal
main() {
    clear
    echo "╔════════════════════════════════════════════╗"
    echo "║     Instalador de Docker para Kali Linux    ║"
    echo "╚════════════════════════════════════════════╝"
    echo
    
    # Verificar requisitos
    check_requirements
    
    # Instalar Docker Engine
    install_docker_engine
    
    # Instalar Docker Desktop
    install_docker_desktop
    
    # Verificación final
    if command -v docker-desktop &> /dev/null; then
        echo
        print_success "¡Instalación completada con éxito!"
        echo
        print_message "PASOS SIGUIENTES:"
        echo "1. Si usas VirtualBox, necesitas habilitar la virtualización anidada:"
        echo "   - Apaga esta máquina virtual"
        echo "   - En Windows (como administrador):"
        echo "     cd \"C:\\Program Files\\Oracle\\VirtualBox\""
        echo "     VBoxManage modifyvm \"Kali linux 2024\" --nested-hw-virt on"
        echo "   - Vuelve a encender esta máquina virtual"
        echo
        echo "2. Cierra sesión y vuelve a iniciarla para aplicar los cambios"
        echo
        echo "3. Inicia Docker Desktop:"
        echo "   docker-desktop"
        echo
        echo "4. Prueba la instalación:"
        echo "   docker run hello-world"
    else
        print_error "La instalación no se completó correctamente"
        exit 1
    fi
}

# Iniciar instalación
main
