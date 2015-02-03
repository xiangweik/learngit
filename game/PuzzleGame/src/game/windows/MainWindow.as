package game.windows
{
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import flashx.textLayout.formats.BaselineOffset;
	import flashx.textLayout.operations.MoveChildrenOperation;
	
	import game.component.Image;
	import game.component.windowsItem.BoxItem;
	import game.component.windowsItem.WordItem;
	import game.manager.StyleManager;
	import game.utils.GameEventConstants;
	
	import org.aswing.JPanel;
	
	public class MainWindow extends JPanel
	{
		private var _winName:String;
		private var _winData:Object;
		public function MainWindow($container:DisplayObjectContainer, $x:int, $y:int, $w:int, $h:int, $name:String, $data:Object)
		{
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
		private var ITEM_NUM:int = 5;
		private var orderList:Array = [0, 1, 2, 3, 4];
		private var animalName:Array = ["Giraffe", "Panda", "Bee", "Dolphin", "Rabbit"];
//		Giraffe:[94, 139],Panda:[70, 120],Bee:[110, 96],Dolphin:[130, 92],Rabbit:[65, 135]
		private var animalSize:Array = [[94, 139], [70, 120], [111, 96], [130, 93], [85, 136]];
		private var colorList:Array = ["redCloth", "yellowCloth", "redCloth", "yellowCloth", "redCloth"];
		private var itemData:Array = [];
		public function createUI():void
		{
			var item:BoxItem;
			_bg = new Image(this, (width - 1000) / 2, (height - 581) / 2, 1000, 581, StyleManager.getInstance().getBitMapData(StyleManager.PRE_LOADSWFNAME, "bg", 1000, 581));
			var obj:Object;
			var startX:int = (width - 175 * 5) / 2;
			for (var i:int = 0; i < ITEM_NUM; i++) 
			{
				item = new BoxItem(this, startX + i * 175, -180 - 30, 190, 594);
				item.name = "item_" + i;
				obj = {name:animalName[i], size:animalSize[i], color:colorList[i]};
				itemData.push(obj);
				item.setItemData(obj, i);
				item.addEventListener(GameEventConstants.ITEM_CLICK, itemClickListener);
			}
			initClothEff();
			initInputArea();
			initStarArea();
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler); //监听容器的键盘点击事件
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler); //监听容器的键盘点击事件
		}
		private var codeHasInput:Array = [];
		/**当前所选动物单词的字母unicode列表 */		
		private var curCodeList:Array = [];
		private var _curAnimalIndex:int;
		private var curReusltType:String;
		protected function keyUpHandler(event:KeyboardEvent):void
		{
			// TODO Auto-generated method stub
			if(!keyboardLock && event.keyCode >= Keyboard.A && event.keyCode <= Keyboard.Z)
			{ 
				var list:Array = getIndexOfChar(event.keyCode);
				var curStr:String;
				if(list.length > 0 && codeHasInput.indexOf(event.keyCode) == -1)
				{
					//输入正确	
					var item:WordItem;
					curStr = animalName[_curAnimalIndex];
					for (var i:int = 0; i < list.length; i++) 
					{
						item = inputArea.getChildByName("wordItem_" + list[i]) as WordItem;
						if(item)
						{
							item.setText(curStr.charAt(int(list[i])));
						}
						codeHasInput.push(event.keyCode);
					}
					if(codeHasInput.length >= curStr.length)
					{
						//该局游戏成功过关
						totalScore += curStarNum;
						keyboardLock = true;
						curReusltType = MainConstants.RESULT_YES;
						showRightImg();
					}
				}else
				{
					//输入错误 
					inputWrong();
				}
			}
		}
		private var rightImg:Image;
		/**当前星星的个数 */		
		private var curStarNum:int = 5;
		private var hasPlayedTimes:int = 0;
		private var totalScore:int;
		private function inputWrong():void
		{
			curStarNum--;
			startStarEff(curStarNum);
			if(curStarNum <= 0)			//所有星星使用完毕
			{
//				播放失败的动画
				keyboardLock = true;
				curReusltType = MainConstants.RESULT_NO;
				showWrongImg();
			}
		}
		private function showRightImg():void
		{
			if(rightImg == null)
			{
				rightImg = new Image(this, 0, 0, 367, 42, StyleManager.getInstance().getBitMapData(StyleManager.MAIN_SWFNAME, "right", 367, 42));
				addChild(rightImg);
				rightImg.visible = true;
			}
			rightImg.setCoordinate((width - rightImg.width) / 2, 0, rightImg);
			rightImg.alpha = 1;
			rightImg.visible = true;
			TweenLite.to(rightImg, 1, {y:395, alpha:1,onComplete:rightImgComplete});
		}
		private var rightImgTimeOut:int;
		private function rightImgComplete():void
		{
			if(rightImg)
			{
				rightImgTimeOut = setTimeout(hideRightImg, 2000);
			}
		}
		private function hideRightImg():void
		{
			TweenLite.to(rightImg, 1, {alpha:0, onComplete:onHideRightImgComplete});
		}
		private function onHideRightImgComplete():void
		{
			playRightResultEff(animalName[_curAnimalIndex]);
			clearTimeout(rightImgTimeOut);
			rightImg.visible = false;
		}
		//
		private var wrongImg:Image;
		private function showWrongImg():void
		{
			if(wrongImg == null)
			{
				wrongImg = new Image(this, 0, 0, 437, 42, StyleManager.getInstance().getBitMapData(StyleManager.MAIN_SWFNAME, "wrong", 437, 42));
				addChild(wrongImg);
				wrongImg.visible = true;
			}
			wrongImg.setCoordinate((width - wrongImg.width) / 2, 0, wrongImg);
			wrongImg.alpha = 1;
			wrongImg.visible = true;
			TweenLite.to(wrongImg, 1, {y:395, alpha:1,onComplete:wrongImgComplete});
		}
		private var wrongImgTimeOut:int;
		private function wrongImgComplete():void
		{
			if(wrongImg)
			{
				wrongImgTimeOut = setTimeout(hidewrongImg, 2000);
			}
		}
		private function hidewrongImg():void
		{
			TweenLite.to(wrongImg, 1, {alpha:0, onComplete:onHidewrongImgComplete});
		}
		private function onHidewrongImgComplete():void
		{
			clearTimeout(wrongImgTimeOut);
			wrongImg.visible = false;
			var item:BoxItem = this.getChildByName("item_" + _curAnimalIndex) as BoxItem;
			if(item)
			{
				item.startLoseEff(playOver);
			}
		}
		private var nextImg:Image;
		private function showNextImg():void
		{
			if(nextImg == null)
			{
				nextImg = new Image(this, 0, 0, 492, 46, StyleManager.getInstance().getBitMapData(StyleManager.MAIN_SWFNAME, "next", 492, 46));
				addChild(nextImg);
			}
			nextImg.setCoordinate((width - nextImg.width) / 2, 150);
			nextImg.visible = true;
		}
		private function hideNextImg():void
		{
			if(nextImg)
			{
				nextImg.visible = false;
			}
		}
		private function playOver():void
		{
			var item:BoxItem = this.getChildByName("item_" + _curAnimalIndex) as BoxItem;
			if(item)
			{
				TweenLite.to(item,1, {y:-180 - 590,alpha:0,onComplete:onFinishTween});
			}
		}
		private function onFinishTween():void
		{
			var item:BoxItem = this.getChildByName("item_" + _curAnimalIndex) as BoxItem;
			if(item)
			{
				item.visible = false;
				resultEffPlayOver();
			}
		}
		/**
		 * 每局完成后初始化游戏 
		 */		
		private function resetGameState():void
		{
			codeHasInput = [];
			curStarNum = 5;
			openCageLock = false;
			resetInputArea();
			resetStarArea();
			showNextImg();
		}
		/**
		 * 规定的机会内未通关时重新开始游戏 
		 */		
		public function reStartGame():void
		{
			totalScore = 0;
			codeHasInput = [];
			curStarNum = 5;
			openCageLock = false;
			resetInputArea();
			resetStarArea();
		}
		private function getIndexOfChar($charCode:uint):Array
		{
			var list:Array = [];
			for (var i:int = 0; i < curCodeList.length; i++) 
			{
				if($charCode == curCodeList[i])
				{
					list.push(i);
				}
			}
			return list;
		}
		/**
		 * 输入字符串，输出字符所对应的unicode码 
		 * @param $str
		 * @return  Giraffe 71 73 82 65 70 70 69
		 * 
		 */		
		private function getCharCodeList($str:String):Array
		{
			var len:int = $str.length;
			var codeList:Array = [];
			$str = $str.toUpperCase();
			for (var i:int = 0; i < len; i++) 
			{
				var str:String = $str.charAt(i);
				var num:int = $str.charCodeAt(i);
				codeList.push($str.charCodeAt(i));
			}
			return codeList;
		}
		protected function keyDownHandler(event:KeyboardEvent):void
		{
			// TODO Auto-generated method stub
			
		}
		private const STAR_NUM:int = 5;
		private function initStarArea():void
		{
			var starMC:MovieClip;
			for (var i:int = 0; i < STAR_NUM; i++) 
			{
				starMC = StyleManager.getInstance().getEffect(StyleManager.PRE_LOADSWFNAME, "star");
				addChild(starMC);
				starMC.name = "starMC_" + i;
				starMC.gotoAndStop(1);
				starMC.x = 62 + i * 45;
				starMC.y = height - 85;
			}
		}
		private function resetStarArea():void
		{
			var starMC:MovieClip;
			for (var i:int = 0; i < STAR_NUM; i++) 
			{
				starMC = this.getChildByName("starMC_" + i) as MovieClip;
				if(starMC)
				{
					starMC.gotoAndStop(1);
					starMC.visible = true;
				}
			}
		}
		private function startStarEff($index:int):void
		{
			var starMC:MovieClip = getChildByName("starMC_" + $index) as MovieClip;
			if(starMC)
			{
				starMC.addEventListener(Event.ENTER_FRAME, starEnterFrame);
				starMC.gotoAndPlay(1);
			}
		}
		protected function starEnterFrame(event:Event):void
		{
			// TODO Auto-generated method stub
			var targetMC:MovieClip = event.target as MovieClip;
			if(targetMC.currentFrame == targetMC.totalFrames)
			{
				targetMC.removeEventListener(Event.ENTER_FRAME, starEnterFrame);
				targetMC.visible = false;
				targetMC.gotoAndStop(1);
			}
		}
		private var openCageLock:Boolean = false;
		private var keyboardLock:Boolean = true;
		private var timeOut:int;
		protected function itemClickListener(event:Event):void
		{
			if(!openCageLock)
			{
				var target:BoxItem = event.target as BoxItem;
				_curAnimalIndex = target.index;
				playClothEff(_curAnimalIndex);
				target.setClothVisible(false);
				openCageLock = true;
				keyboardLock = false;
				hideNextImg();
				hasPlayedTimes++;
				StyleManager.getInstance().addEventListener(GameEventConstants.STYLE_COMPLETE, styleLoadComplete);
				StyleManager.getInstance().loadEffect(animalName[_curAnimalIndex], true);
				curCodeList = getCharCodeList(animalName[_curAnimalIndex]);
				updateInputArea(_curAnimalIndex);
			}
		}
		protected function styleLoadComplete(event:Event):void
		{
			event.stopImmediatePropagation();
			StyleManager.getInstance().removeEventListener(GameEventConstants.STYLE_COMPLETE, styleLoadComplete);
			var item:BoxItem = this.getChildByName("item_" + _curAnimalIndex) as BoxItem;
			item.startNormalEff();
		}
		private function updateInputArea($index:int):void
		{
			var len:int = (animalName[$index] as String).length;
			var len2:int = WORD_NUM - len;
			var startX:int = (inputArea.width - WORDITEM_WIDTH * len - (len - 1) * WORDITEM_XOFF) / 2;
			var item:WordItem;
			for (var i:int = 0; i < WORD_NUM; i++) 
			{
				item = inputArea.getChildByName("wordItem_" + i) as WordItem; 
				if(!item)
					continue;
				if(i < len)
				{
					item.visible = true;
					item.x = startX + i * (WORDITEM_WIDTH + WORDITEM_XOFF);
				}else
				{
					item.visible = false;
				}
			}
		}
		private function resetInputArea():void
		{
			if(inputArea == null)
				return;
			inputArea.setSizeWH(WORDITEM_WIDTH * WORD_NUM + (WORD_NUM - 1) * WORDITEM_XOFF, WORDITEM_HEIGHT);
			var item:WordItem;
			for (var i:int = 0; i < WORD_NUM; i++) 
			{
				item = inputArea.getChildByName("wordItem_" + i) as WordItem;
				if(item)
				{
					item.setLocationXY( i * (WORDITEM_WIDTH + WORDITEM_XOFF), 0);
					item.setText("");
					item.visible = true;
				}
			}
		}
		private function playClothEff($index:int):void
		{
			redEff.visible = yellowEff.visible = false;
			redEff.gotoAndStop(1);
			yellowEff.gotoAndStop(1);
			var item:BoxItem = this.getChildByName("item_" + $index) as BoxItem;
			var targetMC:MovieClip;
			if(colorList[$index] == "redCloth")
			{
				targetMC = redEff;
			}else if(colorList[$index] == "yellowCloth")
			{
				targetMC = yellowEff;
			}
			targetMC.visible = true;
			targetMC.x = item.x + (item.width - 258) / 2 + 500;
			targetMC.y = item.y + item.height - 189 + 50;
			targetMC.gotoAndPlay(1);
			targetMC.addEventListener(Event.ENTER_FRAME, clothEnterFrame);
		}
		protected function clothEnterFrame(event:Event):void
		{
			// TODO Auto-generated method stub
			var target:MovieClip = event.target as MovieClip;
			if(target.currentFrame == target.totalFrames)
			{
				target.gotoAndStop(1);
				target.removeEventListener(Event.ENTER_FRAME, clothEnterFrame);
				target.visible = false;
			}
		}
		private const WORD_NUM:int = 8;
		private var inputArea:JPanel;
		private const WORDITEM_WIDTH:int = 61;
		private const WORDITEM_HEIGHT:int = 45;
		private const WORDITEM_XOFF:int = 5;
		/**
		 * 初始化输入区域 
		 */		
		private function initInputArea():void
		{
			if(inputArea == null)
			{
				inputArea = new JPanel();
				inputArea.setSizeWH(WORDITEM_WIDTH * WORD_NUM + (WORD_NUM - 1) * WORDITEM_XOFF, WORDITEM_HEIGHT);
				inputArea.setLocationXY((width - inputArea.width) / 2, height - 160);
				addChild(inputArea);
				var item:WordItem;
				for (var i:int = 0; i < WORD_NUM; i++) 
				{
					item = new WordItem(inputArea, i * (WORDITEM_WIDTH + WORDITEM_XOFF), 0, WORDITEM_WIDTH, WORDITEM_HEIGHT);
					item.name = "wordItem_" + i;
				}
			}
		}
		private var redEff:MovieClip;
		private var yellowEff:MovieClip;
		public function initClothEff():void
		{
			if(redEff == null)
			{
				redEff = StyleManager.getInstance().getEffect(StyleManager.MAIN_SWFNAME, "redEff");
				if(redEff)
				{
					redEff.gotoAndStop(1);
					redEff.visible = false;
					this.addChild(redEff);
				}
			}
			if(yellowEff == null)
			{
				yellowEff = StyleManager.getInstance().getEffect(StyleManager.MAIN_SWFNAME, "yellowEff");
				if(yellowEff)
				{
					yellowEff.gotoAndStop(1);
					yellowEff.visible = false;
					this.addChild(yellowEff);
				}
			}
		}
		public function destroy():void
		{
			var item:BoxItem;
			for (var i:int = 0; i < ITEM_NUM; i++) 
			{
				item = this.getChildByName("item_" + i) as BoxItem;
				if(item)
				{
					item.destroy();
					this.removeChild(item);
					item = null;
				}
			}
		}
		/**
		 * 播放结果动画 
		 * @param $animalName   当前动物名称	
		 */		
		private function playRightResultEff($animalName:String):void
		{
			var mc:MovieClip = StyleManager.getInstance().getEffect($animalName, $animalName.toLowerCase() + "_" +  MainConstants.RESULT_YES);
			if(mc)
			{
				addChild(mc);
				mc.x = MainConstants.LOC_RIGHT[$animalName][0];
				mc.y = MainConstants.LOC_RIGHT[$animalName][1];
				mc.gotoAndPlay(1);
				mc.addEventListener(Event.ENTER_FRAME, resutEffEnterFrame);
			} 
		}
		protected function resutEffEnterFrame(event:Event):void
		{
			// TODO Auto-generated method stub
			var target:MovieClip = event.target as MovieClip;
			if(target.currentFrame == target.totalFrames)
			{
				target.removeEventListener(Event.ENTER_FRAME, resutEffEnterFrame);
				target.stop();
				removeChild(target);
				target = null;
				resultEffPlayOver();
			}
		} 
		private function resultEffPlayOver():void
		{
			if(hasPlayedTimes >= MainConstants.MAX_TIMETOPLAY)		//判断是否整个游戏结束
			{
				//					调用游戏结束js
				ExternalInterface.call("gameOver", totalScore);
				trace("游戏过关成功！");
			}else
			{
				resetGameState();
				trace("继续下一局游戏！");
			}
		}
	}
}