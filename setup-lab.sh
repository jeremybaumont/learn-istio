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

for pod in $(kubectl get pods -n kube-system -o jsonpath='{.items[0].metadata.name}'); do
    while [[ $(kubectl get pods $pod -n kube-system -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do 
        sleep 3
        echo "Waiting for $pod to be ready."
    done
done

echo "Initialising istio operator..."
istioctl operator init

echo "Installing istio operator"
kubectl apply -f istio-operator.yaml
sleep 10

for pod in $(kubectl get pods -n istio-system -l app=istiod -o jsonpath='{.items[0].metadata.name}'); do
    while [[ $(kubectl get pods $pod -n istio-system -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do 
        sleep 3
        echo "Waiting for $pod to be ready."
    done
done

echo "Enabling istio sidecar injection on default namespace..."
kubectl label namespace default istio-injection=enabled

echo "Installing shpod kubernetes objects/pods... and enabling sidecar injection on shpod namespace..."
kubectl apply -f shpod-namespace.yaml
kubectl label namespace shpod istio-injection=enabled
kubectl apply -f shpod.yaml
