# Gestionar Servicios

Este script `gestionar_servicios.sh` permite listar, habilitar y deshabilitar servicios en un sistema Linux utilizando `systemd`. Está diseñado para ser fácil de usar en dispositivos con pantallas pequeñas, como móviles.

## Características

- Listar servicios activos no habilitados para inicio automático
- Listar servicios habilitados para inicio automático
- Habilitar servicios
- Deshabilitar servicios

## Uso

1. Copia y pega esta línea en tu terminal:
   ```sh
   curl -O https://raw.githubusercontent.com/pyopower/Debian-autostart-servicios-script/main/gestionar_servicios.sh && chmod +x gestionar_servicios.sh && sudo ./gestionar_servicios.sh
