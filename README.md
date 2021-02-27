# progetto reti  logiche 2020 
L’obbiettivo del progetto è quello di descrivere e sintetizzare mediante VHDL un componente
hardware che implementi il metodo di codifica a bassa dissipazione di potenza denominato
“Working Zone”, definita come un intervallo di indirizzi di dimensione fissa che parte da un
indirizzo base. Se l’indirizzo da trasmettere non appartiene a nessuna Working Zone, esso viene
trasmesso così com’è con l’aggiunta di un bit addizionale rispetto ai bit di indirizzamento, che
prende il nome di WZ_BIT posto a 0, il valore trasmesso viene così rappresentato (WZ_BIT &
ADDR). Invece se l’indirizzo da trasmettere appartiene ad una Working Zone, il bit addizionale
WZ_BIT viene posto a 1 mentre i bit di indirizzo vengono divisi in due sottocampi in cui il
WZ_NUM rappresenta il numero della Working Zone a cui appartiene l’indirizzo , mentre l’altro
sottocampo prende il nome di WZ_OFFSET che è l’offset rispetto all’indirizzo di base della
Working Zone, il numero viene composto nella sua forma finale così (WZ_BIT & WZ_NUM &
WZ_OFFSET).
