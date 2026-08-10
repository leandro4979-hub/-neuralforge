#!/usr/bin/env python3
"""
Documentation server for NeuralForge.

This script provides a convenient way to serve the MkDocs documentation locally
for development and preview purposes.

Usage:
    python scripts/serve_docs.py
    python scripts/serve_docs.py --port 8080
    python scripts/serve_docs.py --open
"""

import argparse
import logging
import subprocess
import sys
from pathlib import Path

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Serve NeuralForge documentation locally",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Serve documentation on default port (8000)
  python serve_docs.py

  # Serve on custom port
  python serve_docs.py --port 8080

  # Open browser automatically
  python serve_docs.py --open

  # Use livereload for auto-refresh
  python serve_docs.py --livereload
        """,
    )

    parser.add_argument(
        "--port",
        "-p",
        type=int,
        default=8000,
        help="Port to serve documentation on (default: 8000)",
    )
    parser.add_argument(
        "--host",
        "-H",
        type=str,
        default="127.0.0.1",
        help="Host to serve documentation on (default: 127.0.0.1)",
    )
    parser.add_argument(
        "--open",
        "-o",
        action="store_true",
        help="Open browser automatically",
    )
    parser.add_argument(
        "--livereload",
        "-l",
        action="store_true",
        help="Use livereload for auto-refresh on changes",
    )
    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Enable verbose logging",
    )

    return parser.parse_args()


def check_mkdocs_installed() -> bool:
    """Check if mkdocs is installed."""
    try:
        import mkdocs
        return True
    except ImportError:
        return False


def check_mkdocs_material_installed() -> bool:
    """Check if mkdocs-material theme is installed."""
    try:
        import mkdocs_themes
        return True
    except ImportError:
        return False


def install_mkdocs() -> None:
    """Install mkdocs and required plugins."""
    logger.info("Installing mkdocs and required plugins...")
    
    # Install mkdocs
    subprocess.run(
        [sys.executable, "-m", "pip", "install", "mkdocs"],
        check=True,
    )
    
    # Install material theme
    subprocess.run(
        [sys.executable, "-m", "pip", "install", "mkdocs-material"],
        check=True,
    )
    
    # Install mkdocstrings for API documentation
    subprocess.run(
        [sys.executable, "-m", "pip", "install", "mkdocstrings-python"],
        check=True,
    )
    
    logger.info("mkdocs and plugins installed successfully!")


def serve_docs(args: argparse.Namespace) -> None:
    """Serve the documentation."""
    # Build the command
    cmd = [
        sys.executable,
        "-m",
        "mkdocs",
        "serve",
        "--dev-addr",
        f"{args.host}:{args.port}",
    ]
    
    if args.livereload:
        cmd.append("--livereload")
    
    if args.open:
        cmd.append("--open")
    
    if args.verbose:
        cmd.append("-v")
    
    logger.info(f"Starting mkdocs server on {args.host}:{args.port}")
    logger.info(f"Command: {' '.join(cmd)}")
    
    try:
        # Run the command
        result = subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        logger.error(f"Failed to serve documentation: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        logger.info("Server stopped by user")


def main() -> None:
    """Main function."""
    args = parse_args()

    # Set up logging level
    if args.verbose:
        logger.setLevel(logging.DEBUG)

    logger.info("Starting NeuralForge documentation server...")

    # Check if mkdocs is installed
    if not check_mkdocs_installed():
        logger.warning("mkdocs is not installed")
        install = input("Would you like to install mkdocs? [y/N]: ")
        if install.lower() == "y":
            install_mkdocs()
        else:
            logger.error("mkdocs is required to serve documentation")
            sys.exit(1)
    
    # Check if material theme is installed
    if not check_mkdocs_material_installed():
        logger.warning("mkdocs-material theme is not installed")
        install = input("Would you like to install mkdocs-material? [y/N]: ")
        if install.lower() == "y":
            install_mkdocs()
        else:
            logger.warning("Documentation may not render correctly without mkdocs-material")

    # Check if mkdocs.yml exists
    mkdocs_yml = Path("mkdocs.yml")
    if not mkdocs_yml.exists():
        logger.error(f"mkdocs.yml not found in {Path.cwd()}")
        logger.error("Please run this script from the project root directory")
        sys.exit(1)

    # Check if docs directory exists
    docs_dir = Path("docs")
    if not docs_dir.exists():
        logger.error(f"docs directory not found in {Path.cwd()}")
        sys.exit(1)

    # Serve the documentation
    serve_docs(args)


if __name__ == "__main__":
    main()
