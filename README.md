# How to run consul in local

minikube tunnel
consul-k8s install -config-file values.yaml
consul-k8s upgrade -config-file values.yaml

## UI

[ui](http://localhost:8500/ui/dc1/intentions)

## Check

consul-k8s status

## start & stop minicube

minikube stop
minikube start --driver=docker --kubernetes-version=v1.23.3

## check resource

kubectl get daemonset,statefulset,deployment -n consul

## API

curl [curl](http://localhost:8500/v1/catalog/services?pretty)

## Start bird watcher

make start-bird

kubectl get deployment,service --selector app=frontend
kubectl get deployment,service --selector app=backend

[home](http://localhost:6060)

## Re-deploy

kubectl apply -f frontend-deployment.yaml

### Watching the apply change

kubectl rollout status --watch deploy/frontend

### Check the pod afer add consul

kubectl get pod -l app=frontend -o yaml > t.log

### Check by pass side car proxy

kubectl exec deploy/frontend -c frontend -- \
    curl -si http://backend/bird

### If running Kubernetes in the cloud or on Linux, use

kubectl port-forward service/frontend 6060

## Upgrade consul config

consul-k8s upgrade -config-file values.yaml

## Start gate way

kubectl apply -f ingress-gateway.yaml
kubectl get ingressgateway ingress-gateway -n consul

### Check error if exist

kubectl describe ingressgateway ingress-gateway -n consul

### Apply default proxy

kubectl apply -f proxy-defaults.yaml
kubectl get proxydefaults global -n consul

## Restart metrics server

kubectl rollout restart deploy/prometheus-server -n consul

## Install gafana

kubectl create secret generic grafana-admin \
      --from-literal=admin-user=admin \
      --from-literal=admin-password=admin

helm install grafana grafana \
    --version 6.17.1 \
    --repo https://grafana.github.io/helm-charts \
    --set service.type=LoadBalancer \
    --set service.port=3000 \
    --set persistence.enabled=true \
    --set rbac.pspEnabled=false \
    --set admin.existingSecret=grafana-admin \
    --wait

### Gafana success rate
sum(
  rate(
    envoy_http_downstream_rq_completed{
      consul_source_service="$Service",
      envoy_http_conn_manager_prefix=~"public_listener|ingress_upstream_8080"
    }[$__rate_interval]
  )
)

### Gafana error rate
sum(
  rate(
    envoy_http_downstream_rq_xx{
      consul_source_service="$Service",
      envoy_http_conn_manager_prefix=~"public_listener|ingress_upstream_8080",
      envoy_response_code_class="5"
    }[$__rate_interval]
  )
) /
sum(
  rate(
    envoy_http_downstream_rq_completed{
      consul_source_service="$Service",
      envoy_http_conn_manager_prefix=~"public_listener|ingress_upstream_8080"
    }[$__rate_interval]
  )
)

### Gafana latency

histogram_quantile(
  0.5,
  sum(
    rate(
      envoy_http_downstream_rq_time_bucket{
        consul_source_service="$Service",
        envoy_http_conn_manager_prefix=~"public_listener|ingress_upstream_8080"
      }[$__rate_interval]
    )
  ) by (le)
)

histogram_quantile(
  0.99,
  sum(
    rate(
      envoy_http_downstream_rq_time_bucket{
        consul_source_service="$Service",
        envoy_http_conn_manager_prefix=~"public_listener|ingress_upstream_8080"
      }[$__rate_interval]
    )
  ) by (le)
)

## install tracing collector

helm install jaeger jaeger-operator \
      --version 2.26.0 \
      --repo https://jaegertracing.github.io/helm-charts \
      --wait

kubectl apply -f jaeger.yaml

[Jaeger home](http://localhost:16686/)

### Add config to proxydefault

kubectl apply -f proxy-defaults.yaml

### Restart all services

kubectl rollout restart deploy/consul-ingress-gateway -n consul
kubectl rollout restart deploy/frontend
kubectl rollout restart deploy/backend

## Check pod status

kubectl get pods -l app=backend
