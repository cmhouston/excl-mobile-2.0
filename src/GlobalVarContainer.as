package  
{
	import flash.display.Stage;
//	import interfaces.MainInterface;
	import utilities.*;
	import flash.system.Capabilities;
	import content.Exhibit;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class GlobalVarContainer 
	{
		
		 public static var MainStage:Stage;
		 public static var MainBase:Main;
		 public static var MAIN_INTERFACE:MainInterface;
	//	 public static var DATA_MANAGER:DataManager; 
		 
		 //App Dimension Vars
		 public static var ScreenW:Number=0;
		 public static var ScreenH:Number=0;
		 public static var INTERFACE_HEIGHT:Number = 0;
		 
		 //Content Arrays
		 public static var EXHIBITS:Array = [];
		 public static var COMPONENTS_ARRAY:Array = [];
		 public static var COLORS_ARRAY:Array = [];
		 public static var AGE_RANGE:Array = [];
		 public static var SHOW_AGE_ICONS:Boolean=false;
		 
		 public static var BASE_HEIGHT:Number = 1136;
		 public static var HEIGHT_SCALE:Number = 1;
		 public static var KIOSK_DELAY:Number = 4;
		 public static var SCALE_HEIGHT:Number = 1200;
		 public static var HEADER_HEIGHT:Number = 120;
		 public static var MAIN_MAP_PATH:String = "";
		 public static var HOME_ICON:String = "";
		 public static var HOME_INFO_LABEL:String = "";
		 public static var HOME_MAPS_LABEL:String = "";
		 public static var EXHIBITS_LABEL_PL:String = "";
		 public static var EXHIBITS_LABEL:String = "";
		 public static var HOME_EXHIBITS_LABEL:String = "";
		 public static var JSON_PATH:String = "http://excl.dreamhosters.com/prod/wp-json/v01/excl/museum/81";
		 public static var INFO_PAGE_PATH:String = "http://www.cmhouston.org/";
		 
		 public static var SHARE_SUBJECT:String = "";
		 public static var SHARE_MESSAGE:String = "";
		 public static var IOS_LINK:String = "";
		 public static var ANDROID_LINK:String = "";
		 public static var DOWNLOAD_TEXT:String = "";
		 
		 public static var MAC_OS:Boolean = false;
		 
		 public static var cnt:Number = 0;
		 public static var VIDEO_VOL:Number = 1;
		 public static var DATA_MANAGER:DataManager;
		 
		 public static var LOADING_COMPONENTS:Boolean = false;
		 public static var XLARGE_DISPLAY:Boolean = false;
		 public static var LARGE_FONT:String = "42px";
		 public static var LONG_DESC:String = "";
		 
		 public static var SHOW_TUTORIAL:Boolean = true;
		 public static var QUOTES:Array = [];
		 
		 // 0 = Home, 1 = Exhibitiions, 2 = Component, 3 = Post, 4 = Post Icons, 5= Map
		 public static var TUTORIAL_ARRAY:Array = [0,0,0,0,0,0];
		 
		public function GlobalVarContainer() 
		{
		
			
		}
		
		public static function CheckForMac():Boolean 
		{
			if(Capabilities.version.indexOf('IOS') > -1)
			{
				return true;
			}else{
				return false;
			}
			
		}
		
		
		public static function ParseConfig(xml:XML):void {
			trace("Parsing Config");
			JSON_PATH = xml.json_path;
			
			SHARE_SUBJECT = xml.share_subject;
			SHARE_MESSAGE = xml.share_mssg;
			IOS_LINK = xml.ios_link;
			ANDROID_LINK = xml.android_link;
			DOWNLOAD_TEXT = xml.download_text;
			
			INFO_PAGE_PATH = xml.website;
			SCALE_HEIGHT = Number(xml.scale_height);
			KIOSK_DELAY = Number(xml.kiosk_delay);
			//INFO_PAGE = "http://www.cmhouston.org/";
			
			var xList:XMLList = xml.colors.item;
			var xLen:Number = xList.length();
			var obj:Object;
			
			for (var i:uint = 0; i < xLen;++i){
				obj = new Object();
				obj.title = xList[i].title;
				obj.hex = uint(xList[i].hex);
				COLORS_ARRAY.push(obj);
			}
			
			xList = xml.loading_quotes.quote;
			xLen = xList.length();
			
			for (i = 0; i < xLen;++i){
				trace("QUOTE: " + xList[i]);
				QUOTES.push(xList[i]);
			}
			
		}		
		
		public static function ParseContent(obj:Object):void {
			MAIN_MAP_PATH = obj.data.museum.map;
			HOME_ICON = obj.data.museum.homepage_icon;
			HOME_INFO_LABEL = obj.data.museum.homepage_info_label;
			HOME_MAPS_LABEL = obj.data.museum.homepage_map_label;
			HOME_EXHIBITS_LABEL = obj.data.museum.homepage_exhibits_label;
			EXHIBITS_LABEL_PL = obj.data.museum.exhibit_label_plural;
			EXHIBITS_LABEL = obj.data.museum.exhibit_label;
			
			var eArray:Array = obj.data.museum.exhibits
			eArray.sortOn("sort_order", Array.NUMERIC);
			//trace();
			var ex:Exhibit;
			var o:Object;
			
			
			for (var i:uint = 0; i < eArray.length;++i){
				o = eArray[i];
				ex = new Exhibit(o);
				EXHIBITS.push(ex);
				
				if (o.description.length > LONG_DESC.length){
					LONG_DESC = o.description;					
				}
			}
			//LoadExbibit();
		}		
		
		public static function LoadExbibit():void{
			var ex:Exhibit = EXHIBITS[cnt];
			ex.addEventListener(MoreEvent.EXHIBITS_LOADED, onExhibitLoaded);
			ex.LoadComponent();
			
		}
		
		static private function onExhibitLoaded(e:MoreEvent):void 
		{
			var ex:Exhibit = e.target as Exhibit;
			ex.removeEventListener(MoreEvent.EXHIBITS_LOADED, onExhibitLoaded);
			
			cnt++;
			
			if (cnt < EXHIBITS.length){
				LoadExbibit();
			}else{
				
				trace("*********************************");
				trace("*********************************");
				trace("EXHIBITS LOADED");
			}
		}
		
				
		private static function strReplace(str:String, search:String, replace:String):String {
			return str.split(search).join(replace);
		}
		
	}
	
}