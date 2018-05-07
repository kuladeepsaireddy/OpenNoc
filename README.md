# OpenNoc

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


