package
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	[Frame(factoryClass="PreLoader")]
	[SWF(backgroundColor="#000000"  )] 
	public class PuzzleGameLoading extends Sprite
	{
		[Embed(source="assets/loadingbg2.png")]                
		public static var LOADINGBG:Class;
		private var config:GameConfig = GameConfig.getInstance();
		private static const ENTER_GAME:String = "enterGame";
//		private var _maskRight:Shape;
		private var _preLoader:Object
		public function PuzzleGameLoading($stage:Object)
		{
			Security.allowDomain("*");
			_preLoader = $stage;
//			_maskRight = new Shape();
//			_maskRight.x = 1300;
//			_maskRight.graphics.beginFill(0x0);
//			_maskRight.graphics.drawRect(0,0,332,660);
//			_maskRight.graphics.endFill();
//			addChild( _maskRight );
			config.init(ExternalInterface.call("configInfo"));
		}
		private var sprite:Sprite;
		private var logo:DisplayObject;
//		private var awardTip:TextField;
		private var currLoadText:TextField;
		private var currText:String;
//		private var progress:ProgressCav;
		private var progressTotal:ProgressCav;
		private var xmlLoader:URLLoader;
		private var urlStr:String;
		public function init():void
		{
			sprite = new Sprite();
			addChild( sprite );
			var cl:Class = LOADINGBG;
			logo = new cl();
			logo.x = (config.GameWidth - logo.width) / 2; 
			logo.y = (config.GameHeight - logo.height) / 2;
			sprite.addChild( logo );
//			awardTip = new TextField();
//			awardTip.width = 700;
//			awardTip.autoSize = TextFieldAutoSize.CENTER;
//			awardTip.x = (config.GameWidth - awardTip.width)/2;
//			awardTip.y = 460;
//			sprite.addChild( awardTip );
//			awardTip.htmlText = "<font color='#8b8b8a'>抵制不良游戏  拒绝盗版游戏  注意自我保护  谨防受骗上当  适度游戏益脑  沉迷游戏伤身  合理安排时间  享受健康生活</font>";
			
			currLoadText = new TextField();
			currText = "加载游戏所需的配置文件";
			currLoadText.width = 300;
			currLoadText.textColor = 0xffffff;
			currLoadText.filters = [glowFilter];
			currLoadText.x = (config.GameWidth - currLoadText.width) / 2;
			currLoadText.y = 490;	
			currLoadText.autoSize = TextFieldAutoSize.CENTER;
			currLoadText.mouseEnabled = false;
			sprite.addChild( currLoadText );
			
//			progress = new ProgressCav();
//			progress.x = (config.GameWidth-521)/2;
//			progress.y = currLoadText.y + 20;
//			progress.setValue( 0 );
//			sprite.addChild( progress );
			
			progressTotal = new ProgressCav();
			progressTotal.x = (config.GameWidth-521)/2;
			progressTotal.y = 312;
			progressTotal.setValue(0);
			sprite.addChild( progressTotal );
			
//			progress.visible = false;
			progressTotal.visible = false;

			if( !hasEventListener(Event.ENTER_FRAME) )
				addEventListener(Event.ENTER_FRAME , onEnterFrame);
			xmlLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, xmlLoadCompleteListener);
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR , xmlLoadErrorListener);
			loadXmlFile();
		}
		private function loadXmlFile():void
		{
			currText = "加载游戏配置文件";
			urlStr = config.GamePath + "data/GameConfig.xml?v=" + config.ConfigVersion;
			xmlLoader.load(new URLRequest(urlStr));
		}
		private function destroyXmlLoader():void
		{
			if(xmlLoader)
			{
				if(xmlLoader.hasEventListener(Event.COMPLETE))
				{
					xmlLoader.removeEventListener(Event.COMPLETE, xmlLoadCompleteListener);
				}
				if(xmlLoader.hasEventListener(IOErrorEvent.IO_ERROR))
				{
					xmlLoader.removeEventListener(IOErrorEvent.IO_ERROR, xmlLoadErrorListener);
				}
				xmlLoader = null;
			}
		}
		private var xmlFailCount:int;
		protected function xmlLoadErrorListener(event:IOErrorEvent):void
		{
			// TODO Auto-generated method stub
			trace("config.xml load ioError: " + event.toString());
			xmlFailCount++;
			if(xmlFailCount < 3)
			{
				loadXmlFile();
			}else
			{
				destroyXmlLoader();
			}
		}
		private var configXML:XML;
		protected function xmlLoadCompleteListener(event:Event):void
		{
			// TODO Auto-generated method stub
			configXML = XML(event.currentTarget.data);
			analyseXml(XML(event.currentTarget.data));
			destroyXmlLoader();
		}
		private var preLoadList:Array = [];
		private function analyseXml($xml:XML):void
		{
			if($xml.hasOwnProperty("preLoadSource"))
			{
				var xmlList:XMLList = $xml.preLoadSource.item;
				for (var i:int = 0; i < xmlList.length(); i++) 
				{
					var obj:Object = [];
					obj.name = xmlList[i].@name;
					obj.source = xmlList[i].@source;
					if(xmlList[i].@pathType == "SWFPath")
					{
						obj.fullPath = config.SWFPath + xmlList[i].@source + config.ConfigVersion;
					}else if(xmlList[i].@pathType == "GamePath")
					{
						obj.fullPath = config.GamePath + xmlList[i].@source + config.ConfigVersion;
					}else if(xmlList[i].@pathType == "StylePath")
					{
						obj.fullPath = config.StylePath + xmlList[i].@source + config.ConfigVersion;
					}
					
					obj.label = xmlList[i].@label;
					preLoadList.push(obj);
				}
				total = preLoadList.length;
				startLoadSWF();
				progressTotal.visible = true;
			}
		}
		private var swfLoader:Loader;
		private function startLoadSWF():void
		{
			if(!swfLoader)
			{
				swfLoader = new Loader();
				swfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, swfCompleteListener);
				swfLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, swfIOErrorListener);
				swfLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, swfProgressListener);
			}
			if(preLoadList.length > 0)
			{
				swfLoader.load(new URLRequest(preLoadList[0].fullPath));
				currText = String(preLoadList[0].label);
			}
			setProgressTotal(0);
		}
		private function destroySWFLoader():void
		{
			if(swfLoader)
			{
				if(swfLoader.contentLoaderInfo.hasEventListener(Event.COMPLETE))
				{
					swfLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, swfCompleteListener);
				}
				if(swfLoader.contentLoaderInfo.hasEventListener(IOErrorEvent.IO_ERROR))
				{
					swfLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, swfIOErrorListener);
				}
				if(swfLoader.contentLoaderInfo.hasEventListener(ProgressEvent.PROGRESS))
				{
					swfLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, swfProgressListener);
				}
