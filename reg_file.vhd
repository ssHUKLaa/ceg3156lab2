library ieee;
use ieee.std_logic_1164.all;

entity reg_file is
    port (
        clk         : in  std_logic;
        resetBar    : in  std_logic;
        reg_write   : in  std_logic;
        read_reg1   : in  std_logic_vector(4 downto 0);
        read_reg2   : in  std_logic_vector(4 downto 0);
        write_reg   : in  std_logic_vector(4 downto 0);
        write_data  : in  std_logic_vector(31 downto 0);
        read_data1  : out std_logic_vector(31 downto 0);
        read_data2  : out std_logic_vector(31 downto 0)
    );
end reg_file;

architecture basic of reg_file IS

    component enardFF_2 is
        port (
            i_resetBar : in  std_logic;
            i_d        : in  std_logic;
            i_enable   : in  std_logic;
            i_clock    : in  std_logic;
            o_q        : out std_logic;
            o_qBar     : out std_logic
        );
    end component;

    component mux_32to1_32bit is
        port (
            sel     : in  std_logic_vector(4 downto 0);
            d_in    : in  std_logic_vector(1023 downto 0); -- 32 x 32 bits
            d_out   : out std_logic_vector(31 downto 0)
        );
    end component;

    signal n0, n1, n2, n3, n4 : std_logic;
    signal enables : std_logic_vector(31 downto 0);
    signal regs_flat : std_logic_vector(1023 downto 0);
    type reg_file_type is array (0 to 31) of std_logic_vector(31 downto 0);
    signal reg_matrix : reg_file_type;




begin

    n0 <= not write_reg(0);
    n1 <= not write_reg(1);
    n2 <= not write_reg(2);
    n3 <= not write_reg(3);
    n4 <= not write_reg(4);

    enables(0)  <= n4 and n3 and n2 and n1 and n0 and reg_write;
    enables(1)  <= n4 and n3 and n2 and n1 and write_reg(0) and reg_write;
    enables(2)  <= n4 and n3 and n2 and write_reg(1) and n0 and reg_write;
    enables(3)  <= n4 and n3 and n2 and write_reg(1) and write_reg(0) and reg_write;
    enables(4)  <= n4 and n3 and write_reg(2) and n1 and n0 and reg_write;
    enables(5)  <= n4 and n3 and write_reg(2) and n1 and write_reg(0) and reg_write;
    enables(6)  <= n4 and n3 and write_reg(2) and write_reg(1) and n0 and reg_write;
    enables(7)  <= n4 and n3 and write_reg(2) and write_reg(1) and write_reg(0) and reg_write;
    enables(8)  <= n4 and write_reg(3) and n2 and n1 and n0 and reg_write;
    enables(9)  <= n4 and write_reg(3) and n2 and n1 and write_reg(0) and reg_write;
    enables(10) <= n4 and write_reg(3) and n2 and write_reg(1) and n0 and reg_write;
    enables(11) <= n4 and write_reg(3) and n2 and write_reg(1) and write_reg(0) and reg_write;
    enables(12) <= n4 and write_reg(3) and write_reg(2) and n1 and n0 and reg_write;
    enables(13) <= n4 and write_reg(3) and write_reg(2) and n1 and write_reg(0) and reg_write;
    enables(14) <= n4 and write_reg(3) and write_reg(2) and write_reg(1) and n0 and reg_write;
    enables(15) <= n4 and write_reg(3) and write_reg(2) and write_reg(1) and write_reg(0) and reg_write;
    enables(16) <= write_reg(4) and n3 and n2 and n1 and n0 and reg_write;
    enables(17) <= write_reg(4) and n3 and n2 and n1 and write_reg(0) and reg_write;
    enables(18) <= write_reg(4) and n3 and n2 and write_reg(1) and n0 and reg_write;
    enables(19) <= write_reg(4) and n3 and n2 and write_reg(1) and write_reg(0) and reg_write;
    enables(20) <= write_reg(4) and n3 and write_reg(2) and n1 and n0 and reg_write;
    enables(21) <= write_reg(4) and n3 and write_reg(2) and n1 and write_reg(0) and reg_write;
    enables(22) <= write_reg(4) and n3 and write_reg(2) and write_reg(1) and n0 and reg_write;
    enables(23) <= write_reg(4) and n3 and write_reg(2) and write_reg(1) and write_reg(0) and reg_write;
    enables(24) <= write_reg(4) and write_reg(3) and n2 and n1 and n0 and reg_write;
    enables(25) <= write_reg(4) and write_reg(3) and n2 and n1 and write_reg(0) and reg_write;
    enables(26) <= write_reg(4) and write_reg(3) and n2 and write_reg(1) and n0 and reg_write;
    enables(27) <= write_reg(4) and write_reg(3) and n2 and write_reg(1) and write_reg(0) and reg_write;
    enables(28) <= write_reg(4) and write_reg(3) and write_reg(2) and n1 and n0 and reg_write;
    enables(29) <= write_reg(4) and write_reg(3) and write_reg(2) and n1 and write_reg(0) and reg_write;
    enables(30) <= write_reg(4) and write_reg(3) and write_reg(2) and write_reg(1) and n0 and reg_write;
    enables(31) <= write_reg(4) and write_reg(3) and write_reg(2) and write_reg(1) and write_reg(0) and reg_write;

    gen_registers: for r in 0 to 31 generate
        gen_bits: for b in 0 to 31 generate
            dff_inst: enardFF_2
                port map (
                    i_resetBar => resetBar,
                    i_d        => write_data(b),
                    i_enable   => enables(r),
                    i_clock    => clk,
                    o_q        => reg_matrix(r)(b),  -- note parentheses for std_logic_vector indexing
                    o_qBar     => open
                );
        end generate;
    end generate;

    flatten: for i in 0 to 31 generate
        regs_flat((i+1)*32 - 1 downto i*32) <= reg_matrix(i);
    end generate;


    read_mux1: mux_32to1_32bit
        port map (
            sel   => read_reg1,
            d_in  => regs_flat,
            d_out => read_data1
        );

    read_mux2: mux_32to1_32bit
        port map (
            sel   => read_reg2,
            d_in  => regs_flat,
            d_out => read_data2
        );

end basic;