# Terraform Infrastructure: VPC + EKS Cluster

Цей проєкт демонструє розгортання повноцінної AWS інфраструктури за допомогою Terraform з використанням модульної архітектури. Проєкт використовує модульну архітектуру та best practices Terraform для масштабованих AWS рішень.

---

## Структура проєкту

```text
eks-vpc-cluster/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tf
├── backend.tf
├── README.md
│
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   └── backend.tf
│
├── eks/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   └── backend.tf
│
├── argocd/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   ├── backend.tf
│   └── values/
│       └── argocd-values.yaml
│
├── mlops-experiments/
│   ├── README.md
│   │
│   ├── argocd/
│   │   └── applications/
│   │       ├── grafana.yaml
│   │       ├── minio.yaml
│   │       ├── mlflow-env.yaml
│   │       ├── mlflow.yaml
│   │       ├── postgres.yaml
│   │       ├── prometheus.yaml
│   │       └── pushgateway.yaml
│   │
│   ├── best_model/
│   │   ├── MLmodel
│   │   ├── conda.yaml
│   │   ├── model.pkl
│   │   ├── python_env.yaml
│   │   └── requirements.txt
│   │
│   └── experiments/
│       ├── requirements.txt
│       └── train_and_push.py
│
└── screenshots/
    ├── agrocd-pods.png
    ├── argocd-apply.png
    ├── argocd-mlflow.png
    ├── argocd-ui.png
    ├── eks-terraform-apply.png
    ├── eks-terraform-init.png
    ├── kubectl-nodes.png
    ├── kubectl.png
    ├── vpc-terraform-apply.png
    └── vpc-terraform-init.png
```

---

## Мета проєкту

- Використання модульної структури Terraform
- Автоматичне створення VPC через офіційний модуль
- Розгортання EKS-кластера всередині VPC
- Створення двох node group (CPU workloads)
- Робота з `terraform_remote_state`, outputs та providers
- Підключення до Kubernetes через `kubectl`
- Розгортання ArgoCD у Kubernetes через Terraform 
- Налаштування GitOps підходу для автоматичного деплою застосунків

---

## Використані технології

### Infrastructure & Cloud
- **Terraform >= 1.5** — Infrastructure as Code для автоматизованого розгортання AWS-інфраструктури;
- **AWS (VPC, EKS, S3)** — хмарна платформа для розміщення Kubernetes-кластера та зберігання Terraform state;
- **Kubernetes** — оркестрація контейнеризованих застосунків.

### GitOps & Deployment
- **ArgoCD** — GitOps-інструмент для декларативного розгортання та синхронізації застосунків у Kubernetes;
- **Helm** — менеджер пакетів для встановлення та керування Kubernetes-застосунками.

### MLOps
- **MLflow** — відстеження ML-експериментів, логування параметрів, метрик та артефактів моделей;
- **MinIO** — S3-сумісне сховище для зберігання артефактів MLflow;
- **PostgreSQL** — backend store для зберігання метаданих MLflow;
- **Python 3.x** — реалізація скрипта для запуску та автоматизації ML-експериментів;
- **scikit-learn** — навчання та оцінювання моделей машинного навчання.

### Monitoring & Observability
- **Prometheus** — збір та зберігання метрик;
- **Prometheus PushGateway** — передача метрик від короткоживучих ML-завдань до Prometheus;
- **Grafana** — візуалізація та моніторинг метрик експериментів.

### CLI Tools & Version Control
- **kubectl** — керування ресурсами Kubernetes-кластера;
- **AWS CLI** — взаємодія з AWS-сервісами;
- **Git / GitHub** — контроль версій та зберігання GitOps-конфігурацій.

---

## Вимоги

Перед запуском переконайтесь, що встановлено та налаштовано:

### Infrastructure & Kubernetes

- **AWS CLI** (`aws configure`);
- **Terraform >= 1.5**;
- **kubectl**;
- **Helm**;
- IAM-користувач AWS з правами доступу до **EKS**, **VPC** та **S3**.

