/**
 * 
 * DisplayWrapper 
 * 
 * @author igor almeida
 * @version 0.2
 * @since 14.01.2009
 * 
 * */
package layout
{
	import flash.geom.*;
	import flash.text.*;
	import flash.display.*;
	import flash.utils.getTimer
	public class DisplayWrapper
	{
		private var _item : *;
		private var bounds : Rectangle;
		private var hasStage : Boolean;
		public var isStage: Boolean
		private var timeoffset : Number;
		private var time : uint;
		private const minTime : Number = 60;
		private var flag : Boolean = true;
		private var hasScrollRect : Boolean
		public function DisplayWrapper( p_item :* )
		{
			_item = p_item;
			bounds = new Rectangle( );
			isStage = _item is Stage;
		}
		
		private function getBounds():Rectangle{
			if (_item==null){
				return bounds;
			}
			if ( isStage ){
				bounds.width = _item.stageWidth;
				bounds.height = _item.stageHeight;
				bounds.x = 0;
				bounds.y = 0;
				return bounds;
			}
			if ( _item is Point ){
				bounds.width = 0;
				bounds.height = 0;
				bounds.x = _item.x;
				bounds.y = _item.y;
				return bounds;
			}
			hasStage = (_item.hasOwnProperty("stage") && (_item.stage!=null));
			hasScrollRect = ( _item.hasOwnProperty("scrollRect") && _item.scrollRect!=null && _item.scrollRect is Rectangle );
			if ( hasStage ){
				// thanks adobe to return a freak number when calling getBounds for a empty sprite! :(
				if (_item.width+_item.height==0){
					if(_item.hasOwnProperty("transform") && _item.transform && _item is DisplayObjectContainer){
						// getting relative position/size using the pixel bounds.
						bounds = _item.transform.pixelBounds;
					}
					else{
						// just a empty box
						bounds = new Rectangle(0,0,0,0);
					}
				}
				else{
					bounds = _item.getBounds(_item.stage);
				}
			}
			else{
				bounds.width = _item.width;
				bounds.height = _item.height;
				bounds.x = _item.x;
				bounds.y = _item.y;
			}
			bounds.width = hasScrollRect ? _item.scrollRect.width : bounds.width;
			bounds.height = hasScrollRect ? _item.scrollRect.height : bounds.height;
			return bounds;
		}
		
		public function get width () :Number
		{
			return getBounds().width;
		}
		
		public function get height () :Number
		{
			return getBounds().height;
		}
		
		public function set height(value:Number):void{}
		public function set width(value:Number):void{}

		public function set x ( value : * ) :void{
			if (isStage)return;
			_item.x = (hasStage ? _item.x-bounds.x : 0) + value;
		}

		public function get x ( ) :*{
			return getBounds().x;
		}
		
		public function set y ( value : * ) :void{
			if (isStage)return;
			_item.y = (hasStage ? _item.y-bounds.y : 0) + value;
		}
		
		public function get y ( ) :*{
			return getBounds().y;
		}
		
		public function toString():*{
			return "DisplayWrapper:"+_item;
		}

	}
}