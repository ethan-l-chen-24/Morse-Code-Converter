----------------------------------------------------------------------------------
-- Students: Ethan Chen and Chlorine Hammy Gilberto
-- Project: ENGS 31 Final Project - Morse Code Converter
-- Professor: Ben Dobbins

-- File: Queue
----------------------------------------------------------------------------------

-- library declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.math_real.ALL;


-----------------
-- ENTITY
-----------------
entity queue is
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
end queue;


---------------------
-- ARCHITECTURE 
---------------------
architecture Behavioral of queue is

    -- constants for queue dimensions
    constant width_reg: integer := 8;
    
    -- creating the queue
    type regfile_type is
        array(0 to Nreg - 1) of std_logic_vector(width_reg - 1 downto 0);
    signal regfile : regfile_type;
    
    -- properties of queue
    signal front : integer := 0;
    signal back : integer := 0;
    signal chars_in_queue : integer := 0;
    signal w_en : std_logic; 
    signal r_en: std_logic; 
    signal pop_en: std_logic;
    signal empty: std_logic; 
    signal full: std_logic; 
    
begin   

-- register file for the queue with write and read enable
queue: process(clk_port)
begin
    if rising_edge(clk_port) then
    
        if w_en = '1' then -- write to queue
            regfile(back) <= in_port; -- write at back pointer
            chars_in_queue <= chars_in_queue + 1; -- increment number of chars
            
            if back = Nreg-1 then back <= 0; -- wrap around
            else back <= back + 1;
            end if;  

        elsif r_en = '1' then -- read from queue
            out_port <= regfile(front); -- read at front pointer
            chars_in_queue <= chars_in_queue - 1; -- decrement number of chars
            
            if front = Nreg -1 then front <= 0; -- wrap around
            else front <= front + 1;
            end if; 
         
        elsif pop_en = '1' then
            chars_in_queue <= chars_in_queue - 1; -- decrement number of chars
            
            if back = 0 then back <= Nreg-1;
            else back <= back - 1;
            end if;
        end if;
    
    end if;
end process;
                                                                                                                     
-- handles output signals for empty and full based on chars_in_queue
empty_full: process(chars_in_queue)
begin
    if chars_in_queue = 0 then -- if no characters assert empty
        empty <= '1';
    else
        empty <= '0';
    end if;
    
    if chars_in_queue = 16 then -- if all characters assert true
        full <= '1'; 
    else
        full <='0'; 
    end if;
end process;

-- wirings
w_en <= enqueue_port and not(full); -- enable writing if enqueue and queue not full
r_en <= dequeue_port and not(empty); -- enable reading if dequeue and queue not empty
pop_en <= pop_port and not(empty); -- enable pop if pop and queue not empty
empty_port <= empty;
full_port <= full;

end Behavioral;
