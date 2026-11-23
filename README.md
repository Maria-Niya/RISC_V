# RISC-V Processor

[![Language](https://img.shields.io/badge/Language-SystemVerilog-blue)](#)
[![Architecture](https://img.shields.io/badge/Architecture-RISC--V%20RV32I-red)](#)
[![Tool](https://img.shields.io/badge/Tool-Xilinx%20Vivado-red)](https://www.xilinx.com/products/design-tools/vivado.html)
[![Status](https://img.shields.io/badge/Status-In%20Progress-yellow)](#)

**A modular SystemVerilog implementation of a single-cycle RV32I processor.**

This repository contains a 32-bit RISC-V core built from separate instruction fetch, decode, execute, and writeback stages, connected by a single-cycle top-level module. Instruction and data memories are external to the core.

> This is an active development repository. The top-level core is integrated, but a test bench and test programs are not yet included, so the design has not been verified in simulation.

## Current Features

- 32-bit RV32I single-cycle core (`single_cycle_riscv`)
- Separate instruction fetch, decode, execute, and writeback stages
- 32-entry register file with register `x0` hardwired to zero
- Main control decoding for R-type, I-type, load/store, branch, jump, LUI, and AUIPC instructions
- ALU control for arithmetic, logical, shift, comparison, and branch operations
- Immediate generation for I, S, B, J, LUI, and AUIPC formats
- PC incrementing and branch/jump target selection
- Memory read/write control signals and memory-to-register selection
- Writeback multiplexing for ALU results, memory data, jumps, LUI, and AUIPC
- `stall` input that holds the PC and blocks register writes
- Active-high asynchronous reset (PC resets to `0x8000_0000`)
- Xilinx Vivado-compatible SystemVerilog sources

## Architecture Overview

```text
                 +-----------------------------------------+
                 |            single_cycle_riscv           |
                 |                                         |
  instruction -->|  IF --> ID --> EX --> WB                |--> address (PC)
                 |   ^                    |                |--> alu_out (data address)
                 |   |  branch/jump       |  wb_data       |--> rs2_data (store data)
                 |   +--- target ---------+  -> ID         |--> mem_write / mem_read
  mem_out ------>|                       (register write)  |--> fn3 / opcode
                 +-----------------------------------------+
```

- **IF** holds the PC and selects `PC + 4` or the branch/jump target from EX.
- **ID** decodes the instruction, reads the register file, and generates the immediate and control signals. It also writes `wb_data` back to the register file.
- **EX** runs the ALU, evaluates branches, and computes the branch/jump target (`pc_ex_out`).
- **WB** selects the value written to the register file: ALU result, memory data, return address (`PC + 4`), LUI immediate, or AUIPC result.

The memory stage is the external data memory: the core drives the address, store data, and control signals, and `mem_out` goes straight to the writeback stage.

## Top-Level Interface

```systemverilog
module single_cycle_riscv (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic [31:0] instruction,
    input  logic [31:0] mem_out,
    output logic [31:0] rs2_data,
    output logic [31:0] alu_out,
    output logic        mem_write,
    output logic        mem_read,
    output logic [2:0]  fn3,
    output logic [6:0]  opcode,
    output logic [31:0] address
);
```

| Port | Direction | Description |
| --- | --- | --- |
| `clk` | in | Clock |
| `reset` | in | Asynchronous, active-high reset |
| `stall` | in | Holds the PC and blocks register writes |
| `instruction` | in | Instruction from instruction memory, addressed by `address` |
| `mem_out` | in | Data from data memory |
| `rs2_data` | out | Store data |
| `alu_out` | out | Data memory address |
| `mem_write` | out | Data memory write enable |
| `mem_read` | out | Data memory read enable |
| `fn3` | out | Load/store width |
| `opcode` | out | Current instruction opcode |
| `address` | out | Program counter |

### Memory Requirements

- **Instruction memory:** addressed by `address` (byte address). The PC resets to `0x8000_0000`, so the memory must be mapped there or the base address removed.
- **Data memory:** addressed by `alu_out`, written with `rs2_data`. The memory must use `fn3` to handle byte, halfword, and word access, and `mem_out` must already be sign- or zero-extended for LB, LH, LBU, and LHU.
- Reads are expected to be combinational so the core completes an instruction in one cycle.

## Module Hierarchy

| Module | Responsibility |
| --- | --- |
| [`single_cycle_riscv.sv`](single_cycle_riscv.sv) | Top level: connects the IF, ID, EX, and WB stages |
| [`if_stage.sv`](if_stage.sv) | Maintains the PC and selects sequential or branch/jump targets |
| [`id_stage.sv`](id_stage.sv) | Decodes instructions and coordinates register/control/immediate logic |
| [`ex_stage.sv`](ex_stage.sv) | Performs ALU operations and target-address calculations |
| [`wb_stage.sv`](wb_stage.sv) | Selects ALU, memory, jump return-address, or upper-immediate data for writeback |
| [`decoder.sv`](decoder.sv) | Extracts register fields, opcodes, function fields, and immediate fields |
| [`main_control.sv`](main_control.sv) | Generates datapath and memory-control signals |
| [`alu_control.sv`](alu_control.sv) | Selects the ALU operation |
| [`alu.sv`](alu.sv) | Implements arithmetic, logical, shift, and comparison operations |
| [`register_file.sv`](register_file.sv) | Provides 32 general-purpose registers |
| [`imm_generator.sv`](imm_generator.sv) | Generates sign-extended or zero-extended immediate values |
| [`adder.sv`](adder.sv) | Implements 32-bit addition |
| [`mux2.sv`](mux2.sv) | Provides parameterized 2-to-1 datapath selection |
| [`flopr.sv`](flopr.sv) | Implements a parameterized resettable register |
| [`flopenr.sv`](flopenr.sv) | Implements a parameterized register with enable and reset |
| [`extend.sv`](extend.sv) | Alternative immediate sign-extension module (not used by the core) |

## Instruction Support

The core supports RV32I except FENCE, ECALL, EBREAK, and CSR instructions.

- **R-type:** register-to-register arithmetic and logical operations
- **I-type:** immediate arithmetic, shifts, and comparisons
- **Loads:** LB, LH, LW, LBU, LHU (width selected by `fn3`)
- **Stores:** SB, SH, SW (width selected by `fn3`)
- **Branches:** BEQ, BNE, BLT, BGE, BLTU, and BGEU
- **Jumps:** JAL and JALR
- **Upper immediate:** LUI and AUIPC

Implemented ALU operations include:

| Operation | Examples |
| --- | --- |
| Arithmetic | ADD, SUB |
| Logical | AND, OR, XOR |
| Shift | SLL, SRL, SRA |
| Comparison | SLT, SLTU |
| Branch | Equal, not equal, signed/unsigned less-than and greater-than/equal |

## Repository Layout

```text
RISC_V/
|-- single_cycle_riscv.sv  # Top-level single-cycle core
|-- if_stage.sv            # Program counter and instruction-fetch stage
|-- id_stage.sv            # Decode stage integration
|-- ex_stage.sv            # Execute stage integration
|-- wb_stage.sv            # Memory/ALU/upper-immediate writeback selection
|-- decoder.sv             # Instruction field decoding
|-- main_control.sv        # Main instruction control
|-- alu_control.sv         # ALU operation decoding
|-- alu.sv                 # 32-bit ALU
|-- register_file.sv       # 32-register file
|-- imm_generator.sv       # Immediate construction
|-- rnr-stage.yaml         # Module dependency manifest
`-- supporting modules     # Multiplexer, adder, resettable registers, and extension logic
```

## Author

Developed and maintained by [Maria Niya](https://github.com/Maria-Niya).
