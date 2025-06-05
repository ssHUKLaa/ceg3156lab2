--------------------------------------------------------------------------------
-- Title         : Enabled Asynchronous Reset D Flip-Flop - 1st realization
-- Project       : VHDL Synthesis Overview
-------------------------------------------------------------------------------
-- File          : enARdFF_2.vhd
-- Author        : Rami Abielmona  <rabielmo@site.uottawa.ca>
-- Created       : 2003/05/17
-- Last modified : 2007/09/25
-------------------------------------------------------------------------------
-- Description : This file creates an enabled asynchronous reset D flip-flop 
--		 as defined in the VHDL Synthesis lecture.  The architecture is 
--		 done at the RTL abstraction level and the implementation is done 
--		 in structural VHDL.
-------------------------------------------------------------------------------
-- Modification history :
-- 2003.05.17 	R. Abielmona		Creation
-- 2004.09.22 	R. Abielmona		Ported for CEG 3550
-- 2007.09.25 	R. Abielmona		Modified copyright notice
-------------------------------------------------------------------------------
-- This file is copyright material of Rami Abielmona, Ph.D., P.Eng., Chief Research
-- Scientist at Larus Technologies.  Permission to make digital or hard copies of part
-- or all of this work for personal or classroom use is granted without fee
-- provided that copies are not made or distributed for profit or commercial
-- advantage and that copies bear this notice and the full citation of this work.
-- Prior permission is required to copy, republish, redistribute or post this work.
-- This notice is adapted from the ACM copyright notice.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY enARdFF_2 IS
	PORT(
		i_resetBar	: IN	STD_LOGIC;
		i_d		: IN	STD_LOGIC;
		i_enable	: IN	STD_LOGIC;
		i_clock		: IN	STD_LOGIC;
		o_q, o_qBar	: OUT	STD_LOGIC);
END enARdFF_2;

ARCHITECTURE rtl OF enARdFF_2 IS
	SIGNAL int_q : STD_LOGIC;

BEGIN

oneBitRegister:
PROCESS(i_resetBar, i_clock)
BEGIN
	IF (i_resetBar = '0') THEN
		int_q	<= '0';
	ELSIF (i_clock'EVENT and i_clock = '1') THEN
		IF (i_enable = '1') THEN
			int_q	<=	i_d;
		END IF;
	END IF;
END PROCESS oneBitRegister;

	--  Output Driver

	o_q		<=	int_q;
	o_qBar		<=	not(int_q);

END rtl;
