# Core Module

The `core` module provides the fundamental building blocks of NeuralForge.

## Functions

### `hello`

Return a friendly greeting from NeuralForge.

**Signature:**
```python
def hello(name: Optional[str] = None) -> str
```

**Parameters:**
- `name` (Optional[str]): Optional name to greet. If None, returns a generic greeting.

**Returns:**
- `str`: A greeting string.

**Example:**
```python
from neuralforge import hello

print(hello())  # "Hello from NeuralForge!"
print(hello("Alice"))  # "Hello, Alice! Welcome to NeuralForge."
```

### `run`

Main entry point for NeuralForge execution.

**Signature:**
```python
def run() -> None
```

**Description:**
This function initializes and runs the core NeuralForge workflow. Currently a placeholder for future implementation.

**Example:**
```python
from neuralforge import run

run()
```

## Classes

### `NeuralForgeError`

Base exception class for NeuralForge errors.

**Signature:**
```python
class NeuralForgeError(Exception)
```

**Description:**
Inherits from Python's built-in `Exception` class. Use this for custom error handling in NeuralForge.

**Example:**
```python
from neuralforge.core import NeuralForgeError

try:
    raise NeuralForgeError("Custom error message")
except NeuralForgeError as e:
    print(f"Caught NeuralForge error: {e}")
```

## Module Attributes

### `__version__`

The current version of NeuralForge.

**Type:** `str`

**Value:** `"0.1.0"`

### `__author__`

The author of NeuralForge.

**Type:** `str`

**Value:** `"Leandro_f714"`

## Usage Examples

### Basic Import

```python
import neuralforge

print(neuralforge.__version__)
print(neuralforge.hello())
```

### Specific Imports

```python
from neuralforge import hello, run
from neuralforge.core import NeuralForgeError

# Use functions directly
print(hello("Developer"))

# Run the workflow
run()
```
