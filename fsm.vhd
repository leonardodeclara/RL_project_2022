library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_address : out STD_LOGIC_VECTOR (1 downto 0);
           o_done : out STD_LOGIC;
           o_en : out STD_LOGIC;
           o_we : out STD_LOGIC;
           o_data : out STD_LOGIC_VECTOR (7 downto 0)
           );
end project;

architecture Behavioral of project is
component datapath is
    Port ( 
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
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
        r5_load : in STD_LOGIC:
        r1_sel : in STD_LOGIC;
        o_r2_sel : in STD_LOGIC_VECTOR (2 downto 0);
        r3_sel : in STD_LOGIC;
        r4_sel : in STD_LOGIC;
        r5_sel : in STD_LOGIC;
        d_sel : in STD_LOGIC;
        mem_sel : in STD_LOGIC;
        o_end : out STD_LOGIC);
end component;
signal o_reg1 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg2 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg3 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg4 : STD_LOGIC_VECTOR (15 downto 0);
signal o_reg5 : STD_LOGIC_VECTOR (15 downto 0);
signal mux_reg1 : STD_LOGIC_VECTOR(7 downto 0);
signal sub_reg1 : STD_LOGIC_VECTOR(7 downto 0);
signal mux_o_reg2 : STD_LOGIC_VECTOR(7 downto 0);
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

-- qui devo inserire tutti gli stati e cose varie della fsm -- 
type S is (S0,S1,S2,S3,S4,S5,S6, S7, S8, S9, S10, S11, S12, S13);
signal cur_state, next_state : S;

-- fine di tutte le cose della fsm --

begin
    DATAPATH0: datapath port map(
        i_rst,
        conv_rst,
        i_data,
        i_addr,
        wr_addr,
        o_address,
        o_data,
        r1_load,
        r2_load,
        r3_load,
        r4_load,
        r5_load,
        r1_sel,
        o_r2_sel,
        r3_sel,
        r4_sel,
        r5_sel,
        d_sel,
        mem_sel,
        o_end
    );

    -- process per il reset della fsm
    fsm_state: process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= S0;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;

    -- process per la funzione stato prossimo
    delta: process(cur state, i_start, o_end)
    begin
        next_state <= cur_state;
        case cur_state is
            when S0 =>
                if i_start = '1' then
                    next_state <= S1;
                else if i_start = '0' then
                    next_state <= S0;
                end if;
            when S1 =>
                next_state <= S2;
            when S2 =>
                if o_end = '1' then
                    next_state <= S12;
                else
                    next_state <= S3;
                end if;
            when S3 =>
                next_state <= S4;
            when S4 =>
                next_state <= S5;
            when S5 =>
                next_state <= S6;
            when S6 =>
                next_state <= S7;
            when S7 =>
                next_state <= S8;
            when S8 =>
                next_state <= S9;
            when S9 =>
                next_state <= S10;
            when S10 =>
                next_state <= S11;
            when S11 =>
                if o_end = '0' then
                    next_state <= S3;
                else
                    next_state <= S12;
                end if;
            when S12 =>
                if i_start = '1' then
                    next_state <= S12;
                else if i_start = '0' then
                    next_state <= S13;
            when S13 =>
                next_state <= S0;
    end process;

    -- process per l'aggiornamento dei segnali
    state_signals: process(cur_state)
    begin
        r1_load <= '0';
        r2_load <= '0';
        r3_load <= '0';
        r4_load <= '0';
        r5_load <= '0';
        r1_sel <= '0';
        o_r2_sel <= "000";
        r3_sel <= '0';
        r4_sel <= '0';
        r5_sel <= '0';
        d_sel <= '0';
        mem_sel <= '0';
        o_end <= '0';
        wr_addr <= "1111101000000000";
        i_addr <= "0000000000000000";
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
        case cur_state is
            when S0 =>
            when S1 =>
                i_addr <= "0000000000000000";
                o_en <= '1';
                o_we <= '0';
                r4_sel <= '0';
                r4_load <= '1';
                r5_sel <= '0';
                r5_load <= '1';
                mem_sel <= '0';
                conv_rst <= '1';
            when S2 =>
                r1_sel <= '0';
                r1_load <= '1';
                r4_sel <= '1';
                r4_load <= '1';
                mem_sel <= '0';
                o_en <= '1';
                o_we <= '0';
                conv_rst <= '0';
            when S3 =>
                o_r2_sel <= "000";
                r2_load <= '1';
                d_sel <= '0';
                r3_load <= '1';
                r4_sel <= '1';
                r4_load <= '1';
                --r5_sel <= '0'; in teoria queste 2 righe vanno in S1 e S11
                --r5_load <= '1';
                --mem_sel <= '1'; spostato in S6
            when S4 =>
                o_r2_sel <= "001";
                d_sel <= '1';
                r3_load <= '1';
            when S5 =>
                r2_sel <= "010";
                d_sel <= '1';
                r3_load <= '1';
            when S6 =>
                o_r2_sel <= "011";
                d_sel <= '1';
                r3_load <= '1';
                o_we <= '1';
                o_we <= '1';
                mem_sel <= '1';
            when S7 =>
                o_r2_sel <= "100";
                d_sel <= '0';
                r3_load <= '1';
                r5_sel <= '1';
                r5_load <= '1';
            when S8 =>
                o_r2_sel <= "101";
                d_sel <= '1';
                r3_load <= '1';
            when S9 =>
                o_r2_sel <= "110";
                d_sel <= '1';
                r3_load <= '1';
            when S10 =>
                o_r2_sel <= "111";
                r3_load <= '1';
                d_sel <= '1';
                o_we <= '1';
                o_en <= '1';
                --mem_sel <='1'; potrebbe essere superfluo
            when S11 =>
                o_en <= '1';
                o_we <= '0';
                mem_sel <= '0';
                r1_sel <= '1';
                r1_laod <= '1';
                r5_sel <= '1';
                r5_load <= '1';
            when S12 =>
                o_done <= '1';
            when S13 =>
                o_done <= '0';
        end case;
    end process;

-- 
-- in teoria qui dovrei mettere tutto il codice del datapath, librerie incluse 
--
end Behavioral;