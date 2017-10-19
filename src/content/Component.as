package content 
{
	import flash.events.EventDispatcher;
	import utilities.XMLUtil;
	import utilities.XMLUtilityEvent;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class Component extends EventDispatcher
	{
		public var ID:Number;
		public var SORT_ORDER:Number;
		public var TITLE:String;
		public var IMAGE:String;
		public var POSTS:Array=[];
		public var POSTS_LOADED:Boolean=false;
		
		public function Component(obj:Object) 
		{
			ID = obj.id;
			TITLE = obj.name;
			SORT_ORDER = obj.sort_order;
			IMAGE = obj.image;
			
		//	trace("*   * COMPONENT: "+ ID+" - "+ TITLE);
		}
		
		public function LoadPosts():void{
			if(POSTS.length>0){
				this.dispatchEvent(new MoreEvent(MoreEvent.COMP_LOADED));
			}else{
				XMLUtil.addEventListener(XMLUtilityEvent.XML_LOADED, onPostsLoaded);
				XMLUtil.LoadJSON(GlobalVarContainer.JSON_PATH + "/component/" + String(ID));
			}
		}
		
		private function onPostsLoaded(e:XMLUtilityEvent):void 
		{
			trace(" ");
			XMLUtil.removeEventListener(XMLUtilityEvent.XML_LOADED, onPostsLoaded);
			var obj:Object = XMLUtil.myJSON;
			
			var pArray:Array= obj.data.component.posts
			//trace();
			var p:Post;
			var o:Object;
			
			for (var i:uint = 0; i < pArray.length;++i){
				o = pArray[i];
				p = new Post(o);
				POSTS.push(p);
			}
			POSTS.sortOn("SORT_ORDER", Array.NUMERIC);
			POSTS_LOADED = true;
			this.dispatchEvent(new MoreEvent(MoreEvent.COMP_LOADED));
		}
		
	}

}