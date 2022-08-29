// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3.1 (win64) Build 2489853 Tue Mar 26 04:20:25 MDT 2019
// Date        : Wed Aug 17 15:59:54 2022
// Host        : mecha-3 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               o:/ES32_22X/finalproji/finalproji.srcs/sources_1/ip/blk_mem_ascii_to_morse/blk_mem_ascii_to_morse_stub.v
// Design      : blk_mem_ascii_to_morse
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3.1" *)
module blk_mem_ascii_to_morse(clka, ena, addra, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,addra[7:0],douta[19:0]" */;
  input clka;
  input ena;
  input [7:0]addra;
  output [19:0]douta;
endmodule
