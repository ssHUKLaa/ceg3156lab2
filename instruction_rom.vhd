library ieee;
use ieee.std_logic_1164.all;
LIBRARY lpm;

entity instruction_rom is
    port (
        address : in std_logic_vector(7 downto 0);
        q       : out std_logic_vector(31 downto 0)
    );
end entity;

architecture synth of instruction_rom is

    component lpm_rom
        generic (
            lpm_width           : natural;
            lpm_widthad         : natural;
            lpm_numwords        : natural;
            lpm_address_control : string;
            lpm_outdata         : string;
            lpm_file            : string
        );
        port (
            address : in std_logic_vector(7 downto 0);
            q       : out std_logic_vector(31 downto 0)
        );
    end component;

begin

    rom_inst : lpm_rom
        generic map (
            lpm_width           => 32,
            lpm_widthad         => 8,
            lpm_numwords        => 256,
            lpm_address_control => "UNREGISTERED", -- async address input
            lpm_outdata         => "UNREGISTERED", -- async output
            lpm_file            => "instr_mem.mif"
        )
        port map (
            address => address,
            q       => q
        );

end architecture;
