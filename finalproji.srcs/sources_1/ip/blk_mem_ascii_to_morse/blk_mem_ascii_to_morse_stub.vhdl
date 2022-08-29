-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3.1 (win64) Build 2489853 Tue Mar 26 04:20:25 MDT 2019
-- Date        : Wed Aug 17 15:59:54 2022
-- Host        : mecha-3 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               o:/ES32_22X/finalproji/finalproji.srcs/sources_1/ip/blk_mem_ascii_to_morse/blk_mem_ascii_to_morse_stub.vhdl
-- Design      : blk_mem_ascii_to_morse
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tcpg236-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity blk_mem_ascii_to_morse is
  Port ( 
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 7 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 19 downto 0 )
  );

end blk_mem_ascii_to_morse;

architecture stub of blk_mem_ascii_to_morse is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,ena,addra[7:0],douta[19:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_4_2,Vivado 2018.3.1";
begin
end;
