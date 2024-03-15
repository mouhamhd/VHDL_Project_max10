library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;
use work.son.all;

ENTITY freqsortie IS
	PORT (clk           :  IN      STD_LOGIC; -- clock à 50 Mhz
		validsortie      : IN std_logic ;  --indique si on souhaite émettre du son
		BP0              :  IN      STD_LOGIC;   --active low reset sur BP0
	   ena, Fs          : OUT std_logic -- pour maitrise de la frequence d'echantillonage DAC Fs dure une seule période, ena toute la trame I2C
		
	 ); 
END freqsortie;

ARCHITECTURE comportementale OF freqsortie IS

CONSTANT input_clk : INTEGER :=50000000 ; 
CONSTANT bus_clk : INTEGER := 400000 ; 
CONSTANT duree_trame : INTEGER := (input_clk/bus_clk)* 29 ; -- duree de la trame i2C

SIGNAL sena,sfs : STD_LOGIC;

BEGIN

--- génération du signal ena du DAC pour frequence d'echantillonage de sortie
 -- compteur pour génération d'un signal ena permettant de synchroniser avec l ADC 
cpt_fs:	Process (clk,BP0)
	 variable compteur : std_logic_vector (taille_cpt-1 downto 0) :=(others =>'0')  ; --compteur pour la fr�quence de la conversion;
	 	begin
	    IF(BP0= '0') THEN                --reset asserted
         compteur := (others =>'0');
       ELSIF(clk'EVENT AND clk = '1') THEN
			IF (validsortie='0') THEN  compteur := (others =>'0'); 
			ELSIF(compteur = conv_std_logic_vector(DIV_CLK-1, taille_cpt)) THEN        --end of timing cycle
            compteur := (others =>'0'); 
			   ELSE compteur :=compteur +1 ;	
	      END IF;
		   IF (compteur = conv_std_logic_vector(duree_trame, taille_cpt) ) THEN sena <='0';
		      ELSIF (compteur = conv_std_logic_vector(2, taille_cpt) )	then sena<='1';
			END IF;	
			IF (compteur = conv_std_logic_vector(1, taille_cpt) ) THEN sfs <='1';
		      ELSE sfs<='0';
			END IF;
		 END IF;	
		
	end process cpt_fs;
	
ena <= sena;
Fs <= sfs;	
	
END comportementale;	