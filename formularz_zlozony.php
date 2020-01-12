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
            <u><b>UWAGA!</b></u> wersja rozwojowa. Proszę uważnie czytać instrukcję ponieważ pewne funkcje mogą się zmieniać.
        </h1>
        <p>Plik z pikietami do wygenerowania raportu powinien zawierać 5 kolumn (nr,x,y,h,kod). 
        Skrypt generuje pomiar całkowicie od nowa. Ważne aby w kodzie pliku znajdował się fragment "osn". Wtedy zostanie utworzony pomiar 30 sekund.
        <!--Wylicza średnią wartość XYH z podanych pikiet. Następnie znajduje najbliższą stację refernecyjną ASG
        i wylicza od niej wektory.
        Oczekuje podania nazwy bazy oraz współrzędnych w układzie 2000. Na tej podstawie znajduje stację ASG-EUPOS i
        wylicza do niej wektory do współrzędnych geoentrycznych.-->
        Należy przygotować dodatkowo drugi plik z 17 kolumnami (kody są bez znaczenia), który posłuży do wyliczenia
        wektorów. Są one wyliczane w sposób przybliżony i nie są dokładne. Jak będę miał chwilę to muszę napisać transformację 
        i wtedy będą dokładne.<br/>
        Należy podać dzień obserwacji. Godzina pomiaru jest losowana z przedziału 7:30-8:00.<br/>
        Plik txt/csv można przygotować z raportu GPS i ręcznie go dostosować do przykładu poniżej.</p>
        <!--dwukrotnie 
        X i Y są niezmieniane. H różni się w milimetach, które po uśrednieniu daje H oryginalne punktu.-->
        Można go również przgotować używając szablonów poniżej wykorzystując je w kontrolerze lub ASCII File Generator: <br/>
        <ul>
            <li><a href="./down/Raport_GPS_PL_022016_mod.xsl" download="Raport GPS_CSV.xsl">Szablon CSV</a></li>
            <li><a href="./down/Raport_GPS_PL_022016.xsl" download="Raport GPS.xsl">Szablon HTML</a></li>
        </ul>
    <p>Przykład poprawnie przygotowanego pliku pikiet:<br/>
        <code>1,5750934.54,6564332.64,123.628,kod</code>
    </p>
    <p>Przykład poprawnie przygotowanego pliku z oryginalnego pomiaru:<br/>
        <code>PRS187722591140,1,RTN Fix,2019-05-27 11:38:44,2.000,2751.439,-37364.127,7486.737,1.5,15,3,5750934.54,6564332.64,123.628,0.01,0.01,kod_pikety</code>
    </p>
    <p><label for="pikiety">Wczytaj plki z pikietami do "wygenerowania" pomiaru</label></p>
    <form name="wgraj" action="./generuj_zlozony.php" method="POST" enctype="multipart/form-data">
        <input id="pikiety" type="file" name="wgraj_raport"><br/><br/>
        <label for="data_pom">Podaj datę pomiaru:<br/></label>
        <input id="data_pom" type="date" name="data_pomiaru"><br/><br/>
        <label for="prawdziwy">Wczytaj plik raportu (oryginalny pomiar zawierający 17 kolumn bez danych nagłówków! Z separatorem "," ), 
            z którego zostaną pobrane informacje o nazwie bazy oraz o wektorach.<br/><br/></label>
        <input id="prawdziwy" type="file" name="pomiar_prawdziwy"><br/><br/>
        <!--Podaj nazwę i współrzędne Bazy ("PRS"):<br/>
        Nazwa: <input  type="text" name="baza_nazwa" value=""><br/>
        X: <input  type="text"   name="bazaX" value="0"><br/>
        Y: <input  type="text"   name="bazaY" value="0"><br/>
        H: <input  type="text"   name="bazaH" value=""><br/>-->
        <input type="submit" value="Wyślij" name="wyslij">
    </form>
</body>
</html>