### Python Environment

- **Python 3.10+**;
- `pip`;
- віртуальне середовище (`venv`).

Залежності для запуску експериментів встановлюються командою:

```bash
pip install -r mlops-experiments/experiments/requirements.txt
```

### Доступ до кластера

Перед запуском MLOps-компонентів необхідно налаштувати доступ до EKS-кластера:

```bash
aws eks update-kubeconfig \
  --region eu-central-1 \
  --name demo-eks-cluster
```
---

## S3 Backend 

Для зберігання Terraform state використовувався віддалений backend на базі Amazon S3. Це дозволяє централізовано зберігати стан інфраструктури та уникати конфліктів при роботі з Terraform. 

Структура S3 bucket: 

```text 
tf-state-olena-eks-2026/ 
  ├── vpc/ 
  ├── eks/ 
  └── argocd/ 
```
Для кожного компонента інфраструктури використовується окремий Terraform.

---

## Outputs

Після успішного виконання `terraform apply` доступні вихідні параметри (outputs), які використовуються для перевірки створених ресурсів та передачі значень між модулями: 

- **VPC ID** — ідентифікатор створеної VPC; 
- **Private/Public Subnets** — список створених підмереж; 
- **Cluster Endpoint** — endpoint для взаємодії з EKS API Server; 
- **Cluster Name** — назва створеного EKS-кластера; 
- **Cluster Security Group ID** — ідентифікатор security group кластера (за наявності). 

Для перегляду доступних outputs використовується команда: 

```bash 
terraform output 
``` 

---

## Перевірка роботи 

Після внесення змін до конфігурацій Terraform рекомендується виконувати: 

```bash 
terraform plan 
terraform apply 
terraform output 
``` 

Це дозволяє перевірити заплановані зміни, застосувати їх та переглянути результати розгортання інфраструктури.

---

##  Розгортання

### 1. Ініціалізація VPC

```bash
cd vpc
terraform init
```
![Terraform init](screenshots/vpc-terraform-init.png)

```bash
terraform plan
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
terraform plan
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

### 4. Перевірка стану EKS-кластера

```bash
kubectl get nodes
```
![Nodes](screenshots/kubectl-nodes.png)

---

### 5. Налаштування ArgoCD

```bash
cd argocd 
terraform init 
terraform apply
```
![ArgoCD](screenshots/argocd-apply.png)

Після успішного розгортання було перевірено стан подів та сервісів у namespace `infra-tools`:

```bash
kubectl get pods -n infra-tools
kubectl get svc -n infra-tools
```
![PODS](screenshots/agrocd-pods.png)

---

## Доступ до веб-інтерфейсу ArgoCD

Для доступу до веб-інтерфейсу ArgoCD необхідно виконати port-forward через Kubernetes Service:

```bash 
kubectl port-forward svc/argocd-server -n infra-tools 8080:443
```

Після встановлення port-forward веб-інтерфейс ArgoCD буде доступний за адресою:

https://localhost:8080

![AgroCDUI](screenshots/argocd-ui.png)

Оскільки ArgoCD використовує самопідписаний SSL-сертифікат, браузер може відобразити попередження про безпеку. У такому випадку необхідно обрати:

Додатково → Перейти на localhost (небезпечний сайт)

Початковий пароль користувача admin можна отримати за допомогою команди:

```bash 
kubectl -n infra-tools get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
```

Після входу до веб-інтерфейсу ArgoCD можна переглянути стан синхронізації застосунків та контролювати процес їх розгортання в кластері Kubernetes що показано на скріншоті вище.

---

# MLOps: MLflow Experiment Tracking та Monitoring

У межах цього етапу проєкту було реалізовано повноцінну MLOps-інфраструктуру для відстеження експериментів машинного навчання та моніторингу метрик моделей, після успішної підготовки  Kubernetes-кластер та ArgoCD.

## Використані компоненти

* **MLflow Tracking Server** — для логування параметрів, метрик та артефактів моделей;
* **MinIO** — S3-сумісне сховище для зберігання моделей та артефактів;
* **PostgreSQL** — backend для зберігання метаданих MLflow;
* **Prometheus PushGateway** — проміжний сервіс для передачі метрик експериментів;
* **Prometheus** — система збору та зберігання метрик;
* **Grafana** — візуалізація метрик експериментів;
* **ArgoCD** — GitOps-деплой усіх компонентів.

## Структура MLOps-компонентів

```
├── mlops-experiments/
│   ├── README.md
│   │
│   ├── argocd/
│   │   └── applications/
│   │       ├── grafana.yaml
│   │       ├── minio.yaml
│   │       ├── mlflow-env.yaml
│   │       ├── mlflow.yaml
│   │       ├── postgres.yaml
│   │       ├── prometheus.yaml
│   │       └── pushgateway.yaml
│   │
│   ├── best_model/
│   │   ├── MLmodel
│   │   ├── conda.yaml
│   │   ├── model.pkl
│   │   ├── python_env.yaml
│   │   └── requirements.txt
│   │
│   └── experiments/
│       ├── requirements.txt
│       └── train_and_push.py

