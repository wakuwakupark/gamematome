<?php
	

	$link = mysql_connect("mysql016.phy.lolipop.lan", "LAA0523611", "h1yahag1");
	
	if(!$link){
		die('接続失敗です。'.mysql_error());
	}
	
	// MySQLに対する処理
	
	$db_selected = mysql_select_db('LAA0523611-gamematome', $link);
	if (!$db_selected){
	    die('データベース選択失敗です。'.mysql_error());
	}

	mysql_set_charset('utf8');
	$result = mysql_query('SELECT * FROM affs');
	if (!$result) {
    	die('クエリーが失敗しました。'.mysql_error());
	}
	
	header("Content-Type: text/xml; charset=utf-8");
	echo '<?xml version="1.0" encoding="utf-8"?>
	<data>';

	//user分ループして表示
	while ($row = mysql_fetch_assoc($result) ) {
		echo '<item>';
    	echo '<affsId>'.$row['affsId'].'</affsId>';
    	echo '<title>'.$row['title'].'</title>';
    	echo '<url>'.$row['url'].'</url>';
    	echo '<siteName>'.$row['id'].'</siteName>';
		echo '</item>';
	}

	echo '</data>';

	$close_flag = mysql_close($link);

?>
