----------------------------------------------------------------------------------
-- Students: Ethan Chen and Chlorine Hammy Gilberto
-- Project: ENGS 31 Final Project - Morse Code Converter
-- Professor: Ben Dobbins

-- File: Audio Handler Hardware Tester

-- While running in hardware, pair this file with uart_to_queue_constraints
----------------------------------------------------------------------------------

-- library declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;					-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;


----------------------
-- ENTITY
----------------------
entity audio_handler_hardware is
    Port ( 
        Clk : in std_logic;
        sw_ext_port : in std_logic_vector(15 downto 0);
        
        play_ext_port : in std_logic;
        light_ext_port : out std_logic;
        audio_done_ext_port : out std_logic
        );
end audio_handler_hardware;


------------------------
-- ARCHITECTURE
------------------------
architecture Behavioral of audio_handler_hardware is

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

component button_interface
    Port( clk_port            : in  std_logic;
		  button_port         : in  std_logic;
		  button_db_port      : out std_logic;
		  button_mp_port      : out std_logic);	
end component;

-- Signals for the 100 MHz to 10 MHz clock divider
constant CLOCK_DIVIDER_VALUE: integer := 5;
signal clkdiv: integer := 0;			-- the clock divider counter
signal clk_en: std_logic := '0';		-- terminal count
signal clk10: std_logic;				-- 10 MHz clock signal

-- Other signals
signal play_mp : std_logic := '0';
signal input : std_logic_vector(19 downto 0) := sw_ext_port & "0000";

begin

-- clock

-- Clock buffer for 10 MHz clock
-- The BUFG component puts the slow clock onto the FPGA clocking network
Slow_clock_buffer: BUFG
      port map (I => clk_en,
                O => clk10 );

-- Divide the 100 MHz clock down to 20 MHz, then toggling the 
-- clk_en signal at 20 MHz gives a 10 MHz clock with 50% duty cycle
Clock_divider: process(clk)
begin
	if rising_edge(clk) then
	   	if clkdiv = CLOCK_DIVIDER_VALUE-1 then 
	   		clk_en <= NOT(clk_en);		
			clkdiv <= 0;
		else
			clkdiv <= clkdiv + 1;
		end if;
	end if;
end process Clock_divider;


-- Port Maps

ah: audio_handler GENERIC MAP(
    COUNT_MAX => 10000000 )
PORT MAP(
    clk_port => clk10,
    play_port => play_mp,
    
    -- outputs of controller
    audio_done_port => audio_done_ext_port,
    
    -- inputs to datapath
    code_in_port => input,
    bitcount_port => "10000",
    
    -- outputs of datapath
    audio_out => light_ext_port
    ); 
   
monopulser: button_interface PORT MAP(
    clk_port => clk10,
    button_port => play_ext_port,
    button_db_port => open,
    button_mp_port => play_mp
);
    

end Behavioral;