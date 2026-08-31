"""Tests for NeuralForge model evaluation metrics."""

import numpy as np
import pytest

from neuralforge.ml.metrics import (
    binary_accuracy,
    binary_confusion_matrix,
    mean_absolute_error,
    mean_squared_error,
    r2_score,
    root_mean_squared_error,
)


def test_regression_metrics() -> None:
    y_true = np.array([1.0, 2.0, 3.0])
    y_pred = np.array([1.0, 3.0, 2.0])

    assert mean_absolute_error(y_true, y_pred) == pytest.approx(2.0 / 3.0)
    assert mean_squared_error(y_true, y_pred) == pytest.approx(2.0 / 3.0)
    assert root_mean_squared_error(y_true, y_pred) == pytest.approx(np.sqrt(2.0 / 3.0))
    assert r2_score(y_true, y_pred) == pytest.approx(0.0)


def test_perfect_r2_score() -> None:
    y_true = np.array([1.0, 2.0, 3.0, 4.0])
    assert r2_score(y_true, y_true) == pytest.approx(1.0)


def test_binary_accuracy_uses_threshold() -> None:
    y_true = np.array([0, 1, 1, 0])
    y_score = np.array([0.1, 0.6, 0.4, 0.8])

    assert binary_accuracy(y_true, y_score) == pytest.approx(0.5)
    assert binary_accuracy(y_true, y_score, threshold=0.7) == pytest.approx(0.25)


def test_binary_confusion_matrix() -> None:
    y_true = np.array([1, 1, 0, 0])
    y_score = np.array([0.9, 0.2, 0.8, 0.1])

    assert binary_confusion_matrix(y_true, y_score) == (1, 1, 1, 1)


def test_metrics_reject_mismatched_shapes() -> None:
    with pytest.raises(ValueError, match="same number of elements"):
        mean_squared_error([1, 2], [1])


def test_metrics_reject_empty_input() -> None:
    with pytest.raises(ValueError, match="must not be empty"):
        mean_absolute_error([], [])


def test_r2_rejects_constant_targets() -> None:
    with pytest.raises(ValueError, match="constant"):
        r2_score([1, 1, 1], [1, 1, 1])


def test_binary_metrics_validate_labels_and_threshold() -> None:
    with pytest.raises(ValueError, match="binary labels"):
        binary_accuracy([0, 2], [0.1, 0.9])

    with pytest.raises(ValueError, match="between 0 and 1"):
        binary_confusion_matrix([0, 1], [0.1, 0.9], threshold=1.5)
