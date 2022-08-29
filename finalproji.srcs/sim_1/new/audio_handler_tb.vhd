----------------------------------------------------------------------------------
-- Students: Ethan Chen and Chlorine Hammy Gilberto
-- Project: ENGS 31 Final Project - Morse Code Converter
-- Professor: Ben Dobbins

-- File: Audio Handler Testbench
----------------------------------------------------------------------------------

-- library declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- testbench - empty entity
entity audio_handler_tb is
end audio_handler_tb;

-------------------
-- ARCHITECTURE
-------------------

architecture testbench of audio_handler_tb is

-- Components

component audio_handler is
    Generic(
        COUNT_MAX : integer);
    Port(   
        
        -- inputs to controller
        clk_port : in std_logic;
        play_port : in std_logic;
        
        -- outputs of controller
        audio_done_port : out std_logic;
        
        -- inputs to datapath
        code_in_port : in std_logic_vector(19 downto 0);
        bitcount_port : in std_logic_vector(4 downto 0);
        
        -- outputs of datapath
        audio_out : out std_logic ); 
        
end component;

-- signals

    -- Clk generation (10 MHz)
    signal clk_external : std_logic := '0'; 
    constant ext_clk_period : time := 100ns;
    
    -- wires
    signal play : std_logic := '0';
    signal code_in : std_logic_vector(19 downto 0) := (others => '0');
    signal bitcount_in : std_logic_vector(4 downto 0) := (others => '0');
    signal audio_done_on_scope : std_logic;
    signal audio_out_on_scope : std_logic;

begin

-- Port maps

dut: audio_handler generic map(
        COUNT_MAX => 15 )
    port map(
        clk_port => clk_external,
        play_port => play,
        audio_done_port => audio_done_on_scope,
        code_in_port => code_in,
        bitcount_port => bitcount_in,
        audio_out => audio_out_on_scope
    );
    
-- clk generation process 
clkgen_proc: process 
begin 
    clk_external <= not(clk_external); 
    wait for ext_clk_period/2; 
end process clkgen_proc; 

-- stimulus process 
stimulus_proc: process
begin
    -- Start and set signal values
    code_in <= "01011010101111111111"; -- 10 bit code with filler 1s at end - should output "0101101010"
    bitcount_in <= "01010"; -- 10 bits
    wait for ext_clk_period * 3;
    
    -- Assert play high to move to load 
    play <= '1';
    wait for ext_clk_period * 1;
    play <= '0';
    
    wait;
    
end process stimulus_proc; 

end testbench;