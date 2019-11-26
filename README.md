# okboomer

These scripts will load data from the pushshift.io API for reddit comments into BigQuery.  By default it's set up to pull comments that have the string "ok boomer" in them.  The scripts can easily be modified to pull in different comments.  

## Prepare

You must have `bq`, `jq`, `wget` and `bash` installed.  In the script set the values for `ENDDATE`, `PROJECT`, `DATASET` and `TABLE`.  Note that dataset must already exist.  Table will be destroyed without backing up - be sure that you put in a new table name or one you are okay with losing.  

## Initialize

```
chmod 755 initialize.sh
./initialize.sh
```
This will load all records up to the ENDDATE in the script.  Good for first-time loads.  

## Refresh

On a recurring basis, you can run the `refresh.sh` script to pull in any new records since the latest record in your database.  
