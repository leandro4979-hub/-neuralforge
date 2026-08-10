# ML Module

The `ml` (Machine Learning) module provides utilities for common ML tasks, including data preprocessing, neural network models, and training utilities.

## Data Preprocessing

### `normalize`

Normalize data to the range [0, 1].

**Signature:**
```python
def normalize(
    data: npt.NDArray[np.floating],
    axis: int = 0,
) -> npt.NDArray[np.floating]
```

**Parameters:**
- `data` (np.ndarray): Input array to normalize.
- `axis` (int): Axis along which to normalize. Default is 0 (columns).

**Returns:**
- `np.ndarray`: Normalized array with values in [0, 1].

**Example:**
```python
import numpy as np
from neuralforge.ml import normalize

data = np.array([[1, 2], [3, 4]])
result = normalize(data, axis=0)
# result: array([[0., 0.], [1., 1.]])
```

### `standardize`

Standardize data to have zero mean and unit variance.

**Signature:**
```python
def standardize(
    data: npt.NDArray[np.floating],
    axis: int = 0,
) -> npt.NDArray[np.floating]
```

**Parameters:**
- `data` (np.ndarray): Input array to standardize.
- `axis` (int): Axis along which to standardize. Default is 0 (columns).

**Returns:**
- `np.ndarray`: Standardized array with mean 0 and std 1.

**Example:**
```python
import numpy as np
from neuralforge.ml import standardize

data = np.array([[1, 2], [3, 4]])
result = standardize(data, axis=0)
# result: array([[-1., -1.], [1., 1.]])
```

### `train_test_split`

Split data into training and test sets.

**Signature:**
```python
def train_test_split(
    X: npt.NDArray[np.floating],
    y: npt.NDArray[np.floating],
    test_size: float = 0.2,
    random_state: int = 42,
) -> Tuple[npt.NDArray[np.floating], npt.NDArray[np.floating], 
            npt.NDArray[np.floating], npt.NDArray[np.floating]]
```

**Parameters:**
- `X` (np.ndarray): Feature matrix of shape (n_samples, n_features).
- `y` (np.ndarray): Target vector of shape (n_samples,).
- `test_size` (float): Proportion of data to use for testing (0 < test_size < 1).
- `random_state` (int): Random seed for reproducibility.

**Returns:**
- `Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]`: (X_train, X_test, y_train, y_test)

**Example:**
```python
import numpy as np
from neuralforge.ml import train_test_split

X = np.random.randn(100, 5)
y = np.random.randn(100)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
```

## Neural Network Models

### `SimpleNN`

A simple feedforward neural network.

**Signature:**
```python
class SimpleNN(nn.Module)
```

**Parameters:**
- `input_size` (int): Number of input features.
- `hidden_size` (int): Number of neurons in the hidden layer.
- `output_size` (int): Number of output neurons.
- `activation` (nn.Module): Activation function for hidden layer. Default: ReLU.

**Example:**
```python
import torch
from neuralforge.ml import SimpleNN

model = SimpleNN(input_size=10, hidden_size=64, output_size=2)
x = torch.randn(32, 10)  # batch of 32 samples, 10 features each
output = model(x)
print(output.shape)  # torch.Size([32, 2])
```

**Methods:**
- `forward(x: torch.Tensor) -> torch.Tensor`: Forward pass of the network.

### `save_model`

Save a PyTorch model to disk.

**Signature:**
```python
def save_model(
    model: nn.Module,
    path: str,
    optimizer: Optional[optim.Optimizer] = None,
    epoch: Optional[int] = None,
    loss: Optional[float] = None,
) -> None
```

**Parameters:**
- `model` (nn.Module): The PyTorch model to save.
- `path` (str): File path to save the model (without extension).
- `optimizer` (Optional[optim.Optimizer]): Optional optimizer to save alongside the model.
- `epoch` (Optional[int]): Optional epoch number to include in saved state.
- `loss` (Optional[float]): Optional loss value to include in saved state.

**Example:**
```python
from neuralforge.ml import SimpleNN, save_model
import torch.optim as optim

model = SimpleNN(10, 64, 2)
optimizer = optim.Adam(model.parameters(), lr=0.001)
save_model(model, "my_model", optimizer=optimizer, epoch=10, loss=0.5)
```

### `load_model`

Load a PyTorch model from disk.

**Signature:**
```python
def load_model(
    path: str,
    model: nn.Module,
    optimizer: Optional[optim.Optimizer] = None,
) -> Tuple[nn.Module, Optional[optim.Optimizer], int, float]
```

**Parameters:**
- `path` (str): File path to the saved model (with or without .pt extension).
- `model` (nn.Module): The model instance to load weights into.
- `optimizer` (Optional[optim.Optimizer]): Optional optimizer to load state into.

**Returns:**
- `Tuple[nn.Module, Optional[optim.Optimizer], int, float]`: (model, optimizer, epoch, loss)

**Example:**
```python
from neuralforge.ml import SimpleNN, load_model
import torch.optim as optim

model = SimpleNN(10, 64, 2)
optimizer = optim.Adam(model.parameters(), lr=0.001)
loaded_model, loaded_optimizer, epoch, loss = load_model(
    "my_model.pt", model, optimizer
)
```

### `train_simple_model`

Train a simple neural network on the given data.

**Signature:**
```python
def train_simple_model(
    X_train: npt.NDArray[np.floating],
    y_train: npt.NDArray[np.floating],
    input_size: int,
    hidden_size: int = 64,
    output_size: int = 1,
    epochs: int = 100,
    learning_rate: float = 0.001,
    batch_size: int = 32,
) -> SimpleNN
```

**Parameters:**
- `X_train` (np.ndarray): Training features of shape (n_samples, n_features).
- `y_train` (np.ndarray): Training targets of shape (n_samples,) or (n_samples, n_outputs).
- `input_size` (int): Number of input features.
- `hidden_size` (int): Number of neurons in the hidden layer. Default: 64.
- `output_size` (int): Number of output neurons. Default: 1.
- `epochs` (int): Number of training epochs. Default: 100.
- `learning_rate` (float): Learning rate for the optimizer. Default: 0.001.
- `batch_size` (int): Batch size for training. Default: 32.

**Returns:**
- `SimpleNN`: Trained SimpleNN model.

**Example:**
```python
import numpy as np
from neuralforge.ml import train_simple_model

X = np.random.randn(1000, 10)
y = np.random.randn(1000)
model = train_simple_model(X, y, input_size=10, epochs=50)
```
