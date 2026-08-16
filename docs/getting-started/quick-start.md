# Quick Start

Get started with NeuralForge in just a few minutes!

## Basic Usage

### Import the Package

```python
import neuralforge

# Check version
print(neuralforge.__version__)  # "0.1.0"

# Simple greeting
print(neuralforge.hello())  # "Hello from NeuralForge!"

# Greet someone specific
print(neuralforge.hello("Alice"))  # "Hello, Alice! Welcome to NeuralForge."
```

### Core Functions

The `core` module provides basic functionality:

```python
from neuralforge.core import hello, run, NeuralForgeError

# Use the hello function
message = hello("Developer")

# Run the core workflow
run()

# Handle custom errors
try:
    raise NeuralForgeError("Something went wrong")
except NeuralForgeError as e:
    print(f"Error: {e}")
```

## Machine Learning Examples

### Data Preprocessing

```python
import numpy as np
from neuralforge.ml import normalize, standardize, train_test_split

# Create sample data
data = np.array([[1, 2], [3, 4], [5, 6], [7, 8]])

# Normalize to [0, 1]
normalized = normalize(data)
print(normalized)
# Output:
# [[0.  0. ]
#  [0.5 0.5]
#  [1.  1. ]
#  [1.5 1.5]]

# Standardize to mean=0, std=1
standardized = standardize(data)
print(standardized)

# Split into train/test sets
X = np.random.randn(100, 5)
y = np.random.randn(100)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
```

### Using Data Loaders

```python
from neuralforge.ml import SyntheticDataLoader, CSVDataLoader

# Generate synthetic data
synthetic_loader = SyntheticDataLoader(n_samples=1000, n_features=10, task="regression")
X, y = synthetic_loader.load()

# Load from CSV
csv_loader = CSVDataLoader(
    path="data.csv", target_column="label", feature_columns=["f1", "f2", "f3"]
)
X, y = csv_loader.load()

# Iterate in batches
for X_batch, y_batch in synthetic_loader:
    print(f"Batch shape: {X_batch.shape}")
```

### Training a Neural Network

```python
import numpy as np
from neuralforge.ml import train_simple_model, SimpleNN
import torch

# Generate data
np.random.seed(42)
X = np.random.randn(1000, 10)
true_weights = np.random.randn(10, 1)
y = X.dot(true_weights).flatten() + 0.1 * np.random.randn(1000)

# Train a model
trained_model = train_simple_model(
    X, y, input_size=10, hidden_size=64, output_size=1, epochs=100, learning_rate=0.001
)

# Make predictions
X_test = np.random.randn(5, 10)
with torch.no_grad():
    predictions = trained_model(torch.FloatTensor(X_test))
print(predictions)
```

### Using SimpleNN Directly

```python
import torch
from neuralforge.ml import SimpleNN, save_model, load_model

# Create a model
model = SimpleNN(input_size=10, hidden_size=32, output_size=2)

# Forward pass
x = torch.randn(32, 10)  # batch of 32 samples, 10 features each
output = model(x)
print(output.shape)  # torch.Size([32, 2])

# Save the model
save_model(model, "my_model", epoch=10, loss=0.5)

# Load the model
new_model = SimpleNN(input_size=10, hidden_size=32, output_size=2)
loaded_model, _, epoch, loss = load_model("my_model.pt", new_model)
print(f"Loaded model from epoch {epoch} with loss {loss}")
```

## Command Line Usage

NeuralForge includes a Makefile for common development tasks:

```bash
# Install the package
make install

# Run linting
make lint

# Auto-format code
make format

# Run tests
make test

# Run type checking
make type

# Run all checks
make all
```

## Project Structure

```
neuralforge/
├── src/
│   └── neuralforge/
│       ├── __init__.py      # Package initialization
│       ├── core.py          # Core functions
│       └── ml/              # Machine learning utilities
│           ├── __init__.py
│           ├── data.py      # Data preprocessing
│           ├── data_loaders.py  # Data loading
│           └── models.py    # Neural network models
├── tests/                  # Unit tests
├── docs/                   # Documentation
├── scripts/                # Utility scripts
├── mkdocs.yml              # MkDocs configuration
├── pyproject.toml          # Project configuration
├── Makefile                # Development tasks
└── README.md               # Project overview
```

## Next Steps

- [Installation Guide](installation.md): Detailed installation instructions
- [API Reference](../api/core.md): Complete API documentation
- [Contributing Guide](../../development/contributing.md): Learn how to contribute
