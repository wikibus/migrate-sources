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

mkdir -p ../../output/

for mapping in $MAPPINGS
do
  echo "Converting $mapping"
  ./linkeddatafactory.sh -m $mapping -o ../../output/$(basename $mapping).nq
done

curl https://data.wikibus.org/sparql \
-XPOST \
-u $SPARQL_CREDENTIALS \
-H 'Content-Type: application/x-www-form-urlencoded' \
--data 'update=CLEAR%20%20default'

for output in $OUTFILES
do
  echo "Uploading $output"
  curl -X POST -T $output -H "Content-Type: text/turtle" -u $SPARQL_CREDENTIALS https://data.wikibus.org/data?default -L
done
