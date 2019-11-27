#!/bin/bash

# config
source ./config.sh
# NOTE: CURRENT MAX SEEMS TO BE 1000
RECORDS=1000
FILENAME=`date -u +%Y%m%d%H%M%S`
ENDDATE=`date -u +%s`
# get the max id and load everything after that
QUERY="SELECT MAX(created_utc) FROM \`$PROJECT.$DATASET.$TABLE\` LIMIT 1"
MAXDATE=`bq query --use_legacy_sql=false --format=json $QUERY | jq -c '.[].f0_' | tr -d "\""`
echo "VARIABLES LOADED... ENTERING LOOP"
# fetch the next batch of records
while [ $MAXDATE -lt $ENDDATE ]; do
  wget "http://api.pushshift.io/reddit/search/comment/?q=$QSTRING&after=$MAXDATE&before=$ENDDATE&sort_type=created_utc&sort=asc&size=$RECORDS" -O - \
  | jq -c "del(.data[].media_metadata)|.data[]" > $FILENAME.json

  # load the records into our newly created table
  bq load --source_format=NEWLINE_DELIMITED_JSON \
  $PROJECT:$DATASET.$TABLE $FILENAME.json

  CURLINES=`wc -l < $FILENAME.json`
  if [ "$CURLINES" -lt "$RECORDS" ]
  then
    echo "MADE IT"
    rm $FILENAME.json
    break
  else
    echo "STILL GOING"
    MAXDATE=`bq query --use_legacy_sql=false --format=json $QUERY | jq -c '.[].f0_' | tr -d "\""`
  fi
  rm $FILENAME.json
done
