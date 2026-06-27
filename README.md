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

---

## IV. Architectural Deep-Dive

### 1. RTL Hardware Design Blocks
The UART hardware core is written in synthesizable Verilog and uses an asynchronous, decoupled microarchitecture. It consists of three primary custom design blocks:

#### UART Design Under Test
<img width="508" height="429" alt="uart_hardware_block_diagram" src="https://github.com/varun23-2004/UART-/blob/main/Images/UART_ARCHITECTURE.png" />

#### TestBench Environment Top Block 

#### A. Baud Rate Generator
* **Role:** Operates as a precise clock-divider module.
* **Functionality:** It samples the high-frequency master system clock (`UCLK`) and down-divides it to create a lower-frequency baud tick (`BCLK`). This clock pulse matches standard data transmission frequencies (e.g., 9600, 115200 baud) and determines the exact rate at which bits are shifted onto or sampled from the physical wire.

#### B. Transmit Pipeline (TX_TOP)
* **TX_FIFO:** A synchronous FIFO memory block that buffers parallel input data bytes written from the system bus via `W_data[7:0]`. It asserts the `tx_full` status flag to signal the driver to stop writing when its capacity is reached.
* **TX Controller Core:** Fetches parallel data from the FIFO's output port, maps it to a standard UART frame format, and uses an internal shift register clocked by `BCLK` to serialize the bits out onto the physical `tx` pin.

#### C. Receive Pipeline (RX_TOP)
* **RX Controller Core:** Constantly sniffs the physical input `rx` line for a falling edge transition, which marks a valid **Start Bit**. Once detected, it systematically samples the incoming serial bitstream, checks for a valid **Stop Bit**, converts the frames back into a parallel 8-bit byte, and pushes it into the receive queue.
* **RX_FIFO:** A synchronous FIFO queue that temporarily accumulates incoming parallel bytes. It provides the `rx_empty` flag to alert external master blocks that data is available. 
* **Underflow Masking Logic:** Built directly into the FIFO reading data path. If an illegal read strobe (`rd_uart`) is forced while `rx_empty` is active, this hardware safety hook instantly drives the parallel output data lines to `8'h00` to prevent uninitialized memory junk from escaping into the system.

  

---

### 2. Verification Environment Blocks
The Verification IP framework is engineered using an Object-Oriented Programming (OOP) class structure in SystemVerilog. It abstracts signal toggling into separate tasks to verify the hardware without deadlocks.

#### A. Generator (gen)
* **Role:** The test scenario strategist.
* **Functionality:** Contains specialized, isolated procedural loops for each of the 8 unique regression scenarios. It constructs raw transaction objects (`uart_transaction`), populates their inner data properties deterministically based on the active test type, and loads them into the `gen2drv` and `gen2scb` communication mailboxes.

#### B. Driver (drv)
* **Role:** The testbench pin-level actuator.
* **Functionality:** Unpacks transaction objects from the `gen2drv` mailbox and drives the virtual physical pins (`W_data`, `wr_uart`, `rd_uart`) in perfect synchronization with the master clock domain (`UCLK`). It includes custom processing exceptions, such as zero-delay burst streaming blocks and dedicated inter-packet timeline delay logic (`#5000ns;`) to properly isolate the physical `tx_rx` wire into true line-idle states.

#### C. Monitor (mon)
* **Role:** The objective wire observer.
* **Functionality:** Completely passive and decoupled from the driver. It sniffs the active physical lines (`tx_rx`) and control strobes right off the virtual interface. The moment it detects hardware handshake activity, it reconstructs the pin-level signals back into an abstract transaction container and passes it over to the scoreboard via the `mon2scb` mailbox.

#### D. Scoreboard (scb)
* **Role:** The verification validation engine.
* **Functionality:** Features a `forever` loop that pulls actual transactions from the monitor. For normal tests, it cross-checks them against the reference data provided by the generator via the `gen2scb` mailbox. For structural errors like `FIFO_UNDERFLOW` (where the generator remains silent), it bypasses the empty reference queue entirely to directly assess that the hardware output successfully forced its safety-masked default `8'h00` signature. It tracks strict pass/fail totals, flushes its state counters between back-to-back tests, and logs the final verification summaries.


## V. Verification and Simulation
The test suite consists of **8 comprehensive regression scenarios** verified sequentially
| Test # | Scenario                  | Intent / Description                                                                                                      | Evaluation Target |
| :----: | ------------------------- | ------------------------------------------------------------------------------------------------------------------------- | :---------------: |
|    1   | **HAPPY_PATH**            | Baseline functional verification of legal transmit and receive operations under standard operating conditions.            |         10        |
|    2   | **FIFO_OVERFLOW**         | Stream 20 bytes into a Depth-16 FIFO to verify overflow handling and hardware saturation behavior.                        |         16        |
|    3   | **FIFO_UNDERFLOW**        | Force a read request on an empty FIFO to verify safe underflow handling and default output (`8'h00`).                     |         2         |
|    4   | **WALKING_ONES**          | Shift a single active `1` through all 8 data bus positions to detect stuck-at faults on each data line.                   |         8         |
|    5   | **SINGLE_BIT_SET**        | Verify boundary data patterns by transmitting only the minimum and maximum single-bit values (`8'h01` and `8'h80`).       |         2         |
|    6   | **CONSECUTIVE_BYTES**     | Continuously transmit back-to-back data bytes to verify FSM recovery, buffering, and sequential processing.               |         6         |
|    7   | **IMMEDIATE_START_BURST** | Initiate zero-latency burst transmission to maximize throughput and expose clock-domain or timing race conditions.        |         5         |
|    8   | **LONG_IDLE_TEST**        | Insert a 5,000 ns idle period between packets to verify receiver wake-up and synchronization after prolonged inactivity. |         1         |

