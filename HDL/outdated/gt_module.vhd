----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2026 10:43:01 PM
-- Design Name: 
-- Module Name: gt_module - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gt_module is
  Port (
        clk : in std_logic;
        rst : in std_logic;
        d0: in std_logic_vector(4 downto 0);
        d1: in std_logic_vector(4 downto 0);
        d2: in std_logic_vector(4 downto 0);
        d3: in std_logic_vector(4 downto 0);
        d4: in std_logic_vector(4 downto 0);
        d5: in std_logic_vector(4 downto 0);
        d6: in std_logic_vector(4 downto 0);
        d7: in std_logic_vector(4 downto 0);
        d8: in std_logic_vector(4 downto 0);
        d9: in std_logic_vector(4 downto 0);
        gt: out std_logic_vector(3 downto 0)
        
   );
end gt_module;

architecture Behavioral of gt_module is

signal addrGT_A, addrGT_A_reg : std_logic_vector(3 downto 0); 
signal dataGT_A, dataGT_A_reg : std_logic_vector(4 downto 0);
signal addrGT_B, addrGT_B_reg : std_logic_vector(3 downto 0); 
signal dataGT_B, dataGT_B_reg : std_logic_vector(4 downto 0);  
signal addrGT_C, addrGT_C_reg : std_logic_vector(3 downto 0); 
signal dataGT_C, dataGT_C_reg : std_logic_vector(4 downto 0);
signal addrGT_D, addrGT_D_reg : std_logic_vector(3 downto 0); 
signal dataGT_D, dataGT_D_reg : std_logic_vector(4 downto 0);
signal addrGT_E, addrGT_E_reg1, addrGT_E_reg2, addrGT_E_reg3 : std_logic_vector(3 downto 0); 
signal dataGT_E, dataGT_E_reg1, dataGT_E_reg2, dataGT_E_reg3 : std_logic_vector(4 downto 0);

signal addrGT_AB, addrGT_AB_reg : std_logic_vector(3 downto 0); 
signal dataGT_AB, dataGT_AB_reg : std_logic_vector(4 downto 0);
signal addrGT_CD, addrGT_CD_reg : std_logic_vector(3 downto 0); 
signal dataGT_CD, dataGT_CD_reg : std_logic_vector(4 downto 0);

signal addrGT_ABCD, addrGT_ABCD_reg : std_logic_vector(3 downto 0); 
signal dataGT_ABCD, dataGT_ABCD_reg : std_logic_vector(4 downto 0);

begin

u_gtA: entity work.gt port map(dataA => d0, addrA => "0000", dataB => d1, addrB => "0001", addrGT => addrGT_A, dataGT => dataGT_A);
u_gtB: entity work.gt port map(dataA => d2, addrA => "0010", dataB => d3, addrB => "0011", addrGT => addrGT_B, dataGT => dataGT_B);
u_gtC: entity work.gt port map(dataA => d4, addrA => "0100", dataB => d5, addrB => "0101", addrGT => addrGT_C, dataGT => dataGT_C);
u_gtD: entity work.gt port map(dataA => d6, addrA => "0110", dataB => d7, addrB => "0111", addrGT => addrGT_D, dataGT => dataGT_D);
u_gtE: entity work.gt port map(dataA => d8, addrA => "1000", dataB => d9, addrB => "1001", addrGT => addrGT_E, dataGT => dataGT_E);

