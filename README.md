# Full-Cycle RTL Design and SystemVerilog Verification of a Buffered UART Core

A complete, production-grade silicon macro development project featuring a fully synthesized Universal Asynchronous Receiver-Transmitter (UART) core integrated with dual internal FIFO buffers, alongside a robust, object-oriented SystemVerilog constrained-random verification environment. This project demonstrates a comprehensive execution of the entire digital ASIC design cycle—from structural RTL microarchitecture to advanced boundary verification.

---

## I. Overview
This repository contains a full-cycle, hardware-validated **UART Core** and its accompanying layered **Verification Intellectual Property (VIP)** environment. 

The hardware architecture partitions the UART protocol into independent, synchronized transmit (`TX_TOP`) and receive (`RX_TOP`) pipelines, each backed by a dedicated synchronous FIFO memory buffer to prevent system data loss. The verification environment utilizes an Object-Oriented Programming (OOP) framework in SystemVerilog, deploying modular components (Generator, Driver, Monitor, and Scoreboard) connected via virtual interfaces. 

By taking this macro from RTL microarchitecture down to comprehensive multi-scenario regression sign-off, the project ensures perfect synchronization, reliable clock-domain division, and absolute protocol compliance.

---

## II. Project Objectives

### RTL Design Objectives
* **Modular Microarchitectural Design:** Implement a clean, synthesizable Verilog core dividing the UART protocol into a programmable Baud Generator, an independent TX Serializer state machine, and an RX Deserializer state machine.
* **Elastic Buffer Integration:** Incorporate dual-port internal FIFO architectures (`TX_FIFO` and `RX_FIFO`) to decouple the fast master processor clock domain (`UCLK`) from the slow, physical bit-rate clock (`BCLK`).
* **Robust Hardware Error Masking:** Design internal safety-gating logic to handle protocol anomalies—such as illegal read requests—without corrupting the core's Finite State Machines (FSMs).

### Functional Verification Objectives
* **Layered Testbench Architecture:** Build an expandable, reusable verification environment utilizing mailboxes, custom transaction classes, and virtual hardware interfaces to cleanly decouple generation intent from physical wire handshakes.
* **Corner-Case Stress Testing:** Verify absolute boundary stability under extreme environmental conditions, including full FIFO queue saturation (overflow stress) and zero-packet read requests (underflow masking).
* **Automated Regression Management:** Deploy a self-clearing verification engine capable of executing distinct stimulus profiles sequentially, dynamically flushing scoreboard and driver metrics between iterations to prevent cross-test residue contamination.

---

## III. Key Features

### Hardware Architecture (Design)
* **Divided Clock Domain Synchronization:** A dedicated internal Baud Generator maps the system clock (`UCLK`) down to a precise sampling rate (`BCLK`) to ensure perfect alignment with industry-standard baud targets.
* **Buffered Core Data Alignment:** Depth-16 synchronous FIFO integration guarantees data payload retention, eliminating data loss during back-to-back hardware bursts.
* **Loopback Capable Physical Layer:** Fully self-contained single-wire serial transmission (`tx_rx`) designed for effortless diagnostic loopback and real-world system-level integration.

### Verification Framework (Validation)
* **Constrained-Random Stimulus Execution:** Advanced pattern sequences (including structural `WALKING_ONES` and maximum-bound `SINGLE_BIT_SET` injections) ensure deep structural coverage and eliminate stuck-at wire faults.
* **Hardened Timeline Logging:** Explicit time-unit casting (`#20000ns`) locks the driver's inter-packet line-idle delays securely in place, guaranteeing predictable, repeatable simulation timelines across all EDA tool precisions.
* **Intelligent Scoreboard Checking:** An automated dual-mailbox verification engine that handles both transactional expected-data matching and isolated hardware flag checks dynamically.

## IV. System Architecture

The testbench structure communicates via transaction mailboxes over a virtual hardware interface:
  
# 3 System Design
## 3.1 Block Diagram 
The system consists of modular blocks integrated to form a complete UART communication interface. The high-level architecture includes:
1) UART Transmitter
2) UART Receiver
3) Baud Rate Generator
4) FIFO Buffers
5) Top-level Integration module
## 3.2 Design Parameters 
The UART module is desgined with several configurable parameters to enhance reuseablity and adaptability across various system requirements. The main parameters are as follows:
1) BAUD_RATE= 921600: Defines the baud rate used for data transmission and reception.
2) OVERSAMPLE = 16: Sets the oversampling rate for the receiver to improve sampling accuracy.
3) CLK_FREQ= 100*(10^6): Specifies the system frequency, set to 100 MHz.
4) Final_value=((CLK_FREQ)/(BAUD_RATE*OVERSAMPLE))+0.5: This value represents the divider used to generate the baud rate clock. The addition of 0.5 ensures rounding of the nearest integer.
5) FIFO_WIDTH=8: Sets the width of each data word in the FIFO buffers.
6) FIFO_DEPTH=16: Determines the number of entries in both TX AND RX FIFOs.
7) max_fifo_addr=$clog2(FIFO_DEPTH): Automatically calculates the address qidth needed to index the FIFO.
