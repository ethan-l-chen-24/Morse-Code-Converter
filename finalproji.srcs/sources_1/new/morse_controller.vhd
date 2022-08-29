----------------------------------------------------------------------------------
-- Students: Ethan Chen and Chlorine Hammy Gilberto
-- Project: ENGS 31 Final Project - Morse Code Converter
-- Professor: Ben Dobbins

-- File: Morse Code Controller
----------------------------------------------------------------------------------

-- library declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;


----------------
-- ENTITY
----------------
entity morse_controller is
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
        
end morse_controller;


-------------------
-- ARCHITECTURE
-------------------
architecture behavioral_architecture of morse_controller is
    
    -- internal signals
    signal c_en : std_logic := '0';
    signal count : unsigned(31 downto 0) := (others => '0');
    signal TC : std_logic := '0';
    signal brom_count : unsigned(3 downto 0) := (others => '0');
    signal brom_TC : std_logic := '0';
    signal cvt_morse : std_logic := '0';
    
    -- FSM signals
    type state_type is (Start, Dequeue, Cvt_To_Morse, Load_Morse, Hold, Play);
    signal curr_state : state_type := start;
    signal next_state : state_type;

begin

-- set signal to port
cvt_morse_port <= cvt_morse;

-- update the current state
StateUpdate: process(clk_port)
begin
    if rising_edge(clk_port) then
        curr_state <= next_state;
    end if;
end process StateUpdate;

-- get the next state from curr state and inputs
NextStateLogic: process(curr_state, enter_port, empty_port, audio_done_port, brom_TC, TC)
begin
    next_state <= curr_state; -- default to same state
    
    case curr_state is
        when Start =>
            if enter_port ='1' then -- enter hit, dequeue characters
                next_state <= Dequeue;
            end if;
            
        when Cvt_To_Morse => 
            if brom_TC = '1' then
                next_state <= Load_Morse;
            end if;
        
        when Load_Morse => next_state <= Play;
        
        when Play =>
            if audio_done_port = '1' then -- wait until done playing to move to next character
                next_state <= Hold;
            end if;
            
        when Hold =>
            if TC = '1' then -- wait between characters
                next_state <= Dequeue;
            end if;
        
        when Dequeue =>
            if empty_port = '1' then -- return to start if the queue is empty, otherwise play again
                next_state <= Start;
            else
                next_state <= Cvt_To_Morse;
            end if;
            
    end case;
end process NextStateLogic;

-- map the current state to outputs
OutputLogic: process(curr_state)
begin
    case curr_state is
        when Start =>
            cvt_morse <= '0';
            load_morse_port <= '0';
            play_port <= '0';
            dequeue_port <= '0';
            c_en <= '0';

        when Dequeue =>
            cvt_morse <= '0';
            load_morse_port <= '0';
            play_port <= '0';
            dequeue_port <= '1';
            c_en <= '0';

        when Cvt_To_Morse =>
            cvt_morse <= '1';
            load_morse_port <= '0';
            play_port <= '0';
            dequeue_port <= '0';
            c_en <= '0';
            
        when Load_Morse =>
            cvt_morse <= '0';
            load_morse_port <= '1';
            play_port <= '0';
            dequeue_port <= '0';
            c_en <= '0';

        when Play =>
            cvt_morse <= '0';
            load_morse_port <= '0';
            play_port <= '1';
            dequeue_port <= '0';
            c_en <= '0';

        when Hold =>
            cvt_morse <= '0';
            load_morse_port <= '0';
            play_port <= '0';
            dequeue_port <= '0';
            c_en <= '1';
            
    end case;
end process OutputLogic;

-------------------
-- Counter
-------------------

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

-- increment brom counter
bromCounter: process(clk_port) 
begin
    if rising_edge(clk_port) then
        if cvt_morse = '1' then
            brom_count <= brom_count + 1; -- begin counting
        else
            brom_count <= (others => '0'); -- reset to 0
        end if;
    end if;

end process;

-- assert TC high once we have waited enough clock cycles
bromTCSignal: process(brom_count)
begin
    if brom_count = 3 then
        brom_TC <= '1';
    else
        brom_TC <= '0';
    end if;
end process;


end behavioral_architecture;