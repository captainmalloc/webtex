<?php
    $dir = stripslashes($_POST["dirpath"]);
    $files = scandir($dir);
    $theData = "";
    $filter = False;
    $allowed = "";
    
    if (isset($_POST["allowedexts"])) {
        $allowed = $_POST["allowedexts"];
        $filter = True;
    }
    
    foreach ($files as $file) 
    {
        if ( ($file == ".") || ($file == "..") )
            continue;
        
        if ($filter) {
            $ext = end(explode('.', $file));
            if (strpos($ext, $allowed) !== False) //Needs === !=== because the position can be 0
                $theData .= $file . " ";
        } else {
            $theData .= $file . " ";
        }
    }
    
    echo $theData;
?>