#!/bin/bash

# config
source ./config.sh
FILENAME=`date -u +%Y%m%d%H%M%S`

# remove the table if it exists
bq rm -f -t $PROJECT:$DATASET.$TABLE

# extract the first 10k records from 2019-01-01 onward
wget "http://api.pushshift.io/reddit/search/comment/?q=$QSTRING&after=$STARTDATE&before_=$ENDDATE&sort_type=created_utc&sort=asc&size=10000" -O - \
| jq -c "del(.data[].media_metadata)|.data[]" > $FILENAME.json

# make the table with our json schema file.
bq mk --table --description 'ok boomer data' $PROJECT:$DATASET.$TABLE ./schema.json

# load the records into our newly created table
bq load --source_format=NEWLINE_DELIMITED_JSON \
$PROJECT:$DATASET.$TABLE $FILENAME.json

# get the max id and load everything after that
QUERY="SELECT MAX(created_utc) FROM \`$PROJECT.$DATASET.$TABLE\` LIMIT 1"
MAXDATE=`bq query --use_legacy_sql=false --format=json $QUERY | jq -c '.[].f0_' | tr -d "\""`
echo $MAXDATE

rm $FILENAME.json

# fetch the next batch of records
while [ $MAXDATE -le $ENDDATE ]; do
  wget "http://api.pushshift.io/reddit/search/comment/?q=$QSTRING&after=$MAXDATE&sort_type=created_utc&sort=asc&size=10000" -O - \
  | jq -c "del(.data[].media_metadata)|.data[]" > $FILENAME.json

  # load the records into our newly created table
  bq load --source_format=NEWLINE_DELIMITED_JSON \
  $PROJECT:$DATASET.$TABLE $FILENAME.json

  MAXDATE=`bq query --use_legacy_sql=false --format=json $QUERY | jq -c '.[].f0_' | tr -d "\""`
  echo $MAXDATE

  rm $FILENAME.json
done
