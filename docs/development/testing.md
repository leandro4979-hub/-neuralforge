# Testing Guide

This guide covers testing practices and conventions for NeuralForge.

## 🧪 Testing Philosophy

We believe in:

1. **Test-Driven Development (TDD)**: Write tests before implementing features
2. **High Coverage**: Aim for comprehensive test coverage of all code paths
3. **Fast Tests**: Tests should run quickly to enable frequent execution
4. **Isolated Tests**: Each test should be independent of others
5. **Readable Tests**: Tests should be easy to understand and maintain

## 🛠️ Testing Setup

### Dependencies

Testing dependencies are included in the development installation:

```bash
pip install -e ".[dev]"
```

This installs:
- `pytest`: Testing framework
- `pytest-cov`: Coverage reporting
- `pytest-mock`: Mocking support (if needed)

### Running Tests

**Run all tests:**
```bash
pytest
```

**Run tests with coverage:**
```bash
pytest --cov=src/neuralforge --cov-report=term-missing
```

**Run a specific test file:**
```bash
pytest tests/test_ml.py
```

**Run a specific test class:**
```bash
pytest tests/test_ml.py::TestDataPreprocessing
```

**Run a specific test function:**
```bash
pytest tests/test_ml.py::TestDataPreprocessing::test_normalize_basic
```

**Run tests matching a pattern:**
```bash
pytest -k "normalize"
```

**Run tests with verbose output:**
```bash
pytest -v
```

**Stop on first failure:**
```bash
pytest -x
```

## 📁 Test Organization

### Directory Structure

```
tests/
├── __init__.py           # Empty file to make tests a package
├── conftest.py          # Pytest fixtures available to all tests
├── test_core.py         # Tests for core module
└── test_ml.py           # Tests for ml module
```

### Test File Naming

- Test files should be named `test_*.py`
- Each source module should have a corresponding test file
- Test files should mirror the source directory structure

**Example:**
```
src/
└── neuralforge/
    ├── core.py
    └── ml/
        ├── data.py
        └── models.py

tests/
├── test_core.py
└── test_ml.py
```

## 🏗️ Test Structure

### Test Classes

Group related tests in classes:

```python
class TestNormalize:
    """Tests for the normalize function."""

    def test_basic_normalization(self) -> None:
        """Test basic normalization to [0, 1]."""
        pass

    def test_constant_column(self) -> None:
        """Test normalization handles constant columns."""
        pass


class TestStandardize:
    """Tests for the standardize function."""

    def test_mean_zero(self) -> None:
        """Test standardization results in zero mean."""
        pass

    def test_std_one(self) -> None:
        """Test standardization results in unit variance."""
        pass
```

### Test Method Naming

- Start with `test_`
- Use descriptive names that explain what is being tested
- Use underscores to separate words

**Good:**
```python
def test_normalize_with_negative_values(self) -> None:
    pass


def test_model_forward_pass_shape(self) -> None:
    pass
```

**Bad:**
```python
def test1(self) -> None:
    pass


def test_normalize(self) -> None:  # Too vague
    pass
```

## 🎯 Writing Good Tests

### The Arrange-Act-Assert Pattern

Structure your tests using the AAA pattern:

```python
def test_normalize_basic(self) -> None:
    # Arrange
    data = np.array([[1, 2], [3, 4]])
    
    # Act
    result = normalize(data, axis=0)
    
    # Assert
    assert result.min() == 0.0
    assert result.max() == 1.0
```

### Test One Thing at a Time

Each test should verify one specific behavior:

**Good:**
```python
def test_normalize_min_value(self) -> None:
    """Test that normalized data has minimum value of 0."""
    data = np.array([[1, 2], [3, 4]])
    result = normalize(data)
    assert result.min() == 0.0


def test_normalize_max_value(self) -> None:
    """Test that normalized data has maximum value of 1."""
    data = np.array([[1, 2], [3, 4]])
    result = normalize(data)
    assert result.max() == 1.0
```

**Bad:**
```python
def test_normalize(self) -> None:
    """Test normalize function."""
    data = np.array([[1, 2], [3, 4]])
    result = normalize(data)
    # Tests multiple things at once
    assert result.min() == 0.0
    assert result.max() == 1.0
    assert result.shape == data.shape
    assert np.all(result >= 0)
    assert np.all(result <= 1)
```

