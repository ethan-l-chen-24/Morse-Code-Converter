----------------------------------------------------------------------------------
-- Students: Ethan Chen and Chlorine Hammy Gilberto
-- Project: ENGS 31 Final Project - Morse Code Converter
-- Professor: Ben Dobbins

-- File: Queue TB
----------------------------------------------------------------------------------

-- Library declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.math_real.ALL;

-- Empty Entity Declaration (self contained) 
entity queue_tb is
end queue_tb; 

architecture testbench of queue_tb is

-- Component declaration
component queue is
    Generic(
        Nreg: integer );
    Port(
        clk_port : in std_logic;
        in_port : in std_logic_vector(7 downto 0);
        enqueue_port : in std_logic;
        dequeue_port : in std_logic;
        pop_port : in std_logic;
        out_port : out std_logic_vector(7 downto 0);
        empty_port : out std_logic);
end component; 

    -- Signal Declarations
    signal data_in : std_logic_vector(7 downto 0) := (others => '0');
    signal enqueue : std_logic := '0';
    signal dequeue : std_logic := '0';
    signal pop : std_logic := '0';
    signal out_on_scope : std_logic_vector(7 downto 0) := (others => '0');
    signal empty_on_scope : std_logic := '0';

    -- adding clock signal
    signal clk_external : std_logic := '0'; 
    constant ext_clk_period : time := 100ns;

-- dut 
begin
dut: queue generic map (
        Nreg => 16 )
    port map (
        clk_port => clk_external, 
        in_port => data_in,
        enqueue_port => enqueue,
        dequeue_port => dequeue,
        pop_port => pop,
        out_port => out_on_scope,
        empty_port => empty_on_scope );


-- clk generation process 
clkgen_proc: process 
begin 
    clk_external <= not(clk_external); 
    wait for ext_clk_period/2; 
end process clkgen_proc; 

-- stimulus process 
stimulus_proc: process
begin
    -- start data
    wait for ext_clk_period*3;
    data_in <= "00000000";

    -- enqueue
    wait for ext_clk_period*3;
    enqueue <= '1';
    wait for ext_clk_period*1;
    enqueue <= '0';
    data_in <= "00000001";
    
    -- enqueue
    wait for ext_clk_period*3;
    enqueue <= '1';
    wait for ext_clk_period*1;
    enqueue <= '0';
    data_in <= "00000010";
    
    -- dequeue
    wait for ext_clk_period*3;
    dequeue <= '1';
    wait for ext_clk_period*1;
    dequeue <= '0';
    
    -- enqueue
    wait for ext_clk_period*3;
    enqueue <= '1';
    wait for ext_clk_period*1;
    enqueue <= '0';
    data_in <= "00000011";
    
    -- dequeue
    wait for ext_clk_period*3;
    dequeue <= '1';
    wait for ext_clk_period*1;
    dequeue <= '0';
    
    -- enqueue until full + 1
    wait for ext_clk_period*3;
    enqueue <= '1';
    wait for ext_clk_period*1;
    data_in <= "00000100";
    wait for ext_clk_period*1;
    data_in <= "00000101";
    wait for ext_clk_period*1;
    data_in <= "00000110";
    wait for ext_clk_period*1;
    data_in <= "00000111";
    wait for ext_clk_period*1;
    data_in <= "00001000";
    wait for ext_clk_period*1;
    data_in <= "00001001";
    wait for ext_clk_period*1;
    data_in <= "00001010";
    wait for ext_clk_period*1;
    data_in <= "00001011";
    wait for ext_clk_period*1;
    data_in <= "00001100";
    wait for ext_clk_period*1;
    data_in <= "00001101";
    wait for ext_clk_period*1;
    data_in <= "00001110";
    wait for ext_clk_period*1;
    data_in <= "00001111";
    wait for ext_clk_period*1;
    data_in <= "00010000";
    wait for ext_clk_period*1;
    data_in <= "00010001";
    wait for ext_clk_period*1;
    data_in <= "00010010";
    wait for ext_clk_period*1;
    data_in <= "00010011";
    wait for ext_clk_period*1;
    data_in <= "00010100";
    wait for ext_clk_period*1;
    enqueue <= '0';
    
    -- backspace a few
    wait for ext_clk_period*3;
    pop <= '1';
    wait for ext_clk_period*5;
    pop <= '0';
    
    
    -- dequeue until empty
    wait for ext_clk_period*3;
    dequeue <= '1';
    wait for ext_clk_period*17;
    dequeue <= '0';
    
    -- end testbench
    wait;

end process stimulus_proc; 

end testbench; 
 
 
