#!/usr/bin/env bash


kind create cluster --name istio-lab --config kind-istio-lab.yaml 

export PATH=istio-1.9.0/bin:$PATH 
istioctl operator init
kubectl apply -f demo-profile.yaml
kubectl label namespace default istio-injection=enabled
