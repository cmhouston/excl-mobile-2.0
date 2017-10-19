package utilities
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class LoadedImageEvent extends Event 
	{
		public static var LOADED_IMAGE_COMPLETE:String = "Loaded_Image_Complete";
		
		public static var SHOW_PROGRESS:String = "Show_Progress";
		
		public static var LOADER_TIMEOUT:String = "Loader_Timeout";
		
		public function LoadedImageEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new LoadedImageEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("LoadedImageEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}