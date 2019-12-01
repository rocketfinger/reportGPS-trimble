<!DOCTYPE html>
<!--
To change this license header, choose License Headers in Project Properties.
To change this template file, choose Tools | Templates
and open the template in the editor.
-->
<html>
    <head>
        <meta charset="UTF-8">
        <title>Raport GPS ver. 0.0.3</title>
        <style>
            table, th, td {
                border: 1px solid black;
                text-align: center;
            }
        </style>
    </head>
    <body>
        <?php
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
        ?>
        <h2>Tabela wektorów GPS:</h2>
        <table>
            <tr>
            <b>
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
            </b>
        </tr>
        <?php
        $float = 0;
        $punkty_float = [];
        $tablica_pikiet = array(array("0baza", "1nr_pkt", "2rtn-fix", "3data czas", "4tyczka", "5dx", "6dy", "7dz", "8pdop",
                "9sat", "10epoki", "11x", "12y", "13h", "14mp", "15mh", "16kod"));
        $i = 0;
        $czy_jest_osnowa = false;
        $handle = fopen("up/wejsciowy.txt", "r");
        while (($rekord = fgetcsv($handle, 0, ",")) !== FALSE) {
            for ($j = 0; $j < 17; $j++) {
                $tablica_pikiet[$i][$j] = $rekord[$j];
            }
            if (preg_match("/osn/i", $rekord[16]) == 1) {
                //$tablica_pikiet[$i][10] = 30;
                $czy_jest_osnowa = true;
                $tablica_pikiet[$i][16] = $rekord[16];
                for ($j = 0; $j < 17; $j++) {
                    $tablica_pikiet [$i + 1][$j] = $rekord[$j];
                    //$tablica_pikiet[$i+1][10] = 30;
                    if ($j === 13) {
                        $znak = random_int(0, 1);
                        $przesuniecie = "0.00" . random_int(1, 4);
                        if ($znak === 0) {
                            $tablica_pikiet [$i][$j] = $rekord[$j] - $przesuniecie;
                            $tablica_pikiet [$i + 1][$j] = $rekord[$j] + $przesuniecie;
                            $tablica_pikiet [$i + 1][5] = $rekord[5] + $przesuniecie;
                            $tablica_pikiet [$i + 1][6] = $rekord[6] + $przesuniecie;
                            $tablica_pikiet [$i + 1][7] = $rekord[7] + $przesuniecie;
                        } else {
                            $tablica_pikiet [$i][$j] = $rekord[$j] + $przesuniecie;
                            $tablica_pikiet [$i + 1][$j] = $rekord[$j] - $przesuniecie;
                            $tablica_pikiet [$i + 1][5] = $rekord[5] - $przesuniecie;
                            $tablica_pikiet [$i + 1][6] = $rekord[6] - $przesuniecie;
                            $tablica_pikiet [$i + 1][7] = $rekord[7] - $przesuniecie;
                        }
                    }
                }
                $i++;
            } else {
                $tablica_pikiet [$i][16] = $rekord[16];
            }
            $i++;
        }
        fclose($handle);
        unlink($katalog_docelowy_wgrywania . 'wejsciowy.txt');
        $rozmiar_tablicy_pikiet = sizeof($tablica_pikiet);
        /* if (preg_match("/osn/i", $tablica_pikiet[$rozmiar_tablicy_pikiet - 1][16]) == 1) {
          $tablica_pikiet[$rozmiar_tablicy_pikiet - 1][10] = 30;
          } elseif ($tablica_pikiet[$rozmiar_tablicy_pikiet - 1][10] > 10 and $tablica_pikiet[$rozmiar_tablicy_pikiet - 1][10] < 29) {
          $tablica_pikiet[$rozmiar_tablicy_pikiet - 1][10] = 30;
          } elseif ($tablica_pikiet[$rozmiar_tablicy_pikiet - 1][10] < 5) {
          $tablica_pikiet[$rozmiar_tablicy_pikiet - 1][10] = 5;
          } else {
          $tablica_pikiet[$rozmiar_tablicy_pikiet - 1][10] = $tablica_pikiet[$rozmiar_tablicy_pikiet - 1][10];
          } */
        for ($i = 1; $i < $rozmiar_tablicy_pikiet; $i++) {
            if (preg_match("/osn/i", $tablica_pikiet[$i - 1][16]) == 1) {
                $tablica_pikiet[$i - 1][10] = 30;
                for ($j = $i; $j < $rozmiar_tablicy_pikiet; $j++) {
                    $dataczas = new DateTime($tablica_pikiet[$j][3]);
                    $dataczas->add(new DateInterval('P0Y0M0DT0H0M3' . random_int(3, 9) . 'S'));
                    $tablica_pikiet[$j][3] = $dataczas->format('Y-m-d H:i:s');
                }
            }
            if ($tablica_pikiet[$i - 1][10] < 5) {
                $roznica = 5 - $tablica_pikiet[$i - 1][10];
                $tablica_pikiet[$i - 1][10] = 5;
                for ($j = $i; $j < $rozmiar_tablicy_pikiet; $j++) {
                    $dataczas = new DateTime($tablica_pikiet[$j][3]);
                    $dataczas->add(new DateInterval('P0Y0M0DT0H0M0' . $roznica . 'S'));
                    $tablica_pikiet[$j][3] = $dataczas->format('Y-m-d H:i:s');
                }
            }
            if ($tablica_pikiet[$i - 1][10] > 10 and $tablica_pikiet[$i - 1][10] < 29) {
                $tablica_pikiet[$i - 1][10] = 30;
                for ($j = $i; $j < $rozmiar_tablicy_pikiet; $j++) {
                    $dataczas = new DateTime($tablica_pikiet[$j][3]);
                    $dataczas->add(new DateInterval('P0Y0M0DT0H0M30S'));
                    $tablica_pikiet[$j][3] = $dataczas->format('Y-m-d H:i:s');
                }
            }
        }
        for ($i = 0; $i < $rozmiar_tablicy_pikiet; $i++) {
            if ($tablica_pikiet[$i][8] > 5.0) {
                $tablica_pikiet[$i][8] = random_int(1, 4) . "." . random_int(0, 9);
            }
            if ($tablica_pikiet[$i][14] > 0.03) {
                $tablica_pikiet[$i][14] = "0.0" . random_int(1, 3);
            }
            if ($tablica_pikiet[$i][15] > 0.03) {
                $tablica_pikiet[$i][15] = "0.0" . random_int(1, 3);
                if ($tablica_pikiet[$i][14] > $tablica_pikiet[$i][15]) {
                    $tablica_pikiet[$i][15] = $tablica_pikiet[$i][14];
                }
            }
        }
        switch ($_POST['zakres']) {
            case 'calosc':
                for ($i = 0; $i < $rozmiar_tablicy_pikiet; $i++) {
                    echo "<tr>";
                    if ($tablica_pikiet[$i][2] <> 'RTN Fix') {
                        $float = 1;
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
                echo "</tr></table>";
                if ($czy_jest_osnowa) {
                    ?>
                    <br/><h2>Tabela punktów uśrednionych:</h2>
                    <table>
                        <tr>
                        <b>
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
                        </b>
                        </tr>
                        <?php
                        for ($i = 1; $i < sizeof($tablica_pikiet); $i++) {
                            if ($tablica_pikiet[$i - 1][1] === $tablica_pikiet[$i][1]) {
                                echo "<tr><td>" . $tablica_pikiet[$i - 1][1] . "</td>";
                                echo "<td>" . number_format($tablica_pikiet[$i - 1][11], 2, '.', '') . "</td>"
                                . "<td>" . number_format($tablica_pikiet[$i - 1][12], 2, '.', '') . "</td>"
                                . "<td>" . number_format($tablica_pikiet[$i - 1][13], 3, '.', '') . "</td>";
                                echo "<td>" . number_format($tablica_pikiet[$i][11], 2, '.', '') . "</td>"
                                . "<td>" . number_format($tablica_pikiet[$i][12], 2, '.', '') . "</td>"
                                . "<td>" . number_format($tablica_pikiet[$i][13], 3, '.', '') . "</td>";
                                echo "<td>" . number_format(round(($tablica_pikiet[$i - 1][11] + $tablica_pikiet[$i][11]) / 2, 2, PHP_ROUND_HALF_EVEN), 2, '.', '') . "</td>";
                                echo "<td>" . number_format(round(($tablica_pikiet[$i - 1][12] + $tablica_pikiet[$i][12]) / 2, 2, PHP_ROUND_HALF_EVEN), 2, '.', '') . "</td>";
                                echo "<td>" . number_format(round(($tablica_pikiet[$i - 1][13] + $tablica_pikiet[$i][13]) / 2, 3, PHP_ROUND_HALF_EVEN), 3, '.', '') . "</td>";
                                echo "<td>0.0" . random_int(0, 1) . "</td><td>0.0" . random_int(0, 1) . "</td><td>0.00" . random_int(0, 4) . "</td>"
                                . "<td>0.0" . random_int(0, 1) . "</td></tr>";
                            }
                        }
                        echo "</tr></table>";
                    }
                    /* $plik_eksportowy = './down/pikiety.txt';
                      for($i=0; $i<$rozmiar_tablicy_pikiet; $i++){
                      if()
                      } */
                    // $do_pliku = $tablica_pikiet[1] . ',' . $tablica_pikiet[11] . ',' . $tablica_pikiet[12] . ',' . number_format(round($tablica_pikiet[13], 2, PHP_ROUND_HALF_EVEN), 2, '.', '') . "\n";
                    //file_put_contents($plik_eksportowy, $do_pliku, FILE_APPEND | LOCK_EX);
                    break;
                case 'x':
                    for ($i = 0; $i < $rozmiar_tablicy_pikiet; $i++) {
                        if ($tablica_pikiet[$i][11] > $_POST['Xmin'] and $tablica_pikiet[$i][11] < $_POST['Xmax']) {
                            echo "<tr>";
                            if ($tablica_pikiet[$i][2] <> 'RTN Fix') {
                                $float = 1;
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
                    }
                    echo "</tr></table>";
                    //if ($tablica_pikiet[12] > $_POST['Xmin'] and $tablica_pikiet[12] < $_POST['Xmax']) {
                    //echo "</tr>";
                    /* $do_pliku = $tablica_pikiet[1] . ',' . $tablica_pikiet[11] . ',' . $tablica_pikiet[12] . ',' . number_format(round($tablica_pikiet[13], 2, PHP_ROUND_HALF_EVEN), 2, '.', '') . "\n";
                      $plik_eksportowy = './down/pikiety.txt';
                      file_put_contents($plik_eksportowy, $do_pliku, FILE_APPEND | LOCK_EX); */
                    //}
                    break;
                case 'y':
                    for ($i = 0; $i < $rozmiar_tablicy_pikiet; $i++) {
                        if ($tablica_pikiet[$i][12] > $_POST['Ymin'] and $tablica_pikiet[$i][12] < $_POST['Ymax']) {
                            echo "<tr>";
                            if ($tablica_pikiet[$i][2] <> 'RTN Fix') {
                                $float = 1;
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
                        echo "</tr></table>";
                    }
                    /* if ($tablica_pikiet[12] > $_POST['Ymin'] and $tablica_pikiet[12] < $_POST['Ymax']) {
                      echo "</tr>";
                      $do_pliku = $tablica_pikiet[1] . ',' . $tablica_pikiet[11] . ',' . $tablica_pikiet[12] . ',' . number_format(round($tablica_pikiet[13], 2, PHP_ROUND_HALF_EVEN), 2, '.', '') . "\n";
                      $plik_eksportowy = './down/pikiety.txt';
                      file_put_contents($plik_eksportowy, $do_pliku, FILE_APPEND | LOCK_EX);
                      } */

                    break;
                case 'xy';
                    for ($i = 0; $i < $rozmiar_tablicy_pikiet; $i++) {
                        if ($tablica_pikiet[$i][11] > $_POST['Xmin'] and $tablica_pikiet[$i][11] < $_POST['Xmax']
                                and $tablica_pikiet[$i][12] > $_POST['Ymin'] and $tablica_pikiet[$i][12] < $_POST['Ymax']) {
                            echo "<tr>";
                            if ($tablica_pikiet[$i][2] <> 'RTN Fix') {
                                $float = 1;
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
                        echo "</tr></table>";
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
            ?>

            <?php
            if ($float === 1) {
                print '<script type="text/javascript">
                 window.onload = function () { alert("UWAGA! Wykonano pomiar na FLOAT, AUTO lub RTK!\nSPRAWDŹ! Punkty:\n';
                foreach ($punkty_float as $value) {
                    print $value . ', ';
                }
                print '");}</script>';
            }
            ?><!--
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