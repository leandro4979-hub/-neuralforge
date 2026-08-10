# Code Style Guide

This document outlines the coding standards and style guidelines for NeuralForge.

## 📖 General Principles

1. **Readability First**: Code should be easy to read and understand
2. **Consistency**: Follow the existing patterns in the codebase
3. **Maintainability**: Write code that is easy to maintain and extend
4. **Simplicity**: Prefer simple solutions over complex ones

## 🐍 Python Style

### PEP 8 Compliance

Follow [PEP 8](https://peps.python.org/pep-0008/) - the Python style guide:

- **Indentation**: 4 spaces (no tabs)
- **Maximum Line Length**: 88 characters (configured in ruff)
- **Blank Lines**: Use blank lines to separate functions and classes
- **Imports**: Group imports in the following order:
  1. Standard library imports
  2. Third-party library imports
  3. Local application/library imports
  
  Separate each group with a blank line.

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Variables | `snake_case` | `user_name`, `max_value` |
| Functions | `snake_case` | `def calculate_total():` |
| Classes | `PascalCase` | `class DataLoader:` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_SIZE = 100` |
| Private Variables | `_leading_underscore` | `_internal_value` |
| Protected Variables | `_leading_underscore` | `_protected_value` |
| Private Methods | `_leading_underscore` | `def _internal_method():` |

### Type Hints

Always use type hints for better code clarity and IDE support:

**Good:**
```python
def greet(name: str, times: int = 1) -> str:
    return f"Hello, {name}! " * times

def process_data(data: List[float], normalize: bool = False) -> Tuple[float, float]:
    if normalize:
        data = [x / max(data) for x in data]
    return min(data), max(data)
```

**Bad:**
```python
def greet(name, times=1):
    return f"Hello, {name}! " * times
```

### Docstrings

Use [Google-style docstrings](https://google.github.io/styleguide/pyguide.html#38-comments-and-docstrings):

**Function Docstring:**
```python
def normalize(data: np.ndarray, axis: int = 0) -> np.ndarray:
    """
    Normalize data to the range [0, 1].

    Args:
        data: Input array to normalize.
        axis: Axis along which to normalize. Default is 0 (columns).

    Returns:
        Normalized array with values in [0, 1].

    Raises:
        ValueError: If data is empty.

    Example:
        >>> data = np.array([[1, 2], [3, 4]])
        >>> normalize(data, axis=0)
        array([[0., 0.], [1., 1.]])
    """
    pass
```

**Class Docstring:**
```python
class SimpleNN(nn.Module):
    """
    A simple feedforward neural network.

    This is a basic multi-layer perceptron for classification or regression tasks.

    Args:
        input_size: Number of input features.
        hidden_size: Number of neurons in the hidden layer.
        output_size: Number of output neurons.
        activation: Activation function for hidden layer. Default: ReLU.

    Attributes:
        fc1: First fully connected layer.
        fc2: Second fully connected layer.
        activation: Activation function.

    Example:
        >>> model = SimpleNN(input_size=10, hidden_size=5, output_size=2)
        >>> x = torch.randn(32, 10)
        >>> output = model(x)
    """
    pass
```

**Module Docstring:**
```python
"""
Machine Learning utilities for NeuralForge.

This module provides helper functions and classes for common ML tasks,
including data preprocessing, model utilities, and neural network helpers.
"""
```

## 🧪 Testing Style

### Test File Structure

- Test files should be named `test_*.py` and placed in the `tests/` directory
- Mirror the structure of the source code
- Each test file should have a corresponding source file

### Test Naming

- Test classes: `Test<ModuleName>` or `Test<ClassName>`
- Test methods: `test_<description>` (use underscores to separate words)

**Example:**
```python
class TestDataPreprocessing:
    """Tests for data preprocessing functions."""

    def test_normalize_basic(self) -> None:
        """Test basic normalization."""
        pass

    def test_normalize_range(self) -> None:
        """Test normalization scales to [0, 1]."""
        pass
```

### Test Organization

Group related tests together in test classes:

```python
class TestNormalize:
    """Tests for the normalize function."""
    
    def test_with_positive_values(self) -> None:
        pass
    
    def test_with_negative_values(self) -> None:
        pass
    
    def test_with_constant_column(self) -> None:
        pass

class TestStandardize:
    """Tests for the standardize function."""
    
    def test_mean_zero(self) -> None:
        pass
    
    def test_std_one(self) -> None:
        pass
```

### Assertions

Use pytest's assertion introspection:

**Good:**
```python
assert result == expected
assert len(data) > 0
assert isinstance(obj, MyClass)
```

**Avoid:**
```python
assertTrue(result == expected)
assertEqual(result, expected)
```

### Fixtures

Use pytest fixtures for test dependencies:

```python
import pytest

@pytest.fixture
def sample_data():
    """Provide sample data for testing."""
    return np.array([[1, 2], [3, 4], [5, 6]])

@pytest.fixture
def simple_model():
    """Provide a simple model for testing."""
    return SimpleNN(input_size=2, hidden_size=4, output_size=1)

def test_normalize(sample_data):
    """Test normalize with sample data."""
    result = normalize(sample_data)
    assert result.min() == 0.0
    assert result.max() == 1.0

def test_model_forward(simple_model):
    """Test model forward pass."""
    x = torch.randn(1, 2)
    output = simple_model(x)
    assert output.shape == (1, 1)
```

## 📦 Import Style

### Standard Imports

Group imports as follows:

```python
# Standard library imports
import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple, Union

# Third-party imports
import numpy as np
import numpy.typing as npt
import torch
import torch.nn as nn

# Local imports
from .data import normalize, standardize
from .models import SimpleNN, save_model
```

### Relative vs Absolute Imports

- Use **relative imports** within a package
- Use **absolute imports** from outside the package

**Within the package:**
```python
# In src/neuralforge/ml/models.py
from .data import normalize
from ..core import hello
```

**From outside the package:**
```python
# In tests/test_ml.py
from neuralforge.ml import normalize, SimpleNN
```

## 🎨 Formatting

### Line Length

- Maximum line length: **88 characters**
- Use backslashes for line continuation when needed
- Prefer breaking lines at logical points

**Good:**
```python
result = (
    some_long_function_name(
        arg1, arg2, arg3
    ) + another_long_function_name(arg4, arg5)
)
```

**Also Good:**
```python
with open(path, mode) as file:
    data = file.read()
```

### Whitespace

- No whitespace inside parentheses, brackets, or braces
- One space around operators
- No space after comma in function calls
- One blank line between functions and classes
- Two blank lines between top-level classes

**Good:**
```python
def function(a: int, b: int) -> int:
    return a + b

class MyClass:
    def method(self, x: float) -> float:
        return x * 2
```

**Bad:**
```python
def function( a , b ) :
    return a+b

class MyClass :
    def method( self , x ) :
        return x*2
```

## 🔧 Error Handling

### Exceptions

- Use built-in exceptions when appropriate
- Create custom exceptions for domain-specific errors
- Include meaningful error messages

**Good:**
```python
if test_size <= 0 or test_size >= 1:
    raise ValueError(f"test_size must be between 0 and 1, got {test_size}")

if data.size == 0:
    raise NeuralForgeError("Cannot process empty dataset")
```

**Bad:**
```python
if test_size <= 0 or test_size >= 1:
    raise Exception("Invalid")
```

### Error Messages

- Be specific about what went wrong
- Include the problematic value
- Suggest how to fix the issue

**Good:**
```python
raise ValueError(
    f"Expected array with shape ({expected_shape}), "
    f"but got shape ({actual_shape})"
)
```

**Bad:**
```python
raise ValueError("Shape mismatch")
```

## 📝 Comments

### When to Comment

- Explain **why** something is done, not **what** is being done
- Document non-obvious behavior
- Note limitations or edge cases
- Mark TODO items and future improvements

**Good:**
```python
# We add a small epsilon to avoid division by zero
# when normalizing constant columns
data_range = data_max - data_min
data_range[data_range == 0] = 1e-8
```

**Bad:**
```python
# Subtract min from data
data = data - data.min()
```

### TODO Comments

Use TODO comments for future improvements:

```python
# TODO: Add support for sparse matrices
# TODO: Optimize this function for large datasets
```

### Avoid Redundant Comments

Don't comment code that is self-explanatory:

**Bad:**
```python
# Increment x by 1
x = x + 1
```

**Good:**
```python
x = x + 1
```

## 🛠️ Tool Configuration

### ruff

We use [ruff](https://github.com/astral-sh/ruff) for linting and formatting:

- Line length: 88 characters
- Select rules: E, F, I, N, W, UP
- Ignore E501 (line length handled by ruff format)

Run with:
```bash
ruff check .      # Check for issues
ruff check . --fix  # Auto-fix issues
ruff format .      # Format code
```

### mypy

We use [mypy](https://mypy-lang.org/) for static type checking:

- Python version: 3.10
- Warn on return any
- Warn on unused configs
- Ignore missing imports

Run with:
```bash
mypy src/
```

## 📚 Additional Resources

- [PEP 8 - Python Style Guide](https://peps.python.org/pep-0008/)
- [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html)
- [ruff Documentation](https://docs.astral.sh/ruff/)
- [mypy Documentation](https://mypy.readthedocs.io/)
- [pytest Documentation](https://docs.pytest.org/)
