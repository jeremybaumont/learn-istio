# Istio

Install a kind k8s cluster
```
kind create cluster --name istio-lab --config ./kind-istio-lab.yaml                                                      
```

Install istio
```
istioctl operator init
kubectl apply -f demo-profile.yaml
kubectl get po -n istio-system
kubectl label namespace default istio-injection=enabled
```