```

## Створення та розгортання MLflow-інфраструктури через ArgoCD

Для кожного компонента інфраструктури було створено окремий ArgoCD Application або окрему конфігурацію в межах GitOps-структури.

Було створено applications для:

* **MinIO** 
* **PostgreSQL** 
* **MLflow Tracking Server**
* **Prometheus PushGateway**
* **Prometheus** 
* **Grafana**

Після створення applications було виконано синхронізацію в ArgoCD.

![ArgoCDApp](screenshots/argocd-applications.png)

---

## 1. Розгортання MinIO

MinIO було розгорнуто як S3-compatible object storage для зберігання MLflow artifacts.

Після розгортання було створено bucket:

```
mlflow-artifacts

```

Саме цей bucket використовується MLflow Tracking Server для збереження моделей, метрик, параметрів, артефактів експериментів та інших файлів.

Було перевірено і підтверджено:

- статус pod-ів MinIO;
- доступність MinIO UI;
- наявність bucket mlflow-artifacts;
- коректну роботу port forwarding;  
- правильність налаштованих Access Key та Secret Key;
- коректність access key та secret key.

```bash
kubectl get pods 
kubectl get svc
```

![Pods&SVC](screenshots/kubectl-get-pods-and-svc.png)

Після успішного виконання команди веб-інтерфейс MinIO став доступним за адресою http://localhost:9001


```bash
kubectl port-forward -n mlflow svc/minio-mlflow 9001:9001
```

Для входу до MinIO Console були використані попередньо налаштовані облікові дані (Access Key та Secret Key). Через веб-інтерфейс було перевірено наявність bucket mlflow-artifacts, який використовується MLflow Tracking Server для зберігання моделей, метрик, параметрів експериментів та інших артефактів.

![MinioUI](screenshots/Minio-ui.png)

---

## 2. Розгортання PostgreSQL

PostgreSQL було розгорнуто як реляційну базу даних для використання MLflow Tracking Server як backend store. PostgreSQL забезпечує зберігання інформації про експерименти, запуски (runs), параметри, метрики, теги та інші метадані MLflow.

Було перевірено і підтверджено:

- статус pod-ів PostgreSQL;
- доступність PostgreSQL Service;
- коректну роботу port forwarding;
- успішне підключення до PostgreSQL;
- коректність налаштованих облікових даних;
- наявність бази даних mlflow.

Для перевірки стану ресурсів Kubernetes були використані команди:

```bash
kubectl get pods
kubectl get svc

