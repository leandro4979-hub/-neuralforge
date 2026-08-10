"""
Data loading utilities for machine learning.

This module provides classes and functions for loading and preprocessing
various types of datasets for machine learning tasks.
"""

from abc import ABC, abstractmethod
from pathlib import Path
from typing import Any, Dict, Iterator, List, Optional, Tuple, Union

import numpy as np
import numpy.typing as npt


class BaseDataLoader(ABC):
    """
    Abstract base class for data loaders.

    All data loaders should inherit from this class and implement
    the required methods.
    """

    @abstractmethod
    def load(self) -> Tuple[npt.NDArray[np.floating], npt.NDArray[np.floating]]:
        """
        Load and return the dataset.

        Returns:
            Tuple of (features, targets).
        """
        pass

    @abstractmethod
    def __len__(self) -> int:
        """Return the number of samples in the dataset."""
        pass

    @abstractmethod
    def __iter__(self) -> Iterator[Tuple[npt.NDArray[np.floating], npt.NDArray[np.floating]]]:
        """Iterate over batches of data."""
        pass


class CSVDataLoader(BaseDataLoader):
    """
    Data loader for CSV files.

    Args:
        path: Path to the CSV file.
        target_column: Name or index of the target column.
        feature_columns: List of feature column names or indices.
        delimiter: CSV delimiter. Default: ','.
        skip_header: Whether to skip the header row. Default: True.
        batch_size: Batch size for iteration. Default: 32.
        shuffle: Whether to shuffle data. Default: False.

    Example:
        >>> loader = CSVDataLoader(
        ...     path="data.csv",
        ...     target_column="label",
        ...     feature_columns=["f1", "f2", "f3"]
        ... )
        >>> X, y = loader.load()
    """

    def __init__(
        self,
        path: Union[str, Path],
        target_column: Union[str, int],
        feature_columns: Optional[List[Union[str, int]]] = None,
        delimiter: str = ",",
        skip_header: bool = True,
        batch_size: int = 32,
        shuffle: bool = False,
    ) -> None:
        self.path = Path(path)
        self.target_column = target_column
        self.feature_columns = feature_columns
        self.delimiter = delimiter
        self.skip_header = skip_header
        self.batch_size = batch_size
        self.shuffle = shuffle
        
        self._data: Optional[Tuple[npt.NDArray[np.floating], npt.NDArray[np.floating]]] = None
        self._indices: Optional[npt.NDArray[np.int_]] = None

    def load(self) -> Tuple[npt.NDArray[np.floating], npt.NDArray[np.floating]]:
        """Load data from CSV file."""
        import csv
        
        features: List[List[float]] = []
        targets: List[float] = []
        
        with open(self.path, "r") as f:
            reader = csv.reader(f, delimiter=self.delimiter)
            
            if self.skip_header:
                header = next(reader)
                # If feature_columns not specified, use all columns except target
                if self.feature_columns is None:
                    self.feature_columns = [
                        i for i, col in enumerate(header) 
                        if col != self.target_column
                    ]
                # Convert column names to indices if needed
                if isinstance(self.target_column, str):
                    self.target_column = header.index(self.target_column)
                if self.feature_columns and isinstance(self.feature_columns[0], str):
                    self.feature_columns = [
                        header.index(col) for col in self.feature_columns
                    ]
            
            for row in reader:
                # Extract features
                feature_row = [float(row[i]) for i in self.feature_columns]
                features.append(feature_row)
                
                # Extract target
                target = float(row[self.target_column])
                targets.append(target)
        
        self._data = (np.array(features), np.array(targets))
        self._indices = np.arange(len(targets))
        
        if self.shuffle:
            np.random.shuffle(self._indices)
        
        return self._data

    def __len__(self) -> int:
        """Return number of samples."""
        if self._data is None:
            self.load()
        return len(self._data[1])

    def __iter__(self) -> Iterator[Tuple[npt.NDArray[np.floating], npt.NDArray[np.floating]]]:
        """Iterate over batches."""
        if self._data is None:
            self.load()
        
        X, y = self._data
        n_samples = len(y)
        
        # Shuffle indices if needed
        if self.shuffle:
            self._indices = np.random.permutation(self._indices)
        
        # Yield batches
        for i in range(0, n_samples, self.batch_size):
            batch_indices = self._indices[i:i + self.batch_size]
            yield X[batch_indices], y[batch_indices]


