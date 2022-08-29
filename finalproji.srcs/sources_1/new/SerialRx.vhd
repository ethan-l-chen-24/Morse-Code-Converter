----------------------------------------------------------------------------------
-- Students: Ethan Chen and Chlorine Hammy Gilberto
-- Project: ENGS 31 Final Project - Morse Code Converter
-- Professor: Ben Dobbins

-- File: Serial Receiver
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- library declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.math_real.ALL;


-----------------------
-- ENTITY
-----------------------
entity SerialRx is
    Generic( 
        BAUD_RATE : integer;
        CLOCK_FREQUENCY : integer;
        TX_BITS : integer);
    Port( Clk : IN std_logic;
        RsRx : IN std_logic;   
        --rx_shift : out std_logic;		-- for testing      
        rx_data :  out std_logic_vector(7 downto 0);
        rx_done_tick : out std_logic );
end SerialRx;


-----------------------
-- ARCHITECTURE
-----------------------
architecture Behavioral of SerialRx is

    -- constants
    constant BAUD_COUNT : integer := CLOCK_FREQUENCY / BAUD_RATE;

    -- double flop synchronizer signals
    signal flop1 : std_logic := '1';
    signal rx_stable : std_logic := '1';
    
    -- shift register signal
    signal shift_register : std_logic_vector(9 downto 0) := (others => '0');
    
    -- control signals
    signal shift_en : std_logic := '0';
    signal clear_en : std_logic := '0';
    signal load_en : std_logic := '0';
    signal baud_count_en : std_logic := '0';
    
    -- fsm state signals
    type state_type is (Idle, Wait_Half, Shift, Wait_Full, Transfer, Done);
    signal curr_state : state_type := Idle;
    signal next_state : state_type;
    
    -- counter signals
    signal tx_counter : unsigned(3 downto 0) := (others => '0');
    signal tx_TC : std_logic := '0';
    signal baud_counter : unsigned(11 downto 0) := (others => '0');
    signal baud_over_2_TC : std_logic := '0';
    signal baud_TC: std_logic := '0';
    
begin

-- double flop synchronizer to condition the transmitted bits
doubleFlopSynchronizer: process(Clk)
begin
    if rising_edge(Clk) then
        flop1 <= RsRx; -- input through the first flop
        rx_stable <= flop1; -- first flop through second stable flop
    end if;       
end process;


-- shift register to store incoming bits
shiftRegisterProc: process(Clk)
begin
    if rising_edge(Clk) then
        if clear_en = '1' then -- clear the register when enabled
            shift_register <= (others => '0');
        elsif shift_en = '1' then -- right shift in the bit when enabled
            shift_register <= rx_stable & shift_register(9 downto 1);
        end if;
    end if;
end process;


-- loads shift register inner 8-bits into output register
outputRegisterProc: process(Clk)
begin
    if rising_edge(Clk) then
        if load_en = '1' then -- load the middle 8 bits into the output register when enabled
            rx_data <= shift_register(8 downto 1);
        end if;
    end if;
end process;


-----------------------
-- CONTROLLER
-----------------------

-- updates to the next state
stateUpdate: process(Clk)
begin
    if rising_edge(Clk) then -- update the curr state
        curr_state <= next_state;
    end if;
end process;

-- determines the next state based on curr state and inputs
nextStateLogic: process(curr_state, rx_stable, baud_over_2_TC, baud_TC, tx_TC)
begin
    next_state <= curr_state; -- default to curr state

    case curr_state is
    
        when Idle => -- when start bit enabled, move to start
            if rx_stable = '0' then
                next_state <= Wait_Half;    
            end if;
            
        when Wait_Half =>  -- wait half a baud cycle then shift
            if baud_over_2_TC = '1' then
                next_state <= Shift;
            end if;
            
        when Wait_Full => -- if done, transfer, otherwise wait baud cycle then shift
            if tx_TC = '1' then
                next_state <= Transfer;
            elsif baud_TC = '1' then
                next_state <= Shift;
            end if;
        
        when Shift => next_state <= Wait_Full; -- wait a baud cycle
        
        when Transfer => next_state <= Done; -- clear after loading the output register
        
        when Done => next_state <= Idle; -- return to idle to wait for another data packet
        
    end case;
end process;

-- outputs the proper control signals/data for each state
outputLogic: process(curr_state)
begin
    case curr_state is
        when Idle => 
            shift_en <= '0';
            clear_en <= '1';
            load_en <= '0';
            rx_done_tick <= '0';
            baud_count_en <= '0';
            
        when Wait_Half =>
            shift_en <= '0';
            clear_en <= '0';
            load_en <= '0';
            rx_done_tick <= '0';
            baud_count_en <= '1';
            
        when Wait_Full =>
            shift_en <= '0';
            clear_en <= '0';
            load_en <= '0';
            rx_done_tick <= '0';
            baud_count_en <= '1';
        
        when Shift =>
            shift_en <= '1';
            clear_en <= '0';
            load_en <= '0';
            rx_done_tick <= '0';
            baud_count_en <= '0';
        
        when Transfer =>
            shift_en <= '0';
            clear_en <= '0';
            load_en <= '1';
            rx_done_tick <= '0';
            baud_count_en <= '0';
        
        when Done =>
            shift_en <= '0';
            clear_en <= '1';
            load_en <= '0';
            rx_done_tick <= '1';
            baud_count_en <= '0';
        
    end case;
end process;


-------------------
-- COUNTERS
-------------------

-- counts the number of data bits that have been sent
txCounter: process(Clk)
begin
    if rising_edge(Clk) then
    
        if clear_en = '1' then -- if clear reset to 0
            tx_counter <= (others => '0');
        elsif shift_en = '1' then
            tx_counter <= tx_counter + 1; -- increment
        end if;
        
    end if;
end process;

-- asserts TC signal high when tx counts to TX_BITS
txTerminal: process(tx_counter)
begin
    if tx_counter = TX_BITS then -- if at terminal count, set tx_TC to high
        tx_TC <= '1';
    else 
        tx_TC <= '0';
    end if;
end process;

-- keeps the system in sync with the pre-determined baud count
baudCounter: process(Clk)
begin
    if rising_edge(Clk) then
        if baud_count_en = '1' then -- if clear reset to 0
            baud_counter <= baud_counter + 1;
        else
            baud_counter <= (others => '0');
        end if;
    end if;
end process;

-- asserts TC high when baud counts to BAUD_COUNT
baudTerminal: process(baud_counter)
begin
    if baud_counter = BAUD_COUNT-1 then
        baud_TC <= '1';
    else 
        baud_TC <= '0';
    end if;
end process;

-- asserts TC high when baud counts to BAUD_COUNT/2
baudOverTwoTerminal: process(baud_counter)
begin 
    if baud_counter = BAUD_COUNT/2-1 then
        baud_over_2_TC <= '1';
    else 
        baud_over_2_TC <= '0';
    end if;
end process;

end Behavioral;
