package game.windows
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	
	import game.component.Image;
	import game.manager.StyleManager;
	import game.utils.GameConfig;
	
	import org.aswing.JPanel;
	import org.aswing.LayoutManager;
	
	/**
	 * 游戏介绍界面 
	 * @author admin
	 * 
	 */	
	public class InstructionWindow extends JPanel
	{
		private var _winName:String;
		private var _winData:Object;
		private var config:GameConfig = GameConfig.getInstance();
		private var sp:Shape;
		public function InstructionWindow($container:DisplayObjectContainer, $x:int, $y:int, $w:int, $h:int, $name:String, $data:Object)
		{
			sp = new Shape();
			sp.graphics.clear();
			sp.graphics.beginFill(0x000000, 0.8);
			sp.graphics.drawRect(0, 0, config.GameWidth, config.GameHeight);
			sp.graphics.endFill();
			addChild(sp);
			
			if($container)
				$container.addChild(this);
			setLocationXY($x, $y);
			setSizeWH($w, $h);
			_winName = $name;
			if($data)
				_winData = $data;
			createUI();
		}
		private var _bg:Image;
		private var _btn:SimpleButton;
		public function createUI():void
		{
			_bg = new Image(this, (config.GameWidth - 553) / 2, (config.GameHeight - 411) / 2 - 30, 553, 411, StyleManager.getInstance().getBitMapData(StyleManager.PRE_LOADSWFNAME, "desc", 553, 411));
			_btn = StyleManager.getInstance().getSimpleButton(StyleManager.PRE_LOADSWFNAME, "determine");
			if(_btn)
			{
				_btn.x = (width - _btn.width) / 2;
				_btn.y = _bg.y + 330;
				_btn.addEventListener(MouseEvent.CLICK, btnClickListener);
				this.addChild(_btn);
			}
		}
		protected function btnClickListener(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			destroy();
		}
		public function destroy():void
		{
			if(_btn)
			{
				_btn.removeEventListener(MouseEvent.CLICK, btnClickListener);
				this.removeChild(_btn);
				_btn = null;
			}
			if(_bg)
			{
				_bg.destroy();
				removeChild(_bg);
				_bg = null;
			}
			this.parent.removeChild(this);
		}
	}
}