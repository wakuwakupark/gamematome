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
	$result = mysql_query('SELECT * FROM site_test');
	if (!$result) {
    	die('クエリーが失敗しました。'.mysql_error());
	}
	
	header("Content-Type: text/xml; charset=utf-8");
	echo '<?xml version="1.0" encoding="utf-8"?>
	<data>';

	//user分ループして表示
	while ($row = mysql_fetch_assoc($result) ) {
		echo '<site>';
    	echo '<site_id>'.$row['id'].'</site_id>';
    	echo '<name>'.$row['name'].'</name>';
    	echo '<contentsURL>'.$row['contentsURL'].'</contentsURL>';
    	echo '<rssURL>'.$row['rssURL'].'</rssURL>';
    	echo '<game_id>'.$row['game_id'].'</game_id>';
		echo '</site>';
	}

	echo '</data>';

	$close_flag = mysql_close($link);

?>
