package game.utils
{
	import game.manager.StyleManager;
	
	import gameFrame.GameModel;

	public class GameConfig
	{
		public static var COOKIEISOPEN:Boolean = false;
		private var model:GameModel = GameModel.getInstance();
		public function GameConfig()
		{
		}
		public var GamePath:String;
		public var ConfigVersion:int = 1;
		public var SWFPath:String;
		private var configObj:Object;
		public var StylePath:String;
		public var GameWidth:int;
		public var GameHeight:int;
		/**
		 * 保存各类型路径信息（数据来源：config.js  configObj） 
		 * @param $obj
		 * 
		 */		
		public function init($obj:Object):void
		{
			if($obj)
			{
				configObj = $obj;
				for (var avaliable:String in $obj) 
				{
					this[avaliable] = $obj[avaliable];
				}
			}
		}
		/**
		 * 解析所有资源对象相关信息
		 * @param $configXML
		 * 
		 */		
		public function analyse($configXML:XML):void
		{
			var xmlList:XMLList;
			var i:int;
			var obj:LoadSourceVO;
			if($configXML.hasOwnProperty("preLoadSource"))
			{
				xmlList = $configXML.preLoadSource.item;
				for (i = 0; i < xmlList.length(); i++) 
				{
					obj = new LoadSourceVO(xmlList[i].@name, xmlList[i].@pathType, xmlList[i].@source, xmlList[i].@label);
					obj.fullPath = getFullPath(obj);
					model.saveLoadSourceVO(obj);
				}
			}
			if($configXML.hasOwnProperty("visualSource"))
			{
				xmlList = $configXML.visualSource.item;
				for (i = 0; i < xmlList.length(); i++) 
				{
					obj = new LoadSourceVO(xmlList[i].@name, xmlList[i].@pathType, xmlList[i].@source, xmlList[i].@label);
					obj.fullPath = getFullPath(obj);
					model.saveLoadSourceVO(obj);
				}
			}
		}
		public function getFullPath($vo:LoadSourceVO):String
		{
			switch($vo.pathType)
			{
				case StyleManager.STYLE_TYPE:
				{
					return StylePath + $vo.source + ConfigVersion;
					break;
				}
			}
			return null;
		}
		private static var _instance:GameConfig;
		public static function getInstance():GameConfig
		{
			if(_instance == null)
				_instance = new GameConfig();
			return _instance;
		}
	}
}