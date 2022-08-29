----------------------------------------------------------------------------------
-- Students: Ethan Chen and Chlorine Hammy Gilberto
-- Project: ENGS 31 Final Project - Morse Code Converter
-- Professor: Ben Dobbins

-- File: Audio Handler
----------------------------------------------------------------------------------

-- library declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;


----------------------
-- ENTITY
----------------------
entity audio_handler is
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
end audio_handler;


---------------------------
-- ARCHITECTURE
---------------------------
architecture Behavioral of audio_handler is
    
    -- FSM signals
    type state_type is (Start, Load, Shift, Hold, Done);
    signal curr_state : state_type := start;
    signal next_state : state_type;
    
    -- control signals
    signal pl_load_en : std_logic := '0';
    signal shift_en : std_logic := '0';
    signal c_en : std_logic := '0';
    
    -- counter
    signal count : unsigned(31 downto 0) := (others => '0');
    signal TC : std_logic := '0';
    
    -- datapath
    signal out_of_bits : std_logic := '0';
    signal shift_register : std_logic_vector(19 downto 0) := (others => '0');
    signal decrementor : unsigned(4 downto 0) := (others => '0');
    
begin

---------------------
-- CONTROLLER
---------------------

-- update the current state
StateUpdate: process(clk_port)
begin
    if rising_edge(clk_port) then
        curr_state <= next_state;
    end if;
end process StateUpdate;

-- get the next state from curr state and inputs
NextStateLogic: process(curr_state, play_port, out_of_bits, TC)
begin
    next_state <= curr_state; -- default to same state
    
    case curr_state is
        when Start =>
            if play_port = '1' then -- start if play is asserted
                next_state <= Load;
            end if;
            
        when Load => next_state <= Shift; -- load in the morse code
        
        when Shift =>
            if out_of_bits = '1' then -- shift out morse code bit
                next_state <= Done;
            else
                next_state <= Hold;
            end if;
            
        when Hold => -- hold for allotted time 
            if TC = '1' then
                next_state <= Shift;
            end if;
            
        when Done => next_state <= Start; -- finished playing a character
        
    end case;
    
end process NextStateLogic;

-- map the current state to outputs
OutputLogic: process(curr_state)
begin
    case curr_state is
        when Start =>
            pl_load_en <= '0';
            shift_en <= '0';
            c_en <= '0';
            audio_done_port <= '0';
            
        when Load =>
            pl_load_en <= '1';
            shift_en <= '0';
            c_en <= '0';
            audio_done_port <= '0';
        
        when Shift =>
            pl_load_en <= '0';
            shift_en <= '1';
            c_en <= '0';
            audio_done_port <= '0';
        
        when Hold =>
            pl_load_en <= '0';
            shift_en <= '0';
            c_en <= '1';
            audio_done_port <= '0';
        
        when Done =>
            pl_load_en <= '0';
            shift_en <= '0';
            c_en <= '0';
            audio_done_port <= '1';
    
    end case;
end process OutputLogic;


----------------------
-- Counter
----------------------

-- increment counter
counter: process(clk_port) 
begin
    if rising_edge(clk_port) then
        if c_en = '1' then
            count <= count + 1; -- begin counting
        else
            count <= (others => '0'); -- reset to 0
        end if;
    end if;

end process;

-- assert TC high once we have waited enough clock cycles
tcSignal: process(count)
begin
    if count = COUNT_MAX then
        TC <= '1';
    else
        TC <= '0';
    end if;
end process;


--------------------
-- DATAPATH
--------------------

-- load in and shift out the morse code bits
shiftRegisterProc: process(clk_port)
begin
    if rising_edge(clk_port) then
        if pl_load_en = '1' then -- clear the register when enabled
            shift_register <= code_in_port;
        elsif shift_en = '1' then -- left shift out the bit when enabled
            shift_register <= shift_register(18 downto 0) & '0';
            audio_out <= shift_register(19);
        end if;
    end if;
end process;

-- decrement the bit count for each shift
bitcountDecrementor: process(clk_port)
begin
    if rising_edge(clk_port) then
        if pl_load_en = '1' then
            decrementor <= unsigned(bitcount_port) - 1;
        elsif shift_en = '1' then
            decrementor <= decrementor - 1;
        end if;
    end if;
end process;

-- assert out_of_bits high once we have played all bits
outOfBitsSignal: process(decrementor)
begin
    if decrementor = 0 then
        out_of_bits <= '1';
    else
        out_of_bits <= '0';
    end if;
end process;

end Behavioral;
