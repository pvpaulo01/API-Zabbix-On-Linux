#!/bin/bash
ARQUIVO="CaminhoArquivo.csv"
TOKEN="<TokenAPI>"
URL="http://<URLAPIZABBIX>"
while IFS="," read -r hosts ip community porta grupo; do
IDGRUPOS=$(curl --request POST  \
     --url "$URL"\
     --header 'Content-Type: application/json-rpc'\
     --data '{
            "jsonrpc": "2.0",
            "method": "hostgroup.get",
            "params": {
                "output": "extend",
                "filter": {
                "name": [
                "'"$grupo"'"
                ]
                }
            },
            "auth": "'"${TOKEN}"'",
            "id": 1
        }' | sed -n 's/.*"groupid":"\([^"]*\)".*/\1/p')
echo " o ID do Grupo: $grupo é :$IDGRUPOS"
done < "$ARQUIVO"

