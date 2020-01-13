----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/30/2019 12:54:29 PM
-- Design Name: 
-- Module Name: button_control_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
use IEEE.NUMERIC_STD.ALL;

entity button_control_tb is
end button_control_tb; 

architecture tb of button_control_tb is 

component button_control is 
	port(clk : in std_logic; 
		reset : in std_logic; 
		btnl : in std_logic; 
		btnu : in std_logic; 
		btnd : in std_logic; 
		btnr : in std_logic; 
		btnc : in std_logic; 
        write_en : out std_logic;
        write_data : out std_logic_vector(1 downto 0); 
         write_addr : out std_logic_vector(10 downto 0)
        );

end component; 

signal clk, reset : std_logic := '0'; 
signal btnl, btnu, btnd, btnr, btnc, write_en  : std_logic := '0'; 
signal write_addr : std_logic_vector(10 downto 0) := (others => '0'); 
signal write_data : std_logic_vector(1 downto 0) := "00"; 
constant clk_period: time := 100ns;

begin

	UUT : button_control port map (
		clk => clk, reset => reset, btnl => btnl, btnu => btnu, btnd => btnd, btnr => btnr, btnc => btnc, write_en => write_en, write_addr => write_addr, write_data => write_data
		);

	tb1 : process 
	begin
		wait for 500 ns;
		-- test left movement and movement past screen 
		btnl <= '1';
		wait for 500 ns; 
		btnl <= '0';
		wait for 500 ns;
		btnl <= '1';
		wait for 500 ns; 
		btnl <= '0';
		wait for 500 ns;

		-- test down movement 
		btnd <= '1';
		wait for 500 ns; 
		btnd <= '0';
		wait for 500 ns;

		-- test up movement 
		btnu <= '1';
		wait for 500 ns; 
		btnu <= '0';
		wait for 500 ns;
		btnu <= '1';
		wait for 500 ns; 
		btnu <= '0';
		wait for 500 ns;

		-- test center button functionality 
		btnc <= '1';
		wait for 500 ns; 
		btnc <= '0';
		wait for 500 ns;

	end process;

clock_proc: process
begin
	clk <= not(clk);
    wait for clk_period/2;
end process clock_proc;

end tb;