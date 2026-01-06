import torch
from torchvision import transforms
from PIL import Image
import sys

# Перевірка аргументів командного рядка
if len(sys.argv) < 2:
    print("Використання: python inference.py <шлях_до_зображення>")
    sys.exit(1)

image_path = sys.argv[1]

# Завантаження TorchScript-моделі
model = torch.jit.load("model.pt")
model.eval()

# Попередня обробка зображення
preprocess = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406],
                         std=[0.229, 0.224, 0.225]),
])

image = Image.open(image_path).convert("RGB")
input_tensor = preprocess(image)
input_batch = input_tensor.unsqueeze(0)  # batch dimension

# Інференс
with torch.no_grad():
    output = model(input_batch)
    probabilities = torch.nn.functional.softmax(output[0], dim=0)

# Топ-3 класів
top3_prob, top3_catid = torch.topk(probabilities, 3)
for i in range(top3_prob.size(0)):
    print(f"Клас {top3_catid[i].item()} — ймовірність {top3_prob[i].item():.4f}")
