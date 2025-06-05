LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux_2to1_32bit IS
    PORT(
        sel     : IN  STD_LOGIC;                              -- Select input
        d_in1   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);          -- 32-bit Data input 1
        d_in2   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);          -- 32-bit Data input 2
        d_out   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)           -- 32-bit Data output
    );
END mux_2to1_32bit;

ARCHITECTURE structural OF mux_2to1_32bit IS

    SIGNAL not_sel  : STD_LOGIC;                              -- Inverted select signal
    SIGNAL and1     : STD_LOGIC_VECTOR(31 DOWNTO 0);          -- AND outputs for input 1
    SIGNAL and2     : STD_LOGIC_VECTOR(31 DOWNTO 0);          -- AND outputs for input 2
    SIGNAL temp_out : STD_LOGIC_VECTOR(31 DOWNTO 0);          -- Output before assignment

BEGIN

    not_sel <= NOT sel;

    gen_and1: FOR i IN 0 TO 31 GENERATE
        and1(i) <= d_in1(i) AND not_sel;
    END GENERATE;

    gen_and2: FOR i IN 0 TO 31 GENERATE
        and2(i) <= d_in2(i) AND sel;
    END GENERATE;

    gen_or: FOR i IN 0 TO 31 GENERATE
        temp_out(i) <= and1(i) OR and2(i);
    END GENERATE;

    d_out <= temp_out;

END structural;
