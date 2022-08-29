----------------------------------------------------------------------------------
-- Students: Ethan Chen and Chlorine Hammy Gilberto
-- Project: ENGS 31 Final Project - Morse Code Converter
-- Professor: Ben Dobbins

-- File: Morse Controller and Datapath Testbench
----------------------------------------------------------------------------------

-- library declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- testbench - empty entity
entity morse_tb is
end morse_tb;

-------------------
-- ARCHITECTURE
-------------------

architecture testbench of morse_tb is

-- Components

component morse_controller is
    Generic(
        COUNT_MAX : integer );
    Port (
        --timing:
        clk_port : in std_logic;
        
        --control inputs:
        enter_port : in std_logic;
        empty_port : in std_logic;
        audio_done_port : in std_logic;
        
        --control outputs:
        dequeue_port : out std_logic;
        cvt_morse_port : out std_logic;
        load_morse_port : out std_logic;
        play_port : out std_logic );
        
end component;

component morse_datapath is
    Port( clk_port : in std_logic;
          ascii_in_port : in std_logic_vector(7 downto 0);
          cvt_morse_port : in std_logic;
          load_morse_port : in std_logic;
          morse_code_port : out std_logic_vector(19 downto 0);
          bit_count_port : out std_logic_vector(4 downto 0));
end component;

-- signals

    -- Clk generation (10 MHz)
    signal clk_external : std_logic := '0'; 
    constant ext_clk_period : time := 100ns;
    
    -- wires
    signal enter : std_logic := '0';
    signal empty : std_logic := '0';
    signal audio_done : std_logic := '0';
    signal dequeue_on_scope : std_logic;
    signal cvt_morse_on_scope : std_logic;
    signal load_morse_on_scope : std_logic;
    signal play_on_scope : std_logic;
    
    signal ascii_in : std_logic_vector(7 downto 0) := (others => '0');
    signal morse_code_on_scope : std_logic_vector(19 downto 0);
    signal bit_count_on_scope : std_logic_vector(4 downto 0);

begin

-- Port maps

controller: morse_controller generic map(
        COUNT_MAX => 15 )
    port map(
        clk_port => clk_external,
        enter_port => enter,
        empty_port => empty,
        audio_done_port => audio_done,
        dequeue_port => dequeue_on_scope,
        cvt_morse_port => cvt_morse_on_scope,
        load_morse_port => load_morse_on_scope,
        play_port => play_on_scope
    );
    
datapath: morse_datapath port map(
        clk_port => clk_external,
        ascii_in_port => ascii_in,
        cvt_morse_port => cvt_morse_on_scope,
        load_morse_port => load_morse_on_scope,
        morse_code_port => morse_code_on_scope,
        bit_count_port => bit_count_on_scope
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

    -- start
    wait for ext_clk_period*3;

    -- move to dequeue and back bc empty
    empty <= '1';
    enter <= '1';
    wait for ext_clk_period * 2;
    enter <= '0';
    wait for ext_clk_period * 3;
    
    -- move to dequeue and to convert morse to play because not empty
    empty <= '0';
    enter <= '1';
    wait for ext_clk_period;
    enter <= '0';
    wait for ext_clk_period * 8;
    
    -- assert audio_done to move back to wait and then dequeue, then loop a couple of times
    audio_done <= '1';
    wait for ext_clk_period * 15;
    audio_done <= '0';
    enter <= '0';
    empty <= '1';
    wait for ext_clk_period * 8;
    
    -- NOW TEST DATAPATH
    ascii_in <= "01100011"; -- C in ascii
    empty <= '0';
    enter <= '1';
    wait for ext_clk_period * 5;
    
    wait;
    
    wait;
    
end process stimulus_proc; 

end testbench;
