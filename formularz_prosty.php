<!DOCTYPE html>
<!--
To change this license header, choose License Headers in Project Properties.
To change this template file, choose Tools | Templates
and open the template in the editor.
-->
<html lang="pl">
    <head>
        <title>Raport GPS ver. 0.0.3</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body>
        <h1>
            <u><b>UWAGA!</b></u> wersja rozwojowa. Proszę uważnie czytać instrukcję ponieważ pewne 
            funkcje mogą się zmiać.
        </h1>
        <p>Raport powinien zawierać 17 kolumn (bez RMS). Skrypt wyłącznie kopiuje i modyfikuje istniejące dane:</p>
            <ul>
                <li>czas pomiaru w zakresie gdy jest mniej niż 5 sekund</li>
                <li>dwa razy po 30 sekund gdy w kodzie trafi na ciąg znaków "osn"</li>
                <li>wylicza średnią dla podwójnych pomiarów</li>
                <li>gdy czas pomiaru jest większy niż 10 i mniejszy niż 29 zmienia to na 30 sekund</li>
                <li>PDOP, mp, mh</li>
            </ul>
            <p>Może wygenerować obserwacje z zadanego obszaru. <br/>
            W tym celu należy podać X-min, X-max Y-min, Y-max lub wszystkie 4 wartości. 
            Jeśli chcesz otrzymać raport z całości, pozostaw wartości domyślne.<br/>
            Po wygenerowaniu wyświetla info o pomiarze innym niż RTN oraz pozwala ściągnąć plik z pikietami. (chwilowo wyłączone)<br/><br/>
            Plik txt/csv można przygotować z raportu GPS i ręcznie go dostosować do przykładu poniżej.
            Można go również przygotować używając szablonów poniżej wykorzystując je w kontrolerze lub ASCII File Generator: <br/></p>
            <ul>
                <li><a href="./down/Raport_GPS_PL_022016_mod.xsl" download="Raport GPS_CSV.xsl">Szablon CSV</a></li>
                <li><a href="./down/Raport_GPS_PL_022016.xsl" download="Raport GPS.xsl">Szablon HTML</a></li>
            </ul>
            <p>W przypadku błednego generowania czasu należy podzielić pomiar zgodnie z dniami pomiaru, w których był on wykonany.</p>
        <p>Przykład poprawnie przygotowanego pliku:<br/>
            <code>PRS187722591140,1,RTN Fix,2019-05-27 11:38:44,2.000,2751.439,-37364.127,7486.737,1.5,15,3,5750934.54,6564332.64,123.628,0.01,0.01,kod_pikiety</code>
        </p>
        <h4>Podaj dane do wygenerowania raportu</h4>
            <form name="wgraj" action="./generuj_prosty.php" method="POST" enctype="multipart/form-data">
                <label for="plik">Wgraj plik z komputera:<br/>
                (bez danych nagłówków! Z separatorem "," )</label><br/>
                <input id="plik" type="file" name="wgraj_raport"><br/><br/>
                <!--<label for="data">Podaj datę pomiaru lub pozostaw puste:<br/>
                (W przypadku podania daty, godzina pomiaru zostanie wylosowana z zakresu 7:30-8:00)</label><br/>
                <input id="data" type="date" name="data_pomiaru"><br/><br/>
                <label for="czas">Podaj godzinę rozpoczęcia pomiaru lub pozostaw puste</label><br/>
                <input id="czas" type="time" name="godzina"><br/><br/>
                <time datetime="08:00:01"></time>-->
                Podaj obszar z jakiego ma być wygenerowany raport:<br/>
                <input id="calosc" type="radio" name="zakres" value="calosc" checked="checked">
                <label for="calosc">Całość</label><br/>
                <input id="Xmin-Xmax" type="radio" name="zakres" value="x">
                <label for="Xmin-Xmax">Xmin-Xmax</label><br/>
                <input id="Ymin-Ymax" type="radio" name="zakres" value="y">
                <label for="Ymin-Ymax">Ymin-Ymax</label><br/>
                <input id="Xmin-Xmax_Ymin-Ymax" type="radio" name="zakres" value="xy">
                <label for="Xmin-Xmax_Ymin-Ymax">Xmin-Xmax, Ymin-Ymax</label><br/><br/>
                X-min<input  type="number" name="Xmin" value="0"><br/>
                X-max<input  type="number" name="Xmax" value="0"><br/>
                Y-min<input  type="number" name="Ymin" value="0"><br/>
                Y-max<input  type="number" name="Ymax" value="0"><br/><br/>
                <input type="submit" value="Wyślij" name="wyslij">
            </form>
    </body>
</html>