```
![Pods&SVC](screenshots/kubectl-get-pods-and-svc.png)


Після успішного виконання команди у терміналі для перевірки підключення до бази даних використовувався клієнт PostgreSQL:

```bash
kubectl port-forward -n mlflow svc/postgres-mlflow-postgresq 5433:5432
psql "postgresql://mlflow:mlflowpass@localhost:5433/mlflow"

```
![BDstart](screenshots/bd-starting.png)

У результаті було отримано перелік баз даних PostgreSQL, серед яких була присутня база даних mlflow, що використовується MLflow Tracking Server для зберігання інформації про експерименти та їх метадані. Таким чином було підтверджено успішне розгортання PostgreSQL та його готовність до роботи як backend store для MLflow Tracking Server.

![BDcheck](screenshots/bd-check.png)

---

## 3. Розгортання сервісу Prometheus PushGateway

Сервіс Prometheus PushGateway було розгорнуто в кластері Kubernetes для забезпечення збору метрик від короткоживучих (batch) завдань та застосунків, які не можуть бути безпосередньо опитані Prometheus. PushGateway виступає проміжною ланкою, що дозволяє надсилати користувацькі метрики до системи моніторингу Prometheus для подальшого аналізу та візуалізації.

Було перевірено і підтверджено:

- статус pod-ів Prometheus PushGateway;
- доступність Service для PushGateway;
- коректну роботу port forwarding;
- успішний запуск вебінтерфейсу PushGateway;
- доступність сторінки метрик через браузер;
- можливість надсилання та відображення тестових метрик у PushGateway;
- готовність PushGateway до інтеграції з Prometheus для збору метрик.

Для перевірки стану ресурсів Kubernetes були використані команди:

```bash
kubectl get pods
kubectl get svc

```
![Pods&SVC](screenshots/kubectl-get-pods-and-svc.png)


Після підтвердження успішного запуску pod-ів та сервісів було налаштовано перенаправлення портів для отримання доступу до вебінтерфейсу PushGateway з локальної машини:

```bash
kubectl port-forward -n monitoring svc/prometheus-pushgateway 9092:9091
```
![PushgatewayStart](screenshots/pushgateway-start.png)

Після виконання команди вебінтерфейс PushGateway став доступним за адресою:

```text
http://localhost:9092/
```

Після надсилання метрики було підтверджено її успішне відображення у вебінтерфейсі PushGateway, що свідчить про коректне функціонування сервісу та готовність до інтеграції з Prometheus для централізованого моніторингу застосунків.

![PushgatewayUI](screenshots/pushgatewayUi.png)

---

## 4. Розгортання сервісу Prometheus 

Сервіс Prometheus було розгорнуто в кластері Kubernetes для забезпечення централізованого збору, зберігання та обробки метрик від компонентів інфраструктури та застосунків. Prometheus виконує періодичне опитування (scraping) визначених цільових сервісів, зокрема PushGateway, що дозволяє здійснювати моніторинг стану системи та аналіз продуктивності в режимі реального часу.

Було перевірено і підтверджено:

- статус pod-ів Prometheus;
- доступність Service для Prometheus;
- успішний запуск вебінтерфейсу Prometheus;
- доступність сторінки моніторингу через браузер;
- наявність та коректне відображення цільових сервісів (Targets);
- успішний збір метрик від PushGateway;

Для перевірки стану ресурсів Kubernetes були використані команди:

```bash
kubectl get pods
kubectl get svc

