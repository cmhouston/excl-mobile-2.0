package 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class MoreEvent extends Event 
	{
		public static var COMP_LOADED:String = "Comp Loaded";
		public static var EXHIBITS_LOADED:String = "Exhibits Loaded";
		public static var INTERFACE_LOADED:String = "Interface Loaded";
		public static var INIT_SLIDE_LOADED:String = "Init Slide Loaded";
		public static var SLIDE_LOADED:String = "Slide Loaded";
		public static var SLIDER_LOADED:String = "Slider Loaded";
		public static var SLIDE_CHANGED:String = "Slide Changed";
		public static var PAGE_LOADED:String = "Page Loaded";
		public static var VIDEO_LOADED:String = "Video Loaded";
		public static var UNLOAD_PAGE:String = "Unload Page";
		public static var UPDATE_COUNTER:String = "Update Counter";
		public static var CLOSE_BROWSER:String = "Close Browser";
		public static var CLOSE_POPUP:String = "Close Popup";
		public static var SAVE_COMPLETE:String = "Save Complete";
		
		public function MoreEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new MoreEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("MoreEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}