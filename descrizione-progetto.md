Progetto Reti Logiche
Versione VIVADO: 2016.4
Con Artix (architettura di fpga 7)

Tutorial VIVADO https://politecnicomilano.webex.com/recordingservice/sites/politecnicomilano/recording/68ca392e3fc8103a9b2b0050568221e0/playback

Descrizione progetto Terraneo https://politecnicomilano.webex.com/recordingservice/sites/politecnicomilano/recording/dfc0072a5681103ab1bf0050568221e0/playback

Algoritmo di Viterbi
Frequenza dei bit d'uscita è il doppio della frequenza dei bit d'entrata
Clock dimensionato sull'uscita, clock d'ingresso legge un bit ogni due prodotti

Dati si trovano in memoria a blocchi di 8 bit, bisogna estrarli e fare una trasformazione parallelo-seriale. Si legge da memoria una parola alla volta-> trasformo in una sequenza di bit, ognuno di quelli che viene trasformato in una coppia di bit->sequenza viene allineata e va a riempire 2 Byte-> trasformazione seriale-parallela e salvataggio in memoria.

Encoding realizzato dall'algoritmo di Viterbi.

Per la scrittura in memoria devo fornire nello stesso ciclo di clock il dato e l'indirizzo a cui scrivere.
Per la lettura in un ciclo fornisco l'indirizzo e nel ciclo successivo mi viene restituito il dato. Deve esserci un ciclo di attesa.

Datapath + FSM -> in vhdl vanno in unico file

Separazione parte sequenziale e parte combinatoria: ci deve essere un process che contiene i Flip flop e un process che implementa la parte di logica. No unico process

No operazioni di moltiplicazione e divisione. 

entity project_reti_logiche 
i_start e o_done : servono per il protocollo di start-done, serve ad attivare il modulo e segnalare il termine.
i_data,o_address,o_en,o_we,o_data sono l'interfacciamento verso la memoria.
es. per leggere dalla memoria ad un ciclo di clock fornisco come o_address il valore dell'indirizzo da cui voglio leggere, o_en = 1 perché se in un ciclo di clock se o_en = 1 significa che la memoria è operativa, o_we = 0 perché voglio leggere, o_data DC perché voglio leggere. Al ciclo successivo la memoria mi fornirà in i_data il contenuto della cella di memoria richiesta.


o_en = 0: né lettura né scrittura in memoria
o_en  = 1 && o_we = 1: scrittura in memoria alla cella o_addr

Memoria asincrona: lettura/scrittura avvengono nello stesso ciclo di clock.
Memoria sincrona: dato in lettura avviene al ciclo di clock successivo. Bisogna tenere conto di un ciclo di clock ritardo nella FSM. Scrittura in memoria sincrona avviene comunque nello stesso ciclo di clock.

Creare i test bench a partire dal tb_example.vhd
Test bench non vanno consegnati

Test behavioural:
Test post-syntesis: simulazione delle porte logiche e FF

Vedere progetto di esempio per come passare da una parola di 16 bit ad una di 8 (si usa mux)
Posso scrivere solo una volta (una parola) per ciclo di clock in memoria -> per scrivere parole di 16 bit ho bisogno di due stati consecutivi


Funzionamento datapath
Leggo dall'indirizzo 0 il numero di parole da convertire e lo salvo nel reg1. 
Inizialmente in reg4 salvo l'indirizzo "0000000000000001" che verrà restituito su o_addr.

Leggo la prima parola dall'indirizzo o_addr, la salvo in reg2, do in input gli 8 bit ad un mux che procederà a selezionare un bit per volta; a partire dal primo bit,  applico il comportamento previsto dal convolutore (si parte dallo stato 00 della FSM). Scrivo i due bit in un reg nei due bit meno significativi e, alla prima iterazione, li sommo a 8 bit a 0, faccio due shift logici a sx e salvo il contenuto in reg3 che restituirà il contenuto sotto forma di o_data; inoltre il contenuto di reg3 va in input ad un mux che ne selezionerà il contenuto e lo darà in input in modo da sommarlo al risultato della convoluzione del secondo bit e così via.

Intanto devo salvare in reg5 l'indirizzo 1000 e quando avrò convertito 4 bit salverò la parola contenuto in reg3 (o_data) in o_addr che sarà pari al contenuto di reg5, che verrà anche incrementato e quindi dovrò fare r5_load.

Dopo aver letto tutti i bit di reg2 dovrò leggere da memoria da o_addr che conterrà il contenuto di reg4, che verrà inoltre incrementato.

Ogni volta che leggo da memoria la parola da convertire decremento il contenuto di reg1, quando sarà = 0 mi fermo, o_done =1.

Importante: per leggere da memoria allo stato S0 devo avere o_en=1 e o_we=0 e allo stato S1 su i_data avrò il contenuto di o_addr richiesto allo stato precedente. Per scrivere allo stato S0 deve avere o_en=1 e o_we=1 e nello ciclo di clock avverrà la scrittura in memoria.

Segnale di reset i_rst va inserito all'interno di un process con il clock