```
![Pods&SVC](screenshots/kubectl-get-pods-and-svc.png)


Після підтвердження успішного запуску pod-ів та сервісів було налаштовано перенаправлення портів для отримання доступу до вебінтерфейсу Prometheus з локальної машини:

```bash
kubectl port-forward -n monitoring svc/prometheus-server 9093:80
```
![PrometheusStart](screenshots/prometheus-start.png)

Після виконання команди вебінтерфейс PushGateway став доступним за адресою:

```text
http://localhost:9092/
```

Для перевірки коректності налаштування збору метрик було відкрито розділ Status → Targets, де підтверджено успішний стан (UP) цільових сервісів, зокрема PushGateway. У результаті було підтверджено коректне функціонування сервісу Prometheus, успішний збір метрик від підключених компонентів та готовність системи до подальшої інтеграції з інструментами візуалізації та моніторингу, зокрема Grafana.

![PrometheusUI](screenshots/prometheus-ui.png)

---

## 5. Розгортання сервісу Grafana

Сервіс Grafana було розгорнуто в кластері Kubernetes для забезпечення візуалізації та аналізу метрик, зібраних системою моніторингу Prometheus. Grafana дозволяє створювати інтерактивні інформаційні панелі (dashboards), що забезпечують зручний моніторинг стану інфраструктури та застосунків у режимі реального часу.

Було перевірено і підтверджено:

- статус pod-ів Grafana;
- доступність Service для Grafana;
- успішний запуск вебінтерфейсу Grafana;
- доступність сторінки Grafana через браузер;
- успішне підключення джерела даних Prometheus (Data Source);
- коректне отримання метрик із Prometheus;
- успішне створення та відображення інформаційних панелей моніторингу (Dashboards).

Для перевірки стану ресурсів Kubernetes були використані команди:

```bash
kubectl get pods
kubectl get svc

```
![Pods&SVC](screenshots/kubectl-get-pods-and-svc.png)


Після підтвердження успішного запуску pod-ів та сервісів було налаштовано перенаправлення портів для отримання доступу до вебінтерфейсу Grafana з локальної машини:

```bash
kubectl port-forward -n monitoring svc/grafana 3000:80
```
![GrafanaStart](screenshots/grafana-start.png)

Після підтвердження успішного запуску pod-ів та сервісів було налаштовано перенаправлення портів для отримання доступу до вебінтерфейсу Grafana з локальної машини:

```text
http://localhost:3000
```

Для входу до системи були використані облікові дані адміністратора, визначені під час розгортання сервісу.

Для візуалізації зібраних метрик було створено інформаційну панель моніторингу (Dashboard), що використовує дані, отримані з Prometheus. Було підтверджено коректне відображення показників та оновлення даних у реальному часі.

![GrafanaCheck](screenshots/grafana1check.png)

---

## 6. Розгортання MLflow Tracking Server

MLflow Tracking Server було розгорнуто в кластері Kubernetes для централізованого керування експериментами машинного навчання. Сервер забезпечує реєстрацію та зберігання інформації про запуски експериментів, параметри моделей, метрики, артефакти та інші метадані. Як backend store використовувалася база даних PostgreSQL, а для зберігання артефактів було налаштовано відповідне сховище.

Було перевірено і підтверджено:

- статус pod-ів MLflow Tracking Server;
- доступність Service для MLflow;
- коректну роботу port forwarding;
- успішний запуск вебінтерфейсу MLflow;
- доступність сторінки експериментів через браузер;
- коректне підключення MLflow до PostgreSQL як backend store.

Для перевірки стану ресурсів Kubernetes були використані команди:

```bash
kubectl get pods
kubectl get svc

```
![Pods&SVC](screenshots/kubectl-get-pods-and-svc.png)


Після підтвердження успішного запуску pod-ів та сервісів було налаштовано перенаправлення портів для отримання доступу до вебінтерфейсу MLflow з локальної машини:

```bash
kubectl port-forward -n mlflow svc/mlflow 5000:5000

