# Architecture & Design

## 1. Module Overview: `simple_axi_master`

The core is a custom AXI4 Master logic block that translates simple high-level commands into AXI4 read/write transactions.

### Interface

| Signal Group | Direction | Description |
| :--- | :--- | :--- |
| `i_rw` | Input | Command Trigger: `00`=Idle, `01`=Write, `10`=Read. |
| `i_addr` | Input | Target Physical Address (32-bit). |
| `i_size` | Input | Transfer Size: `0`=Byte, `1`=Half, `2`=Word, `3`=DWord. |
| `i_wdata` | Input | Data to write (64-bit). |
| `o_rdata` | Output | Data read from memory (64-bit). |
| `o_profile_latency` | Output | Cycle count of the last completed transaction. |
| `m_axi_*` | I/O | Standard AXI4-Full Master Interface. |

### FSM Design

The module uses a structured Finite State Machine (FSM) to ensure protocol compliance:

1. **IDLE:** Waits for `i_rw` command.
2. **SET_ADDR:** Asserts `AxVALID` with stable address/control signals.
3. **ADDR_WAIT:** Waits for `AxREADY`.
4. **DATA_LAST:** Transfers data (asserts `WVALID`/`RREADY`).
5. **RET:** Handshakes response (`BVALID`/`RVALID`).

## 2. Integration: `simple_axi_master_wrapper`

A Verilog wrapper that exposes the SystemVerilog module to Vivado IP Integrator and can be added to a Block Design.

* **Padding:** Pads 32-bit inputs to 64-bit internal logic.
* **Static Signals:** Drives required AXI sideband signals (`AxBURST`, `AxCACHE`, `AxPROT`) to valid defaults (`INCR`, `Bufferable`, `Secure`).
* **Interface Definition:** Contains strict `X_INTERFACE_INFO` attributes to allow Vivado to infer the AXI bus automatically.

## 3. System Integration (Block Design)

The project instantiates the master in a Zynq subsystem:

* **Control Path:** Zynq PS $\to$ AXI GPIO $\to$ Master Control Signals.
* **Data Path:** Master `m_axi` $\to$ AXI Interconnect $\to$ Zynq HP0 Slave Port $\to$ DDR Memory.
* **Reset:** GPIO-controlled soft reset for the PL logic to recover from deadlocks without rebooting the CPU.
