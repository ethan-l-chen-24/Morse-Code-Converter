----------------------------------------------------------------------------------
-- Students: Ethan Chen and Chlorine Hammy Gilberto
-- Project: ENGS 31 Final Project - Morse Code Converter
-- Professor: Ben Dobbins

-- File: SPI Transmitter
----------------------------------------------------------------------------------

-- library declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;


-----------------------------
-- ENTITY
-----------------------------
entity spi_transmitter is
    Generic(
        TICK_COUNT : integer ); -- number of ticks between measurements
    Port(
        clk_port : in std_logic;
        data_in_port : in std_logic_vector(11 downto 0);
        
        cs_port : out std_logic;
        data_out_port : out std_logic );
end spi_transmitter;


-----------------------------
-- ARCHITECTURE
-----------------------------
architecture Behavioral of spi_transmitter is

    -- FSM signals
    type statetype is (Hold, Load, Transmit);
    signal curr_state : statetype := Hold;
    signal next_state : statetype;

    -- control signals
    signal pl_load_en : std_logic := '0';
    signal shift_en : std_logic := '0';
    signal hold_count_en : std_logic := '0';

    -- datapath signals
    signal data_in : std_logic_vector(15 downto 0); -- data into shift register
    signal shift_register : std_logic_vector(15 downto 0) := (others => '0');
    signal cs : std_logic := '0';
    
    -- timing signals
    signal hold_count : unsigned(11 downto 0) := (others => '0');
    signal hold_TC : std_logic := '0';
    signal tx_count : unsigned(3 downto 0) := (others => '0');
    signal tx_TC : std_logic := '0';

begin

-------------------------
-- CONTROLLER
-------------------------

-- update the current state
state_update: process(clk_port) 
begin
    if rising_edge(clk_port) then -- update state on rising edge of clock
        curr_state <= next_state;
    end if;
end process;

-- get the next state from curr state and inputs
next_state_logic: process(curr_state, hold_TC, tx_TC)
begin
    next_state <= curr_state; -- default curr state
    
    case curr_state is
        when Hold =>
            if hold_TC = '1' then -- hold between measurements then load
                next_state <= Load;
            end if;
        
        when Load => next_state <= Transmit; -- load and then transmit data
        
        when Transmit =>
            if tx_TC = '1' then -- transmit until done then go back to hold to cycle
                next_state <= Hold;
            end if;
    end case;   
end process;

-- map the current state to outputs
output_logic: process(curr_state)
begin
    case curr_state is
    
        when Hold =>
            pl_load_en <= '0';
            shift_en <= '0';
            hold_count_en <= '1';
            cs <= '1';
        
        when Load =>
            pl_load_en <= '1';
            shift_en <= '0';
            hold_count_en <= '0';
            cs <= '1';
        
        when Transmit =>
            pl_load_en <= '0';
            shift_en <= '1';
            hold_count_en <= '0';
            cs <= '0';
            
    end case;
end process;

------------------------
-- DATAPATH
------------------------

-- left shift register with parallel load and shift enable signals
shift_register_proc: process(clk_port)
begin
    if rising_edge(clk_port) then
        if pl_load_en = '1' then
            shift_register <= data_in; -- parallel load
        elsif shift_en = '1' then
            shift_register <= shift_register(14 downto 0) & '0'; -- shift out
            data_out_port <= shift_register(15); -- store MSB
        end if;
    end if;
end process;

-- one clock cycle delay to CS (to match up with bit transmissions)
cs_proc: process(clk_port)
begin
    if rising_edge(clk_port) then
        cs_port <= cs;
    end if;
end process;

-- appending 0s to front of data in
data_in <= "0000" & data_in_port;

--------------------
-- COUNTERS
--------------------

-- increment hold counter
hold_counter: process(clk_port) 
begin
    if rising_edge(clk_port) then
        if hold_count_en = '1' then
            if hold_count = TICK_COUNT then
                hold_count <= (others => '0');
            else
                hold_count <= hold_count + 1; -- count
            end if;
        else
            hold_count <= (others => '0');
        end if;
    end if;
end process;

-- assert TC high once hold count is met
hold_tick: process(hold_count)
begin
    if hold_count = TICK_COUNT-1 then
        hold_TC <= '1';
    else
        hold_TC <= '0';
    end if;
end process;

-- increment transmission counter
tx_counter: process(clk_port)
begin
    if rising_edge(clk_port) then
        if shift_en = '1' then
            if tx_count = 15 then
                tx_count <= (others => '0');
            else
                tx_count <= tx_count + 1; -- count
            end if;
        else
            tx_count <= (others => '0');
        end if;
    end if;
end process;

-- assert TC high once we have transmitted all bits
tx_tick: process(tx_count)
begin
    if tx_count = 15 then
        tx_TC <= '1';
    else
        tx_TC <= '0';
    end if;
end process;


end Behavioral;