```
![MLflowTrack](screenshots/MLflow-tracking.png)

У результаті відкриття вебінтерфейсу MLflow було підтверджено його коректну роботу. У UI відображалися успішно зареєстровані експерименти та запуски, що свідчить про правильне функціонування MLflow Tracking Server і його взаємодію з PostgreSQL як backend store.

![BDcheck](screenshots/MLflowUI.png)

---

## 7. Запуск ML-експерименту

Запуск скрипта `train_and_push.py` виконувався локально з директорії `mlops-experiments/experiments` у віртуальному Python-середовищі `.venv`.

Перед запуском необхідно активувати віртуальне середовище:

```bash
source .venv/bin/activate
```

Після успішної активації в терміналі має відображатися префікс:

```text
(.venv)
```

Далі потрібно перейти до директорії з експериментами:

```bash
cd mlops-experiments/experiments
```

Перед запуском скрипта були налаштовані змінні середовища для підключення до MinIO, MLflow Tracking Server та Prometheus PushGateway:

```bash
export AWS_ACCESS_KEY_ID=minio
export AWS_SECRET_ACCESS_KEY=minio123
export MLFLOW_S3_ENDPOINT_URL=http://localhost:9000
export MLFLOW_TRACKING_URI=http://localhost:5000
export PUSHGATEWAY_URL=localhost:9092
```

Після налаштування змінних середовища було запущено скрипт:

```bash
python train_and_push.py
```

У процесі виконання скрипт автоматично:

- завантажував датасет **Iris**;
- запускав серію експериментів із різними значеннями гіперпараметрів `learning_rate` та `epochs`;
- створював окремий **MLflow Run** для кожного запуску;
- логував параметри та метрики (`accuracy`, `loss`) до **MLflow**;
- зберігав моделі як артефакти у **MinIO**;
- надсилав метрики `mlflow_accuracy` та `mlflow_loss` до **Prometheus PushGateway**;
- визначав найкращу модель за максимальним значенням `accuracy`;
- копіював найкращу модель до директорії `best_model/`.

У результаті виконання було отримано такі значення метрик:

```text
run_id=ce9feab8838246b48217e4c0b2fa8ab5 learning_rate=0.001 epochs=50 accuracy=0.7333 loss=0.5634

run_id=e1ea5aae233f424ebc8e6a9dce304f05 learning_rate=0.005 epochs=50 accuracy=0.8000 loss=0.4259

run_id=9a054b1761364bbab5fe1d81c8e7048b learning_rate=0.01 epochs=100 accuracy=0.8667 loss=0.3280

run_id=b991656abd804370a4ed76e5a53270ee learning_rate=0.05 epochs=100 accuracy=0.9000 loss=0.2322

