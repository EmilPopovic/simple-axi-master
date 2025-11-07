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

# Run synthesis
.PHONY: synth
synth: project
	@echo "Running synthesis..."
	$(VIVADO_BATCH) $(SCRIPTS_DIR)/run_synth.tcl
	@echo "Synthesis complete!"

# Run implementation
.PHONY: impl
impl: synth
	@echo "Running implementation..."
	$(VIVADO_BATCH) $(SCRIPTS_DIR)/run_impl.tcl
	@echo "Implementation complete!"

# Generate bitstream
.PHONY: bitstream
bitstream: impl
	@echo "Generating bitstream..."
	$(VIVADO_BATCH) $(SCRIPTS_DIR)/run_bitstream.tcl
	@echo "Bitstream generated!"
	@ls -lh $(BITSTREAM) 2>/dev/null || echo "Bitstream not found"

# Complete build flow
.PHONY: build
build: project
	@echo "Running complete build flow..."
	$(VIVADO_BATCH) $(SCRIPTS_DIR)/build_all.tcl
	@echo "Build complete!"
	@ls -lh $(BITSTREAM) 2>/dev/null || echo "Bitstream not found"

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
	@echo "  make synth      - Run synthesis"
	@echo "  make impl       - Run implementation"
	@echo "  make bitstream  - Generate bitstream"
	@echo "  make build      - Complete build (synth + impl + bitstream)"
