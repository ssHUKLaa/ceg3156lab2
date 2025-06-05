LIBRARY ieee;
use IEEE.STD_LOGIC_1164.ALL;

entity CLA_8bit IS
	PORT (
		a,b : IN STD_LOGIC_VECTOR(7 downto 0);
		cin : IN STD_LOGIC;
		Sum : OUT STD_LOGIC_VECTOR(7 downto 0);
		CarryOut, zeroOut, OverFlowOut : OUT STD_LOGIC
	);
end CLA_8bit;

architecture basic of CLA_8bit IS

	 
	signal transitoryG : STD_LOGIC_VECTOR(7 downto 0);
	signal transitoryP : STD_LOGIC_VECTOR(7 downto 0);
	signal transitoryC : STD_LOGIC_VECTOR(7 downto 0);
	signal transitorySignal, check_if_zero : STD_LOGIC_VECTOR(7 downto 0);

	
begin
	transitoryG(0) <= a(0) AND b(0);
	transitoryP(0) <= a(0) OR b(0);
	transitoryC(0) <= transitoryG(0) OR (transitoryP(0) AND Cin);
	transitorySignal(0) <= (a(0) XOR b(0)) XOR cin;
	
	transitoryG(1) <= a(1) AND b(1);
	transitoryP(1) <= a(1) OR b(1);
	transitoryC(1) <= transitoryG(0) OR (transitoryP(0) AND transitoryC(0));
	transitorySignal(1) <= (a(1) XOR b(1)) XOR transitoryC(1);
	
	transitoryG(2) <= a(2) AND b(2);
	transitoryP(2) <= a(2) OR b(2);
	transitoryC(2) <= transitoryG(1) OR (transitoryP(1) AND transitoryC(1));
	transitorySignal(2) <= (a(2) XOR b(2)) XOR transitoryC(2);
	
	transitoryG(3) <= a(3) AND b(3);
	transitoryP(3) <= a(3) OR b(3);
	transitoryC(3) <= transitoryG(2) OR (transitoryP(2) AND transitoryC(2));
	transitorySignal(3) <= (a(3) XOR b(3)) XOR transitoryC(3);
	
	transitoryG(4) <= a(4) AND b(4);
	transitoryP(4) <= a(4) OR b(4);
	transitoryC(4) <= transitoryG(3) OR (transitoryP(3) AND transitoryC(3));
	transitorySignal(4) <= (a(4) XOR b(4)) XOR transitoryC(4);
	
	transitoryG(5) <= a(5) AND b(5);
	transitoryP(5) <= a(5) OR b(5);
	transitoryC(5) <= transitoryG(4) OR (transitoryP(4) AND transitoryC(4));
	transitorySignal(5) <= (a(5) XOR b(5)) XOR transitoryC(5);
	
	transitoryG(6) <= a(6) AND b(6);
	transitoryP(6) <= a(6) OR b(6);
	transitoryC(6) <= transitoryG(5) OR (transitoryP(5) AND transitoryC(5));
	transitorySignal(6) <= (a(6) XOR b(6)) XOR transitoryC(6);
	
	transitoryG(7) <= a(7) AND b(7);
	transitoryP(7) <= a(7) OR b(7);
	transitoryC(7) <= transitoryG(6) OR (transitoryP(6) AND transitoryC(6));
	transitorySignal(7) <= (a(7) XOR b(7)) XOR transitoryC(7);

	CarryOut <= transitoryG(7) OR (transitoryP(7) AND transitoryC(7));
	OverFlowOut <= (a(7) AND b(7)) XOR (transitorySignal(7));
	
	check_if_zero <= NOT transitorySignal;
	zeroOut <= check_if_zero(0) AND check_if_zero(1) AND check_if_zero(2) AND check_if_zero(3) AND check_if_zero(4) AND check_if_zero(5) AND check_if_zero(6) AND check_if_zero(7);
	
	Sum <= transitorySignal;

end basic;