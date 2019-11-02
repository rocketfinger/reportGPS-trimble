<!DOCTYPE html>
<!--
To change this license header, choose License Headers in Project Properties.
To change this template file, choose Tools | Templates
and open the template in the editor.
-->
<html>
    <head>
        <meta charset="UTF-8">
        <title>Raport GPS ver. 0.0.1</title>
        <style>
            table, th, td {
                border: 1px solid black;
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
            $float = 0;
            $punkty_float = [];
            if (($handle = fopen("up/wejsciowy.txt", "r")) !== FALSE) {
                while (($data = fgetcsv($handle, 0, ";")) !== FALSE) {
                    $num = count($data);
                    switch ($_POST['zakres']) {
                        case 'calosc':
                            if ($data[2] <> 'RTN Fix') {
                                $float = 1;
                                array_push($punkty_float, $data[1]);
                            }
                            echo "<tr>";
                            for ($c = 0; $c < $num; $c++) {
                                if ($c === 3) {
                                    if ($data[10] < 5) {
                                        $dataczas = new DateTime($data[$c]);
                                        $dataczas->add(new DateInterval('P0Y0M0DT0H0M05S'));
                                        echo "<td>", $dataczas->format('Y-m-d H:i:s'), "</td>";
                                    } else {
                                        echo "<td>", strip_tags($data[$c]), "</td>";
                                    }
                                } elseif ($c === 8) {
                                    echo "<td>";
                                    if ($data[$c] > 5.0) {
                                        echo "4.", random_int(0, 9), "</td>";
                                    } else {
                                        echo strip_tags($data[$c]), "</td>";
                                    }
                                } elseif ($c === 10) {
                                    echo "<td>";
                                    if (5 - $data[$c] > 0) {
                                        echo "5</td>";
                                    } else {
                                        echo strip_tags($data[$c]), "</td>";
                                    }
                                } elseif ($c === 14 || $c === 15) {
                                    echo "<td>";
                                    if ($data[$c] > 0.03) {
                                        echo "0.0", random_int(1, 3), "</td>";
                                    } else {
                                        echo strip_tags($data[$c]), "</td>";
                                    }
                                } else {
                                    echo "<td>", strip_tags($data[$c]), "</td>";
                                }
                            }
                            echo "</tr>";
                            $do_pliku = $data[1] . ',' . $data[11] . ',' . $data[12] . ',' . number_format(round($data[13], 2, PHP_ROUND_HALF_EVEN), 2, '.', '') . "\n";
                            $plik_eksportowy = './down/pikiety.txt';
                            file_put_contents($plik_eksportowy, $do_pliku, FILE_APPEND | LOCK_EX);
                            break;

                        case 'x':
                            if ($data[11] > $_POST['Xmin'] and $data[11] < $_POST['Xmax']) {
                                if ($data[2] <> 'RTN Fix') {
                                    $float = 1;
                                    array_push($punkty_float, $data[1]);
                                }
                                echo "<tr>";
                            }
                            for ($c = 0; $c < $num; $c++) {
                                if ($data[11] > $_POST['Xmin'] and $data[11] < $_POST['Xmax']) {
                                    if ($c === 3) {
                                        if ($data[10] < 5) {
                                            $dataczas = new DateTime($data[$c]);
                                            $dataczas->add(new DateInterval('P0Y0M0DT0H0M05S'));
                                            echo "<td>", $dataczas->format('Y-m-d H:i:s'), "</td>";
                                        } else {
                                            echo "<td>", strip_tags($data[$c]), "</td>";
                                        }
                                    } elseif ($c === 8) {
                                        echo "<td>";
                                        if ($data[$c] > 5.0) {
                                            echo "4.", random_int(0, 9), "</td>";
                                        } else {
                                            echo strip_tags($data[$c]), "</td>";
                                        }
                                    } elseif ($c === 10) {
                                        echo "<td>";
                                        if (5 - $data[$c] > 0) {
                                            echo "5</td>";
                                        } else {
                                            echo strip_tags($data[$c]), "</td>";
                                        }
                                    } elseif ($c === 14 || $c === 15) {
                                        echo "<td>";
                                        if ($data[$c] > 0.03) {
                                            echo "0.0", random_int(1, 3), "</td>";
                                        } else {
                                            echo strip_tags($data[$c]), "</td>";
                                        }
                                    } else {
                                        echo "<td>", strip_tags($data[$c]), "</td>";
                                    }
                                }
                            }
                            if ($data[11] > $_POST['Xmin'] and $data[11] < $_POST['Xmax']) {
                                echo "</tr>";
                            $do_pliku = $data[1] . ',' . $data[11] . ',' . $data[12] . ',' . number_format(round($data[13], 2, PHP_ROUND_HALF_EVEN), 2, '.', '') . "\n";
                            $plik_eksportowy = './down/pikiety.txt';
                            file_put_contents($plik_eksportowy, $do_pliku, FILE_APPEND | LOCK_EX);
                            }
                            break;

                        case 'y':
                            if ($data[12] > $_POST['Ymin'] and $data[12] < $_POST['Ymax']) {
                                if ($data[2] <> 'RTN Fix') {
                                    $float = 1;
                                    array_push($punkty_float, $data[1]);
                                    echo "<tr>";
                                }
                                for ($c = 0; $c < $num; $c++) {
                                    if ($data[12] > $_POST['Ymin'] and $data[12] < $_POST['Ymax']) {
                                        
                                    }if ($c === 3) {
                                        if ($data[10] < 5) {
                                            $dataczas = new DateTime($data[$c]);
                                            $dataczas->add(new DateInterval('P0Y0M0DT0H0M05S'));
                                            echo "<td>", $dataczas->format('Y-m-d H:i:s'), "</td>";
                                        } else {
                                            echo "<td>", strip_tags($data[$c]), "</td>";
                                        }
                                    } elseif ($c === 8) {
                                        echo "<td>";
                                        if ($data[$c] > 5.0) {
                                            echo "4.", random_int(0, 9), "</td>";
                                        } else {
                                            echo strip_tags($data[$c]), "</td>";
                                        }
                                    } elseif ($c === 10) {
                                        echo "<td>";
                                        if (5 - $data[$c] > 0) {
                                            echo "5</td>";
                                        } else {
                                            echo strip_tags($data[$c]), "</td>";
                                        }
                                    } elseif ($c === 14 || $c === 15) {
                                        echo "<td>";
                                        if ($data[$c] > 0.03) {
                                            echo "0.0", random_int(1, 3), "</td>";
                                        } else {
                                            echo strip_tags($data[$c]), "</td>";
                                        }
                                    } else {
                                        echo "<td>", strip_tags($data[$c]), "</td>";
                                    }
                                }
                            }
                            if ($data[12] > $_POST['Ymin'] and $data[12] < $_POST['Ymax']) {
                                echo "</tr>";
                            $do_pliku = $data[1] . ',' . $data[11] . ',' . $data[12] . ',' . number_format(round($data[13], 2, PHP_ROUND_HALF_EVEN), 2, '.', '') . "\n";
                            $plik_eksportowy = './down/pikiety.txt';
                            file_put_contents($plik_eksportowy, $do_pliku, FILE_APPEND | LOCK_EX);
                            }

                            break;

                        case 'xy';
                            if ($data[11] > $_POST['Xmin'] and $data[11] < $_POST['Xmax']
                                    and $data[12] > $_POST['Ymin'] and $data[12] < $_POST['Ymax']) {
                                if ($data[2] <> 'RTN Fix') {
                                    $float = 1;
                                    array_push($punkty_float, $data[1]);
                                }
                                echo "<tr>";
                            }
                            for ($c = 0; $c < $num; $c++) {

                                if ($data[11] > $_POST['Xmin'] and $data[11] < $_POST['Xmax']
                                        and $data[12] > $_POST['Ymin'] and $data[12] < $_POST['Ymax']) {
                                    if ($c === 3) {
                                        if ($data[10] < 5) {
                                            $dataczas = new DateTime($data[$c]);
                                            $dataczas->add(new DateInterval('P0Y0M0DT0H0M05S'));
                                            echo "<td>", $dataczas->format('Y-m-d H:i:s'), "</td>";
                                        } else {
                                            echo "<td>", strip_tags($data[$c]), "</td>";
                                        }
                                    } elseif ($c === 8) {
                                        echo "<td>";
                                        if ($data[$c] > 5.0) {
                                            echo "4.", random_int(0, 9), "</td>";
                                        } else {
                                            echo strip_tags($data[$c]), "</td>";
                                        }
                                    } elseif ($c === 10) {
                                        echo "<td>";
                                        if (5 - $data[$c] > 0) {
                                            echo "5</td>";
                                        } else {
                                            echo strip_tags($data[$c]), "</td>";
                                        }
                                    } elseif ($c === 14 || $c === 15) {
                                        echo "<td>";
                                        if ($data[$c] > 0.03) {
                                            echo "0.0", random_int(1, 3), "</td>";
                                        } else {
                                            echo strip_tags($data[$c]), "</td>";
                                        }
                                    } else {
                                        echo "<td>", strip_tags($data[$c]), "</td>";
                                    }
                                }
                            }
                            if ($data[11] > $_POST['Xmin'] and $data[11] < $_POST['Xmax']
                                    and $data[12] > $_POST['Ymin'] and $data[12] < $_POST['Ymax']) {
                                echo "</tr>";
                            $do_pliku = $data[1] . ',' . $data[11] . ',' . $data[12] . ',' . number_format(round($data[13], 2, PHP_ROUND_HALF_EVEN), 2, '.', '') . "\n";
                            $plik_eksportowy = './down/pikiety.txt';
                            file_put_contents($plik_eksportowy, $do_pliku, FILE_APPEND | LOCK_EX);
                            }
                            break;

                        default:
                            break;
                    }
                }
                fclose($handle);
            }
            unlink($katalog_docelowy_wgrywania . 'wejsciowy.txt');
            ?>
        </table>
        <?php
        if ($float === 1) {
            print '<script type="text/javascript">
                 window.onload = function () { alert("UWAGA! Wykonano pomiar na FLOAT, AUTO lub RTK!\nSPRAWDŹ! Punkty:\n';
            foreach ($punkty_float as $value) {
                print $value . '\n';
            }
            print '");}</script>';
        }
        ?>
        <script type="text/javascript">
            function download(dataurl, filename) {
                var a = document.createElement("a");
                a.href = dataurl;
                a.setAttribute("download", filename);
                a.click();
            }
            download("./down/pikiety.txt", "pikiety.txt");
        </script>
    </body>
</html>