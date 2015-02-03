package gameFrame
{
	import flash.utils.Dictionary;
	
	import game.utils.Cookie;
	import game.utils.LoadSourceVO;

	public class GameModel
	{
		public var cookie:Cookie = new Cookie("PuzzleGame"); 
		private var _styleMap:Dictionary = new Dictionary();
		public function GameModel(obj:privateCls)
		{
		}
		/**
		 * 保存 LoadSourceVO对象
		 * @param $vo
		 * 
		 */		
		public function saveLoadSourceVO($vo:LoadSourceVO):void
		{
			if(!$vo || hasLoadSourceVO($vo.name))
				return;
			_styleMap[$vo.name] = $vo;
		}
		/**
		 * 批量保存 LoadSourceVO对象对象
		 * @param $obj
		 */		
		public function saveLoadSourceVOs($obj:Object):void
		{
			for (var name:String in $obj) 
			{
				if($obj[name])
				{
					var obj:LoadSourceVO = new LoadSourceVO(name, $obj[name].pathType, $obj[name].source, $obj[name].label);
					if($obj[name].hasOwnProperty("fullPath"))
						obj.fullPath = $obj[name].fullPath;
					if($obj[name].hasOwnProperty("data"))
						obj.data = $obj[name].data;
					saveLoadSourceVO(obj);
				}
			}
		}
		public function retrieveLoadSourceVO($name:String):LoadSourceVO
		{
			return _styleMap[$name];
		}
		public function hasLoadSourceVO($name:String):Boolean
		{
			return _styleMap[$name] != null;
		}
		private static var _instance:GameModel;
		public static function getInstance():GameModel
		{
			if(_instance == null)
			{
				_instance = new GameModel(new privateCls());
			}
			return _instance;
		}

		public function get styleMap():Dictionary
		{
			return _styleMap;
		}

	}
}
class privateCls{}