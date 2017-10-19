
/********************************************************
 * ******************************************************
 * @author Darius Portilla
 * @Date 10/29/2013 
 * @path com.sixfoot.utilities.XMLUtil.as
 * ******************************************************
 ********************************************************/

package utilities
{
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.system.LoaderContext;
	import flash.system.ApplicationDomain;
	import flash.events.HTTPStatusEvent;
	import flash.net.URLRequestDefaults;
	
	public class XMLUtil
	{
		public static var myXML:XML;
		public static var myJSON:Object;
		private static var loader:URLLoader = new URLLoader();
		private static var jloader:Loader = new Loader();
		private static var dispatcher:EventDispatcher = new EventDispatcher();
		private static var JSON2LOAD:String;
		private static var IS_LOADING_JSON:Boolean = false;
		
		public static function LoadXML(x:String):void {
			URLRequestDefaults.idleTimeout = 1200000;
			
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onLoadXML)
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			trace("LOADING: " + x);

			loader.load(new URLRequest(x));

		}
		
		static private function securityErrorHandler(e:SecurityErrorEvent):void 
		{
			trace("************ XML SECURITY ERROR *************");
			trace("SECURITY error occured with " + e.target);
		}
		
		private static function onLoadXML(e:Event):void{
				
			try {
					//Convert the downloaded text into an XML
					XML.ignoreWhitespace = true; 
					myXML = new XML(e.target.data);
									
					loader.removeEventListener(Event.COMPLETE, onLoadXML)
					dispatcher.dispatchEvent(new XMLUtilityEvent(XMLUtilityEvent.XML_LOADED));
					
				} catch (e:TypeError){
					//Could not convert the data, probavlu because
					//because is not formated correctly
					trace("Could not parse the XML")
					trace(e.message)
				}
					
		}
		

		public static function LoadJSON(x:String):void {
			
			IS_LOADING_JSON = true;
				trace("LOADING: JSON");
			JSON2LOAD = x;
			loader = new URLLoader();
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			
			loader.addEventListener(Event.COMPLETE, onLoadJSON);
			var req:URLRequest = new URLRequest(x);
			loader.load(req);

		}
		
		private static function httpStatusHandler(event:HTTPStatusEvent):void {
		//  trace("httpStatusHandler: " + event);
		//  trace("status: " + event.status);
		}
		  
		private static function onLoadJSON(e:Event):void{
				
			try {
					//Convert the downloaded text into an JSON
					
					myJSON = JSON.parse(e.target.data);
									
					dispatcher.dispatchEvent(new XMLUtilityEvent(XMLUtilityEvent.XML_LOADED));
					
				} catch (e:TypeError){
					//Could not convert the data, probavlu because
					//because is not formated correctly
					trace("Could not parse the JSON")
					trace(e.message);
					LoadJSON(JSON2LOAD);
				}
					
		}
		
		public static function onError(e:IOErrorEvent):void {
			// Do nothing
			trace(e);
			//if (IS_LOADING_JSON) LoadJSON(JSON2LOAD);
		}
		
		//Static Class Event Utilities
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
            dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
            dispatcher.removeEventListener(type, listener, useCapture);
        }
        public static function dispatchEvent(event:Event):Boolean {
            return dispatcher.dispatchEvent(event);
        }
        public static function hasEventListener(type:String):Boolean {
            return dispatcher.hasEventListener(type);
        }
	}
	
}