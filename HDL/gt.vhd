----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2026 04:45:09 PM
-- Design Name: 
-- Module Name: gt - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gt is
    Port ( dataA : in std_logic_vector(4 downto 0);
           addrA : in std_logic_vector(3 downto 0);
           dataB : in std_logic_vector(4 downto 0);
           addrB : std_logic_vector(3 downto 0);
           dataGT : out std_logic_vector(4 downto 0);
           addrGT : out std_logic_vector(3 downto 0)
           );
end gt;

architecture Behavioral of gt is

begin

process(dataA,dataB)
begin
    if(unsigned(dataA)>= unsigned(dataB)) then
        dataGT <= dataA;
        addrGT <= addrA;
    else
        dataGT <= dataB;
        addrGT <= addrB;
    end if;
end process;


end Behavioral;
