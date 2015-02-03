package
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class ProgressCav extends Sprite
	{
		private var pregress:DisplayObject;
		private var img:DisplayObject;
		private var proText:TextField;
		private var cursor:MovieClip;
		[Embed(source="assets/progressBg.png")]
		public static var BG:Class;
		[Embed(source="assets/progress.png")]
		public static var CONTENT:Class;
		[Embed(source="assets/cursor.swf")]
		public static var CURSOURC:Class;
		public function ProgressCav()
		{
			initUI()
		}
		public function destory():void{
			if( cursor ){
				cursor.stop();
				removeChild( cursor );
			}
			while( numChildren> 0 ){
				removeChildAt(0);
			}
		}
		private function initUI():void{
			var cl:Class = BG;
			pregress = new cl();
			pregress.x = 0;
			pregress.y = 0;
			pregress.width = 521;
			pregress.height = 23;
			addChild( pregress );
			
			var cl2:Class = CONTENT;
			img = new cl2();
			img.width = 512;
			img.height = 16;
			img.x = 5;
			img.y = 3;
			addChild( img );
			
			var cl3:Class = CURSOURC;
			cursor = new cl3();
			cursor.x = 21;
			cursor.y = -10;
			addChild( cursor );
			
			proText = new TextField();
			proText.mouseEnabled = proText.selectable = false;
			proText.y = 5;
			proText.width = pregress.width;
			proText.textColor = 0xffffff;
			proText.autoSize = TextFieldAutoSize.CENTER;
			addChild( proText );
			proText.text = ""
		}
		private var _percent:int;
		public function setValue( percent:int ):void{
			if( percent > 100 )
				percent = 100;
			_percent = percent;
			img.width = (img.width / 100) * percent;
			cursor.x = (img.width+ img.x)-10;
			proText.text = percent+"%";
			if( percent >= 100 ){
				cursor.stop();
				cursor.visible = false;
			}else{
				cursor.play();
				cursor.visible = true;
			}
		}
		public function get getValue():int{
			return _percent;
		}
	}
}