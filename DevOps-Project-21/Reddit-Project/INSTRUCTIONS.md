# 🛠️ Deployment & Operations Guide

This guide covers the deployment, monitoring, and teardown of the DevSecOps Reddit Clone project.

## Phase 1: Infrastructure Provisioning (Terraform)
Navigate to the Terraform directory to build the AWS infrastructure.

1. Initialize Terraform plugins: `terraform init`
2. Validate the configuration: `terraform validate`
3. Provision the infrastructure: `terraform apply --auto-approve`
4. Update your local kubeconfig to connect to the new EKS cluster: `aws eks update-kubeconfig --name <your-cluster-name> --region us-east-1`

## Phase 2: CI Pipeline (Jenkins & Security)
Configure Jenkins to handle the build and security scanning.

1. Install required Jenkins plugins: Docker, SonarQube Scanner, Kubernetes CLI.
2. Add credentials for Docker Hub, GitHub, and SonarQube in Jenkins.
3. Run the Jenkins pipeline (`Jenkinsfile`).
4. Verify that SonarQube passes the quality gate and Trivy completes the vulnerability scan before the Docker image is pushed to Docker Hub.

## Phase 3: CD Pipeline (ArgoCD & GitOps)
Set up ArgoCD to automate the deployment of Kubernetes manifests.



1. Create the ArgoCD namespace: `kubectl create namespace argocd`
2. Install ArgoCD: `kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml`
3. Port-forward the ArgoCD UI to your local machine: `kubectl port-forward svc/argocd-server -n argocd 8080:443`
4. Retrieve the default admin password: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"` (Decode the Base64 output).
5. Login to `https://localhost:8080`, connect your GitHub repository, and sync the Reddit application.

## Phase 4: Networking (Nginx Ingress)
Expose the application to the internet securely.

1. Install the Nginx Ingress Controller for AWS: `kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/aws/deploy.yaml`
2. Apply your `ingress.yaml` file (ensure it contains CORS annotations and a catch-all rule).
3. Retrieve the AWS Load Balancer URL: `kubectl get svc -n ingress-nginx`
4. Map your custom domain to the AWS Load Balancer URL via your DNS provider (CNAME or Alias record).

## Phase 5: Monitoring (Prometheus & Grafana)
Deploy the monitoring stack using Helm.

1. Add the Prometheus Helm repository: `helm repo add prometheus-community https://prometheus-community.github.io/helm-charts`
2. Update Helm: `helm repo update`
3. Create a monitoring namespace: `kubectl create namespace monitoring`
4. Install the stack: `helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring`
5. Port-forward Grafana to access the dashboards: `kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80`

---

## 🛑 Troubleshooting Real-World Issues

### 1. Connection Timed Out (AWS Security Groups)
* **Symptom:** Browser spins and eventually times out when accessing the Load Balancer URL.
* **Fix:** The AWS Security Group attached to the Load Balancer or Worker Nodes is blocking incoming traffic. Navigate to AWS EC2 > Security Groups and add an Inbound Rule allowing TCP Port 80 from `0.0.0.0/0`.

### 2. 404 Not Found (Ingress Routing)
* **Symptom:** The AWS Load Balancer URL returns a raw "404 Not Found" from Nginx.
* **Fix:** The Ingress controller is strictly filtering by Hostname. Add a "Catch-All" rule (a rule without a specific `host` defined) to your `ingress.yaml` to allow raw AWS URL traffic, or ensure your DNS is fully propagated.

### 3. ArgoCD Out of Sync
* **Symptom:** Changes pushed to GitHub (like updating the `ingress.yaml`) are not reflecting in the cluster.
* **Fix:** Log into the ArgoCD UI, click on the application, click "Refresh" to force a Git pull, and then click "Sync" to apply the changes.

### 4. Cross-Origin Resource Sharing (CORS) Errors
* **Symptom:** The frontend loads, but API calls fail. The browser console shows `Origin is not allowed by Access-Control-Allow-Origin`.
* **Fix:** Add the following annotations to your `ingress.yaml` metadata to handle CORS at the infrastructure level:
  `nginx.ingress.kubernetes.io/enable-cors: "true"`
  `nginx.ingress.kubernetes.io/cors-allow-origin: "*"`

---

## 🧹 Cost-Saving Teardown (Critical)
Always destroy resources when finished to avoid AWS charges.

1. **Delete Kubernetes Load Balancers:** First, delete the Ingress and Service load balancers using `kubectl delete svc <service-name>`. If you skip this, AWS will leave orphaned load balancers running.
2. **Destroy Infrastructure:** Run `terraform destroy --auto-approve` to tear down the EKS cluster and VPC.
3. **Terminate Jenkins:** Manually terminate the Jenkins EC2 instance in the AWS Console.
4. **Manual Sweep:** Double-check AWS EC2 > Load Balancers and AWS EC2 > Volumes to ensure nothing was left behind.