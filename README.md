
# 1. UART:
UART is one of the most widely used serial communication protocols in embedded systems and digital design. It facilitates async communication between devices using two lines: Trasmit(TX) and Receive (RX). Unlike sync protocols UART dose'nt require shared clock between sender and receiver making it ideal for low-speed, short distance data exchange.

# 1.1. Project Objectives:
The objective of this project is to design a complete UART module in Verilog,
consisting of Transmitter and Receiver units, FIFO buffers for data handling and a baud rate generator for controlling data transmission speed. The design aims to be synthesizable, parameterrized and ready for FPGA implementation. 

# 2. UART Protocol Overview:
## 2.1 Serial Communication Overview:
Serial communication is a method of transmitting data one bit a time over a single channel. It contrasts with parallel communication, which sends multiple bits simultaneously. Serial communication is more efficient for long distance and low pin count applications. UART is a form of serial communication that is asynchronous, meaning it does not use a shared clock between sender and receiver. Instead, both ends agree on timing parameters beforehand.
## 2.2 UART Protocol Characteristics:
UART communication consits of several standard components:
1) START BIT: Signals the beginning of data transmisson.
2) DATA BITS: Typically 5 to 8 bits representing the actual data
3) PARITY BIT (optional): Used for error checking.
4) STOP BIT(S): Marks the end of the data packet.

Key Characteristics of UART:
1) Asynchronous transmission (no clock line)
2) Full-Duplex communication via separate TX and RX lines.
3) Baud rate agreement required at both ends.
4) Framing and oversampling for reliabe data interpretation. 

## 2.3 UART Baud Rate Generation & Oversampling:
The baud rate in UART defines the number of symbols (bits) transmitted per second. It directly affects the timing of the start, data and stop bits during communication. Since UART is asynchronous both the transmitter and receiver must be configured to use the same baud rate for correct data exchange. 
            $Divisor = \frac{f_{clk}}{\text{Baud rate}}$
This divisor is used in both transmitter and reciever to generate precise timing for sending and sampling bits.

## 2.4 Oversampling and Receiver Synchronization:
Since there is no clock line, the receiver needs a mechanism to synchronize with the transmitter. This is done using oversampling, commonly 16x or 8x. 16x means the receiver samples the RX line 16 times per bit period. When it detects a falling edge (start bit), it waits 8 clock cycles (mid-point of the bit) to sample the value. It continues sampling every 16 clocks to read the rest of the bits.
Oversampling allows:
1) Better noise immunity
2) Center-point sampling for accuracy
3) Recovery from slight clock mismatches.

## 2.5 Baud Rate Error Analysis:
UART modules typically use a system clock to derive the baud rate using a frequency divider. However, since the divisor must be an integer, the actual baud rate may not exactly match the desired one, causing a baud rate error. This discrepancy introduces timing mismatches, especially over long frames and can impact receiver sampling accuracy.
To minimize error:Choose system clock values that align well with common baud rates, allows configurable baud rates to adjust real-world tolerances. Implement receiver oversampling and edge detection to recover from small mismatches.

# System Design
## Block Diagram 
The system consists of modular blocks integrated to form a complete UART communication interface. The high-level architecture includes:
1) UART Transmitter
2) UART Receiver
3) Baud Rate Generator
4) FIFO Buffers
5) Top-level Integration module
## Design Parameters 
The UART module is desgined with several configurable parameters to enhance reuseablity and adaptability across various system requirements. The main parameters are as follows:
1) BAUD_RATE= 921600: Defines the baud rate used for data transmission and reception.
2) OVERSAMPLE = 16: Sets the oversampling rate for the receiver to improve sampling accuracy.
3) CLK_FREQ= 100*(10^6): Specifies the system frequency, set to 100 MHz.
4) Final_value=((CLK_FREQ)/(BAUD_RATE*OVERSAMPLE))+0.5: This value represents the divider used to generate the baud rate clock. The addition of 0.5 ensures rounding of the nearest integer.
5) FIFO_WIDTH=8: Sets the width of each data word in the FIFO buffers.
6) FIFO_DEPTH=16: Determines the number of entries in both TX AND RX FIFOs.
7) max_fifo_addr=$clog2(FIFO_DEPTH): Automatically calculates the address qidth needed to index the FIFO.
