# okboomer

These scripts will load data from the pushshift.io API for reddit comments into BigQuery.  By default it's set up to pull comments that have the string "ok boomer" in them.  The scripts can easily be modified to pull in different comments.  

## Prepare

You must have `bq`, `jq`, `wget` and `bash` installed.  In the `config.sh` script set the values for `ENDDATE`, `PROJECT`, `DATASET` and `TABLE`.  Note that dataset must already exist.  Table will be destroyed without backing up - be sure that you put in a new table name or one you are okay with losing.  

## Initialize

```
chmod 755 initialize.sh
./initialize.sh
```
This will load all records up to the ENDDATE in the script.  Good for first-time loads.  

## Refresh

On a recurring basis, you can run the `refresh.sh` script to pull in any new records since the latest record in your database.  

## Docker

You can run this with the attached docker image and a service user.  You'll need to install docker first of course, and create a service user.  Take the json file generated during service user creation, rename it to `secret.json` and place it in the `secret` folder of this project.  Now you are ready to run.  First build the docker image (don't forget to copy the '.' at the end of the command).  
```
docker build -t boomeretl .
```
Next you'll need to run but you have to authenticate as part of the command.
```
docker run --entrypoint bash boomeretl \
  -c "gcloud auth activate-service-account --key-file /usr/src/app/secret/secret.json && \
        ./refresh.sh"
```
This should run the refresh script on any system that is docker-enabled.  
