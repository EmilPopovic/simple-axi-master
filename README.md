# Simple AXI Master for PYNQ-Z2

A reference design for a general purpose AXI4-Full Master IP written in SystemVerilog for FPGA designs using the PYNQ-Z2 board. Supports single-beat read/write transactions to PS memory and peripherals with interrupt-style done signaling. Includes a Jupyter notebook which shows memory and device transactions.

<img width="300" alt="ip" src="https://github.com/user-attachments/assets/2e1b8d81-a0c6-4134-aecb-e2e141a9f21f" />


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

## Overview

### Block Design

A reference block design is included. It uses the AXI Master to communicate with PS memory, RGB LEDs and switches. PS is acting as the host, connected to the host bus through an AXI Interconnect (`gpio_interconnect`, top right) and five AXI GPIO modules (`gpio_addr`, `gpio_wdata`, `gpio_rdata`, `gpio_ctrl`, `gpio_latency`, right)

<img width="2972" height="1572" alt="image" src="https://github.com/user-attachments/assets/9e41dd67-3aef-4183-bb90-11e02fa59f2f" />

### Demo

The PS controls the IP using a driver (`software/axi/driver.py`) written in Python. A Jupyter notebook (`software/demo.ipynb`) provides a GUI for interacting with a small buffer and devices.

<img width="400" alt="ui_mem" src="https://github.com/user-attachments/assets/355e1de3-48d9-4eb6-bd61-b7f8842d92da" />
<img width="400" alt="ui_dev" src="https://github.com/user-attachments/assets/fd1f7cbb-57d2-4793-8e85-f24269b4fc32" />


