# Data Loaders Module

The `data_loaders` module provides classes and utilities for loading and preprocessing data for machine learning tasks.

## Base Classes

### `BaseDataLoader`

Abstract base class for all data loaders.

**Signature:**
```python
class BaseDataLoader(ABC)
```

**Description:**
All data loaders should inherit from this class and implement the required methods.

**Abstract Methods:**
- `load() -> Tuple[np.ndarray, np.ndarray]`: Load and return the dataset as (features, targets).
- `__len__() -> int`: Return the number of samples in the dataset.
- `__iter__() -> Iterator[Tuple[np.ndarray, np.ndarray]]`: Iterate over batches of data.

## Concrete Data Loaders

### `CSVDataLoader`

Data loader for CSV files.

**Signature:**
```python
class CSVDataLoader(BaseDataLoader)
```

**Parameters:**
- `path` (Union[str, Path]): Path to the CSV file.
- `target_column` (Union[str, int]): Name or index of the target column.
- `feature_columns` (Optional[List[Union[str, int]]]): List of feature column names or indices. If None, uses all columns except target.
- `delimiter` (str): CSV delimiter. Default: ','.
- `skip_header` (bool): Whether to skip the header row. Default: True.
- `batch_size` (int): Batch size for iteration. Default: 32.
- `shuffle` (bool): Whether to shuffle data. Default: False.

**Example:**
```python
from neuralforge.ml import CSVDataLoader

# Load data from CSV
loader = CSVDataLoader(
    path="data.csv",
    target_column="label",
    feature_columns=["feature1", "feature2", "feature3"],
)

# Load all data at once
X, y = loader.load()

# Iterate in batches
for X_batch, y_batch in loader:
    print(f"Batch: X={X_batch.shape}, y={y_batch.shape}")
```

**Usage with Column Indices:**
```python
# Use column indices instead of names
loader = CSVDataLoader(
    path="data.csv",
    target_column=0,  # First column is target
    feature_columns=[1, 2, 3],  # Columns 1, 2, 3 are features
)
```

### `SyntheticDataLoader`

Data loader for generating synthetic datasets.

**Signature:**
```python
class SyntheticDataLoader(BaseDataLoader)
```

**Parameters:**
- `n_samples` (int): Number of samples to generate.
- `n_features` (int): Number of features per sample.
- `n_classes` (int): Number of classes for classification. Default: 2.
- `task` (str): Type of task ('classification' or 'regression'). Default: 'classification'.
- `random_state` (int): Random seed for reproducibility. Default: 42.
- `batch_size` (int): Batch size for iteration. Default: 32.

**Example:**
```python
from neuralforge.ml import SyntheticDataLoader

# Generate classification data
classification_loader = SyntheticDataLoader(
    n_samples=1000, n_features=10, n_classes=3, task="classification"
)
X, y = classification_loader.load()

# Generate regression data
regression_loader = SyntheticDataLoader(
    n_samples=1000, n_features=10, task="regression"
)
X, y = regression_loader.load()

# Iterate in batches
for X_batch, y_batch in regression_loader:
    print(f"Batch shape: {X_batch.shape}")
```

**Classification vs Regression:**

For **classification**, the loader generates data with a linear decision boundary:
- Features are randomly generated from a standard normal distribution
- Targets are class labels (integers from 0 to n_classes-1)

For **regression**, the loader generates data with a linear relationship:
- Features are randomly generated from a standard normal distribution
- Targets are computed as a linear combination of features plus noise

## Factory Class

### `DataLoaderFactory`

Factory class for creating data loaders.

**Signature:**
```python
class DataLoaderFactory
```

**Static Methods:**

#### `create`

Create a data loader based on type.

**Signature:**
```python
@staticmethod
def create(loader_type: str, **kwargs: Any) -> BaseDataLoader
```

**Parameters:**
- `loader_type` (str): Type of loader ('csv' or 'synthetic').
- `**kwargs`: Arguments to pass to the loader constructor.

**Returns:**
- `BaseDataLoader`: An instance of the specified data loader.

**Example:**
```python
from neuralforge.ml import DataLoaderFactory

# Create a synthetic data loader
loader = DataLoaderFactory.create(
    loader_type="synthetic", n_samples=1000, n_features=10, task="regression"
)

# Create a CSV data loader
csv_loader = DataLoaderFactory.create(
    loader_type="csv", path="data.csv", target_column="label"
)
```

## Usage Patterns

### Training Loop with Data Loaders

```python
from neuralforge.ml import SyntheticDataLoader, train_simple_model

# Create data loader
loader = SyntheticDataLoader(n_samples=1000, n_features=10, task="regression")

# Load all data
X, y = loader.load()

# Train model
model = train_simple_model(X, y, input_size=10, epochs=50)
```

### Batch Processing

```python
from neuralforge.ml import CSVDataLoader

loader = CSVDataLoader(
    path="large_dataset.csv", target_column="label", batch_size=64, shuffle=True
)

# Process data in batches
for X_batch, y_batch in loader:
    # Process batch
    print(f"Processing batch of size {len(X_batch)}")
    # Your processing code here
```

### Custom Data Loader

To create a custom data loader, inherit from `BaseDataLoader`:

```python
from neuralforge.ml import BaseDataLoader
from typing import Tuple, Iterator
import numpy as np


class MyCustomLoader(BaseDataLoader):
    def __init__(self, data: np.ndarray, targets: np.ndarray):
        self.data = data
        self.targets = targets
        self.batch_size = 32

    def load(self) -> Tuple[np.ndarray, np.ndarray]:
        return self.data, self.targets

    def __len__(self) -> int:
        return len(self.targets)

    def __iter__(self) -> Iterator[Tuple[np.ndarray, np.ndarray]]:
        for i in range(0, len(self), self.batch_size):
            yield (
                self.data[i : i + self.batch_size],
                self.targets[i : i + self.batch_size],
            )


# Usage
loader = MyCustomLoader(X, y)
X_batch, y_batch = next(iter(loader))
```
