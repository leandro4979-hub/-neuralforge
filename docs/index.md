# NeuralForge

**Experimental AI systems, automation workflows, and futuristic tooling.**

NeuralForge is a Python framework designed for building and experimenting with AI-driven automation and neural network workflows. It provides a modular foundation for developing cutting-edge AI applications.

## ✨ Features

- **Modular Architecture**: Clean, maintainable code structure with separate modules for different functionalities
- **Machine Learning Utilities**: Pre-built data preprocessing, model training, and data loading utilities
- **Neural Network Support**: PyTorch-based neural network implementations
- **Type Hints**: Full type annotation support for better code quality
- **Modern Python**: Built for Python 3.10+ with modern best practices
- **Comprehensive Testing**: Full test coverage with pytest

## 🚀 Quick Start

### Installation

```bash
pip install -e ".[dev]"
```

### Basic Usage

```python
from neuralforge import hello

print(hello())  # "Hello from NeuralForge!"
```

### Machine Learning Example

```python
import numpy as np
from neuralforge.ml import train_simple_model, SyntheticDataLoader

# Generate synthetic data
loader = SyntheticDataLoader(n_samples=1000, n_features=10, task="regression")
X, y = loader.load()

# Train a model
model = train_simple_model(X, y, input_size=10, epochs=50)

# Make predictions
X_test = np.random.randn(5, 10)
import torch
with torch.no_grad():
    predictions = model(torch.FloatTensor(X_test))
```

## 📚 Documentation

- **[Getting Started](getting-started/installation.md)**: Installation and setup instructions
- **[API Reference](api/core.md)**: Complete API documentation
- **[Development](development/contributing.md)**: Contribution guidelines and development practices

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](development/contributing.md) for details on how to get started.

## 📄 License

NeuralForge is licensed under the [MIT License](about/license.md).

---

*Built with ❤️ for the open-source community*
