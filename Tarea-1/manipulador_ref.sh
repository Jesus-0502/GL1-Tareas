#!/bin/bash

# Script para la manipulacion de referencias
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

# Verificamos si existe el archivo donde se guardan las referencias
ref="$HOME/referencias"
if [[ ! -f $ref ]] 
then
    touch $ref
fi

# Funcion que representa al flag --help
help () {
    echo "Uso:"
    echo "./manipular_modulos [OPCION]... [NOMBRE_REFERENCIA]... [PATH_ARCHIVO]..."
    echo "./manipular_modulos [OPCION]... [NOMBRE_REFERENCIA]..."
    echo "./manipular_modulos [OPCION]..."
    echo "./manipular_modulos [OPCION]... [NOMBRE_REFERENCIA]... [PERMISOS_MODO_OCTAL]\n" 
    echo "Sinopsis:"
    echo "Script que permite activar o desactivar módulos de la computadora.\n"
    echo "Flags disponibles:\n"
    echo "  -a, --add      Agrega una referencia\n  -r, --remove        Elimina una referencia\n  -p, --print       Imprime las rutas de los archivos referenciados\n  -c, --change        Cambia la permisologia de un archivo mediante la referencia\n  --help      Muestra esta ayuda y sale"
}

# Funcion que representa al flag -p | --print
imprimir_ref () {

    echo "Archivos: "
    awk '{print $2}' $ref
}

# Funcion que representa al flag -a | --add
agregar_ref () {

    # 
    if [[ ! -e $2  ]]
	then
        echo "ERROR: El archivo no fue encontrado."
        exit 1
    fi
    # Variable para verificar si el archivo ya fue referenciado
    temp=$(cat $ref | awk '{print $2}' | grep -o $2)

    # Variable para verificar si la referencia esta disponible
    hola=$(cat $ref | awk '{print $1}' | grep -o $1)

    if [[ $2 == /dev/* ]]
    then    
        echo "ERROR: el archivo que quiere referenciar es un dispositivo."
        exit 1

    elif [[ $temp == $2 ]]
    then
        echo "ERROR: ya existe la referencia para $2."
        exit 1

    elif [[ $hola == $1 ]]
    then
        echo "ERROR: ya existe la referencia $1."
        exit 1

    else
        echo "$1 $2" >> $ref
    fi
}

# Funcion que representa al flag -r | --remove
eliminar_ref () {
    
    # Verificamos si la referencia existe
    temp=$(cat $ref | grep -o $1)
    if [[ $temp != $1 ]]
    then
	    echo "ERROR: la referencia $1 no existe."
        exit 1
    else
        # Archivo temporal
        tmp_file=$(mktemp)
        # Copiamos el contenido de $ref al archivo temporal exceptuando 
        # la referencia a eliminar
        awk -v ref="$1" '$1 != ref' $ref > $tmp_file
        # Copiamos al archivo $ref
        mv $tmp_file $ref
        # Borramos el archivo temporal
        rm $tmp_file
    fi
	
}

cambiar_permisos () {

    archivo=$(cat $ref | grep -w $1 | awk '{print $2}')

    # Verificamos si el segundo argumento son los permisos
    if [[ $2 =~ ^[1-7]{3}$ ]]
    then
        echo "cambiando permisos"
        sudo chmod $2 $archivo
    else
        echo "ERROR: Permisos ingresados no validos."
    fi
}

# Manejo de opciones de entrada del usuario
case $1 in
    --help)
        help
        ;;
    -a | --add)
        if [[ -z $2 ]] && [[ -z $3 ]]
        then
            echo "ERROR: No has ingresado ningun parámetro."
            echo "Intenta '\033[1m./manipulador_ref --help\033[00m' para mas información."
        else
            agregar_ref $2 $3
        fi
        ;;
    -r | --remove)
        if [[ -z $2 ]]
        then
            echo "ERROR: No has ingresado ningun parámetro."
            echo "Intenta '\033[1m./manipulador_ref --help\033[00m' para mas información."
        else
            eliminar_ref $2
        fi
        ;;
    -p | --print)
        imprimir_ref
        ;;
    -c | --change)
        if [[ -z $2 ]] && [[ -z $3 ]]
        then
            echo "ERROR: No has ingresado ningun parámetro."
            echo "Intenta '\033[1m./manipulador_modulos --help\033[00m' para mas información."
        else
            cambiar_permisos $2 $3
        fi
        ;;
    *)
        echo "ERROR: Opción no válida." 
        echo "Intenta '\033[1m./manipulador_modulos --help\033[00m' para mas información."
        ;;
esac

