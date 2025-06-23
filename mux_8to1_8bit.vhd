LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux_8to1_8bit IS
    PORT(
        sel   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); -- 3-bit selector
        d_in0 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        d_in1 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        d_in2 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        d_in3 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        d_in4 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        d_in5 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        d_in6 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        d_in7 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        d_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END mux_8to1_8bit;

ARCHITECTURE structural OF mux_8to1_8bit IS

    SIGNAL sel0, sel1, sel2     : STD_LOGIC;
    SIGNAL nsel0, nsel1, nsel2 : STD_LOGIC;
    SIGNAL enable               : STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL and_out0, and_out1, and_out2, and_out3 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL and_out4, and_out5, and_out6, and_out7 : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
    -- Decode select lines
    sel0 <= sel(0);
    sel1 <= sel(1);
    sel2 <= sel(2);
    nsel0 <= NOT sel0;
    nsel1 <= NOT sel1;
    nsel2 <= NOT sel2;

    -- 3-to-8 decoder
    enable(0) <= nsel2 AND nsel1 AND nsel0;
    enable(1) <= nsel2 AND nsel1 AND sel0;
    enable(2) <= nsel2 AND sel1  AND nsel0;
    enable(3) <= nsel2 AND sel1  AND sel0;
    enable(4) <= sel2  AND nsel1 AND nsel0;
    enable(5) <= sel2  AND nsel1 AND sel0;
    enable(6) <= sel2  AND sel1  AND nsel0;
    enable(7) <= sel2  AND sel1  AND sel0;

    -- AND gates for each 8-bit input with enable
    gen_and0: FOR i IN 0 TO 7 GENERATE and_out0(i) <= d_in0(i) AND enable(0); END GENERATE;
    gen_and1: FOR i IN 0 TO 7 GENERATE and_out1(i) <= d_in1(i) AND enable(1); END GENERATE;
    gen_and2: FOR i IN 0 TO 7 GENERATE and_out2(i) <= d_in2(i) AND enable(2); END GENERATE;
    gen_and3: FOR i IN 0 TO 7 GENERATE and_out3(i) <= d_in3(i) AND enable(3); END GENERATE;
    gen_and4: FOR i IN 0 TO 7 GENERATE and_out4(i) <= d_in4(i) AND enable(4); END GENERATE;
    gen_and5: FOR i IN 0 TO 7 GENERATE and_out5(i) <= d_in5(i) AND enable(5); END GENERATE;
    gen_and6: FOR i IN 0 TO 7 GENERATE and_out6(i) <= d_in6(i) AND enable(6); END GENERATE;
    gen_and7: FOR i IN 0 TO 7 GENERATE and_out7(i) <= d_in7(i) AND enable(7); END GENERATE;

    -- OR gates to combine the outputs
    gen_or: FOR i IN 0 TO 7 GENERATE
        d_out(i) <= and_out0(i) OR and_out1(i) OR and_out2(i) OR and_out3(i) OR
                    and_out4(i) OR and_out5(i) OR and_out6(i) OR and_out7(i);
    END GENERATE;

END structural;
