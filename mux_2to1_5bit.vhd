LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux_2to1_5bit IS
    PORT(
        sel     : IN  STD_LOGIC;                              -- Select input
        d_in1   : IN  STD_LOGIC_VECTOR(4 downto 0);           -- 5-bit Data input 1
        d_in2   : IN  STD_LOGIC_VECTOR(4 downto 0);           -- 5-bit Data input 2
        d_out   : OUT STD_LOGIC_VECTOR(4 downto 0)            -- 5-bit Data output
    );
END mux_2to1_5bit;

ARCHITECTURE structural OF mux_2to1_5bit IS

    SIGNAL not_sel  : STD_LOGIC;
    SIGNAL and1     : STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL and2     : STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL temp_out : STD_LOGIC_VECTOR(4 downto 0);

BEGIN
    not_sel <= NOT(sel);

    -- AND gates for each bit of d_in1
    and1(0) <= d_in1(0) AND not_sel;
    and1(1) <= d_in1(1) AND not_sel;
    and1(2) <= d_in1(2) AND not_sel;
    and1(3) <= d_in1(3) AND not_sel;
    and1(4) <= d_in1(4) AND not_sel;

    -- AND gates for each bit of d_in2
    and2(0) <= d_in2(0) AND sel;
    and2(1) <= d_in2(1) AND sel;
    and2(2) <= d_in2(2) AND sel;
    and2(3) <= d_in2(3) AND sel;
    and2(4) <= d_in2(4) AND sel;

    -- OR gates to combine outputs
    temp_out(0) <= and1(0) OR and2(0);
    temp_out(1) <= and1(1) OR and2(1);
    temp_out(2) <= and1(2) OR and2(2);
    temp_out(3) <= and1(3) OR and2(3);
    temp_out(4) <= and1(4) OR and2(4);

    -- Final output
    d_out <= temp_out;

END structural;
