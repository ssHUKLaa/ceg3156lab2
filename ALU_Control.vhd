library ieee;
use ieee.std_logic_1164.all;

entity ALU_Control is
    port (
        ALUOP : IN std_logic_vector(1 downto 0);
        funct : IN std_logic_vector(5 downto 0);
        Opr : OUT std_logic_vector(2 downto 0)
    );
end ALU_Control;

architecture struct of ALU_Control IS
    
begin
    Opr(2) <= ALUOP(0) OR (funct(1) AND ALUOP(1));
    Opr(1) <= NOT ALUOP(1) OR NOT funct(2);
    Opr(0) <= ALUOP(1) AND (funct(3) or funct(0));
end struct;