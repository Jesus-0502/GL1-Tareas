#!/bin/bash

# Script para lregistrar logs de dispositvos USB
# Elaborado por: CJ
# Estado: Imcompleto

# Configuración
LOG_FILE="/var/log/USB_logs.log"
UDEV_RULE_PATH="/etc/udev/rules.d/99-usb-logs.rules"
SCRIPT_PATH="/usr/local/bin/usb_logger_aux.sh"


if [[ ! -f $SCRIPT_PATH ]]
then
    # Crear el script de logging
    sudo tee "$SCRIPT_PATH" > /dev/null <<'EOF'
#!/bin/bash

LOG_FILE="/var/log/USB_logs.log"
PORT_ID=$(basename "$(dirname "$DEVNAME")")  # Ejemplo: "1-1" para puerto USB
CURRENT_TIME=$(date "+%Y/%m/%d %a %I:%M %p")
if [ -z "$PORT_ID" ] || [ "$PORT_ID" = "." ]; then
    exit 0
fi

case "$1" in
    "add")
        # Registrar conexión
        echo "PUERTO_$PORT_ID | $CURRENT_TIME | " | column -t -s " " >> "$LOG_FILE"
        ;;
    "remove")
        # Buscar la última conexión no completada de este puerto
        last_entry=$(tac "$LOG_FILE" | grep -m1 "PUERTO_$PORT_ID |.*| $")
        
        if [ -n "$last_entry" ]; then
            # Completar la entrada existente
            temp_file=$(mktemp)
            awk -v port="PUERTO_$PORT_ID" -v time="$CURRENT_TIME" '
                $0 ~ port" \\|.*\\| $" { 
                    if (!found) {
                        sub(/\| $/, "| "time); 
                        found=1
                    }
                }
                { print }
            ' "$LOG_FILE" > "$temp_file" && mv "$temp_file" "$LOG_FILE"
        else
            # Registrar desconexión sin conexión previa
            echo "PUERTO_$PORT_ID | | $CURRENT_TIME" | column -t -s " " >> "$LOG_FILE"
        fi
        ;;
esac
EOF

    # Dar permisos de ejecucion al script
    sudo chmod +x "$SCRIPT_PATH"
fi

# Crear reglas udev
if [ ! -f "$UDEV_RULES_PATH" ]; then
    sudo tee "$UDEV_RULE_PATH" > /dev/null <<'EOF'
ACTION=="add", SUBSYSTEM=="usb", RUN+="/usr/local/bin/usb_logger_aux.sh add"
ACTION=="remove", SUBSYSTEM=="usb", RUN+="/usr/local/bin/usb_logger_aux.sh remove"
EOF
    # Recargar reglas udev
    sudo udevadm control --reload-rules
    sudo udevadm trigger
fi

if [[ ! -f $LOG_FILE ]]
then
    # Crear archivo de log y dar permisos
    sudo touch "$LOG_FILE"
    sudo chmod 666 "$LOG_FILE"
    echo "PUERTOS | FECHA_CONEXION | FECHA_DESCONEXION" | column -t >> $LOG_FILE

fi