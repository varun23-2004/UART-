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
* **Deterministic Timing Hardening:** Rigid timeline synchronization utilizing explicit time units (`#5000ns;`) within the driver loop, ensuring predictable inter-packet line delays regardless of varying simulator tool default precisions (ps vs. ns).
* **Self-Purging Metric Gating:** Dynamic mailbox and internal tracking resets executed between sequential tests, preventing residual data pollution and enabling true automated regression sign-off.

## IV. System Architecture

### 1. UART Design Under Test (DUT) Internals

### 2. Testbench Environment Top Block
![UART Verification VIP Architecture](uart_architecture.png)

## V. Verification and Simulation
The test suite consists of 8 comprehensive regression scenarios verified sequentially:Test #ScenarioIntent / DescriptionEvaluation Target1HAPPY_PATHBaseline legal write and read cycles under standard conditions.102FIFO_OVERFLOWStream 20 bytes into a Depth-16 FIFO to test hardware saturation boundaries.163FIFO_UNDERFLOWInject artificial read request onto empty FIFO; verifies safety masking to 8'h00.24WALKING_ONESShift a active '1' bit through all 8 data bus positions to ensure no stuck-at pin faults.85SINGLE_BIT_SETBoundary pattern testing focusing exclusively on absolute maximum/minimum bounds (8'h01, 8'h80).26CONSECUTIVE_BYTESRapid back-to-back sequential processing of constant values to monitor FSM reset timing.67IMMEDIATE_START_BURSTZero-latency burst streaming to maximize data throughput and catch clock domain race conditions.58LONG_IDLE_TESTInject a massive 20,000ns inter-packet silence window to confirm receiver wake-up reliability.
