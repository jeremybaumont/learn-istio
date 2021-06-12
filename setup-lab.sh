#!/usr/bin/env zsh 
set -e

echo "Deleting any kind clusters..."
kind delete clusters --all

echo "Setting kernel parameter... net/netfilter/nf_conntrack_max"
sudo sysctl -w net.netfilter.nf_conntrack_max=393216

echo "Installing kubernetes cluster..."
kind create cluster --name istio-lab --config kind-istio-lab.yaml 

echo "Setting cluster info context..."
kubectl cluster-info --context kind-istio-lab

echo "Checking kubernetes pods status..."
sleep 2
kubectl get pods -n kube-system

echo "Initialising istio operator..."
istioctl operator init

echo "Installing istio operator"
kubectl apply -f istio-operator.yaml

echo "Checking istios pods status..."
sleep 2
kubectl get pods -n istio-system

echo "Enabling istio sidecar injection on default namespace..."
kubectl label namespace default istio-injection=enabled

echo "Installing shpod kubernetes objects/pods... and enabling sidecar injection on shpod namespace..."
kubectl label namespace shpod istio-injection=enabled
kubectl apply -f shpod.yaml
