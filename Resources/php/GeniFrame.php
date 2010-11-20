<?php
    $page = "<html><head><META HTTP-EQUIV=\"CACHE-CONTROL\" CONTENT=\"NO-CACHE\"><meta http-equiv=\"Cache-Control\" content=\"no-store\" /><META HTTP-EQUIV=\"EXPIRES\" CONTENT=\"-1\"></head><body>";
    
    $relFilePath = stripslashes($_POST["pdfrelpath"]);
    $absFilePath = stripslashes($_POST["pdfabspath"]);
    
    //The date triks, avoid cache problems!
    $iFrame = "<iframe src=\"" . basename($relFilePath) . "?v=" . date("His") . "\" width=\"100%\" height=\"95%\" frameborder=\"0\"></iframe>";
    //$iFrame = "<iframe src=\"" . basename($relFilePath) . "?dummy=" . date("His") . "\" width=\"100%\" height=\"95%\" frameborder=\"0\"></iframe>";
    //$iFrame = "<iframe src=\"http://docs.google.com/gview?url=" . $absFilePath . "&embedded=true\" width=\"100%\" height=\"95%\" frameborder=\"0\"></iframe>";
    $page .= $iFrame . "</body></html>";
    
    //$object = "<object type=\"application/pdf\" data=\"" . basename($relFilePath) . "\" width=\"100%\" height=\"95%\" frameborder=\"0\"></object>";
    //$page .= $object . "</body></html>";
    
    $myFile = $relFilePath . ".html";
    $content = $page;
    $fh = fopen($myFile, 'w');
    $theData = fwrite($fh, $content);
    fclose($fh);

    echo basename($myFile);
?>