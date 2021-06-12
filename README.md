# Istio

## Setup a quick lab

Setup a kubernetes with istio operator installed
```
./setup-lab.sh
```

## Directories

* tetrate-tetrate-fundamentals directory contains all the manifests from the public [Istio Tetrace fundamentals training](https://academy.tetrate.io/courses/certified-istio-administrator).
* envoy-config directory takes the same approach than [Istio: Up and Running](https://learning.oreilly.com/library/view/istio-up-and) to show some Istio configuration and the Envoy configuration it results in, highlight the main similarities, and outline how other changes to the same Istio configuration will manifest in Envoy so that we can test and see for ourself and use this knowledge to diagnose and solve the majority of Istio issues that we’ll come across. contains some manifests of istio objects and explain which envoy configuration is generated.

## Well-known issues

https://github.com/kubernetes/kubernetes/pull/44919

Before creating the kind cluster:
```sudo sysctl -w net/netfilter/nf_conntrack_max=393216``` 
