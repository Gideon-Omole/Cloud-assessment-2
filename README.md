
# Technical Report: End-to-End Deployment of a Retail Application on AWS EKS with ALB Integration


## 1. Git Repository Link

`https://github.com/Gideon-Omole/Cloud-assessment-2.git`

The repository contains:

* **infra/** → Terraform IaC for VPC, EKS, IAM, networking.
* **k8s-manifest/** → Kubernetes manifests for the retail app deployment.
* **.github/workflows/** → GitHub Actions CI/CD pipeline for Terraform automation (plan & apply).

---

## 2. Deployment & Architecture Guide

### Architecture Overview

**Components:**

* **Networking (VPC):**

  * 1 VPC with public and private subnets across multiple AZs.
  * Internet Gateway + NAT Gateway for outbound traffic from private subnets.
  * Route tables for proper traffic segmentation.

* **Compute (EKS):**

  * Amazon EKS cluster deployed into private subnets.
  * Worker nodes running workloads (pods for microservices).

* **Application (Retail Store Sample App):**

  * Deployed via `kubectl apply -f kubernetes.yaml`.
  * Services: carts, catalog, checkout, orders, UI, backed by MySQL, Redis, PostgreSQL, DynamoDB, RabbitMQ.
  * The **UI service** is exposed via an AWS Application Load Balancer (type = LoadBalancer).

* **IAM & Security:**

  * Cluster role bindings for developers (read-only).
  * Separate IAM policies for admin vs. developer.

* **CI/CD:**

  * GitHub Actions pipeline.
  * Feature branches → run `terraform plan`.
  * Merges to `main` → trigger `terraform apply`.
  * Remote backend: S3 + DynamoDB for state management & locking.

---

### Architecture Diagram

```plaintext
                  +-----------------------------+
                  |        AWS Region           |
                  |                             |
                  |  +----------------------+   |
Internet  <-----> |  |  VPC (10.0.0.0/16)  |   |
                  |  |                      |   |
                  |  |  +----------------+  |   |
                  |  |  | Public Subnets |  |   |
                  |  |  |  ALB (UI svc)  |<---------+
                  |  |  +----------------+  |   |   |
                  |  |                      |   |   |
                  |  |  +----------------+  |   |   |
                  |  |  | Private Subnets|  |   |   |
                  |  |  |   EKS Cluster  |  |   |   |
                  |  |  |   (Pods:       |  |   |   |
                  |  |  |   carts,       |  |   |   |
                  |  |  |   catalog,     |  |   |   |
                  |  |  |   checkout,    |  |   |   |
                  |  |  |   orders, UI)  |  |   |   |
                  |  |  +----------------+  |   |   |
                  |  |                      |   |   |
                  |  +----------------------+   |   |
                  |                             |
                  +-----------------------------+
```

---

### Accessing the Application

1. Get the service URL:

   ```bash
   kubectl get svc ui
   ```

   Example output:

   ```
   NAME   TYPE           CLUSTER-IP     EXTERNAL-IP                           PORT(S)  AGE
   ui     LoadBalancer   10.100.200.10  a1b2c3d4e5f6g7h8.elb.amazonaws.com    80/TCP   10m
   ```
2. Open in browser:

   ```
   http://a1b2c3d4e5f6g7h8.elb.amazonaws.com
   ```

---

## 3. Developer Read-Only Access

### IAM User

* IAM User: `dev-readonly`
* Access Key ID & Secret: shared securely (via AWS Secrets Manager or password manager).

### AWS Console Access

* Login using IAM user credentials.
* Has read-only policies for EKS & EC2.

### Kubernetes Access

1. Configure kubeconfig:

   ```bash
   aws eks update-kubeconfig --name staging-altsch_project --region eu-west-2
   ```
2. Validate:

   ```bash
   kubectl get pods --all-namespaces
   ```

---

