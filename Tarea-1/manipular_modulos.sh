#!/bin/bash

# Script para la manipulacion de modulos
# Elaborado por: CJ

NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
# Funcion que representa al flag -a
activar () {
    # Verificamos si el modulo ya se encuentra en el archivo /proc/modules
    modulo=$(lsmod | awk '{print $1}' | grep -w $1)
    #echo $modulo
    #echo $1
    if [[ $modulo = $1 ]]
    then
        echo "El módulo $modulo ya está activado"
    else

	# Verificamos si el modulo existe para ser cargado
	ARCHIVO_KO=$(find /lib/modules/$(uname -r) -name "$1.ko.zst")
    if [[ ! -e $ARCHIVO_KO  ]]
	then
        echo "ERROR: El módulo $1 no fue encontrado"
	else
		echo "Activando módulo..."
		sudo modprobe $ARCHIVO_KO 
		echo "Módulo activado!"
	fi
    fi
}

# Funcion que representa al flag -r
desactivar () {
    # Verificamos si el modulo ya se encuentra en el archivo /proc/modules
    modulo=$(lsmod | awk '{print $1}' | grep -w $1)
    if [[ $modulo = $1 ]]
    then
        echo "Desactivando módulo..."
        sudo modprobe -r $modulo
        echo "Módulo $modulo desactivado!"
    else
        echo "El módulo $modulo ya está desactivado"
    fi
}

# Funcion que representa al flag --help
help () {
    echo "Uso: ./manipular_modulos [OPCION]... [NOMBRE_MODULO]...\n"
    echo "Sinopsis"
    echo "Script que permite activar o desactivar módulos de la computadora.\n"
    echo "Flags disponibles:\n"
    echo "  -a, --activate      Activa el módulo\n  -r, --remove        Desactiva el módulo\n      --help       Muestra esta ayuda y sale"
}


# Manejo de opciones de entrada del usuario
case $1 in
    --help)
        help
        ;;
    -a | --activate)
        if [[ -z $2 ]]
        then
            echo "ERROR: No has ingresado ningun parámetro."
            echo "Intenta '\033[1m./manipular_modulos --help\033[00m' para mas información."
        else
            activar $2
        fi
        ;;
    -r | --remove)
        if [[ -z $2 ]]
        then
            echo "ERROR: No has ingresado ningun parámetro."
            echo "Intenta '\033[1m./manipular_modulos --help\033[00m' para mas información."
        else
            desactivar $2
        fi
        ;;
    *)
        echo "ERROR: opción no válida. Intenta '\033[1m./manipular_modulos --help\033[00m' para mas información."
        ;;
esac
