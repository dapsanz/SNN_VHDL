----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2026 03:07:37 PM
-- Design Name: 
-- Module Name: counter - Behavioral
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

entity counter is
  Generic(
        w : integer := 32
  );
  
  Port ( 
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        Q: out std_logic_vector(w-1 downto 0)
  );
end counter;

architecture Behavioral of counter is

signal data: std_logic_vector(w-1 downto 0);
signal datap1: std_logic_vector(w-1 downto 0);

begin

datap1 <= std_logic_vector(unsigned(data) + 1);
dut: entity work.reg
    generic map(
        w => w
    )
    port map(
        clk => clk,
        D => datap1,
        en => en,
        rst => rst,
        Q => data
    );
Q <= data;
end Behavioral;
