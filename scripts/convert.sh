#!/bin/bash
IFS=$'\n\t'
set -euo pipefail

curl https://cloudbox.netage.nl/f/d11919273c184226be77/?dl=1 -L -o ldf-exec.zip
unzip ldf-exec.zip
cd ldf-exec
chmod +x linkeddatafactory.sh

echo "db.url=$SQL_URL" >> r2rml.properties
echo "db.login=$SQL_USERNAME" >> r2rml.properties
echo "db.password=$SQL_PASSWORD" >> r2rml.properties
echo "db.driver=com.microsoft.sqlserver.jdbc.SQLServerDriver" >> r2rml.properties


./linkeddatafactory.sh \
  -m ../../src-gen/mappings.r2rml.ttl \
  -o ./triples.nq

curl -X PUT -T ./triples_1.nq -H "Content-Type: application/n-quads" $SPARQL_GRAPH_STORE -L
