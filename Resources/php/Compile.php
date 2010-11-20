<?php
    //chdir(dirname($myFile));
    $myFile = stripslashes($_POST["texpath"]);
    //$command = '/usr/texbin/latexmk -pdf ' . $myFile;
    //$command = '/usr/texbin/pdflatex -output-directory=' . dirname($myFile) . ' --shell-escape --synctex=1 ' . $myFile;
    $command = '/usr/texbin/pdflatex -output-directory=' . dirname($myFile) . ' --shell-escape --synctex=1 --halt-on-error ' . $myFile;
    //$command = '/usr/texbin/pdflatex --shell-escape --synctex=1 --halt-on-error ' . $myFile;
    $shellOutput = shell_exec($command);
    echo trim($shellOutput); 
    //echo $command;
?>