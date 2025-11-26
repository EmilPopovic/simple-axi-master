# Simple AXI Master for PYNQ-Z2

A reference design for a general purpose AXI4-Full Master IP written in SystemVerilog for FPGA designs using the PYNQ-Z2 board. Supports single-beat read/write transactions to PS memory and peripherals with interrupt-style done signaling.

## Features

* **Custom AXI4 Master IP:** Written in SystemVerilog, supporting configurable width and single-beat unaligned transfers.
* **Python Driver:** A high-level `pynq` driver class to control the hardware.
* **Interactive Demo:** Jupyter Notebook UI for reading/writing memory, status monitoring, and hex dumps.
* **Robust Build System:** `make` and `tcl` based workflow for reproducible Vivado builds and bitstream generation.

## Directory Structure

* `rtl/` - SystemVerilog source code for the AXI Master and wrapper.
* `sim/` - Testbenches for verification.
* `bd/` - Vivado Block Design sources (Tcl export).
* `scripts/` - Tcl scripts for project creation, building, and exporting.
* `software/` - Python drivers and Jupyter Notebooks.
* `overlay/` - Generated bitstream (`.bit`) and hardware handoff (`.hwh`) files.

## Getting Started

### Prerequisites

* Xilinx Vivado 2022.2 (or compatible)
* PYNQ-Z2 Board with PYNQ image v3.0+
* VS Code (Recommended for development)

### Quick Start (On Board)

1. Clone this repository to `/home/xilinx/jupyter-notebooks/simple-axi-master`.
2. Navigate to `software/` in Jupyter Lab.
3. Open `demo.ipynb` and run all cells.
4. Use the UI to write data to DDR and read it back via the FPGA.
