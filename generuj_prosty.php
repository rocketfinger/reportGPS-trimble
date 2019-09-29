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
//            $katalog_docelowy_wgrywania = "up/";
//            $plik_docelowy_wgrywania = $katalog_docelowy_wgrywania . basename($_FILES["wgraj_raport"]["name"]);
//            $wgranieOK = 1;
//            $czy_tekstowy = strtolower(pathinfo($plik_docelowy_wgrywania,PATHINFO_EXTENSION));
//            // Sprawdź czy plik istnieje
//            if (file_exists($plik_docelowy_wgrywania)) 
//            {
//                echo "Plik już istnieje. Zgłoś adminowi aby usunął ręcznie.";
//                $wgranieOK = 0;
//            }
//            // Dozwolone foramty plików
//            if($czy_tekstowy != "txt" && $czy_tekstowy != "csv") {
//                echo "Tylko pliki TXT i CSV są dozwolone.";
//                $wgranieOK = 0;
//            }
//            // Sprawdź czy wgranieOK ma wartość 0 świadczącą o błędzie
//            if ($wgranieOK == 0) {
//                echo "Jakiś błąd jest po drodze. Pliku nie wgrano.";
//            // jeśli ma wartość 1 to rób dalej
//            } else {
//                if (move_uploaded_file($_FILES["wgraj_raport"]["tmp_name"], $plik_docelowy_wgrywania)) {
//                    echo "Plik ". basename( $_FILES["wgraj_raport"]["name"]). " wgrano.";
//                    //zmień nazwę z dowolnej na standardową
//                    rename("$katalog_docelowy_wgrywania".basename( $_FILES["wgraj_raport"]["name"]), "$katalog_docelowy_wgrywania/wejsciowy.txt");
//                } else {
//                    echo "Jakiś błąd w końcowym etapie wgrywania. Spróbuj jeszcze raz.";
//                }
//            }
            ?>
        <table>
            <tr>
                <th>Pkt Bazowy</th>
                <th>Nr pkt</th>
                <th>Rozwiązanie</th>
                <th>Data</th>
                <th>Godzina</th>
                <th>Wys. anteny</th>
                <th>ECEF ∆X</th>
                <th>ECEF ∆Y</th>
                <th>ECEF ∆Z</th>
                <th>PODP</th>
                <th>RMS</th>
                <th>sat</th>
                <th>e</th>
                <th>X</th>
                <th>Y</th>
                <th>h</th>
                <th>mp</th>
                <th>mh</th>
            </tr>
            <?php
            if (($handle = fopen("up/wejsciowy.txt", "r")) !== FALSE) {
                while (($data = fgetcsv($handle, 0, ";")) !== FALSE) {
                    $num = count($data);
                    echo "<tr>";
                    for ($c=0; $c < $num; $c++) {
                        if($c===16 || $c ===17)
                        {
                            echo "<td>"; 
                            if ($data[$c]>0.04)
                            {
                                echo "0.0", rand(1,4) ,"</td>";
                            }
                            else
                            {
                                echo $data[$c] ,"</td>";
                            }
                        }
                        else
                        {
                            echo "<td> $data[$c] </td>"; 
                        }
                    }
                    echo "</tr>";
                }
                fclose($handle);
            }
        ?>
        </table>
    </body>
</html>