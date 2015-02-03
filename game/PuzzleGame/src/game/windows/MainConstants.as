package game.windows
{
	public class MainConstants
	{
		/**长劲鹿*/		
		public static const GIRAFFE:String = "Giraffe";
		/**大熊猫*/		
		public static const PANDA:String = "Panda";
		/**蜜蜂*/		
		public static const BEE:String = "Bee";
		/**海豚*/		
		public static const DOLPHIN:String = "Dolphin";
		/**兔子*/		
		public static const RABBIT:String = "Rabbit";
		
		public static const SIZE_NORMAL:Object = {Giraffe:[94, 139],Panda:[70, 120],Bee:[110, 96],Dolphin:[130, 92],Rabbit:[65, 135]};
		
		public static const LOC_RIGHT:Object = {Giraffe:[-355, 140],Panda:[-355, 140],Bee:[363, -425],Dolphin:[1090, 135],Rabbit:[1100, 135]};
		/***星星的最大数量*/		
		public static const MAX_STAR_NUM:int = 5;
		/***最多可玩局数(一局代表一个动物)*/		
		public static const MAX_TIMETOPLAY:int = 3;
		public static const RESULT_YES:String = "yes";
		public static const RESULT_NO:String = "no";
	}
}