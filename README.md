# OpenNoc

OpenNoc is an open source network on chip implementation enabling quick NoC based application implementation on FPGAs.
It uses deflection based unidirectional torus topology for the NoC implementation.
It is very lite-weight in nature and support high clock performance.
But the throughput offered (packets injected per clock cycle) is much lesser compared to other topologies such as mesh and fully connected.
But running the NoC at high clock frequency, better throughput can be achieved.

In addition to the NoC routing architecture, OpenNoc also supports a packetizer and PCIe-based host machine interface if the design is targeted for Virtex-7 690tffg1761-2 FPGA (the one present in VC709 evaluation board).
It could be also supported on VC707 board by minor modifications to an IP core.

### Prerequisites

The NoC portion can be synthesized or simulated using any FPGA sysnthesis and simulation tools (such as Xilinx ISE, Xilinx Vivado, Intel Quartus, ModelSim, NCSim, ICarus Verilog etc.)
For implementing the packetizer and the host communication IP, users require Xilinx Vivado 2017.3 or above with a valid implementation license.

### Directory structure 

**App**: Two example applications of OpenNoc IP using Xilinx Vivado Tool flow

ImgProcess --> Interfacing OpenNoc with processing elements for image processing

pcieSystem --> Interfacing OpenNoc to a host computer using Dyract IP core

**data**: Directory where the testing image for image processing application is located.
The output after processing is also stored in the same directory

**Imp**: Implementation directory. For implemeting and simulating OpenNoc in non-IP based Vivado and ISE flow

**src**: The source directory. Contains the OpenNoc, Dyract and image processing IP source codes and Vivado IP files. Also test bench files used in the implementation directory.
For more details about Dyract IP core, please refer to [dyract][dyract]

[dyract]: https://github.com/warclab/dyract 


