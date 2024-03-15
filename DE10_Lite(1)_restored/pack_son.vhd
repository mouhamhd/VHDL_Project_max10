library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;


package son is
  
  constant Tclk : time := 10 ns;   -- demie-frequence horloge de base 50 MHZ (= periode 20 ns)
  constant DIV_CLK : integer := 5000;   -- division de l'horloge clk pour frequence d'echantillonage d'entrée 5000 donne 10Khz
  constant taille_cpt : integer := 13;  -- nombre de bits necessaires pour faire cette division de frequence
  
  constant N : integer := 32168 ;      -- son size => taille des memoires (petit pour simulation à augmenter si sur la carte)
  constant EXP : integer := 15;           -- LOG2 son size

  
  constant NbitCNA : integer := 12;    -- Number of bit for CNA
  constant NbitCAN : integer := 12;    -- Number of bit for CAN
   
  constant Ts : integer :=  5000 ; -- correspond à 10Khz pour la fréquence d'échantillonage de sortie ;
  
  constant Nsousech : integer := 100; -- pour le prendre qu'un échantillon sur 100 et tomber à 10khz de fréquence d'échantillonage d'entrée.

 CONSTANT input_clk : INTEGER :=50000000 ; -- fréquence d'horloge utilisée par l'interface DAC à 50 Mhz
 CONSTANT bus_clk : INTEGER := 400000 ;    -- fréquence de l'horloge du bus I2C
 CONSTANT duree_trame : INTEGER := (input_clk/bus_clk)* 29 ; -- duree de la trame i2C

end son;

