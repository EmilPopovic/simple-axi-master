# Makefile for AXI Master Vivado Project
# PYNQ-Z2 Target

PROJECT_NAME := axi-master
PROJECT_DIR := $(CURDIR)/$(PROJECT_NAME)
SCRIPTS_DIR := $(CURDIR)/scripts

VIVADO := vivado
VIVADO_BATCH := $(VIVADO) -mode batch -nolog -nojournal -source
VIVADO_GUI := $(VIVADO) -mode gui -nolog -nojournal

.PHONY: all
all: project

# Create Vivado project
.PHONY: project
project:
	@echo "Creating Vivado project..."
	$(VIVADO_BATCH) $(SCRIPTS_DIR)/create_project.tcl
	@echo "Done! Project created at: $(PROJECT_DIR)/$(PROJECT_NAME).xpr"

# Open project in GUI
.PHONY: open
open:
	@if [ ! -f $(PROJECT_DIR)/$(PROJECT_NAME).xpr ]; then \
		echo "Project not found. Creating..."; \
		$(MAKE) project; \
	fi
	$(VIVADO_GUI) $(PROJECT_DIR)/$(PROJECT_NAME).xpr &

# Clean project directory
.PHONY: clean
clean:
	@echo "Removing project directory..."
	rm -rf $(PROJECT_DIR)
	@echo "Clean complete!"

# Show help
.PHONY: help
help:
	@echo "AXI Master - PYNQ-Z2 Project"
	@echo ""
	@echo "Targets:"
	@echo "  make          - Create Vivado project (default)"
	@echo "  make project  - Create Vivado project"
	@echo "  make open     - Open project in Vivado GUI"
	@echo "  make clean    - Remove project directory"
	@echo "  make help     - Show this help"
