LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY lpm;

ENTITY data_ram IS
    PORT (
        aclr    : IN STD_LOGIC := '0';
        address : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clock   : IN STD_LOGIC := '1';
        data    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        rden    : IN STD_LOGIC := '1';
        wren    : IN STD_LOGIC;
        q       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END data_ram;

ARCHITECTURE synth OF data_ram IS

    COMPONENT lpm_ram_dq
    GENERIC (
        lpm_width           : NATURAL;
        lpm_widthad         : NATURAL;
        lpm_numwords        : NATURAL;
        lpm_indata          : STRING;
        lpm_address_control : STRING;
        lpm_outdata         : STRING;
        lpm_file            : STRING
    );
    PORT (
        address : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        data    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        inclock : IN STD_LOGIC;
        we      : IN STD_LOGIC;
        q       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    END COMPONENT;


    SIGNAL ram_q : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

    ram_inst : lpm_ram_dq
    GENERIC MAP (
        lpm_width           => 32,
        lpm_widthad         => 8,
        lpm_numwords        => 256,
        lpm_indata          => "REGISTERED",       -- sync write input
        lpm_address_control => "UNREGISTERED",     -- async address input
        lpm_outdata         => "UNREGISTERED",     -- async data output
        lpm_file            => "data_mem_32.mif"
    )
    PORT MAP (
        address => address,
        data    => data,
        inclock => clock,
        we      => wren,
        q       => ram_q
    );

    -- Gate output with rden: output zero if rden = '0'
    q <= ram_q WHEN rden = '1' ELSE (OTHERS => '0');

END synth;