### Use Descriptive Assertions

Pytest's assertion introspection provides helpful error messages:

**Good:**
```python
assert result == expected
assert len(data) > 0
assert isinstance(obj, MyClass)
assert np.allclose(actual, expected, rtol=1e-5)
```

**Avoid:**
```python
assertTrue(result == expected)
assertEqual(result, expected)
```

### Test Edge Cases

Always test edge cases and boundary conditions:

```python
class TestTrainTestSplit:
    """Tests for train_test_split function."""
    
    def test_normal_split(self) -> None:
        """Test normal split with valid test_size."""
        X = np.random.randn(100, 5)
        y = np.random.randn(100)
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
        assert len(X_train) == 80
        assert len(X_test) == 20
    
    def test_zero_test_size(self) -> None:
        """Test split with test_size=0."""
        X = np.random.randn(10, 2)
        y = np.random.randn(10)
        with pytest.raises(ValueError):
            train_test_split(X, y, test_size=0)
    
    def test_one_test_size(self) -> None:
        """Test split with test_size=1."""
        X = np.random.randn(10, 2)
        y = np.random.randn(10)
        with pytest.raises(ValueError):
            train_test_split(X, y, test_size=1)
    
    def test_negative_test_size(self) -> None:
        """Test split with negative test_size."""
        X = np.random.randn(10, 2)
        y = np.random.randn(10)
        with pytest.raises(ValueError):
            train_test_split(X, y, test_size=-0.1)
    
    def test_empty_data(self) -> None:
        """Test split with empty data."""
        X = np.array([]).reshape(0, 2)
        y = np.array([])
        # Should handle gracefully or raise appropriate error
        pass
```

## 🔄 Fixtures

Use pytest fixtures for test dependencies and setup:

### Module-Level Fixtures

```python
import pytest
import numpy as np


@pytest.fixture
def sample_data():
    """Provide sample data for testing."""
    return np.array([[1, 2], [3, 4], [5, 6], [7, 8]])


@pytest.fixture
def simple_model():
    """Provide a simple neural network model."""
    return SimpleNN(input_size=2, hidden_size=4, output_size=1)


# Use in tests
def test_normalize(sample_data):
    """Test normalize with sample data."""
    result = normalize(sample_data)
    assert result.min() == 0.0
    assert result.max() == 1.0


def test_model_forward(simple_model):
    """Test model forward pass."""
    import torch

    x = torch.randn(1, 2)
    output = simple_model(x)
    assert output.shape == (1, 1)
```

### Shared Fixtures (conftest.py)

For fixtures used across multiple test files, add them to `conftest.py`:

```python
# tests/conftest.py
import pytest
import numpy as np
import torch


@pytest.fixture
def rng():
    """Provide a seeded random number generator."""
    return np.random.default_rng(42)


@pytest.fixture
def device():
    """Provide the best available device for testing."""
    return torch.device("cuda" if torch.cuda.is_available() else "cpu")


@pytest.fixture
def sample_tensor(device):
    """Provide a sample tensor on the appropriate device."""
    return torch.randn(10, 5, device=device)
```

## 📊 Mocking

Use `pytest-mock` for mocking external dependencies:

```python
def test_csv_loader(mocker):
    """Test CSVDataLoader with mocked file."""
    # Mock the open function
    mock_open = mocker.mock_open(read_data="a,b,c\n1,2,3\n4,5,6")
    mocker.patch("builtins.open", mock_open)

    loader = CSVDataLoader(path="dummy.csv", target_column=0, feature_columns=[1, 2])
    X, y = loader.load()

    assert X.shape == (2, 2)
    assert y.shape == (2,)
```

## ⚡ Performance Testing

For performance-critical code, add performance tests:

```python
import time


def test_normalize_performance():
    """Test that normalize runs in acceptable time."""
    # Create large dataset
    data = np.random.randn(10000, 100)

    start = time.time()
    result = normalize(data)
    elapsed = time.time() - start

    assert elapsed < 0.1  # Should complete in under 100ms
    assert result.shape == data.shape
```

## 📈 Coverage

