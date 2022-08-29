----------------------------------------------------------------------------------
-- Students: Ethan Chen and Chlorine Hammy Gilberto
-- Project: ENGS 31 Final Project - Morse Code Converter
-- Professor: Ben Dobbins

-- File: Sine Wave Gen TB
----------------------------------------------------------------------------------

-- library declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

------------------------
-- EMPTY ENTITY
------------------------
entity sine_wave_generator_tb is
end sine_wave_generator_tb;


------------------------------
-- ARCHITECTURE
------------------------------
architecture testbench of sine_wave_generator_tb is

-- component declarations

component sine_wave_generator is
    Generic(
        CLK_FREQ : integer;
        NUM_POINTS : integer := 32;
        MAX_AMPLITUDE : integer := 255;
        FREQUENCY : integer := 261 );
    Port(
        clk_port : in std_logic;
        audio_en_port : in std_logic;
        sine_out_port : out std_logic_vector(7 downto 0) );
end component;

-- signals
    signal audio_en : std_logic := '0';
    signal sine_out_on_scope : std_logic_vector(7 downto 0);

     -- adding clock signal
    signal clk_external : std_logic := '0'; 
    constant ext_clk_period : time := 100ns;

begin

-- port map
dut: sine_wave_generator generic map(
    CLK_FREQ => 10000000,
    NUM_POINTS => 32,
    MAX_AMPLITUDE => 255,
    FREQUENCY => 523
)
port map(
    clk_port => clk_external,
    audio_en_port => audio_en,
    sine_out_port => sine_out_on_scope
);

-- clk generation process 
clkgen_proc: process 
begin 
    clk_external <= not(clk_external); 
    wait for ext_clk_period/2; 
end process clkgen_proc; 

-- test
stimulus_proc: process
begin
    wait for ext_clk_period*20; -- leave out at 0
    
    audio_en <= '1'; -- generate sine wave
    wait;
    
end process;


end testbench;
