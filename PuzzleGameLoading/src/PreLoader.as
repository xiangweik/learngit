package 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.ContextMenuItem;
	import flash.utils.getDefinitionByName;
	
	[SWF( width=1000 , height= 600 , backgroundColor="#0e5f94"  )]
	public class PreLoader extends MovieClip
	{
		private var gameWidth:int = 1000;
		private var gameHeight:int = 600;
		private var text:TextField;
		
		private var item1:ContextMenuItem;
		private var item2:ContextMenuItem;
		private var item3:ContextMenuItem;
		private var item4:ContextMenuItem;
		private var item5:ContextMenuItem;
		private var item6:ContextMenuItem;
		public function PreLoader()
		{
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");			
			stop();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 30;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			text = new TextField();
			text.text = "正在初始化中..."
			text.width = 200;
			text.textColor = 0xffffff;
			text.x = (gameWidth -200 )/2;
			text.y = 280;
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.color = 0xffffff;
			textFormat.align = "center";
			text.defaultTextFormat =  textFormat ;			
			addChild( text );
		}
		public function onEnterFrame(event:Event):void
		{
			graphics.clear();
			var percent:Number = root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal;
			text.text = "正在初始化中..."+int(percent*100)+"%";
			if(framesLoaded == totalFrames)
			{
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				nextFrame();
				init();
			}
		}
		private var app:Object;
		private function init():void
		{
			text.text = "";
			removeChild( text );
			var mainClass:Class = Class(getDefinitionByName("PuzzleGameLoading"));
			if(mainClass)
			{
				app = new mainClass(this);
				app.setStage(stage);
				addChild(app as DisplayObject);
				app.init();
			}
		}
	}
}