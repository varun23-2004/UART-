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
| Test # | Scenario                  | Intent / Description                                                                                                      | Evaluation Target |
| :----: | ------------------------- | ------------------------------------------------------------------------------------------------------------------------- | :---------------: |
|    1   | **HAPPY_PATH**            | Baseline functional verification of legal transmit and receive operations under standard operating conditions.            |         10        |
|    2   | **FIFO_OVERFLOW**         | Stream 20 bytes into a Depth-16 FIFO to verify overflow handling and hardware saturation behavior.                        |         16        |
|    3   | **FIFO_UNDERFLOW**        | Force a read request on an empty FIFO to verify safe underflow handling and default output (`8'h00`).                     |         2         |
|    4   | **WALKING_ONES**          | Shift a single active `1` through all 8 data bus positions to detect stuck-at faults on each data line.                   |         8         |
|    5   | **SINGLE_BIT_SET**        | Verify boundary data patterns by transmitting only the minimum and maximum single-bit values (`8'h01` and `8'h80`).       |         2         |
|    6   | **CONSECUTIVE_BYTES**     | Continuously transmit back-to-back data bytes to verify FSM recovery, buffering, and sequential processing.               |         6         |
|    7   | **IMMEDIATE_START_BURST** | Initiate zero-latency burst transmission to maximize throughput and expose clock-domain or timing race conditions.        |         5         |
|    8   | **LONG_IDLE_TEST**        | Insert a 20,000 ns idle period between packets to verify receiver wake-up and synchronization after prolonged inactivity. |         1         |

