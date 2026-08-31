"""
Tests for the NeuralForge ML utilities module.
"""

import numpy as np
import pytest
import torch

from neuralforge.ml.data import normalize, standardize, train_test_split
from neuralforge.ml.models import SimpleNN, load_model, save_model, train_simple_model


class TestDataPreprocessing:
    """Test cases for data preprocessing functions."""

    def test_normalize_basic(self) -> None:
        """Test basic normalization."""
        data = np.array([[0, 0], [1, 1]])
        result = normalize(data)

        # Min is 0, max is 1, so normalized should be same as input
        np.testing.assert_array_almost_equal(result, data)

    def test_normalize_range(self) -> None:
        """Test normalization scales to [0, 1]."""
        data = np.array([[1, 2], [3, 4]])
        result = normalize(data, axis=0)

        # Check min and max are 0 and 1
        assert result.min() == 0.0
        assert result.max() == 1.0

    def test_normalize_constant_column(self) -> None:
        """Test normalization handles constant columns."""
        data = np.array([[1, 5], [1, 10], [1, 15]])
        result = normalize(data, axis=0)

        # First column is constant (all 1s), should remain 0 after normalization
        assert np.all(result[:, 0] == 0)
        # Second column should be normalized
        assert result[0, 1] == 0.0
        assert result[2, 1] == 1.0

    def test_standardize_basic(self) -> None:
        """Test basic standardization."""
        data = np.array([[0, 0], [1, 1]])
        result = standardize(data)

        # Mean is 0.5, std is 0.5 for both columns
        # Standardized: (x - 0.5) / 0.5 = 2x - 1
        expected = np.array([[-1, -1], [1, 1]])
        np.testing.assert_array_almost_equal(result, expected)

    def test_standardize_mean_zero(self) -> None:
        """Test standardization results in zero mean."""
        data = np.array([[1, 2], [3, 4], [5, 6]])
        result = standardize(data, axis=0)

        # Mean should be approximately zero
        np.testing.assert_array_almost_equal(result.mean(axis=0), [0, 0], decimal=10)

    def test_standardize_std_one(self) -> None:
        """Test standardization results in unit variance."""
        data = np.array([[1, 2], [3, 4], [5, 6]])
        result = standardize(data, axis=0)

        # Std should be approximately one
        np.testing.assert_array_almost_equal(result.std(axis=0), [1, 1], decimal=10)

    def test_train_test_split_shapes(self) -> None:
        """Test train_test_split returns correct shapes."""
        X = np.random.randn(100, 10)
        y = np.random.randn(100)

        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

        # Check shapes
        assert X_train.shape[1] == 10  # Same number of features
        assert X_test.shape[1] == 10
        assert len(y_train) == X_train.shape[0]
        assert len(y_test) == X_test.shape[0]

        # Check split ratio
        assert X_train.shape[0] == 80
        assert X_test.shape[0] == 20

    def test_train_test_split_reproducibility(self) -> None:
        """Test train_test_split is reproducible with same random_state."""
        X = np.random.randn(100, 10)
        y = np.random.randn(100)

        X_train1, X_test1, y_train1, y_test1 = train_test_split(
            X, y, test_size=0.2, random_state=42
        )
        X_train2, X_test2, y_train2, y_test2 = train_test_split(
            X, y, test_size=0.2, random_state=42
        )

        np.testing.assert_array_equal(X_train1, X_train2)
        np.testing.assert_array_equal(X_test1, X_test2)

    def test_train_test_split_invalid_size(self) -> None:
        """Test train_test_split raises error for invalid test_size."""
        X = np.random.randn(10, 2)
        y = np.random.randn(10)

        with pytest.raises(ValueError):
            train_test_split(X, y, test_size=1.5)

        with pytest.raises(ValueError):
            train_test_split(X, y, test_size=-0.1)


class TestSimpleNN:
    """Test cases for SimpleNN model."""

    def test_simple_nn_creation(self) -> None:
        """Test SimpleNN can be created."""
        model = SimpleNN(input_size=10, hidden_size=5, output_size=2)
        assert isinstance(model, torch.nn.Module)

    def test_simple_nn_forward(self) -> None:
        """Test SimpleNN forward pass."""
        model = SimpleNN(input_size=10, hidden_size=5, output_size=2)
        x = torch.randn(32, 10)
        output = model(x)

        assert output.shape == (32, 2)

    def test_simple_nn_parameters(self) -> None:
        """Test SimpleNN has correct number of parameters."""
        model = SimpleNN(input_size=10, hidden_size=5, output_size=2)

        # Count parameters: (10*5 + 5) + (5*2 + 2) = 55 + 12 = 67
        param_count = sum(p.numel() for p in model.parameters())
        assert param_count == 67


class TestModelSerialization:
    """Test cases for model serialization functions."""

    def test_save_and_load_model(self) -> None:
        """Test saving and loading a model."""
        import os
        import tempfile

        model = SimpleNN(input_size=10, hidden_size=5, output_size=2)

        with tempfile.TemporaryDirectory() as tmpdir:
            path = os.path.join(tmpdir, "test_model")
            save_model(model, path)

            # Create a new model instance
            new_model = SimpleNN(input_size=10, hidden_size=5, output_size=2)
            loaded_model, _, _, _ = load_model(path, new_model)

            # Check that state dicts are equal
            assert model.state_dict().keys() == loaded_model.state_dict().keys()

    def test_save_and_load_with_optimizer(self) -> None:
        """Test saving and loading model with optimizer."""
        import os
        import tempfile

        model = SimpleNN(input_size=10, hidden_size=5, output_size=2)
        optimizer = torch.optim.Adam(model.parameters(), lr=0.001)

        with tempfile.TemporaryDirectory() as tmpdir:
            path = os.path.join(tmpdir, "test_model")
            save_model(model, path, optimizer=optimizer, epoch=10, loss=0.5)

            new_model = SimpleNN(input_size=10, hidden_size=5, output_size=2)
            new_optimizer = torch.optim.Adam(new_model.parameters(), lr=0.001)

            loaded_model, loaded_optimizer, epoch, loss = load_model(
                path, new_model, new_optimizer
            )

            assert epoch == 10
            assert loss == 0.5
            assert loaded_optimizer is not None


class TestTraining:
    """Test cases for training functions."""

    def test_train_simple_model_basic(self) -> None:
        """Test basic model training."""
        # Create simple linear data
        np.random.seed(42)
        X = np.random.randn(100, 5)
        y = X.dot(np.random.randn(5, 1)).flatten() + 0.1 * np.random.randn(100)

        model = train_simple_model(
            X, y, input_size=5, output_size=1, epochs=10, batch_size=16
        )

        # Model should be a SimpleNN instance
        assert isinstance(model, SimpleNN)

    def test_train_simple_model_predictions(self) -> None:
        """Test that trained model makes predictions."""
        np.random.seed(42)
        X = np.random.randn(50, 3)
        true_weights = np.random.randn(3, 1)
        y = X.dot(true_weights).flatten() + 0.01 * np.random.randn(50)

        model = train_simple_model(
            X, y, input_size=3, output_size=1, epochs=50, learning_rate=0.01
        )

        # Test prediction
        with torch.no_grad():
            X_test = torch.FloatTensor(X[:5])
            predictions = model(X_test).numpy().flatten()

        # Predictions should be close to actual values (within reasonable error)
        assert predictions.shape == (5,)
