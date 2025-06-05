library ieee;
use ieee.std_logic_1164.all;

entity mux_32to1_32bit is
    port (
        sel     : in  std_logic_vector(4 downto 0);  -- 5-bit selector (0-31)
        d_in    : in  std_logic_vector(32*32 - 1 downto 0); -- 32 inputs × 32 bits
        d_out   : out std_logic_vector(31 downto 0)
    );
end mux_32to1_32bit;

architecture structural of mux_32to1_32bit is

    signal enables : std_logic_vector(31 downto 0);

    type word_array is array(0 to 31) of std_logic_vector(31 downto 0);
    signal inputs : word_array;

    signal and_outs : word_array;

begin

    gen_input_slice: for i in 0 to 31 generate
        inputs(i) <= d_in((i+1)*32 - 1 downto i*32);
    end generate;

    enables(0)  <= '1' when sel = "00000" else '0';
    enables(1)  <= '1' when sel = "00001" else '0';
    enables(2)  <= '1' when sel = "00010" else '0';
    enables(3)  <= '1' when sel = "00011" else '0';
    enables(4)  <= '1' when sel = "00100" else '0';
    enables(5)  <= '1' when sel = "00101" else '0';
    enables(6)  <= '1' when sel = "00110" else '0';
    enables(7)  <= '1' when sel = "00111" else '0';
    enables(8)  <= '1' when sel = "01000" else '0';
    enables(9)  <= '1' when sel = "01001" else '0';
    enables(10) <= '1' when sel = "01010" else '0';
    enables(11) <= '1' when sel = "01011" else '0';
    enables(12) <= '1' when sel = "01100" else '0';
    enables(13) <= '1' when sel = "01101" else '0';
    enables(14) <= '1' when sel = "01110" else '0';
    enables(15) <= '1' when sel = "01111" else '0';
    enables(16) <= '1' when sel = "10000" else '0';
    enables(17) <= '1' when sel = "10001" else '0';
    enables(18) <= '1' when sel = "10010" else '0';
    enables(19) <= '1' when sel = "10011" else '0';
    enables(20) <= '1' when sel = "10100" else '0';
    enables(21) <= '1' when sel = "10101" else '0';
    enables(22) <= '1' when sel = "10110" else '0';
    enables(23) <= '1' when sel = "10111" else '0';
    enables(24) <= '1' when sel = "11000" else '0';
    enables(25) <= '1' when sel = "11001" else '0';
    enables(26) <= '1' when sel = "11010" else '0';
    enables(27) <= '1' when sel = "11011" else '0';
    enables(28) <= '1' when sel = "11100" else '0';
    enables(29) <= '1' when sel = "11101" else '0';
    enables(30) <= '1' when sel = "11110" else '0';
    enables(31) <= '1' when sel = "11111" else '0';


    gen_and: for i in 0 to 31 generate
        gen_and_bits: for j in 0 to 31 generate
            and_outs(i)(j) <= inputs(i)(j) and enables(i);
        end generate;
    end generate;

    gen_or: for j in 0 to 31 generate
        d_out(j) <= and_outs(0)(j) or and_outs(1)(j) or and_outs(2)(j) or and_outs(3)(j) or
                    and_outs(4)(j) or and_outs(5)(j) or and_outs(6)(j) or and_outs(7)(j) or
                    and_outs(8)(j) or and_outs(9)(j) or and_outs(10)(j) or and_outs(11)(j) or
                    and_outs(12)(j) or and_outs(13)(j) or and_outs(14)(j) or and_outs(15)(j) or
                    and_outs(16)(j) or and_outs(17)(j) or and_outs(18)(j) or and_outs(19)(j) or
                    and_outs(20)(j) or and_outs(21)(j) or and_outs(22)(j) or and_outs(23)(j) or
                    and_outs(24)(j) or and_outs(25)(j) or and_outs(26)(j) or and_outs(27)(j) or
                    and_outs(28)(j) or and_outs(29)(j) or and_outs(30)(j) or and_outs(31)(j);
    end generate;

end architecture;
