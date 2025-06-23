LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY singleCycleProc IS
	PORT (
		ValueSelect : IN STD_LOGIC_VECTOR(2 downto 0);
		GClock : IN STD_LOGIC;
		GReset : IN STD_LOGIC;
		MuxOut : OUT STD_LOGIC_VECTOR(31 downto 0);
		InstructionOut : OUT STD_LOGIC_VECTOR(31 downto 0);
		BranchOut : OUT STD_LOGIC;
		ZeroOut : OUT STD_LOGIC;
		MemWriteOut : OUT STD_LOGIC;
		RegWriteOut : Out STD_LOGIC
	);
END singleCycleProc;

ARCHITECTURE basic of singleCycleProc IS 

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

   component instruction_rom IS
	   PORT (
		   address : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		   q       : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	   );
   END component;

	component CLA_8bit IS
		PORT (
			a,b : IN STD_LOGIC_VECTOR(7 downto 0);
			cin : IN STD_LOGIC;
			Sum : OUT STD_LOGIC_VECTOR(7 downto 0);
			CarryOut, zeroOut, OverFlowOut : OUT STD_LOGIC
		);
	end component;

	component reg_file is
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
	end component;

	component mux_2to1_4bit IS
		PORT(
			sel     : IN  STD_LOGIC;                             -- Select input
			d_in1   : IN  STD_LOGIC_VECTOR(3 downto 0);        -- 8-bit Data input 1
			d_in2   : IN  STD_LOGIC_VECTOR(3 downto 0);        -- 8-bit Data input 2                         -- Reset input
			d_out   : OUT STD_LOGIC_VECTOR(3 downto 0)          -- 8-bit Data output
		);
	END component;

	component ALU_32bit is
		PORT (
			A, B : IN std_logic_vector(31 downto 0);
			sel : IN std_logic_vector(2 downto 0);
			ALU_res : OUT std_logic_vector(31 downto 0);
			Zero : OUT std_logic
		);
	end component;

	component mux_2to1_32bit IS
		PORT(
			sel     : IN  STD_LOGIC;                              -- Select input
			d_in1   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);          -- 32-bit Data input 1
			d_in2   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);          -- 32-bit Data input 2
			d_out   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)           -- 32-bit Data output
		);
	END component;

	component control_unit is
		port(
			opcode		: in std_logic_vector(5 downto 0);
			RegDst		: out std_logic;
			ALUSrc		: out std_logic;
			MemtoReg		: out std_logic;
			RegWrite		: out std_logic;
			MemRead		: out std_logic;
			MemWrite		: out std_logic;
			Branch		: out std_logic;
			BNE : out std_logic;
			Jump : out std_logic;
			ALUOp			: out std_logic_vector(1 downto 0)
		);
	end component;

	component data_ram IS
		PORT (
			aclr    : IN STD_LOGIC := '0';
			address : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- 256 x 32-bit words
			clock   : IN STD_LOGIC := '1';
			data    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			rden    : IN STD_LOGIC := '1';
			wren    : IN STD_LOGIC;
			q       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END component;

	component mux_2to1_8bit IS
		PORT(
			sel     : IN  STD_LOGIC;                             -- Select input
			d_in1   : IN  STD_LOGIC_VECTOR(7 downto 0);        -- 8-bit Data input 1
			d_in2   : IN  STD_LOGIC_VECTOR(7 downto 0);        -- 8-bit Data input 2                         -- Reset input
			d_out   : OUT STD_LOGIC_VECTOR(7 downto 0)          -- 8-bit Data output
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

	component mux_8to1_8bit IS
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
	END component;

	component mux_2to1_5bit IS
		PORT(
			sel     : IN  STD_LOGIC;                              -- Select input
			d_in1   : IN  STD_LOGIC_VECTOR(4 downto 0);           -- 5-bit Data input 1
			d_in2   : IN  STD_LOGIC_VECTOR(4 downto 0);           -- 5-bit Data input 2
			d_out   : OUT STD_LOGIC_VECTOR(4 downto 0)            -- 5-bit Data output
		);
	END component;

	component ALU_Control is
		port (
			ALUOP : IN std_logic_vector(1 downto 0);
			funct : IN std_logic_vector(5 downto 0);
			Opr : OUT std_logic_vector(2 downto 0)
		);
	end component;

	
	SIGNAL ALUOp : std_logic_vector(1 downto 0);
	SIGNAL Opr : std_logic_vector(2 downto 0);
	SIGNAL trans_writereg : std_logic_vector(4 downto 0);
	SIGNAL mux1BranchSum, branchSum, PC_SIG, newPCval, incPC, jumpaddr, shinstadr, transMuxOut, transMemRead, ALUResult, instruction_Signal, regData1, regData2, sngextendaddr, ALUBIn, otherValues : std_logic_vector(31 downto 0);
	SIGNAL tempSelbranch, ZeroRes, RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, BNE, Jump : std_logic;
BEGIN

	inc_pc: entity work.CLA_32bit
	port map (
	  a           => PC_SIG,
	  b           => "00000000000000000000000000000100",
	  cin         => '0',
	  Sum         => incPC,
	  CarryOut    => open,
	  zeroOut     => open,
	  OverFlowOut => open
	);

	GEN_PC: FOR i IN 0 TO 31 GENERATE
		enardff_2_inst: entity work.enARdFF_2
		port map (
		  i_resetBar => GReset,
		  i_d        => newPCval(i),
		  i_enable   => '1',
		  i_clock    => GClock,
		  o_q        => PC_SIG(i),
		  o_qBar     => open
		);
	end generate;

	instruction_rom_inst: entity work.instruction_rom
	port map (

	  address => PC_SIG(9 downto 2),
	  q       => instruction_Signal
	);

	control_unit_inst: entity work.control_unit
	port map (
	  opcode   => instruction_Signal(31 downto 26),
	  RegDst   => RegDst,
	  ALUSrc   => ALUSrc,
	  MemtoReg => MemtoReg,
	  RegWrite => RegWrite,
	  MemRead  => MemRead,
	  MemWrite => MemWrite,
	  Branch   => Branch,
	  BNE      => BNE,
	  Jump     => Jump,
	  ALUOp    => ALUOp
	);

	

	mux_2to1_5bit_inst: entity work.mux_2to1_5bit
	port map (
	  sel   => RegDst, --test
	  d_in1 => instruction_Signal(20 downto 16),
	  d_in2 => instruction_Signal(15 downto 11),
	  d_out => trans_writereg
	);

	reg_file_inst: entity work.reg_file
	port map (
	  clk        => GClock,
	  resetBar   => GReset,
	  reg_write  => RegWrite,
	  read_reg1  => instruction_Signal(25 downto 21),
	  read_reg2  => instruction_Signal(20 downto 16),
	  write_reg  => trans_writereg,
	  write_data => transMuxOut,
	  read_data1 => regData1,
	  read_data2 => regData2
	);

	sngextendaddr <= (15 DOWNTO 0 => instruction_Signal(15)) & instruction_Signal(15 downto 0);

	mux_2to1_32bit_inst: mux_2to1_32bit
	port map (
	  sel   => ALUSrc,
	  d_in1 => regData2,
	  d_in2 => sngextendaddr,
	  d_out => ALUBIn
	);

	alu_control_inst: entity work.ALU_Control
	port map (
	  ALUOP => ALUOP,
	  funct => instruction_Signal(5 downto 0),
	  Opr   => Opr
	);

	alu_32bit_inst: entity work.ALU_32bit
	port map (
	  A       => regData1,
	  B       => ALUBIn,
	  sel     => Opr,
	  ALU_res => ALUResult,
	  Zero    => ZeroRes
	);

	data_ram_inst: entity work.data_ram
	port map (
	  aclr    => '0',
	  address => ALUResult(9 downto 2),
	  clock   => GClock,
	  data    => regData2,
	  rden    => MemRead,
	  wren    => MemWrite,
	  q       => transMemRead
	);

	mux_2to1_32bit_inst_2: entity work.mux_2to1_32bit
	port map (
	  sel   => MemtoReg,
	  d_in1 => ALUResult,
	  d_in2 => transMemRead,
	  d_out => transMuxOut
	);


	shinstadr <= sngextendaddr(29 downto 0) & "00";

	add_addrs: entity work.CLA_32bit
	port map (
	  a           => incPC,
	  b           => shinstadr,
	  cin         => '0',
	  Sum         => branchSum,
	  CarryOut    => open,
	  zeroOut     => open,
	  OverFlowOut => open
	);

	tempSelbranch <= (ZeroRes and Branch) or (NOT ZeroRes and BNE);

	mux_2to1_32bit_inst_3: entity work.mux_2to1_32bit
	port map (
	  sel   => tempSelbranch,
	  d_in1 => incPC,
	  d_in2 => branchSum,
	  d_out => mux1BranchSum
	);

	jumpaddr <= incPC(31 downto 28) & (instruction_Signal(25 downto 0) & "00");


	mux_2to1_32bit_inst_4: entity work.mux_2to1_32bit
	port map (
	  sel   => Jump,
	  d_in1 => mux1BranchSum,
	  d_in2 => jumpaddr,
	  d_out => newPCval
	);

	BranchOut <= tempSelbranch;
	ZeroOut <= ZeroRes;
	MemWriteOut <= MemWrite;
	RegWriteOut <= RegWrite;
	otherValues <= "0000000000000000000000000" & RegDst & Jump & MemRead & MemtoReg & ALUOp & ALUSrc;

	mux_8to1_32bit_inst: entity work.mux_8to1_32bit
	port map (
	  sel   => ValueSelect,
	  d_in0 => PC_SIG,
	  d_in1 => ALUResult,
	  d_in2 => regData1,
	  d_in3 => regData2,
	  d_in4 => transMuxOut,
	  d_in5 => otherValues,
	  d_in6 => otherValues,
	  d_in7 => otherValues,
	  d_out => MuxOut
	);
	InstructionOut <=instruction_Signal;
	
end basic;