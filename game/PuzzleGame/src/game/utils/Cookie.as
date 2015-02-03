package game.utils
{
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	/**
	 * cookie 
	 * @author xw
	 */	
	public class Cookie 
	{
		/**缓存起始时间*/
		private var _time:uint;
		/**缓存名称*/
		private var _name:String;
		/**最小磁盘空间*/
		private var _minDiskSpace:Number;
		/**本地共享对象*/
		private var _so:SharedObject;
		/**状态，0：尚未开启，1：己开启，-1：用户拒约本地缓存*/
		private var _status:int=0;
		/**
		 * @param name					名字
		 * @param minDiskSpace			磁盘最小需求空间，默认10M
		 * @param timeOut				保存时长，默认为永久保存,单位：秒
		 */				
		public function Cookie(name:String,minDiskSpace:Number=1024*1024*10,timeOut:uint=0) 
		{
			_name = name;
			_time = timeOut;
			_minDiskSpace=minDiskSpace;
			_so = SharedObject.getLocal(name, "/");
			return;
		}
		public function get status():int
		{
			if(_status==0&&_so.size>0)
				_status=1;
			return _status;
		}
		public function set status(s:int):void
		{
			_status=s;
			return;
		}
		/**
		 * 清除超时内容;
		 */		
		public function clearTimeOut():void 
		{
			var obj:* = _so.data.cookie;
			if(obj != undefined&&_time!=0) 
			{
				for(var key:* in obj)
				{
					if(obj[key] == undefined || obj[key].time == undefined || isTimeOut(obj[key].time))
					{
						delete obj[key];
					}
				}
				_so.data.cookie = obj;
				flush();
			}
			return;
		}
		/**
		 * 获取超时值; 
		 * @return 
		 * 
		 */		
		public function getTimeOut():uint 
		{
			return _time;
		}
		/**
		 * 获取名称; 
		 * @return 
		 * 
		 */		
		public function getName():String 
		{
			return _name;
		}
		/**
		 * 清除Cookie所有值; 
		 * 
		 */		
		public function clear():void 
		{
			_so.clear();
		}
		/**
		 * 添加Cookie值;
		 * @param key		键
		 * @param value		值
		 * 
		 */		
		public function put(key:String, value:*):void 
		{
			var today:Date = new Date();
			key = "key_"+key;
			value.time = today.getTime();
			if(_so.data.cookie == undefined)
			{
				var obj:Object = {};
				obj[key] = value;
				_so.data.cookie = obj;
			}
			else
			{
				_so.data.cookie[key] = value;
			}
			
			flush();
			
			return;
		}
		/**
		 * 删除Cookie值;
		 * @param key		键
		 * 
		 */		
		public function remove(key:String):void 
		{
			if (contains(key)) 
			{
				delete _so.data.cookie["key_" + key];
				flush();
			}
			return;
		}
		/**
		 * 获取Cookie值; 
		 * @param key		键
		 * @return 
		 * 
		 */		
		public function get(key:String):Object
		{
			return contains(key)?_so.data.cookie["key_"+key]:null;
		}
		/**
		 * Cookie值是否存在 
		 * @param key		键
		 * @return 
		 * 
		 */		
		public function contains(key:String):Boolean
		{
			key = "key_" + key;
			return _so.data.cookie != undefined && _so.data.cookie[key] != undefined;
		}
		/**
		 * 检测是否超时. 
		 * @param time
		 * @return 
		 */		
		private function isTimeOut(time:uint):Boolean 
		{
			var tag:Boolean=_time>0;
			if(tag)
			{
				var today:Date = new Date();
				tag=time + _time * 1000 < today.getTime();
			}
			return tag;
		}
		private function flushStatusHandler(evt:NetStatusEvent):void
		{
			switch (evt.info.code) 
			{
				case "SharedObject.Flush.Success":
					_status=1;
					break;
				case "SharedObject.Flush.Failed":
					_status=-1;
					break;
			}
			_so.removeEventListener(NetStatusEvent.NET_STATUS, flushStatusHandler);
			return;
		}
		public function flush():void
		{
			if(_status==0) _status=-1;
			var flushStr:String=_so.flush(_minDiskSpace);
			if(flushStr!=null)
			{
				switch(flushStr)
				{
					case SharedObjectFlushStatus.FLUSHED:
						_status=1;
						break;
					case SharedObjectFlushStatus.PENDING:
						_so.addEventListener(NetStatusEvent.NET_STATUS,flushStatusHandler);
				}
			}
			return;
		}
		
	}
}