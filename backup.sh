#!/bin/bash

#Colours
green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"

function ctrl_c(){
echo -e "\n\n${red}[!] Saliendo...\n${end}"
tput cnorm; exit 1
}

# Ctrl+C
trap ctrl_c INT

function helpPanel(){
echo -e "\n${yellow}[+] Uso: $0${end}\n"
echo -e "\t${blue}-m) Dinero con el que se desea jugar${end}"
echo -e "\t${blue}-t) Técnica a utilizar${end} ${purple}(Martingala/InverseLabrouchere)${end}\n"

exit 1
}

function martingala(){
echo -e "\n${blue}[+] Dinero actual: $money€${end}"
echo -ne "\n${green}[+] ¿Cuánto dinero tienes pensado apostar? -> ${end}" && read initial_bet
echo -ne "\n${yellow}[+] ¿A qué deseas apostar (par/impar)? -> ${end}" && read par_impar

echo -e "\n${grey}[+] Vamos a jugar con una cantidad inicial de ${blue}$initial_bet€ a $par_impar${end}${end}"

backup_bet=$initial_bet
play_counter=1
jugadas_malas=""


echo -e "[+] Tienes ${green}$money€${end}"
tput civis
while true; do
  money=$(($money-$initial_bet))
  echo -e "\n${grey}[+] Acabas de apostar ${yellow}$initial_bet€${end} y tienes ${green}$money€${end}${end}"
  random_number="$((RANDOM % 37))"
  echo -e "[+] Ha salido el número ${green}$random_number${end}"
   
if [ ! "$money" -lt 0 ]; then

  if [ "$par_impar" == "par" ]; then #Par

  if [ "$(($random_number % 2))" -eq 0 ]; then
    if [ "$random_number" -eq 0 ]; then
      echo -e "${red}[+] Ha salido el 0, por tanto perdemos${end}"
      initial_bet=$(($initial_bet*2))
      jugadas_malas+="$random_number "
      echo -e "[+] Tienes ${green}$money€${end}"
    else
  echo -e "[+] ${green} El número que ha salido es par, ¡Ganas!${end}"
  reward=$(($initial_bet*2))
  echo -e "[+]Ganas ${turquoise}$reward€${end}"
  money=$(($money+$reward))
  echo -e "[+]Tienes ${green}$money€${end}"
  initial_bet=$backup_bet
  jugadas_malas=""
    fi
  else
  echo -e "[+]${red} El número que ha salido es impar, ¡Pierdes!${end}"
  initial_bet=$(($initial_bet*2))
  jugadas_malas+="$random_number "
  echo -e "[+] Tienes ${green}$money€${end}"
  fi

elif [ "$par_impar" == "impar" ]; then #Impar

  if [ "$(($random_number % 2))" -eq 1 ]; then
    if [ "$random_number" -eq 0 ]; then
      echo -e "${red}[+] Ha salido el 0, por tanto perdemos${end}"
      initial_bet=$(($initial_bet*2))
      jugadas_malas+="$random_number "
      echo -e "[+] Tienes ${green}$money€${end}"
    else
  echo -e "[+] ${green} El número que ha salido es impar, ¡Ganas!${end}"
  reward=$(($initial_bet*2))
  echo -e "[+]Ganas ${turquoise}$reward€${end}"
  money=$(($money+$reward))
  echo -e "[+]Tienes ${green}$money€${end}"
  initial_bet=$backup_bet
  jugadas_malas=""
    fi
  else
  echo -e "[+]${red} El número que ha salido es par, ¡Pierdes!${end}"
  initial_bet=$(($initial_bet*2))
  jugadas_malas+="$random_number "
  echo -e "[+] Tienes ${green}$money€${end}"
  fi
  fi
  #fi

else 
  #Nos quedamos a 0
  echo -e "\n${red}[!] Te has quedado a 0${end}\n"
  echo -e "${yellow}[+] Han habido un total de ${blue}$(($play_counter-1))${end} jugadas${end}"
  echo -e "\nA continuación se van a representar las malas jugadas consecutivas que han salido: \n"
  echo -e "${blue}[ $jugadas_malas]${end}"
  tput cnorm; exit 0
fi

let play_counter+=1
done

tput cnorm #Recuperamos cursor
}

