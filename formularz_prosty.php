<!DOCTYPE html>
<!--
To change this license header, choose License Headers in Project Properties.
To change this template file, choose Tools | Templates
and open the template in the editor.
-->
<html>
    <head>
        <title>Raport GPS ver. 0.0.3</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body>
        <p>
        <h1>
            <u><b>UWAGA!</b></u> wersja rozwojowa. Proszę uważnie czytać instrukcję ponieważ pewne 
            funkcje mogą się zmiać.
        </h1>
            Raport powinien zawierać 17 kolumn (bez RMS). Skrypt wyłącznie kopiuje i modyfikuje istniejące dane:
            <ul>
                <li>czas pomiaru w zakresie gdy jest mniej niż 5 sekund</li>
                <li>dwa razy po 30 sekund gdy w kodzie trafi na ciąg znaków "osn"</li>
                <li>gdy czas pomiaru jest większy niż 10 i mniejszy niż 29 zmienia to na 30 sekund</li>
                <li>PDOP, mp, mh</li>
            </ul>
            Może wygenerować obserwacje z zadanego obszaru. <br/>
            W tym celu należy podać X-min, X-max Y-min, Y-max lub wszystkie 4 wartości. 
            Jeśli chcesz otrzymać raport z całości, pozostaw wartości domyślne.<br/>
            Po wygenerowaniu wyświetla ifno o pomiarze innym niż RTN oraz pozwala ściągnąć plik z pikietami. (chwilowo wyłączone)<br/><br/>
            Plik txt/csv można przygotować z raportu GPS i ręcznie go dostosować do przykładu poniżej.
            Można go również przygotować używając szablonów poniżej wykorzystując je w kontrolerze lub ASCII File Generator: <br/>
            <ul>
                <li><a href="./down/Raport GPS PL 022016_mod.xsl" download="Raport GPS_CSV.xsl">Szablon CSV</a></li>
                <li><a href="./down/Raport GPS PL 022016.xsl" download="Raport GPS.xsl">Szablon HTML</a></li>
            </ul>
        </p>
        <p>Przykład poprawnie przygotowanego pliku:<br/>
            <code>PRS187722591140,1,RTN Fix,2019-05-27 11:38:44,2.000,2751.439,-37364.127,7486.737,1.5,15,3,5750934.54,6564332.64,123.628,0.01,0.01,kod_pikety</code>
        </p>
        <p>Wczytaj plik raportu (bez danych nagłówków! Z separatorem , )
            <form name="wgraj" action="./generuj_prosty.php" method="POST" enctype="multipart/form-data">
                <input type="file" name="wgraj_raport"><br/><br/><!--
                Podaj datę pomiaru lub pozostaw puste:<br/>
                <input type="date" name="data_pomiaru"><br/><br/>-->
                Podaj obszar z jakiego ma być wygenerowany raport:<br/>
                <input type="radio" name="zakres" value="calosc" checked="cheked">Całość<br/>
                <input type="radio" name="zakres" value="x">Xmin-Xmax<br/>
                <input type="radio" name="zakres" value="y">Ymin-Ymax<br/>
                <input type="radio" name="zakres" value="xy">Xmin-Xmax, Ymin-Ymax<br/><br/>
                X-min<input  type="number" name="Xmin" value="0"><br/>
                X-max<input  type="number" name="Xmax" value="0"><br/>
                Y-min<input  type="number" name="Ymin" value="0"><br/>
                Y-max<input  type="number" name="Ymax" value="0"><br/><br/>
                <input type="submit" value="Wyślij" name="wyslij">
            </form>
        </p>
    </body>
</html>
