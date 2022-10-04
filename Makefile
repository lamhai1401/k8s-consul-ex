start-bird:
	kubectl apply -f ./manifests

start-server:
	minikube start --driver=docker --kubernetes-version=v1.23.3
	minikube tunnel