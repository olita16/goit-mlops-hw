# Lesson 3 — TorchScript Model + Docker

Цей проєкт демонструє контейнеризацію ML-моделі (PyTorch TorchScript) з двома Docker-образами: **fat** і **slim**.  

---

## Структура папки `lesson-3`

```
lesson-3/
├── Dockerfile.fat       # Повний образ з усіма залежностями
├── Dockerfile.slim      # Оптимізований multi-stage образ
├── export_model.py      # Скрипт для збереження TorchScript моделі
├── inference.py         # Скрипт для запуску inference
├── install_dev_tools.sh # Bash-скрипт для підготовки середовища
├── model.pt             # TorchScript модель
├── requirements.txt     # Python-залежності
├── comparison.txt       # Порівняння образів
└── README.md            # Ця інструкція
```

---

## Встановлення та запуск

### 1. Підготовка середовища (опційно)
На Mac переконайтеся, що встановлено:

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- Python ≥ 3.9

Якщо потрібен Bash-скрипт для Linux, можна запустити:

```bash
bash install_dev_tools.sh
```

---

### 2. Побудова Docker-образів

Перейти у корінь репозиторію (`goit-mlops-hw`) і виконати:

```bash
# Fat-образ
docker build -f lesson-3/Dockerfile.fat -t fat-image lesson-3

# Slim-образ
docker build -f lesson-3/Dockerfile.slim -t slim-image lesson-3
```

---

### 3. Запуск inference

Приклад запуску **зображення `example.jpg`** (папка `lesson-3`):

```bash
docker run --rm -v $(pwd)/lesson-3:/app fat-image python inference.py example.jpg
docker run --rm -v $(pwd)/lesson-3:/app slim-image python inference.py example.jpg
```

> Скрипт виводить топ-3 класи з ймовірностями.

---

### 4. Порівняння образів

| Образ       | Розмір | Коментар |
|------------|--------|----------|
| fat-image  | 1.73 GB | Повний образ, усі залежності встановлені |
| slim-image | 757 MB  | Оптимізований, multi-stage build, менше зайвих пакетів |

---

### 5. Примітки

- Fat-образ великий через повні Python-пакети та apt-залежності.  
- Slim-образ менший, підходить для production.  
- Модель TorchScript (`model.pt`) збережена за допомогою `torch.jit`.  


