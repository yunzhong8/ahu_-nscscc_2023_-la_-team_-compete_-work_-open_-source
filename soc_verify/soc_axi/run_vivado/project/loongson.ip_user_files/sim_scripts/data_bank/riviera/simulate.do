onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+data_bank -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.data_bank xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {data_bank.udo}

run -all

endsim

quit -force
