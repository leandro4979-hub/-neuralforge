"""
Tests for the NeuralForge core module.
"""

import pytest
from neuralforge.core import hello, NeuralForgeError


class TestHello:
    """Test cases for the hello function."""

    def test_hello_default(self) -> None:
        """Test hello() with no arguments."""
        assert hello() == "Hello from NeuralForge!"

    def test_hello_with_name(self) -> None:
        """Test hello() with a name argument."""
        assert hello("Alice") == "Hello, Alice! Welcome to NeuralForge."

    def test_hello_with_empty_name(self) -> None:
        """Test hello() with an empty string name."""
        assert hello("") == "Hello, ! Welcome to NeuralForge."

    def test_hello_with_numeric_name(self) -> None:
        """Test hello() with a numeric name (type coercion)."""
        # Python will convert the int to str
        assert hello(123) == "Hello, 123! Welcome to NeuralForge."


class TestNeuralForgeError:
    """Test cases for NeuralForgeError exception."""

    def test_error_is_exception(self) -> None:
        """Test that NeuralForgeError is an Exception subclass."""
        assert issubclass(NeuralForgeError, Exception)

    def test_error_can_be_raised(self) -> None:
        """Test that NeuralForgeError can be raised and caught."""
        with pytest.raises(NeuralForgeError):
            raise NeuralForgeError("Test error")

    def test_error_with_message(self) -> None:
        """Test that NeuralForgeError carries a message."""
        msg = "Something went wrong"
        error = NeuralForgeError(msg)
        assert str(error) == msg
