package game.manager
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import game.utils.Cookie;
	import game.utils.GameConfig;
	import game.utils.GameEventConstants;
	import game.utils.LoadSourceVO;
	
	import gameFrame.GameModel;

	/**
	 * 样式管理类
	 * @author xw
	 */
	public class StyleManager extends EventDispatcher
	{
		private var isCookie:Boolean=false;
		/**swf文件加载*/
		private var urlLoader:URLLoader;
		/**等待加载的队列*/
		private var waitLoad:Dictionary=new Dictionary();
		/**正在加载的样式*/
		private var currentLoading:Object; //{name:name,isFireEvent}
		private var model:GameModel = GameModel.getInstance();
		/**样式文件库*/
		private var _styleMap:Dictionary=model.styleMap;
		private var cookie:Cookie = model.cookie;
		public function StyleManager(access:Private)
		{
		}
		private static var _instance:StyleManager;
		public static function getInstance():StyleManager
		{
			if (!_instance)
				_instance = new StyleManager(new Private());
			return _instance;
		}
		public function loadEffect($swfname:String, isFireEvent:Boolean=false):void
		{
			if (_styleMap[$swfname] && _styleMap[$swfname].data)
			{
				if (isFireEvent)
				{
//					var completeEvent:GameEvent = new GameEvent(GameEventConstants.STYLE_COMPLETE);
//					completeEvent.data=$swfname;
					var completeEvent:Event = new Event(GameEventConstants.STYLE_COMPLETE);
//					completeEvent.data=$swfname;
					dispatchEvent(completeEvent);
				}
			}
			else if (currentLoading && currentLoading.name == $swfname && isFireEvent)
			{
				currentLoading.isFireEvent=isFireEvent;
			} 
			else if (waitLoad[$swfname] && isFireEvent)
			{
				waitLoad[$swfname]=isFireEvent;
			}
			else if (!waitLoad[$swfname] && (!currentLoading || currentLoading.name != $swfname))
			{
				waitLoad[$swfname]=isFireEvent;
			}
			if (!currentLoading)
				load();
			
			return;
		}
		public function getEffect($swfname:String, name:String):MovieClip
		{
			var Cla:Class = getClass($swfname, name);
			if (Cla)
			{
				return new Cla() as MovieClip;
			}
			return null;
		}
		public function getSprite($swfname:String, name:String):Sprite
		{
			var Cla:Class = getClass($swfname, name);
			if (Cla)
			{
				return new Cla() as Sprite;
			}
			return null;
		}
		public function getBitMapData($swfname:String, name:String, bitmapWidth:int, bitmapHeight:int):BitmapData
		{
			if(name == "")
				return null;
			var Cla:Class = getClass($swfname, name);
			if (Cla)
			{
				return new Cla(bitmapWidth, bitmapHeight) as BitmapData;
			}
			return null;
		}
		public function getSimpleButton($swfname:String, name:String):SimpleButton
		{
			var Cla:Class = getClass($swfname, name);
			if (Cla)
			{
				return new Cla() as SimpleButton;
			}
			return null;
		}
		public function getClass($swfname:String, name:String):Class
		{
			var Cla:Class;
			if (_styleMap[$swfname] && (_styleMap[$swfname] as LoadSourceVO).data)
			{
				var domain:ApplicationDomain = ((_styleMap[$swfname] as LoadSourceVO).data as LoaderInfo).applicationDomain;
				if (domain.hasDefinition(name))
				{
					Cla = domain.getDefinition(name) as Class;
				}
			}
			else
			{
				loadEffect($swfname);
			}
			return Cla;
		}
		public function hasEffectLib($swfname:String):Boolean
		{
			return Boolean(_styleMap[$swfname].data);
		}
		private function load():void
		{
			if (!currentLoading)
			{
				for (var tem:String in waitLoad)
				{
					currentLoading={name: String(tem), isFireEvent: waitLoad[tem]};
					delete waitLoad[tem];
					break;
				}
				if (currentLoading)
				{
					var tag:Boolean=!isCookie;
					//从本地缓存读取
					if (isCookie)
					{
						var obj:Object=cookie.get(currentLoading.name);
						if (obj)
						{
							if (obj.version == getVersionByType(currentLoading.name))
							{
								convertToLib(obj.data);
							}
							else
							{
								cookie.remove(currentLoading.name);
								tag=true;
							}
						}
						else
						{
							tag=true;
						}
					}
					//从服务器读取
					if (tag)
					{
						if (getFileByType(currentLoading.name))
						{
							if (!urlLoader)
							{
								urlLoader=new URLLoader();
								urlLoader.dataFormat=URLLoaderDataFormat.BINARY;
								urlLoader.addEventListener(Event.COMPLETE, urlLoadCompleteHandler);
								urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoadIoErrorHandler);
								urlLoader.addEventListener(ProgressEvent.PROGRESS, urlLoadProgressHandler);
							}
							urlLoader.load(new URLRequest(getFileByType(currentLoading.name)));
							//							trace( getFileByType(currentLoading.name) , "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" )
						}
						else
						{
							currentLoading=null;
							load();
						}
					}
				}
				else //无等待队列
				{
					if (urlLoader)
					{
						urlLoader.addEventListener(Event.COMPLETE, urlLoadCompleteHandler);
						urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoadIoErrorHandler);
						urlLoader.addEventListener(ProgressEvent.PROGRESS, urlLoadProgressHandler);
						urlLoader.close();
						urlLoader=null;
					}
				}
			}
			return;
		}
		private function urlLoadCompleteHandler(evt:Event):void
		{
			if (isCookie && cookie.status == 0 && !GameConfig.COOKIEISOPEN) //检查是否放入地本缓存
			{
				cookie.status=-1;
			}
			else if (isCookie && cookie.status == 1 && currentLoading)
			{
				cookie.put(currentLoading.name, {version: getVersionByType(currentLoading.name), data: urlLoader.data as ByteArray});
			}
			convertToLib(urlLoader.data as ByteArray);
			return;
		}
		private function urlLoadIoErrorHandler(evt:IOErrorEvent):void
		{
			currentLoading=null;
			load();
			return;
		}
		private var tempLoader:Loader;
		/**
		 * 转换加载的内容,使之容入到库中.
		 * @param data
		 *
		 */
		private function convertToLib(data:ByteArray):void
		{
			tempLoader=new Loader();
			tempLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onLoaderComplete);
			tempLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			tempLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			tempLoader.loadBytes(data, new LoaderContext(false));
			return;
		}
		private var isLoadBytesOver:Boolean;
		private function onProgress(e:ProgressEvent):void
		{
			trace(tempLoader.contentLoaderInfo.bytesLoaded, tempLoader.contentLoaderInfo.bytesTotal);
		}
		private function onError(e:IOErrorEvent):void
		{
			
			tempLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _onLoaderComplete);
			tempLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			tempLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
