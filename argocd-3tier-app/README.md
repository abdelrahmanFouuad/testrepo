
# 📄 Documentation: 3-Tier Application Deployment with ArgoCD

> **Repository**: [https://github.com/abdelrahmanFouuad/testrepo/tree/main/argocd-3tier-app](https://github.com/abdelrahmanFouuad/testrepo/tree/main/argocd-3tier-app)  
> **Purpose**: GitOps-based deployment of a secure, production-ready 3-tier application on Kubernetes using ArgoCD.

---

## 🎯 Overview

This repository implements a **complete GitOps workflow** for deploying a **3-tier application** (frontend, backend, database) on Kubernetes. It follows security best practices, uses real open-source components, and is fully managed by **ArgoCD**.

The architecture includes:
- **Frontend**: React-based admin dashboard (using [`react-admin`](https://marmelab.com/react-admin/))
- **Backend**: REST API server (using [`json-server`](https://github.com/typicode/json-server))
- **Database**: MySQL (deployed in-cluster via Bitnami image)
- **Orchestration**: Kubernetes + ArgoCD (GitOps)

All components run as **non-root users**, with hardened security contexts compliant with **OpenShift restricted SCC** and Kubernetes **Pod Security Standard (Restricted)**.

---

## 🗂️ Repository Structure

```bash
testrepo/
└── argocd-3tier-app/
    ├── apps/
    │   ├── frontend/               # React frontend source + Dockerfile
    │   ├── backend/                # Node.js backend source + Dockerfile
    │   └── manifests/              # Kubernetes manifests (deployed by ArgoCD)
    │       ├── namespace.yaml
    │       ├── mysql-secret.yaml
    │       ├── mysql-pvc.yaml
    │       ├── mysql-deployment.yaml
    │       ├── backend-deployment.yaml
    │       ├── frontend-deployment.yaml
    │       └── ingress.yaml
    └── argocd/
        └── application.yaml        # ArgoCD Application manifest
```

> ✅ **GitOps Principle**: The `argocd-3tier-app/apps/manifests/` directory is the **single source of truth** for the desired cluster state.

---

## 🧱 Architecture Diagram

```
User
  │
  ▼
Ingress (three-tier.local)
  ├── /        → frontend Service → frontend Pods (React)
  └── /api/*   → backend Service  → backend Pods (JSON Server)
                     │
                     ▼
                 MySQL Service → MySQL Pod (Bitnami)
```

---

## 🐳 Container Images

| Component  | Image                                      | Build Context                              |
|-----------|--------------------------------------------|--------------------------------------------|
| Frontend  | `abdelrahmanfouuad/frontend:latest`        | `argocd-3tier-app/apps/frontend/`          |
| Backend   | `abdelrahmanfouuad/backend:latest`         | `argocd-3tier-app/apps/backend/`           |
| Database  | `bitnami/mysql:8.0` (public)               | —                                          |

> 🔁 **You must build and push the `frontend` and `backend` images to Docker Hub before deployment.**

### Build & Push Commands

From the **root of your local clone** (`testrepo/`):

```bash
# Build frontend
docker build -t abdelrahmanfouuad/frontend:latest \
  -f argocd-3tier-app/apps/frontend/Dockerfile \
  argocd-3tier-app/apps/frontend

# Build backend
docker build -t abdelrahmanfouuad/backend:latest \
  -f argocd-3tier-app/apps/backend/Dockerfile \
  argocd-3tier-app/apps/backend

# Push to Docker Hub
docker push abdelrahmanfouuad/frontend:latest
docker push abdelrahmanfouuad/backend:latest
```

---

## 🔐 Security Hardening

All workloads enforce **zero-trust container security**, aligned with Kubernetes **Restricted Pod Security Standard**:

- ✅ **Non-root execution** (`runAsUser: 1001`)
- ✅ **No privilege escalation** (`allowPrivilegeEscalation: false`)
- ✅ **Read-only root filesystem**
- ✅ **All Linux capabilities dropped**
- ✅ **Seccomp profile**: `RuntimeDefault`
- ✅ **FSGroup** for volume ownership
- ✅ Secrets stored in Kubernetes `Secret` (never in ConfigMaps or code)

These settings are compatible with:
- Kubernetes **Pod Security Admission (PSA)** in `restricted` mode
- OpenShift **restricted SecurityContextConstraints (SCC)**

---

## 🔑 Creating Database Secret and ConfigMap

To securely configure MySQL, use Kubernetes `Secret`.

### Step 1: Encode Credentials

```bash
echo -n 'three-tier-user' | base64    # → dGhyZWUtdGllci11c2Vy
echo -n 'S3cureP@ssw0rd!' | base64   # → UzNjdXJlUEBzc3cwcmQh
```

### Step 2: Create `mysql-secret.yaml`

```yaml
# argocd-3tier-app/apps/manifests/mysql-secret.yaml
apiVersion: v1
kind: Secret
meta
  name: mysql-secret
  namespace: three-tier-app
type: Opaque

  MYSQL_USER: dGhyZWUtdGllci11c2Vy
  MYSQL_PASSWORD: UzNjdXJlUEBzc3cwcmQh
  MYSQL_ROOT_PASSWORD: UzNjdXJlUEBzc3cwcmQh
```

> 🔒 **Warning**: Only commit this to a **private repository**. For public repos, use Sealed Secrets or External Secrets Operator.

This secret is consumed by the MySQL pod to initialize the database.

> 📝 Note: The current `json-server` backend does **not** connect to MySQL—it serves static data from `db.json`. This setup prepares you for future migration to a real backend.

---

## 🚀 Deployment Instructions

### Prerequisites

- Kubernetes cluster (v1.24+)
- `kubectl` configured
- ArgoCD installed in `argocd` namespace
- Ingress controller (e.g., NGINX) installed
- Docker Hub account with images pushed

### Step 1: Clone & Configure

```bash
git clone https://github.com/abdelrahmanFouuad/testrepo.git
cd testrepo
```

Ensure your images are pushed (see **Build & Push Commands** above).

### Step 2: Deploy ArgoCD Application

```bash
kubectl apply -f argocd-3tier-app/argocd/application.yaml
```

This creates an ArgoCD `Application` that syncs from:
- **Repo**: `https://github.com/abdelrahmanFouuad/testrepo.git`
- **Path**: `argocd-3tier-app/apps/manifests`
- **Branch**: `main`

### Step 3: Access the Application

```bash
# Get ingress IP
kubectl get ingress -n three-tier-app

# Add to /etc/hosts (replace <IP> with actual IP)
echo "<IP> three-tier.local" | sudo tee -a /etc/hosts

# Open in browser
open http://three-tier.local
```

You’ll see a **React Admin dashboard** powered by `json-server`.

---

## 🔄 GitOps Workflow

- Any change to `argocd-3tier-app/apps/manifests/` → auto-synced by ArgoCD
- ArgoCD runs in **automated sync mode** (`prune: true`, `selfHeal: true`)
- Namespace `three-tier-app` is auto-created

> 💡 **Never use `kubectl apply` manually**—all changes must go through Git.

---

## 🧪 Validation

```bash
kubectl get pods -n three-tier-app
# Expected: frontend-x, backend-x, mysql-x

kubectl logs -l app=backend -n three-tier-app
# Should show: "JSON Server running on port 3000"

curl http://three-tier.local/api/posts
# Should return JSON
```

---
