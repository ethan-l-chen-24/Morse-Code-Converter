----------------------------------------------------------------------------------
-- Company: Ethan Chen and Chlorine Hammy Gilberto
-- Project: ENGS 31 Final Project - Morse Code Converter
-- Professor: Ben Dobbins

-- File: UART Hardware Tester

-- While running in hardware, pair this file with uart
----------------------------------------------------------------------------------

-- library declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

library UNISIM;					-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;

entity uart is
    Port ( Clk : in  STD_LOGIC;					-- 100 MHz board clock
           RsRx  : in  STD_LOGIC;				-- Rx input
		   RsTx  : out  STD_LOGIC;				-- Tx output
           
           -- Testing ports
           -- clk10_p : out std_logic;				-- 10 MHz clock
           -- RsRx_p : out std_logic;				-- serial data stream
		   -- rx_shift_p : out std_logic;			-- Rx register shift           
		   -- rx_done_tick_p : OUT  std_logic );	-- data ready
		 
		   -- validation in hardware ports 
		   seg_ext_port	      : out std_logic_vector(0 to 6);		-- segment control
	       dp_ext_port			  : out std_logic;						-- decimal point control
	       an_ext_port			  : out std_logic_vector(3 downto 0));  -- digit control

end uart;


architecture Structural of uart is

-- Signals for the 100 MHz to 10 MHz clock divider
constant CLOCK_DIVIDER_VALUE: integer := 5;
signal clkdiv: integer := 0;			-- the clock divider counter
signal clk_en: std_logic := '0';		-- terminal count
signal clk10: std_logic;				-- 10 MHz clock signal

-- Other signals
signal rx_data : std_logic_vector(7 downto 0);
signal rx_done_tick : std_logic;

-- Component declarations
COMPONENT SerialRx
	Generic( 
        BAUD_RATE : integer;
        CLOCK_FREQUENCY : integer;
        TX_BITS : integer);
    Port( Clk : IN std_logic;
        RsRx : IN std_logic;   
        -- rx_shift : out std_logic;		-- for testing      
        rx_data :  out std_logic_vector(7 downto 0);
        rx_done_tick : out std_logic );
END COMPONENT;

component SerialTx is
    Generic ( 
        CLOCK_FREQUENCY : integer;
        BAUD_RATE : integer );
    Port ( Clk : in  STD_LOGIC;
           tx_data : in  STD_LOGIC_VECTOR (7 downto 0);
           tx_start : in  STD_LOGIC;
           tx : out  STD_LOGIC;					    -- to RS-232 interface
           tx_done_tick : out  STD_LOGIC);
end component;

component mux7seg
    Port ( clk_port 	: in  std_logic;						-- runs on a fast (1 MHz or so) clock
	       y3_port 	    : in  std_logic_vector (3 downto 0);	-- digits
		   y2_port 	    : in  std_logic_vector (3 downto 0);	-- digits
		   y1_port 	    : in  std_logic_vector (3 downto 0);	-- digits
           y0_port 	    : in  std_logic_vector (3 downto 0);	-- digits
           dp_set_port  : in  std_logic_vector(3 downto 0);     -- decimal points
		   
           seg_port 	: out  std_logic_vector(0 to 6);		-- segments (a...g)
           dp_port 	    : out  std_logic;						-- decimal point
           an_port 	    : out  std_logic_vector (3 downto 0) );	-- anodes
end component;

-------------------------
	
begin

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

------------------------------



Receiver: SerialRx GENERIC MAP(
    BAUD_RATE => 9600,
        CLOCK_FREQUENCY => 10000000,
        TX_BITS => 10 )
     PORT MAP(
		Clk => clk10,				-- receiver is clocked with 10 MHz clock
		RsRx => RsRx,
		-- rx_shift => open,		-- testing port
		rx_data => rx_data,
		rx_done_tick => rx_done_tick );
		
Transmitter: SerialTx GENERIC MAP(
    CLOCK_FREQUENCY => 10000000,
    BAUD_RATE => 9600 )
PORT MAP (
   Clk => clk10,
   tx_data => rx_data,
   tx_start => rx_done_tick,
   tx => RsTx,					    -- to RS-232 interface
   tx_done_tick => open);


sevenSeg: Mux7Seg PORT MAP(
   clk_port 	=> clk10,
   y3_port 	    => rx_data(7 downto 4),
   y2_port 	    => rx_data(3 downto 0),
   y1_port 	    => "0000",
   y0_port 	    => "0000",
   dp_set_port  => "0000",
 
   seg_port 	=> seg_ext_port,
   dp_port 	    => dp_ext_port,
   an_port 	    => an_ext_port );
		
end Structural;

