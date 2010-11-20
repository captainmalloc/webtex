<?php
    $myFile = stripslashes($_POST["texpath"]);
    
    $content = $_POST["texcontent"]; //hornet
    //$content = stripslashes($_POST["texcontent"]); //scoditti.com
    
    $fh = fopen($myFile, 'w');
    $theData = fwrite($fh, $content);
    fclose($fh);
    echo $content;
    ?>