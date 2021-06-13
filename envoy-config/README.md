# Envoy Config

In this directory, we the same approach than [Istio: Up and Running](https://learning.oreilly.com/library/view/istio-up-and) to show some Istio configuration and the Envoy configuration it results in, highlight the main similarities, and outline how other changes to the same Istio configuration will manifest in Envoy so that we can test and see for ourself and use this knowledge to diagnose and solve the majority of Istio issues that we’ll come across. contains some manifests of istio objects and explain which envoy configuration is generated.

## Ingress gateway
On the istio-ingressgateway pod the listeners and clusters looks like the following:
```
~/code/learn/istio/envoy-config > ipc listeners $(kubectl -n istio-system get pod -l istio=ingressgateway -o jsonpath='{.items[0].metadata.name}') -n istio-system

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



On shpod pod the listeners on itio-proxy pod container looks like the following:
```
~/code/learn/istio/envoy-config > ipc listeners shpod -n shpod | awk 'nr<2{print $0;next}{print $0| "sort -r"}'                                                                                                                                                                     
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

## Gateway

When we apply the following gateway `foo-com-gateway`
```
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: foo-com-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - hosts:
    - "*.foo.com"
    port:
      number: 80
      name: http
      protocol: HTTP
```

### Physical Listener - Basic HTTP Port

It creates a physical listener on the istio-ingressgateway istio-proxy pod container on port 8080 and a route named `http.80`:
```
~/code/learn/istio/envoy-config > ipc listeners $(kubectl -n istio-system get pod -l istio=ingressgateway -o jsonpath='{.items[0].metadata.name}') -n istio-system 

ADDRESS PORT  MATCH DESTINATION
0.0.0.0 8080  ALL   Route: http.80
0.0.0.0 15021 ALL   Inline Route: /healthz/ready*
0.0.0.0 15090 ALL   Inline Route: /stats/prometheus*
```

```
~/code/learn/istio/envoy-config > ipc listeners $(kubectl -n istio-system get pod -l istio=ingressgateway -o jsonpath='{.items[0].metadata.name}') -n istio-system --port 8080 -o yaml    
- accessLog:
  - filter:
      responseFlagFilter:
        flags:
        - NR
    name: envoy.access_loggers.file
    typedConfig:
      '@type': type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
      logFormat:
        textFormat: |
          [%START_TIME%] "%REQ(:METHOD)% %REQ(X-ENVOY-ORIGINAL-PATH?:PATH)% %PROTOCOL%" %RESPONSE_CODE% %RESPONSE_FLAGS% %RESPONSE_CODE_DETAILS% %CONNECTION_TERMINATION_DETAILS% "%UPSTREAM_TRANSPORT_FAILURE_REASON%" %BYTES_RECEIVED% %BYTES_SENT% %DURATION% %RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)% "%REQ(X-FORWARDED-FOR)%" "%REQ(USER-AGENT)%" "%REQ(X-REQUEST-ID)%" "%REQ(:AUTHORITY)%" "%UPSTREAM_HOST%" %UPSTREAM_CLUSTER% %UPSTREAM_LOCAL_ADDRESS% %DOWNSTREAM_LOCAL_ADDRESS% %DOWNSTREAM_REMOTE_ADDRESS% %REQUESTED_SERVER_NAME% %ROUTE_NAME%
      path: /dev/stdout
  address:
    socketAddress:
      address: 0.0.0.0
      portValue: 8080
  filterChains:
  - filters:
    - name: envoy.filters.network.http_connection_manager
      typedConfig:
        '@type': type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
        accessLog:
        - name: envoy.access_loggers.file
          typedConfig:
            '@type': type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
            logFormat:
              textFormat: |
                [%START_TIME%] "%REQ(:METHOD)% %REQ(X-ENVOY-ORIGINAL-PATH?:PATH)% %PROTOCOL%" %RESPONSE_CODE% %RESPONSE_FLAGS% %RESPONSE_CODE_DETAILS% %CONNECTION_TERMINATION_DETAILS% "%UPSTREAM_TRANSPORT_FAILURE_REASON%" %BYTES_RECEIVED% %BYTES_SENT% %DURATION% %RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)% "%REQ(X-FORWARDED-FOR)%" "%REQ(USER-AGENT)%" "%REQ(X-REQUEST-ID)%" "%REQ(:AUTHORITY)%" "%UPSTREAM_HOST%" %UPSTREAM_CLUSTER% %UPSTREAM_LOCAL_ADDRESS% %DOWNSTREAM_LOCAL_ADDRESS% %DOWNSTREAM_REMOTE_ADDRESS% %REQUESTED_SERVER_NAME% %ROUTE_NAME%
            path: /dev/stdout
        forwardClientCertDetails: SANITIZE_SET
        httpFilters:
        - name: istio.metadata_exchange
          typedConfig:
            '@type': type.googleapis.com/udpa.type.v1.TypedStruct
            typeUrl: type.googleapis.com/envoy.extensions.filters.http.wasm.v3.Wasm
            value:
              config:
                configuration:
                  '@type': type.googleapis.com/google.protobuf.StringValue
                  value: |
                    {}
                vm_config:
                  code:
                    local:
                      inline_string: envoy.wasm.metadata_exchange
                  runtime: envoy.wasm.runtime.null
        - name: envoy.filters.http.cors
          typedConfig:
            '@type': type.googleapis.com/envoy.extensions.filters.http.cors.v3.Cors
        - name: envoy.filters.http.fault
          typedConfig:
            '@type': type.googleapis.com/envoy.extensions.filters.http.fault.v3.HTTPFault
        - name: istio.stats
          typedConfig:
            '@type': type.googleapis.com/udpa.type.v1.TypedStruct
            typeUrl: type.googleapis.com/envoy.extensions.filters.http.wasm.v3.Wasm
            value:
              config:
                configuration:
                  '@type': type.googleapis.com/google.protobuf.StringValue
                  value: |
                    {
                      "debug": "false",
                      "stat_prefix": "istio",
                      "disable_host_header_fallback": true
                    }
                root_id: stats_outbound
                vm_config:
                  code:
                    local:
                      inline_string: envoy.wasm.stats
                  runtime: envoy.wasm.runtime.null
                  vm_id: stats_outbound
        - name: envoy.filters.http.router
          typedConfig:
            '@type': type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
        httpProtocolOptions: {}
        normalizePath: true
        pathWithEscapedSlashesAction: KEEP_UNCHANGED
        rds:
          configSource:
            ads: {}
            initialFetchTimeout: 0s
            resourceApiVersion: V3
          routeConfigName: http.80
        serverName: istio-envoy
        setCurrentClientCertDetails:
          cert: true
          dns: true
          subject: true
          uri: true
        statPrefix: outbound_0.0.0.0_8080
        streamIdleTimeout: 0s
        tracing:
          clientSampling:
            value: 100
          customTags:
          - metadata:
              kind:
                request: {}
              metadataKey:
                key: envoy.filters.http.rbac
                path:
                - key: istio_dry_run_allow_shadow_effective_policy_id
            tag: istio.authorization.dry_run.allow_policy.name
          - metadata:
              kind:
                request: {}
              metadataKey:
                key: envoy.filters.http.rbac
                path:
                - key: istio_dry_run_allow_shadow_engine_result
            tag: istio.authorization.dry_run.allow_policy.result
          - metadata:
              kind:
                request: {}
              metadataKey:
                key: envoy.filters.http.rbac
                path:
                - key: istio_dry_run_deny_shadow_effective_policy_id
            tag: istio.authorization.dry_run.deny_policy.name
          - metadata:
              kind:
                request: {}
              metadataKey:
                key: envoy.filters.http.rbac
                path:
                - key: istio_dry_run_deny_shadow_engine_result
            tag: istio.authorization.dry_run.deny_policy.result
          - environment:
              defaultValue: latest
              name: CANONICAL_REVISION
            tag: istio.canonical_revision
          - environment:
              defaultValue: unknown
              name: CANONICAL_SERVICE
            tag: istio.canonical_service
          - environment:
              defaultValue: unknown
              name: ISTIO_META_MESH_ID
            tag: istio.mesh_id
          - environment:
              defaultValue: default
              name: POD_NAMESPACE
            tag: istio.namespace
          overallSampling:
            value: 100
          randomSampling:
            value: 1
        upgradeConfigs:
        - upgradeType: websocket
        useRemoteAddress: true
  name: 0.0.0.0_8080
  trafficDirection: OUTBOUND
```

If we look at the route `http.80` we observe a virtualHost named `blackhole:80` without any routes configuration. This is equivalent to return a 404.:
```
~/code/learn/istio/envoy-config > ipc routes $(kubectl -n istio-system get pod -l istio=ingressgateway -o jsonpath='{.items[0].metadata.name}') -n istio-system --name http.80 -o yaml              

- name: http.80
  validateClusters: false
  virtualHosts:
  - domains:
    - '*'
    name: blackhole:80

```

The istio-ingressgateway service exposes a nodeport 32208 on the internal IP 172.18.0.2 that forward on port 80 on the service, that will load balance to the istio-ingressgateway pods on port 8080. 
```
~/code/learn/istio/envoy-config > k get svc -n istio-system istio-ingressgateway -o wide       

NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                                                                      AGE    SELECTOR
istio-ingressgateway   LoadBalancer   10.96.42.110   <pending>     15021:30871/TCP,80:32208/TCP,443:30737/TCP,31400:31810/TCP,15443:30597/TCP   155m   app=istio-ingressgateway,istio=ingressgateway


~/code/learn/istio/envoy-config > k get svc -n istio-system istio-ingressgateway -o yaml

apiVersion: v1
kind: Service
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"labels":{"app":"istio-ingressgateway","install.operator.istio.io/owning-resource":"demo-istio-install","install.operator.istio.io/owning-resource-namespace":"istio-system","istio":"ingressgateway","istio.io/rev":"default","operator.istio.io/component":"IngressGateways","operator.istio.io/managed":"Reconcile","operator.istio.io/version":"1.10.1","release":"istio"},"name":"istio-ingressgateway","namespace":"istio-system"},"spec":{"ports":[{"name":"status-port","port":15021,"protocol":"TCP","targetPort":15021},{"name":"http2","port":80,"protocol":"TCP","targetPort":8080},{"name":"https","port":443,"protocol":"TCP","targetPort":8443},{"name":"tcp","port":31400,"protocol":"TCP","targetPort":31400},{"name":"tls","port":15443,"protocol":"TCP","targetPort":15443}],"selector":{"app":"istio-ingressgateway","istio":"ingressgateway"},"type":"LoadBalancer"}}
  creationTimestamp: "2021-06-12T02:55:05Z"
  labels:
    app: istio-ingressgateway
    install.operator.istio.io/owning-resource: demo-istio-install
    install.operator.istio.io/owning-resource-namespace: istio-system
    istio: ingressgateway
    istio.io/rev: default
    operator.istio.io/component: IngressGateways
    operator.istio.io/managed: Reconcile
    operator.istio.io/version: 1.10.1
    release: istio
  name: istio-ingressgateway
  namespace: istio-system
  resourceVersion: "993"
  uid: 338467fe-490b-4d44-bc5e-3b4195b4d354
spec:
  clusterIP: 10.96.42.110
  clusterIPs:
  - 10.96.42.110
  externalTrafficPolicy: Cluster
  ports:
  - name: status-port
    nodePort: 30871
    port: 15021
    protocol: TCP
    targetPort: 15021
  - name: http2
    nodePort: 32208
    port: 80
    protocol: TCP
    targetPort: 8080
  - name: https
    nodePort: 30737
    port: 443
    protocol: TCP
    targetPort: 8443
  - name: tcp
    nodePort: 31810
    port: 31400
    protocol: TCP
    targetPort: 31400
  - name: tls
    nodePort: 30597
    port: 15443
    protocol: TCP
    targetPort: 15443
  selector:
    app: istio-ingressgateway
    istio: ingressgateway
  sessionAffinity: None
  type: LoadBalancer
status:
  loadBalancer: {}

```

If we try to call the internal IP of a kubernetes node on the nodeport that forward to the physical listener port 8080 that was created by the `foo-com-gateway`, we verify it returns a 404.
```
> env | grep INGRESS_ 

INGRESS_HOST=172.18.0.2
INGRESS_PORT=32208
SECURE_INGRESS_PORT=30737
TCP_INGRESS_PORT=31810

~/code/learn/istio/envoy-config > http $INGRESS_HOST:$INGRESS_PORT Host:something.foo.com

HTTP/1.1 404 Not Found
content-length: 0
date: Sat, 12 Jun 2021 03:48:30 GMT
server: istio-envoy
```

### Physical Listener - TLS Termination

Let's setup a TLS termination on the `foo-com-gateway`:
```
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: foo-com-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - hosts:
    - "*.foo.com"
    port:
      number: 80
      name: http
      protocol: HTTP
  - port:
      number: 443
      name: https
      protocol: HTTPS
    hosts:
    - "*.foo.com"
    tls:
      mode: SIMPLE
      serverCertificate: /etc/certs/server.pem
      privateKey: /etc/certs/privatekey.pem

```

Another physical listener is created on the istio-ingressgateway istio-proxy pod container, named `0.0.0.0_8443`. This listener has a filter chain for only the server_names `*.foo.com` 
```
~/code/learn/istio/envoy-config > ipc listeners $(kubectl -n istio-system get pod -l istio=ingressgateway -o jsonpath='{.items[0].metadata.name}') -n istio-system 


ADDRESS PORT  MATCH          DESTINATION
0.0.0.0 8080  ALL            Route: http.80
0.0.0.0 8443  SNI: *.foo.com Route: https.443.https.foo-com-gateway.default
0.0.0.0 15021 ALL            Inline Route: /healthz/ready*
0.0.0.0 15090 ALL            Inline Route: /stats/prometheus*

```

```

~/code/learn/istio/envoy-config > ipc listeners $(kubectl -n istio-system get pod -l istio=ingressgateway -o jsonpath='{.items[0].metadata.name}') -n istio-system --port 8443 -o yaml

- accessLog:
  - filter:
      responseFlagFilter:
        flags:
        - NR
    name: envoy.access_loggers.file
    typedConfig:
      '@type': type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
      logFormat:
        textFormat: |
          [%START_TIME%] "%REQ(:METHOD)% %REQ(X-ENVOY-ORIGINAL-PATH?:PATH)% %PROTOCOL%" %RESPONSE_CODE% %RESPONSE_FLAGS% %RESPONSE_CODE_DETAILS% %CONNECTION_TERMINATION_DETAILS% "%UPSTREAM_TRANSPORT_FAILURE_REASON%" %BYTES_RECEIVED% %BYTES_SENT% %DURATION% %RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)% "%REQ(X-FORWARDED-FOR)%" "%REQ(USER-AGENT)%" "%REQ(X-REQUEST-ID)%" "%REQ(:AUTHORITY)%" "%UPSTREAM_HOST%" %UPSTREAM_CLUSTER% %UPSTREAM_LOCAL_ADDRESS% %DOWNSTREAM_LOCAL_ADDRESS% %DOWNSTREAM_REMOTE_ADDRESS% %REQUESTED_SERVER_NAME% %ROUTE_NAME%
      path: /dev/stdout
  address:
    socketAddress:
      address: 0.0.0.0
      portValue: 8443
  filterChains:
  - filterChainMatch:
      serverNames:
      - '*.foo.com'
    filters:
    - name: envoy.filters.network.http_connection_manager
      typedConfig:
        '@type': type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
        accessLog:
        - name: envoy.access_loggers.file
          typedConfig:
            '@type': type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
            logFormat:
              textFormat: |
                [%START_TIME%] "%REQ(:METHOD)% %REQ(X-ENVOY-ORIGINAL-PATH?:PATH)% %PROTOCOL%" %RESPONSE_CODE% %RESPONSE_FLAGS% %RESPONSE_CODE_DETAILS% %CONNECTION_TERMINATION_DETAILS% "%UPSTREAM_TRANSPORT_FAILURE_REASON%" %BYTES_RECEIVED% %BYTES_SENT% %DURATION% %RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)% "%REQ(X-FORWARDED-FOR)%" "%REQ(USER-AGENT)%" "%REQ(X-REQUEST-ID)%" "%REQ(:AUTHORITY)%" "%UPSTREAM_HOST%" %UPSTREAM_CLUSTER% %UPSTREAM_LOCAL_ADDRESS% %DOWNSTREAM_LOCAL_ADDRESS% %DOWNSTREAM_REMOTE_ADDRESS% %REQUESTED_SERVER_NAME% %ROUTE_NAME%
            path: /dev/stdout
        forwardClientCertDetails: SANITIZE_SET
        httpFilters:
        - name: istio.metadata_exchange
          typedConfig:
            '@type': type.googleapis.com/udpa.type.v1.TypedStruct
            typeUrl: type.googleapis.com/envoy.extensions.filters.http.wasm.v3.Wasm
            value:
              config:
                configuration:
                  '@type': type.googleapis.com/google.protobuf.StringValue
                  value: |
                    {}
                vm_config:
                  code:
                    local:
                      inline_string: envoy.wasm.metadata_exchange
                  runtime: envoy.wasm.runtime.null
        - name: envoy.filters.http.cors
          typedConfig:
            '@type': type.googleapis.com/envoy.extensions.filters.http.cors.v3.Cors
        - name: envoy.filters.http.fault
          typedConfig:
            '@type': type.googleapis.com/envoy.extensions.filters.http.fault.v3.HTTPFault
        - name: istio.stats
          typedConfig:
            '@type': type.googleapis.com/udpa.type.v1.TypedStruct
            typeUrl: type.googleapis.com/envoy.extensions.filters.http.wasm.v3.Wasm
            value:
              config:
                configuration:
                  '@type': type.googleapis.com/google.protobuf.StringValue
                  value: |
                    {
                      "debug": "false",
                      "stat_prefix": "istio",
                      "disable_host_header_fallback": true
                    }
                root_id: stats_outbound
                vm_config:
                  code:
                    local:
                      inline_string: envoy.wasm.stats
                  runtime: envoy.wasm.runtime.null
                  vm_id: stats_outbound
        - name: envoy.filters.http.router
          typedConfig:
            '@type': type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
        httpProtocolOptions: {}
        normalizePath: true
        pathWithEscapedSlashesAction: KEEP_UNCHANGED
        rds:
          configSource:
            ads: {}
            initialFetchTimeout: 0s
            resourceApiVersion: V3
          routeConfigName: https.443.https.foo-com-gateway.default
        serverName: istio-envoy
        setCurrentClientCertDetails:
          cert: true
          dns: true
          subject: true
          uri: true
        statPrefix: outbound_0.0.0.0_8443
        streamIdleTimeout: 0s
        tracing:
          clientSampling:
            value: 100
          customTags:
          - metadata:
              kind:
                request: {}
              metadataKey:
                key: envoy.filters.http.rbac
                path:
                - key: istio_dry_run_allow_shadow_effective_policy_id
            tag: istio.authorization.dry_run.allow_policy.name
          - metadata:
              kind:
                request: {}
              metadataKey:
                key: envoy.filters.http.rbac
                path:
                - key: istio_dry_run_allow_shadow_engine_result
            tag: istio.authorization.dry_run.allow_policy.result
          - metadata:
              kind:
                request: {}
              metadataKey:
                key: envoy.filters.http.rbac
                path:
                - key: istio_dry_run_deny_shadow_effective_policy_id
            tag: istio.authorization.dry_run.deny_policy.name
          - metadata:
              kind:
                request: {}
              metadataKey:
                key: envoy.filters.http.rbac
                path:
                - key: istio_dry_run_deny_shadow_engine_result
            tag: istio.authorization.dry_run.deny_policy.result
          - environment:
              defaultValue: latest
              name: CANONICAL_REVISION
            tag: istio.canonical_revision
          - environment:
              defaultValue: unknown
              name: CANONICAL_SERVICE
            tag: istio.canonical_service
          - environment:
              defaultValue: unknown
              name: ISTIO_META_MESH_ID
            tag: istio.mesh_id
          - environment:
              defaultValue: default
              name: POD_NAMESPACE
            tag: istio.namespace
          overallSampling:
            value: 100
          randomSampling:
            value: 1
        upgradeConfigs:
        - upgradeType: websocket
        useRemoteAddress: true
    transportSocket:
      name: envoy.transport_sockets.tls
      typedConfig:
        '@type': type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
        commonTlsContext:
          alpnProtocols:
          - h2
          - http/1.1
          tlsCertificateSdsSecretConfigs:
          - name: file-cert:/etc/certs/server.pem~/etc/certs/privatekey.pem
            sdsConfig:
              apiConfigSource:
                apiType: GRPC
                grpcServices:
                - envoyGrpc:
                    clusterName: sds-grpc
                setNodeOnFirstMessageOnly: true
                transportApiVersion: V3
              resourceApiVersion: V3
        requireClientCertificate: false
  listenerFilters:
  - name: envoy.filters.listener.tls_inspector
    typedConfig:
      '@type': type.googleapis.com/envoy.extensions.filters.listener.tls_inspector.v3.TlsInspector
  name: 0.0.0.0_8443
  trafficDirection: OUTBOUND
```

The route `https.443.https.foo-com-gateway.default` is the same way than for the other physical listener, a blackhole without any routes config.
```
~/code/learn/istio/envoy-config > ipc routes $(kubectl -n istio-system get pod -l istio=ingressgateway -o jsonpath='{.items[0].metadata.name}') -n istio-system --name https.443.https.foo-com-gateway.default -o yaml

- name: https.443.https.foo-com-gateway.default
  validateClusters: false
  virtualHosts:
  - domains:
    - '*'
    name: blackhole:443
```

## Virtual Service

Let's bind a Virtual Service to this Gateway.
```
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
 name: foo-default
spec:
 hosts:
 - bar.foo.com
 gateways:
 - foo-com-gateway
 http:
 - route:
   - destination:
       host: bar.foo.svc.cluster.local
```

### Routes

No change occurred in the physical listeners `0.0.0.0_80` and `0.0.0.0_8443`. For HTTP, all of the action happens in routes. Other protocols for example, TCP push more of the logic to the listener.
The route `http.80` is configured on the `bar.foo.com` and `bar.foo.com:*` domains with the default route prefix `/` catching all requests and forward them to the cluster `outbound|80||bar.foo.svc.cluster.local`
```
~/code/learn/istio/envoy-config > ipc routes $(kubectl -n istio-system get pod -l istio=ingressgateway -o jsonpath='{.items[0].metadata.name}') -n istio-system --name http.80 -o json      

[
    {
        "name": "http.80",
        "virtualHosts": [
            {
                "name": "bar.foo.com:80",
                "domains": [
                    "bar.foo.com",
                    "bar.foo.com:*"
                ],
                "routes": [
                    {
                        "match": {
                            "prefix": "/"
                        },
                        "route": {
                            "cluster": "outbound|80||bar.foo.svc.cluster.local",
                            "timeout": "0s",
                            "retryPolicy": {
                                "retryOn": "connect-failure,refused-stream,unavailable,cancelled,retriable-status-codes",
                                "numRetries": 2,
                                "retryHostPredicate": [
                                    {
                                        "name": "envoy.retry_host_predicates.previous_hosts"
                                    }
                                ],
                                "hostSelectionRetryMaxAttempts": "5",
                                "retriableStatusCodes": [
                                    503
                                ]
                            },
                            "maxGrpcTimeout": "0s"
                        },
                        "metadata": {
                            "filterMetadata": {
                                "istio": {
                                    "config": "/apis/networking.istio.io/v1alpha3/namespaces/default/virtual-service/foo-default"
                                }
                            }
                        },
                        "decorator": {
                            "operation": "bar.foo.svc.cluster.local:80/*"
                        }
                    }
                ],
                "includeRequestAttemptCount": true
            }
        ],
        "validateClusters": false
    }
]
```

Note that the route `https.443.https.foo-com-gateway.default` is also modified cause the Virtual Service is linked to the `foo-com-gateway` gateway.

```

~/code/learn/istio/envoy-config > ipc routes $(kubectl -n istio-system get pod -l istio=ingressgateway -o jsonpath='{.items[0].metadata.name}') -n istio-system --name https.443.https.foo-com-gateway.default -o yaml

- name: https.443.https.foo-com-gateway.default
  validateClusters: false
  virtualHosts:
  - domains:
    - bar.foo.com
    - bar.foo.com:*
    includeRequestAttemptCount: true
    name: bar.foo.com:443
    routes:
    - decorator:
        operation: bar.foo.svc.cluster.local:443/*
      match:
        prefix: /
      metadata:
        filterMetadata:
          istio:
            config: /apis/networking.istio.io/v1alpha3/namespaces/default/virtual-service/foo-default
      route:
        cluster: outbound|443||bar.foo.svc.cluster.local
        maxGrpcTimeout: 0s
        retryPolicy:
          hostSelectionRetryMaxAttempts: "5"
          numRetries: 2
          retriableStatusCodes:
          - 503
          retryHostPredicate:
          - name: envoy.retry_host_predicates.previous_hosts
          retryOn: connect-failure,refused-stream,unavailable,cancelled,retriable-status-codes
        timeout: 0s


```

We can add retries, split traffic among several destinations, inject faults... All this options of a VirtualService will manifest as routes in envoy configuration.

## ServiceEntry

Istio generates an envoy cluster for each kubernetes service and port in the mesh. We can create a ServiceEntry to see a new cluster appear in Envoy configuration.
For example if we look at the current cluster on the pod shpod:

```
~/code/learn/istio/envoy-config > ipc clusters shpod -n shpod

SERVICE FQDN                                            PORT      SUBSET     DIRECTION     TYPE             DESTINATION RULE
BlackHoleCluster                                        -         -          -             STATIC
InboundPassthroughClusterIpv4                           -         -          -             ORIGINAL_DST
InboundPassthroughClusterIpv6                           -         -          -             ORIGINAL_DST
PassthroughCluster                                      -         -          -             ORIGINAL_DST
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

If we apply the following ServiceEntry:

```
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: http-server
spec:
  hosts:
  - some.domain.com
  ports:
  - number: 80
    name: http
    protocol: http
  resolution: STATIC
  endpoints:
  - address: 2.2.2.2
```

### Cluster

An outbound cluster `outbound|80||some.domain.com` is created on every istio-proxy:
```

~/code/learn/istio/envoy-config > ipc clusters shpod -n shpod                                    λ:main  [  ]
SERVICE FQDN                                            PORT      SUBSET     DIRECTION     TYPE             DESTINATION RULE
BlackHoleCluster                                        -         -          -             STATIC
InboundPassthroughClusterIpv4                           -         -          -             ORIGINAL_DST
InboundPassthroughClusterIpv6                           -         -          -             ORIGINAL_DST
PassthroughCluster                                      -         -          -             ORIGINAL_DST
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
some.domain.com                                         80        -          outbound      EDS
xds-grpc                                                -         -          -             STATIC
zipkin                                                  -         -          -             STRICT_DNS

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
some.domain.com                                         80        -          outbound      EDS
xds-grpc                                                -         -          -             STATIC
zipkin                                                  -         -          -             STRICT_DNS

~/code/learn/istio/envoy-config > ipc clusters shpod -n shpod --fqdn some.domain.com -o json     λ:main  [  ]
[
    {
        "name": "outbound|80||some.domain.com",
        "type": "EDS",
        "edsClusterConfig": {
            "edsConfig": {
                "ads": {},
                "initialFetchTimeout": "0s",
                "resourceApiVersion": "V3"
            },
            "serviceName": "outbound|80||some.domain.com"
        }
        "connectTimeout": "10s",
        "circuitBreakers": {
            "thresholds": [
                {
                    "maxConnections": 4294967295,
                    "maxPendingRequests": 4294967295,
                    "maxRequests": 4294967295,
                    "maxRetries": 4294967295,
                    "trackRemaining": true
                }
            ]
        },
        "metadata": {
            "filterMetadata": {
                "istio": {
                    "default_original_port": 80,
                    "services": [
                        {
                            "host": "some.domain.com",
                            "name": "some.domain.com",
                            "namespace": "default"
                        }
                    ]
                }
            }
        },
        "filters": [
            {
                "name": "istio.metadata_exchange",
                "typedConfig": {
                    "@type": "type.googleapis.com/udpa.type.v1.TypedStruct",
                    "typeUrl": "type.googleapis.com/envoy.tcp.metadataexchange.config.MetadataExchange",
                    "value": {
                        "protocol": "istio-peer-exchange"
                    }
                }
            }
        ]
    }
]
```


It create also the respective envoy endpoints:
```
~/code/learn/istio/envoy-config > ipc endpoints $(kubectl -n istio-system get pod -l istio=ingressgateway -o jsonpath='{.items[0].metadata.name}') -n istio-system --cluster 'outbound|80||some.domain.com' -o json


[
    {
        "name": "outbound|80||some.domain.com",
        "addedViaApi": true,
        "hostStatuses": [
            {
                "address": {
                    "socketAddress": {
                        "address": "2.2.2.2",
                        "portValue": 80
                    }
                },
                "stats": [
                    {
                        "name": "cx_connect_fail"
                    },
                    {
                        "name": "cx_total"
                    },
                    {
                        "name": "rq_error"
                    },
                    {
                        "name": "rq_success"
                    },
                    {
                        "name": "rq_timeout"
                    },
                    {
                        "name": "rq_total"
                    },
                    {
                        "type": "GAUGE",
                        "name": "cx_active"
                    },
                    {
                        "type": "GAUGE",
                        "name": "rq_active"
                    }
                ],
                "healthStatus": {
                    "edsHealthStatus": "HEALTHY"
                },
                "weight": 1,
                "locality": {}
            }
        ],
        "circuitBreakers": {
            "thresholds": [
                {
                    "maxConnections": 4294967295,
                    "maxPendingRequests": 4294967295,
                    "maxRequests": 4294967295,
                    "maxRetries": 4294967295
                },
                {
                    "priority": "HIGH",
                    "maxConnections": 1024,
                    "maxPendingRequests": 1024,
                    "maxRequests": 1024,
                    "maxRetries": 3
                }
            ]
        },
        "observabilityName": "outbound|80||some.domain.com"
    }
]
```

If we add an extra port in the ServiceEntry like following:
```

~/code/learn/istio/envoy-config > cat some-domain-se-w-extra-port.yaml                                                                                                                              λ:main  [   ]
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: http-server
spec:
  hosts:
  - some.domain.com
  ports:
  - number: 443
    name: https
    protocol: https
  - number: 80
    name: http
    protocol: http
  resolution: STATIC
  endpoints:
  - address: 2.2.2.2
```

It will create another envoy cluster:
```

~/code/learn/istio/envoy-config > ipc clusters $(kubectl -n istio-system get pod -l istio=ingressgateway -o jsonpath='{.items[0].metadata.name}') -n istio-system                                   λ:main  [   ]

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
some.domain.com                                         80        -          outbound      EDS
some.domain.com                                         443       -          outbound      EDS
xds-grpc                                                -         -          -             STATIC
zipkin                                                  -         -          -             STRICT_DNS
```
