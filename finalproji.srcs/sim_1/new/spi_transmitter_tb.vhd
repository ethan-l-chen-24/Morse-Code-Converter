----------------------------------------------------------------------------------
-- Students: Ethan Chen and Chlorine Hammy Gilberto
-- Project: ENGS 31 Final Project - Morse Code Converter
-- Professor: Ben Dobbins

-- File: Spi Transmitter Testbench
----------------------------------------------------------------------------------

-- library declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--------------------------
-- EMPTY ENTITY
--------------------------
entity spi_transmitter_tb is
end spi_transmitter_tb;


---------------------------
-- ARCHITECTURE
---------------------------
architecture Behavioral of spi_transmitter_tb is

-- components

component spi_transmitter is
    Generic(
        TICK_COUNT : integer );
    Port(
        clk_port : in std_logic;
        en_port : in std_logic;
        data_in_port : in std_logic_vector(11 downto 0);
        
        cs_port : out std_logic;
        data_out_port : out std_logic );
end component;

-- signals
    signal audio_en : std_logic := '0';
    signal data_in : std_logic_vector(11 downto 0) := (others => '0');
    signal cs_on_scope : std_logic := '0';
    signal data_out_on_scope : std_logic := '0';

 -- adding clock signal
    signal clk_external : std_logic := '0'; 
    constant ext_clk_period : time := 100ns;

begin

-- port maps

dut: spi_transmitter generic map(
    TICK_COUNT => 5 ) 
port map (
    clk_port => clk_external,
    en_port => audio_en,
    data_in_port => data_in,
    cs_port => cs_on_scope,
    data_out_port => data_out_on_scope );

-- clk generation process 
clkgen_proc: process 
begin 
    clk_external <= not(clk_external); 
    wait for ext_clk_period/2; 
end process clkgen_proc;

-- tests
stimulus_proc: process
begin
    
    -- start
    wait for ext_clk_period*3;

    -- assert data and enable
    data_in <= "010110110110";
    audio_en <= '1';
    wait for ext_clk_period * 19;
    
    -- assert different data
    data_in <= "000000000111";
    wait for ext_clk_period * 20;
    
    -- disable
    audio_en <= '0';

    wait;
    
end process; 


end Behavioral;
