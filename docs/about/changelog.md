# Changelog

All notable changes to NeuralForge will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure with `src/neuralforge/` package
- Core module with `hello()`, `run()`, and `NeuralForgeError`
- Machine learning utilities module (`ml/`)
  - Data preprocessing: `normalize()`, `standardize()`, `train_test_split()`
  - Data loaders: `CSVDataLoader`, `SyntheticDataLoader`, `DataLoaderFactory`
  - Models: `SimpleNN`, `save_model()`, `load_model()`, `train_simple_model()`
- Comprehensive test suite with `pytest`
- GitHub Actions CI workflow
- Makefile for common development tasks
- MkDocs documentation setup with Material theme
- CONTRIBUTING.md with contribution guidelines
- Code style guide and testing guide

### Changed
- Expanded README.md with comprehensive project documentation
- Updated .gitignore with project-specific patterns

### Fixed
- N/A (initial release)

### Removed
- N/A (initial release)

## [0.1.0] - 2026-05-24

### Added
- Initial commit with repository setup
  - README.md with project description
  - LICENSE (MIT)
  - .gitignore (Python-focused)

---

## Versioning

NeuralForge uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html):

- **MAJOR** version: Breaking changes, incompatible API modifications
- **MINOR** version: Backwards-compatible new functionality
- **PATCH** version: Backwards-compatible bug fixes

## Types of Changes

| Type | Description |
|------|-------------|
| **Added** | New features, functionality, or improvements |
| **Changed** | Changes to existing functionality |
| **Fixed** | Bug fixes |
| **Removed** | Deprecated or removed features |
| **Security** | Security-related changes |
| **Deprecated** | Soon-to-be removed features |

## Contributing to the Changelog

When making a pull request, please include a changelog entry in your PR description:

```markdown
## Changelog Entry

### Added/Changed/Fixed/Removed
- Brief description of the change
```

Or update the changelog directly as part of your PR.

## Release Process

1. Update the version in `pyproject.toml`
2. Update this changelog with the new version and date
3. Create a Git tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
4. Push the tag: `git push origin vX.Y.Z`
5. Create a GitHub release with the changelog notes

## Previous Releases

- **v0.1.0** (2026-05-24): Initial release - Repository setup with basic files

---

*For a complete history, see the [Git commit log](https://github.com/leandro4979-hub/-neuralforge/commits/main).*
