library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity datapath is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_start : in STD_LOGIC;
           conv_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           i_addr : in STD_LOGIC_VECTOR (15 downto 0);
           wr_addr : in STD_LOGIC_VECTOR (15 downto 0);
           o_address : out STD_LOGIC_VECTOR (15 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           r1_load : in STD_LOGIC;
           r2_load : in STD_LOGIC;
           r3_load : in STD_LOGIC;
           r4_load : in STD_LOGIC;
           r5_load : in STD_LOGIC;
           r1_sel : in STD_LOGIC;
           o_r2_sel : in STD_LOGIC_VECTOR (2 downto 0);
           r4_sel : in STD_LOGIC;
           r5_sel : in STD_LOGIC;
           d_sel : in STD_LOGIC;
           mem_sel : in STD_LOGIC;
           o_end : out STD_LOGIC);
end datapath;

architecture Behavioral of datapath is
signal o_reg1 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg2 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg3 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg4 : STD_LOGIC_VECTOR (15 downto 0);
signal o_reg5 : STD_LOGIC_VECTOR (15 downto 0);
signal mux_reg1 : STD_LOGIC_VECTOR(7 downto 0);
signal sub_reg1 : STD_LOGIC_VECTOR(7 downto 0);
signal i_conv : STD_LOGIC;
signal o_conv : STD_LOGIC_VECTOR(1 downto 0);
signal sum_conv:  STD_LOGIC_VECTOR(7 downto 0);
signal o_sll : STD_LOGIC_VECTOR(7 downto 0);
signal mux_sum_conv : STD_LOGIC_VECTOR(7 downto 0);
signal mux_reg4 : STD_LOGIC_VECTOR (15 downto 0);
signal sum_reg4 : STD_LOGIC_VECTOR (15 downto 0);
signal mux_reg5 : STD_LOGIC_VECTOR (15 downto 0);
signal sum_reg5 : STD_LOGIC_VECTOR (15 downto 0);
type C is (C0,C1,C2,C3);
signal conv_cur_state, conv_next_state : C;

--- rivedere se usare  elsif i_clk'event and i_clk = '1' then oppure elsif rising_edge(i_clk) then -- 

begin

    with r1_sel select 
        mux_reg1 <= i_data when '0',
                    sub_reg1 when '1',
        		    "XXXXXXXX" when others;

    r1: process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg1 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r1_load = '1') then
                o_reg1 <= mux_reg1;
            end if;
        end if;
    end process;
    
    sub_reg1 <= o_reg1 - "00000001";
    
    o_end <= '1' when (o_reg1 = "00000000") else '0';
    
    r2: process(i_clk, i_rst, i_start)
    begin
        if(i_rst = '1' or i_start='0') then
            o_reg2 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r2_load = '1') then
                o_reg2 <= i_data;
            end if;
        end if;
    end process;
    
    with o_r2_sel select
        i_conv <= o_reg2(0) when "000",
                  o_reg2(1) when "001",
                  o_reg2(2) when "010",
                  o_reg2(3) when "011",
                  o_reg2(4) when "100",
                  o_reg2(5) when "101",
                  o_reg2(6) when "110",
                  o_reg2(7) when "111",
                  'X' when others;


    conv_state: process(i_clk, conv_rst)
    begin
        if(conv_rst = '1') then
            conv_cur_state <= C0;
        elsif i_clk'event and i_clk = '1' then
            conv_cur_state <= conv_next_state;
        end if;
    end process;

    -- o_conv non ci va nella sensitivity list
    conv_lambda: process (conv_cur_state, i_conv)
    begin
        conv_next_state <= conv_cur_state;
        case conv_cur_state is
            when C0 =>
                if i_conv = '1' then
                    conv_next_state <= C2;
                    o_conv <= "11";
                elsif i_conv = '0' then
                    conv_next_state <= C0;
                    o_conv <= "00";
                end if;
            when C1 =>
                if i_conv = '1' then
                    conv_next_state <= C2;
                    o_conv <= "00";
                elsif i_conv = '0' then
                    conv_next_state <= C0;
                    o_conv <= "11";
                end if;
            when C2 =>
                if i_conv = '1' then
                    conv_next_state <= C3;
                    o_conv <= "10";
                elsif i_conv = '0' then
                    conv_next_state <= C1;
                    o_conv <= "01";
                end if;
            when C3 =>
                if i_conv = '1' then
                    conv_next_state <= C3;
                    o_conv <= "01";
                elsif i_conv = '0' then
                    conv_next_state <= C1;
                    o_conv <= "10";
                end if;
        end case;
    end process;

    -- non so se va bene l'and con i due bit dell'output del conv fatto così)--
    sum_conv <= ("000000" & o_conv)+ mux_sum_conv;
    
    with d_sel select
        mux_sum_conv <= "00000000" when '0',
                        o_sll when '1',
                        "XXXXXXXX" when others;
    
    
    r3: process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg3 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r3_load = '1') then
                o_reg3 <= sum_conv;
            end if;
        end if;
    end process;

    -- non sono sicuro su queste due istruzioni, se vadano da qualche altra parte--
    o_data <= o_reg3;
    o_sll <= o_reg3(5 downto 0) & "00" ;
    
    with r4_sel select
        mux_reg4 <= i_addr when '0',
                    sum_reg4 when '1',
                    "XXXXXXXXXXXXXXXX" when others;

    r4: process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg4 <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if(r4_load = '1') then
                o_reg4 <= mux_reg4;
            end if;
        end if;
    end process;

    sum_reg4 <= o_reg4 + "0000000000000001";

    with r5_sel select
        mux_reg5 <= wr_addr when '0',
                    sum_reg5 when '1',
                    "XXXXXXXXXXXXXXXX" when others;

    r5: process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg5 <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if(r5_load = '1') then
                o_reg5 <= mux_reg5;
            end if;
        end if;
    end process;

    sum_reg5 <= o_reg5 + "0000000000000001";

    with mem_sel select
        o_address <= o_reg4 when '0',
                    o_reg5 when '1',
                    "XXXXXXXXXXXXXXXX" when others;

end Behavioral;