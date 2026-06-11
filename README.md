# Terraform Infrastructure: VPC + EKS Cluster

Цей проєкт демонструє розгортання повноцінної AWS інфраструктури за допомогою Terraform з використанням модульної архітектури.

---

## Структура проєкту

```
eks-vpc-cluster/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tf
├── backend.tf
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   └── backend.tf
├── eks/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   └── backend.tf
└── README.md
```

---

## Мета проєкту

- Використання модульної структури Terraform
- Автоматичне створення VPC через офіційний модуль
- Розгортання EKS-кластера всередині VPC
- Створення двох node group (CPU workloads)
- Робота з `terraform_remote_state`, outputs та providers
- Підключення до Kubernetes через `kubectl`

---

## Використані технології

- Terraform >= 1.5
- AWS (VPC, EKS, S3)
- kubectl
- AWS CLI

---

## Вимоги

Перед запуском переконайтесь, що встановлено:

- AWS CLI (`aws configure`)
- Terraform
- kubectl
- IAM користувач з правами: EKS, VPC, S3

---

##  Розгортання

### 1. Ініціалізація VPC

```bash
cd vpc
terraform init
```
![Terraform init](screenshots/vpc-terraform-init.png)

```bash
terraform apply
```
![Terraform apply](screenshots/vpc-terraform-apply.png)


---

### 2. Ініціалізація EKS

```bash
cd eks
terraform init
```
![EKS cluster](screenshots/eks-terraform-init.png)

```bash
terraform apply
```
![EKS cluster](screenshots/eks-terraform-apply.png)

---

### 3. Налаштування kubectl

```bash
aws eks update-kubeconfig \
  --region eu-central-1 \
  --name demo-eks-cluster
```
![kubectl](screenshots/kubectl.png)

---

### 4. Перевірка кластера

```bash
kubectl get nodes
```
![Nodes](screenshots/kubectl-nodes.png)

---

## Архітектура

- VPC створено через офіційний Terraform модуль
- EKS розгорнуто всередині VPC
- Node groups:
  - CPU nodes (t3.micro)
  - додаткові workload групи
- Remote state зберігається у S3

---

## S3 Backend

```
tf-state-olena-eks-2026/
├── vpc/
└── eks/
```

---

## Outputs

Після `terraform apply` доступні:

- VPC ID
- Subnets
- Cluster endpoint
- Cluster name

---

## Перевірка роботи

```bash
terraform plan
terraform apply
terraform output
```

---

## Очищення інфраструктури

```bash
terraform destroy
```

---

## Результат

Після успішного застосування описаних вище команд результат є наступним:

- Створено VPC інфраструктуру
- Розгорнуто EKS кластер
- Доступ через kubectl налаштовано
- Node groups працюють і доступні

---

## Примітка

Проєкт використовує модульну архітектуру та best practices Terraform для масштабованих AWS рішень.