class SyntheticDataLoader(BaseDataLoader):
    """
    Data loader for generating synthetic datasets.

    Useful for testing and prototyping machine learning models.

    Args:
        n_samples: Number of samples to generate.
        n_features: Number of features per sample.
        n_classes: Number of classes for classification. Default: 2.
        task: Type of task ('classification' or 'regression'). Default: 'classification'.
        random_state: Random seed for reproducibility. Default: 42.
        batch_size: Batch size for iteration. Default: 32.

    Example:
        >>> loader = SyntheticDataLoader(n_samples=1000, n_features=10, task="classification")
        >>> X, y = loader.load()
    """

    def __init__(
        self,
        n_samples: int,
        n_features: int,
        n_classes: int = 2,
        task: str = "classification",
        random_state: int = 42,
        batch_size: int = 32,
    ) -> None:
        self.n_samples = n_samples
        self.n_features = n_features
        self.n_classes = n_classes
        self.task = task
        self.random_state = random_state
        self.batch_size = batch_size
        
        self._rng = np.random.default_rng(random_state)
        self._data: Optional[Tuple[npt.NDArray[np.floating], npt.NDArray[np.floating]]] = None
        self._indices: Optional[npt.NDArray[np.int_]] = None

    def load(self) -> Tuple[npt.NDArray[np.floating], npt.NDArray[np.floating]]:
        """Generate synthetic data."""
        if self.task == "classification":
            X, y = self._generate_classification_data()
        elif self.task == "regression":
            X, y = self._generate_regression_data()
        else:
            raise ValueError(f"Unknown task: {self.task}. Use 'classification' or 'regression'.")
        
        self._data = (X, y)
        self._indices = np.arange(self.n_samples)
        return self._data

    def _generate_classification_data(self) -> Tuple[npt.NDArray[np.floating], npt.NDArray[np.floating]]:
        """Generate synthetic classification data."""
        # Generate random features
        X = self._rng.standard_normal((self.n_samples, self.n_features))
        
        # Generate random weights for a linear decision boundary
        weights = self._rng.standard_normal((self.n_features, self.n_classes))
        bias = self._rng.standard_normal(self.n_classes)
        
        # Compute logits
        logits = X @ weights + bias
        
        # Convert to probabilities and then to class labels
        probs = np.exp(logits) / np.sum(np.exp(logits), axis=1, keepdims=True)
        y = np.argmax(probs, axis=1).astype(np.float64)
        
        return X, y

    def _generate_regression_data(self) -> Tuple[npt.NDArray[np.floating], npt.NDArray[np.floating]]:
        """Generate synthetic regression data."""
        # Generate random features
        X = self._rng.standard_normal((self.n_samples, self.n_features))
        
        # Generate random weights for a linear relationship
        weights = self._rng.standard_normal(self.n_features)
        bias = self._rng.standard_normal()
        
        # Compute targets with some noise
        y = X @ weights + bias + 0.1 * self._rng.standard_normal(self.n_samples)
        
        return X, y

    def __len__(self) -> int:
        """Return number of samples."""
        return self.n_samples

    def __iter__(self) -> Iterator[Tuple[npt.NDArray[np.floating], npt.NDArray[np.floating]]]:
        """Iterate over batches."""
        if self._data is None:
            self.load()
        
        X, y = self._data
        
        # Shuffle indices
        self._indices = self._rng.permutation(self._indices)
        
        # Yield batches
        for i in range(0, self.n_samples, self.batch_size):
            batch_indices = self._indices[i:i + self.batch_size]
            yield X[batch_indices], y[batch_indices]


class DataLoaderFactory:
    """
    Factory class for creating data loaders.

    Provides a convenient way to create different types of data loaders
    based on configuration.

    Example:
        >>> factory = DataLoaderFactory()
        >>> loader = factory.create(
        ...     loader_type="synthetic",
        ...     n_samples=1000,
        ...     n_features=10
        ... )
    """

    @staticmethod
    def create(
        loader_type: str,
        **kwargs: Any,
    ) -> BaseDataLoader:
        """
        Create a data loader based on type.

        Args:
            loader_type: Type of loader ('csv', 'synthetic').
            **kwargs: Arguments to pass to the loader constructor.

        Returns:
            An instance of the specified data loader.
        """
        loaders: Dict[str, type] = {
            "csv": CSVDataLoader,
            "synthetic": SyntheticDataLoader,
        }
        
        if loader_type not in loaders:
            raise ValueError(f"Unknown loader type: {loader_type}. Available: {list(loaders.keys())}")
        
        return loaders[loader_type](**kwargs)