run_id=a5e310c588fb44879af5b10ed28cedce learning_rate=0.1 epochs=150 accuracy=0.9333 loss=0.1950
```

Після завершення всіх експериментів скрипт автоматично визначив найкращу модель:

```text
Best model:
run_id=a5e310c588fb44879af5b10ed28cedce
accuracy=0.9333
loss=0.1950
params={'learning_rate': 0.1, 'epochs': 150}
saved_to=/Users/olenatrzewik/eks-vpc-cluster/mlops-experiments/best_model
```

Таким чином, найкращою виявилася модель із параметрами:

- `learning_rate = 0.1`
- `epochs = 150`
- `accuracy = 0.9333`
- `loss = 0.1950`

Після визначення найкращої моделі вона була автоматично збережена в директорії:

```text
mlops-experiments/best_model/
```

Наведений нижче скріншот демонструє успішне виконання скрипта `train_and_push.py` у віртуальному середовищі `.venv`, логування експериментів у MLflow, обчислення метрик та автоматичний вибір найкращої моделі.

![Train and Push Execution](screenshots/train-and-push-terminal.png)

---

## Результат

У межах цього проєкту було реалізовано повноцінну MLOps-інфраструктуру на базі Kubernetes та GitOps-підходу.

У результаті виконання роботи було:

- розгорнуто сервіси **MLflow**, **MinIO**, **PostgreSQL** та **Prometheus PushGateway** декларативно через **ArgoCD**;
- налаштовано **MLflow Tracking Server** для логування параметрів, метрик та артефактів експериментів;
- використано **MinIO** як S3-сумісне сховище для збереження моделей та інших артефактів;
- налаштовано **PostgreSQL** як backend store для зберігання метаданих MLflow;
- реалізовано Python-скрипт `train_and_push.py` для автоматизованого запуску ML-експериментів;
- виконано серію експериментів із різними значеннями гіперпараметрів та автоматичним логуванням результатів у MLflow;
- налаштовано передачу метрик `accuracy` та `loss` до **Prometheus PushGateway** для подальшого моніторингу;
- підтверджено успішний збір метрик у **Prometheus** та їх візуалізацію в **Grafana**;
- реалізовано автоматичний вибір найкращої моделі за значенням `accuracy`;
- забезпечено автоматичне збереження найкращої моделі в директорії `best_model/`.

Таким чином, було побудовано повний MLOps-пайплайн: від розгортання інфраструктури та відстеження експериментів до моніторингу метрик і автоматичного визначення найкращої моделі.

---


# Очищення інфраструктури (Infrastructure Cleanup)

Після завершення роботи з проєктом рекомендується видалити створені AWS-ресурси для уникнення додаткових витрат. Видалення інфраструктури виконується у зворотному порядку відносно процесу розгортання з урахуванням залежностей між компонентами.

## 1. Видалення застосунків, розгорнутих через ArgoCD

Спочатку необхідно видалити всі застосунки, керовані ArgoCD:

- MLflow Tracking Server;
- MinIO;
- PostgreSQL;
- Prometheus PushGateway;
- Prometheus;
- Grafana.

Видалення можна виконати через веб-інтерфейс ArgoCD або за допомогою Kubernetes:

```bash
kubectl delete applications --all -n argocd
```

Після цього рекомендується переконатися, що пов'язані ресурси були успішно видалені:

```bash
kubectl get pods --all-namespaces
kubectl get pvc --all-namespaces
```

---

## 2. Видалення ArgoCD

Після очищення застосунків необхідно видалити саму інсталяцію ArgoCD:

```bash
cd argocd

terraform plan -destroy
terraform destroy
```

За потреби можна перевірити відсутність відповідного namespace:

```bash
kubectl get namespaces
```

---

## 3. Видалення EKS-кластера

Наступним кроком виконується видалення Kubernetes-кластера та пов'язаних ресурсів AWS:

```bash
cd eks
terraform plan -destroy
terraform destroy
```

У результаті буде видалено:

- EKS Cluster;
- Managed Node Groups;
- IAM Roles і пов'язані політики;
- Security Groups, створені для кластера.

Перевірити успішність видалення можна командою:

```bash
aws eks list-clusters
```

---

## 4. Видалення мережевої інфраструктури

Після успішного видалення EKS-кластера можна видалити мережеві ресурси:

```bash
cd vpc

terraform plan -destroy
terraform destroy
```

Буде видалено:

- VPC;
- Public та Private Subnets;
- Internet Gateway;
- NAT Gateway;
- Route Tables;
- Security Groups та інші пов'язані мережеві компоненти.

---

## 5. Очищення Terraform Backend (опціонально)

Якщо подальше використання інфраструктури не планується, можна видалити Terraform state з S3:

```bash
aws s3 rm s3://tf-state-olena-eks-2026/vpc/ --recursive
aws s3 rm s3://tf-state-olena-eks-2026/eks/ --recursive
aws s3 rm s3://tf-state-olena-eks-2026/argocd/ --recursive
```

За необхідності можна видалити S3 bucket повністю:

```bash
aws s3 rb s3://tf-state-olena-eks-2026 --force
```

> **Примітка:** Terraform state слід видаляти лише після повного знищення всіх ресурсів інфраструктури.

Очищення інфраструктури виконувалося у зворотному порядку відносно процесу розгортання: спочатку було видалено застосунки та ArgoCD, далі EKS-кластер, мережеву інфраструктуру та Terraform state. Такий підхід дозволяє коректно обробляти залежності між компонентами, уникати помилок під час видалення ресурсів та мінімізувати витрати на використання AWS-сервісів.

---
