# OpenNoc

OpenNoc is an open source network on chip implementation enabling quick NoC based application implementation on FPGAs.
It uses deflection based unidirectional torus topology for the NoC implementation.
It is very lite-weight in nature and support high clock performance.
But the throughput offered (packets injected per clock cycle) is much lesser compared to other topologies such as mesh and fully connected.
But running the NoC at high clock frequency, better throughput can be achieved.

In addition to the NoC routing architecture, OpenNoc also supports a packetizer and PCIe-based host machine interface if the design is targeted for Virtex-7 690tffg1761-2 FPGA (the one present in VC709 evaluation board).
It could be also supported on VC707 board by minor modifications to an IP core.

## Prerequisites

The NoC portion can be synthesized or simulated using any FPGA sysnthesis and simulation tools (such as Xilinx ISE, Xilinx Vivado, Intel Quartus, ModelSim, NCSim, ICarus Verilog etc.)
For implementing the packetizer and the host communication IP, users require Xilinx Vivado 2017.3 or above with a valid implementation license.

## Directory structure 

**App**: Two example applications of OpenNoc IP using Xilinx Vivado Tool flow

ImgProcess --> Interfacing OpenNoc with processing elements for image processing

pcieSystem --> Interfacing OpenNoc to a host computer using Dyract IP core

**data**: Directory where the testing image for image processing application is located.
The output after processing is also stored in the same directory

**Imp**: Implementation directory. For implemeting and simulating OpenNoc in non-IP based Vivado and ISE flow

**src**: The source directory. Contains the OpenNoc, Dyract and image processing IP source codes and Vivado IP files. Also test bench files used in the implementation directory.
For more details about Dyract IP core, please refer to [dyract][dyract]

[dyract]: https://github.com/warclab/dyract 

## Getting Started
###1. Simulation
For simulating the functionality of OpenNoc and to evaluate the performance (throughput), test-benches and processing element (PE) models are provided along with OpenNoc RTL source code.
The top test-bench file is located at OpenNoc/src/Verilog/tb/randomTb.v
The following parameters can be modified in the test-bench file for evaluating different configurations

X --> Number of switches/PEs in the X direction

Y --> Number of switches/PEs in the Y direction

data_width --> Data bus width between the switch and the PE. The total bus width will be sum of data bus width and the bits required for address bits. It is calculated automatically

numPackets --> Number of packets used for simulation. This is the number of packets injected by each PE. So the total number of packets injected will be this number multiplied by number of PEs (X*Y)

injectRate --> The rate at which packets are injected. If this value is set to 1, PEs will try to inject one packet on every clock cycle. If this value is 2, they will try to inject 1 packet every two clock cycles and so on.

pattern --> The test pattern. This value decides the destination address used by each PE when injecting packets to the NoC. The supported patterns are RANDOM, SELF, RightNeighbour, TopNeighbour and MixedNeighbour.

The PE model for simulation is OpenNoc/src/Verilog/tb/randomPe.v
The configured number of PEs are instantiated in a single Verilog file called randomPeMesh.v present in the same folder.
Users can see the interfaces coming from individual PEs are merged into a single interface in this module, which makes interfacing PEs with the NoC easier.
The RTL source code (two verilog files) for the NoC is present in the OpenNoc/src/Verilog/VivadoIPs/openNoc/src folder.
All 5 files (2 RTL and 3 testbench) are required for simulation.
If Vivado Simulator is using for simulation, users can use the project file available at OpenNoc/Imp/Vivado2017_3/openNoc project file for simulation where all the required simulation sources are already added.
At the end of simultion, the throughput and efficiency of the NoC is displayed on the TCL console.
The latency for each packet is available inside the Vivado project sim folder in csv format (called receive_log.csv)

###2. Implementation
As discussed before, the two source files for OpenNoC torus is present in the OpenNoc/src/Verilog/VivadoIPs/openNoc/src.
The top RTL file is openNocTop.v
Users can customize the following parameters in this file for obtaining the NoC of their preferred configuration.

X --> Number of switches/PEs in the X direction

Y --> Number of switches/PEs in the Y direction

data_width --> Data bus width between the switch and the PE. The total bus width will be sum of data bus width and the bits required for address bits. It is calculated automatically

x_size --> Number of bits representing x coordinate of PE address in the data packet.
It should be greater than or equal to log2(X).

y_size --> Number of bits representing y coordinate of PE address in the data packet.
It should be greater than or equal to log2(Y).

The switch to PE interface confirms to AXI4 stream interface and user PEs should confirm to this standard.
All the AXI4 stream interfaces from the switches are merged as a single AXI interface in openNocTop.v module.
Following are the interface signals

| Signal        | Direction| Description|
| ------------- |:---------|:------|
| clk           |  I       |AXI4 Stream synchronous clock signal |
| rstn          |  I       |Synchronous active low signal |
| r_valid_pe    |  I       |AXI4 read valid signal. The total width of the bus is X*Y and each signal corresponds to each switch. The index number of the signal corresponds to the switch/PE address |
| r_data_pe     |  I       |AXI4 read data bus. The total width of the bus is X*Y*total_width. Where total_width is x_size+y_size+data_width|
| r_ready_pe    |  O       |AXI4 read ready signal from switches |
| w_valid_pe    |  O       |AXI4 write valid signal from switches |
| w_data_pe     |  O       |AXI4 write data bus|

Note that there is no w_ready_pe. PEs are expected to have enough internal buffering for always accepting data received from switches.

The expected data packet follows the following format

|----------------------|--------------|--------------|  
|________data__________|_y coordinate_|_x coordinate_|  

Once users have developed their own PE, they can interface it with openNocTop module.
For example design please refer to OpenNoc/src/Verilog/tb/randomTb.v and OpenNoc/src/Verilog/tb/randomPeMesh.v files.
Another example RTL PE is available at OpenNoc/src/Verilog/VivadoIPs/Inverter/src/nbyn_pe_2.v and procTop.v files.
The sample PE is used for image processing.
It subtracts each byte in the data field from 256 and sends back the processed pack to PE address zero.
For this application the data field also contains a packet number field, which is preserved.

If using Vivado software suite, OpenNoC is also available as an IP core.
For using the IP in your design, include the directory OpenNoc/src/Verilog/VivadoIPs in the IP repository path.
Then OpenNoC can be directly included in the Vivado Block design flow.
By double clicking the IP core, parameters such as X and Y sizes and data width can be customized.
A full example design using IP based design can be found at OpenNoc/App/Vivado/ImgProcess/ImgProcess.xpr project.
This project can be fully 