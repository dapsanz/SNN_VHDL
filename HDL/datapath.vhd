----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2026 12:14:05 AM
-- Design Name: 
-- Module Name: datapath - Behavioral
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

entity datapath is
     Port (
            ------  Formal Ports   ------
            clk : in std_logic;
            rst : in std_logic;
            init_weight : in std_logic_vector(7 downto 0);
            init_image : in std_logic_vector(7 downto 0);
            output_digit: out std_logic_vector(3 downto 0);         
            ------ Control Signals ------
            leak   : in std_logic;           
            spikegen_go   : in std_logic;
            fifo_rd : in std_logic;  
            --- RAM WE ---
            hidden_weights_we : in std_logic;
            hidden_neurons_we : in std_logic;
            image_we : in std_logic;      
            --- Digit Counter En ---     
            en_cd0   : in std_logic;
            en_cd1   : in std_logic; 
            en_cd2   : in std_logic;        
            en_cd3   : in std_logic;        
            en_cd4   : in std_logic;        
            en_cd5   : in std_logic;        
            en_cd6   : in std_logic;        
            en_cd7   : in std_logic;        
            en_cd8   : in std_logic;        
            en_cd9   : in std_logic;
            ------ Output Flags ------ 
            fifo_full: out std_logic;
            fifo_empty: out std_logic;
            neuron_spike   : out std_logic           
      );
end datapath;

architecture Behavioral of datapath is

signal weight_addr : std_logic_vector(16 downto 0);
signal weight_val : std_logic_vector(7 downto 0);


signal v_n : std_logic_vector(15 downto 0);
signal v_new : std_logic_vector(15 downto 0);
signal cntr_128:std_logic_vector(6 downto 0);  
signal fifo_out: std_logic_vector(9 downto 0);


signal pixel_id: std_logic_vector(9 downto 0);
signal pixel_val: std_logic_vector(7 downto 0);
signal pixel_spike : std_logic;

--- Digit Counters ---
signal counter_d0 : std_logic_vector(4 downto 0);
signal counter_d1 : std_logic_vector(4 downto 0);
signal counter_d2 : std_logic_vector(4 downto 0);
signal counter_d3 : std_logic_vector(4 downto 0);
signal counter_d4 : std_logic_vector(4 downto 0);
signal counter_d5 : std_logic_vector(4 downto 0);
signal counter_d6 : std_logic_vector(4 downto 0);
signal counter_d7 : std_logic_vector(4 downto 0);
signal counter_d8 : std_logic_vector(4 downto 0);
signal counter_d9 : std_logic_vector(4 downto 0);





begin

weight_addr <= fifo_out & cntr_128;

u_weights: entity work.BRAM
    generic map(
        k => 17,
        w => 8
    )
    port map(
        clk => clk,
        we  => hidden_weights_we,
        addr => weight_addr,
        din  => init_weight,
        dout => weight_val
    );
    
u_hidden_neurons: entity work.BRAM
    generic map(
        k => 7,
        w => 16
    )
    port map(
        clk => clk,
        we  => hidden_neurons_we,
        addr => cntr_128,
        din  => v_new,
        dout => v_n
    );
    
u_image: entity work.BRAM
    generic map(
        k => 10,
        w => 8
    )
    port map(
        clk => clk,
        we  => image_we,
        addr => pixel_id,
        din  => init_image,
        dout => pixel_val
    );
    
u_neuron: entity work.neuron
    port map(
        I_in => weight_val,
        V_in => v_n,
        leak => leak,
        spike => neuron_spike,
        V_out => v_new
    );
u_fifo: entity work.FIFO
    port map(
        clk => clk,
        rst => rst,
        din => pixel_id,
        read => fifo_rd,
        write => pixel_spike,
        dout => fifo_out,
        full => fifo_full,
        empty => fifo_empty
    );
u_spikegen: entity work.spikegen
    port map(
        p_val => pixel_val,
        go => spikegen_go,
        spike => pixel_spike,
        clk => clk,
        rst => rst
    );
u_counter_d0: entity work.counter
    generic map(
        w => 5
    )
    port map(
        clk => clk,
        rst => rst,
        en => en_cd0,
        Q => counter_d0
    );
u_counter_d1: entity work.counter
    generic map(
        w => 5
    )
    port map(
        clk => clk,
        rst => rst,
        en => en_cd1,
        Q => counter_d1
    );
u_counter_d2: entity work.counter
    generic map(
        w => 5
    )
    port map(
        clk => clk,
        rst => rst,
        en => en_cd2,
        Q => counter_d2
    );
u_counter_d3: entity work.counter
    generic map(
        w => 5
    )
    port map(
        clk => clk,
        rst => rst,
        en => en_cd3,
        Q => counter_d3
    );
u_counter_d4: entity work.counter
    generic map(
        w => 5
    )
    port map(
        clk => clk,
        rst => rst,
        en => en_cd4,
        Q => counter_d4
    );
u_counter_d5: entity work.counter
    generic map(
        w => 5
    )
    port map(
        clk => clk,
        rst => rst,
        en => en_cd5,
        Q => counter_d5
    );
u_counter_d6: entity work.counter
    generic map(
        w => 5
    )
    port map(
        clk => clk,
        rst => rst,
        en => en_cd6,
        Q => counter_d6
    );
u_counter_d7: entity work.counter
    generic map(
        w => 5
    )
    port map(
        clk => clk,
        rst => rst,
        en => en_cd7,
        Q => counter_d7
    );
u_counter_d8: entity work.counter
    generic map(
        w => 5
    )
    port map(
        clk => clk,
        rst => rst,
        en => en_cd8,
        Q => counter_d8
    );
u_counter_d9: entity work.counter
    generic map(
        w => 5
    )
    port map(
        clk => clk,
        rst => rst,
        en => en_cd9,
        Q => counter_d9
    );
    
 u_output_logic: entity work.gt_module
 port map(
    clk=> clk,
    rst=> rst,
    d0 => counter_d0,
    d1 => counter_d1,
    d2 => counter_d2,
    d3 => counter_d3,
    d4 => counter_d4,
    d5 => counter_d5,
    d6 => counter_d6,
    d7 => counter_d7, 
    d8 => counter_d8,
    d9 => counter_d9,
    gt => output_digit
 );    
 
 -- Inside datapath architecture
process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            pixel_id <= (others => '0');
            cntr_128 <= (others => '0');
        else
            pixel_id <= std_logic_vector(unsigned(pixel_id) + 1);
            cntr_128 <= std_logic_vector(unsigned(cntr_128) + 1);
        end if;
    end if;
end process;
end Behavioral;
