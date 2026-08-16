# Installation

This guide will help you set up NeuralForge for development or usage.

## Prerequisites

- **Python**: 3.10 or higher
- **pip**: Python package manager (usually comes with Python)
- **Git**: For cloning the repository (optional)

## Installation Methods

### From Source (Recommended for Development)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/leandro4979-hub/-neuralforge.git
   cd -neuralforge
   ```

2. **Create a virtual environment (recommended):**
   ```bash
   python -m venv .venv
   ```

3. **Activate the virtual environment:**
   - **Linux/Mac:**
     ```bash
     source .venv/bin/activate
     ```
   - **Windows:**
     ```cmd
     .venv\Scripts\activate
     ```

4. **Install in development mode with all dependencies:**
   ```bash
   pip install -e ".[dev]"
   ```

### Using pip (When Published)

Once published to PyPI:

```bash
pip install neuralforge
```

### Install Only Runtime Dependencies

If you don't need development tools:

```bash
pip install -e .
```

## Verify Installation

Test that NeuralForge is installed correctly:

```python
import neuralforge

print(neuralforge.__version__)  # Should print "0.1.0"
print(neuralforge.hello())  # Should print "Hello from NeuralForge!"
```

## Development Dependencies

The following development tools are included when installing with `[dev]`:

- **ruff**: Fast linter and formatter
- **mypy**: Static type checker
- **pytest**: Testing framework
- **pytest-cov**: Coverage reporting

## Troubleshooting

### Common Issues

**Issue: Python version too old**

```
ERROR: Package 'neuralforge' requires a different Python: 3.10.0 not in '>=3.10'
```

**Solution:** Upgrade Python to 3.10 or higher.

**Issue: Missing dependencies**

```
ModuleNotFoundError: No module named 'torch'
```

**Solution:** Run `pip install -e ".[dev]"` to install all dependencies.

**Issue: Virtual environment not activated**

```
Command "python" not found
```

**Solution:** Make sure to activate your virtual environment before running commands.

## Next Steps

- [Quick Start Guide](quick-start.md): Learn how to use NeuralForge
- [API Reference](../api/core.md): Explore the full API
- [Contributing Guide](../../development/contributing.md): Contribute to the project
