package
{
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import game.event.GameEvent;
	import game.manager.StyleManager;
	import game.utils.GameConfig;
	import game.utils.GameEventConstants;
	import game.utils.WindowsName;
	import game.windows.InstructionWindow;
	import game.windows.MainWindow;
	
	import gameFrame.GameModel;
	
	import org.aswing.AsWingManager;

	[SWF (height=1000,width=600)]
	public class PuzzleGame extends Sprite
	{
		private var _model:GameModel = GameModel.getInstance();
		private var config:GameConfig = GameConfig.getInstance();
		public function PuzzleGame()
		{
			Security.allowDomain("*");
			ExternalInterface.addCallback("PlayAgain", receiveFromJavaScript);
		} 
		private function receiveFromJavaScript():void
		{
			// TODO Auto Generated method stub
			resetGame();
		}
		private function resetGame():void
		{
//			mainWin.res
//			private var instructionWin:InstructionWindow;
//			private var mainWin:MainWindow;
		}
		private var _preEventType:String;
		/**
		 * 设置游戏信息：舞台，配置对象(config.js中的对象)，配置文件(config.xml)
		 * @param $state 
		 * @param $confObj
		 * @param $configXML
		 */		
		public function setGameInfo($state:DisplayObjectContainer, $confObj:Object, $configXML:XML, $loadedSwfList:Object, $eventType:String):void
		{
			_preEventType = $eventType; 
			GameConfig.getInstance().init($confObj);
			GameConfig.getInstance().analyse($configXML);
			loadSwfFile();
		}
		private var total:int = 2;
		private function loadSwfFile():void
		{
			// TODO Auto Generated method stub
			StyleManager.getInstance().addEventListener(GameEventConstants.STYLE_COMPLETE, styleLoadComplete);
			StyleManager.getInstance().addEventListener(GameEventConstants.STYLE_IOERROR, styleLoadError);
			StyleManager.getInstance().loadEffect(StyleManager.PRE_LOADSWFNAME, true);
			
			StyleManager.getInstance().addEventListener(GameEventConstants.STYLE_COMPLETE, styleLoadComplete);
			StyleManager.getInstance().addEventListener(GameEventConstants.STYLE_IOERROR, styleLoadError);
			StyleManager.getInstance().loadEffect(StyleManager.MAIN_SWFNAME, true);
		}
		protected function styleLoadError(event:Event):void
		{
			// TODO Auto-generated method stub
			trace("style load fail: " + event.toString());
		}
		protected function styleLoadComplete(event:Event):void
		{ 
			// TODO Auto-generated method stub
			event.stopImmediatePropagation();
			total--;
			trace("style load complete: " + event.toString());
			if(total <= 0 && event.type == GameEventConstants.STYLE_COMPLETE)
			{
				createMainWindows();
				dispatchEvent(new Event(_preEventType, true));
				StyleManager.getInstance().removeEventListener(GameEventConstants.STYLE_COMPLETE, styleLoadComplete);
				StyleManager.getInstance().removeEventListener(GameEventConstants.STYLE_IOERROR, styleLoadError);
			}
		}
		private var instructionWin:InstructionWindow;
		private var mainWin:MainWindow;
		private var maskSp:Sprite;
		private function createMainWindows():void 
		{
			mainWin = new MainWindow(this, 0, 0, config.GameWidth, config.GameHeight, WindowsName.Main_Win, null);
//			instructionWin = new InstructionWindow(this, (config.GameWidth - 553) / 2, (config.GameHeight - 441) / 2, 553, 441, WindowsName.Intro_Win, null);
			instructionWin = new InstructionWindow(this, 0, 0, config.GameWidth, config.GameHeight, WindowsName.Intro_Win, null);
		}
		private function setMask():void
		{
			// TODO Auto Generated method stub
			setMaskShape(leftMask, 0x0e5f94, 0, 0, 70, height);
			setMaskShape(rightMask, 0x0e5f94, (width - 79), 0, 70, height);
		}
		private function setMaskShape($target:Shape, $color:uint, $x:int, $y:int, $w:int, $h:int):void
		{
			if($target == null)
			{
				$target = new Shape();
				maskSp.addChild($target);
				$target.graphics.beginFill($color,1);
				$target.graphics.drawRect($x, $y, $w, $h);
				$target.graphics.endFill();
			}
		}
		private var leftMask:Shape;
		private var rightMask:Shape;
		private function loadingPreSource():void
		{
			
		}
	}
}