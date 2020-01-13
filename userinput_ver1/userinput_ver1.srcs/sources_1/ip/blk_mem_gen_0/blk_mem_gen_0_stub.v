// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2.2 (win64) Build 2348494 Mon Oct  1 18:25:44 MDT 2018
// Date        : Sun May 26 13:27:19 2019
// Host        : DESKTOP-NLIN2T4 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               t:/engs31/finalproject/userinput_ver1/userinput_ver1.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_stub.v
// Design      : blk_mem_gen_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_1,Vivado 2018.2.2" *)
module blk_mem_gen_0(clka, ena, wea, addra, dina, clkb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[10:0],dina[1:0],clkb,addrb[10:0],doutb[1:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [10:0]addra;
  input [1:0]dina;
  input clkb;
  input [10:0]addrb;
  output [1:0]doutb;
endmodule
