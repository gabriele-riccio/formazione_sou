#!/bin/bash
#--Esercizio1--File in /bin che iniziano con "c"

#Determinare il numero di file nella directory /bin la cui prima lettera è c.
#prima cosa vedo cosa c'è nella directory /bin
ls /bin
#output:Lista di file al suo interno enorme.
#A me interessano però quelli che iniziano con "c".
#Eseguo:
ls /bin/c*    #uso il glob *.
#output: lista dei file che iniziano per c.

#N.B se voglio contare anche le righe uso il pipe "|" che fa in modo che wc -l, che conta le righe, conti quelle di quello che ha in input, ovvero ls /bin/c* cioè quelle che iniziano per c.ù
ls /bin/c* | wc -l   
#output: nel mio caso 67
