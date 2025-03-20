#!/bin/bash


helm install dynatrace-operator oci://public.ecr.aws/dynatrace/dynatrace-operator --create-namespace --namespace dynatrace --atomic



# Deploy a dynakube file and restart tomcat and it will have this issue

kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1
