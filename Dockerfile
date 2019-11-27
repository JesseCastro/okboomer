FROM google/cloud-sdk:alpine
WORKDIR /usr/src/app
RUN ls
# COPY FILES
COPY ./schema.json /usr/src/app/
COPY ./refresh.sh /usr/src/app/
COPY ./secret/ /usr/src/app/secret

# INSTALL NEEDED TOOLS
RUN apk --no-cache --update-cache add jq

# Env vars
ENV GOOGLE_APPLICATION_CREDENTIALS="/usr/src/app/secret/secret.json"
ENV CLOUDSDK_PYTHON_SITEPACKAGES=1

# BQ Init - run through .bqconfig script.
RUN gcloud auth activate-service-account --key-file /usr/src/app/secret/secret.json && bq query "SELECT 1"


# build it
# docker build -t boomeretl .
# run it
# run from command line with
#docker run --entrypoint bash boomeretl \
#  -c "gcloud auth activate-service-account --key-file /usr/src/app/secret/secret.json && \
#        ./refresh.sh"
