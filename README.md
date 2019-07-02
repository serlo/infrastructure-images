# infrastructure-images

Infrastructure Images are project independent docker images. The images are either built from a gcr.io base image or the github docker image is pulled and pushed to gcr.io.

## DBSetup

Builds a cronjob image from alpine base image and adds some logic to import the serlo database from a dump.
This image is used in Minikube as well as GCloud Dev and Staging.

## DBDump

Builds a cronjob image from alpine base image and adds some logic to save the serlo database as a dump.
This image is used in GCloud Prod to automate make the latest anonymized dump available for other envirnoments.

## Varnish

Builds a Varnish image from alpine base image.

## Grafana

Pulls and pushes the official Grafana images to gcr.io as gcr.io does not have usually the latest versions.
