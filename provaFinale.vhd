--------------------------------------------------------------------------------------------------------
--
-- PROVA FINALE (Progetto di reti logiche)
-- Professore: Gianluca Palermo
-- Anno accadermico 2019/2020
--
-- Nicholas Rosati 
-- 
--
--------------------------------------------------------------------------------------------------------


library IEEE;
library IEEE;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

entity project_reti_logiche is
    Port (
           i_clk : in std_logic;
           i_start : in std_logic;
           i_rst : in std_logic; 
           i_data : in std_logic_vector(7 downto 0);
           o_address : out std_logic_vector(15 downto 0);
           o_done : out std_logic;
           o_en : out std_logic;
           o_we : out std_logic;
           o_data : out std_logic_vector(7 downto 0)
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

type state_type is (START,LEGGI_INDIRIZZO,WAIT_CLOCK_CICLE,SALVA_INDIRIZZO,CONTROLLA_BASE,CONTROLLA_DIFFERENZA, METTI_IN_MEMORIA,
                        ALZO_SEGNALE_DONE,ABBASSO_SEGNALE_DONE);
         
         signal stato_corrente : state_type;                
    

begin

process(i_clk, i_rst)     
            
            variable valoreADDR: std_logic_vector(7 downto 0);   
            variable WZ_OFFSET: std_logic_vector(3 downto 0);
            variable WZ_NUM: std_logic_vector(2 downto 0);
            variable WZ_BIT: std_logic_vector(0 downto 0);
            variable valoreBase: std_logic_vector(7 downto 0);
            variable indirizzoCorrente: std_logic_vector(15 downto 0);
            variable valoreRisultato: std_logic_vector(7 downto 0);
                   
    begin
     if (i_rst = '1') then 
                    stato_corrente <= START;
                end if;
                if (rising_edge(i_clk)) then 
                    case stato_corrente is
                         when START =>
                            if (i_start = '1') then
                                   indirizzoCorrente := "0000000000001000";  -- assegno ad indirizzoCorrente l'indirizzo da cui paritire 
                                   stato_corrente <= LEGGI_INDIRIZZO;
                                end if; 
                        
                           when LEGGI_INDIRIZZO =>  
                           -- in qusto stato passo il mio indirizzo   
                               if(conv_integer(indirizzoCorrente) >= 0 and conv_integer(indirizzoCorrente) <= 8) then -- controllo che indirizzo sia compreso tra il valore 0 e 8 
                                   o_en <= '1';
                                   o_we <= '0';
                                   o_address <= indirizzoCorrente;
                                   stato_corrente <= WAIT_CLOCK_CICLE;
                                else 
                                -- se ecced oquesto limite non hto trovato nessuna WZ e rimando l'indirizzo ADDR
                                   WZ_BIT := "0";
                                   valoreRisultato :=(WZ_BIT & valoreADDR(6 downto 0));
                                   stato_corrente <= METTI_IN_MEMORIA; 
                               end if;
                         
                           when WAIT_CLOCK_CICLE => -- stato di wait per attendere la lettura dei dati 
                               stato_corrente <= SALVA_INDIRIZZO;
                          
                           when SALVA_INDIRIZZO => -- salvo il mio indirizzo preso dalla memoria 
                               if(conv_integer(indirizzoCorrente) = 8) then 
                                   valoreADDR := i_data;
                                   o_en <= '0';
                                   indirizzoCorrente := indirizzoCorrente - "0000000000000001";
                                   stato_corrente <= LEGGI_INDIRIZZO;
                               else 
                                   valoreBase := i_data;
                                   o_en <= '0';
                                   stato_corrente <= CONTROLLA_BASE;
                               end if;
                       
                           when CONTROLLA_BASE => -- controllo se il valore ADDR puo appartenere alla WZ e in caso contario ne cerco un altro se esiste
                               if(valoreADDR < valoreBase) then 
                                    indirizzoCorrente := indirizzoCorrente - "0000000000000001";
                                    stato_corrente <= LEGGI_INDIRIZZO;
                               else
                                    if(conv_integer(valoreADDR - valoreBase) <= 3)then 
                                        stato_corrente <= CONTROLLA_DIFFERENZA;
                                    else 
                                        indirizzoCorrente:= indirizzoCorrente - "0000000000000001";
                                        stato_corrente <= LEGGI_INDIRIZZO;
                                    end if;
                                    
                               end if;
                       
                           when CONTROLLA_DIFFERENZA =>
                           -- il mio ADDR appartiene ad una wz e gli creo la codifica corretta da mettere poi in memoria 
                               if(conv_integer(valoreADDR - valoreBase) = 0) then 
                                   WZ_OFFSET := "0001";
                                   WZ_BIT := "1";
                                   WZ_NUM := indirizzoCorrente(2 downto 0);
                                   valoreRisultato :=(WZ_BIT & WZ_NUM & WZ_OFFSET);
                                   stato_corrente <= METTI_IN_MEMORIA;
                               elsif(conv_integer(valoreADDR - valoreBase) = 1) then 
                                   WZ_OFFSET := "0010";
                                   WZ_BIT := "1";  
                                   WZ_NUM := indirizzoCorrente(2 downto 0);
                                   valoreRisultato := (WZ_BIT & WZ_NUM & WZ_OFFSET);
                                   stato_corrente <= METTI_IN_MEMORIA;
                               elsif(conv_integer(valoreADDR - valoreBase) = 2) then 
                                   WZ_OFFSET := "0100";
                                   WZ_BIT := "1";  
                                   WZ_NUM := indirizzoCorrente(2 downto 0);
                                   valoreRisultato := (WZ_BIT & WZ_NUM & WZ_OFFSET);
                                   stato_corrente <= METTI_IN_MEMORIA;
                               elsif(conv_integer(valoreADDR - valoreBase) = 3) then 
                                   WZ_OFFSET := "1000";
                                   WZ_BIT := "1";  
                                   WZ_NUM := indirizzoCorrente(2 downto 0);
                                   valoreRisultato := (WZ_BIT & WZ_NUM & WZ_OFFSET);
                                   stato_corrente <= METTI_IN_MEMORIA;
                               else 
                                   WZ_BIT := "0";
                                   valoreRisultato :=(WZ_BIT & valoreADDR(6 downto 0));
                                   stato_corrente <= METTI_IN_MEMORIA;
                               end if;
                               
                           when METTI_IN_MEMORIA => -- metto il risultato ottenuto in memoria. 
                               o_en <= '1';
                               o_we <= '1';
                               o_address <= "0000000000001001";
                               o_data <= valoreRisultato;
                               stato_corrente <= ALZO_SEGNALE_DONE;
                               
                           when ALZO_SEGNALE_DONE => 
                               o_en <= '0';
                               o_done <= '1';
                               stato_corrente <= ABBASSO_SEGNALE_DONE;
                               
                           when ABBASSO_SEGNALE_DONE =>
                               o_done <= '0';
                               stato_corrente <= START; 
                          
                               
       
end case;
end if;
end process;
end Behavioral;