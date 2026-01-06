import torch
import torchvision.models as models

model = models.mobilenet_v2(pretrained=True)
model.eval()

example_input = torch.randn(1, 3, 224, 224)
traced_model = torch.jit.trace(model, example_input)
traced_model.save("model.pt")

print("Model saved as model.pt")
