package content 
{
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class Post extends Object
	{
		public var ID:Number;
		public var SECTION_ORDER:Number;
		public var SORT_ORDER:Number;
		public var TITLE:String;
		public var SECTION:String;
		public var IMAGE:String;
		public var PREVIEW_TEXT:String;
		public var BODY_TEXT:String;
		public var HEADER_TYPE:String;
		public var HEADER_URL:String;
		public var IMAGE_SHARING:Boolean;
		public var TEXT_SHARING:Boolean;
		public var COMMENTING:Boolean;
		public var AGE_RANGE:Array;
		
		
		public function Post(obj:Object) 
		{
			ID = obj.id;
			TITLE = obj.name;
			SECTION_ORDER = Number(obj.section_order);
			SORT_ORDER = Number(obj.sort_order);
			SECTION = obj.section;
			IMAGE = obj.image;
			PREVIEW_TEXT = obj.post_preview_text;
			BODY_TEXT = obj.post_body;
			HEADER_TYPE = obj.post_header_type;
			HEADER_URL = obj.post_header_url;
			IMAGE_SHARING = obj.image_sharing;
			TEXT_SHARING = obj.text_sharing;
			COMMENTING = obj.commenting;
			
			AGE_RANGE = obj.age_range.split(",");
			
			
			trace("**    ** POST: " + ID + " - " + TITLE);
		}
		
	}

}