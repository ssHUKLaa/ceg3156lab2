LIBRARY ieee;
use IEEE.STD_LOGIC_1164.ALL;

ENTITY ALU_32bit is
    PORT (
        A, B : IN std_logic_vector(31 downto 0);
        sel : IN std_logic_vector(2 downto 0);
        ALU_res : OUT std_logic_vector(31 downto 0);
        Zero : OUT std_logic
    );
end ALU_32bit;

architecture basic of ALU_32bit IS

    component mux_8to1_32bit IS
        PORT(
            sel   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); -- 3-bit selector
            d_in0 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            d_in1 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            d_in2 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            d_in3 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            d_in4 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            d_in5 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            d_in6 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            d_in7 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            d_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END component;

    component CLA_32bit IS
        PORT (
            a, b      : IN  std_logic_vector(31 downto 0);
            cin       : IN  std_logic;
            sum       : OUT std_logic_vector(31 downto 0);
            carryOut  : OUT std_logic;
            zeroOut   : OUT std_logic;
            overflowOut : OUT std_logic
        );
    END component;

    SIGNAL transAnd, transOr, transSum, transB, transDiff : std_logic_vector(31 downto 0);
    SIGNAL transZero : std_logic;
begin

    cla_32bit_inst: entity work.CLA_32bit
    port map (
      a           => A,
      b           => B,
      cin         => '0',
      sum         => transSum,
      carryOut    => open,
      zeroOut     => open,
      overflowOut => open
    );

    transB <= NOT B;

    subtractor: entity work.CLA_32bit
    port map (
      a           => a,
      b           => transB,
      cin         => '1',
      sum         => transDiff,
      carryOut    => open,
      zeroOut     => transZero,
      overflowOut => open
    );

    Zero <= transZero AND sel(2) AND sel(1) AND sel(0);
    transAnd <= A AND B;
    transOr <= A OR B;

    mux_8to1_32bit_inst: entity work.mux_8to1_32bit
    port map (
      sel   => sel,
      d_in0 => transAnd,
      d_in1 => transOr,
      d_in2 => transSum,
      d_in3 => transSum,
      d_in4 => transSum,
      d_in5 => transSum,
      d_in6 => transDiff,
      d_in7 => transDiff,
      d_out => ALU_res
    );





end basic;