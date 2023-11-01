package player.event
{
	import flash.events.Event;

	public class PlayerEvent extends Event
	{
		public static const ON_PAUSE :String = "PLAYEREVENT_ONPAUSE" ;
		public static const ON_PLAY  :String = "PLAYEREVENT_ONPLAY"  ;
		public static const ON_SEEK  :String = "PLAYEREVENT_ONSEEK"  ;
		public static const ON_VOLUME:String = "PLAYEREVENT_ONVOLUME";

		public function PlayerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) : void
		{
			super(type, bubbles, cancelable);
		}
	}
}