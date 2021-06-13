#!/usr/bin/env zsh 
set -e

echo "Deleting any kind clusters..."
kind delete clusters --all

echo "Setting kernel parameter... net/netfilter/nf_conntrack_max"
sudo sysctl -w net.netfilter.nf_conntrack_max=${1:-393216}

echo "Installing kubernetes cluster..."
kind create cluster --name istio-lab --config kind-istio-lab.yaml 

echo "Setting cluster info context..."
kubectl cluster-info --context kind-istio-lab

echo "Checking kubernetes pods status..."
sleep 10 
kubectl get pods -n kube-system

echo "Installing metallb..."
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/metallb.yaml

echo "Checking kubernetes pods status..."
sleep  5 
kubectl get pods -n kube-system

echo "Initialising istio operator..."
istioctl operator init

echo "Installing istio operator"
kubectl apply -f istio-operator.yaml

echo "Checking istios pods status..."
sleep 15 
kubectl get pods -n istio-system

echo "Enabling istio sidecar injection on default namespace..."
kubectl label namespace default istio-injection=enabled

echo "Installing shpod kubernetes objects/pods... and enabling sidecar injection on shpod namespace..."
kubectl apply -f shpod.yaml
kubectl label namespace shpod istio-injection=enabled
kubectl delete po shpod -n shpod
kubectl apply -f shpod.yaml


