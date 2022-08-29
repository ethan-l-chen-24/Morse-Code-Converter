----------------------------------------------------------------------------------
-- Students: Ethan Chen and Chlorine Hammy Gilberto
-- Project: ENGS 31 Final Project - Morse Code Converter
-- Professor: Ben Dobbins

-- File: Top Level Debug File (7 Seg)

-- While running in hardware, pair this file with top_level_debug_constraints
----------------------------------------------------------------------------------

-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;

--------------------
-- ENTITY
--------------------
entity final_project_top_level_debug is
    Port (
        clk_ext_port: in std_logic; 
        rsrx_ext_port: in std_logic; 
        audio_ext_port: out std_logic;
        
        seg_ext_port: out std_logic_vector(0 to 6);
        dp_ext_port: out std_logic;
        an_ext_port: out std_logic_vector(3 downto 0)
        );
end final_project_top_level_debug;


-------------------------
-- ARCHITECTURE
-------------------------
architecture Behavioral of final_project_top_level_debug is

-- components

component system_clock_generator is
    generic (CLOCK_DIVIDER_RATIO : integer);
	port (
        input_clk_port		: in std_logic;
        system_clk_port	    : out std_logic;
		fwd_clk_port		: out std_logic);
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

-- signal declarations 

    signal system_clk : std_logic := '0';
    signal data : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_done : std_logic := '0';
    
    signal empty : std_logic := '0';
    signal audio_done : std_logic := '0';
    signal dequeue : std_logic := '0';
    signal cvt_morse : std_logic := '0';
    signal load_morse : std_logic := '0';
    signal play : std_logic := '0';
    
    signal ascii : std_logic_vector(7 downto 0) := (others => '0');
    signal morse_code : std_logic_vector(19 downto 0) := (others => '0');
    signal bit_count : std_logic_vector(4 downto 0) := (others => '0');
    
    signal enter : std_logic := '0';
    signal enqueue : std_logic := '0';
    signal pop : std_logic := '0';
    signal data_unsigned: unsigned(7 downto 0); 
    
begin

-- port mapping s==

clocking: system_clock_generator generic map(
    CLOCK_DIVIDER_RATIO => 100 )
port map(
    input_clk_port => clk_ext_port, 
    system_clk_port => system_clk,
    fwd_clk_port => open );
    
sevenSeg: Mux7Seg PORT MAP(
   clk_port 	=> system_clk,
   y3_port 	    => data(7 downto 4),
   y2_port 	    => data(3 downto 0),
   y1_port 	    => "0000",
   y0_port 	    => "0000",
   dp_set_port  => "0000",
 
   seg_port 	=> seg_ext_port,
   dp_port 	    => dp_ext_port,
   an_port 	    => an_ext_port );
    
 -- serialRx 
 uart: SerialRx generic map(
     BAUD_RATE => 9600,
     CLOCK_FREQUENCY => 1000000,
     TX_BITS => 10 )
 port map(
     clk => system_clk,
     RsRx => rsrx_ext_port,
     rx_data => data,
     rx_done_tick => rx_done );
 
controller: morse_controller generic map(
    COUNT_MAX => 500000 )
port map( 
    clk_port => system_clk,
    enter_port => enter, -- GLUE
    empty_port => empty, 
    audio_done_port => audio_done,
    
    dequeue_port => dequeue,
    cvt_morse_port => cvt_morse,
    load_morse_port => load_morse, 
    play_port => play );


datapath: morse_datapath port map(
    clk_port => system_clk,
    ascii_in_port => ascii, 
    cvt_morse_port => cvt_morse,
    load_morse_port => load_morse, 
    morse_code_port => morse_code, 
    bit_count_port => bit_count );

ah: audio_handler generic map(
    COUNT_MAX => 250000 )
port map(
    clk_port => system_clk,
    play_port => play, 
    audio_done_port => audio_done, 
    code_in_port => morse_code,
    bitcount_port => bit_count, 
    audio_out =>  audio_ext_port );

char_queue: queue generic map(
    NReg => 16 )
port map(
    clk_port => system_clk,
    in_port => data,
    enqueue_port => enqueue, -- GLUE
    dequeue_port => dequeue, 
    pop_port => pop, -- GLUE
    out_port => ascii,
    empty_port => empty,
    full_port => open  );
    
-- Glue Logic
data_unsigned <= unsigned(data); 

-- enqueue gets high if rx_done and ascii sent is a character, space, or number
process(data_unsigned, rx_done)
begin
    if rx_done = '1' then
        if data_unsigned > 96 then 
            if data_unsigned < 123 then
            
                enqueue <= '1';
            else
                enqueue <= '0';
            end if;
        elsif data_unsigned > 47 then 
            if data_unsigned < 58 then 
                enqueue <= '1'; 
            else
                enqueue <= '0';
            end if;  
        elsif data_unsigned = 32 then 
            enqueue <= '1';
        else 
            enqueue <= '0';
        end if; 
    else
        enqueue <= '0';
    end if; 
                


end process;

-- enter gets high if the ascii sent is the enter key
process(data_unsigned, rx_done)
begin
    if rx_done = '1' then
        if data_unsigned = 13 then 
            enter <= '1'; 
        else 
            enter <='0'; 
        end if;
    else
        enter <= '0';
    end if;
end process;

-- backspace gets high if the ascii sent is the backspace key
backspacePress: process(data_unsigned, rx_done)
begin
    if rx_done = '1' then -- only for a single keypress
        if data_unsigned = 127 then -- return key
            pop <= '1'; 
        else 
            pop <='0'; 
        end if;
    else
        pop <= '0';
    end if;
end process;

end Behavioral;
