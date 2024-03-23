#!/bin/bash

# Script para criar hosts no Zabbix a partir de um arquivo CSV
# Data de Criação: 23/03/2024
# Autor: Paulo Victor de Oliveira Moraes
#
# Este script lê um arquivo CSV contendo informações sobre hosts
# e os adiciona ao Zabbix utilizando a API JSON-RPC.
# O arquivo CSV deve estar no formato:
# host,ip,community,porta,grupo
#
# Requisitos:
# - O arquivo CSV deve estar no seguinte formato:
#     host,ip,community,porta,grupo
# - A URL da API JSON-RPC do Zabbix deve estar definida na variável URL.
# - O token de autenticação da API deve estar definido na variável TOKEN.
#
# Exemplo de Uso:
#   ./criar_hosts_zabbix.sh 

#Criando as Variaveis necessárias para Manipulação por API do ZABBIX

ARQUIVO="CaminhoArquivo.csv"
TOKEN="<TokenAPI>"
URL="http://<URLAPIZABBIX>"

#Crieando um Laço de repedição para ler seu arquivo.csv . O mesmo irá ler cada Linha e criar as Variavels necessárias
#Obs: lembrando que o Linux é : "case sensitive" portanto lembrese de criar seu cvs e as colunas com os mesmo nome especificado no comando read abaixo.
#Obs: Lembrando que qualquer comentário nas linhas do Json é para melhor compreensão recomendo remove-los ao usar em seu ambiente.

while IFS="," read -r host ip community porta grupo; do
    # Obtendo o ID do grupo
    IDGRUPO=$(curl --request POST \
        --url "$URL" \
        --header 'Content-Type: application/json-rpc' \
        --data '{
            "jsonrpc": "2.0",
            "method": "hostgroup.get",
            "params": {
                "output": "extend",
                "filter": {
                    "name": ["'"$grupo"'"]
                }
            },
            "auth": "'"$TOKEN"'",
            "id": 1
        }' | sed -n 's/.*"groupid":"\([^"]*\)".*/\1/p')
    # Criando o host no Zabbix  e adicionando no respectivo grupo filtrado acima
    # Cada Host irá ser criado com o Template padrão : Template Module ICMP Ping

    curl --request POST \
        --url "$URL" \
        --header 'Content-Type: application/json-rpc' \
        --data '{
            "jsonrpc": "2.0",
            "method": "host.create",
            "params": {
                "host": "'"$host"'",
                "status": 1,
                "interfaces": [
                    {
                        "type": 1,
                        "main": 1,
                        "useip": 1,
                        "ip": "'"$ip"'",
                        "dns": "8.8.8.8",
                        "port": "'"$porta"'"
                    }
                ],
                "groups": [
                    {
                        "groupid": "'"$IDGRUPO"'"
                    }
                ],
                "templates": [
                    {
                        "templateid": "10564" # Template Module ICMP Ping
                    }
                ]
            },
            "auth": "'"$TOKEN"'",
            "id": 1
        }'
    echo ""
    echo "Maquina: $host IP: $ip Grupo: $grupo"
done < "$ARQUIVO"

