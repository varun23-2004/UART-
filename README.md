
# 1. UART:
UART is one of the most widely used serial communication protocols in embedded systems and digital design. It facilitates async communication between devices using two lines: Trasmitter (TX) and Receiver (RX). Unlike sync protocols UART dose'nt require shared clock between sender and receiver making it ideal for low-speed, short distance data exchange.

## 1.1. Project Objectives:
The objective of this project is to design a complete UART module in Verilog,
consisting of Transmitter and Receiver units, FIFO buffers for data handling and a baud rate generator for controlling data transmission speed. The design aims to be synthesizable, parameterrized and ready for FPGA implementation. 

## II. Project Objectives
* **Functional Verification:** Validate error-free parallel-to-serial and serial-to-parallel data transitions across standard operating conditions.
* **Boundary Stress Validation:** Prove robust design handling under intense data streaming conditions (FIFO overflow) and illegal read conditions (FIFO underflow).
* **Protocol Compliance:** Confirm strict adherence to the UART framing specification, including precise start/stop bit transitions and extended period bus-settling times.
* **Clean Automation:** Implement a structured regression manager capable of flushing state metrics and switching stimulus profiles dynamically without hanging the simulator.
  
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
