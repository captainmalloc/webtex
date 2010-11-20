<?php
    ini_set('max_execution_time', 600);
    include("dbconfig.php");
    $con = mysql_connect("$dbhost","$dbuser","$dbpassword");
    if (!$con)
    {
        die('Could not connect: ' . mysql_error());
    }
    
    // some code
    mysql_select_db($database, $con);
    
    $username = $_POST["username"];
    
    $query = "SELECT * FROM `" . $database . "`.`" . $table . "` WHERE name=\"" . $username . "\";";
    $result=mysql_query($query) or die(mysql_error());
    $count = mysql_num_rows($result);
    if (isset($_POST["email"]) ) {
        if ($count>0)
            //We are registering and the username already exists
            echo 1; 
        else {
            //Proced with registration: create a database antry and the user folder
            $mail = $_POST["email"];
            $password = $_POST["password"];
            $insert_query = $sql = "INSERT INTO `" . $database . "`.`" . $table . "` (`user_id`, `mail`, `name`, `pass`) VALUES (NULL, '" . $mail . "', '" . $username . "', '" . $password . "');";
            $result = mysql_query($insert_query) or die(mysql_error());
            
            $projectspath = $_POST["userspath"];
            if (mkdir($projectspath . $username)) 
                echo $username; ////The user directory
            else
                die(mysql_error());
        }       
    } else {
        if ($count>0) {
            $password = $_POST["password"];
            $row =  mysql_fetch_array($result);
            $pass = $row['pass'];
            if ($password == $pass)
                echo $username; //The user directory
            else
                //That's wrong password!
                //echo "Bad username or password";
                echo 0;
        } else {
            //That's wrong username!
            //echo "Bad username or password";
            echo 0;
        }
    }
    mysql_close($con);
?>