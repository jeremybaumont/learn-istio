# Envoy Config

In this directory, we the same approach than [Istio: Up and Running](https://learning.oreilly.com/library/view/istio-up-and) to show some Istio configuration and the Envoy configuration it results in, highlight the main similarities, and outline how other changes to the same Istio configuration will manifest in Envoy so that we can test and see for ourself and use this knowledge to diagnose and solve the majority of Istio issues that we’ll come across. contains some manifests of istio objects and explain which envoy configuration is generated.


On ingressgateway pod the listneres and clusters looks like the following:
```
~/code/learn/istio/envoy-config > ipc listeners $(kubectl -n istio-system get pod -l istio=ingressgateway -o jsonpath='{.items[0].metadata.name}')
-n istio-system
ADDRESS PORT  MATCH DESTINATION
0.0.0.0 15021 ALL   Inline Route: /healthz/ready*
0.0.0.0 15090 ALL   Inline Route: /stats/prometheus*

~/code/learn/istio/envoy-config > ipc clusters $(kubectl -n istio-system get pod -l istio=ingressgateway -o jsonpath='{.items[0].metadata.name}') -n istio-system
SERVICE FQDN                                            PORT      SUBSET     DIRECTION     TYPE           DESTINATION RULE
BlackHoleCluster                                        -         -          -             STATIC
agent                                                   -         -          -             STATIC
istio-egressgateway.istio-system.svc.cluster.local      80        -          outbound      EDS
istio-egressgateway.istio-system.svc.cluster.local      443       -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local     80        -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local     443       -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local     15021     -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local     15443     -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local     31400     -          outbound      EDS
istio-operator.istio-operator.svc.cluster.local         8383      -          outbound      EDS
istiod.istio-system.svc.cluster.local                   443       -          outbound      EDS
istiod.istio-system.svc.cluster.local                   15010     -          outbound      EDS
istiod.istio-system.svc.cluster.local                   15012     -          outbound      EDS
istiod.istio-system.svc.cluster.local                   15014     -          outbound      EDS
kube-dns.kube-system.svc.cluster.local                  53        -          outbound      EDS
kube-dns.kube-system.svc.cluster.local                  9153      -          outbound      EDS
kubernetes.default.svc.cluster.local                    443       -          outbound      EDS
prometheus_stats                                        -         -          -             STATIC
sds-grpc                                                -         -          -             STATIC
xds-grpc                                                -         -          -             STATIC
zipkin                                                  -         -          -             STRICT_DNS
```



On shpod pod the listeners on itio-proxy looks like the following:
```
~/code/learn/istio/envoy-config > ipc listeners shpod -n shpod | awk 'NR<2{print $0;next}{print $0| "sort -r"}'                                                                                                                                                                     
ADDRESS       PORT  MATCH                                                                    DESTINATION
10.96.88.153  443   ALL                                                                      Cluster: outbound|443||istio-egressgateway.istio-system.svc.cluster.local
10.96.151.255 443   ALL                                                                      Cluster: outbound|443||istio-ingressgateway.istio-system.svc.cluster.local
10.96.151.255 31400 ALL                                                                      Cluster: outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local
10.96.151.255 15443 ALL                                                                      Cluster: outbound|15443||istio-ingressgateway.istio-system.svc.cluster.local
10.96.151.255 15021 Trans: raw_buffer; App: HTTP                                             Route: istio-ingressgateway.istio-system.svc.cluster.local:15021
10.96.151.255 15021 ALL                                                                      Cluster: outbound|15021||istio-ingressgateway.istio-system.svc.cluster.local
10.96.10.70   443   ALL                                                                      Cluster: outbound|443||istiod.istio-system.svc.cluster.local
10.96.10.70   15012 ALL                                                                      Cluster: outbound|15012||istiod.istio-system.svc.cluster.local
10.96.0.1     443   ALL                                                                      Cluster: outbound|443||kubernetes.default.svc.cluster.local
10.96.0.10    9153  Trans: raw_buffer; App: HTTP                                             Route: kube-dns.kube-system.svc.cluster.local:9153
10.96.0.10    9153  ALL                                                                      Cluster: outbound|9153||kube-dns.kube-system.svc.cluster.local
10.96.0.10    53    ALL                                                                      Cluster: outbound|53||kube-dns.kube-system.svc.cluster.local
0.0.0.0       8383  Trans: raw_buffer; App: HTTP                                             Route: 8383
0.0.0.0       8383  ALL                                                                      PassthroughCluster
0.0.0.0       80    Trans: raw_buffer; App: HTTP                                             Route: 80
0.0.0.0       80    ALL                                                                      PassthroughCluster
0.0.0.0       15090 ALL                                                                      Inline Route: /stats/prometheus*
0.0.0.0       15021 ALL                                                                      Inline Route: /healthz/ready*
0.0.0.0       15014 Trans: raw_buffer; App: HTTP                                             Route: 15014
0.0.0.0       15014 ALL                                                                      PassthroughCluster
0.0.0.0       15010 Trans: raw_buffer; App: HTTP                                             Route: 15010
0.0.0.0       15010 ALL                                                                      PassthroughCluster
0.0.0.0       15006 Trans: tls; App: TCP TLS; Addr: ::0/0                                    InboundPassthroughClusterIpv6
0.0.0.0       15006 Trans: tls; App: TCP TLS; Addr: 0.0.0.0/0                                InboundPassthroughClusterIpv4
0.0.0.0       15006 Trans: tls; App: istio-http/1.0,istio-http/1.1,istio-h2; Addr: ::0/0     InboundPassthroughClusterIpv6
0.0.0.0       15006 Trans: tls; App: istio-http/1.0,istio-http/1.1,istio-h2; Addr: 0.0.0.0/0 InboundPassthroughClusterIpv4
0.0.0.0       15006 Trans: tls; Addr: ::0/0                                                  InboundPassthroughClusterIpv6
0.0.0.0       15006 Trans: tls; Addr: 0.0.0.0/0                                              InboundPassthroughClusterIpv4
0.0.0.0       15006 Trans: raw_buffer; App: HTTP; Addr: ::0/0                                InboundPassthroughClusterIpv6
0.0.0.0       15006 Trans: raw_buffer; App: HTTP; Addr: 0.0.0.0/0                            InboundPassthroughClusterIpv4
0.0.0.0       15006 Trans: raw_buffer; Addr: ::0/0                                           InboundPassthroughClusterIpv6
0.0.0.0       15006 Trans: raw_buffer; Addr: 0.0.0.0/0                                       InboundPassthroughClusterIpv4
0.0.0.0       15006 Addr: *:15006                                                            Non-HTTP/Non-TCP
0.0.0.0       15001 ALL                                                                      PassthroughCluster
0.0.0.0       15001 Addr: *:15001                                                            Non-HTTP/Non-TCP



~/code/learn/istio/envoy-config > ipc cluster shpod -n shpod | awk 'NR<2{print $0;next}{print $0| "sort -r"}'                                                                                                                                                                       
SERVICE FQDN                                            PORT      SUBSET     DIRECTION     TYPE             DESTINATION RULE
zipkin                                                  -         -          -             STRICT_DNS
xds-grpc                                                -         -          -             STATIC
sds-grpc                                                -         -          -             STATIC
prometheus_stats                                        -         -          -             STATIC
PassthroughCluster                                      -         -          -             ORIGINAL_DST
kubernetes.default.svc.cluster.local                    443       -          outbound      EDS
kube-dns.kube-system.svc.cluster.local                  9153      -          outbound      EDS
kube-dns.kube-system.svc.cluster.local                  53        -          outbound      EDS
istio-operator.istio-operator.svc.cluster.local         8383      -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local     80        -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local     443       -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local     31400     -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local     15443     -          outbound      EDS
istio-ingressgateway.istio-system.svc.cluster.local     15021     -          outbound      EDS
istio-egressgateway.istio-system.svc.cluster.local      80        -          outbound      EDS
istio-egressgateway.istio-system.svc.cluster.local      443       -          outbound      EDS
istiod.istio-system.svc.cluster.local                   443       -          outbound      EDS
istiod.istio-system.svc.cluster.local                   15014     -          outbound      EDS
istiod.istio-system.svc.cluster.local                   15012     -          outbound      EDS
istiod.istio-system.svc.cluster.local                   15010     -          outbound      EDS
InboundPassthroughClusterIpv6                           -         -          -             ORIGINAL_DST
InboundPassthroughClusterIpv4                           -         -          -             ORIGINAL_DST
BlackHoleCluster                                        -         -          -             STATIC
agent                                                   -         -          -             STATIC
```


