package modules 
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*
	import flash.events.MouseEvent;
	import utilities.PhpUtility;
	import utilities.PhpUtilityEvent;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class CommentPopup extends Comment_Popup
	{
		private var Post_ID:Number;
		
		public function CommentPopup(n:Number) 
		{
			Post_ID = n;
			name_txt.htmlText = "";
			body_txt.htmlText = "";
			mssg_txt.autoSize = "left";
			
			btn_cancel.buttonMode = btn_submit.buttonMode = true;
			
			btn_cancel.addEventListener(MouseEvent.CLICK, onCancelComment);
			btn_submit.addEventListener(MouseEvent.CLICK, onSubmitComment);
		}
		
		private function onCancelComment(e:MouseEvent):void 
		{
			btn_cancel.removeEventListener(MouseEvent.CLICK, onCancelComment);
			btn_submit.removeEventListener(MouseEvent.CLICK, onSubmitComment);
			this.dispatchEvent(new MoreEvent(MoreEvent.CLOSE_POPUP));
		}
		
		private function onSubmitComment(e:MouseEvent):void 
		{
			mssg_txt.alpha = 1;
			
			if (body_txt.text.length < 1){
				mssg_txt.htmlText = "You need to enter a comment.";
				
				TweenMax.to(mssg_txt, 1, {alpha:0, ease:Strong.easeOut, delay:4});
			}else{				
				btn_cancel.removeEventListener(MouseEvent.CLICK, onCancelComment);
				btn_submit.removeEventListener(MouseEvent.CLICK, onSubmitComment);
				
				btn_cancel.alpha = btn_submit.alpha = .4;
				
				var obj:Object = new Object();
				obj.name = name_txt.text;
				obj.comment_body = body_txt.text;
				obj.email = "";
				
				mssg_txt.htmlText = "Submitting comment.";
				
				PhpUtility.addEventListener(PhpUtilityEvent.PXML_LOADED, onCommentSubmitted);
				PhpUtility.PostComment(Post_ID, obj);
			}
		}
		
		private function onCommentSubmitted(e:PhpUtilityEvent):void 
		{
			PhpUtility.removeEventListener(PhpUtilityEvent.PXML_LOADED, onCommentSubmitted);
			trace("Comment Response: " + PhpUtility.myXML);
			
			btn_cancel.visible = btn_submit.visible = false;
			mssg_txt.htmlText = "Thank you.\nYour comment has been submitted and will be visible upon approval.";
			mssg_txt.alpha = 1;
			TweenMax.to(mssg_txt, 1, {alpha:0, ease:Strong.easeOut, delay:4, onComplete:ClosePopup});
		}
		
		private function ClosePopup():void 
		{
			this.dispatchEvent(new MoreEvent(MoreEvent.CLOSE_POPUP));
		}
		
	}

}