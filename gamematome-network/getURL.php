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
	$result = mysql_query('SELECT * FROM url_table');
	if (!$result) {
    	die('クエリーが失敗しました。'.mysql_error());
	}

	//user分ループして表示
	while ($row = mysql_fetch_assoc($result) ) {
		echo $row['url'];
	}

	$close_flag = mysql_close($link);

?>
