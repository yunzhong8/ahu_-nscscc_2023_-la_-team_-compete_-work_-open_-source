// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
// Date        : Sat Aug  5 14:17:17 2023
// Host        : SY running 64-bit Ubuntu 22.04.2 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/ip/pht_ram/pht_ram_stub.v
// Design      : pht_ram
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2019.2" *)
module pht_ram(clka, ena, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[9:0],dina[1:0],clkb,enb,addrb[9:0],doutb[1:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [9:0]addra;
  input [1:0]dina;
  input clkb;
  input enb;
  input [9:0]addrb;
  output [1:0]doutb;
endmodule
