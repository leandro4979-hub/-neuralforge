"""
Data preprocessing utilities for machine learning.

This module provides common data preprocessing functions for ML workflows.
"""

import numpy as np
import numpy.typing as npt


def normalize(
    data: npt.NDArray[np.floating],
    axis: int = 0,
) -> npt.NDArray[np.floating]:
    """
    Normalize data to the range [0, 1].

    Args:
        data: Input array to normalize.
        axis: Axis along which to normalize. Default is 0 (columns).

    Returns:
        Normalized array with values in [0, 1].

    Example:
        >>> import numpy as np
        >>> data = np.array([[1, 2], [3, 4]])
        >>> normalize(data, axis=0)
        array([[0. , 0. ],
               [1. , 1. ]])
    """
    min_vals = data.min(axis=axis, keepdims=True)
    max_vals = data.max(axis=axis, keepdims=True)
    range_vals = max_vals - min_vals

    # Avoid division by zero for constant columns
    range_vals[range_vals == 0] = 1.0

    return (data - min_vals) / range_vals


def standardize(
    data: npt.NDArray[np.floating],
    axis: int = 0,
) -> npt.NDArray[np.floating]:
    """
    Standardize data to have zero mean and unit variance.

    Args:
        data: Input array to standardize.
        axis: Axis along which to standardize. Default is 0 (columns).

    Returns:
        Standardized array with mean 0 and std 1.

    Example:
        >>> import numpy as np
        >>> data = np.array([[1, 2], [3, 4]])
        >>> standardize(data, axis=0)
        array([[-1., -1.],
               [ 1.,  1.]])
    """
    mean = data.mean(axis=axis, keepdims=True)
    std = data.std(axis=axis, keepdims=True)

    # Avoid division by zero for constant columns
    std[std == 0] = 1.0

    return (data - mean) / std


def train_test_split(
    X: npt.NDArray[np.floating],
    y: npt.NDArray[np.floating],
    test_size: float = 0.2,
    random_state: int = 42,
) -> tuple[
    npt.NDArray[np.floating],
    npt.NDArray[np.floating],
    npt.NDArray[np.floating],
    npt.NDArray[np.floating],
]:
    """
    Split data into training and test sets.

    Args:
        X: Feature matrix of shape (n_samples, n_features).
        y: Target vector of shape (n_samples,).
        test_size: Proportion of data to use for testing (0 < test_size < 1).
        random_state: Random seed for reproducibility.

    Returns:
        Tuple of (X_train, X_test, y_train, y_test).

    Example:
        >>> import numpy as np
        >>> X = np.array([[1, 2], [3, 4], [5, 6], [7, 8]])
        >>> y = np.array([0, 1, 0, 1])
        >>> X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.5)
    """
    if not 0 < test_size < 1:
        raise ValueError("test_size must be between 0 and 1")

    if X.shape[0] != y.shape[0]:
        raise ValueError(
            f"X and y must have the same number of samples: "
            f"got {X.shape[0]} and {y.shape[0]}"
        )

    rng = np.random.default_rng(random_state)
    n_samples = X.shape[0]
    n_test = int(n_samples * test_size)

    # Generate random indices
    indices = rng.permutation(n_samples)
    test_indices = indices[:n_test]
    train_indices = indices[n_test:]

    return (
        X[train_indices],
        X[test_indices],
        y[train_indices],
        y[test_indices],
    )
