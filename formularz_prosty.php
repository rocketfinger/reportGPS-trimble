<!DOCTYPE html>
<!--
To change this license header, choose License Headers in Project Properties.
To change this template file, choose Tools | Templates
and open the template in the editor.
-->
<html>
    <head>
        <title>Raport GPS ver. 0.0.1</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body>
        <p>Raport powinien zawierać 16 kolumn (bez RMS). Skrypt wyłącznie kopiuje i modyfikuje istniejące dane
            (czas pomiaru tylko w zakresie gdy jest mniej niż 5 sekund!, PDOP, mp, mh). Może wygenerować obserwacje z zadanego obszaru. <br/>
            W tym celu należy podać X-min, X-max Y-min, Y-max lub wszystkie 4 wartości. 
            Jeśli chcesz otrzymać raport z całości, pozostaw wartości domyślne.<br/><br/>
            Plik csv/txt lub html (a potem ręczne utworzenie pliku txt z pliku html)
            można przygotować używając szablonów poniżej wykorzystując je w kontrolerze lub ASCII File Generator: <br/>
        <ul>
            <li><a href="">Szablon CSV</a></li>
            <li><a href="">Szablon HTML</a></li>
        </ul></p>
    <p>Przykład poprawnie przygotowanego pliku:<br/>
        <code>PRS187722591140;1;RTN Fix;2019-05-27 11:38:44;2.000;2751.439;-37364.127;7486.737;1.5;15;3;5750934.54;6564332.64;123.628;0.01;0.01</code></p>
    <p>Wczytaj plik raportu (bez danych nagłówków! Z separatorem ; )
    <form name="wgraj" action="./generuj_prosty.php" method="POST" enctype="multipart/form-data">
        <input type="file" name="wgraj_raport"><br/><br/>
        Podaj obszar z jakiego ma być wygenerowany raport:<br/>
        <input type="radio" name="zakres" value="calosc" checked="cheked">Całość<br/>
        <input type="radio" name="zakres" value="x">Xmin-Xmax<br/>
        <input type="radio" name="zakres" value="y">Ymin-Ymax<br/>
        <input type="radio" name="zakres" value="xy">Xmin-Xmax, Ymin-Ymax<br/>
        X-min<input  type="number" name="Xmin" value="5750930"><br/>
        X-max<input  type="number" name="Xmax" value="5752031"><br/>
        Y-min<input  type="number" name="Ymin" value="6564261"><br/>
        Y-max<input  type="number" name="Ymax" value="6564335"><br/><br/>
        <input type="submit" value="Wyślij" name="wyslij">
    </form></p>
</body>
</html>
