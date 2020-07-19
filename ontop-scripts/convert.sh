#!/bin/bash
IFS=$'\n\t'
set -euo pipefail

if [ -d "./ontop" ]
then
  echo "ontop has already been installed"
else
  # install ontop
  mkdir ontop
  cd ontop
  wget https://github.com/ontop/ontop/releases/download/ontop-4.0.0-rc-1/ontop-cli-4.0.0-rc-1.zip
  unzip ontop-cli-4.0.0-rc-1.zip
  cd ..
fi

# download sql driver
wget https://github.com/microsoft/mssql-jdbc/releases/download/v8.2.2/mssql-jdbc-8.2.2.jre8.jar -P ontop/jdbc/

touch triples.nt
BEFORE=$(wc -l triples.nt)
./ontop/ontop materialize -m ../src-gen/mapping.r2rml.ttl -f ntriples -o ./triples.nt -p sql.properties

# show triples count before/after
AFTER=$(wc -l triples.nt)
echo "wc -l triples.nt BEFORE: $BEFORE"
echo "wc -l triples.nt AFTER:  $AFTER"
