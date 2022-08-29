----------------------------------------------------------------------------------
-- Students: Ethan Chen and Chlorine Hammy Gilberto
-- Project: ENGS 31 Final Project - Morse Code Converter
-- Professor: Ben Dobbins

-- File: Sine Wave Generator
----------------------------------------------------------------------------------

-- library declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;

----------------------
-- ENTITY
----------------------
entity sine_wave_generator is
    Generic(
        CLK_FREQ : integer;
        NUM_POINTS : integer := 32;
        MAX_AMPLITUDE : integer := 255; 
        FREQUENCY : integer := 261 );
    Port(
        clk_port : in std_logic;
        audio_en_port : in std_logic;
        sine_out_port : out std_logic_vector(7 downto 0) );
end sine_wave_generator;


---------------------------
-- ARCHITECTURE
---------------------------
architecture Behavioral of sine_wave_generator is

-- constants
    constant TC_COUNT : integer := CLK_FREQ / NUM_POINTS / FREQUENCY;

-- signals
    signal counter : integer := 0; -- counts where we are in sine wave
    type memory_type is 
        array(0 to NUM_POINTS - 1) of integer range 0 to MAX_AMPLITUDE;
        
    signal sine : memory_type := (128, 152, 176, 198, 218, 234, 245, 253, 255, 253, 245, 234, 218, 198, 
                                  176, 152, 128, 103, 79, 57, 37, 21, 10, 2, 0, 2, 10, 21, 37, 57, 79, 103); -- sine wave
                                  
    signal sine_out : integer := 0;
    
    signal timer_count : unsigned(15 downto 0) := (others => '0'); -- frequency divider
    signal timer_TC : std_logic := '0';
    
begin

-- generates the sine wave if enabled
sine_wave_gen: process(clk_port)
begin
    if rising_edge(clk_port) then  
        if audio_en_port = '1' then -- only create sine wave if enabled
        
            if timer_TC = '1' then -- after waiting allotted clock cycles
                if counter = NUM_POINTS - 1 then -- increment counter
                    counter <= 0;
                else
                    counter <= counter + 1;
                end if;
            end if;
        
            sine_out <= sine(counter); -- get the wave pattern from rom
       
        else
            sine_out <= 0; -- reset to 0
            counter <= 0;
        end if;       
    end if;

end process;

-- generates proper frequency ticks
timer: process(clk_port)
begin
    if rising_edge(clk_port) then
        if timer_count = TC_COUNT then
            timer_count <= (others => '0');
        else
            timer_count <= timer_count + 1; 
        end if;
    end if;
end process;

-- sets the TC to high to increment counter
timer_tick: process(timer_count)
begin
    if timer_count = TC_COUNT then
        timer_TC <= '1';
    else
        timer_TC <= '0';
    end if;
end process;

-- map integer value to a std_logic_vector
sine_out_port <= std_logic_vector(to_unsigned(sine_out, 8));

end Behavioral;
