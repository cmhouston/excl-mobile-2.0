package content 
{
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class Exhibit extends EventDispatcher
	{
		public var ID:Number;
		public var SORT_ORDER:Number;
		public var TITLE:String;
		public var IMAGE:String;
		public var DESC:String;
		public var COMPONENTS:Array = [];
		public var COMPONENTS_PREVIEW:Array = [];
		public var COMPONENTS_JSON:Array = [];
		
		private var cnt:Number = 0;
		
		public function Exhibit(obj:Object) 
		{
			ID = obj.id;
			TITLE = obj.name;
			SORT_ORDER = obj.sort_order;
			IMAGE = obj.exhibit_image;
			DESC = obj.description;
			
			
			COMPONENTS_JSON= obj.components;
			//trace();
			
			var co:Object;
			
			for (var i:uint = 0; i < COMPONENTS_JSON.length;++i){
				co = new Component(COMPONENTS_JSON[i]);
				COMPONENTS.push(co);
			}
		}
		
		public function LoadComponent():void{
			trace("*******************************");
			trace("   EXHIBIT: " + TITLE);
			var co:Component;
			if(cnt<COMPONENTS_JSON.length){
				co = COMPONENTS[cnt];
				co.addEventListener(MoreEvent.COMP_LOADED, onCompLoaded);
				co.LoadPosts();
			}else{
				this.dispatchEvent(new MoreEvent(MoreEvent.EXHIBITS_LOADED));
			}
		}
		
		private function onCompLoaded(e:MoreEvent):void 
		{
			var co:Component = e.target as Component
			co.removeEventListener(MoreEvent.COMP_LOADED, onCompLoaded);
			
			cnt++;
			LoadComponent();
		}
		
	}

}