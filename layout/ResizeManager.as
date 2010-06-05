package layout
{	
	import flash.events.Event;
	import flash.display.Stage;
	
	public class ResizeManager extends LayoutManager
	{
		public var stageReference:Stage;
		public var eventData:Array;
		
		/**
		 *	A class that extends LayoutManager and listens to stage Resize
		 * 	@example This sample aligns mySprite to the right side of the stage:<listing version="3.0">
			 rm = new ResizeManager(stage)
			 rm.place(Layout.ALIGN_RIGHT,[stage, mySprite])
		 * 	</listing>
		*/
		public function ResizeManager(stageReference:Stage)
		{
			this.stageReference = stageReference;
			stageReference.addEventListener(Event.RESIZE, resizeHandler, false, 0, true)
			super()
		}

		override public function place(alignment:int, arr:Array, prop:Object = null):void
		{
			if(eventData==null){
				eventData = new Array()
			}
			eventData.push({"alignment":alignment,"arr":arr,"prop":prop});
			super.place(alignment, arr, prop);
		}
		
		public function resizeHandler(e:Event=null):void
		{
			for(var i:Object in eventData){
				super.place(eventData[i]["alignment"], eventData[i]["arr"], eventData[i]["prop"])
			}
		}

	}
}