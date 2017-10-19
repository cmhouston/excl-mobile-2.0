package Pages  
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*
	import content.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.html.HTMLLoader;
	import flash.media.StageWebView;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import modules.CommentPopup;
	import utilities.AppUtility;
	import utilities.LoadedImage;
	import utilities.LoadedImageEvent;
	import utilities.SimpleStageVideo;
	import utilities.SimpleVideoPlayer;
	import flash.events.LocationChangeEvent;
	import utilities.XMLUtil;
	import utilities.XMLUtilityEvent;
	import nid.image.encoder.JPEGEncoder;
	
	//****** SHARING
	import com.milkmangames.nativeextensions.*;
	import com.milkmangames.nativeextensions.events.*;
	
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class PostPage extends Sprite
	{
		private var post:Post;
		private var CommentsArray:Array;
		private var tempBack:TempBack = new TempBack;
		private var cover:MovieClip;
	//	private var textHolder:MovieClip= new MovieClip();
		private var loadCover:LoadingCover = new LoadingCover();
		private var sw:Number = GlobalVarContainer.ScreenW;
		private var sh:Number = GlobalVarContainer.ScreenH;
		private var img:LoadedImage;
		private var vid:SimpleStageVideo;
		//private var htmlLoader:HTMLLoader = new HTMLLoader();
		private var webview:StageWebView = new StageWebView();
	//	private var titleText:TitleText = new TitleText();
		public var IS_VIDEO:Boolean = false;
		private var rect:Rectangle;
		private var freezeData:BitmapData;
		private var webViewBitmap:Bitmap;
		private var freezeTimer:Timer = new Timer(200, 2);
		
		private var postButtons:PostButtons = new PostButtons();
		private var commentPopup:CommentPopup;
		private var BMP:BitmapData; 
		
		private var sharePopup:SharePopup;
		
		public function PostPage(p:Post, bmp:BitmapData) 
		{
			post = p;
			BMP = bmp;
			
		}
		
		public function init():void{
						
			addChild(tempBack);
			tempBack.width = sw;
			tempBack.scaleY = tempBack.scaleX;
			
			loadCover.back.width = sw;
			loadCover.back.alpha = .6;
			loadCover.back.height = tempBack.height;
			loadCover.loader.x = sw / 2;
			loadCover.loader.y = tempBack.height / 2;
			addChild(loadCover);
			cover = AppUtility.CreateBack(sw, sh - this.y - tempBack.height, 0xFFFFFF);
			addChild(cover);
			cover.y =  tempBack.height;
			
			freezeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onFreezeComplete);
			
			/*htmlLoader.width = sw - 20;
			//htmlLoader.height = sh - (textHolder.y + titleText.height + 5);
			htmlLoader.height = 500;
			trace("HTML HEIGHT: " + htmlLoader.height+" /HTML WIDTH: "+htmlLoader.width);
			htmlLoader.x = 10;
			htmlLoader.loadString(post.BODY_TEXT);
			textHolder.addChild(htmlLoader);
			htmlLoader.y = titleText.height + 5;
			
			htmlLoader.addEventListener(LocationChangeEvent.LOCATION_CHANGING, locationChanging);
			*/
			postButtons.scaleX = postButtons.scaleY = sw / postButtons.width;
			
			/*postButtons.btn_share.x = sw / 2 - 40-postButtons.btn_share.width;
			postButtons.btn_comment.x = sw / 2 + 40;*/
			postButtons.btn_share.visible = false;
			postButtons.btn_comment.visible = false;
			if (AppUtility.isMobile()){			
			
				if (GoViral.goViral.isEmailAvailable()||GoViral.goViral.isSocialServiceAvailable(GVSocialServiceType.SMS)){
					postButtons.btn_share.visible = true;
					postButtons.btn_share.buttonMode = true;
					postButtons.btn_share.addEventListener(MouseEvent.CLICK, onSharePost);
				}
				
				if (post.COMMENTING){
					postButtons.btn_comment.visible = true;
					postButtons.btn_comment.buttonMode = true;
					postButtons.btn_comment.addEventListener(MouseEvent.CLICK, onCommentPost);
				}
			
			}
			rect=new Rectangle(0, cover.y+this.y, sw, sh - ( cover.y+this.y));
			
			//addChild(textHolder);
			
			trace("HEADER TYPE: " + post.HEADER_TYPE+" /PATH: " + post.HEADER_URL);
			
			if (post.HEADER_URL == "false"){
				post.HEADER_TYPE = "image";
				post.HEADER_URL = post.IMAGE;
			}
			if (post.HEADER_TYPE == "image"){
				tempBack.gotoAndStop(1);
				img = new LoadedImage(post.HEADER_URL);
				img.addEventListener(LoadedImageEvent.LOADED_IMAGE_COMPLETE, onImgComplete);
				img.loadImage();
			}else{
				IS_VIDEO = true;
				tempBack.gotoAndStop(2);
				vid = new SimpleStageVideo(post.HEADER_URL, this.y);
				vid.addEventListener(MoreEvent.VIDEO_LOADED, onVidLoaded);
				vid.init();
			}
			
			
		}
		
		private function onCommentPost(e:MouseEvent):void 
		{
			FreezePage();
			GlobalVarContainer.MainBase.ShowDropCover();
			commentPopup = new CommentPopup(post.ID);
			commentPopup.addEventListener(MoreEvent.CLOSE_POPUP, onClosePopup);
			commentPopup.width = sw - 60;
			commentPopup.scaleY = commentPopup.scaleX;
			GlobalVarContainer.MainBase.addChild(commentPopup);
			commentPopup.x = sw / 2 - commentPopup.width / 2;
			commentPopup.y = sh + 20;
			
			TweenMax.to(commentPopup, .6, {y:20, ease:Strong.easeOut});
			
		}
		
		private function onClosePopup(e:MoreEvent):void 
		{
			UnFreezePage();
			commentPopup.removeEventListener(MoreEvent.CLOSE_POPUP, onClosePopup);
			TweenMax.to(commentPopup, .4, {y:sh + 20, ease:Strong.easeOut, onComplete:RemovePopup});
		}
		
		private function RemovePopup():void 
		{
			GlobalVarContainer.MainBase.RemoveDropCover();
			GlobalVarContainer.MainBase.removeChild(commentPopup);
			commentPopup = null;
		}
		
		private function onSharePost(e:MouseEvent):void 
		{
			FreezePage();
			GlobalVarContainer.MainBase.ShowDropCover();
			sharePopup = new SharePopup();
			sharePopup.btn_close.addEventListener(MouseEvent.MOUSE_DOWN, onCloseSharePopup);
			if (GoViral.goViral.isEmailAvailable()){
				sharePopup.btn_email.alpha = 1;
				if(GlobalVarContainer.CheckForMac()){
					sharePopup.btn_email.addEventListener(MouseEvent.MOUSE_DOWN, sendEmailMessage);
				}else{
					sharePopup.btn_email.addEventListener(MouseEvent.MOUSE_DOWN, sendAndroidEmail);
				}
			}else{
				sharePopup.btn_email.alpha = .3;
			}
			
			
			if (GoViral.goViral.isSocialServiceAvailable(GVSocialServiceType.SMS)){
				
				sharePopup.btn_text.alpha = 1;
				if(GlobalVarContainer.CheckForMac()){
					sharePopup.btn_text.addEventListener(MouseEvent.MOUSE_DOWN, socialComposerSMS);
				}else{
					sharePopup.btn_text.addEventListener(MouseEvent.MOUSE_DOWN, sendGenericMessage);
				}
			}else{
				sharePopup.btn_text.alpha = .3;
			}
			
			
			sharePopup.width = sw - 60;
			sharePopup.scaleY = sharePopup.scaleX;
			GlobalVarContainer.MainBase.addChild(sharePopup);
			sharePopup.x = sw / 2 - sharePopup.width / 2;
			sharePopup.y = sh + 20;
			
			TweenMax.to(sharePopup, .6, {y:20, ease:Strong.easeOut});
			
			
			
		}
		
		private function onCloseSharePopup(e:MouseEvent):void 
		{
			RemoveSharePopup();
		}
		
		private function RemoveSharePopup():void 
		{
			UnFreezePage();
			sharePopup.btn_close.removeEventListener(MouseEvent.MOUSE_DOWN, onCloseSharePopup);
			if(GlobalVarContainer.CheckForMac()){
				sharePopup.btn_email.removeEventListener(MouseEvent.MOUSE_DOWN, sendEmailMessage);
				sharePopup.btn_text.removeEventListener(MouseEvent.MOUSE_DOWN, socialComposerSMS);
			}else{
				sharePopup.btn_email.removeEventListener(MouseEvent.MOUSE_DOWN, sendAndroidEmail);
				sharePopup.btn_text.removeEventListener(MouseEvent.MOUSE_DOWN, sendGenericMessage);
			}
			GlobalVarContainer.MainBase.RemoveDropCover();
			GlobalVarContainer.MainBase.removeChild(sharePopup);
			sharePopup = null;
		}
		
		
		
		private function locationChanging(e:LocationChangeEvent):void 
		{
			e.preventDefault();
			trace("Link Clicked: " +e.location);
			GlobalVarContainer.MAIN_INTERFACE.ShowWebPage(e.location);
		}
		
		public function InitWeb():void{
			XMLUtil.addEventListener(XMLUtilityEvent.XML_LOADED, onPostContentLoaded);
			XMLUtil.LoadJSON(GlobalVarContainer.JSON_PATH + "/component/" + String(post.ID));			
		
		}
		
		
		private function onPostContentLoaded(e:Event):void 
		{
			XMLUtil.removeEventListener(XMLUtilityEvent.XML_LOADED, onPostContentLoaded);
			var obj:Object = XMLUtil.myJSON;
			
			if (obj.data.component.comments == false){
				CommentsArray = [];
			}else{
				CommentsArray = obj.data.component.comments;
			}
			
			trace("Comments: " + CommentsArray.length);
			
			ShowWeb();
		}
		
		private function ShowWeb():void 
		{
			webview.stage = GlobalVarContainer.MainStage;
			
			//webview.viewPort = rect;
			/*<video width="320" height="240" controls>
			  <source src="movie.mp4" type="video/mp4">
			  <source src="movie.ogg" type="video/ogg">
			Your browser does not support the video tag.
			</video>
*/			var postBody:String;
			var padding:Number =20;
			var sides:String = String(padding) + "px";
			var twidth:String = String(sw-40) + "px";
			var fsize:String = "30px";
			var csize:String = "30px";
			if (GlobalVarContainer.XLARGE_DISPLAY){
				fsize = "20px";
				csize = "24px";
			}
			//postBody = '<html><head><meta name="viewport" content="width='+twidth+', initial-scale=1.0, maximum-scale=1.0, user-scalable=no" /></head><body>';
			postBody = '<html><head><meta name="viewport" content="width=device-width" /></head><body>';
			//postBody += "<table width='" + twidth + "'style='table-layout: fixed; padding-left:" + sides + "; padding-right:" + sides + ";padding-top:10px; padding-bottom:20px; display: inline-block; word-wrap: break-word; overflow-wrap:break-word; font-size:"+fsize+"'><tr><td align='center'><h3>" + post.TITLE+"</h3></td></tr><tr><td style='; word-wrap: break-word; overflow-wrap:break-word;'>" + post.BODY_TEXT + "<br/><br/></td></tr><tr><td><br/><br/><h4><u>Comments:</u></h4></td></tr>";
			postBody += "<table 'style='table-layout: fixed; padding-left:" + sides + "; padding-right:" + sides + ";padding-top:10px; padding-bottom:20px; display: inline-block; word-wrap: break-word; overflow-wrap:break-word; font-size:"+fsize+"'><tr><td align='center'><h3>" + post.TITLE+"</h3></td></tr><tr><td style='; word-wrap: break-word; overflow-wrap:break-word;'>" + post.BODY_TEXT + "<br/><br/></td></tr><tr><td><br/><br/><h4><u>Comments:</u></h4></td></tr>";
			//postBody = "<table width='" + twidth + "'style='table-layout: fixed; padding-left:" + sides + "; padding-right:" + sides + ";padding-top:10px; padding-bottom:20px; display: inline-block; word-wrap: break-word; overflow-wrap:break-word; font-size:"+fsize+"'><tr><td align='center'><h3>" + post.TITLE+"</h3></td></tr><tr><td style='; word-wrap: break-word; overflow-wrap:break-word;'>" + post.BODY_TEXT + "<br/><br/></td></tr><tr><td><br/><br/><h4><u>Comments:</u></h4></td></tr>";
			
			if (CommentsArray.length > 0 ){
				for (var i:uint = 0; i < CommentsArray.length; ++i){
					postBody += "<tr><td>" + CommentsArray[i].body + "<br/><br/><span style='font-size:"+csize+"; color:grey'><i>" + CommentsArray[i].date+"</i></span><br/><br/></td></tr>";
				}
			}else{
				postBody += "<tr><td><i>There are no comments to display</i></td></tr>"
			}
			
			//postBody += "<tr><td><br/><br/></td></tr></table>";
			postBody += "<tr><td><br/><br/></td></tr></table></body></html>";
			
			webview.loadString(postBody, "text/html" );
			webview.addEventListener(LocationChangeEvent.LOCATION_CHANGING, locationChanging);
			
			//webview.
			trace("BODY: " + post.BODY_TEXT);
		}
		
		private function ResetWeb():void 
		{
			
			if(webview)
			webview.viewPort = rect;
			
			if (IS_VIDEO){
				vid.MoveVideo(rect.x);
			}
		}
		
		public function ClosePage():void{
			if (IS_VIDEO){
				vid.goClear();
			}
			TweenMax.killTweensOf(rect);
				webview.stage = null;
				
				webview.dispose();
				webview = null;
		}
		
		public function SlideWebPage():void{
			TweenMax.to(rect, .6, {x: sw, ease:Strong.easeOut, onUpdate:ResetWeb});
		}
		
		
		public function MenuSlideWeb(w:Number):void{
			TweenMax.to(rect, .6, {x: w, ease:Strong.easeOut, onUpdate:ResetWeb});
		}
		
		public function FreezePage():void{
			freezeData = new BitmapData(webview.viewPort.width, webview.viewPort.height,true,0xffffff);
			webview.drawViewPortToBitmapData(freezeData);
			webViewBitmap = new Bitmap(freezeData);
			
			webview.stage = null;
			webViewBitmap.y = rect.y-this.y;
			addChild(webViewBitmap);
		}
		
		public function UnFreezePage():void{
			freezeTimer.start();
		}
		
		private function onFreezeComplete(e:TimerEvent):void 
		{
			freezeTimer.reset();
			removeChild(webViewBitmap);
			webViewBitmap = null;
			webview.stage = GlobalVarContainer.MainStage;
		}
		
		private function onImgComplete(e:LoadedImageEvent):void 
		{
			img.removeEventListener(LoadedImageEvent.LOADED_IMAGE_COMPLETE, onImgComplete);
			this.addChild(img);
			img.width = sw;
			img.scaleY = img.scaleX;
			
			addChild(loadCover);
			addChild(cover);
			
			var VH:Number = img.height;
			if (img.height > sh / 2) VH = sw / 2;
			
			TweenMax.to(cover, 1, {y: img.height, ease:Strong.easeOut});
			TweenMax.to(loadCover, 1, {alpha:0, ease:Strong.easeOut, onComplete:removeLoadCover});
			
			removeChild(tempBack);
			tempBack = null;
			
			//Add the post buttons
			if(AppUtility.isMobile()){
				addChild(postButtons);
				postButtons.y = sh;
			}else{
				postButtons.height = 0;
			}
			
			 
			webview.viewPort = rect;
			TweenMax.to(rect, 1, {y: VH + this.y + postButtons.height, height:sh - (VH + this.y + postButtons.height), ease:Strong.easeOut, onUpdate:ResetWeb, onComplete:ShowPostButtons });
		}
		
		private function ShowPostButtons():void 
		{
			postButtons.y = img.height;
		}
		
		
		private function onVidLoaded(e:MoreEvent):void 
		{
			vid.removeEventListener(MoreEvent.VIDEO_LOADED, onVidLoaded);
			addChild(vid);
			addChild(loadCover);
			addChild(cover);
		//	addChild(textHolder);
			var VH:Number = vid.VH;
			TweenMax.to(cover, 1, {y: VH, ease:Strong.easeOut});
			//TweenMax.to(textHolder, 1, {y:  VH + 10, ease:Strong.easeOut});
			
			removeChild(tempBack);
			tempBack = null;
			
			//Add the post buttons
			if(AppUtility.isMobile()){
				addChild(postButtons);
				postButtons.y = VH;
			}else{
				postButtons.height = 0;
			}
			
			TweenMax.to(rect, 1, {y: VH+this.y+postButtons.height, height:sh-(VH+this.y+postButtons.height),ease:Strong.easeOut, onUpdate:ResetWeb});
			TweenMax.to(loadCover, 1, {alpha:0, ease:Strong.easeOut, onComplete:removeLoadCover});
			
			
		}
		
		private function removeLoadCover():void 
		{
			this.removeChild(loadCover);
			loadCover = null;
		}
		
		//************ SHARING FUNCTIONS **************//
		/** Social Composer SMS */
		public function socialComposerSMS(e:MouseEvent):void
		{
			
			RemoveSharePopup();
			var mssg:String = post.TITLE+"\r\r" + AppUtility.stripHTML(post.BODY_TEXT);
			
			log("Check availability...");
			if (!GoViral.goViral.isSocialServiceAvailable(GVSocialServiceType.SMS))
			{
				log("SMS service not available.");
				return;
			}
			
			//var bitmapData:BitmapData=getOrCreateBitmapData();
			
			log("Showing composer...");

			GoViral.goViral.displaySocialComposerView(
				"SMS", 
				mssg, 
				BMP,
				"http://www.cmhouston.org/"
				).addDialogListener(function(e:GVShareEvent):void {
					switch(e.type)
					{
						case GVShareEvent.SOCIAL_COMPOSER_FINISHED:
							log("SMS composer finished!");
							break;
						case GVShareEvent.SOCIAL_COMPOSER_CANCELED:
							log("SMS composer canceled.");
							break;
					}
				});
				
			log("did show SMS composer.");
		}
		
		/** Send Generic Message */
		public function sendGenericMessage(e:MouseEvent):void
		{
			RemoveSharePopup();
			
			if (!GoViral.goViral.isGenericShareAvailable())
			{
				log("Generic share doesn't work on this platform.");
				return;
			}
				
			var mssg:String = post.TITLE+"\r\r" + AppUtility.stripHTML(post.BODY_TEXT);

			log("Sending generic share intent...");
			
			GoViral.goViral.shareGenericMessage(
				GlobalVarContainer.SHARE_SUBJECT,
				mssg,
				false,
				350,
				512).addDialogListener(function(e:GVShareEvent):void {
					log("Generic share completed.");
			});
				
			log("Did send generic share intent.");
		}
		
		
		public function sendEmailMessage(e:MouseEvent):void
		{
			RemoveSharePopup();
			var mssg:String = "<html><body><table><tr><td><img src='" + post.IMAGE+"' /></td></tr><tr><td><h2>" + post.TITLE+"</h2>" + post.BODY_TEXT + "<br/><br/></td></tr><tr><td style='height:10px'></td></tr><tr><td align='center'><br/><br/>"+GlobalVarContainer.DOWNLOAD_TEXT+":<br/><br/>";
			if (GlobalVarContainer.IOS_LINK != ""){
				mssg += "<a href='" + GlobalVarContainer.IOS_LINK + "'>iTunes</a><br/><br/>";
			}
			if (GlobalVarContainer.ANDROID_LINK != ""){
				mssg += "<a href='" + GlobalVarContainer.ANDROID_LINK + "'>Google Play</a><br/>";
			}
			mssg += "</td></tr></table></body></html>";
			
			if (!GoViral.goViral.isEmailAvailable())
			{
				log("Email is not enabled on device.");
				return;
			}
			log("Opening email composer...");			
			
			GoViral.goViral.showEmailComposer(
			GlobalVarContainer.SHARE_SUBJECT, "",
			mssg, true).addDialogListener(function(e:GVMailEvent):void {
				switch(e.type)
				{
					case GVMailEvent.MAIL_SENT:
						log("Mail sent!");
						break;
					case GVMailEvent.MAIL_SAVED:
						log("Mail saved.");
						break;
					case GVMailEvent.MAIL_CANCELED:
						log("Mail canceled.");
						break;
					case GVMailEvent.MAIL_FAILED:
						log("Failed sending mail.");
						break;
				}
			});
			log("Email Composer opened.");
		}
		
		/*public function sendAndroidEmail(e:MouseEvent):void{
			RemoveSharePopup();
			var mssg:String = "<html><body><table><tr><td><h2>" + post.TITLE+"</h2>" + post.BODY_TEXT + "<br/><br/></td></tr><tr><td style='height:10px'></td></tr><tr><td align='center'><br/><br/>"+GlobalVarContainer.DOWNLOAD_TEXT+":<br/><br/>";
			if (GlobalVarContainer.IOS_LINK != ""){
				mssg += "<a href='" + GlobalVarContainer.IOS_LINK + "'>iTunes</a><br/><br/>";
			}
			if (GlobalVarContainer.ANDROID_LINK != ""){
				mssg += "<a href='" + GlobalVarContainer.ANDROID_LINK + "'>Google Play</a><br/>";
			}
			mssg += "</td></tr></table></body></html>";
			
			var encoder:JPEGEncoder = new JPEGEncoder(90);
			var byteArray:ByteArray = encoder.encode(BMP);
			
			if(GoViral.goViral.isEmailAvailable())
			{
				// show an email to who@where.com and john@doe.com, with subject 'this is a subject!', a
				// and a plain text body of 'This has a pic attached.' Attaches a bitmapData image called
				// myBitmapData.
				GoViral.goViral.showEmailComposerWithByteArray(
				GlobalVarContainer.SHARE_SUBJECT, "", mssg, true, byteArray, "image/jpeg", "photo.jpg").addDialogListener(function(e:GVMailEvent):void {
					switch(e.type)
					{
					case GVMailEvent.MAIL_SENT:
					trace("Mail sent!");
					break;
					case GVMailEvent.MAIL_SAVED:
					trace("Mail saved.");
					break;
					case GVMailEvent.MAIL_CANCELED:
					trace("Mail canceled.");
					break;
					case GVMailEvent.MAIL_FAILED:
					trace("Failed sending mail.");
					break;
					}
				});
			}
		}*/
		public function sendAndroidEmail(e:MouseEvent):void{
			RemoveSharePopup();
			var mssg:String = "<html><body><table><tr><td><h2>" + post.TITLE+"</h2>" + post.BODY_TEXT + "<br/><br/></td></tr><tr><td style='height:10px'></td></tr><tr><td align='center'><br/><br/>" + GlobalVarContainer.DOWNLOAD_TEXT + ":<br/><br/>";
			
			if (GlobalVarContainer.IOS_LINK != ""){
				mssg += "<a href='" + GlobalVarContainer.IOS_LINK + "'>iTunes</a><br/><br/>";
			}
			if (GlobalVarContainer.ANDROID_LINK != ""){
				mssg += "<a href='" + GlobalVarContainer.ANDROID_LINK + "'>Google Play</a><br/>";
			}
			mssg += "</td></tr></table></body></html>";			
			
			
			if(GoViral.goViral.isEmailAvailable())
			{
				// show an email to who@where.com and john@doe.com, with subject 'this is a subject!', a
				// and a plain text body of 'This has a pic attached.' Attaches a bitmapData image called
				// myBitmapData.
				GoViral.goViral.showEmailComposer(
				GlobalVarContainer.SHARE_SUBJECT, "", mssg, true).addDialogListener(function(e:GVMailEvent):void {
					switch(e.type)
					{
					case GVMailEvent.MAIL_SENT:
					trace("Mail sent!");
					break;
					case GVMailEvent.MAIL_SAVED:
					trace("Mail saved.");
					break;
					case GVMailEvent.MAIL_CANCELED:
					trace("Mail canceled.");
					break;
					case GVMailEvent.MAIL_FAILED:
					trace("Failed sending mail.");
					break;
					}
				});
			}
		}
		private function log(msg:String):void
		{
			trace("[GoViralExample] "+msg);
			//txtStatus.text=msg;
		}
	}

}