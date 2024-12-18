# Variables
POETRY := poetry
BASH := bash
MAKE := make

# Installs the dependencies
install_dependencies:
	$(MAKE) remove_environment;
	$(POETRY) env use $(shell which python3.12);
	$(POETRY) install

# Removes the existing environment
remove_environment:
	rm -rf .venv;

# Activates poetry environment
activate_environment:
	$(POETRY) shell