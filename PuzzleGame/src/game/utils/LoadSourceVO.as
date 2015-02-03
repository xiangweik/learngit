package game.utils
{
	/**
	 * 需要加载的资源对象（与GameConfig.xml中每个item的属性一致，其中name必须唯一） 
	 * @author xw
	 * 
	 */	
	public class LoadSourceVO
	{
		private var _name:String;
		private var _pathType:String;
		private var _source:String;
		private var _label:String;
		public var data:Object;
		private var _fullPath:String;
		public function LoadSourceVO($name:String, $pathType:String, $source:String, $label:String)
		{
			_name = $name;
			_pathType = $pathType;
			_source = $source;
			_label = $label;
		}
		public function get name():String
		{
			return _name;
		}
		public function get pathType():String
		{
			return _pathType;
		}
		public function get source():String
		{
			return _source;
		}
		public function get label():String
		{
			return _label;
		}

		public function get fullPath():String
		{
			return _fullPath;
		}

		public function set fullPath(value:String):void
		{
			_fullPath = value;
		}


	}
}