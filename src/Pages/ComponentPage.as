package Pages 
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*
	import content.Component;
	import content.Post;
	import content.PostSection;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import modules.PostRow;
	import utilities.LoadedImageEvent;
	import utilities.LoadedImage;
	import utilities.AppUtility;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class ComponentPage extends MovieClip
	{
		private var img:LoadedImage;
		private var COMPONENT:Component;
		private var section:PostSection;
		private var sw:Number = GlobalVarContainer.ScreenW;
		private var sh:Number = GlobalVarContainer.ScreenH;
		private var header:SectionHeader;
		private var back:MovieClip;
		
		private var SECTION_ARRAY:Array = [];
		private var POSTS_ARRAY:Array = [];
		private var post:Post;
		
		private var row:SectionRow;
		private var pRow:PostRow;
		private var pageHolder:MovieClip = new MovieClip();
		private var postRowPage:MovieClip = new MovieClip();
		private var pRowArray:Array;
		private var postPage:PostPage;
		private var kioskTimer:Timer;
		private var timerCover:BlackBack = new BlackBack();
		private var popup:ModePopup = new ModePopup();
		private var KIOSK_MODE:Boolean = false;
		private var SHOWING_MENU:Boolean = false;
		private var iconAge:Icon_agefilter;
		private var AR:Array;
		
		
		private var dvy:Number = 0;  
		// previous coordinates  
		private var prevY:Number = 0;  
		// deceleration  
		private var friction:Number = 0.9;  

		private var dragRect:Rectangle;
		private var catRect:Rectangle;
		private var CURR_RECT:Rectangle;
		private var StartY:Number = 100;
		private var rowHolder:Sprite= new Sprite();
		private var rowback:Btn_Black = new Btn_Black();
		private var RowMask:Btn_Black = new Btn_Black();
		private var IS_DRAGGING:Boolean = false;
		private var HSC:Number = 1;
		
		private var catHolder:Sprite= new Sprite();
		private var catback:Btn_Black = new Btn_Black();
		private var CatMask:Btn_Black = new Btn_Black();
		
		
		private var CURR_HOLDER:Sprite;
		
		public function ComponentPage(c:Component) 
		{
			COMPONENT = c;
			
			back = AppUtility.CreateBack(sw, sh, 0xffffff);
			this.addChild(back);
			
			header = new SectionHeader();			
			
			header.btn_menu.x = header.back.width - header.btn_menu.width -10;
			
			header.title_txt.autoSize = "center";
			
			header.width = sw;
			header.scaleY = header.scaleX;
			
			header.title_txt.htmlText = COMPONENT.TITLE;
			
			//var titleSpace:Number = 640 - ((header.btn_back.x + header.btn_back.width) + header.btn_menu.x + 40);
			var titleSpace:Number = 460;
			if (header.title_txt.width > titleSpace){
				header.title_txt.scaleY = HSC =header.title_txt.scaleX= titleSpace/header.title_txt.width;
				header.title_txt.y = header.back.height / 2 - header.title_txt.height / 2;
			}
			header.title_txt.x = header.back.width / 2 - header.title_txt.width / 2
			
			header.btn_menu.buttonMode = true;
			header.btn_back.buttonMode = true;
			header.btn_back.addEventListener(MouseEvent.MOUSE_DOWN, onBack);
			this.addChild(header);
			
			header.btn_menu.addEventListener(MouseEvent.MOUSE_DOWN, onShowMenu);
			
			addChild(pageHolder);
			
			timerCover.width = sw;
			timerCover.height = sh;
			timerCover.alpha = .3;
			kioskTimer = new Timer(1000, GlobalVarContainer.KIOSK_DELAY);
			header.title_txt.addEventListener(MouseEvent.MOUSE_DOWN, onGoKioskMode);
			header.title_txt.addEventListener(MouseEvent.MOUSE_UP, onStopKioskMode);
			header.title_txt.addEventListener(MouseEvent.MOUSE_OUT, onStopKioskMode);
		}
		
		
		private function onShowMenu(e:MouseEvent):void 
		{
			if (postPage){
				if(SHOWING_MENU){
					postPage.UnFreezePage();
					SHOWING_MENU = false;
				}else{
					postPage.FreezePage();
					SHOWING_MENU = true;
				}
			}
			GlobalVarContainer.MainBase.ShowMenu();
		}
		
		private function onBack(e:MouseEvent):void 
		{
			header.btn_back.removeEventListener(MouseEvent.MOUSE_DOWN, onBack);
			this.dispatchEvent(new MoreEvent(MoreEvent.UNLOAD_PAGE));
		}
		
		public function init():void{
			trace("IMAGE: " + COMPONENT.IMAGE);
			img = new LoadedImage(COMPONENT.IMAGE);
			img.addEventListener(LoadedImageEvent.LOADED_IMAGE_COMPLETE, onImgComplete);
			img.loadImage();
		}
		
		private function onImgComplete(e:LoadedImageEvent):void 
		{
			img.removeEventListener(LoadedImageEvent.LOADED_IMAGE_COMPLETE, onImgComplete);
			img.width = sw;
			img.scaleY = img.scaleX;
			pageHolder.addChild(catHolder);
			catHolder.addChild(catback);
			catHolder.y = header.height;
			catHolder.addChild(img)
			
			this.dispatchEvent(new MoreEvent(MoreEvent.PAGE_LOADED));
			
			if (COMPONENT.POSTS_LOADED){
				POSTS_ARRAY = COMPONENT.POSTS;
				sortPosts();
			}else{
				GetPosts();
			}
		}
		
	
		private function GetPosts():void 
		{
			COMPONENT.addEventListener(MoreEvent.COMP_LOADED, onComploaded);
			COMPONENT.LoadPosts();
		}
		
		private function onComploaded(e:MoreEvent):void 
		{
			COMPONENT.removeEventListener(MoreEvent.COMP_LOADED, onComploaded);
		
			trace("SORTING POSTS");
			POSTS_ARRAY = COMPONENT.POSTS;
			GlobalVarContainer.COMPONENTS_ARRAY.push([COMPONENT.ID, POSTS_ARRAY]);
			sortPosts();
			
		}
		
		private function sortPosts():void{
			
			catRect = new Rectangle();
			dragRect = new Rectangle();
				
			var s:String;
			var sa:Array=[];
			
			for (var i:uint = 0; i < POSTS_ARRAY.length; ++i){
				post = POSTS_ARRAY[i];
				s = post.SECTION;
				if (sa.indexOf(s) < 0){
					//trace("**********************");
				//	trace("NEW SECTION: "+s);
					section = new PostSection();
					section.TITLE = s;
					section.SORT_ORDER = post.SECTION_ORDER;
					section.POSTS.push(post);
					SECTION_ARRAY.push(section);
					sa.push(s);
				}else{
					section = SECTION_ARRAY[sa.indexOf(s)];
					section.POSTS.push(post);
				//	trace("SECTION: " + section.TITLE+" /CNT: " + section.POSTS.length);
				}
			}
			
			SECTION_ARRAY.sortOn("SORT_ORDER", Array.NUMERIC);
			
			catback.alpha = 0;
			catback.height = 10;
			//rowHolder.y = HH + 10;
			
			var xtra:Number = 10;
			if (GlobalVarContainer.XLARGE_DISPLAY) xtra = 20;
			var start:Number = img.y + img.height + xtra;
			
			for (i = 0; i < SECTION_ARRAY.length; ++i){
				row = new SectionRow();
				row.title_txt.autoSize = "left";
				row.title_txt.mouseEnabled = false;
				row.title_txt.htmlText = SECTION_ARRAY[i].TITLE;
				row.NUM = i;
				row.width = sw;
				row.scaleY = row.scaleX;
				AppUtility.ChangeColor(row.back, GlobalVarContainer.COLORS_ARRAY[i].hex);
				catHolder.addChild(row);
				row.y = start;
				start += row.height + xtra;
				row.buttonMode = true;
				row.mouseChildren = false;
				row.alpha = 0;
				row.visible = false;
				TweenMax.to(row, .2, {autoAlpha:1, delay:i * .1});
				row.addEventListener(MouseEvent.CLICK, onShowSectionPosts);
			}
			
			var HH:Number = header.y + header.height;
			
			if (catHolder.height > sh - HH){
				
				CURR_HOLDER = catHolder;
				trace("NEED A SCROLLER");
				catback.width = sw;
				catback.height = catback.height+10;
				catRect.x - 0
				catRect.y = HH-(catHolder.height - (sh - HH));
				catRect.width = 0;
				catRect.height = catHolder.height - (sh - HH);
				CURR_RECT = catRect;
				IS_DRAGGING = false;
				catHolder.addEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
				CatMask.width = sw;
				CatMask.height = sh - HH;
				CatMask.x = 0;
				CatMask.y = HH;
				pageHolder.addChild(CatMask);
				catHolder.mask = CatMask;
				
			}
			
		}
		
		private function onShowSectionPosts(e:MouseEvent):void 
		{			
			if (IS_DRAGGING) return;
			
			/*if(CURR_HOLDER){
				CURR_HOLDER.removeEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
			}*/
			stopAnimation();
			var start:Number = 0;
			var n:Number = e.target.NUM;
			var HH:Number = header.y + header.height+10;
			AR = GlobalVarContainer.AGE_RANGE;
			
			pRowArray = [];
			
			section = SECTION_ARRAY[n];
			var a:Array = section.POSTS;
			var row:Sprite;
			
			postRowPage.addChild(rowHolder);
			rowHolder.addChild(rowback);
			rowback.alpha = 0;
			rowback.height = 10;
			rowHolder.y = HH+10;
			
			for (var i:uint = 0; i < a.length; ++i){
				row = new Sprite;
				pRow = new PostRow(a[i]);
				pRow.LoadRow();
				
				rowHolder.addChild(row);
				row.addChild(pRow);
				row.y = start;
				row.x = 10;
				pRow.width = sw - 20;
				pRow.scaleY = pRow.scaleX;
				start += row.height+10;
				pRowArray.push(pRow);
				pRow.ROW = row;
				pRow.NUM = i;
				pRow.buttonMode = true;
				pRow.mouseChildren = false;
				pRow.addEventListener(MouseEvent.CLICK, onShowPostPage);
				var p:Post = a[i];
				
				//Check the age filter and add icon				
				iconAge = new Icon_agefilter();
				iconAge.x = row.width - iconAge.width - 10;
				iconAge.y = row.height - iconAge.height - 10;
				pRow.icon = iconAge;
				
				row.addChild(iconAge);
				if(CheckAgeRange(p)){		
					trace("HAS AGE: " + p.AGE_RANGE);
					TintRow(pRow, 0);
					iconAge.gotoAndStop(2);
				}else{		
					trace("NO AGE: " + p.AGE_RANGE);
					TintRow(pRow, .5);
					iconAge.gotoAndStop(1);
				}
				
			}
			
			postRowPage.x = sw;
			addChild(postRowPage);
			
			header.title_txt.scaleY = header.title_txt.scaleX = 1;
			header.title_txt.htmlText = section.TITLE;
			//var titleSpace:Number = 640 - ((header.btn_back.x + header.btn_back.width) + header.btn_menu.x + 40);
			var titleSpace:Number = 460;
			if (header.title_txt.width > titleSpace){
				//header.title_txt.width = titleSpace;
				header.title_txt.scaleY = header.title_txt.scaleX= 460/header.title_txt.width;
				header.title_txt.y = header.back.height / 2 - header.title_txt.height / 2;
			}
			header.title_txt.x = header.back.width / 2- header.title_txt.width/2
			
			
			header.btn_back.removeEventListener(MouseEvent.MOUSE_DOWN, onBack);
			
			TweenMax.to(pageHolder, .6, {x:0 - sw, ease:Strong.easeOut});
			TweenMax.to(postRowPage, .6, {x:0, ease:Strong.easeOut, onComplete:AddBackEvent});
			rowback.height = rowHolder.height;
			
			if (rowHolder.height > sh - HH){
				
				CURR_HOLDER = rowHolder;
				//trace("NEED A SCROLLER");
				rowback.width = sw;
				rowback.height = rowHolder.height + 10;
				
				dragRect.height = rowHolder.height-(sh-HH)
				trace("DRAG RECT HEIGHT: " + dragRect.height);
				dragRect.y =  HH - dragRect.height;
				//dragRect.y =  HH - (rowHolder.height - (sh - HH));
				CURR_RECT = dragRect;
				IS_DRAGGING = false;
				rowHolder.addEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
				RowMask.width = sw;
				RowMask.height = sh - HH;
				RowMask.x = 0;
				RowMask.y = HH;
				postRowPage.addChild(RowMask);
				rowHolder.mask = RowMask;
				
			}
			
			header.btn_back.visible = true;
		}
		
		//****************************************//
		//AGE CHECK FUNCTIONS
		private function CheckAgeRange(p:Post):Boolean 
		{
			trace("AGE RANGE LENGTH: " + AR.length);
			pRow.CheckAgeIcons();
			
			if (AR.length < 1){
				pRow.icon.visible = false;
				pRow.ages.visible = false;
				return true;
			}else{				
				if (GlobalVarContainer.SHOW_AGE_ICONS){
					pRow.icon.visible = false;
					pRow.ages.visible = true;
				}else{
					pRow.ages.visible = false;
					pRow.icon.visible = true;
				}
			}
			
			var HAS_AGE:Boolean = false;
			var s:String;
			for (var i:uint = 0; i < p.AGE_RANGE.length; ++i){
				s = p.AGE_RANGE[i];
				if (AR.lastIndexOf(s) >= 0){
					//trace("HAS THE AGE: " + s);
					HAS_AGE = true;
					break;
				}
			}
			if(!HAS_AGE)pRow.ages.visible = false;
			return HAS_AGE;
		}
		
		//Change the row to grey at 50% if it's not in the age range
		private function TintRow(row:PostRow, t:Number):void{
			TweenMax.to(row, 0, {colorMatrixFilter:{colorize:0x8a8a8a, amount:t}}); 
		}
		
		private function onShowPostPage(e:MouseEvent):void 
		{
			if (IS_DRAGGING) return;
			header.btn_back.removeEventListener(MouseEvent.MOUSE_DOWN, onBackToComponent);
			var n:Number = e.target.NUM;
			var p:Post = section.POSTS[n];
			var bmp:BitmapData = e.target.img.GetBitMapData();
			postPage = new PostPage(p, bmp);
			
			addChild(postPage);
			postPage.x = sw;
			postPage.y = header.height;
			postPage.init();
			TweenMax.to(postRowPage, .6, {x:0 - sw, ease:Strong.easeOut});
			TweenMax.to(postPage, .6, {x:0, ease:Strong.easeOut, onComplete:AddBackToSectionEvent});
			
			
			header.btn_back.visible = true;
			
			if (p.HEADER_TYPE != "image")
			removeChild(back);
		}
		
		private function AddBackToSectionEvent():void 
		{
			postPage.InitWeb();
			header.btn_back.addEventListener(MouseEvent.MOUSE_DOWN, onBackToSection);
		}
		
		private function onBackToSection(e:MouseEvent):void 
		{
			header.btn_back.removeEventListener(MouseEvent.MOUSE_DOWN, onBackToSection);
			postPage.SlideWebPage();
			TweenMax.to(postRowPage, .6, {x:0, ease:Strong.easeOut});
			TweenMax.to(postPage, .6, {x:sw, ease:Strong.easeOut,onComplete:RemovePostPage});
		}
		
		private function RemovePostPage():void 
		{
			this.removeChild(postPage);
			postPage.ClosePage();
			postPage = null;
			AddBackEvent();
		}
		
		private function AddBackEvent():void 
		{			
			
			if (GlobalVarContainer.SHOW_TUTORIAL && GlobalVarContainer.TUTORIAL_ARRAY[3] == 0)
			GlobalVarContainer.MainBase.ShowTutorial(3);
			header.btn_back.addEventListener(MouseEvent.MOUSE_DOWN, onBackToComponent);
		}
		
		private function onBackToComponent(e:MouseEvent):void 
		{			
			var HH:Number = header.y + header.height+10;
			header.title_txt.htmlText = COMPONENT.TITLE;
			
			header.title_txt.scaleY = header.title_txt.scaleX = HSC;
			header.title_txt.y = header.back.height / 2 - header.title_txt.height / 2;
			header.title_txt.x = header.back.width / 2 - header.title_txt.width / 2;
			header.btn_back.removeEventListener(MouseEvent.MOUSE_DOWN, onBackToComponent);
			TweenMax.to(pageHolder, .6, {x:0, ease:Strong.easeOut});
			catHolder.y = header.y + header.height;
			TweenMax.to(postRowPage, .6, {x:sw, ease:Strong.easeOut, onComplete:ClearPosts});
			
			if (catHolder.height > sh - header.y - header.height){
				CURR_HOLDER = catHolder;
				catHolder.addEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
				IS_DRAGGING = false;
				//dragRect.y = HH-(catHolder.height - (sh - HH));
				CURR_RECT = catRect;
				//dragRect.height = catHolder.height-(sh-HH)
			}
			
			if(KIOSK_MODE){
				header.btn_back.visible = false;
			}
		}
		
		private function ClearPosts():void 
		{
			removeChild(postRowPage);
			var row:Sprite;
			for (var i:uint = 0; i < pRowArray.length; ++i){
				pRow = pRowArray[i];
				row = pRow.ROW;
				rowHolder.removeChild(row);
				pRow = null;
				row = null;
			}
			pRowArray = [];
			rowHolder.removeEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
			header.btn_back.addEventListener(MouseEvent.MOUSE_DOWN, onBack);
		}
		
		//************** KIOSK MODE EVENTS ***************//
		
		private function onGoKioskMode(e:MouseEvent):void 
		{			
			kioskTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			kioskTimer.start();
		}
		
		private function onStopKioskMode(e:MouseEvent):void 
		{
			kioskTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			kioskTimer.reset();
		}
		
		private function onTimerComplete(e:TimerEvent):void 
		{
			this.addChild(timerCover);
			this.addChild(popup);
			popup.width = sw / 2;
			popup.scaleY = popup.scaleX;
			popup.pass_txt.displayAsPassword = true;
			popup.x = sw / 2;
			popup.y = sh + popup.height;
			TweenMax.to(popup, .6, {y:sh/2, ease:Strong.easeOut});
			
			popup.btn_submit.addEventListener(MouseEvent.CLICK, onSubmitPopup);
			popup.btn_cancel.addEventListener(MouseEvent.CLICK, onCancelPopup);
			
			kioskTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			kioskTimer.reset();
		}
		
		private function onSubmitPopup(e:MouseEvent):void 
		{
			TweenMax.killTweensOf(popup.mssg_txt);
			popup.mssg_txt.alpha = 0;
			trace("POPUP: " + popup.pass_txt.text.toLowerCase());
			var s:String = popup.pass_txt.text;
			
			if(!KIOSK_MODE){
				if (s.toLowerCase() == "kiosk"){
					KIOSK_MODE = true;
					popup.mssg_txt.alpha = 1;
					popup.mssg_txt.htmlText = "Kiosk Activated";
					header.btn_back.visible = false;
					header.btn_menu.visible = false;
					
					TweenMax.to(popup.mssg_txt, .6, {alpha:0, ease:Strong.easeOut, delay:3, onComplete:HidePopup});
					
					popup.btn_submit.removeEventListener(MouseEvent.CLICK, onSubmitPopup);
					popup.btn_cancel.removeEventListener(MouseEvent.CLICK, onCancelPopup);
				}else{
					popup.mssg_txt.alpha = 1;
					popup.mssg_txt.htmlText = "Password Incorrect";
					TweenMax.to(popup.mssg_txt, .6, {alpha:0, ease:Strong.easeOut, delay:3});
				}
			}else{
				if (s.toLowerCase() == "kiosk"){
					KIOSK_MODE = false;
					popup.mssg_txt.htmlText = "Kiosk Deactivated";
					header.btn_back.visible = true;
					header.btn_menu.visible = true;
					popup.mssg_txt.alpha = 1;
					TweenMax.to(popup.mssg_txt, .6, {alpha:0, ease:Strong.easeOut, delay:3, onComplete:HidePopup});
					popup.btn_submit.removeEventListener(MouseEvent.CLICK, onSubmitPopup);
					popup.btn_cancel.removeEventListener(MouseEvent.CLICK, onCancelPopup);
				}else{
					popup.mssg_txt.alpha = 1;
					popup.mssg_txt.htmlText = "Password Incorrect";
					TweenMax.to(popup.mssg_txt, .6, {alpha:0, ease:Strong.easeOut, delay:3});
				}
			}
		}
		
		private function HidePopup():void 
		{
			popup.pass_txt.htmlText = "";
			TweenMax.to(popup, .6, {y:sh + popup.height, ease:Strong.easeOut, onComplete:RemovePopup});
		}
		
		private function RemovePopup():void 
		{
			this.removeChild(timerCover);
			this.removeChild(popup);
		}
		
		
		private function onCancelPopup(e:MouseEvent):void 
		{
			TweenMax.killTweensOf(popup.mssg_txt);
			popup.mssg_txt.alpha = 0;
			popup.btn_submit.removeEventListener(MouseEvent.CLICK, onSubmitPopup);
			popup.btn_cancel.removeEventListener(MouseEvent.CLICK, onCancelPopup);
			HidePopup();
		}
		
		public function CheckForPosts():void{
			if(postPage){
				this.removeChild(postPage);
				postPage.ClosePage();
				postPage = null;
			}
		}
		
		public function CheckForPostFreeze():void{
			SHOWING_MENU = false;
			AR = GlobalVarContainer.AGE_RANGE;
			
			if (postRowPage){
				var a:Array = section.POSTS;
				var p:Post;
				for (var i:uint = 0; i < pRowArray.length; ++i){
					pRow = pRowArray[i];
					p = a[i];
					
					if(CheckAgeRange(p)){		
						trace("HAS AGE: " + p.AGE_RANGE);
						TintRow(pRow, 0);
						pRow.icon.gotoAndStop(2);
					}else{		
						trace("NO AGE: " + p.AGE_RANGE);
						TintRow(pRow, .5);
						pRow.icon.gotoAndStop(1);
					}
				}
			}
			
			if(postPage){
				postPage.UnFreezePage();				
			}
		}
		
		//********* DRAGGING FUNCTIONS *************//
		
		private function SetupDragging():void 
		{
			IS_DRAGGING = false;
			CURR_HOLDER.addEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
		}
		
		private function onStartDrag(e:MouseEvent):void 
		{
			 StartY = this.mouseY;
			 stopAnimation();;  
			 
			 CURR_HOLDER.startDrag(false,CURR_RECT);  
			 GlobalVarContainer.MainStage.addEventListener(MouseEvent.MOUSE_UP, goMouseUp);  
			 GlobalVarContainer.MainStage.addEventListener(MouseEvent.MOUSE_OUT, goMouseUp);  
			 this.addEventListener(Event.ENTER_FRAME, onDrag);  
		}
		
		private function onDrag(e:Event):void   
		{  
			if (Math.abs(this.mouseY - StartY) > 3) IS_DRAGGING = true;
			 dvy = CURR_HOLDER.y - prevY;  
			 prevY = CURR_HOLDER.y;  
		}  
		  
		private function goMouseUp(e:MouseEvent):void   
		{  
			trace("MOUSING UP");
			 CURR_HOLDER.stopDrag();  
			 GlobalVarContainer.MainStage.removeEventListener(MouseEvent.MOUSE_UP, goMouseUp);  
			 GlobalVarContainer.MainStage.removeEventListener(MouseEvent.MOUSE_OUT, goMouseUp);  
			 this.removeEventListener(Event.ENTER_FRAME, onDrag);  
			 this.addEventListener(Event.ENTER_FRAME, throwAnimation);  
		}  
		
		private function throwAnimation(e:Event):void 
		{
			 dvy *= friction;  
			 CURR_HOLDER.y += dvy;  
			 
			 var XT:Number = 0;
			 
			 if (CURR_HOLDER == rowHolder){
				 trace("THROWING ROW HOLDER");
				 XT = 10;
			 }
			 
			 if (CURR_HOLDER.y <  sh-10+XT- CURR_HOLDER.height){
				 CURR_HOLDER.y = sh-10+XT- CURR_HOLDER.height;
				 stopAnimation();
			 }else if (CURR_HOLDER.y > header.y+header.height+XT){
				 CURR_HOLDER.y = header.y+header.height+XT;
				 stopAnimation();
			 }
			 
			 
			 if (Math.abs(dvy) < 0.1) stopAnimation();  
		}
		
		private function stopAnimation():void {  
			 IS_DRAGGING = false;
			 dvy =  prevY  = 0;  
			 this.removeEventListener(Event.ENTER_FRAME, throwAnimation);  
		} 
		
	
	
	}

}