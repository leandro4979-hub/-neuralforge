"""
Machine Learning utilities for NeuralForge.

This module provides helper functions and classes for common ML tasks,
including data preprocessing, model utilities, neural network helpers,
data loading, and model evaluation.
"""

from .data import normalize, standardize, train_test_split
from .data_loaders import BaseDataLoader, CSVDataLoader, DataLoaderFactory, SyntheticDataLoader
from .metrics import (
    binary_accuracy,
    binary_confusion_matrix,
    mean_absolute_error,
    mean_squared_error,
    r2_score,
    root_mean_squared_error,
)
from .models import SimpleNN, load_model, save_model, train_simple_model

__all__ = [
    # Data preprocessing
    "normalize",
    "standardize",
    "train_test_split",
    # Models
    "SimpleNN",
    "save_model",
    "load_model",
    "train_simple_model",
    # Data loaders
    "BaseDataLoader",
    "CSVDataLoader",
    "SyntheticDataLoader",
    "DataLoaderFactory",
    # Metrics
    "mean_absolute_error",
    "mean_squared_error",
    "root_mean_squared_error",
    "r2_score",
    "binary_accuracy",
    "binary_confusion_matrix",
]
