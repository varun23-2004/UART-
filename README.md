# UART Core: RTL Design & Verification IP Framework

A comprehensive, production-grade silicon IP package featuring a custom-designed Universal Asynchronous Receiver-Transmitter (UART) hardware core integrated with a modular, Object-Oriented SystemVerilog verification suite. This repository demonstrates end-to-end ASIC/SoC frontend engineering development—spanning hardware microarchitecture design, FIFO buffer implementation, structural testbench development, and a targeted multi-scenario regression flow.

---

## I. Overview
This project represents a complete, self-contained silicon IP development cycle encompassing both the **RTL Design** and **Functional Verification** of an asynchronous serial communication (UART) macro. 

The hardware architecture features independent Transmit (TX) and Receive (RX) pipelines, dedicated internal buffering via synchronous FIFO memories, and an configurable integer clock divider for high-accuracy baud rate generation. 

The accompanying verification environment is built from the ground up using an **Object-Oriented SystemVerilog** architecture. By decoupling execution handshakes (Driver/Monitor) from evaluation checkers (Scoreboard), the testbench provides an automated, self-clearing verification loop that executes a suite of targeted boundary and protocol stress scenarios without requiring manual waveform debugging.

---

## II. Project Objectives
* **End-to-End Core Synthesis Preparation:** Architect a clean, synthesizable Verilog RTL description of a UART macro containing fully decoupled, independent TX/RX engines.
* **Deterministic Boundary Validation:** Formulate targeted functional testing sequences to validate hardware behavior at physical boundary conditions, specifically ensuring robust data handling during buffer saturation (FIFO Overflow) and illegal access attempts (FIFO Underflow).
* **Protocol & Phase Compliance:** Enforce strict adherence to standard UART framing constraints (Start, Data, and Stop bit sequencing) and verify reliable Receiver FSM wake-up characteristics following microsecond-scale line inactivity.
* **Automated Regression Management:** Implement a self-contained testbench stepping engine capable of purging transaction mailboxes, initializing hardware resets, and cycling through distinct test scenarios seamlessly in a single compilation sweep.

---

## III. Project Features

### RTL Hardware Design Features
* **Decoupled Tx/Rx Topologies:** Independent `TX_TOP` and `RX_TOP` hardware blocks allowing full-duplex, simultaneous data transmission and reception without cross-domain interference.
* **Synchronous FIFO Memory Buffering:** Integrated high-speed FIFO queues utilizing master system clock (`UCLK`) synchronization to buffer data streams and prevent data dropping during CPU handshake delays.
* **Hardware-Level Underflow Protection:** Built-in output safety masking that automatically forces the parallel data bus (`R_data`) to a clean `8'h00` state if an illegal read strobe is asserted while the receive queue is completely empty.
* **Integrated Baud Generator Engine:** A dedicated clock division macro that translates the high-frequency master system clock (`UCLK`) into highly precise internal baud ticks (`BCLK`) to govern serial shift registers.

### Verification IP Framework Features
* **Modular OOP Architecture:** Clean segregation of verification tasks into distinct structural classes including a targeted Generator, a pin-driving Driver, an independent wire-sniffing Monitor, and a processing Scoreboard.
* **Targeted Regression Suite:** A deterministic test array running 8 precise, specialized verification sequences—ranging from standard `HAPPY_PATH` and data patterns (`WALKING_ONES`) to zero-delay throughput bursts (`IMMEDIATE_START_BURST`).
* **Deterministic Timing Hardening:** Rigid timeline synchronization utilizing explicit time units (`#20000ns;`) within the driver loop, ensuring predictable inter-packet line delays regardless of varying simulator tool default precisions (ps vs. ns).
* **Self-Purging Metric Gating:** Dynamic mailbox and internal tracking resets executed between sequential tests, preventing residual data pollution and enabling true automated regression sign-off.

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
