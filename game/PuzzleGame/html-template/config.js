function configInfo()
{
	var configObj = new Object();
	configObj.GamePath = "../puzzleWebSource/";
	configObj.ConfigVersion = 1;
	configObj.SWFPath = "../puzzleWebSource/abcswf/";
	configObj.StylePath = "../puzzleWebSource/style/";
	configObj.GameWidth = 1000;
	configObj.GameHeight = 600;
	return configObj;
}
function gameOver(score){
	alert("score: " + score);
}



