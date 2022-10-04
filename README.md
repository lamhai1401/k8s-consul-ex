# How to run consul in local

minikube tunnel
consul-k8s install -config-file values.yaml

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
