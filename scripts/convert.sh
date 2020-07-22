#!/bin/bash
IFS=$'\n\t'
set -euo pipefail

MAPPINGS="../../src-gen/*.r2rml.ttl"
OUTFILES="../../output/*.nq"

curl https://cloudbox.netage.nl/f/d4dc98e723734c89a9ab/?dl=1 -L -o ldf-exec.zip
unzip ldf-exec.zip
cd ldf-exec
chmod +x linkeddatafactory.sh

echo "db.url=$SQL_URL" >> r2rml.properties
echo "db.login=$SQL_USERNAME" >> r2rml.properties
echo "db.password=$SQL_PASSWORD" >> r2rml.properties
echo "db.driver=com.microsoft.sqlserver.jdbc.SQLServerDriver" >> r2rml.properties

mkdir ../../output/

for mapping in $MAPPINGS
do
  ./linkeddatafactory.sh -m $mapping -o ../../output/$(basename $mapping).nq
done

curl -X DELETE $SPARQL_GRAPH_STORE -L

for output in $OUTFILES
do
  curl -X POST -T $output -H "Content-Type: application/n-quads" $SPARQL_GRAPH_STORE -L
done
