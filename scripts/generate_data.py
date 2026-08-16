#!/usr/bin/env python3
"""
Data generation script for NeuralForge.

This script generates synthetic datasets for testing and development purposes.

Usage:
    python scripts/generate_data.py --help
    python scripts/generate_data.py --output data.csv --n-samples 1000 --n-features 10
    python scripts/generate_data.py --output data.csv --task classification --n-classes 3
"""

import argparse
import logging
import sys

import numpy as np
import pandas as pd

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Generate synthetic datasets for NeuralForge",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Generate regression dataset
  python generate_data.py --output data.csv --n-samples 1000 --n-features 10

  # Generate classification dataset
  python generate_data.py --output data.csv --task classification --n-classes 3

  # Generate with noise
  python generate_data.py --output data.csv --noise 0.5

  # Generate with specific random seed
  python generate_data.py --output data.csv --seed 42
        """,
    )

    # Output
    parser.add_argument(
        "--output",
        "-o",
        type=str,
        default="data.csv",
        help="Output file path (default: data.csv)",
    )

    # Dataset parameters
    parser.add_argument(
        "--n-samples",
        "-n",
        type=int,
        default=1000,
        help="Number of samples to generate (default: 1000)",
    )
    parser.add_argument(
        "--n-features",
        "-f",
        type=int,
        default=10,
        help="Number of features per sample (default: 10)",
    )
    parser.add_argument(
        "--task",
        type=str,
        choices=["regression", "classification"],
        default="regression",
        help="Type of dataset to generate (default: regression)",
    )
    parser.add_argument(
        "--n-classes",
        "-c",
        type=int,
        default=2,
        help="Number of classes for classification (default: 2)",
    )

    # Data generation parameters
    parser.add_argument(
        "--noise",
        type=float,
        default=0.1,
        help="Amount of noise to add to the data (default: 0.1)",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=42,
        help="Random seed for reproducibility (default: 42)",
    )
    parser.add_argument(
        "--target-column",
        type=str,
        default="target",
        help="Name of the target column (default: target)",
    )
    parser.add_argument(
        "--feature-prefix",
        type=str,
        default="feature_",
        help="Prefix for feature column names (default: feature_)",
    )

    # Format options
    parser.add_argument(
        "--format",
        type=str,
        choices=["csv", "numpy", "pandas"],
        default="csv",
        help="Output format (default: csv)",
    )
    parser.add_argument(
        "--header",
        action="store_true",
        default=True,
        help="Include header row in CSV output (default: True)",
    )
    parser.add_argument(
        "--index",
        action="store_true",
        help="Include index column in CSV output",
    )

    # Verbosity
    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Enable verbose logging",
    )

    return parser.parse_args()


def generate_regression_data(
    n_samples: int,
    n_features: int,
    noise: float,
    rng: np.random.Generator,
) -> tuple[np.ndarray, np.ndarray]:
    """
    Generate synthetic regression data.

    Creates a linear relationship with some noise.

    Args:
        n_samples: Number of samples.
        n_features: Number of features.
        noise: Amount of noise to add.
        rng: Random number generator.

    Returns:
        Tuple of (features, targets).
    """
    # Generate random features
    X = rng.standard_normal((n_samples, n_features))

    # Generate random weights and bias
    weights = rng.standard_normal(n_features)
    bias = rng.standard_normal()

    # Calculate targets with linear relationship and noise
    y = X @ weights + bias + noise * rng.standard_normal(n_samples)

    return X, y


def generate_classification_data(
    n_samples: int,
    n_features: int,
    n_classes: int,
    noise: float,
    rng: np.random.Generator,
) -> tuple[np.ndarray, np.ndarray]:
    """
    Generate synthetic classification data.

    Creates data with linear decision boundaries.

    Args:
        n_samples: Number of samples.
        n_features: Number of features.
        n_classes: Number of classes.
        noise: Amount of noise to add.
        rng: Random number generator.

    Returns:
        Tuple of (features, targets).
    """
    # Generate random features
    X = rng.standard_normal((n_samples, n_features))

    # Generate random weights and bias for each class
    weights = rng.standard_normal((n_features, n_classes))
    bias = rng.standard_normal(n_classes)

    # Calculate logits
    logits = X @ weights + bias + noise * rng.standard_normal((n_samples, n_classes))

    # Convert to probabilities and then to class labels
    probs = np.exp(logits) / np.sum(np.exp(logits), axis=1, keepdims=True)
    y = np.argmax(probs, axis=1).astype(np.float64)

    return X, y


def save_csv(
    X: np.ndarray,
    y: np.ndarray,
    output_path: str,
    target_column: str,
    feature_prefix: str,
    header: bool,
    index: bool,
) -> None:
    """Save data to CSV file."""
    # Create DataFrame
    feature_columns = [f"{feature_prefix}{i}" for i in range(X.shape[1])]
    data = {col: X[:, i] for i, col in enumerate(feature_columns)}
    data[target_column] = y

    df = pd.DataFrame(data)

    # Save to CSV
    df.to_csv(
        output_path,
        index=index,
        header=header,
    )
    logger.info(f"Saved CSV file to {output_path}")


def save_numpy(
    X: np.ndarray,
    y: np.ndarray,
    output_path: str,
) -> None:
    """Save data to numpy .npz file."""
    output_path = output_path if output_path.endswith(".npz") else f"{output_path}.npz"
    np.savez(
        output_path,
        X=X,
        y=y,
    )
    logger.info(f"Saved numpy file to {output_path}")


def save_pandas(
    X: np.ndarray,
    y: np.ndarray,
    output_path: str,
    target_column: str,
    feature_prefix: str,
) -> None:
    """Save data to pandas pickle file."""
    feature_columns = [f"{feature_prefix}{i}" for i in range(X.shape[1])]
    data = {col: X[:, i] for i, col in enumerate(feature_columns)}
    data[target_column] = y

    df = pd.DataFrame(data)
    output_path = output_path if output_path.endswith(".pkl") else f"{output_path}.pkl"
    df.to_pickle(output_path)
    logger.info(f"Saved pandas file to {output_path}")


def main() -> None:
    """Main data generation function."""
    args = parse_args()

    # Set up logging level
    if args.verbose:
        logger.setLevel(logging.DEBUG)

    logger.info("Starting data generation...")
    logger.info(f"Arguments: {args}")

    try:
        # Set random seed
        rng = np.random.default_rng(args.seed)

        # Generate data
        if args.task == "regression":
            logger.info(f"Generating regression data with {args.n_samples} samples...")
            X, y = generate_regression_data(
                args.n_samples,
                args.n_features,
                args.noise,
                rng,
            )
        else:  # classification
            logger.info(
                f"Generating classification data with {args.n_samples} samples..."
            )
            X, y = generate_classification_data(
                args.n_samples,
                args.n_features,
                args.n_classes,
                args.noise,
                rng,
            )

        logger.info(f"Generated data: X.shape={X.shape}, y.shape={y.shape}")

        # Save data
        output_path = args.output
        if args.format == "csv":
            save_csv(
                X,
                y,
                output_path,
                args.target_column,
                args.feature_prefix,
                args.header,
                args.index,
            )
        elif args.format == "numpy":
            save_numpy(X, y, output_path)
        elif args.format == "pandas":
            save_pandas(X, y, output_path, args.target_column, args.feature_prefix)

        # Print summary
        logger.info("Data generation completed!")
        logger.info(f"  Samples: {X.shape[0]}")
        logger.info(f"  Features: {X.shape[1]}")
        logger.info(f"  Task: {args.task}")
        if args.task == "classification":
            unique_classes = np.unique(y)
            logger.info(f"  Classes: {len(unique_classes)}")
            logger.info(
                f"  Class distribution: {dict(zip(*np.unique(y, return_counts=True)))}"
            )
        logger.info(f"  Saved to: {output_path}")

    except Exception as e:
        logger.error(f"Data generation failed: {e}")
        if args.verbose:
            import traceback

            traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
