onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib myFifo_opt

do {wave.do}

view wave
view structure
view signals

do {myFifo.udo}

run -all

quit -force
