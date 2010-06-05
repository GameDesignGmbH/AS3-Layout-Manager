package layout
{
	public function place(alignment:int=-1, arr:Array=null, prop:Object = null):LayoutManager
	{
		if(alignment!=-1 && arr!=null) layoutManagerInstance.place(alignment, arr, prop);
		return layoutManagerInstance;
	}
}

import layout.LayoutManager;
internal var layoutManagerInstance:LayoutManager = new LayoutManager( );