package utilities 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class PhpUtilityEvent extends Event 
	{
		public static var PXML_LOADED:String = "PXml_Loaded";
		public static var SUB_LOADED:String = "SUB_Loaded";
		public static var UPDATE_LOADED:String = "Update_Loaded";
		public function PhpUtilityEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new PhpUtilityEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PhpUtilityEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}