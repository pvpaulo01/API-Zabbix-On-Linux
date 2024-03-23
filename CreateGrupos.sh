#!/bin/bash
ARQUIVO="CaminhoArquivo.csv"
TOKEN="<TokenAPI>"
URL="http://<URLAPIZABBIX>"
while IFS="," read -r Grupos; do
curl --request POST \
        --url "$URL" \
        --header 'Content-Type: application/json-rpc' \
        --data '{
            "jsonrpc": "2.0",
            "method": "hostgroup.create",
            "params": {
		"name": "'"${Grupos}"'"
            },
            "auth": "'"${TOKEN}"'",
            "id": 1
        }'
echo ""
echo " Grupo: $Grupos Criado com sucesso!!"
done < "$ARQUIVO"

