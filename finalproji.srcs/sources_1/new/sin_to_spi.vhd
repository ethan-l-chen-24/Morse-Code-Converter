----------------------------------------------------------------------------------
-- Students: Ethan Chen and Chlorine Hammy Gilberto
-- Project: ENGS 31 Final Project - Morse Code Converter
-- Professor: Ben Dobbins

-- File: Sine to SPI tester

-- While running in hardware, pair this file with sin_to_spi_constraints
----------------------------------------------------------------------------------

-- library declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;					-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;

-------------------------
-- ENTITY
-------------------------

entity sin_to_spi is
  Port(
    clk_port : in std_logic;
  
    play_ext_port : in std_logic;
    
    cs_ext_port : out std_logic;
    data_ext_port : out std_logic;
    sclk_ext_port : out std_logic
   );
end sin_to_spi;

--------------------------
-- ARCHITECTURE
--------------------------

architecture Behavioral of sin_to_spi is

component system_clock_generator is
    generic (CLOCK_DIVIDER_RATIO : integer);
	port (
        input_clk_port		: in std_logic;
        system_clk_port	    : out std_logic;
		fwd_clk_port		: out std_logic);
end component;

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

component spi_transmitter is
    Generic(
        TICK_COUNT : integer );
    Port(
        clk_port : in std_logic;
        data_in_port : in std_logic_vector(11 downto 0);
        
        cs_port : out std_logic;
        data_out_port : out std_logic );
end component;

component button_interface
    Port( clk_port            : in  std_logic;
		  button_port         : in  std_logic;
		  button_db_port      : out std_logic;
		  button_mp_port      : out std_logic);	
end component;

-- signals for wiring
signal clk10 : std_logic := '0';
signal sine : std_logic_vector(7 downto 0);
signal data_in : std_logic_vector(11 downto 0);
signal play_db : std_logic := '0';

begin
data_in <= "0000" & sine;

-- port maps

clocking: system_clock_generator generic map(
    CLOCK_DIVIDER_RATIO => 10 )
port map(
    input_clk_port => clk_port, 
    system_clk_port => clk10,
    fwd_clk_port => sclk_ext_port );

sine_wave_gen: sine_wave_generator generic map(
    CLK_FREQ => 10000000,
    NUM_POINTS => 32,
    MAX_AMPLITUDE => 255,
    FREQUENCY => 261
)
port map(
    clk_port => clk10,
    audio_en_port => play_db,
    sine_out_port => sine
);

transmitter: spi_transmitter generic map(
        TICK_COUNT => 1000 )
    port map(
        clk_port => clk10,
        data_in_port => data_in,
        
        cs_port => cs_ext_port,
        data_out_port => data_ext_port );
        
debouncer: button_interface PORT MAP(
    clk_port => clk10,
    button_port => play_ext_port,
    button_db_port => play_db,
    button_mp_port => open
);



end Behavioral;
