#!/usr/bin/env bash
#per prima cosa per poter usare gli array associativi, scarico la versione 5.3.9 di Bash dato che si può usare solo in versioni di BASH >=4.
#Esercizio bonus:creare un array di stringhe in 2 modi: il primo l'ho già svolto ora voglio farlo con un ciclo for per ordinarle in ordine alfabetico, togliere i duplicati e mettere le stringhe tutte in maiuscolo o minuscolo)

#Seconda versione dell'esercizio, dove voglio ordinare in ordine alfabetico, rimuovere duplicati e convertire in uppercase una lista usando cicli for e array associativi (della versione >=4 di bash).

INPUT=("juvenTUs" "MILAN" "napoli" "genoA" "milAN" "inter" "ROMA" "LAZIO" "bologna" "inter" "atalanta" "Como" "Genoa")

#Stampo l'input originale con printf '%s\n' "${INPUT[@]}" come prima:

echo "== INPUT ORIGINALE =="
printf '%s\n' "${INPUT[@]}"

#Inizio con la fase 1 l'uppercase(in modo che dopo per fare la deduplicazione con l'arrey associativo non ho problemi).

# ${var^^} è la sintassi Bash >=4 per convertire in maiuscolo, mentre ${var,,} in minuscolo 
#declare -a serve a creare e dichiarare un array 
#uso il ciclo for, una volta creata la lista upper_list prende gli elementi dell' INPUT e li rende tutti maiuscoli con ${item^^} eli aggiunge all'interno di upper_list per ogni iterazione.
#fa lo stesso array ma tutto in maiuscolo.

declare -a upper_list
for item in "${INPUT[@]}"; do
  upper_list+=( "${item^^}" )
done

#stampo
echo "--Dopo uppercase--"
printf '%s\n' "${upper_list[@]}"

#output=JUVENTUS MILAN NAPOLI GENOA MILAN INTER ROMA LAZIO BOLOGNA INTER ATALANTA COMO GENOA

#Fase 2 Deduplicazione con array associativo
#declare -A crea un array associativo: Gli array associativi sono stati introdotti a partire dalla versione 4.0 di Bash.
#In python ad esempio o in altri linguaggi di programmazione è conosciuto come dizionario, mappa o hash.
#A differenza degli array classici che usano numeri come indici, questi usano stringhe di testo(chiavi) per memorizzare e richiamare valori.
#Le chiavi sono le stringhe presenti nel array, se essa esiste gia nell'array dopo ogni ciclo allora lo saltiamo con il ciclo for.

declare -A seen    #il primo crea l'array associativo che ha gli elementi del mio array iniziale come chiavi, di valore 1, marca come visto ad ogni iterazione la stringa dell'array iniziale.
declare -a unique  #il secondo crea un array normale (quello finale) che avrà gli elementi del mio array iniziale, senza duplicati.

for item in "${upper_list[@]}"; do
  if [[ -z "${seen[$item]}" ]]; then
    seen["$item"]=1     #lo marca come visto
    unique+=( "$item" ) #se non è duplicato lo aggiunge
  fi
done

#for item in "${upper_list[@]}"; do  ad ogni ciclo passa in rassegna tutte le stringhe dell array iniziale, prendendo ogni elemento a ciclo e lo salva nella variabile item
#if [[ -z "${seen[$item]}" ]]; then controlla in ogni ciclo se quell'elemento dell'array esiste già nell array associativo seen, lo marca come visto e se non c'è gia lo aggiunge all'array associativo unique, altrimenti lo elimina 
#con -z che controlla se la stringa è vuota.

#stampa

echo "--Dopo la deduplicazione--"
printf '%s\n' "${unique[@]}"

#output=JUVENTUS MILAN NAPOLI GENOA INTER ROMA LAZIO BOLOGNA ATALANTA COMO

#--3 Fase: Bubble sort per ordinare in ordine alfabetico
#Ho cercato su internet: è l'ordinamento a bolla, prende gli elementi più pesanti e li mette alla fine dell'array.
#utilizzo 2 cicli annidati(lo facevo anche in javascript) per confrontare una variabile i e una j per capire quale delle due deve stare avanti all'altra così da avere alla fine l'ordine alfabetico.
#per prima cosa calcolo la lunghezza dell'array con n=${#unique[@]}
n=${#unique[@]}

#poi parte il ciclo for:  for (( i=0; i<n-1; i++ )); do l'iterazione avviene partendo dal primo termine dell'array(i=0), fino all'ultimo(i<n-1 dato che parte da 0),
#e incrementa a ogni iterazione. l'altro invece lo faccio fino a j<n-1-i per non far controllare l'ultimo e il primo elemento con niente o di nuovo con alcuni che ho già controllato.
#if [[ "${unique[$j]}" > "${unique[$((j+1))]}" ]]; then confronta due elementi adiacenti, mentre > [[ ]] confronta l'ordine alfabetico di due stringhe adiacenti, vedendo la prima lettera.
#la parte dopo l'if, se è True l'if(ho ad esempio come primo secondo elemento un elemento che inizia per una lettera che viene prima rispetto al primo), salvo il primo elemento nella variabile
#temporanea 'tmp', rinomino la prima variabile con la seconda e la reinserisco nella tmp, in modo da spostare verso il fondo quelle con la prima lettera più 'GRANDE' e verso l'inizio quelle con la prima lettera verso
#l'alto.
for (( i=0; i<n-1; i++ )); do
  for (( j=0; j<n-1-i; j++)); do
    if [[ "${unique[$j]}" > "${unique[$((j+1))]}" ]]; then
      tmp="${unique[$j]}"
      unique[$j]="${unique[$((j+1))]}"
      unique[$((j+1))]="$tmp"
    fi
  done
done

#ora non ci resta che stampare 
echo "=== Output finale (dopo aver ordinato) ==="
printf '%s\n' "${unique[@]}"
#output: ATALANTA BOLOGNA COMO GENOA INTER JUVENTUS LAZIO MILAN NAPOLI ROMA
    