function inverseLabrouchere(){

echo -e "\n${blue}[+] Dinero actual: $money€${end}"
echo -ne "\n${yellow}[+] ¿A qué deseas apostar (par/impar)? -> ${end}" && read par_impar

declare -a my_sequence=(1 2 3 4)

echo -e "\n${yellow}[+] Comenzamos con la secuencia ${green}[${my_sequence[@]}]${end}${end}"

bet=$((${my_sequence[0]} + ${my_sequence[-1]}))

#unset my_sequence[0]
#unset my_sequence[-1]

#my_sequence=(${my_sequence[@]})

jugadas_totales=0

tput civis
while true; do
  let jugadas_totales+=1
  random_number=$(($RANDOM %37))
  money=$(($money - $bet))
  if [ ! "$money" -lt 0 ]; then
      echo -e "[+] Invertimos $bet"
      echo -e "[+] Tenemos $money€"
      echo -e "\n[+] Ha salido el número ${blue}$random_number${end}"

      if [ "$par_impar" == "par" ]; then
        if [ "$(($random_number % 2))" -eq 0 ] && [ "$random_number" -ne 0 ]; then
        echo -e "${green}[+] El número es par, ¡Ganas!${end}"
        reward=$(($bet*2))
      let money+=$reward
      echo "[+] Tienes $money€ ahora"

      my_sequence+=($bet)
      my_sequence=(${my_sequence[@]})

      echo -e "[+] Nuestra nueva secuencia es ${blue}[${my_sequence[@]}]${end}"
      if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
      bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
    elif [ "${#my_sequence[@]}" -eq 1 ]; then
      bet=${my_sequence[0]}
    else
    echo -e "${red}[!] Hemos perdido nuestra secuencia${end}"
    my_sequence=(1 2 3 4)
    echo -e "${yellow}[+] Restablecemos la secuencia a [${my_sequence[@]}]${end}"
    bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
      fi
    #elif [ "$random_number" -eq 0 ]; then
    #echo  -e "${red}[+] El número es 0, ¡Pierdes!${end}"

    elif [ "$((random_number % 2))" -eq 1 ] || [ "$random_number" -eq 0 ]; then
      if [ "$((random_number % 2))" -eq 1 ]; then
    echo  -e "${red}[+] El número es impar, ¡Pierdes!${end}"
    else
    echo  -e "${red}[+] El número es 0, ¡Pierdes!${end}"
      fi
    unset my_sequence[0]
    unset my_sequence[-1] 2>/dev/null
    my_sequence=(${my_sequence[@]})

    echo -e "[+] La sequencia se nos queda: ${blue}[${my_sequence[@]}]${end}"

     if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
      bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
    elif [ "${#my_sequence[@]}" -eq 1 ]; then
      bet=${my_sequence[0]}
    else
    echo -e "${red}[!] Hemos perdido nuestra secuencia${end}"
    my_sequence=(1 2 3 4)
    echo -e "${yellow}[+] Restablecemos la secuencia a [${my_sequence[@]}]${end}"
    bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
     fi
      fi

    fi
  else
  #Nos quedamos a 0
  echo -e "\n${red}[!] Te has quedado a 0${end}\n"
  echo -e "${turquoise}[+] En total ha habido $jugadas_totales jugadas${end}\n"
  tput cnorm; exit 1

  fi

sleep 1
done

tput cnorm

}

while getopts "m:t:h" arg; do
case $arg in 
    m) money=$OPTARG;;
    t) technique=$OPTARG;;
    h) helpPanel;;
esac
done

if [ $money ] && [ $technique ]; then
  if [ "$technique" == "martingala" ]; then
martingala
elif [ "$technique" == "inverseLabrouchere" ]; then
inverseLabrouchere
else
echo -e "\n${red}[!] La técnica a utilizar no existe${end}"
helpPanel
  fi
else 
  helpPanel
fi 