reg_s1_A_addr: entity work.reg generic map(w => 4) port map(clk => clk, rst => rst, en => '1', d => addrGT_A, q => addrGT_A_reg);
reg_s1_A_data: entity work.reg generic map(w => 5) port map(clk => clk, rst => rst, en => '1', d => dataGT_A, q => dataGT_A_reg);
reg_s1_B_addr: entity work.reg generic map(w => 4) port map(clk => clk, rst => rst, en => '1', d => addrGT_B, q => addrGT_B_reg);
reg_s1_B_data: entity work.reg generic map(w => 5) port map(clk => clk, rst => rst, en => '1', d => dataGT_B, q => dataGT_B_reg);
reg_s1_C_addr: entity work.reg generic map(w => 4) port map(clk => clk, rst => rst, en => '1', d => addrGT_C, q => addrGT_C_reg);
reg_s1_C_data: entity work.reg generic map(w => 5) port map(clk => clk, rst => rst, en => '1', d => dataGT_C, q => dataGT_C_reg);
reg_s1_D_addr: entity work.reg generic map(w => 4) port map(clk => clk, rst => rst, en => '1', d => addrGT_D, q => addrGT_D_reg);
reg_s1_D_data: entity work.reg generic map(w => 5) port map(clk => clk, rst => rst, en => '1', d => dataGT_D, q => dataGT_D_reg);
reg_s1_E_addr: entity work.reg generic map(w => 4) port map(clk => clk, rst => rst, en => '1', d => addrGT_E, q => addrGT_E_reg1);
reg_s1_E_data: entity work.reg generic map(w => 5) port map(clk => clk, rst => rst, en => '1', d => dataGT_E, q => dataGT_E_reg1);

u_gtAB: entity work.gt port map(dataA => dataGT_A_reg, addrA => addrGT_A_reg, dataB => dataGT_B_reg, addrB => addrGT_B_reg, addrGT => addrGT_AB, dataGT => dataGT_AB);
u_gtCD: entity work.gt port map(dataA => dataGT_C_reg, addrA => addrGT_C_reg, dataB => dataGT_D_reg, addrB => addrGT_D_reg, addrGT => addrGT_CD, dataGT => dataGT_CD);

reg_s2_AB_addr: entity work.reg generic map(w => 4) port map(clk => clk, rst => rst, en => '1', d => addrGT_AB, q => addrGT_AB_reg);
reg_s2_AB_data: entity work.reg generic map(w => 5) port map(clk => clk, rst => rst, en => '1', d => dataGT_AB, q => dataGT_AB_reg);
reg_s2_CD_addr: entity work.reg generic map(w => 4) port map(clk => clk, rst => rst, en => '1', d => addrGT_CD, q => addrGT_CD_reg);
reg_s2_CD_data: entity work.reg generic map(w => 5) port map(clk => clk, rst => rst, en => '1', d => dataGT_CD, q => dataGT_CD_reg);
reg_s2_E_addr:  entity work.reg generic map(w => 4) port map(clk => clk, rst => rst, en => '1', d => addrGT_E_reg1, q => addrGT_E_reg2);
reg_s2_E_data:  entity work.reg generic map(w => 5) port map(clk => clk, rst => rst, en => '1', d => dataGT_E_reg1, q => dataGT_E_reg2);

u_gtABCD: entity work.gt port map(dataA => dataGT_AB_reg, addrA => addrGT_AB_reg, dataB => dataGT_CD_reg, addrB => addrGT_CD_reg, addrGT => addrGT_ABCD, dataGT => dataGT_ABCD);

reg_s3_ABCD_addr: entity work.reg generic map(w => 4) port map(clk => clk, rst => rst, en => '1', d => addrGT_ABCD, q => addrGT_ABCD_reg);
reg_s3_ABCD_data: entity work.reg generic map(w => 5) port map(clk => clk, rst => rst, en => '1', d => dataGT_ABCD, q => dataGT_ABCD_reg);
reg_s3_E_addr:    entity work.reg generic map(w => 4) port map(clk => clk, rst => rst, en => '1', d => addrGT_E_reg2, q => addrGT_E_reg3);
reg_s3_E_data:    entity work.reg generic map(w => 5) port map(clk => clk, rst => rst, en => '1', d => dataGT_E_reg2, q => dataGT_E_reg3);

u_gtABCDE: entity work.gt port map(dataA => dataGT_ABCD_reg, addrA => addrGT_ABCD_reg, dataB => dataGT_E_reg3, addrB => addrGT_E_reg3, addrGT => gt, dataGT => open);

end Behavioral;
