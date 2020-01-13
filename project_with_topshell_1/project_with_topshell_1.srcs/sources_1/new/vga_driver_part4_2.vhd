library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
library UNISIM;						-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;

entity vga_driver_part4_2 is
    Port ( clk : in  STD_LOGIC;
           doutb1: in std_logic_vector(1 downto 0);
           RAMaddress: out std_logic_vector(10 downto 0);
           --row: in std_logic_vector(9 downto 0);
           --column: in std_logic_vector(9 downto 0);
           color: out std_logic_vector(11 downto 0);
           Hsync : out  STD_LOGIC := '1';
           Vsync : out  STD_LOGIC := '1'
           );
end vga_driver_part4_2;



architecture Behavioral of vga_driver_part4_2 is
constant YELLOW  : std_logic_vector(11 downto 0) := "111111110000";
constant WHITE         : std_logic_vector(11 downto 0) := "111111111111";
constant BLACK         : std_logic_vector(11 downto 0) := "000000000000";



signal HDISP : integer := 639;
signal HFPorch : integer := 16;
signal HSyncPulse : integer := 96;
signal HBPorch : integer := 48;

signal VDISP : integer := 479;
signal VFPorch : integer := 10; 
signal VSyncPulse: integer := 2;
signal VBPorch : integer := 29;

signal posH : integer := 0;
signal posV : integer := 0;

--signal temp : std_logic := '0';
signal count : integer := 1;

signal VidToggle : std_logic := '0';

signal clk25: std_logic := '0';
signal clk25_unbuf: std_logic := '0';

--signal blockaddressH: std_logic_vector(9 downto 0);
--signal blockaddressV: std_logic_vector(8 downto 0);
--signal blockaddress: std_logic_vector(15 downto 0);
signal temp_address: std_logic_vector(10 downto 0);
--signal temp_mem_address: std_logic_vector(10 downto 0);
signal counterX: unsigned(9 downto 0) := "0000000000";
signal counterY: unsigned(8 downto 0) := "000000000";
--signal counter3: unsigned(3 downto 0) := "0000";

--signal vsynctemp, hsynctemp: std_logic := '0';

--signal doutb: std_logic_vector (1 downto 0);
--signal column: std_logic_vector(9 downto 0);
--signal row: std_logic_vector(8 downto 0);
begin

--column <= std_logic_vector(counterX);
--row <= std_logic_vector(counterY);
---- set the colors based on the current pixel
--process(row, column)
--begin
---- large vertical color bands, evenly spaced horizontally, 320px vertically
---- Gray, yellow, cyan, green, purple, red, blue
--if (column >= 0) and (column < 92) and (row >= 0) and (row < 320) then
--color <= GRAY1;
--elsif (column >= 92) and (column < 184) and (row >= 0) and (row < 320) then
--color <= YELLOW;
--elsif (column >= 184) and (column < 276) and (row >= 0) and (row < 320) then
--color <= CYAN;
--elsif (column >= 276) and (column < 368) and (row >= 0) and (row < 320) then
--color <= GREEN;
--elsif (column >= 368) and (column < 460) and (row >= 0) and (row < 320) then
--color <= PURPLE;
--elsif (column >= 460) and (column < 552) and (row >= 0) and (row < 320) then
--color <= RED;
--elsif (column >= 552) and (column <= 640) and (row >= 0) and (row < 320) then
--color <= BLUE;
---- small colored rectangles from 320->360 pixels, evenly spaced horizontally-- blue, black, purple, black, cyan, black, gray
--elsif (column >= 0) and (column < 92) and (row >= 320) and (row < 360) then
--color <= BLUE;
--elsif (column >= 92) and (column < 184) and (row >= 320) and (row < 360) then
--color <= BLACK;
--elsif (column >= 184) and (column < 276) and (row >= 320) and (row < 360) then
--color <= PURPLE;
--elsif (column >= 276) and (column < 368) and (row >= 320) and (row < 360) then
--color <= BLACK;
--elsif (column >= 368) and (column < 460) and (row >= 320) and (row < 360) then
--color <= CYAN;
--elsif (column >= 460) and (column < 552) and (row >= 320) and (row < 360) then
--color <= BLACK;
--elsif (column >= 552) and (column <= 640) and (row >= 320) and (row < 360) then
--color <= GRAY1;
---- bottom large blocks
--elsif (column >= 0) and (column < 114) and (row >= 360) and (row <= 480) then
--color <= DARK_BLU;
--elsif (column >=114) and (column < 228) and (row >= 360) and (row <= 480) then
--color <= WHITE;
--elsif (column >= 228) and (column < 342) and (row >= 360) and (row <= 480) then
--color <= DARK_PUR;
--elsif (column >= 342) and (column < 460) and (row >= 360) and (row <= 480) then
--color <= GRAY0;
--elsif (column >= 460) and (column < 491) and (row >= 360) and (row <= 480) then
--color <= BLACK;
--elsif (column >= 491) and (column < 521) and (row >= 360) and (row <= 480) then
--color <= GRAY0;
--elsif (column >= 521) and (column < 552) and (row >= 360) and (row <= 480) then
--color <= GRAY1;
--elsif (column >= 552) and (column <= 640) and (row >= 360) and (row <= 480) then
--color <= GRAY0;
---- black for any gaps, shouldn't be any
--else
--color <= BLACK;
--end if;
--end process;

