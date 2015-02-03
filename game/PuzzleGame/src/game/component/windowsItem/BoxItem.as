package game.component.windowsItem
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import game.component.Image;
	import game.event.GameEvent;
	import game.manager.StyleManager;
	import game.utils.GameEventConstants;
	import game.windows.MainConstants;
	
	import org.aswing.JPanel;

	/**
	 * 笼子Item 
	 * @author xw
	 */	
	public class BoxItem extends JPanel
	{
		private var _box:Image;
		private var _cloth:Image;
		private var _base:Image;
		public function BoxItem($container:DisplayObjectContainer, $x:int, $y:int, $w:int, $h:int)
		{
			if($container)
				$container.addChild(this);
			setLocationXY($x, $y);
			setSizeWH($w, $h);
			createUI();
		}
		public function destroy():void
		{
			var obj:DisplayObject;
			while(this.numChildren > 0)
			{
				obj = this.getChildAt(0);
				if(obj is Image)
				{
					(obj as Image).destroy();
					removeChild(obj);
					obj = null;
				}else if(obj is MovieClip)
				{
					(obj as MovieClip).stop();
					removeChild(obj);
					obj = null;
				}else
				{
					removeChild(obj);
					obj = null;
				}
			}
		}
		private var _effContainer:JPanel;
		private var _animaImg:Image;
		private var _normalEff:MovieClip;
		private function createUI():void
		{
			_base = new Image(this, (width - 127) / 2, (height - 28), 127, 28, StyleManager.getInstance().getBitMapData(StyleManager.PRE_LOADSWFNAME, "base", 127, 28));
			_effContainer = new JPanel();
			_effContainer.setSizeWH(width, height);
			_effContainer.setLocationXY(0, 0);
			addChild(_effContainer);
			_animaImg = new Image(this, 0, 0, 200, 200);
			_box = new Image(this, (width - 141) / 2, 0, 141, 594, StyleManager.getInstance().getBitMapData(StyleManager.PRE_LOADSWFNAME, "cage", 141, 594));
			_cloth = new Image(this, (width - 188) / 2 - 2, (height - 138) - 5, 188, 138);
			_cloth.isBackImage = false;
			_cloth.addEventListener(MouseEvent.CLICK, mouseClickListener);
		}
		protected function mouseClickListener(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			event.stopImmediatePropagation();
			var e:Event = new Event(GameEventConstants.ITEM_CLICK, true);
//			e.data = {name:_animalName, index:_index};
			dispatchEvent(e);
		}
		private var _data:Object;
		private var _index:int;
		private var _animalName:String;
		public function setItemData($value:Object, $index:int):void
		{
			this._data = $value;
			this._index = $index;
			//
			_animalName = _data.name;
			_animaImg.bitmapData =  StyleManager.getInstance().getBitMapData(StyleManager.PRE_LOADSWFNAME, _animalName, _data.size[0], _data.size[1]);
			_animaImg.setSize(_data.size[0],  _data.size[1]);
			_animaImg.setCoordinate((width -  _data.size[0]) / 2, (height -  _data.size[1]));
			_cloth.bitmapData = StyleManager.getInstance().getBitMapData(StyleManager.PRE_LOADSWFNAME, _data.color, 188, 138);
		}
		public function startNormalEff():void
		{
			_normalEff = StyleManager.getInstance().getEffect(_animalName, _animalName.toLowerCase() + "_normal");
			if(_normalEff)
			{
				_effContainer.addChild(_normalEff);
				_normalEff.gotoAndPlay(1);
				_normalEff.visible = true;
				_animaImg.visible = false;
				var obj:Object = MainConstants.SIZE_NORMAL;
				_normalEff.x = _effContainer.x + (_effContainer.width - MainConstants.SIZE_NORMAL[_animalName][0]) / 2;
				_normalEff.y = _effContainer.y + _effContainer.height - MainConstants.SIZE_NORMAL[_animalName][1] - 10;
			}
		}
		private var _loseEff:MovieClip;
		private var _call:Function;
		public function startLoseEff($callBack:Function):void
		{
			if($callBack != null)
				this._call = $callBack;
			_loseEff = StyleManager.getInstance().getEffect(_animalName, _animalName.toLowerCase() + "_" + MainConstants.RESULT_NO);
			if(_normalEff)
			{
				_effContainer.addChild(_loseEff);
				_loseEff.gotoAndPlay(1);
				_normalEff.visible = false;
				_loseEff.visible = true;
				var obj:Object = MainConstants.SIZE_NORMAL;
				_loseEff.x = _effContainer.x + (_effContainer.width - MainConstants.SIZE_NORMAL[_animalName][0]) / 2;
				_loseEff.y = _effContainer.y + _effContainer.height - MainConstants.SIZE_NORMAL[_animalName][1] - 10;
				_loseEff.addEventListener(Event.ENTER_FRAME, loseEnterFrame);
			}
		}
		
		protected function loseEnterFrame(event:Event):void
		{
			// TODO Auto-generated method stub
			var target:MovieClip = event.target as MovieClip;
			if(target.currentFrame == target.totalFrames)
			{
				target.removeEventListener(Event.ENTER_FRAME, loseEnterFrame);
				if(_call != null)
					_call();
			}
		}
		public function setClothVisible($bol:Boolean):void
		{
			_cloth.visible = $bol;
		}
		public function get animalName():String
		{
			return _animalName;
		}

		public function get index():int
		{
			return _index;
		}

	}
}