LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY CLA_32bit IS
    PORT (
        a, b      : IN  std_logic_vector(31 downto 0);
        cin       : IN  std_logic;
        sum       : OUT std_logic_vector(31 downto 0);
        carryOut  : OUT std_logic;
        zeroOut   : OUT std_logic;
        overflowOut : OUT std_logic
    );
END CLA_32bit;

ARCHITECTURE basic OF CLA_32bit IS

    COMPONENT CLA_8bit IS
        PORT (
            a, b         : IN  std_logic_vector(7 downto 0);
            cin          : IN  std_logic;
            sum          : OUT std_logic_vector(7 downto 0);
            carryOut     : OUT std_logic;
            zeroOut      : OUT std_logic;
            overflowOut  : OUT std_logic
        );
    END COMPONENT;

    SIGNAL carry : std_logic_vector(4 downto 0);
    SIGNAL segmentSums : std_logic_vector(31 downto 0);
    SIGNAL zeroFlags : std_logic_vector(3 downto 0);
    SIGNAL overflowFlags : std_logic_vector(3 downto 0);
BEGIN

    carry(0) <= cin;

    CLA0: CLA_8bit
        PORT MAP(
            a => a(7 downto 0),
            b => b(7 downto 0),
            cin => carry(0),
            sum => segmentSums(7 downto 0),
            carryOut => carry(1),
            zeroOut => zeroFlags(0),
            overflowOut => overflowFlags(0)
        );

    CLA1: CLA_8bit
        PORT MAP(
            a => a(15 downto 8),
            b => b(15 downto 8),
            cin => carry(1),
            sum => segmentSums(15 downto 8),
            carryOut => carry(2),
            zeroOut => zeroFlags(1),
            overflowOut => overflowFlags(1)
        );

    CLA2: CLA_8bit
        PORT MAP(
            a => a(23 downto 16),
            b => b(23 downto 16),
            cin => carry(2),
            sum => segmentSums(23 downto 16),
            carryOut => carry(3),
            zeroOut => zeroFlags(2),
            overflowOut => overflowFlags(2)
        );

    CLA3: CLA_8bit
        PORT MAP(
            a => a(31 downto 24),
            b => b(31 downto 24),
            cin => carry(3),
            sum => segmentSums(31 downto 24),
            carryOut => carry(4),
            zeroOut => zeroFlags(3),
            overflowOut => overflowFlags(3)
        );

    sum <= segmentSums;
    carryOut <= carry(4);
    zeroOut <= zeroFlags(0) AND zeroFlags(1) AND zeroFlags(2) AND zeroFlags(3);
    overflowOut <= overflowFlags(3);  -- Overflow of MSB segment

END basic;
