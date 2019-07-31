// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
// Date        : Mon Jul 29 03:57:41 2019
// Host        : qingchuan-ma-laptop running 64-bit Ubuntu 18.04.2 LTS
// Command     : write_verilog -force -mode synth_stub
//               /media/qingchuan-ma/MQC_SSD/warehouse/Vivado/paper_io/paper_io.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_stub.v
// Design      : blk_mem_gen_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_3,Vivado 2019.1" *)
module blk_mem_gen_0(clka, ena, wea, addra, dina, douta, clkb, enb, web, addrb, 
  dinb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[17:0],dina[5:0],douta[5:0],clkb,enb,web[0:0],addrb[17:0],dinb[5:0],doutb[5:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [17:0]addra;
  input [5:0]dina;
  output [5:0]douta;
  input clkb;
  input enb;
  input [0:0]web;
  input [17:0]addrb;
  input [5:0]dinb;
  output [5:0]doutb;
endmodule