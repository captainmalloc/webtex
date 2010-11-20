 <?php
     $target_path = $_POST["updirrelpath"];
     $usr_target_path = $_POST["usrupdirrelpath"];

	foreach ($_FILES["file"]["error"] as $key => $error) {
		if ($error == UPLOAD_ERR_OK) {
  			if (file_exists($target_path . $_FILES["file"]["name"][$key]) ) {
      			echo $_FILES["file"]["name"][$key] . " already exists.";
      		} else {
                $tmpfile = $_FILES["file"]["tmp_name"][$key];
                $finalfile = $_FILES["file"]["name"][$key];
                $finalfilepath = $target_path . $finalfile;
				move_uploaded_file($tmpfile, $finalfilepath);
                if (!file_exists($usr_target_path))
                    mkdir($usr_target_path);
                $usrfinalfilepath = $usr_target_path . $finalfile;
                copy($finalfilepath, $usrfinalfilepath);
//                $content = file_get_contents($tmpfile);
//                $fh = fopen($tmpfile, 'w');
//                $theData = fwrite($finalfile, $content);
//                fclose($fh);
      			echo $finalfilepath;
      		}
		} else {
			echo "Return Code: " . $error;
		}
	}
?>
