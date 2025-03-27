#!/bin/bash


helm install dynatrace-operator oci://public.ecr.aws/dynatrace/dynatrace-operator --create-namespace --namespace dynatrace --atomic



# Deploy a dynakube file and restart tomcat and it will have this issue
#Node JS Version nok
#kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1

kubectl run tomcat --image=tomcat:latest --port=8080 --dry-run=client -o yaml | kubectl apply -f -

# curl -sS https://webinstall.dev/k9s | bash
