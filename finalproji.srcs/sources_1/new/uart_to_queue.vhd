----------------------------------------------------------------------------------
-- Students: Ethan Chen and Chlorine Hammy Gilberto
-- Project: ENGS 31 Final Project - Morse Code Converter
-- Professor: Ben Dobbins

-- File: UART to Queue Hardware Tester

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
entity uart_to_queue is
    Port ( 
        Clk : in std_logic;
        RsRx : in std_logic;
        
        dequeue : in std_logic;
        pop : in std_logic;
        full_ext_port : out std_logic;
        empty_ext_port : out std_logic;
        
        seg_ext_port : out std_logic_vector(0 to 6);
        dp_ext_port : out std_logic;
        an_ext_port : out std_logic_vector(3 downto 0)
        );
end uart_to_queue;


------------------------
-- ARCHITECTURE
------------------------
architecture Behavioral of uart_to_queue is

-- Components

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
        empty_port : out std_logic;
        full_port : out std_logic);
end component;

component SerialRx is
    Generic( 
        BAUD_RATE : integer;
        CLOCK_FREQUENCY : integer;
        TX_BITS : integer);
    Port( Clk : IN std_logic;
        RsRx : IN std_logic;   
        -- rx_shift : out std_logic;		-- for testing      
        rx_data :  out std_logic_vector(7 downto 0);
        rx_done_tick : out std_logic );
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
signal rx_data : std_logic_vector(7 downto 0);
signal rx_done_tick : std_logic;
signal queue_out: std_logic_vector(7 downto 0) := (others => '0');
signal dequeue_mp: std_logic;
signal pop_mp: std_logic;

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

receiver: SerialRx generic map(
        BAUD_RATE => 9600,
        CLOCK_FREQUENCY => 10000000,
        TX_BITS => 10 )
    port map(
        Clk => clk10,
        RsRx => RsRx,
        rx_data => rx_data,
        rx_done_tick => rx_done_tick );
        
charQueue: Queue generic map(
        Nreg => 16 )
    port map(
        clk_port => clk10,
        in_port => rx_data,
        enqueue_port => rx_done_tick,
        dequeue_port => dequeue_mp,
        pop_port => pop_mp,
        out_port => queue_out,
        empty_port => empty_ext_port, 
        full_port => full_ext_port);
    
sevenSeg: Mux7Seg PORT MAP(
   clk_port 	=> clk10,
   y3_port 	    => queue_out(7 downto 4),
   y2_port 	    => queue_out(3 downto 0),
   y1_port 	    => "0000",
   y0_port 	    => "0000",
   dp_set_port  => "0000",
 
   seg_port 	=> seg_ext_port,
   dp_port 	    => dp_ext_port,
   an_port 	    => an_ext_port );
   
dequeue_monopulser: button_interface PORT MAP(
    clk_port => clk10,
    button_port => dequeue,
    button_db_port => open,
    button_mp_port => dequeue_mp
);

pop_monopulser: button_interface PORT MAP(
    clk_port => clk10,
    button_port => pop,
    button_db_port => open,
    button_mp_port => pop_mp
);
    

end Behavioral;
