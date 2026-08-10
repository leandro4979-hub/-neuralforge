# Contributing to NeuralForge

We welcome contributions from the community! This guide will help you get started with contributing to NeuralForge.

## 🎯 Ways to Contribute

There are many ways you can contribute to NeuralForge:

- **Reporting Bugs**: Help us identify and fix issues
- **Suggesting Features**: Share your ideas for new features
- **Code Contributions**: Submit pull requests with bug fixes or new features
- **Documentation**: Improve and expand our documentation
- **Testing**: Write tests to improve code coverage
- **Code Review**: Review pull requests from other contributors

## 🚀 Getting Started

### 1. Fork the Repository

Start by forking the NeuralForge repository on GitHub:

1. Go to [https://github.com/leandro4979-hub/-neuralforge](https://github.com/leandro4979-hub/-neuralforge)
2. Click the "Fork" button in the top-right corner
3. Select your GitHub account as the destination

### 2. Clone Your Fork

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/-neuralforge.git
cd -neuralforge

# Add the upstream repository
git remote add upstream https://github.com/leandro4979-hub/-neuralforge.git
```

### 3. Set Up Development Environment

```bash
# Create a virtual environment
python -m venv .venv

# Activate the virtual environment
# Linux/Mac:
source .venv/bin/activate
# Windows:
.venv\Scripts\activate

# Install development dependencies
pip install -e ".[dev]"
```

### 4. Verify Your Setup

```bash
# Run tests
make test

# Run linting
make lint

# Run type checking
make type
```

## 📝 Contribution Guidelines

### Code Style

Please follow these coding standards:

- **PEP 8**: Follow [PEP 8](https://peps.python.org/pep-0008/) style guide
- **Type Hints**: Use type hints for all function parameters and return values
- **Docstrings**: Include docstrings for all public functions and classes
- **Line Length**: Keep lines under 88 characters (configured in ruff)

Run the formatter and linter before committing:

```bash
make format  # Auto-format your code
make lint    # Check for linting issues
```

### Commit Messages

Write clear, descriptive commit messages following these guidelines:

- Use the **imperative mood** ("Add feature" not "Added feature")
- **First line**: 50 characters or less, summarizing the change
- **Body**: Explain what was changed and why (if needed)
- **Reference issues**: Use "Closes #123" or "Fixes #456" to link to issues

**Good Examples:**
```
feat: Add CSV data loader implementation

Implement CSVDataLoader class for loading data from CSV files.
Includes support for custom delimiters and column selection.

Closes #42
```

```
fix: Correct normalization edge case

Fix division by zero when normalizing constant columns.
Adds check to set range to 1.0 when min == max.

Fixes #37
```

**Bad Examples:**
```
fixed bug
```

```
WIP
```

### Pull Request Process

1. **Create a Feature Branch**:
   ```bash
   git checkout -b feat/your-feature-name
   # or for bugs:
   git checkout -b fix/your-bug-fix
   ```

2. **Make Your Changes**:
   - Follow the coding standards
   - Add tests for new functionality
   - Update documentation if needed

3. **Run All Checks**:
   ```bash
   make all
   ```

4. **Commit Your Changes**:
   ```bash
   git add .
   git commit -m "Your commit message"
   ```

5. **Push to Your Fork**:
   ```bash
   git push origin feat/your-feature-name
   ```

6. **Open a Pull Request**:
   - Go to the [NeuralForge repository](https://github.com/leandro4979-hub/-neuralforge)
   - Click "New Pull Request"
   - Select your fork and branch
   - Fill out the PR template
   - Submit the pull request

### Pull Request Template

When opening a pull request, please include the following information:

```markdown
## Description

[Brief description of the changes]

## Related Issues

[List any related issues, e.g., Closes #123, Fixes #456]

## Changes Made

- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Test addition/improvement
- [ ] Code refactoring
- [ ] Other (please specify)

## Testing

[Describe how you tested your changes]

## Checklist

- [ ] Code follows PEP 8 style guidelines
- [ ] All tests pass
- [ ] New functionality has been tested
- [ ] Documentation has been updated (if applicable)
- [ ] Type hints have been added
- [ ] Docstrings have been added/updated
```

## 📂 Project Structure

```
neuralforge/
├── src/
│   └── neuralforge/
│       ├── __init__.py      # Package initialization
│       ├── core.py          # Core functions and classes
│       └── ml/              # Machine learning utilities
│           ├── __init__.py
│           ├── data.py      # Data preprocessing functions
│           ├── data_loaders.py  # Data loading classes
│           └── models.py    # Neural network models
├── tests/                  # Unit and integration tests
│   ├── __init__.py
│   ├── test_core.py        # Tests for core module
│   └── test_ml.py          # Tests for ML module
├── docs/                   # Documentation
│   ├── index.md
│   ├── getting-started/
│   └── api/
├── scripts/                # Utility scripts
├── .github/                # GitHub configuration
│   └── workflows/
│       └── ci.yml          # CI/CD workflow
├── mkdocs.yml              # MkDocs configuration
├── pyproject.toml          # Project configuration
├── Makefile                # Development tasks
├── README.md               # Project overview
└── CONTRIBUTING.md         # This file
```

## 🔧 Development Tools

### Makefile Commands

| Command | Description |
|---------|-------------|
| `make install` | Install package in development mode |
| `make lint` | Run linting (ruff check) |
| `make format` | Auto-format code (ruff) |
| `make test` | Run tests with coverage |
| `make test-no-cov` | Run tests without coverage |
| `make type` | Run type checking (mypy) |
| `make clean` | Remove build artifacts and cache |
| `make all` | Run lint, type, and test |

### Testing

We use `pytest` for testing. Write tests for new functionality and ensure all existing tests pass.

```bash
# Run all tests
pytest

# Run tests with coverage
pytest --cov=src/neuralforge

# Run a specific test file
pytest tests/test_ml.py

# Run a specific test function
pytest tests/test_ml.py::TestDataPreprocessing::test_normalize_basic
```

### Type Checking

We use `mypy` for static type checking:

```bash
mypy src/
```

### Linting and Formatting

We use `ruff` for both linting and formatting:

```bash
# Check for linting issues
ruff check .

# Auto-fix linting issues
ruff check . --fix

# Format code
ruff format .
```

## 📚 Code Review Process

1. **Initial Review**: Maintainers will review your PR within a few days
2. **Feedback**: You may receive feedback or requests for changes
3. **Address Feedback**: Make the requested changes and push new commits
4. **Approval**: Once all feedback is addressed, your PR will be approved
5. **Merge**: A maintainer will merge your PR into the main branch

## 🤝 Community Guidelines

### Be Respectful

- Treat everyone with respect and kindness
- Be open to feedback and different perspectives
- Avoid offensive or discriminatory language

### Be Patient

- Maintainers are volunteers with limited time
- PR reviews may take time
- Be patient with questions and feedback

### Be Helpful

- Help other contributors with questions
- Review other people's pull requests
- Share your knowledge and expertise

## 📄 License

By contributing to NeuralForge, you agree that your contributions will be licensed under the [MIT License](../../about/license.md).

## 🙏 Thank You!

Thank you for considering contributing to NeuralForge! Your contributions help make this project better for everyone.

If you have any questions or need help getting started, please open an issue or discussion on GitHub.
