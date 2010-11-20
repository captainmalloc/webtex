<?php
    //$myFile = "Main.tex";
    
    //$_PHP_AUTH_USER = "adriano";
    //$_PHP_AUTH_PW = "Ano2Server";
    //$_AUTH_TYPE = "Basic";
    
    /*
    if (!isset($_SERVER['PHP_AUTH_USER'])) {
        header('WWW-Authenticate: Basic realm=""');
        header('HTTP/1.0 401 Unauthorized');
        echo "Texte utilisé si le visiteur utilise le bouton d\'annulation";
        exit;
    } else {
        echo "<p>Bonjour, {$_SERVER['PHP_AUTH_USER']}.</p>";
        echo "<p>Votre mot de passe est {$_SERVER['PHP_AUTH_PW']}.</p>";
    }
    */
    
    /*
    $url = stripslashes($_POST["texpath"]);
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    //curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_ANY);
    //curl_setopt($ch, CURLOPT_USERPWD, 'adriano:Ano2Server');
    curl_setopt($ch, CURLOPT_FORBID_REUSE, true);
    curl_setopt($ch, CURLOPT_FRESH_CONNECT, true);
    curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows; U; Windows NT 6.0; da; rv:1.9.0.11) Gecko/2009060215 Firefox/3.0.11');
    $contents = curl_exec($ch);
    if ($contents === false) {
        trigger_error('Failed to execute cURL session: ' . curl_error($ch), E_USER_ERROR);
    }
    echo $contents;
    */
    
    
//    $myFile = stripslashes($_POST["texpath"]);
//    $fh = fopen($myFile, 'r');
//    $theData = fread($fh, filesize($myFile));
//    fclose($fh);
//    echo $theData;
    
    $myFile = stripslashes($_POST["texpath"]);
    $theData = file_get_contents($myFile);
    echo $theData;
?>