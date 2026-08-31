#!/usr/bin/env python3
"""
Training script for NeuralForge models.

This script provides a command-line interface for training machine learning models
using NeuralForge's ML utilities.

Usage:
    python scripts/train_model.py --help
    python scripts/train_model.py --data-type synthetic --n-samples 1000 --epochs 50
    python scripts/train_model.py --data-type csv --data-path data.csv --target-column label
"""

import argparse
import logging
import sys

import numpy as np
import torch

from neuralforge.ml import (
    CSVDataLoader,
    SimpleNN,
    SyntheticDataLoader,
    normalize,
    save_model,
    standardize,
    train_simple_model,
)

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Train a machine learning model using NeuralForge",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Train on synthetic data
  python train_model.py --data-type synthetic --n-samples 1000 --epochs 50

  # Train on CSV data
  python train_model.py --data-type csv --data-path data.csv --target-column label

  # Train with custom parameters
  python train_model.py --data-type synthetic --n-features 20 --hidden-size 128 --lr 0.001
        """,
    )

    # Data source
    parser.add_argument(
        "--data-type",
        type=str,
        choices=["synthetic", "csv"],
        default="synthetic",
        help="Type of data to use for training (default: synthetic)",
    )

    # Synthetic data parameters
    parser.add_argument(
        "--n-samples",
        type=int,
        default=1000,
        help="Number of samples for synthetic data (default: 1000)",
    )
    parser.add_argument(
        "--n-features",
        type=int,
        default=10,
        help="Number of features for synthetic data (default: 10)",
    )
    parser.add_argument(
        "--task",
        type=str,
        choices=["classification", "regression"],
        default="regression",
        help="Type of task for synthetic data (default: regression)",
    )
    parser.add_argument(
        "--n-classes",
        type=int,
        default=2,
        help="Number of classes for classification (default: 2)",
    )

    # CSV data parameters
    parser.add_argument(
        "--data-path",
        type=str,
        default=None,
        help="Path to CSV file for training data",
    )
    parser.add_argument(
        "--target-column",
        type=str,
        default=None,
        help="Name of the target column in CSV file",
    )
    parser.add_argument(
        "--feature-columns",
        type=str,
        nargs="+",
        default=None,
        help="Names of feature columns in CSV file",
    )

    # Model parameters
    parser.add_argument(
        "--hidden-size",
        type=int,
        default=64,
        help="Number of neurons in hidden layer (default: 64)",
    )
    parser.add_argument(
        "--output-size",
        type=int,
        default=1,
        help="Number of output neurons (default: 1)",
    )

    # Training parameters
    parser.add_argument(
        "--epochs",
        type=int,
        default=100,
        help="Number of training epochs (default: 100)",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=32,
        help="Batch size for training (default: 32)",
    )
    parser.add_argument(
        "--lr",
        "--learning-rate",
        type=float,
        default=0.001,
        help="Learning rate for optimizer (default: 0.001)",
    )

    # Preprocessing
    parser.add_argument(
        "--normalize",
        action="store_true",
        help="Normalize input data to [0, 1]",
    )
    parser.add_argument(
        "--standardize",
        action="store_true",
        help="Standardize input data to mean=0, std=1",
    )

    # Output
    parser.add_argument(
        "--model-path",
        type=str,
        default="trained_model",
        help="Path to save trained model (without extension, default: trained_model)",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=42,
        help="Random seed for reproducibility (default: 42)",
    )
    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Enable verbose logging",
    )

    return parser.parse_args()


def load_data(args: argparse.Namespace) -> tuple[np.ndarray, np.ndarray]:
    """Load training data based on arguments."""
    if args.data_type == "synthetic":
        logger.info(f"Generating synthetic {args.task} data...")
        loader = SyntheticDataLoader(
            n_samples=args.n_samples,
            n_features=args.n_features,
            n_classes=args.n_classes,
            task=args.task,
            random_state=args.seed,
        )
        X, y = loader.load()
        logger.info(f"Generated {X.shape[0]} samples with {X.shape[1]} features")

    elif args.data_type == "csv":
        if not args.data_path:
            logger.error("--data-path is required for CSV data type")
            sys.exit(1)
        if not args.target_column:
            logger.error("--target-column is required for CSV data type")
            sys.exit(1)

        logger.info(f"Loading data from {args.data_path}...")
        loader = CSVDataLoader(
            path=args.data_path,
            target_column=args.target_column,
            feature_columns=args.feature_columns,
        )
        X, y = loader.load()
        logger.info(f"Loaded {X.shape[0]} samples with {X.shape[1]} features")

    else:
        logger.error(f"Unknown data type: {args.data_type}")
        sys.exit(1)

    return X, y


def preprocess_data(
    X: np.ndarray,
    y: np.ndarray,
    args: argparse.Namespace,
) -> tuple[np.ndarray, np.ndarray]:
    """Preprocess data based on arguments."""
    if args.normalize:
        logger.info("Normalizing data...")
        X = normalize(X)

    if args.standardize:
        logger.info("Standardizing data...")
        X = standardize(X)

    return X, y


def train_and_save(
    X: np.ndarray,
    y: np.ndarray,
    args: argparse.Namespace,
) -> SimpleNN:
    """Train model and save to disk."""
    logger.info("Training model...")
    logger.info(f"  Input size: {X.shape[1]}")
    logger.info(f"  Hidden size: {args.hidden_size}")
    logger.info(f"  Output size: {args.output_size}")
    logger.info(f"  Epochs: {args.epochs}")
    logger.info(f"  Batch size: {args.batch_size}")
    logger.info(f"  Learning rate: {args.lr}")

    # Set random seed for reproducibility
    np.random.seed(args.seed)
    torch.manual_seed(args.seed)

    # Train model
    model = train_simple_model(
        X,
        y,
        input_size=X.shape[1],
        hidden_size=args.hidden_size,
        output_size=args.output_size,
        epochs=args.epochs,
        learning_rate=args.lr,
        batch_size=args.batch_size,
    )

    # Save model
    logger.info(f"Saving model to {args.model_path}.pt...")
    save_model(
        model,
        args.model_path,
        epoch=args.epochs,
        loss=0.0,  # Loss not tracked in train_simple_model currently
    )

    return model


def evaluate_model(
    model: SimpleNN,
    X: np.ndarray,
    y: np.ndarray,
    args: argparse.Namespace,
) -> None:
    """Evaluate the trained model."""
    logger.info("Evaluating model...")

    with torch.no_grad():
        X_tensor = torch.FloatTensor(X)
        y_tensor = torch.FloatTensor(y)

        # Reshape y if needed
        if y_tensor.dim() == 1:
            y_tensor = y_tensor.unsqueeze(1)

        predictions = model(X_tensor)

        if args.task == "regression":
            # Calculate MSE
            mse = torch.nn.functional.mse_loss(predictions, y_tensor).item()
            logger.info(f"Mean Squared Error: {mse:.6f}")
        else:
            # Calculate accuracy for classification
            predicted_classes = torch.argmax(predictions, dim=1)
            actual_classes = (
                torch.argmax(y_tensor, dim=1)
                if y_tensor.shape[1] > 1
                else y_tensor.squeeze()
            )
            accuracy = (predicted_classes == actual_classes).float().mean().item()
            logger.info(f"Accuracy: {accuracy * 100:.2f}%")


def main() -> None:
    """Main training function."""
    args = parse_args()

    # Set up logging level
    if args.verbose:
        logger.setLevel(logging.DEBUG)
        logging.getLogger("neuralforge").setLevel(logging.DEBUG)

    logger.info("Starting NeuralForge training...")
    logger.info(f"Arguments: {args}")

    try:
        # Load data
        X, y = load_data(args)

        # Preprocess data
        X, y = preprocess_data(X, y, args)

        # Train and save model
        model = train_and_save(X, y, args)

        # Evaluate model
        evaluate_model(model, X, y, args)

        logger.info("Training completed successfully!")
        logger.info(f"Model saved to: {args.model_path}.pt")

    except Exception as e:
        logger.error(f"Training failed: {e}")
        if args.verbose:
            import traceback

            traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
