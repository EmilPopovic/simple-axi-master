# Simple AXI Master for PYNQ-Z2

A general purpose 64-bit AXI4 master module for FPGA designs using PYNQ-Z2. Supports single-beat read/write transactions to PS memory and peripherals with interrupt-style done signaling.

## Features

- Single-beat AXI4 transactions (read/write)
- Done signal raised on completion (interrupt-ready)
- Error detection (AXI response codes and unaligned addresses)
- PYNQ-Z2 demo with PS DDR access
- Python library for ARM control
