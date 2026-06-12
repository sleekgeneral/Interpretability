# FPGA-Based Local and Global Interpretability Framework for Convolutional Tsetlin Machines

This repository contains the FPGA implementation of a hardware-accelerated interpretability framework for Convolutional Tsetlin Machines (CTMs). The design supports both **local interpretability** and **global interpretability** generation for trained CTM models.

The implementation has been validated using the **MNIST** and **EMNIST** datasets on a Xilinx Zynq UltraScale+ FPGA platform.

---

# Specifications

| Parameter               | Value                   |
| ----------------------- | ----------------------- |
| Number of Clauses       | 152 (Fixed)             |
| Patch Size              | 7 × 7 (Fixed)           |
| Stride                  | 1 (Fixed)               |
| Supported Classes       | 10 (MNIST), 8 (EMNIST)  |
| FPGA Platform           | Zynq UltraScale+ ZCU102 |
| Communication Interface | UART                    |

### Notes

* Patch size is fixed at **7 × 7**.
* Stride is fixed at **1**.
* The design is intended for interpretability generation only.
* Clause and weight configurations are dataset-specific.
* The implementation has been tested on **MNIST** and **EMNIST** datasets.

---

# Repository Structure

## Hardware

The hardware directory contains:

* Verilog source files (`.v`)
* Testbench files
* Clause memory initialization files (`.coe`)
* Weight memory initialization files (`.coe`)
* Vivado project sources

### Hardware Hierarchy

```text
class_top
├── buffer
|── remap_unit
│   ├── addr_gen
│   └── gen_en
└── top
    ├── weight_adder
    ├── conv_arch
    │   ├── conv_enable_generation
    │   ├── convolution
    │   │   └── interpretability
```

---

## Software

The software directory contains:

* Vitis source files (`.c`)
* Utility functions
* Dataset-specific implementations

These files can be used to recreate the software environment within Xilinx Vitis.

---

## MATLAB Scripts

MATLAB scripts are provided for software-side experimentation and result recreation purposes only.

These scripts are not required for FPGA execution and are intended for:

* Data analysis
* Result verification
* Interpretability visualization
* Reproduction of software-generated figures

---

# Local Interpretability

The local interpretability architecture generates input-specific interpretation maps by identifying activated clauses and projecting their corresponding patch literals onto valid image regions.

### Features

* Hardware-accelerated clause evaluation
* Patch-based interpretation generation
* Support for MNIST and EMNIST datasets
* Fixed 7 × 7 patch extraction
* Real-time interpretability generation through FPGA execution

### Execution Flow

1. Load clauses and weights into FPGA memory.
2. Send input images through UART.
3. Perform convolutional clause evaluation.
4. Generate activated clause locations.
5. Project valid patch literals onto image space.
6. Produce local interpretation maps.

---

# Global Interpretability

Global interpretability generation is implemented using a standalone hardware module.

### Files

```text
global.v
```

### Inputs

* Clause memory initialization files (`.coe`)
* Combined weight files (`.coe`)

The same weight storage structure is used for both MNIST and EMNIST models.

### Features

* Dataset-level interpretability generation
* Clause aggregation across classes
* Hardware-based visualization support
* Independent execution from the local interpretability pipeline

### Execution Flow

1. Load clauses from COE files.
2. Load combined weight memories.
3. Execute clause aggregation.
4. Generate class-level interpretability maps.
5. Export results for visualization and analysis.

---

# Getting Started

## Required Tools

The following tools are recommended:

* Xilinx Vivado 2024.1 or later
* Xilinx Vitis 2024.1 or later
* MATLAB (optional, for result recreation and analysis)

---

# Tested Datasets

The implementation has been verified using:

1. MNIST
2. EMNIST

Both datasets were evaluated on the Zynq UltraScale+ ZCU102 FPGA platform.

---

# Reproducing Results

### Hardware

1. Open the Vivado project.
2. Generate the bitstream.
3. Program the FPGA.
4. Load the required COE files.
5. Execute the design.

### Software

1. Open the Vitis project.
2. Build the application.
3. Program the FPGA.
4. Execute the application through UART communication.

### MATLAB

MATLAB scripts may be used to recreate plots, visualizations, and analysis results presented in the associated work.

---

# License

This repository is intended for academic and research purposes. Please refer to the license file for usage and distribution information.

---

# Citation

If this repository contributes to your research, please cite the associated publication describing the FPGA-based local and global interpretability framework for Convolutional Tsetlin Machines.
