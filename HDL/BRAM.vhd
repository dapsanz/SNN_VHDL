----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Diego Perez Sanchez
-- 
-- Create Date: 02/27/2026 01:06:42 PM
-- Design Name: 
-- Module Name: BRAM - Behavioral
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

entity BRAM is
  Generic(
        k : integer := 10; -- address bits
        w : integer := 8 -- data bits
  );
  Port(
        clk : in  std_logic;
        we  : in  std_logic;
        addr: in  std_logic_vector(k-1 downto 0);
        din : in  std_logic_vector(w-1 downto 0);
        dout: out std_logic_vector(w-1 downto 0)
        );
end BRAM;

architecture Behavioral of BRAM is

type RAM is array (0 to (2**k)-1) of std_logic_vector(w-1 downto 0);
signal RAM_SIGNAL:RAM; 
begin
    process(clk)
    begin  
        if(rising_edge(clk)) then
            if(we = '1') then 
                    RAM_SIGNAL(TO_INTEGER(unsigned(addr))) <= din;
                end if;    
            dout <= RAM_SIGNAL(TO_INTEGER(unsigned(addr)));
            end if;
        
    end process;
   
end Behavioral;