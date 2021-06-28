#!/bin/bash
#Portfolioprüfung – Werkstück A – Alternative 7 - Labyrinth
#Emmanuel David - 1369740 / Muhammed Erdal Akkoc - 1221147 / Tim Fichtner - 1220889

#Aus Übersichtsgründen sind alle Funktionen oberhalb des Programmalgorithmus ausgelagert.

#-------------------------------
#          Funktionen
#-------------------------------


#Funktion, die die gültige Benutzereingabe bezüglich der Höhe und Breite prüft.
#Zahlenbereich des gültigen Inputs (5-29) ist variierbar. Unter 5 macht keinen logischen Sinn, da sonst der begehbare Bereich nur noch 3 Zellen beinhaltet.
#29 liegt noch im gut ausführbaren Bereich. Viel größer ist nicht empfehlenswert aus Performanzgründen.
#Ungerade Zahlen sind notwendig, damit ein logisches von Wänden umschlossenes Labyrinth ausgegeben wird. Dieser Punkt wird später beim Algorithmus nochmal verdeutlicht.

function input_achsen {
  local sAchse=$1                                                 #Übergebener Parameter wird an sAchse übergeben
  while true; do
    read -p "$sAchse: " nVarAchse                                 #Einlesen der Benutzereingabe nVarAchse
    if [[ ! $nVarAchse =~ ^[0-9]+$ ]];then                        #Prüfung, ob die Eingabe eine Zahl ist
      echo "Bitte nur Zahlen eingeben!"
    elif [[ $nVarAchse -gt 29 ]] || [[ $nVarAchse -lt 5 ]];then   #Prüfung, ob die Eingabe in dem Bereich 5-29 liegt
      echo "Bitte zwischen 5 und 29 eingeben!"      
    elif [[ $((nVarAchse % 2)) -eq 0 ]];then                      #Prüfung, ob die Eingabe eine ungerade Zahl ist
      echo "Bitte eine ungerade Zahl eingeben!"
    else
      if [[ $sAchse == "Höhe" ]];then                             #Wenn keine der oberen if-Bedingungen greift wird je nach Fall "Höhe" oder "Breite" die zugehörige Variable deklariert. 
        nHoehe=$((nVarAchse + 2))                                 #Auf die deklarierte Variable wird im Rest des Codes immer zugegriffen, wenn man mit der Höhe oder Breite arbeiten will.
      else                                                        #Höhe und Breite wird + 2 dazu addiert, da leere Felder um das sichtbare Labyrinth sind. Somit ist die Eingabe = sichtbares Labyrinth.
        nBreite=$((nVarAchse + 2))
      fi
    break                                                       
    fi
  done
}

#Funktion, die das Array des Labyrinths initiiert. Das Array wird für die Ausgabe des Labyrinths benötigt.
#Das ausgebenene Array hat nHoehe * nBreite Index-Werte. Jeder Index-Wert stellt eine Zelle des Labyrinths dar.
#Jeder Index-Wert wird einem Anfangswert von 0, 1 oder 2 zugewiesen.
#Später bei der Ausgabefunktion wird 0 als "Wand" definiert, 1 als "leeres (begehbares) Feld" und 2 als "Spieler".


function lab_array_initiieren {

  #In der ersten for-Schleife wird je y-Wert (Höhenwert), also je Zeile, jeder x-Wert (Spaltenwert einer Zeile) initiiert.
  #In der for-Schleife der ersten for-Schleife wird jedem x-Wert jeder Zeile der Wert 0 zugewiesen, ausgenommen vom ersten und letzten x-Wert jeder Zeile.
  #Diesen wird nach der eingeschlossenen for-Schleife der Wert 1 zugewiesen.
  #Bei einem 7*7 Array sieht das Array dann z.B. so aus:
  #lab_array: 1000001100000110000011000001100000110000011000001

  for ((y=0; y<nHoehe; y++)) ; do                   
    for ((x=1; x<$((nBreite-1)); x++)) ; do          
      lab_array[$((y * nBreite + x))]=0                      #Definiert die Mitte des Labyrinthes als Wandzellen
    done
    lab_array[$((y * nBreite + 0))]=1                          #Fügt die linken leeren Felder als Begrenzung hinzu
    lab_array[$((y * nBreite + (nBreite - 1)))]=1              #Fügt die rechten leeren Felder als Begrenzung hinzu
  done

  #In der zweiten for-Schleife wird jedem x-Wert der ersten und letzten Zeile der Wert 1 zugewiesen.
  #Bei einem 7*7 Array sieht das Array dann z.B. so aus:
  #lab_array: 1111111100000110000011000001100000110000011111111

  for ((x=0; x<nBreite; x++)) ; do
    lab_array[$x]=1                                          #Fügt die oberen leeren Felder als Begrenzung hinzu
    lab_array[$(((nHoehe - 1) * nBreite + x))]=1             #Fügt die unteren leeren Felder als Begrenzung hinzu
  done

  #Hier werden nochmal 2 Index-Werte auf bestimmte Felder gesetzt: Anfängliche Spielerposition und Ausgang des Labyrinths.
  #Diese Zellen sind nicht zufällig, da somit der größtmögliche Abstand zwischen Eingang und Ausgang erfolgt.
  #Bei einem 5*5 Array sieht das Array dann z.B. so aus:
  #lab_array: 1111111102000110000011000001100000110001011111111

  lab_array[$((nBreite + 2))]=2                              #Fügt den Spieler in den Eingang des Labyrinths hinzu
  lab_array[$(((nHoehe - 2) * nBreite + nBreite - 3))]=1     #Fügt den Ausgang des Labyrinth hinzu
}


