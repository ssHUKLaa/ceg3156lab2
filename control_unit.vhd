library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
	port(
		opcode		: in std_logic_vector(5 downto 0);
		RegDst		: out std_logic;
		ALUSrc		: out std_logic:
		MemtoReg		: out std_logic;
		RegWrite		: out std_logic;
		MemRead		: out std_logic;
		MemWrite		: out std_logic;
		Branch		: out std_logic
		ALUOp			: out std_logic_vector(1 downto 0);
	);
end control_unit;

architecture structural of control_unit is
	signal rType, lw, sw, beq	: std_logic;
	
begin
	-- Opcode decoders
	rType <= not opcode(5) and not opcode(4) and not opcode(3) and not opcode(2) and not opcode(1) and not opcode(0);
	lw <= opcode(5) and not opcode(4) and not opcode(3) and not opcode(2) and opcode(1) and opcode(0);
	sw <= opcode(5) and not opcode(4) and opcode(3) and not opcode(2) and opcode(1) and opcode(0);
	beq <= not opcode(5) and not opcode(4) and not opcode(3) and opcode(2) and not opcode(1) and not opcode(0);

	--  Control signal generation
	Reg 		<= rType;
	ALUSrc 	<= lw or sw;
	MemtoReg <= lw;
	RegWrite <= rType or lw;
	MemRead 	<= lw;
	MemWrite <= sw;
	Branch 	<= beq;
	
	-- ALUOp signal generation
	ALUOp(1) <= rType;
	ALUop(0) <= beq;
end structural;