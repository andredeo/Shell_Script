#!/bin/bash

#################################################################################
# Definicao de variaveis de trabalho                                            #
# Leia atentamente essa secao e                                                 #
# Realize as alteracoes necessarias                                             #
#################################################################################

# O script funciona no modo passagem de parametro ou valor fixo
# "-m 0" = Valores Fixos
# "-m 1" = Passagem de parametro

# Defina aqui o arquivo de origem
# Ele so sera usado no modo valor fixo
sourcefile="/Scripts/BEJobFullZabbix.csv"

# O script esta preparado para duas situacoes em relacao ao arquivo .csv
# "-d 0" = O arquivo nao termina em ","
# "-d 1" = O arquivo termina em ","

#################################################################################
# NAO ALTERE DESSE PONTO EM DIANTE                                              #
# A MENOS QUE SAIBA O QUE ESTA FAZENDO                                          #
#################################################################################

#################################################################################
# Checagem de dependencias							#
#################################################################################

# Tenta executar o comando
jq >/dev/null 2>&1

# Armazena o codigo de retorno do comando anterior
dependencia=`echo $?`

# Verifica a depencia e exibe a mensagem apropriada, se necessario
if [ "$dependencia" -ne 2 ]
then
	clear
	echo 'DEPENDENCIA NAO LOCALIZADA: jq
Utilize o gerenciador de pacotes de sua distribuicao
para resolver a dependencia. Por exemplo:
Debian/Ubuntu:
	$ sudo apt-get -y install jq
Red Hat/CentOS/Fedora:
	$ sudo yum -y install jq'
	exit
fi

#################################################################################
# Definicao das Funcoes								#
#################################################################################
help() {
clear
echo "Uso: $0 [opcoes]

OPCOES:
-h	Exibe o help do script
-m	Modo de operacao do Script:
	-m 0 = Valor Fixo: Busca o arquivo de origem dentro
	da configuracao do script
	-m 1 = Passagem de parametro: Espera receber o arquivo de origem
	por passagem de parametro
-f	Localizacao do arquivo de origem
-d	Delimitador:
	-d 0 = O arquivo nao termina em ","
	-d 1 = O arquivo termina em ","

EXEMPLOS DE USO:
$0 -h				Exibe o help do script
$0 -m 0 -d 0			Script em modo fixo; O arquivo nao termina em \",\"
$0 -m 1 -f <arquivo> -d 1		Script em modo dinamico; Arquivo de origem informado
						na opcao -f; O arquivo termina em \",\""
exit
}

# Checa os parametros passados para o script
checkInput() {

# Verificando se foi passado algum parametro
if [ "$#" -eq 0 ] 
then
	echo "Uso: $0 -h"
	exit
fi

# Obtendo os parametros e identificando as opcoes
while getopts "hm:f:d:" OPT ; do
	case "${OPT}" in
		h) help ;;
		m) mode="$OPTARG" ;;
		f) sourcefile="$OPTARG" ;;
		d) delimitador="$OPTARG" ;;
		*) help
		   exit ;;
	esac
done

}

#################################################################################
# Chamada da Funcao checkInput							#
#################################################################################
checkInput $1 $2 $3 $4 $5 $6 $7 $8 $9

#################################################################################
# Validacao dos Parametros Passados para o Script				#
#################################################################################
if [ "$mode" -eq 0 ] 2> /dev/null
then
	echo "Script em modo fixo"
	chave=0
else
	if [ "$mode" -eq 1 ] 2> /dev/null
	then
		echo "Script em modo dinamico"
		chave=1
	else
		echo "Opcao invalida para \"-m\", utilize \"-m 0\" ou \"-m 1\""
		exit
	fi
fi

if [ ! -s $sourcefile ]
then
	echo "Arquivo nao existe ou nao possui conteudo"
	exit
else
	if [ ! -r $sourcefile ]
	then
		echo "Usuario sem privilegio de leitura no arquivo"
		exit
	fi
fi

if [ "$delimitador" -eq 0 ] 2> /dev/null
then
        echo "O arquivo nao termina em \",\""
        delimitador=0
else
	if [ "$delimitador" -eq 1 ] 2> /dev/null
        then
        	echo "O arquivo termina em \",\""
                delimitador=1
        else
        	echo "Opcao invalida para \"-d\", utilize \"-d 0\" ou \"-d 1\""
        fi
fi

##
## FASE DE TESTES ##
##
echo $sourcefile
echo $chave