#Funktion, die definiert, welches Symbol bei jedem bei jedem Index-Wert des Arrays ausgegeben wird.
#Außerdem wird nach jeder Zeile nun ein Umbruch eingefügt, sodass die Ausgabe zweidimensional dargestellt wird.

function labyrinth_ausgeben {
  for ((y=0; y<nHoehe; y++)) ; do
    for ((x = 0; x<nBreite; x++ )) ; do
      if [[ lab_array[$((y * nBreite + x))] -eq 0 ]];then     #Wenn im Array eine 0 steht wird "██" ausgegeben.
        echo -n -e "\u2588\u2588"
      elif [[ lab_array[$((y * nBreite + x))] -eq 2 ]];then   #Wenn im Array eine 2 steht wird "● " ausgegeben.
        echo -n -e "\u25CF "
      else
        echo -n "  "                                          #Wenn etwas anderes als eine 0 drin steht, wird ein leeres Feld ausgegeben.
      fi
    done
  echo                                                        #Zeilenumbruch und zweidimensionale Darstellung
  done
}


#Funktion, in der das Labyrinth generiert wird mithilfe des Algorithmus des rekursiven Backtrackings.
#Die genaue Funktionsweise des Algorithmus wird genauer in der Dokumentation erklärt.

function rekursives_backtracking {
  local nAktuelle_zelle=$1                          #Übergebener Parameter wird an nAktuelle_zelle übergeben.
  local nZufallszahl=$RANDOM                        #Zufallszahl wird mit einem zufälligen Integer-Wert generiert.
  local i=0                                         #Zählvariable i wird deklariert und auf 0 gesetzt.
  lab_array[$nAktuelle_zelle]=1                     #Aktuelle Zelle wird auf leer gesetzt.

    #while-Schleife, die solange läuft wie i kleiner als 4 ist. 
    #Je Instanz der Rekursion wird folglich 4 mal i geprüft und somit jede der Richtungsoptionen abgedeckt.
    #Man kann sich den Algorithmus als langen Pfad vorstellen, der sich immer um 2 Zellen weiterbewegt je Rekursioninstanz.
    #Wenn man in ein Deadend geraten ist, an dem keine der benachbarten Zellen begehbar ist, wird die while-Schleife beendet und somit auch die jeweilige Rekursionsinstanz.
    #Jede fehlende ungeprüfte Richtung jeder vorherigen Instanz wird beim Rücklauf ebenso nachgeprüft und (falls begehbar) wieder neue Instanzen generiert.
    #Wenn alle Rekursionsinstanzen abgeschlossen sind, wird die Funktion beendet und der Pfad des Labyrinths ist generiert. 

    while [ $i -le 3 ] ; do
      nModZufallszahl=$((nZufallszahl % 4))     #Zufallszahl wird mit Modulo 4 ausgegeben. Somit sind nur 4 Ausgaben möglich.
      
      #Prüfung der einzelnen Richtungen mittels Modulo der Zufallszahl.
      #Addieren der Richtung und der aktuellen Zelle. Somit wird die nächste Zelle, die betrachtet werden soll, ausgewählt.

      if [[ $nModZufallszahl -eq 0 ]];then      
        nRichtung=1                             #Ausgabe Richtung rechts 
      elif [[ $nModZufallszahl -eq 1 ]];then
        nRichtung=-1                            #Ausgabe Richtung links
      elif [[ $nModZufallszahl -eq 2 ]];then
        nRichtung=$nBreite                      #Ausgabe Richtung unten
      elif [[ $nModZufallszahl -eq 3 ]];then
        nRichtung=$((-$nBreite))                #Ausgabe Richtung oben
      fi
      local nNaechste_zelle=$((nAktuelle_zelle + nRichtung))    

        #Prüfung, ob sich in der nächsten Zelle eine Wand befindet.
        #Addieren der Richtung und der nächsten Zelle. Somit wird die übernächste Zelle, die betrachtet werden soll, ausgewählt.

        if [[ lab_array[$nNaechste_zelle] -eq 0 ]];then
          local nUebernaechste_zelle=$((nNaechste_zelle + nRichtung))  

          #Prüfung, ob sich in der übernächsten Zelle eine Wand befindet.
          #Wenn ja, wird die nächste Zelle des Algorithmus auf leer gesetzt. 
          #Eine weitere Rekursionsinstanz wird geöffnet, bei der die übernächste Zelle als aktuelle Zelle übergeben wird und wieder am Anfang der Rekursion auf leer gesetzt wird.
          #Somit wird immer 2 Zellen in eine Richtung gegangen statt eine. Dies hat folgende Gründe:
          #1) Wände zwischen Zellen müssen als Zelle definiert werden, da man diese sonst nicht anders ausgeben kann.
          #   Somit ist bei 2 Zellenschritten garantiert, dass die Wände korrekt die leeren Felder trennen.
          #2) Damit der Algorithmus erkennt wo sich die Begrenzung des Labyrinths befindet, ist das sichtbare Feld von unsichtbaren leeren Feldern umgeben.
          #   Somit wird ebenso immer eine Außenwand, die innen an die Umgrenzung anliegt, ausgegeben.
          #Hierbei ist es auch notwendig, dass ungerade Zahlen eingegeben werden in der Funktion input_achsen.
          #Wenn wir uns z.B. in Zelle 1 befinden und uns 2 Zellen weiterbewegen sind dies 3 Zellen, die dargestellt werden.

          if [[ lab_array[$nUebernaechste_zelle] -eq 0 ]];then
            lab_array[$nNaechste_zelle]=1
            rekursives_backtracking $nUebernaechste_zelle
          fi
        fi

      #Wenn keine neue Rekursionsinstanz eröffnet wird, werden i und die Zufallszahl um 1 erhöht.
      #Somit wird die nächste Richtung geprüft und keine Richtung doppelt geprüft.

      i=$((i + 1))
      nZufallszahl=$((nZufallszahl + 1))
    done
}


