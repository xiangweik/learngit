package game.component.windowsItem
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import game.component.Image;
	import game.manager.StyleManager;
	
	import org.aswing.JPanel;
	import org.aswing.LayoutManager;

	/**
	 * 字母输入框Item 
	 * @author xw
	 * 
	 */	
	public class WordItem extends JPanel
	{
		private var _txt:TextField;
		private var _bg:Image;
		public function WordItem($container:DisplayObjectContainer, $x:int, $y:int, $w:int, $h:int)
		{
			if($container)
				$container.addChild(this);
			setLocationXY($x, $y);
			setSizeWH($w, $h);
			_bg = new Image(this, 0, 0, 61, 45, StyleManager.getInstance().getBitMapData(StyleManager.PRE_LOADSWFNAME, "wordBox", 61, 45));
			_txt = new TextField();
			var tf:TextFormat = new TextFormat("", 30, 0x000000, true);
			tf.align = TextFormatAlign.CENTER;
			_txt.selectable = false;
			_txt.defaultTextFormat = tf;
			_txt.width = 50;
			_txt.height = 45;
			_txt.x = (_bg.width - _txt.width) / 2;
			_txt.y = (_bg.height - _txt.height) / 2;
			addChild(_txt);
		}
		public function destroy():void
		{
			if(_txt)
			{
				removeChild(_txt);
				_txt = null;
			}
			if(_bg)
			{
				_bg.destroy();
				removeChild(_bg);
				_bg = null;
			}
			this.parent.removeChild(this);
		}
		public function setText($txt:String):void
		{
			_txt.text = $txt;
		}
	}
}