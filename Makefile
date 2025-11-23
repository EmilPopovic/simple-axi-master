# Makefile for AXI Master Vivado Project
# PYNQ-Z2 Target

PROJECT_NAME := axi-master
PROJECT_DIR := $(CURDIR)/$(PROJECT_NAME)
SCRIPTS_DIR := $(CURDIR)/scripts
OVERLAY_DIR := $(CURDIR)/overlay

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

# Export block designs to TCL
.PHONY: export-bd
export-bd:
	@if [ ! -f $(PROJECT_DIR)/$(PROJECT_NAME).xpr ]; then \
		echo "ERROR: Project not found. Run 'make project' first."; \
		exit 1; \
	fi
	@echo "Exporting block designs to TCL..."
	$(VIVADO_BATCH) $(SCRIPTS_DIR)/export_bd.tcl

# Generate Bitstream and Deploy to overlay/
.PHONY: bitstream
bitstream:
	@if [ ! -f $(PROJECT_DIR)/$(PROJECT_NAME).xpr ]; then \
		echo "ERROR: Project not found. Run 'make project' first."; \
		exit 1; \
	fi
	@echo "Building Bitstream (this may take a while)..."
	$(VIVADO_BATCH) $(SCRIPTS_DIR)/build_bitstream.tcl
	
	@echo "Deploying artifacts to $(OVERLAY_DIR)..."
	@mkdir -p $(OVERLAY_DIR)
	
	@find $(PROJECT_DIR)/$(PROJECT_NAME).runs/impl_1 -name "*.bit" -exec cp {} $(OVERLAY_DIR)/demo.bit \;
	
	@find $(PROJECT_DIR) -name "*.hwh" -exec cp {} $(OVERLAY_DIR)/demo.hwh \;
	
	@if [ ! -f $(OVERLAY_DIR)/demo.hwh ]; then \
		echo "WARNING: .hwh not found directly. Extracting from XSA..."; \
		if [ -f $(CURDIR)/$(PROJECT_NAME).xsa ]; then \
			unzip -p $(CURDIR)/$(PROJECT_NAME).xsa *hw_handoff/*.hwh > $(OVERLAY_DIR)/demo.hwh || \
			unzip -p $(CURDIR)/$(PROJECT_NAME).xsa *.hwh > $(OVERLAY_DIR)/demo.hwh; \
			echo "Extracted HWH from XSA."; \
		else \
			echo "ERROR: Could not find .hwh or .xsa file!"; \
			exit 1; \
		fi \
	fi

	@echo "Build Complete! Files are ready in $(OVERLAY_DIR)"

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
	@echo "Cleaning generated block design files..."
	@find bd/ -type f -not -name '*.tcl' -delete 2>/dev/null || true
	@find bd/ -type d -empty -delete 2>/dev/null || true
	@echo "Clean complete!"

# Show help
.PHONY: help
help:
	@echo "AXI Master - PYNQ-Z2 Project"
	@echo ""
	@echo "Targets:"
	@echo "  make           - Create Vivado project (default)"
	@echo "  make project   - Create Vivado project"
	@echo "  make export-bd - Export block designs to TCL"
	@echo "  make open      - Open project in Vivado GUI"
	@echo "  make clean     - Remove project directory"
	@echo "  make bitstream - Build bitstream and copy to overlay/"
	@echo "  make help      - Show this help"
