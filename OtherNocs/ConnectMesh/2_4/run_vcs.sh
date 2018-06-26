#!/bin/bash
vcs -timescale=1ns/1ps -sverilog *.v +v2k -full64
./simv
