package
{
	public class GameConfig
	{
		public function GameConfig()
		{
		}
		public var GamePath:String = "";
		public var SWFPath:String = "";
		public var StylePath:String = "";
		public var ConfigVersion:int;
		public var configObj:Object = {};
		public var GameWidth:int;
		public var GameHeight:int;
		public function init($obj:Object):void
		{
			configObj = $obj;
			if(!$obj)
				return;
			for (var attributes:String in $obj) 
			{
				this[attributes] =$obj[attributes];
			}
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