We aim for high test coverage. Check coverage with:

```bash
pytest --cov=src/neuralforge --cov-report=term-missing
```

This will show:
- Percentage of code covered by tests
- Lines that are not covered

**Target: 90%+ coverage**

### Coverage Badge

Add a coverage badge to your README:

```markdown
[![Coverage](https://img.shields.io/badge/coverage-95%25-brightgreen)](https://github.com/leandro4979-hub/-neuralforge/actions)
```

## 🔍 Debugging Tests

### Verbose Output

```bash
pytest -v -s
```

- `-v`: Verbose output
- `-s`: Show print statements

### Pdb Integration

Add breakpoints in tests:

```python
def test_something():
    import pdb

    pdb.set_trace()  # Breakpoint
    result = some_function()
    assert result == expected
```

Or use pytest's built-in pdb:

```bash
pytest --pdb
```

### Print Debugging

For quick debugging:

```python
def test_debug():
    data = np.array([[1, 2], [3, 4]])
    print(f"Input data: {data}")
    result = normalize(data)
    print(f"Result: {result}")
    assert result.min() == 0.0
```

## 📝 Test Documentation

Document complex tests with comments:

```python
class TestComplexFunctionality:
    """
    Tests for complex functionality that requires explanation.
    
    These tests verify the interaction between multiple components
    and may have specific setup requirements.
    """
    
    @pytest.fixture
    def complex_setup(self):
        """
        Set up a complex test scenario.
        
        This creates a dataset, trains a model, and prepares test data
        for evaluating the full pipeline.
        """
        # Setup code here
        pass
    
    def test_full_pipeline(self, complex_setup):
        """
        Test the complete ML pipeline from data to predictions.
        
        This test verifies that:
        1. Data can be loaded
        2. Model can be trained
        3. Predictions can be made
        4. Results are reasonable
        """
        # Test code here
        pass
```

## 🚫 Anti-Patterns

### Don't Test Implementation Details

**Bad:**
```python
def test_internal_method(self):
    """Test internal method that might change."""
    obj = MyClass()
    result = obj._internal_method()  # Testing private method
    assert result == expected
```

**Good:**
```python
def test_public_interface(self):
    """Test public interface."""
    obj = MyClass()
    result = obj.public_method()  # Test public behavior
    assert result == expected
```

### Don't Test External Libraries

**Bad:**
```python
def test_numpy_sum(self):
    """Test numpy's sum function."""
    arr = np.array([1, 2, 3])
    assert np.sum(arr) == 6
```

**Good:**
```python
# Don't test numpy, test your code that uses numpy
def test_my_sum_function(self):
    """Test my function that uses numpy."""
    arr = np.array([1, 2, 3])
    result = my_sum_function(arr)
    assert result == 6
```

### Avoid Slow Tests

**Bad:**
```python
def test_large_dataset(self):
    """Test with very large dataset."""
    data = np.random.randn(1000000, 100)  # Too large
    result = normalize(data)
    assert result.shape == data.shape
```

**Good:**
```python
@pytest.mark.slow
def test_large_dataset(self):
    """Test with moderately large dataset."""
    data = np.random.randn(10000, 100)  # Reasonable size
    result = normalize(data)
    assert result.shape == data.shape
```

## 🏷️ Test Markers

Use pytest markers to categorize tests:

```python
@pytest.mark.slow
def test_large_computation():
    """Test that takes a long time to run."""
    pass


@pytest.mark.integration
def test_full_integration():
    """Integration test."""
    pass


@pytest.mark.skip(reason="Not implemented yet")
def test_future_feature():
    """Test for feature not yet implemented."""
    pass


@pytest.mark.xfail
def test_known_failure():
    """Test that is expected to fail."""
    pass
```

Run tests with markers:

```bash
pytest -m "not slow"  # Skip slow tests
pytest -m integration   # Run only integration tests
```

## 📚 Resources

- [pytest Documentation](https://docs.pytest.org/)
- [pytest Fixtures](https://docs.pytest.org/en/7.1.x/how-to/fixtures.html)
- [Testing Python](https://realpython.com/pytest-python-testing/)
- [Test-Driven Development with Python](https://www.obeythetestinggoat.com/)
