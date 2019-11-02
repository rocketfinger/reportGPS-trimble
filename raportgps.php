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
        <h2>Raport GPS</h2>
        <div><p>Skrypt generuje "poprawne" raporty z pomiaru GPS dla odbiorników TRIMBLE.<br/>
                Są dwa tryby pracy:
            <ol type="1">
                <li>Prosty raport - generuje tylko porawki czasu, PDOP, mp, mh. Może wygenerować obserwacje dla 
                    zadanego odcinka X-X lub Y-Y. <u><b>NIE generuje nowych obserwacji, np. dla osnowy</b></u></li>
                <li>Złożony raport - generuje to co powyżej oraz z druiego pliku zaczytuje osnowę lub pikiety 
                    i "mierzy" z odpowienimi wartościami</li>
            </ol></p>
        <p>Żaden z powyższych nie generuje nagłówków raportu! Należy je "dokleić" samemu.<br/></p>
        <p>Przed przystąpieniem do tworzenia raportów należy przygotować poprawnie pliki wejściowe.
            Jest to opisane szczegółowo na stronach generujacych raport.<br/></p>
        <p>Jaki raport chcesz wygenerować?
        <ol type="1">
            <li><a href="formularz_prosty.php">Prosty</a></li>
            <li><a href="formularz_prosty.php">Złożony</a></li>
        </ol></p>
        </div>
    </body>
</html>
        <?php
        if(file_exists("./down/pikiety.txt")){
            unlink("./down/pikiety.txt");
        }
        ?>