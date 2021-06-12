#!/usr/bin/env bash

kubectl delete vs web-frontend customers
kubectl delete svc web-frontend customers
kubectl delete deploy web-frontend customers-v1
kubectl delete gateway gateway
