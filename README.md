# 🐋 Instalador Automático de Docker para Kali Linux

Script automatizado para instalar la última versión de Docker Engine y Docker Desktop en Kali Linux, especialmente diseñado para entornos virtualizados (VirtualBox).

## 📋 Requisitos

- Kali Linux 2024 o superior
- Mínimo 4GB de RAM
- Conexión a Internet
- Permisos de administrador (sudo)
- Si usas VirtualBox: Virtualización anidada habilitada

## 🚀 Instalación Rápida

1. Descarga el script:
```bash
wget https://raw.githubusercontent.com/EnriqueSLsys/docker-kali-install/main/install_docker.sh
```

2. Dale permisos de ejecución:
```bash
chmod +x install_docker.sh
```

3. Ejecútalo:
```bash
sudo ./install_docker.sh
```

## 🔧 Pasos Post-Instalación (Solo para VirtualBox)

1. Apaga tu máquina virtual de Kali Linux
2. En Windows, ejecuta como administrador:
```cmd
cd "C:\Program Files\Oracle\VirtualBox"
VBoxManage modifyvm "NOMBRE_DE_TU_MAQUINA" --nested-hw-virt on
```
3. Enciende tu máquina virtual
4. Inicia Docker Desktop:
```bash
docker-desktop
```

## ✅ Verificar la Instalación

```bash
# Verificar versión de Docker
docker --version

# Probar Docker
docker run hello-world
```

## 🛟 Solución de Problemas Comunes

1. **Error de KVM**: 
   - Sigue los pasos de post-instalación para VirtualBox
   - Verifica que tu CPU soporta virtualización

2. **Docker Desktop no inicia**:
   - Verifica que la virtualización anidada está habilitada
   - Reinicia la máquina virtual

3. **Error de permisos**:
   - Cierra sesión y vuelve a entrar para aplicar los cambios de grupo
   - O ejecuta: `newgrp docker`

## 📚 Comandos Útiles

```bash
# Ver estado de Docker
sudo systemctl status docker

# Ver contenedores activos
docker ps

# Ver todas las imágenes
docker images

# Detener Docker Desktop
killall docker-desktop

# Reiniciar servicio Docker
sudo systemctl restart docker
```

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Por favor, abre un issue primero para discutir los cambios.

## 📜 Licencia

MIT License - Ver [LICENSE](LICENSE) para más detalles.