#Funktion, die prüft, ob sich der Spieler in die gewünschte Richtung bewegen kann.

function kollisionspruefung {
  if [[ ${lab_array[$nNeue_position]} = 1 ]];then  #If-Bedingung greift, wenn die Zelle, in die man sich bewegen möchte, leer ist.
    lab_array[$nAktuelle_position]=1               #Spieler wird aus der aktuellen Zelle gelöscht und die aktuelle Zelle wieder auf leer gesetzt.
    lab_array[$nNeue_position]=2                   #Spieler wird auf die neue Zelle gesetzt
    nAktuelle_position=$nNeue_position             #Die neue Position wird als aktuelle Position deklariert.
    let nZuege++                                   #Anzahl Züge wird um 1 erhöht
    clear                                             
    labyrinth_ausgeben
  else                                             #Wenn sich in der Zelle, in die man sich bewegen möchte, eine Mauer befindet, bewegt sich der Spieler nicht. 
    echo "Hier ist eine Mauer."                    #Es wird eine entsprechende Meldung ausgegeben.
  fi
}

#--------------------------------------------
#      Initialisierung und Generierung
#--------------------------------------------

clear
echo -e "Portfolioprüfung – Werkstück A – Alternative 7 - Labyrinth\n"
echo -e "Bitte die Höhe und Breite des Labyrinths angeben.\nNur ungerade Zahlen zwischen 5 und 29 sind gültig.\n"

#Höhe und Breite werden angefragt vom Benutzer. Hierbei wird die Funktion input_achsen aufgerufen und ein String als Parameter übergeben.

input_achsen "Höhe" 
input_achsen "Breite"

