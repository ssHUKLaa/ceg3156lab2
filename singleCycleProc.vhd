LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY singleCycleProc IS
	PORT (
		ValueSelect : IN STD_LOGIC_VECTOR(2 downto 0);
		GClock : IN STD_LOGIC;
		GReset : IN STD_LOGIC;
		MuxOut : OUT STD_LOGIC_VECTOR(7 downto 0);
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
		PORT
		(
			aclr		: IN STD_LOGIC  := '0';
			address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
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
	
	SIGNAL trans_writereg : std_logic_vector(3 downto 0);
	SIGNAL mux1BranchSum, branchSum, PC_SIG, newPCval, incPC, jumpaddr, shinstadr, transMuxOut, transMemRead, ALUResult, instruction_Signal, regData1, regData2, sngextendaddr, ALUBIn : std_logic_vector(31 downto 0);
	SIGNAL ZeroRes : std_logic;
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
	  aclr    => '0',
	  address => PC_SIG(7 downto 0),
	  clock   => GClock,
	  q       => instruction_Signal
	);

	mux_2to1_4bit_inst: entity work.mux_2to1_4bit
	port map (
	  sel   => instruction_Signal, --test
	  d_in1 => instruction_Signal(20 downto 16),
	  d_in2 => instruction_Signal(15 downto 11),
	  d_out => trans_writereg
	);

	reg_file_inst: entity work.reg_file
	port map (
	  clk        => GClock,
	  resetBar   => GReset,
	  reg_write  => test,
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
	  sel   => test,
	  d_in1 => regData2,
	  d_in2 => sngextendaddr,
	  d_out => ALUBIn
	);

	alu_32bit_inst: entity work.ALU_32bit
	port map (
	  A       => regData1,
	  B       => ALUBIn,
	  sel     => test,
	  ALU_res => ALUResult,
	  Zero    => ZeroRes
	);

	data_ram_inst: entity work.data_ram
	port map (
	  aclr    => '0',
	  address => ALUResult(7 downto 0),
	  clock   => GClock,
	  data    => regData2,
	  rden    => test,
	  wren    => test,
	  q       => transMemRead
	);

	mux_2to1_32bit_inst_2: entity work.mux_2to1_32bit
	port map (
	  sel   => test,
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
	  CarryOut    => '0',
	  zeroOut     => open,
	  OverFlowOut => open
	);


	mux_2to1_32bit_inst_3: entity work.mux_2to1_32bit
	port map (
	  sel   => test,
	  d_in1 => incPC,
	  d_in2 => branchSum,
	  d_out => mux1BranchSum
	);

	jumpaddr <= incPC(31 downto 28) & (instruction_Signal(25 downto 0) & "00");


	mux_2to1_32bit_inst_4: entity work.mux_2to1_32bit
	port map (
	  sel   => test,
	  d_in1 => mux1BranchSum,
	  d_in2 => jumpaddr,
	  d_out => newPCval
	);



	
end basic;