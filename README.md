# RISC-V Processor

[![Language](https://img.shields.io/badge/Language-SystemVerilog-blue)](#)
[![Architecture](https://img.shields.io/badge/Architecture-RISC--V%20RV32-red)](#)
[![Tool](https://img.shields.io/badge/Tool-Xilinx%20Vivado-red)](https://www.xilinx.com/products/design-tools/vivado.html)
[![Status](https://img.shields.io/badge/Status-In%20Progress-yellow)](#)

**A modular SystemVerilog implementation of the RISC-V instruction pipeline.**

This repository contains the building blocks of a 32-bit RISC-V processor and is currently organized around instruction fetch, decode, execute, memory/writeback, and control stages. The implementation uses parameterized RTL modules, control decoding, register-file access, immediate generation, arithmetic operations, branch evaluation, PC control, memory operations, and writeback selection.

> This is an active development repository. A complete processor top-level and a comprehensive test suite may not yet be included.

## Current Features

- 32-bit RV32-style datapath modules
- Separate instruction fetch, decode, execute, and writeback stages
- 32-entry register file with register `x0` hardwired to zero
- Main control decoding for R-type, I-type, load/store, branch, jump, LUI, and AUIPC instructions
- ALU control for arithmetic, logical, shift, comparison, and branch operations
- Immediate generation for I, S, B, J, LUI, and AUIPC formats
- PC incrementing and branch/jump target selection
- Memory read/write control and memory-to-register selection
- Writeback multiplexing for ALU results, memory data, jumps, LUI, and AUIPC
- Active-high asynchronous reset
- Xilinx Vivado-compatible SystemVerilog sources

## Architecture Overview

```text
32-bit Instruction
        |
        v
+----------------+
|  IF Stage      |  PC update, PC + 4, branch target selection
+----------------+
        |
        v
+----------------+
|  ID Stage      |  Instruction decode, register file, control, immediate
+----------------+
        |
        v
+----------------+
|  EX Stage      |  ALU operations, branch evaluation, target calculation
+----------------+
        |
        v
|  Memory       |  Load/store control and memory data interface
+----------------+
        |
        v
|  WB Stage     |  Select data for the register file
+----------------+
```

The module hierarchy is:

| Module | Responsibility |
| --- | --- |
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
| [`extend.sv`](extend.sv) | Alternative immediate sign-extension module |

## Instruction Support

The control and decode modules contain paths for the following RISC-V instruction families:

- **R-type:** register-to-register arithmetic and logical operations
- **I-type:** immediate arithmetic, shifts, and comparisons
- **Loads:** base-plus-offset loads
- **Stores:** base-plus-offset stores
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

The exact supported instruction subset depends on which source modules are integrated and should be expanded and validated through a complete test program.

## Getting Started

### Vivado Simulation

1. Clone the repository:
   ```bash
   git clone https://github.com/Maria-Niya/RISC_V.git
   cd RISC_V
   ```

2. Create a new RTL project in Xilinx Vivado.
3. Add the required SystemVerilog source files.
4. Use [`rnr-stage.yaml`](rnr-stage.yaml) as a module dependency reference:
   - The `if_stage` module requires `adder.sv`, `mux2.sv`, and `if_stage.sv`.
   - The `id_stage` module requires decoder, immediate-generator, register-file, control, and stage sources.
   - The `ex_stage` module requires adder, multiplexer, ALU, ALU-control, and stage sources.
   - The `wb_stage` module requires memory data, ALU data, return addresses, immediate data, and writeback-control inputs.
5. Add a test bench and set the desired top-level module.
6. Run behavioral simulation and inspect results in the Vivado waveform viewer.

### Icarus Verilog Example

The stage modules can be checked with Icarus Verilog by compiling the required dependency set. For example:

```bash
iverilog -g2012 \
  adder.sv mux2.sv alu.sv alu_control.sv ex_stage.sv \
  -o ex_stage_sim
```

The same compilation pattern is used for the fetch and decode stages, but a test bench must be supplied to instantiate a module and generate stimulus.
The writeback stage can be compiled independently with `wb_stage.sv`.

## Repository Layout

```text
RISC_V/
|-- if_stage.sv         # Program counter and instruction-fetch stage
|-- id_stage.sv         # Decode stage integration
|-- ex_stage.sv         # Execute stage integration
|-- wb_stage.sv         # Memory/ALU/upper-immediate writeback selection
|-- decoder.sv          # Instruction field decoding
|-- main_control.sv     # Main instruction control
|-- alu_control.sv      # ALU operation decoding
|-- alu.sv              # 32-bit ALU
|-- register_file.sv    # 32-register file
|-- imm_generator.sv    # Immediate construction
|-- rnr-stage.yaml      # Stage module dependency manifest
`-- supporting modules  # Multiplexer, adder, resettable registers, and extension logic
```

## Development Roadmap

- Integrate a complete processor top-level module
- Add or integrate the instruction/data memory implementation
- Verify memory and writeback behavior with directed test benches
- Add a reusable program loader and test instruction programs
- Create directed SystemVerilog test benches
- Expand verification to instruction-set compliance and edge cases
- Add synthesis constraints and optional FPGA demo support


## Author

Developed and maintained by [Maria Niya](https://github.com/Maria-Niya).
