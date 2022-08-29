----------------------------------------------------------------------------------
-- Students: Ethan Chen and Chlorine Hammy Gilberto
-- Project: ENGS 31 Final Project - Morse Code Converter
-- Professor: Ben Dobbins

-- File: Morse Code Datapath
----------------------------------------------------------------------------------

-- library declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-----------------------
-- ENTITY
-----------------------
entity morse_datapath is
    Port( clk_port : in std_logic;
          ascii_in_port : in std_logic_vector(7 downto 0);
          cvt_morse_port : in std_logic;
          load_morse_port : in std_logic;
          morse_code_port : out std_logic_vector(19 downto 0);
          bit_count_port : out std_logic_vector(4 downto 0));
end morse_datapath;


----------------------
-- ARCHITECTURE
----------------------
architecture Behavioral of morse_datapath is
    -- signals out of lookup tables
    signal code_out : std_logic_vector(19 downto 0) := (others => '0');
    signal bit_out : std_logic_vector(4 downto 0) := (others => '0');
    
    -- brom blocks
    
    COMPONENT blk_mem_ascii_to_morse
    PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(19 DOWNTO 0)
    );
    END COMPONENT;

    COMPONENT blk_mem_morse_bitcounts
    PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
    );
    END COMPONENT;
    
begin

-- port maps

asciiToMorse : blk_mem_ascii_to_morse
  PORT MAP (
    clka => clk_port,
    ena => cvt_morse_port,
    addra => ascii_in_port,
    douta => code_out
  );
  
morse_bitcounts : blk_mem_morse_bitcounts
  PORT MAP (
    clka => clk_port,
    ena => cvt_morse_port,
    addra => ascii_in_port,
    douta => bit_out
  );
    
-- loads the output of the lookup tables into the output registers
morse: process(clk_port)
begin
    if rising_edge(clk_port) then
        if load_morse_port = '1' then
            morse_code_port <= code_out; -- load into output registers
            bit_count_port <= bit_out;
        end if;
    end if;
end process;

end Behavioral;