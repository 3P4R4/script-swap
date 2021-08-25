#!/bin/bash

# scriptswap.sh
# Script para gestionar el uso de la memoria swap del sistema.

# Variables
estado=$(free -h)
valor=$(cat /proc/sys/vm/swappiness)

# Funciones

# Indicación de pausa de visualizacion
function pause(){
 local message="$@"
 echo
 [ -z $message ] && message="Presiona [Enter] para continuar..."
 read -p "$message" readEnterKey
}

# Mostrar un menu en pantalla
function show_menu(){
    date
    echo "------------------------------------------------------"
    echo "                   Menu Principal                     "
    echo "------------------------------------------------------"
    echo
    echo "1. Ver estado de uso de la RAM y Swap"
    echo "2. Ver valor de swapiness actual"
    echo "3. Deshabilitar el uso de la swap"
    echo "4. Habilitar el uso de la swap"
    echo "5. Trasladar datos de la swap a la RAM"
    echo "6. Modificar el valor de swappiness para la sesión"
    echo "7. Modificar valor de swapiness de forma persistente"
    echo "8. Salir"
}

# Mostrar mensaje de cabecera
function write_header(){
 local h="$@"
 echo "---------------------------------------------------------------"
 echo "     ${h}"
 echo "---------------------------------------------------------------"
}

# Ver estado de uso de RAM y Swap
function uso_memoria(){
write_header " Información del  uso de la memoria"
 echo "El uso de RAM y swap es:"
 echo
 echo "$estado"
 pause
}

# Ver valor de swapiness actual
function val_swappiness(){
write_header " Valor actual de swappiness"
 echo "El valor actual de swappines es:"
 cat /proc/sys/vm/swappiness
 pause
}

# Deshabilitar el uso de la swap
function swap_off(){
write_header " Deshabilitando el uso de la memoria swap"
 sudo swapoff -a
 sleep 3
 echo
 echo "Deshabilitado el uso de la swap"
uso_memoria
}

# Habilitar el uso de la swap
function swap_up(){
write_header " Habilitando el uso de la memoria swap"
 sudo swapon -a
 sleep 3
 echo
 echo "Habilitado el uso de la swap"
uso_memoria
}

# Trasladar datos de la Swap a RAM
function swap_on(){
write_header " Trasladando los datos de la swap a la RAM"
 sudo swapoff -a ; sudo swapon -a
 sleep 3
 echo
 echo "Trasladados los datos de la swap a la RAM con éxito"
 uso_memoria
}

# Modificar el valor swapiness en la sesión actual
function swappiness_ses(){
echo "                                                                   "
write_header "Vamos a modificar el valor swappiness para la sesión actual"
 echo "Cuanto mayor sea este valor, más tardará el sistema en usar la swap"
 echo "Introduce el valor que te interese (entre 0 y 100)"
read n
 numero=$(echo $n | grep "^[0-9]*$")
        if [ $numero ]
   then
          sudo sysctl vm.swappiness=$n
          echo "El nuevo valor de swapiness es :"
    cat /proc/sys/vm/swappiness
        else
          echo "El valor debe ser numérico y estar en el rango 0-100"
          exit 1
        fi
 pause
}

# Modificar el valor swapiness de forma persistente
function swappiness_per(){
write_header " Vamos a modificar el valor swapiness de forma persistente"
 echo "Se requieren privilegios de sudo y los cambios se aplicarán tras un reinicio"
 echo "Cuanto mayor sea este valor, más tardará el sistema en usar la swap"
 echo "Introduce el valor que te interese (entre 0 y 100)"
read n
 numero=$(echo $n | grep "^[0-9]*$")
  if [ $numero ]
    then
           sudo write "vm.swappiness=$n"  >> /etc/sysctl.conf
           val_swappiness
        else
           echo "El valor debe ser numérico y estar en el rango 0-100"
        fi
# pause
}

# Obtener entrada por teclado y elegir opción
function read_input(){
 local c
 echo
 read -p "Elige una opción [ 1 - 8 ] " c
 case $c in
  1) uso_memoria ;;
  2) val_swappiness ;;
  3) swap_off  ;;
  4) swap_up ;;
  5) swap_on ;;
  6) swappiness_ses ;;
  7) swappiness_per ;;
  8) echo ; echo "    FINALIZADO EL PROGRAMA." ; echo ; echo " Vigila la estabilidad del sistema!" ; exit 0 ;;
  *)
   echo "Seleccione una sola opción entre 1 to 8."
   pause
 esac
}

# Programa principal
while true
do
 clear
  show_menu # mostrar memu
  read_input  # esperar la entrada del usuario
done