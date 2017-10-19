package utilities 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class XMLUtilityEvent extends Event 
	{
		public static var XML_LOADED:String = "Xml_Loaded";
		public function XMLUtilityEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new XMLUtilityEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("XMLUtilityEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}