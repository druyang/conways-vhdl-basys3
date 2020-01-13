library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;						-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;

entity vga_working is
    Port ( clk : in  STD_LOGIC;
           doutb1: in std_logic_vector(1 downto 0);--input from RAM with alive/dead and selected/unselected data
           reset : in std_logic := '0';--input from switch to change color
           color: out std_logic_vector(11 downto 0);--sends 12 bit color to VGA
           Hsync : out  STD_LOGIC := '1';--Horizontal sync sent to VGA
           Vsync : out  STD_LOGIC := '1';--Vertical sync sent to VGA
           RAMaddress: out std_logic_vector(10 downto 0)--Send address to read address of dual port RAM
           );
end vga_working;



architecture Behavioral of vga_working is
constant PINK  : std_logic_vector(11 downto 0) := "000011111111";
constant WHITE         : std_logic_vector(11 downto 0) := "111111111111";
constant BLACK         : std_logic_vector(11 downto 0) := "000000000000";


--standards for 640x480 @60Hz VGA display
signal HDISP : integer := 639;
signal HFPorch : integer := 16;
signal HSyncPulse : integer := 96;
signal HBPorch : integer := 48;

signal VDISP : integer := 479;
signal VFPorch : integer := 10; 
signal VSyncPulse: integer := 2;
signal VBPorch : integer := 29;

--position counters
signal posH : integer := 0;
signal posV : integer := 0;

signal count : integer := 1;

signal VidToggle : std_logic := '0';

signal clk25: std_logic := '0';
signal clk25_unbuf: std_logic := '0';

--pixel counters 
signal counterX: unsigned(9 downto 0) := "0000000000";
signal counterY: unsigned(8 downto 0) := "000000000";

begin

--This process manages the Horizontal Sync of the VGA driver
HSync_proc : process(HDISP, HFPorch, HSyncPulse, HBPorch, posH, clk25)
begin

     if (rising_edge(clk25)) then
    	if (posH >= (HDISP + HFPorch) and posH < (HDISP + HFPorch + HSyncPulse)) then
        	Hsync <= '0';--Sets Hsync low during the horizontal sync pulse
        else
        	Hsync <= '1';--Other than during the sync pulse, Hsync goes high
        end if;
    end if;
end process;

--This process manages the Vertical Sync of the VGA driver
VSync_proc : process(VDISP, VFPorch, VSyncPulse, VBPorch, posV, clk25)
begin
    
     if (rising_edge(clk25)) then
    	if (posV >= (VDISP + VFPorch) and posV < (VDISP + VFPorch + VSyncPulse)) then
        	Vsync <= '0';--Sets Vsync low during the vertical sync pulse
        else
        	Vsync <= '1';--Other than during the sync pulse, Vsync goes high
        end if;
    end if;
end process;

--This process determines whether the VGA driver in inside the display area or not
VidToggle_proc : process(VDISP, HDISP, posV, posH, clk25)
begin
    
    	if (posV <= VDISP and posH <= HDISP) then
        	VidToggle <= '1';--if both vertical and horizontal position are less than or equal to the count of display area, VidToggle goes high
        else
        	VidToggle <= '0';--if either position is outside the display area, VidToggle goes low
        end if;
end process;

--This process keeps track of the horizontal position of the VGA driver
posH_counter : process(clk25, posH)
begin
	
     if (rising_edge(clk25)) then--updates on rising edge of the clock
    	if (posH = (HDISP + HFPorch + HSyncPulse + HBPorch)) then--Resets horizontal position to 0 when VGA driver reaches end of each row
    		posH <= 0;
    	else 
    		posH <= posH + 1;--Anywhere other than the end of the row, the horizontal position gets updated by adding 1
        end if;
    end if;
end process;

--This process keeps track of the vertical position of the VGA driver
posV_counter : process(clk25, posH, posV)
begin
	
    if (rising_edge(clk25)) then--updates on rising edge of the clock
    	if (posH = (HDISP + HFPorch + HSyncPulse + HBPorch)) then--Horizontal position must be at the end of the current row
          if (posV = (VDISP + VFPorch + VSyncPulse + VBPorch)) then--Vertical position must be at the bottom of the screen
              posV <= 0;--Vertical position resets to 0 if the driver reaches the bottom right of VGA (including porches and sync pulses)
          else 
              posV <= posV + 1;--Anywhere but the very bottom, the vertical position updates as the driver reaches the end of each row
          end if;
        else
            posV <= posV;
   		end if;
    end if;
end process;

clk_div: process (clk)--divides 100MHz clock to 25MHz
begin
if (rising_edge(clk)) then
	count <=count+1;
	if (count = 2) then
		clk25_unbuf <= NOT clk25_unbuf;
		count <= 1;
	end if;
end if;
end process;

Slow_clock_buffer: BUFG--clock buffer for our divided 25MHz clock
	port map (I => clk25_unbuf,
		      O => clk25);

--Process to display and change color
color_project_proc: process(clk25, doutb1, reset)
begin
    if rising_edge(clk25) then
        if (VidToggle = '0') then--if VGA driver is outside display area, displays black
            color <= BLACK;
        else
            if (reset = '1') then--if switch V17 goes high, displays pink on selected block
            case doutb1(1) is--reads most significant bit of input data and determines which color to display
                when '0' =>--if bit reads 0, it is considered dead and displays black
                    color <= BLACK;
                when '1' =>--if bit reads 1, it is considered alive and displays pink
                    color <= PINK;
                when others =>--sets all other blocks to black
                    color <= BLACK;
            end case;
            else--if switch V17 goes low, displays white on selected block
            case doutb1(1) is--reads most significant bit of input data and determines which color to display
                when '0' =>--if bit reads 0, it is considered dead and displays black
                    color <= BLACK;
                when '1' =>--if bit reads 1, it is considered alive and displays white
                    color <= WHITE;
                when others =>
                    color <= BLACK;--sets all other blocks to black
            end case;
            end if;            
        end if;
    end if;

end process;

--counter process to keep track of pixel coordinates as VGA runs on 25MHz clock
counterMix_proc: process(clk25)
    begin
        if rising_edge(clk25) then
            if (VidToggle = '1') then--only enables counter when in display area
                counterX <= counterX + 1;--updates column counter
                if (counterX = "1001111111") then
                    counterY <= counterY + 1;--increases row counter at end of each row
                    counterX <= "0000000000";--resets column counter at end of each row
                	if (counterY = "111011111") then
                    	counterY <= "000000000";--resets row counter at bottom of screen
                	end if;
            	end if;
            end if;
        end if;
end process;
--outputs address to read from memory into dual port RAM
RAMaddress <= std_logic_vector(counterX(9 downto 4)) & std_logic_vector(counterY(8 downto 4));
end architecture;
