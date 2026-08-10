# Makefile for NeuralForge development tasks
# Usage: make <target>

.PHONY: help install lint test type format clean build docs

# Default target
help:
	@echo "NeuralForge Development Makefile"
	@echo "================================"
	@echo ""
	@echo "Available targets:"
	@echo "  install    - Install the package in development mode"
	@echo "  lint       - Run linting (ruff check)"
	@echo "  format     - Auto-format code (ruff format)"
	@echo "  test       - Run tests with coverage"
	@echo "  test-no-cov - Run tests without coverage"
	@echo "  type       - Run type checking (mypy)"
	@echo "  clean      - Remove build artifacts and cache"
	@echo "  build      - Build the package"
	@echo "  docs       - Build documentation (if configured)"
	@echo "  all        - Run lint, type, and test"
	@echo ""

# Installation
install:
	pip install -e ".[dev]"

# Linting
lint:
	ruff check .

# Formatting
format:
	ruff check . --fix
	ruff format .

# Type checking
type:
	mypy src/

# Testing
test:
	pytest --cov=src/neuralforge --cov-report=term-missing

test-no-cov:
	pytest --no-cov

# Clean build artifacts
clean:
	rm -rf .mypy_cache
	rm -rf .ruff_cache
	rm -rf __pycache__
	rm -rf *.egg-info
	rm -rf build/
	rm -rf dist/
	rm -rf .pytest_cache/
	rm -rf .coverage
	rm -rf coverage.xml
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true

# Build the package
build:
	python -m build

# Documentation (placeholder - uncomment when docs are set up)
# docs:
# 	mkdocs build

# Run all checks
all: lint type test