//				swfLoader = null;
			}
		}
		private var curSwfUrl:String;
		private var puzzleGame:DisplayObject;
		private var loadedSwfList:Object = {};
		protected function swfCompleteListener(event:Event):void
		{
			if(preLoadList[0].fullPath)
				curSwfUrl = preLoadList[0].fullPath; 
			preLoadList[0].data = swfLoader.contentLoaderInfo;
			if(preLoadList[0].name == "PreLoad")
			{
				var domain:ApplicationDomain = swfLoader.contentLoaderInfo.applicationDomain;
				var cls:Class = domain.getDefinition("desc") as Class;
			}
			loadedSwfList[preLoadList[0].name] = preLoadList[0];
			preLoadList.shift();
			if(curSwfUrl.indexOf("PuzzleGame.swf") > -1)
			{
				puzzleGame = swfLoader.content;
				currText = "正在初始化";
				puzzleGame.addEventListener(ENTER_GAME, enterGameListener);
				addChild(puzzleGame);
				initGame();
			}
			if(preLoadList.length > 0)
			{
				startLoadSWF();
			}else
			{
				allSwfLoadComplete();
			}
		}
		private function initGame():void
		{
			if(preLoadList.length <= 0)
			{
				Object(puzzleGame).setGameInfo(_state, config.configObj, configXML, loadedSwfList, ENTER_GAME);
			}
		}
		private var total:int;
		private var loadedNum:int = 0;
		private var percent:int;
		protected function swfProgressListener(event:ProgressEvent):void
		{
			loadedNum++;
			percent = loadedNum / total * 100;
			percent = percent > 100 ? 100 : percent;
			setProgressTotal(percent);
		}
		private var swfFailCount:int;
		protected function swfIOErrorListener(event:IOErrorEvent):void
		{
			trace("swf load io error: " + event.toString());
			swfFailCount++;
			if(swfFailCount < 10)
			{
				startLoadSWF();
			}else
			{
				destroySWFLoader();
			}
		}
		private function allSwfLoadComplete():void
		{
			destroySWFLoader();
		}
		protected function enterGameListener(event:Event):void
		{
			// TODO Auto-generated method stub
			destroySWFLoader();
			destroyXmlLoader();
			destroyDisplayObj();
		}
		private function destroyDisplayObj():void
		{
			// TODO Auto Generated method stub
//			if(_maskRight)
//			{
//				_maskRight.graphics.clear();
//				removeChild(_maskRight);
//				_maskRight = null;
//			}
			if(logo)
			{
				if(logo.parent)
					logo.parent.removeChild(logo);
				logo = null;
			}
//			if(awardTip)
//			{
//				if(awardTip.parent)
//					awardTip.parent.removeChild(awardTip);
//				awardTip = null;
//			}
			if(currLoadText)
			{
				if(currLoadText.parent)
					currLoadText.parent.removeChild(currLoadText);
				currLoadText = null;
			}
//			if(progress)
//			{
//				if(progress.parent)
//					progress.parent.removeChild(progress);
//				progress.destory();
//				progress = null;
//			}
			if(progressTotal)
			{
				if(progressTotal.parent)
					progressTotal.parent.removeChild(progressTotal);
				progressTotal.destory();
				progressTotal = null;
			}
			if(sprite)
			{
				if(sprite.parent)
					sprite.parent.removeChild(sprite);
				sprite = null;
			}
		}
		/**
		 * 文字黑色描边 
		 */		
		private static  var textGlowFilter:GlowFilter;
		public static function get glowFilter():GlowFilter{
			if( !textGlowFilter ){
				textGlowFilter = new GlowFilter();
			}
			textGlowFilter.blurX = 2;
			textGlowFilter.blurY = 2;
			textGlowFilter.color = 0x000000;
			textGlowFilter.strength = 10;
			textGlowFilter.quality = 1;
			return textGlowFilter;
		}
		private var li:int = 0;
		private var loadList:Array = [];
		private  function onEnterFrame(e:Event):void{
			if( li == 1 )
			{
				setCurLoadText(currText + " .");
			}else if( li == 6 )
			{
				setCurLoadText(currText + " . . ");
			}else if( li == 12 )
			{
				setCurLoadText(currText + " . . .");
			}
			li++;
			if( li > 18 )
				li = 0;
		}
		private function setCurLoadText($text:String):void
		{
			if(currLoadText)
			{
				currLoadText.text = $text;
			}
		}
		private function setProgress($progress:int):void
		{
//			if(progress)
//			{
//				progress.setValue($progress);
//			}
		}
		private function setProgressTotal($progress:int):void
		{
			if(progressTotal)
			{
				progressTotal.setValue($progress);
			}
		}
		private var _state:*;
		public function setStage($state:Stage):void{
			_state = $state;
		}
	}
}