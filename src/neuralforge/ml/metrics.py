"""Model evaluation metrics for NeuralForge.

This module provides dependency-light NumPy implementations of common
regression and binary-classification metrics.
"""

from __future__ import annotations

import numpy as np
import numpy.typing as npt

ArrayLike = npt.ArrayLike


def _as_1d_float(values: ArrayLike, *, name: str) -> npt.NDArray[np.float64]:
    array = np.asarray(values, dtype=np.float64).reshape(-1)
    if array.size == 0:
        raise ValueError(f"{name} must not be empty")
    if not np.all(np.isfinite(array)):
        raise ValueError(f"{name} must contain only finite values")
    return array


def _validate_pair(y_true: ArrayLike, y_pred: ArrayLike) -> tuple[npt.NDArray[np.float64], npt.NDArray[np.float64]]:
    true = _as_1d_float(y_true, name="y_true")
    pred = _as_1d_float(y_pred, name="y_pred")
    if true.shape != pred.shape:
        raise ValueError("y_true and y_pred must have the same number of elements")
    return true, pred


def mean_absolute_error(y_true: ArrayLike, y_pred: ArrayLike) -> float:
    """Return mean absolute error (MAE)."""
    true, pred = _validate_pair(y_true, y_pred)
    return float(np.mean(np.abs(true - pred)))


def mean_squared_error(y_true: ArrayLike, y_pred: ArrayLike) -> float:
    """Return mean squared error (MSE)."""
    true, pred = _validate_pair(y_true, y_pred)
    return float(np.mean(np.square(true - pred)))


def root_mean_squared_error(y_true: ArrayLike, y_pred: ArrayLike) -> float:
    """Return root mean squared error (RMSE)."""
    return float(np.sqrt(mean_squared_error(y_true, y_pred)))


def r2_score(y_true: ArrayLike, y_pred: ArrayLike) -> float:
    """Return the coefficient of determination, R².

    Raises:
        ValueError: If fewer than two targets are provided or y_true is constant.
    """
    true, pred = _validate_pair(y_true, y_pred)
    if true.size < 2:
        raise ValueError("r2_score requires at least two samples")

    residual = float(np.sum(np.square(true - pred)))
    total = float(np.sum(np.square(true - np.mean(true))))
    if total == 0.0:
        raise ValueError("r2_score is undefined when y_true is constant")
    return 1.0 - residual / total


def binary_accuracy(y_true: ArrayLike, y_score: ArrayLike, *, threshold: float = 0.5) -> float:
    """Return binary classification accuracy from scores or probabilities."""
    true, score = _validate_pair(y_true, y_score)
    if not 0.0 <= threshold <= 1.0:
        raise ValueError("threshold must be between 0 and 1")
    if not np.all(np.isin(true, [0.0, 1.0])):
        raise ValueError("y_true must contain only binary labels 0 and 1")

    predicted = (score >= threshold).astype(np.float64)
    return float(np.mean(predicted == true))


def binary_confusion_matrix(
    y_true: ArrayLike,
    y_score: ArrayLike,
    *,
    threshold: float = 0.5,
) -> tuple[int, int, int, int]:
    """Return ``(true_positive, false_positive, true_negative, false_negative)``."""
    true, score = _validate_pair(y_true, y_score)
    if not 0.0 <= threshold <= 1.0:
        raise ValueError("threshold must be between 0 and 1")
    if not np.all(np.isin(true, [0.0, 1.0])):
        raise ValueError("y_true must contain only binary labels 0 and 1")

    predicted = score >= threshold
    positive = true == 1.0
    negative = ~positive

    true_positive = int(np.sum(predicted & positive))
    false_positive = int(np.sum(predicted & negative))
    true_negative = int(np.sum(~predicted & negative))
    false_negative = int(np.sum(~predicted & positive))
    return true_positive, false_positive, true_negative, false_negative