#Funktionen zur Array Initiierung und Generierung des Labyrinths werden aufgerufen.

lab_array_initiieren
rekursives_backtracking  $((2 * nBreite + 2))         #Erster Parameter, der an die Rekursion übergeben wird, ist nicht zufällig, sondern immer oben links unter dem Eingang.

#-----------------------------------------
#        Ausgabe und Spielerbewegung
#-----------------------------------------

#Variablen für die Bewegung des Spielers

sRichtung="0"                                         #Benutzereingabe der Richtungstasten, die eingelesen wird 
nAktuelle_position=$((nBreite + 2))                   #Aktuelle Position des Balls wird auf den Eingang des Labyrinths gesetzt
nAusgang=$(((nHoehe - 2) * nBreite + nBreite - 3))    #Ausgang, um später Ende des Labyrinths zu überprüfen
nEingang=$((nBreite + 2))                             #Eingang, um zu verhindern, dass sich der Spieler "Out-Of-Bounds" bewegen kann.
nZuege="0"                                            #Zugzähler wird initiiert. Nur notwendig, wenn das Spiel bei 0 Zügen beendet wird, da sonst ein leeres Feld ausgegeben wird statt 0.
sEingaben="a -> Nach links bewegen\ns -> Nach rechts bewegen\nd -> Nach unten bewegen\nw -> Nach oben bewegen\nq -> Spiel beenden"    #Hilfe für Benutzereingaben, die bei jeder Ausgabe des Labyrinths mit ausgegeben werden.

clear
labyrinth_ausgeben
echo -e "Züge = 0\n"
echo -e $sEingaben

#while-Schleife, bei der man den Spieler bewegen kann, solange man nicht "q" drückt, um das Programm zu beenden.

while [ $sRichtung != "q" ];do         #Solange nicht die Taste q gedrückt wird, kann der Ball bewegt werden
  read  -n1 -s sRichtung               #Eingabe vom Benutzer wird gelesen
  clear
  labyrinth_ausgeben
  
  #Benutzereingabe wird einer Richtung zugewiesen. Dann wird mit der Funktion kollisionspruefung geprüft, ob sich in der nächsten Zelle eine Mauer befindet.

  if [[ $sRichtung == a ]];then                          #Benutzer will den Spieler ein Feld nach links bewegen
    nNeue_position=$((nAktuelle_position - 1))
    kollisionspruefung
  elif [[ $sRichtung == d ]];then                        #Benutzer will den Spieler ein Feld nach unten bewegen
    nNeue_position=$((nAktuelle_position + 1))
    kollisionspruefung
  elif [[ $sRichtung == s ]];then                        #Benutzer will den Spieler ein Feld nach unten bewegen
    nNeue_position=$((nAktuelle_position + nBreite))
    kollisionspruefung
  elif [[ $sRichtung == w ]];then                        #Benutzer will den Spieler ein Feld nach oben bewegen
    nNeue_position=$((nAktuelle_position - nBreite))
    if [[ $nNeue_position -lt $nEingang ]];then          #Falls sich der Spieler dabei außerhalb des Labyrinths bewegt, wird dies abgebrochen und dem Benutzer mitgeteilt.             
      echo "Falsche Richtung. Der Ausgang befindet sich unten rechts."
      echo -e "Züge = $nZuege\n"
      echo -e "Bewegung mit den Pfeiltasten: asdw\nSpiel Beenden: q"
      continue
    fi
    kollisionspruefung
  fi

  if [[ $nAktuelle_position -gt $nAusgang ]];then        #Falls sich der Spieler eine Zelle unterhalb des Ausgangs befindet, wird das Spiel beendet und dem Benutzer mitgeteilt.
    echo "Züge = $nZuege"
    echo "Herzlichen Glückwunsch! Du hast $nZuege Züge gebraucht."
    read
    exit
  fi

  if [[ ! $sRichtung == *[asdwq] ]];then                 #Prüft, ob eine gültige Eingabe vorliegt. Andernfalls wird es dem Benutzer mitgeteilt.
    echo "Bitte nur die Buchstaben asdw oder q eingeben!"
  fi

  echo -e "Züge = $nZuege\n"
  echo -e $sEingaben
done

#Wenn die while-Schleife mit "q" beendet wird, wird das Spiel beendet und eine entsprechende Mitteilung ausgegeben.

clear
labyrinth_ausgeben
echo -e "Züge = $nZuege\n"
read -p "Das Spiel wurde beendet."