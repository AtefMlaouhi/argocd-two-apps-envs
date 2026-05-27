SHELL := /bin/bash

.PHONY: help apply-project apply-dev apply-prod apply-all delete-dev delete-prod delete-all status namespaces

help:
	@echo "Commands:"
	@echo "  make namespaces     Create dev and prod namespaces"
	@echo "  make apply-project  Apply Argo CD project"
	@echo "  make apply-dev      Apply dev Argo CD applications"
	@echo "  make apply-prod     Apply prod Argo CD applications"
	@echo "  make apply-all      Apply project, dev apps and prod apps"
	@echo "  make status         Show Argo CD applications and resources"
	@echo "  make delete-dev     Delete dev applications"
	@echo "  make delete-prod    Delete prod applications"
	@echo "  make delete-all     Delete all Argo CD apps and project"

namespaces:
	kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -
	kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -

apply-project:
	kubectl apply -f argocd/projects/

apply-dev:
	kubectl apply -f argocd/applications/dev/

apply-prod:
	kubectl apply -f argocd/applications/prod/

apply-all: namespaces apply-project apply-dev apply-prod

status:
	kubectl get applications -n argocd
	kubectl get all -n dev
	kubectl get all -n prod

delete-dev:
	kubectl delete -f argocd/applications/dev/ --ignore-not-found

delete-prod:
	kubectl delete -f argocd/applications/prod/ --ignore-not-found

delete-all: delete-dev delete-prod
	kubectl delete -f argocd/projects/ --ignore-not-found
