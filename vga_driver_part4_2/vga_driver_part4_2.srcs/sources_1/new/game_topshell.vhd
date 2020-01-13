----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/30/2019 04:24:53 PM
-- Design Name: 
-- Module Name: game_topshell - Behavioral
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity game_topshell is
Port ( 
           mclk: in std_logic;
           --Buttons
           reset: in std_logic;
           btnl: in std_logic;
           btnu: in std_logic;
           btnd: in std_logic;
           btnr: in std_logic;
           btnc: in std_logic;
           write_en: out std_logic;
           write_addr: out std_logic;
           write_data: out std_logic;
           --VGA 
           color: out std_logic_vector(11 downto 0);
           Hsync : out  STD_LOGIC := '1';
           Vsync : out  STD_LOGIC := '1');
           --Game Controller
end game_topshell;

architecture Behavioral of game_topshell is

component vga_driver_part3_1 is
port (     clk: in std_logic;
           color: out std_logic_vector(11 downto 0);
           Hsync : out  STD_LOGIC := '1';
           Vsync : out  STD_LOGIC := '1');
end component;

component 
begin


end Behavioral;
