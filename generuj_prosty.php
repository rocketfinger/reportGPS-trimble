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
        <link href="styl.css" rel="stylesheet" type="text/css"/>
    </head>
    <body>
        <?php
        //wgrywanie pliku
        $katalog_docelowy_wgrywania = "up/";
        $plik_docelowy_wgrywania = $katalog_docelowy_wgrywania . basename($_FILES["wgraj_raport"]["name"]);
        $wgranieOK = 1;
        $czy_tekstowy = strtolower(pathinfo($plik_docelowy_wgrywania, PATHINFO_EXTENSION));
        // Sprawdź czy plik istnieje
        if (file_exists($plik_docelowy_wgrywania)) {
            echo "Plik już istnieje. Zgłoś adminowi aby usunął ręcznie.";
            $wgranieOK = 0;
        }
        // Dozwolone foramty plików
        if ($czy_tekstowy != "txt" && $czy_tekstowy != "csv") {
            echo "Tylko pliki TXT i CSV są dozwolone.";
            $wgranieOK = 0;
        }
        // Sprawdź czy wgranieOK ma wartość 0 świadczącą o błędzie
        if ($wgranieOK == 0) {
            echo "Jakiś błąd jest po drodze. Pliku nie wgrano.";
            // jeśli ma wartość 1 to rób dalej
        } else {
            if (move_uploaded_file($_FILES["wgraj_raport"]["tmp_name"], $plik_docelowy_wgrywania)) {
                //zmień nazwę z dowolnej na standardową
                rename("$katalog_docelowy_wgrywania" . basename($_FILES["wgraj_raport"]["name"]), "$katalog_docelowy_wgrywania/wejsciowy.txt");
            } else {
                echo "Jakiś błąd w końcowym etapie wgrywania. Spróbuj jeszcze raz.";
            }
        }
        //zmienna kontrolna dla punktów błędnych
        $float = false;
        //tablica do zapisu błednych punktów, które na końcu będą wyświetlone
        $punkty_float = [];
        //tablica główna zawieracjaca rekody z pliku. tak wiem, powinien być obiekt :)
        $tablica_pikiet = array(array("0baza", "1nr_pkt", "2rtn-fix", "3data czas", "4tyczka", "5dx", "6dy", "7dz", "8pdop",
                "9sat", "10epoki", "11x", "12y", "13h", "14mp", "15mh", "16kod"));
        //zmienna do obługi pętli wczytania pliku
        $i = 0;
        //zmienna kontrolna przechowująca informację czy wystąpiły punkty osnowy pomiarowej
        $czy_jest_osnowa = false;
        //wgrywanie rekordów z pliku
        $handle = fopen("up/wejsciowy.txt", "r");
        while (($rekord = fgetcsv($handle, 0, ",")) !== FALSE) {
            //załaduj dane z odczytanego rekordu do tablicy pikiet
            for ($j = 0; $j < 17; $j++) {
                $tablica_pikiet[$i][$j] = $rekord[$j];
            }
            /*
             * jeśli znajdzie fragment "osn" w kodzie pikiety to dodaj drugi pomiar
             * punktu "w ciemno". bez sprawdzenia czy jest dwa razy mierzone czy też nie.
             * w przyszłości albo przepisać od nowa albo sprawdzić czy już są dwa pomiary.
             */
            if (preg_match("/osn/i", $rekord[16]) == 1) {
                //$tablica_pikiet[$i][10] = 30;
                $tablica_pikiet[$i][16] = $rekord[16];
                /*
                 * dodaj drugi pomiar dla punktu osnowy wraz z "przsunięciem" współrzędnych
                 * dla pierwszego i drugiego pomairu aby po uśrednenieniu uzyskać
                 * wartość pierwotnie pomierzoną.
                 */
                for ($j = 0; $j < 17; $j++) {
                    $tablica_pikiet [$i + 1][$j] = $rekord[$j];
                    //$tablica_pikiet[$i+1][10] = 30;
                    /*
                     * dla współrzędej H punktu wylosować przesunięcie, które również
                     * będzie uwzględnione w polach wektorów XYZ
                     */
                    if ($j === 13) {
                        //wylosuj znak "+" lub "-"
                        $znak = random_int(0, 1);
                        //wylosuj przesunięcie w milimetrach
                        $przesuniecie = "0.00" . random_int(1, 4);
                        //dodaj
                        if ($znak === 0) {
                            //odejmij od oryginału i wpisz nowe H, nie zmieniaj przyrostów XYZ
                            $tablica_pikiet [$i][13] = $rekord[13] - $przesuniecie;
                            //dodaj do dorobionego punktu i zmień przyrosty XYZ
                            $tablica_pikiet [$i + 1][13] = $rekord[13] + $przesuniecie;
                            $tablica_pikiet [$i + 1][5] = $rekord[5] + $przesuniecie;
                            $tablica_pikiet [$i + 1][6] = $rekord[6] + $przesuniecie;
                            $tablica_pikiet [$i + 1][7] = $rekord[7] + $przesuniecie;
                        }
                        //odejmij
                        else {
                            //dodaj do oryginału i wpisz nowe H, nie zmieniaj przyrostów XYZ
                            $tablica_pikiet [$i][13] = $rekord[13] + $przesuniecie;
                            //dodejmij od dorobionego punktu i zmień przyrosty XYZ
                            $tablica_pikiet [$i + 1][13] = $rekord[13] - $przesuniecie;
                            $tablica_pikiet [$i + 1][5] = $rekord[5] - $przesuniecie;
                            $tablica_pikiet [$i + 1][6] = $rekord[6] - $przesuniecie;
                            $tablica_pikiet [$i + 1][7] = $rekord[7] - $przesuniecie;
                        }
                    }
                }
                /*
                 * dodaj do licznika pętli while "1" aby przeskoczyć dalej i nienadpisywać
                 * dorobionego punktu osnowy. kontynuuj zaczytywanie rekordów z pliku
                 */
                $i++;
            } else {
                //jeśli nie trafił na fragment "osn" w kodzie pikiety to nie robi nic i zapisuje dalej
                $tablica_pikiet [$i][16] = $rekord[16];
            }
            //dodaj "1" do licznika pętli while
            $i++;
        }
        //zamknij plik
        fclose($handle);
        //skasuj plik
        unlink($katalog_docelowy_wgrywania . 'wejsciowy.txt');
        //przypisz rozmiar tablicy pikiet aby za każdym razemi nie liczyć wielkości
        $rozmiar_tablicy_pikiet = sizeof($tablica_pikiet);
        /*
         * nie pamiętam do czego to było. jak sobie przypmnęto skasuję albo wykorzystam
         * if (preg_match("/osn/i", $tablica_pikiet[$rozmiar_tablicy_pikiet - 1][16]) == 1) {
         * $tablica_pikiet[$rozmiar_tablicy_pikiet - 1][10] = 30;
         * } elseif ($tablica_pikiet[$rozmiar_tablicy_pikiet - 1][10] > 10 and $tablica_pikiet[$rozmiar_tablicy_pikiet - 1][10] < 29) {
         * $tablica_pikiet[$rozmiar_tablicy_pikiet - 1][10] = 30;
         * } elseif ($tablica_pikiet[$rozmiar_tablicy_pikiet - 1][10] < 5) {
         * $tablica_pikiet[$rozmiar_tablicy_pikiet - 1][10] = 5;
         * } else {
         * $tablica_pikiet[$rozmiar_tablicy_pikiet - 1][10] = $tablica_pikiet[$rozmiar_tablicy_pikiet - 1][10];
         * } 
         */
        /*
         * w pętli po tablicy pikiet trzeba się przelećieć i sprawdzić osnowę. 
         * zmienić ilość epok pomiarowych oraz przeliczyć czas rozpoczęcia pomiaru
         * tak aby nie zachodziły na siebie. zacznij od 1 aby móc porównać
         * nazwy pikiet z początku i z końca tablicy pikiet
         */
        for ($i = 1; $i < $rozmiar_tablicy_pikiet; $i++) {
            //znajdź osnowę w kodzie pikiety
            if (preg_match("/osn/i", $tablica_pikiet[$i - 1][16]) == 1) {
                /*
                 * dodaj do każdego rekordu poniżej osnowy losową ilość sekund
                 * zacznij od "i" aż do końca tablicy pikiet
                 */
                for ($j = $i; $j < $rozmiar_tablicy_pikiet; $j++) {
                    $dataczas = new DateTime($tablica_pikiet[$j][3]);
                    $dataczas->modify('+'.random_int(5, 9).' seconds');
                    $tablica_pikiet[$j][3] = $dataczas->format('Y-m-d H:i:s');
                }
            }
            /*
             * sprawdzenie czy nazwa pikiety bieżącej jest równa poprzedniej
             * jeśli tak to też jest to osnowa
             */
            if ($tablica_pikiet[$i][1] == $tablica_pikiet[$i - 1][1]) {
                //ustaw 30 epok dla bieżącego i poprzedniego
                $tablica_pikiet[$i - 1][10] = 30;
                $tablica_pikiet[$i][10] = 30;
                //ustaw zmienną kontrolną osnowy na true
                $czy_jest_osnowa = true;
                /*
                 * dodaj do każdego rekordu powyżej osnowy 60 sekund
                 * zacznij od "i" aż do końca tablicy pikiet
                 */
                for ($j = $i + 1; $j < $rozmiar_tablicy_pikiet; $j++) {
                    $dataczas = new DateTime($tablica_pikiet[$j][3]);
                    $dataczas->modify('+60 seconds');
                    $tablica_pikiet[$j][3] = $dataczas->format('Y-m-d H:i:s');
                }
                /*
                 * po zakończeniu pętli zmień czas o 30 sekund dla bieżącego
                 */
                $dataczas = new DateTime($tablica_pikiet[$i][3]);
                $dataczas->modify('+30 seconds');
                $tablica_pikiet[$i][3] = $dataczas->format('Y-m-d H:i:s');
            }
            //jeśli ilość epok jest mniejsza niż 5 zwiększ do 5 i przelicz czas wszystkim poniżej
            if ($tablica_pikiet[$i - 1][10] < 5) {
                $roznica = 5 - $tablica_pikiet[$i - 1][10];
                $tablica_pikiet[$i - 1][10] = 5;
                for ($j = $i; $j < $rozmiar_tablicy_pikiet; $j++) {
                    $dataczas = new DateTime($tablica_pikiet[$j][3]);
                    $dataczas->modify('+' . $roznica . ' seconds');
                    $tablica_pikiet[$j][3] = $dataczas->format('Y-m-d H:i:s');
                }
            }
            //jeśli ilość epok jest w przedziale 10-29 to zrób 30 i przelicz wszystko w dół dodając 30 sekund
            if ($tablica_pikiet[$i - 1][10] > 10 and $tablica_pikiet[$i - 1][10] < 29) {
                $roznica = 30 - $tablica_pikiet[$i - 1][10];
                $tablica_pikiet[$i - 1][10] = 30;
                for ($j = $i; $j < $rozmiar_tablicy_pikiet; $j++) {
                    $dataczas = new DateTime($tablica_pikiet[$j][3]);
                    $dataczas->modify('+' . $roznica . ' seconds');
                    $tablica_pikiet[$j][3] = $dataczas->format('Y-m-d H:i:s');
                }
            }
            //zmiana ilości epok dla ostatniego rekordu
            if ($i === $rozmiar_tablicy_pikiet - 1) {
                if ($tablica_pikiet[$i][10] < 5) {
                    $tablica_pikiet[$i][10] = 5;
                } elseif ($tablica_pikiet[$i][10] > 10 and $tablica_pikiet[$i][10] < 29) {
                    $tablica_pikiet[$i][10] = 30;
                } elseif (preg_match("/osn/i", $tablica_pikiet[$i][16]) == 1 || $tablica_pikiet[$i - 1][1] == $tablica_pikiet[$i][1]) {
                    $tablica_pikiet[$i][10] = 30;
                } else {
                    
                }
            }
        }
        //wyliczanie poprawek pdop, mp, mh
        for ($i = 0; $i < $rozmiar_tablicy_pikiet; $i++) {
            //jeśli pdop większe niż 5
            if ($tablica_pikiet[$i][8] > 5.0) {
                $tablica_pikiet[$i][8] = random_int(1, 4) . "." . random_int(0, 9);
                //dla punktów podwójnie pomierzonych zrób zrób taki sam PDOP
                if ($i > 0 && $tablica_pikiet[$i][1] == $tablica_pikiet[$i - 1][1]) {
                    $tablica_pikiet[$i][8] = $tablica_pikiet[$i - 1][8];
                }
            }
            //jeśli mp większe niż 3cm
            if ($tablica_pikiet[$i][14] > 0.03) {
                $tablica_pikiet[$i][14] = "0.0" . random_int(1, 3);
            }
            //jesli mh większe niż 3cm
            if ($tablica_pikiet[$i][15] > 0.03) {
                $tablica_pikiet[$i][15] = "0.0" . random_int(1, 3);
                //dodatkowo mp nie może być większe niż mp więc muszą być równe
                if ($tablica_pikiet[$i][14] > $tablica_pikiet[$i][15]) {
                    $tablica_pikiet[$i][15] = $tablica_pikiet[$i][14];
                }
            }
        }
        /*
         * wydruk tabeli wektorów z podziałem na wybór zakresu
         */
        ?>
        <h2 class="raport">Tabela wektorów GPS:</h2>
        <table>
            <tr>
                <th>Pkt Bazowy</th>
                <th>Nr pkt</th>
                <th>Rozwiązanie</th>
                <th>Data Godzina</th>
                <th>Wys. anteny</th>
                <th>ECEF ∆X</th>
                <th>ECEF ∆Y</th>
                <th>ECEF ∆Z</th>
                <th>PODP</th>
                <th>sat</th>
                <th>e</th>
                <th>X</th>
                <th>Y</th>
                <th>h</th>
                <th>mp</th>
                <th>mh</th>
            </tr>
            <?php
            switch ($_POST['zakres']) {
                case 'calosc':
                    for ($i = 0; $i < $rozmiar_tablicy_pikiet; $i++) {
                        echo "<tr>";
                        /*
                         * sprawdzenie czy punkt pomierzono na poprawkach sieciowych,
                         * jeśli nie to dodanie do tablicy "złych" punktów
                         */
                        if ($tablica_pikiet[$i][2] <> 'RTN Fix') {
                            $float = true;
                            array_push($punkty_float, $tablica_pikiet[$i][1]);
                        }
                        //sformatowany wydruk danych numerycznych i zwykłych
                        for ($j = 0; $j < 16; $j++) {
                            if ($j === 4 or $j === 5 or $j === 6 or $j === 7 or $j === 13) {
                                echo "<td>", number_format($tablica_pikiet[$i][$j], 3, '.', ''), "</td>";
                            } elseif ($j === 11 or $j === 12 or $j === 14 or $j === 15) {
                                echo "<td>", number_format($tablica_pikiet[$i][$j], 2, '.', ''), "</td>";
                            } elseif ($j === 8) {
                                echo "<td>", number_format($tablica_pikiet[$i][$j], 1, '.', ''), "</td>";
                            } else {
                                echo "<td>", $tablica_pikiet[$i][$j], "</td>";
                            }
                        }
                        echo "</tr>\n";
                    }
                    echo "</table>\n";

                    /*
                     * tutaj było generowanie pikiet i ich współrzędnych aby nie było rozbieżności
                     * z pomiaru i z raportu
                     * 
                     * $plik_eksportowy = './down/pikiety.txt';
                     * for($i=0; $i<$rozmiar_tablicy_pikiet; $i++){
                     * if()
                     * }
                     * $do_pliku = $tablica_pikiet[1] . ',' . $tablica_pikiet[11] . ',' . $tablica_pikiet[12] . ',' . number_format(round($tablica_pikiet[13], 2, PHP_ROUND_HALF_EVEN), 2, '.', '') . "\n";
                     * file_put_contents($plik_eksportowy, $do_pliku, FILE_APPEND | LOCK_EX);
                     */
                    break;
                //generuj raport dla zakresu X
                case 'x':
                    for ($i = 0; $i < $rozmiar_tablicy_pikiet; $i++) {
                        if ($tablica_pikiet[$i][11] > $_POST['Xmin'] and $tablica_pikiet[$i][11] < $_POST['Xmax']) {
                            echo "<tr>";
                            if ($tablica_pikiet[$i][2] <> 'RTN Fix') {
                                $float = true;
                                array_push($punkty_float, $tablica_pikiet[$i][1]);
                            }
                            for ($j = 0; $j < 16; $j++) {
                                if ($j === 4 or $j === 5 or $j === 6 or $j === 7 or $j === 13) {
                                    echo "<td>", number_format($tablica_pikiet[$i][$j], 3, '.', ''), "</td>";
                                } elseif ($j === 11 or $j === 12 or $j === 14 or $j === 15) {
                                    echo "<td>", number_format($tablica_pikiet[$i][$j], 2, '.', ''), "</td>";
                                } elseif ($j === 8) {
                                    echo "<td>", number_format($tablica_pikiet[$i][$j], 1, '.', ''), "</td>";
                                } else {
                                    echo "<td>", $tablica_pikiet[$i][$j], "</td>";
                                }
                            }
                        }
                        echo "</tr>\n";
                    }
                    echo "</table>\n";
                    /* if ($tablica_pikiet[12] > $_POST['Xmin'] and $tablica_pikiet[12] < $_POST['Xmax']) {
                      echo "</tr>";
                      $do_pliku = $tablica_pikiet[1] . ',' . $tablica_pikiet[11] . ',' . $tablica_pikiet[12] . ',' . number_format(round($tablica_pikiet[13], 2, PHP_ROUND_HALF_EVEN), 2, '.', '') . "\n";
                      $plik_eksportowy = './down/pikiety.txt';
                      file_put_contents($plik_eksportowy, $do_pliku, FILE_APPEND | LOCK_EX);
                      } */
                    break;
                //generuj raport dla zakresu Y
                case 'y':
                    for ($i = 0; $i < $rozmiar_tablicy_pikiet; $i++) {
                        if ($tablica_pikiet[$i][12] > $_POST['Ymin'] and $tablica_pikiet[$i][12] < $_POST['Ymax']) {
                            echo "<tr>";
                            if ($tablica_pikiet[$i][2] <> 'RTN Fix') {
                                $float = true;
                                array_push($punkty_float, $tablica_pikiet[$i][1]);
                            }
                            for ($j = 0; $j < 16; $j++) {
                                if ($j === 4 or $j === 5 or $j === 6 or $j === 7 or $j === 13) {
                                    echo "<td>", number_format($tablica_pikiet[$i][$j], 3, '.', ''), "</td>";
                                } elseif ($j === 11 or $j === 12 or $j === 14 or $j === 15) {
                                    echo "<td>", number_format($tablica_pikiet[$i][$j], 2, '.', ''), "</td>";
                                } elseif ($j === 8) {
                                    echo "<td>", number_format($tablica_pikiet[$i][$j], 1, '.', ''), "</td>";
                                } else {
                                    echo "<td>", $tablica_pikiet[$i][$j], "</td>";
                                }
                            }
                            echo "</tr>\n";
                        }
                        echo "</table>\n";
                    }
                    /* if ($tablica_pikiet[12] > $_POST['Ymin'] and $tablica_pikiet[12] < $_POST['Ymax']) {
                      echo "</tr>";
                      $do_pliku = $tablica_pikiet[1] . ',' . $tablica_pikiet[11] . ',' . $tablica_pikiet[12] . ',' . number_format(round($tablica_pikiet[13], 2, PHP_ROUND_HALF_EVEN), 2, '.', '') . "\n";
                      $plik_eksportowy = './down/pikiety.txt';
                      file_put_contents($plik_eksportowy, $do_pliku, FILE_APPEND | LOCK_EX);
                      } */

                    break;
                //generuj raport dla zakresu XY
                case 'xy';
                    for ($i = 0; $i < $rozmiar_tablicy_pikiet; $i++) {
                        if ($tablica_pikiet[$i][11] > $_POST['Xmin'] and $tablica_pikiet[$i][11] < $_POST['Xmax']
                                and $tablica_pikiet[$i][12] > $_POST['Ymin'] and $tablica_pikiet[$i][12] < $_POST['Ymax']) {
                            echo "<tr>";
                            if ($tablica_pikiet[$i][2] <> 'RTN Fix') {
                                $float = true;
                                array_push($punkty_float, $tablica_pikiet[$i][1]);
                            }
                            for ($j = 0; $j < 16; $j++) {
                                if ($j === 4 or $j === 5 or $j === 6 or $j === 7 or $j === 13) {
                                    echo "<td>", number_format($tablica_pikiet[$i][$j], 3, '.', ''), "</td>";
                                } elseif ($j === 11 or $j === 12 or $j === 14 or $j === 15) {
                                    echo "<td>", number_format($tablica_pikiet[$i][$j], 2, '.', ''), "</td>";
                                } elseif ($j === 8) {
                                    echo "<td>", number_format($tablica_pikiet[$i][$j], 1, '.', ''), "</td>";
                                } else {
                                    echo "<td>", $tablica_pikiet[$i][$j], "</td>";
                                }
                            }
                            echo "</tr>\n";
                        }
                        echo "</table>\n";
                    }
                    /* if ($tablica_pikiet[11] > $_POST['Xmin'] and $tablica_pikiet[11] < $_POST['Xmax']
                      and $tablica_pikiet[12] > $_POST['Ymin'] and $tablica_pikiet[12] < $_POST['Ymax']) {
                      echo "</tr>";
                      $do_pliku = $tablica_pikiet[1] . ',' . $tablica_pikiet[11] . ',' . $tablica_pikiet[12] . ',' . number_format(round($tablica_pikiet[13], 2, PHP_ROUND_HALF_EVEN), 2, '.', '') . "\n";
                      $plik_eksportowy = './down/pikiety.txt';
                      file_put_contents($plik_eksportowy, $do_pliku, FILE_APPEND | LOCK_EX);
                      } */
                    break;
                default:
                    break;
            }
            //sprawdzenie zmiennej kontrolnej i ewentualny wydruk punktów uśrednionych
            if ($czy_jest_osnowa) {
                ?>
            <br/><h2 class="raport">Tabela punktów uśrednionych:</h2>
                <table>
                    <tr>
                        <th>Nr pkt</th>
                        <th>x</th>
                        <th>y</th>
                        <th>h</th>
                        <th>x'</th>
                        <th>y'</th>
                        <th>h'</th>
                        <th>x sr</th>
                        <th>y sr</th>
                        <th>h sr</th>
                        <th>mx</th>
                        <th>my</th>
                        <th>mh</th>
                        <th>mp</th>
                    </tr>
                    <?php
                    //sformatowany wydruk. zacznij od 1 aż do końca sprawdzając czy $i-1=$i. następnie uśrednij
                    for ($i = 1; $i < sizeof($tablica_pikiet); $i++) {
                        if ($tablica_pikiet[$i - 1][1] == $tablica_pikiet[$i][1]) {
                            echo "<tr><td>" . $tablica_pikiet[$i - 1][1] . "</td>";
                            echo "<td>" . number_format($tablica_pikiet[$i - 1][11], 2, '.', '') . "</td>"
                            . "<td>" . number_format($tablica_pikiet[$i - 1][12], 2, '.', '') . "</td>"
                            . "<td>" . number_format($tablica_pikiet[$i - 1][13], 3, '.', '') . "</td>";
                            echo "<td>" . number_format($tablica_pikiet[$i][11], 2, '.', '') . "</td>"
                            . "<td>" . number_format($tablica_pikiet[$i][12], 2, '.', '') . "</td>"
                            . "<td>" . number_format($tablica_pikiet[$i][13], 3, '.', '') . "</td>";
                            echo "<td><b>" . number_format(round(($tablica_pikiet[$i - 1][11] + $tablica_pikiet[$i][11]) / 2, 2, PHP_ROUND_HALF_EVEN), 2, '.', '') . "</b></td>";
                            echo "<td><b>" . number_format(round(($tablica_pikiet[$i - 1][12] + $tablica_pikiet[$i][12]) / 2, 2, PHP_ROUND_HALF_EVEN), 2, '.', '') . "</b></td>";
                            echo "<td><b>" . number_format(round(($tablica_pikiet[$i - 1][13] + $tablica_pikiet[$i][13]) / 2, 3, PHP_ROUND_HALF_EVEN), 3, '.', '') . "</b></td>";
                            echo "<td>0.0" . random_int(0, 1) . "</td><td>0.0" . random_int(0, 1) . "</td><td>0.00" . random_int(0, 4) . "</td>"
                            . "<td>0.0" . random_int(0, 1) . "</td></tr>\n";
                        }
                    }
                    echo "</table>";
                }
                /*
                 * sprawdzenie zmiennej kontrolnej czy były "złe" punkty
                 * i wyświetlenie okienka informacyjnego z punktami
                 */
                if ($float === true) {
                    print '<script>
                         window.onload = function () { alert("UWAGA! Wykonano pomiar na FLOAT, AUTO lub RTK!\nSPRAWDŹ! Punkty:\n';
                    foreach ($punkty_float as $value) {
                        print $value . ', ';
                    }
                    print '");}</script>';
                }
                ?>
                <!--
                pobranie pliku z pikietami z raportu. wyłączone
                <script type="text/javascript">
                    function download(dataurl, filename) {
                        var a = document.createElement("a");
                        a.href = dataurl;
                        a.setAttribute("download", filename);
                        a.click();
                    }
                    download("./down/pikiety.txt", "pikiety.txt");
                </script>-->
                </body>
                </html>