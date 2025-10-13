# 📄 Documentation: 3-Tier Application Deployment with ArgoCD

> **Repository**: [https://github.com/ibrahemyasser/3Tier-deployment-with-ArgoCd](https://github.com/ibrahemyasser/3Tier-deployment-with-ArgoCd)  
> **Purpose**: GitOps-based deployment of a secure, production-ready 3-tier application on Kubernetes using ArgoCD.

---

## 🎯 Overview

This repository implements a **complete GitOps workflow** for deploying a **3-tier application** (frontend, backend, database) on Kubernetes. It follows security best practices, uses real open-source components, and is fully managed by **ArgoCD**.

The architecture includes:
- **Frontend**: React-based admin dashboard (using `react-admin`)
- **Backend**: REST API server (using `json-server`)
- **Database**: MySQL (deployed in-cluster via Bitnami image)
- **Orchestration**: Kubernetes + ArgoCD (GitOps)

All components run as **non-root users**, with hardened security contexts compliant with **OpenShift restricted SCC** and Kubernetes Pod Security Standards.

---

## 🗂️ Repository Structure

```bash
3Tier-deployment-with-ArgoCd/
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

> ✅ **GitOps Principle**: The `manifests/` directory is the **single source of truth** for the desired cluster state.

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

| Component  | Image (Example)                          | Build Context                     |
|-----------|------------------------------------------|-----------------------------------|
| Frontend  | `your-registry/frontend:latest`          | `apps/frontend/`                  |
| Backend   | `your-registry/backend:latest`           | `apps/backend/`                   |
| Database  | `bitnami/mysql:8.0` (public)             | —                                 |

> 🔁 **You must build and push `frontend` and `backend` images to your container registry before deployment.**

### Build Commands

```bash
# From repo root
docker build -t your-registry/frontend:latest -f apps/frontend/Dockerfile apps/frontend
docker build -t your-registry/backend:latest -f apps/backend/Dockerfile apps/backend

docker push your-registry/frontend:latest
docker push your-registry/backend:latest
```

> 💡 Replace `your-registry` with your Docker Hub/GHCR username (e.g., `abdelrahmanfouuad`).

---

## 🔐 Security Hardening

All workloads enforce **zero-trust container security**:

- ✅ **Non-root execution** (`runAsUser: 1001`)
- ✅ **No privilege escalation**
- ✅ **Read-only root filesystem**
- ✅ **All Linux capabilities dropped**
- ✅ **Seccomp profile**: `RuntimeDefault`
- ✅ **FSGroup** for volume ownership
- ✅ Secrets stored in Kubernetes `Secret` (not ConfigMaps)

These settings comply with:
- Kubernetes **Pod Security Standard (restricted)**
- OpenShift **restricted SecurityContextConstraints (SCC)**

---

## 🔑 Creating Database Secret and ConfigMap

To securely connect your application components to MySQL, this deployment uses Kubernetes-native resources:
- **`Secret`**: Stores sensitive data (username, password) in base64-encoded form.
- **`ConfigMap`** (optional): Stores non-sensitive configuration like host, port, or database name.

> ✅ **Best Practice**: Never hardcode credentials in source code or plain-text manifests. Always use `Secret` for secrets.

### Step 1: Choose Secure Credentials

Define your database parameters:

| Parameter        | Example Value        |
|------------------|----------------------|
| Host             | `mysql`              |
| Port             | `3306`               |
| Database Name    | `appdb`              |
| Username         | `three-tier-user`    |
| Password         | `S3cureP@ssw0rd!`    |

> 💡 The host is `mysql` because the in-cluster MySQL **Service** is named `mysql` (see `mysql-deployment.yaml`).

### Step 2: Encode Secrets in Base64

Kubernetes `Secret` values must be base64-encoded:

```bash
echo -n 'three-tier-user' | base64
# Output: dGhyZWUtdGllci11c2Vy

echo -n 'S3cureP@ssw0rd!' | base64
# Output: UzNjdXJlUEBzc3cwcmQh
```

### Step 3: Create `mysql-secret.yaml`

```yaml
# apps/manifests/mysql-secret.yaml
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

This secret is consumed by the **MySQL pod** to initialize the database with your custom user.

### Step 4: (Optional) Create `backend-config.yaml` for Real Backends

If you replace `json-server` with a real backend (e.g., Node.js + MySQL), create a `ConfigMap`:

```yaml
# apps/manifests/backend-config.yaml
apiVersion: v1
kind: ConfigMap
meta
  name: backend-config
  namespace: three-tier-app

  DB_HOST: "mysql"
  DB_PORT: "3306"
  DB_NAME: "appdb"
```

Then reference both in your backend deployment:

```yaml
# In backend-deployment.yaml
envFrom:
  - configMapRef:
      name: backend-config
  - secretRef:
      name: mysql-secret
```

> 📝 **Note**: The current `json-server` backend does **not** use MySQL—it serves static `db.json`. This setup prepares you for future upgrades.

### Step 5: Security Notes

- 🔒 **Private Repos Only**: If you commit `mysql-secret.yaml` to Git, ensure your repository is **private**.
- 🛡️ **Production Recommendation**: For public repos or higher security, use:
  - [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
  - [External Secrets Operator](https://external-secrets.io/) with AWS Secrets Manager, HashiCorp Vault, etc.

### Step 6: Verification

After ArgoCD syncs, verify:

```bash
kubectl get secret mysql-secret -n three-tier-app
kubectl describe secret mysql-secret -n three-tier-app  # Keys visible, values redacted
```

---

## 🚀 Deployment Instructions

### Prerequisites

- Kubernetes cluster (v1.24+)
- `kubectl` configured
- ArgoCD installed in `argocd` namespace
- Ingress controller (e.g., NGINX) installed
- Container registry with `frontend` and `backend` images pushed

### Step 1: Fork or Clone This Repo

```bash
git clone https://github.com/ibrahemyasser/3Tier-deployment-with-ArgoCd.git
cd 3Tier-deployment-with-ArgoCd
```

### Step 2: Update Image Names

Edit the following files and replace image placeholders with your actual image URLs:

- `apps/manifests/frontend-deployment.yaml`
- `apps/manifests/backend-deployment.yaml`

Example:
```yaml
image: abdelrahmanfouuad/frontend:latest
```

### Step 3: Commit & Push to Your GitHub

```bash
git add .
git commit -m "Configure images"
git push origin main
```

### Step 4: Deploy ArgoCD Application

```bash
kubectl apply -f argocd/application.yaml
```

> This creates an ArgoCD `Application` that syncs manifests from your repo.

### Step 5: Access the Application

1. Get Ingress IP:
   ```bash
   kubectl get ingress -n three-tier-app
   ```
2. Add to `/etc/hosts`:
   ```bash
   echo "<INGRESS-IP> three-tier.local" | sudo tee -a /etc/hosts
   ```
3. Open in browser: [http://three-tier.local](http://three-tier.local)

You should see a **React Admin dashboard** displaying sample data from the backend.

---

## 🛠️ Customization

### Use External MySQL (Recommended for Production)

1. Delete `mysql-*.yaml` from `manifests/`
2. Create a `Secret` with your external DB credentials:
   ```yaml
   apiVersion: v1
   kind: Secret
   meta
     name: mysql-secret
     namespace: three-tier-app
   data:
     DB_HOST: <base64-encoded-host>
     DB_USER: ...
     DB_PASSWORD: ...
   ```
3. Update backend to read these env vars (modify `server.js` accordingly).

### Enable TLS on Ingress

Add TLS block to `ingress.yaml`:
```yaml
spec:
  tls:
    - hosts:
        - three-tier.example.com
      secretName: three-tier-tls
  rules:
    - host: three-tier.example.com
      ...
```

---

## 🔄 GitOps Workflow

- Any change to `apps/manifests/` → **auto-synced** by ArgoCD
- ArgoCD runs in **automated sync mode** with `prune` and `selfHeal`
- Namespace `three-tier-app` is auto-created

> 💡 **Never `kubectl apply` manually**—all changes must go through Git.

---

## 🧪 Validation

After sync, verify:

```bash
kubectl get pods -n three-tier-app
# Should show: frontend, backend, mysql

kubectl logs -n three-tier-app -l app=backend
# Should show: "JSON Server running on port 3000"

curl http://three-tier.local/api/posts
# Should return JSON data
```

---