HSync_proc : process(HDISP, HFPorch, HSyncPulse, HBPorch, posH, clk25)--took reset out
begin

     if (rising_edge(clk25)) then
    	if (posH >= (HDISP + HFPorch) and posH < (HDISP + HFPorch + HSyncPulse)) then
        	Hsync <= '0';
        else
        	Hsync <= '1';
        end if;
    end if;
end process;

VSync_proc : process(VDISP, VFPorch, VSyncPulse, VBPorch, posV, clk25)
begin
    
     if (rising_edge(clk25)) then
    	if (posV >= (VDISP + VFPorch) and posV < (VDISP + VFPorch + VSyncPulse)) then
        	Vsync <= '0';
        else
        	Vsync <= '1';
        end if;
    end if;
end process;

VidToggle_proc : process(VDISP, HDISP, posV, posH, clk25)
begin
    
    	if (posV <= VDISP and posH <= HDISP) then
        	VidToggle <= '1';
        else
        	VidToggle <= '0';
        end if;
end process;


posH_counter : process(clk25, posH)
begin
	
     if (rising_edge(clk25)) then
    	if (posH = (HDISP + HFPorch + HSyncPulse + HBPorch)) then
    		posH <= 0;
    	else 
    		posH <= posH + 1;
        end if;
    end if;
end process;

posV_counter : process(clk25, posH, posV)
begin
	
    if (rising_edge(clk25)) then
    	if (posH = (HDISP + HFPorch + HSyncPulse + HBPorch)) then
          if (posV = (VDISP + VFPorch + VSyncPulse + VBPorch)) then
              posV <= 0;
          else 
              posV <= posV + 1;
          end if;
        else
            posV <= posV;
   		end if;
    end if;
end process;

--blockaddressH <= std_logic_vector( to_unsigned(posH, 10));--address location for Horizontal Position
--blockaddressV <= std_logic_vector( to_unsigned(posV, 9));--address location for Vertical Position
--temp_address <= blockaddressH(9 downto 4) & blockaddressV(8 downto 4);--concatenate two address locations to create 16x16 bit blocks

clk_div: process (clk)
begin
if (rising_edge(clk)) then
	count <=count+1;
	if (count = 2) then
		clk25_unbuf <= NOT clk25_unbuf;
		count <= 1;
	end if;
end if;
end process;

Slow_clock_buffer: BUFG
	port map (I => clk25_unbuf,
		      O => clk25);

color_project_proc: process(clk25, doutb1)
begin
    if rising_edge(clk25) then
            case doutb1 is
                when "00" =>
                    color <= BLACK;
                when "11" =>
                    color <= YELLOW;
                when "01" =>
                    color <= WHITE;
                when others =>
                    color <= YELLOW;
            end case;
    end if;

end process;

counterMix_proc: process(clk25)
    begin
        if rising_edge(clk25) then
            if (VidToggle = '1') then
                counterX <= counterX + 1;
                if (counterX = "1001111111") then
                    counterY <= counterY + 1;
                    counterX <= "0000000000";
                	if (counterY = "111011111") then
                    	counterY <= "000000000";
                	end if;
            	end if;
            end if;
        end if;
end process;
RAMaddress <= std_logic_vector(counterX(9 downto 4)) & std_logic_vector(counterY(8 downto 4));
end architecture;
