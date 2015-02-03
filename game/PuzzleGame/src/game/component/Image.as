package game.component
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	public class Image extends Sprite
	{
		private var _bm:Bitmap;
		public function Image($container:DisplayObjectContainer, $x:int, $y:int, $w:int, $h:int, $bmd:BitmapData = null, $isbackIamge:Boolean = true)
		{
			if($container)
				$container.addChild(this);
			_bm = new Bitmap();
			addChild(_bm);
			setCoordinate($x, $y, this);
			setSize($w, $h, this);
			isBackImage = $isbackIamge;
			bitmapData = $bmd;
		}
		public function setCoordinate($x:int, $y:int, $target:DisplayObject = null):void
		{
			if(!$target)
				$target = this;
			$target.x = $x;
			$target.y = $y;
		}
		public function setSize($w:int, $h:int, $target:DisplayObject = null):void
		{
			if(!$target)
				$target = this;
			$target.width = $w;
			$target.height = $h;
		}
		public function set bitmapData($bmd:BitmapData):void
		{
			if($bmd)
			{
				_bm.bitmapData = $bmd;
				setCoordinate(0, 0, _bm);
				setSize($bmd.width, $bmd.height, _bm);
				setSize($bmd.width, $bmd.height, this);
			}
		}
		public function destroy():void
		{
			if(_bm)
			{
				if(_bm.bitmapData)
				{
					_bm.bitmapData.dispose();
				}
				removeChild(_bm);
				_bm = null;
			}
		}
		public function set isBackImage($bol:Boolean):void
		{
			this.buttonMode = this.mouseEnabled = !$bol;
		}
	}
}