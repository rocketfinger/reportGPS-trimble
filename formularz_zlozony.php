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
         Wczytaj plik raportu (bez danych nagłówków! z searatorem ; ):<br>a
        <form name="wgraj" action="generuj_prosty.php" method="POST" enctype="multipart/form-data">
            <input type="file" name="wgraj_raport"><br>
            <input type="submit" value="Wyślij" name="wyslij">
        </form>
         
<!--         <form action="generuj_prosty.php" method="post" enctype="multipart/form-data">
    Select image to upload:
    <input type="file" name="fileToUpload" id="fileToUpload">
    <input type="submit" value="Upload Image" name="submit">
</form>-->
    </body>
</html>
