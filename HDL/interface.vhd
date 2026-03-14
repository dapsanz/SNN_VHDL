----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2026 10:55:57 PM
-- Design Name: 
-- Module Name: interface - Behavioral
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

entity interface is
  Port ( clk: in std_logic;
         rst: in std_logic;
         output_digit: out std_logic_vector(3 downto 0)
   );
end interface;

architecture Behavioral of interface is

attribute dont_touch : string;
attribute dont_touch of u_controller : label is "true";
attribute dont_touch of u_datapath   : label is "true";

signal leak   : std_logic;           
signal spikegen_go : std_logic;
signal fifo_rd : std_logic;  
--- RAM WE ---
signal hidden_weights_we :std_logic;
signal hidden_neurons_we : std_logic;
signal image_we : std_logic;       
signal en_cd0   : std_logic;
signal en_cd1   : std_logic; 
signal en_cd2   : std_logic;        
signal en_cd3   : std_logic;        
signal en_cd4   : std_logic;        
signal en_cd5   : std_logic;        
signal en_cd6   : std_logic;        
signal en_cd7   : std_logic;        
signal en_cd8    : std_logic;        
signal en_cd9   : std_logic;
------ Output Flags ------ 
signal fifo_full:  std_logic;
signal fifo_empty:  std_logic;
signal neuron_spike   :  std_logic;  

signal init_weight : std_logic_vector(7 downto 0):= (others => '0');
signal init_image : std_logic_vector(7 downto 0):= (others => '0');
--signal output_digit: std_logic_vector(3 downto 0);     

begin


u_controller: entity work.controller
port map(
    clk               => clk,
    rst               => rst,
    leak              => leak,
    spikegen_go       => spikegen_go,
    fifo_rd           => fifo_rd,
    hidden_weights_we => hidden_weights_we,
    hidden_neurons_we => hidden_neurons_we,
    image_we          => image_we,
    en_cd0            => en_cd0,
    en_cd1            => en_cd1,
    en_cd2            => en_cd2,
    en_cd3            => en_cd3,
    en_cd4            => en_cd4,
    en_cd5            => en_cd5,
    en_cd6            => en_cd6,
    en_cd7            => en_cd7,
    en_cd8            => en_cd8,
    en_cd9            => en_cd9,

    fifo_full         => fifo_full,
    fifo_empty        => fifo_empty,
    neuron_spike      => neuron_spike
);

u_datapath: entity work.datapath
port map(
    clk               => clk,
    rst               => rst,
    
    init_weight       => init_weight,
    init_image        => init_image,
    output_digit      => output_digit,
    
    leak              => leak,
    spikegen_go       => spikegen_go,
    fifo_rd           => fifo_rd,
    hidden_weights_we => hidden_weights_we,
    hidden_neurons_we => hidden_neurons_we,
    image_we          => image_we,
    en_cd0            => en_cd0,
    en_cd1            => en_cd1,
    en_cd2            => en_cd2,
    en_cd3            => en_cd3,
    en_cd4            => en_cd4,
    en_cd5            => en_cd5,
    en_cd6            => en_cd6,
    en_cd7            => en_cd7,
    en_cd8            => en_cd8,
    en_cd9            => en_cd9,

    fifo_full         => fifo_full,
    fifo_empty        => fifo_empty,
    neuron_spike      => neuron_spike
);

stim: process(clk)
begin
    if(rising_edge(clk)) then
        init_weight <= std_logic_vector(unsigned(init_weight)+1);
        init_image  <= std_logic_vector(unsigned(init_image)+1);
    end if; 
end process;

end Behavioral;
