"""
Neural network model utilities.

This module provides simple neural network implementations and model
serialization utilities using PyTorch.
"""

from pathlib import Path

import numpy as np
import numpy.typing as npt
import torch
import torch.nn as nn
import torch.optim as optim


class SimpleNN(nn.Module):
    """
    A simple feedforward neural network.

    This is a basic multi-layer perceptron for classification or regression tasks.

    Args:
        input_size: Number of input features.
        hidden_size: Number of neurons in the hidden layer.
        output_size: Number of output neurons.
        activation: Activation function for hidden layer. Default: ReLU.

    Example:
        >>> model = SimpleNN(input_size=10, hidden_size=5, output_size=2)
        >>> x = torch.randn(32, 10)  # batch of 32 samples, 10 features each
        >>> output = model(x)
    """

    def __init__(
        self,
        input_size: int,
        hidden_size: int,
        output_size: int,
        activation: nn.Module | None = None,
    ) -> None:
        super().__init__()
        self.fc1 = nn.Linear(input_size, hidden_size)
        self.fc2 = nn.Linear(hidden_size, output_size)
        self.activation = activation if activation is not None else nn.ReLU()

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """
        Forward pass of the network.

        Args:
            x: Input tensor of shape (batch_size, input_size).

        Returns:
            Output tensor of shape (batch_size, output_size).
        """
        x = self.fc1(x)
        x = self.activation(x)
        x = self.fc2(x)
        return x


def save_model(
    model: nn.Module,
    path: str,
    optimizer: optim.Optimizer | None = None,
    epoch: int | None = None,
    loss: float | None = None,
) -> None:
    """
    Save a PyTorch model to disk.

    Args:
        model: The PyTorch model to save.
        path: File path to save the model (without extension).
        optimizer: Optional optimizer to save alongside the model.
        epoch: Optional epoch number to include in saved state.
        loss: Optional loss value to include in saved state.

    Example:
        >>> model = SimpleNN(10, 5, 2)
        >>> save_model(model, "my_model")
    """
    checkpoint: dict[str, object] = {
        "model_state_dict": model.state_dict(),
    }

    if optimizer is not None:
        checkpoint["optimizer_state_dict"] = optimizer.state_dict()

    if epoch is not None:
        checkpoint["epoch"] = epoch

    if loss is not None:
        checkpoint["loss"] = loss

    # Save as .pt file
    torch.save(checkpoint, f"{path}.pt")


def load_model(
    path: str,
    model: nn.Module,
    optimizer: optim.Optimizer | None = None,
) -> tuple[nn.Module, optim.Optimizer | None, int | None, float | None]:
    """
    Load a PyTorch model from disk.

    Args:
        path: File path to the saved model (with or without .pt extension).
        model: The model instance to load weights into.
        optimizer: Optional optimizer to load state into.

    Returns:
        Tuple of (model, optimizer, epoch, loss).
        Optimizer, epoch, and loss will be None if not saved.

    Example:
        >>> model = SimpleNN(10, 5, 2)
        >>> optimizer = torch.optim.Adam(model.parameters())
        >>> model, optimizer, epoch, loss = load_model("my_model.pt", model, optimizer)
    """
    # Ensure .pt extension
    path_obj = Path(path)
    if not path_obj.suffix:
        path_obj = path_obj.with_suffix(".pt")

    # weights_only=False because checkpoints may contain optimizer state and
    # arbitrary metadata written by this module. Only load files from trusted sources.
    checkpoint = torch.load(path_obj, weights_only=False)
    model.load_state_dict(checkpoint["model_state_dict"])

    opt = optimizer
    if optimizer is not None and "optimizer_state_dict" in checkpoint:
        optimizer.load_state_dict(checkpoint["optimizer_state_dict"])

    epoch = checkpoint.get("epoch")
    loss = checkpoint.get("loss")

    return model, opt, epoch, loss


def train_simple_model(
    X_train: npt.NDArray[np.floating],
    y_train: npt.NDArray[np.floating],
    input_size: int,
    hidden_size: int = 64,
    output_size: int = 1,
    epochs: int = 100,
    learning_rate: float = 0.001,
    batch_size: int = 32,
) -> SimpleNN:
    """
    Train a simple neural network on the given data.

    Args:
        X_train: Training features of shape (n_samples, n_features).
        y_train: Training targets of shape (n_samples,) or (n_samples, n_outputs).
        input_size: Number of input features.
        hidden_size: Number of neurons in the hidden layer.
        output_size: Number of output neurons.
        epochs: Number of training epochs.
        learning_rate: Learning rate for the optimizer.
        batch_size: Batch size for training.

    Returns:
        Trained SimpleNN model.

    Example:
        >>> import numpy as np
        >>> X = np.random.randn(100, 10)
        >>> y = np.random.randn(100)
        >>> model = train_simple_model(X, y, input_size=10, epochs=10)
    """
    # Convert numpy arrays to PyTorch tensors
    X_tensor = torch.FloatTensor(X_train)
    y_tensor = torch.FloatTensor(y_train)

    # Reshape y if it's 1D
    if y_tensor.dim() == 1:
        y_tensor = y_tensor.unsqueeze(1)

    # Create model
    model = SimpleNN(input_size, hidden_size, output_size)
    model.train()

    # Loss and optimizer
    criterion = nn.MSELoss()
    optimizer = optim.Adam(model.parameters(), lr=learning_rate)

    # Training loop
    n_samples = X_tensor.shape[0]

    for _epoch in range(epochs):
        # Mini-batch training
        for i in range(0, n_samples, batch_size):
            X_batch = X_tensor[i : i + batch_size]
            y_batch = y_tensor[i : i + batch_size]

            # Forward pass
            outputs = model(X_batch)
            loss = criterion(outputs, y_batch)

            # Backward pass and optimize
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

    return model
