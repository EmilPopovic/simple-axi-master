# Architecture & Design

## 1. Module Overview: `simple_axi_master`

The core is a custom AXI4 Master logic block that translates simple high-level commands into AXI4 read/write transactions.

### Interface

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `WIDTH` | Data width of host and AXI bus in bits. Must be `32` or `64`. | `32` |
| `DEBUG` | `0`=Don't output debug signals, `1`=Output debug signals. | `0` |

| Signal Group | Direction | Description |
| :--- | :--- | :--- |
| `i_rw` | Input | Command Trigger: `00`=Idle, `01`=Write, `10`=Read. |
| `i_addr` | Input | Target Physical Address (32-bit). |
| `i_size` | Input | Transfer Size: `0`=Byte, `1`=Half, `2`=Word, `3`=DWord. |
| `i_wdata` | Input | Data to write (32- or 64-bit). |
| `i_clear` | Input | Clear status and read data. |
| `o_rdata` | Output | Data read from memory (32- or 64-bit). |
| `o_wait` | Output | High while transaction in progress. |
| `o_done` | Output | Signals transaction is done. Goes low if cleared or new transaction started. |
| `o_error` | Output | Transaction failed, data is not valid. |
| `o_invalid` | Output | Invalid address, transaction was rejected. |
| `o_debug_state` | Output | Current state of the internal FSM |
| `o_profile_latency` | Output | Cycle count of the last completed transaction. |
| `m_axi_*` | I/O | Standard AXI4-Full Master Interface. |

**Starting a transaction:**

Asserting a `i_rw` signal starts a transfer immediately, `i_addr` (and `i_wdata` if writing) must be set before or together with `i_rw`. A transfer should only be started if `o_wait` is low, as it will be ignored otherwise.

`i_addr` must be aligned to the requested `i_size`, otherwise the address is invalid, and the transaction will be rejected and `o_invalid` asserted.

**After a completed transaction:**

After a transfer completes, `o_wait` will go low, `o_done` will go high, and error signals (`o_error` and `o_invalid`) will be set accordingly.

In case of a read, data will be present on `o_rdata` until cleared or another read finished. If reading narrow data (i.e. byte, half), it will be present on the `o_rdata` bus rotated to the lowest bits regardless of address alignment.

**Handling errors:**

The master can be in one of the following states based on the status signals:

| Status Status | `o_wait` | `o_done` | `o_error` | `o_invalid` | Description | After `i_clear` |
| :------------ | :------- | :------- | :-------- | :---------- | :---------- | :-------------- |
| **Idle** | `0` | `0` | `0` | `0` | No transfer, status cleared, no data | `Idle` (no action) |
| **Done** | `0` | `1` | `0` | `0` | Transfer completed without error, data valid | `Idle` |
| **Active** | `1` | `0` | `0` | `0` | Transfer is in progress | `Active` (ignored) |
| **Error** | `0` | `1` | `1` | `0` | Slave error | `Idle` |
| **Invalid Address** | `0` | `1` | `1` | `1` | Invalid address requested | `Idle` |

**Clearing status:**

Status is cleared by pulsing `i_clear` for one or more clock cycles. All status bits will be set low, and read data zeroed. A clear command will be ignored if a transaction is in progress. If the AXI Master was in any status state other than `Active`, it will go into `Idle`.

### FSM Design

The module uses a structured Finite State Machine (FSM) to ensure protocol compliance:

1. **IDLE:** Waits for `i_rw` command.
2. **SET_ADDR:** Asserts `AxVALID` with stable address/control signals.
3. **ADDR_WAIT:** Waits for `AxREADY`.
4. **DATA_LAST:** Transfers data (asserts `WVALID`/`RREADY`).
5. **RET:** Handshakes response (`BVALID`/`RVALID`).

## 2. Integration: `simple_axi_master_wrapper`

A Verilog wrapper that exposes the SystemVerilog module to Vivado IP Integrator and can be added to a Block Design.

* **Static Signals:** Drives required AXI sideband signals (`AxBURST`, `AxCACHE`, `AxPROT`) to valid defaults (`INCR`, `Bufferable`, `Secure`).
* **Interface Definition:** Contains strict `X_INTERFACE_INFO` attributes to allow Vivado to infer the AXI bus automatically.

## 3. System Integration (Block Design)

The project instantiates the master in a Zynq subsystem:

* **Control Path:** Zynq PS $\to$ AXI GPIO $\to$ Master Control Signals.
* **Data Path:** Master `m_axi` $\to$ AXI Interconnect $\to$ Zynq HP0 Slave Port $\to$ DDR Memory.
* **Reset:** GPIO-controlled soft reset for the PL logic to recover from deadlocks without rebooting the CPU.