//			var errorEvent:GameEvent=new GameEvent(GameEventConstants.STYLE_IOERROR);
//			errorEvent.data=currentLoading.name;
			var errorEvent:Event=new Event(GameEventConstants.STYLE_IOERROR);
//			errorEvent.data=currentLoading.name;
			dispatchEvent(errorEvent);
		}
		private function _onLoaderComplete(evt:Event):void
		{
			_styleMap[currentLoading.name].data=tempLoader.contentLoaderInfo;
			
			tempLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			tempLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _onLoaderComplete);
			tempLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			tempLoader=null;
			if (currentLoading.isFireEvent)
			{
				var e:Event = new Event(GameEventConstants.STYLE_COMPLETE, true);
//				var e:GameEvent = new GameEvent(GameEventConstants.STYLE_COMPLETE, true);
//				e.data = currentLoading.name;
				dispatchEvent(e);
			}
			currentLoading=null;
			load();
			return;
		}
		private function urlLoadProgressHandler(e:ProgressEvent):void
		{
//			var completeEvent:GameEvent=new GameEvent(GameEventConstants.STYLE_PROGRESS);
			var completeEvent:Event =new Event(GameEventConstants.STYLE_PROGRESS);
//			completeEvent.data=e;
			this.dispatchEvent(completeEvent);
		}
		private function getFileByType($name:String):String
		{
			if(model.hasLoadSourceVO($name))
				return model.retrieveLoadSourceVO($name).fullPath;
			return null;
		}
		private function getVersionByType($name:String):int
		{
			return 1;
		}
		public static const PRE_LOADSWFNAME:String = "PreLoad";
		public static const MAIN_SWFNAME:String = "MainStyle";
		public static const BEE_SWFNAME:String = "Bee";
		public static const DOLPHIN_SWFNAME:String = "Dolphin";
		public static const GIRAFFE_SWFNAME:String = "Giraffe";
		public static const PANDA_SWFNAME:String = "Panda";
		public static const RABBIT_SWFNAME:String = "Rabbit";
		
		/***样式文件类型*/
		public static const STYLE_TYPE:String = "StylePath";
	}
}
class Private
{
}
