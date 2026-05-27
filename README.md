# Argo CD GitOps Repo — Two Apps, Dev and Prod

This repository manages two static HTML applications with Argo CD:

- `app-one`
- `app-two`

Each app has two environments:

- `dev`
- `prod`

Each app serves only an `index.html` file through nginx.

## Repository structure

```txt
.
├── argocd/
│   ├── projects/
│   │   └── bi-project.yaml
│   └── applications/
│       ├── dev/
│       │   ├── app-one-dev.yaml
│       │   └── app-two-dev.yaml
│       └── prod/
│           ├── app-one-prod.yaml
│           └── app-two-prod.yaml
└── apps/
    ├── app-one/
    │   ├── base/
    │   └── overlays/
    │       ├── dev/
    │       └── prod/
    └── app-two/
        ├── base/
        └── overlays/
            ├── dev/
            └── prod/
```

## Prerequisites

You need:

```bash
kubectl version --client
argocd version --client
```

You also need Argo CD installed in your cluster.

Example local install:

```bash
kubectl create namespace argocd

kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Wait for Argo CD:

```bash
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s
```

## Update repository URL

Before applying the Argo CD Applications, replace this value in all files under `argocd/applications/`:

```txt
https://github.com/YOUR_ORG/argocd-two-apps-envs.git
```

With your real Git repository URL.

Example:

```bash
grep -R "YOUR_ORG" -n argocd/applications
```

## Create namespaces

```bash
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -
```

## Apply Argo CD project

```bash
kubectl apply -f argocd/projects/bi-project.yaml
```

## Deploy dev applications

```bash
kubectl apply -f argocd/applications/dev/
```

## Deploy prod applications

```bash
kubectl apply -f argocd/applications/prod/
```

## Deploy everything

```bash
kubectl apply -f argocd/projects/
kubectl apply -f argocd/applications/dev/
kubectl apply -f argocd/applications/prod/
```

## Check Argo CD applications

```bash
kubectl get applications -n argocd
```

## Check Kubernetes resources

```bash
kubectl get all -n dev
kubectl get all -n prod
```

## Test app-one dev

```bash
kubectl port-forward svc/app-one -n dev 8081:80
```

Open:

```txt
http://localhost:8081
```

## Test app-two dev

```bash
kubectl port-forward svc/app-two -n dev 8082:80
```

Open:

```txt
http://localhost:8082
```

## Test app-one prod

```bash
kubectl port-forward svc/app-one -n prod 8091:80
```

Open:

```txt
http://localhost:8091
```

## Test app-two prod

```bash
kubectl port-forward svc/app-two -n prod 8092:80
```

Open:

```txt
http://localhost:8092
```

## Delete applications

```bash
kubectl delete -f argocd/applications/dev/
kubectl delete -f argocd/applications/prod/
kubectl delete -f argocd/projects/
```

## Notes

- Dev uses 1 replica.
- Prod uses 2 replicas.
- Each environment has a different `index.html`.
- Kustomize generates the nginx `index.html` ConfigMap.
- Argo CD sync is automated with prune and self-heal.
