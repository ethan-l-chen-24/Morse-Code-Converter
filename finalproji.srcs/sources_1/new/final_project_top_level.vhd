----------------------------------------------------------------------------------
-- Students: Ethan Chen and Chlorine Hammy Gilberto
-- Project: ENGS 31 Final Project - Morse Code Converter
-- Professor: Ben Dobbins

-- File: Top Level

-- While running in hardware, pair this with top_level_constraints
----------------------------------------------------------------------------------

-- library declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;


----------------------------
-- ENTITY
----------------------------
entity final_project_top_level is
    Port (
        clk_ext_port: in std_logic; 
        rsrx_ext_port: in std_logic; 
        rstx_ext_port: out std_logic;

        audio_ext_port: out std_logic;
        sclk_ext_port: out std_logic;
        cs_ext_port: out std_logic;
        data_ext_port: out std_logic );
end final_project_top_level;


---------------------------------
-- ARCHITECTURE
---------------------------------
architecture Behavioral of final_project_top_level is

----------------------------
-- COMPONENT DECLARATIONS
----------------------------

component system_clock_generator is
    generic (CLOCK_DIVIDER_RATIO : integer);
	port (
        input_clk_port		: in std_logic;
        system_clk_port	    : out std_logic;
		fwd_clk_port		: out std_logic);
end component;

component SerialRx is
    Generic( 
        BAUD_RATE : integer;
        CLOCK_FREQUENCY : integer;
        TX_BITS : integer);
    Port( Clk : IN std_logic;
        RsRx : IN std_logic;        
        rx_data :  out std_logic_vector(7 downto 0);
        rx_done_tick : out std_logic );
end component;

component SerialTx is
    Generic ( 
       CLOCK_FREQUENCY : integer;
       BAUD_RATE : integer );
    Port ( Clk : in  STD_LOGIC;
       tx_data : in  STD_LOGIC_VECTOR (7 downto 0);
       tx_start : in  STD_LOGIC;
       tx : out  STD_LOGIC;					    
       tx_done_tick : out  STD_LOGIC);
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

------------------------
-- SIGNALS
------------------------

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
    signal transmit : std_logic := '0';
    
    signal audio_w : std_logic := '0';
    signal sine_wave : std_logic_vector(7 downto 0) := (others => '0');
    signal data_in : std_logic_vector(11 downto 0);
    
-----------------------
-- CONSTANTS
-----------------------

    constant BAUD_RATE : integer := 9600;
    constant CLOCK_DIVIDER_RATIO : integer := 100;
    constant CLOCK_FREQUENCY : integer := 100000000/CLOCK_DIVIDER_RATIO;
    constant MORSE_UNIT : integer := 250000;
    constant TX_BITS : integer := 10;
    constant FREQUENCY : integer := 261;
    
begin

-------------------------
-- PORT MAPS
-------------------------

clocking: system_clock_generator generic map(
    CLOCK_DIVIDER_RATIO => CLOCK_DIVIDER_RATIO )
port map(
    input_clk_port => clk_ext_port, 
    system_clk_port => system_clk,
    fwd_clk_port => sclk_ext_port );
    

uart_receiver: SerialRx generic map(
     BAUD_RATE => BAUD_RATE,
     CLOCK_FREQUENCY => CLOCK_FREQUENCY,
     TX_BITS => TX_BITS )
port map(
     clk => system_clk,
     RsRx => rsrx_ext_port,
     rx_data => data,
     rx_done_tick => rx_done );
     
uart_transmitter: SerialTx generic map(
    BAUD_RATE => BAUD_RATE,
    CLOCK_FREQUENCY => CLOCK_FREQUENCY )
port map(
   Clk => system_clk,
   tx_data => data,
   tx_start => transmit,
   tx => rstx_ext_port,					   
   tx_done_tick => open);
 
controller: morse_controller generic map(
    COUNT_MAX => 2*MORSE_UNIT )
port map( 
    clk_port => system_clk,
    enter_port => enter, -- GLUE LOGIC BELOW
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
    COUNT_MAX => MORSE_UNIT )
port map(
    clk_port => system_clk,
    play_port => play, 
    audio_done_port => audio_done, 
    code_in_port => morse_code,
    bitcount_port => bit_count, 
    audio_out =>  audio_w );

char_queue: queue generic map(
    NReg => 16 )
port map(
    clk_port => system_clk,
    in_port => data,
    enqueue_port => enqueue, -- GLUE LOGIC BELOW
    dequeue_port => dequeue, 
    pop_port => pop, -- GLUE LOGIC BELOW
    out_port => ascii,
    empty_port => empty,
    full_port => open  );
    
  sine_wave_gen: sine_wave_generator generic map(
    CLK_FREQ => CLOCK_FREQUENCY,
    NUM_POINTS => 32,
    MAX_AMPLITUDE => 255,
    FREQUENCY => FREQUENCY )
port map(
    clk_port => system_clk,
    audio_en_port => audio_w,
    sine_out_port => sine_wave
);

transmitter: spi_transmitter generic map(
    TICK_COUNT => 100 )
port map(
    clk_port => system_clk,
    data_in_port => data_in,
        
    cs_port => cs_ext_port,
    data_out_port => data_ext_port );

----------------------
-- GLUE LOGIC
----------------------

data_unsigned <= unsigned(data); 

-- enqueue gets high if rx_done and ascii sent is a character, space, or number
charPress: process(data_unsigned, rx_done)
begin
    if rx_done = '1' then -- only for a single keypress
        if data_unsigned > 96 then -- if character enqueue
            if data_unsigned < 123 then
                enqueue <= '1';
            else
                enqueue <= '0';
            end if;
        elsif data_unsigned > 47 then -- if number enqueue
            if data_unsigned < 58 then 
                enqueue <= '1'; 
            else
                enqueue <= '0';
            end if;  
        elsif data_unsigned = 32 then -- if a space enqueue
            enqueue <= '1';
        else 
            enqueue <= '0';
        end if; 
    else
        enqueue <= '0';
    end if; 
               
end process;

-- enter gets high if the ascii sent is the enter key
enterPress: process(data_unsigned, rx_done)
begin
    if rx_done = '1' then -- only for a single keypress
        if data_unsigned = 13 then -- return key
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
        if data_unsigned = 127 then -- delete key
            pop <= '1'; 
        else 
            pop <='0'; 
        end if;
    else
        pop <= '0';
    end if;
end process;

-- padding 0s
data_in <= "0000" & sine_wave;
audio_ext_port <= audio_w;
transmit <= (pop OR enqueue);

end Behavioral;
