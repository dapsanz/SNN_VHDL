----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/25/2026 05:03:21 PM
-- Design Name: 
-- Module Name: decoder - Behavioral
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

entity decoder is
  generic (
        w : integer := 4

  );
  Port (
        a: in std_logic_vector(w-1 downto 0);
        y: out std_logic_vector((2**w)-1 downto 0);
        en: in std_logic
        );
end decoder;

architecture Behavioral of decoder is

begin

    process(a, en)
    begin
        y <= (others => '0');
        if en = '1' then
            y(to_integer(unsigned(a))) <= '1';
        end if;
    end process;

end Behavioral;