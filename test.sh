#!/usr/bin/env sh

kubectl delete crontabs --all --ignore-not-found=true
kubectl delete crd crontabs.stable.example.com --ignore-not-found=true
kubectl apply -f $@
sleep 3
kubectl explain crontab --recursive
