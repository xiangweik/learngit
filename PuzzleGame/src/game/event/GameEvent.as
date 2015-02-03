package game.event
{
	import flash.events.Event;
	
	public class GameEvent extends Event
	{
		public var data:Object;
		public function GameEvent($type:String, $bubbles:Boolean=false, $cancelable:Boolean=false, $data:Object = null)
		{
			super(type, bubbles, cancelable);
			if($data)
				data = $data;
		}
	}
}