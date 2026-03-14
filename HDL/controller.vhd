----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2026 10:42:08 PM
-- Design Name: 
-- Module Name: controller - Behavioral
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

entity controller is
  Port (    
        clk: in std_logic;
        rst: in std_logic;
        
        leak   : out std_logic;           
        spikegen_go : out std_logic;
        fifo_rd : out std_logic;  
        --- RAM WE ---
        hidden_weights_we : out std_logic;
        hidden_neurons_we : out std_logic;
        image_we : out std_logic;       
        en_cd0   : out std_logic;
        en_cd1   : out std_logic; 
        en_cd2   : out std_logic;        
        en_cd3   : out std_logic;        
        en_cd4   : out std_logic;        
        en_cd5   : out std_logic;        
        en_cd6   : out std_logic;        
        en_cd7   : out std_logic;        
        en_cd8   : out std_logic;        
        en_cd9   : out std_logic;
        ------ Output Flags ------ 
        fifo_full: in std_logic;
        fifo_empty: in std_logic;
        neuron_spike   : in std_logic   
  
   );
end controller;

architecture Behavioral of controller is
    signal dummy_counter : unsigned(3 downto 0) := (others => '0');
begin

process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            dummy_counter <= (others => '0');
            
            leak              <= '0';
            spikegen_go       <= '0';
            fifo_rd           <= '0';
            hidden_weights_we <= '0';
            hidden_neurons_we <= '0';
            image_we          <= '0';
            
            -- Reset all enables
            en_cd0 <= '0'; en_cd1 <= '0'; en_cd2 <= '0'; en_cd3 <= '0'; 
            en_cd4 <= '0'; en_cd5 <= '0'; en_cd6 <= '0'; en_cd7 <= '0'; 
            en_cd8 <= '0'; en_cd9 <= '0';
        else
            dummy_counter <= dummy_counter + 1;

            -- Control signals logic
            leak        <= fifo_full and dummy_counter(0);
            spikegen_go <= not fifo_empty;
            fifo_rd     <= neuron_spike and dummy_counter(1);
            hidden_weights_we <= dummy_counter(2);
            hidden_neurons_we <= dummy_counter(3);
            image_we          <= dummy_counter(0) xor dummy_counter(3);

            -- Default all to '0' first, then set the active one
            en_cd0 <= '0'; en_cd1 <= '0'; en_cd2 <= '0'; en_cd3 <= '0'; 
            en_cd4 <= '0'; en_cd5 <= '0'; en_cd6 <= '0'; en_cd7 <= '0'; 
            en_cd8 <= '0'; en_cd9 <= '0';

            case dummy_counter is
                when "0000" => en_cd0 <= '1';
                when "0001" => en_cd1 <= '1';
                when "0010" => en_cd2 <= '1';
                when "0011" => en_cd3 <= '1';
                when "0100" => en_cd4 <= '1';
                when "0101" => en_cd5 <= '1';
                when "0110" => en_cd6 <= '1';
                when "0111" => en_cd7 <= '1';
                when "1000" => en_cd8 <= '1';
                when "1001" => en_cd9 <= '1';
                when others => null; -- Keeps them all '0' for 10-15
            end case;
        end if;
    end if;
end process;

end Behavioral;