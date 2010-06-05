package layout
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	/**
	 * 
	 * 	LayoutManager is a simple way to align and distribute displayObjects.
	 * 	Use the place method with an <code>Align</code> and <code>arr</code> parameters.
	 *	
	 *	The <code>arr</code> parameter define the list of objects to arrange. The first object in the Array will be used as reference to align all other objects.
	 * 	
	 * 	@example Basic usage (Using the place global function, wich acts as an static instance of LayoutManager):<listing version="3.0">
		 var sp1 :Sprite = new Sprite()
		 var sp2 :Sprite = new Sprite()
		 addChild(sp1)
		 addChild(sp2)
	 
		 place(Align.DISTRIBUTE_RIGHT,[sp1, sp2]) // will put sp2 by the right side of sp1 using the sp1.x + sp1.width as reference..
	 * 	</listing>
	 * 	
	 * 	@example Using more than one Alignment property at once:<listing version="3.0">
		 place(Align.BOTTOM + Align.DISTRIBUTE_RIGHT,[sp1, sp2]) // will put sp2 aligned by base and to the right side of sp1.
	 * 	</listing>
	 * 	
	 * 	@example Grouping objects<listing version="3.0">
		 place(Align.DISTRIBUTE_RIGHT,[sp1, [sp2, sp3]]) // Will place sp2 and sp3 together to the right of sp1, but won't change sp3 position to the right side of sp2.
	 * 	</listing>
	 * 	
	 * 	@example You can use also a Stage instance as a reference:<listing version="3.0">
		 place(Align.CENTER,[stage, sp]) // will put the sp in the center of the stage. Be careful with object with read only properties.
	 * 	</listing>
	 * 	
	 *	@see Align
	 * 	@author Igor Almeida
	 * 	@author Cássio Souza
	 * 	@author Pedro Moraes
	 * 	
	 */
	
	public class LayoutManager
	{	
		public var padding_x:Number
		public var padding_y:Number
		public var sizeX:Number
		public var sizeY:Number
		public var ignoreSize:Boolean;
		public var step:Number;
		public var rounded:Boolean;
		
		/** @private */
		public var alignOptions:Array
		/**  
        *   @private
		*	Count iterator
        */
		public var c:int;
		/** @private */
		public var sizing:Number;
		/** @private */
		public var reffSize:Number;
		/** @private */
		public var reffPos:Number;
		/** @private */
		public var reff:Number
		/** @private */
		public var objSize:Number;
		/** @private */
		public var objPos:Number;
		/** @private */
		public var bounds:Rectangle;
		/** @private */
		public var tempRect:Rectangle;
		/** @private */
		public var baseDisplay:Object;
		
		public function LayoutManager():void
		{
		}
		
		/**
		 * 
		 *	Distributes and Aligns the elements of an Array
		 * 
		 *	@param	alignment	int		How to align or distribute the elements
		 *	@param	arr			Array	Array of display objects to align or distribute
		 *	@param	prop		Object	Optional arguments for layouting elements
		 * 
		 **/
		public function place(alignment:int, arr:Array, prop:Object = null):void
		{
			padding_x = (prop && prop.hasOwnProperty("padding_x")) ? prop["padding_x"]:0;
			padding_y = (prop && prop.hasOwnProperty("padding_y")) ? prop["padding_y"]:0;
			sizeX = (prop && prop.hasOwnProperty("width")) ? prop["width"]:NaN;
			sizeY = (prop && prop.hasOwnProperty("height")) ? prop["height"]:NaN;
			ignoreSize = (prop && prop.hasOwnProperty("ignoreSize")) ? prop["ignoreSize"]:false;
			step = (prop && prop.hasOwnProperty("step")) ? prop["step"]:1;
			rounded = (prop && prop.hasOwnProperty("rounded")) ? prop["rounded"]:false;
			
			if (arr[0]==null)
			{
				return;
			}
			var items:Array = clone(arr);
			
			alignOptions = match(alignment,Align.RIGHT, Align.LEFT, Align.TOP, Align.BOTTOM,Align.CENTER, Align.CENTER_HORIZONTAL, Align.CENTER_VERTICAL, Align.DISTRIBUTE_RIGHT, Align.DISTRIBUTE_LEFT, Align.DISTRIBUTE_UP, Align.DISTRIBUTE_DOWN)
			for (var i:String in alignOptions)
			{
				switch (alignOptions[i])
				{
					case Align.RIGHT:
						placeBy(items, "x", "width", -1,padding_x, sizeX, step, rounded);
						break;
					case Align.LEFT:
						placeBy(items, "x", "width", 1, padding_x, 0, step, rounded);
						break;
					case Align.TOP:
						placeBy(items, "y", "height", 1, padding_y, 0, step, rounded);
						break;
					case Align.BOTTOM:
						placeBy(items, "y", "height", -1,padding_y, sizeY, step, rounded);
						break; 
					case Align.CENTER:
						placeCenter(items, "x","width", padding_x, sizeX, step, rounded);
						placeCenter(items, "y","height", padding_y, sizeY, step, rounded);
						break;
					case Align.CENTER_HORIZONTAL:
						placeCenter(items, "x","width", padding_x, sizeX, step, rounded);
						break;
					case Align.CENTER_VERTICAL:
						placeCenter(items, "y","height", padding_y, sizeY, step, rounded);
						break;
					case Align.DISTRIBUTE_RIGHT:
						placeTo(items, "x", "width", 1, padding_x, sizeX, step, rounded);
						break;
					case Align.DISTRIBUTE_LEFT:
						placeTo(items, "x","width", -1, padding_x, sizeX, step, rounded);
						break;
					case Align.DISTRIBUTE_UP:
						placeTo(items, "y", "height", -1,padding_y, sizeY, step, rounded);
						break;
					case Align.DISTRIBUTE_DOWN:
						placeTo(items, "y", "height", 1, padding_y, sizeY, step, rounded);
						break;
				}
			}

			if(match(alignment,Align.GRID)[0] == Align.GRID)
			{
				if(prop && prop.hasOwnProperty("rows"))
				{
					horizontalGrid(arr, prop["rows"], prop)
				}
				else if(prop && prop.hasOwnProperty("cols"))
				{
					verticalGrid(arr, prop["cols"], prop)
				}
				else
				{
					throw new Error("To create a GRID you should provide rows or cols property");
				}
			}
			
			items = null;
		}
		
		
		/**
		 * 
		 *	Put the itens to the given side of the next element.
		 * 
		 **/
		private function placeTo(items:Array, prop:String, size:String, operator:int = 1, padding:Number = 0, forceSize:Number = NaN, step:Number = 1, rounded:Boolean=false):void
		{
			c = 0;
			while (c < items.length)
			{
				if (c > 0 && items[c] != null && items[c-1] != null)
				{
					reffSize = ignoreSize? 0 : items[c - 1][size];
					reffPos = items[c - 1][prop];
					objSize = ignoreSize? 0 : items[c][size];
					objPos = items[c][prop];
					sizing = (isNaN(forceSize)) ? (operator < 0) ? objSize:reffSize:forceSize;
					if(items[c] is ReferenceRectangle)
					{
						items[c][prop] = items[c][prop] + (((reffPos - objPos) * operator + sizing + padding) * step) * operator;
						for(var i:Object in items[c].originalObjects)
						{
							items[c].originalObjects[i][prop] = items[c].originalObjects[i][prop] + (((reffPos - objPos) * operator + sizing + padding) * step) * operator;
						}
					}
					else{
						items[c][prop] = items[c][prop] + (((reffPos - objPos) * operator + sizing + padding) * step) * operator;	
					}
					if(rounded) {
					    items[c]["x"] = Math.round(items[c]["x"]);
                        items[c]["y"] = Math.round(items[c]["y"]);
					}
				}
				sizing = forceSize;
				c++;
			}
		}
		
		/**
		 * 
		 *	Align all itens by the given position of the first item
		 * 
		 **/
		private function placeBy(items:Array, prop:String, size:String, operator:int = 1, padding:Number = 0, forceSize:Number = NaN, step:Number = 1, rounded:Boolean=false):void
		{
			c = 0;
			reffSize = ignoreSize? 0 : items[0][size];
			reffPos = items[0][prop];
			while (c<items.length)
			{
				if(c>0 && items[c] != null && items[0]!=null)
				{
					objSize = ignoreSize? 0 : items[c][size];
					objPos = items[c][prop];
					sizing = (isNaN(forceSize)) ? reffSize:forceSize;
					if(items[c] is ReferenceRectangle)
					{
						items[c][prop] = items[c][prop] + ((((reffPos - objPos + (operator==1 ? 0:sizing - objSize))) * operator) * operator) * step + (padding * operator)
						for(var i:Object in items[c].originalObjects)
						{
							items[c].originalObjects[i][prop] = items[c].originalObjects[i][prop] + ((((reffPos - objPos + (operator==1 ? 0:sizing - objSize))) * operator) * operator) * step + (padding * operator)
						}
					}
					else{
						items[c][prop] = items[c][prop] + ((((reffPos - objPos + (operator==1 ? 0:sizing - objSize))) * operator) * operator) * step + (padding * operator)
					}
					if(rounded) {
					    items[c]["x"] = Math.round(items[c]["x"]);
                        items[c]["y"] = Math.round(items[c]["y"]);
					}
				}
				sizing = forceSize;
				c++;
			}
		}
		
		/**
		 * 
		 *	Center all the elements in X or Y
		 * 
		 **/
		private function placeCenter(items:Array, prop:String, size:String, padding:Number = 0, forceSize:Number = NaN, step:Number = 1, rounded:Boolean=false):void
		{
			c = 0;
			sizing = forceSize;
			var boundsA:Rectangle;
			var boundsB:Rectangle;
			reffSize = ignoreSize? 0 : items[0][size];
			reffPos = items[0][prop];
			reff = (isNaN(forceSize) ? reffSize:forceSize) * .5;	
			while (c<items.length)
			{
				if(c>0 && items[c] != null)
				{
					objSize = ignoreSize? 0 : items[c][size];
					objPos = items[c][prop];
					sizing = isNaN(forceSize) ? objSize:forceSize;
					if(items[c] is ReferenceRectangle)
					{
						items[c][prop] = items[c][prop] - ((objPos - reffPos) + (sizing * .5 - reff)) * step;
						for(var i:Object in items[c].originalObjects)
						{
							items[c].originalObjects[i][prop] = items[c].originalObjects[i][prop] - ((objPos - reffPos) + (sizing * .5 - reff)) * step;
						}
					}
					else{
						items[c][prop] = items[c][prop] - ((objPos - reffPos) + (sizing * .5 - reff)) * step;
					}
					if(rounded) {
					    items[c]["x"] = Math.round(items[c]["x"]);
                        items[c]["y"] = Math.round(items[c]["y"]);
					}
				}
				c++;
			}
		}
		
		/**
		 * 
		 *	Create a grid based on the n ratio
		 * 
		 **/
		private function getGrid(items:Array, n:int):Array
		{
			var grid:Array = new Array();
			var mod:int = items.length/n;
			mod += int(items.length%n)>0 ? 1:0 ;
			c = 0;
			while (c<mod)
			{
				var start:int = c*n;
				var end:int = start + n;
				grid.push(items.slice(start, end));
				c++;
			}
			return grid;
		}
		
		/**
		 * 
		 *	Create a vertical grid and arrange items.
		 * 
		 **/
		private function verticalGrid(arr:Array, columns:int, prop:Object = null):Array
		{
			if(columns<=1)
			{
				place(Align.LEFT, arr);
				place(Align.DISTRIBUTE_DOWN, arr, prop);
				return arr;
			}
			var grid:Array = getGrid(arr, columns);
			var count:int = 0;
			var max:int = grid.length

			while (count<max)
			{
				if(count>0)
				{
					place(Align.RIGHT, [grid[count-1][0], grid[count][0]]);
					place(Align.DISTRIBUTE_DOWN, [grid[count-1][0], grid[count][0]], prop);
				}
				place(Align.TOP, grid[count]);
				place(Align.DISTRIBUTE_RIGHT, grid[count] , prop);
				if(grid[count].length==1)
				{
					place(Align.RIGHT, [grid[0][0], grid[count][0]]);
				}
				count++;
			}
			return grid;
		}
		/**
		 * 
		 *	Create a vertical grid and arrange items.
		 * 
		 **/
		private function horizontalGrid(arr:Array, rows:int, prop:Object = null):Array
		{
			if(rows<=1)
			{
				place(Align.TOP, arr);
				place(Align.DISTRIBUTE_LEFT, arr, prop);
				return arr;
			}
			var grid:Array = getGrid(arr, rows);
			var count:int = 0;
			while (count<grid.length)
			{
				if(count>0)
				{
					place(Align.TOP, [grid[count-1][0], grid[count][0]]);
					place(Align.DISTRIBUTE_RIGHT, [grid[count-1][0], grid[count][0]], prop);
				}
				place(Align.RIGHT, grid[count]);
				place(Align.DISTRIBUTE_DOWN, grid[count] , prop);
				if(grid[count].length==1)
				{
					place(Align.TOP, [grid[0][0], grid[count][0]]);
				}
				count++;
			}
			return grid;
		}
		/**
		 * 
		 *	Return the rectangle of all items
		 * 
		 *	To work fine, put in array objects at the same scope.
		 * 
		 *	@param arr	Array
		 *	@return Rectangle
		 * 
		 */
		public function getRect(arr:Array):Rectangle
		{
			var a:Array = clone(arr);
			bounds = new Rectangle(a[0].x, a[0].y, a[0].width, a[0].height);
			a.shift();
			var count:int = a.length;
			while(count--)
			{
				if (a[count] == null){
					continue;
				}
				if (a[count].hasOwnProperty("stage")){
					tempRect = a[count].getBounds(a[count].stage);
				}else{
					tempRect = new Rectangle(a[count].x, a[count].y, a[count].width, a[count].height);
				}
				bounds = bounds.union(tempRect);
			}
			return bounds;
		}
		
		/**
		 * 
		 *	shallow clone
		 * 
		 *	@param	a	Array
		 *	@return Array
		 * 
		 **/
		private function clone(a:Array):Array
		{
			var c:int = a.length;
			var array:Array = new Array();
			while(c--)
			{
				if (a[c]==null){
					continue;
				}
				if(a[c] is Array){
					var orig:Array = a[c] as Array;
					a[c] = new ReferenceRectangle(getRect(a[c]));
					for(var k:Object in orig){
						orig[k] = new DisplayWrapper(orig[k]);
					}
					a[c].originalObjects = orig;
					array.push(a[c]);
					orig = null;
				}
				else if ((a[c] is Point) || (a[c].hasOwnProperty("x") && 
											 a[c].hasOwnProperty("y") && 
											 a[c].hasOwnProperty("width") &&
											 a[c].hasOwnProperty("height"))) 
				{
					array.push(new DisplayWrapper(a[c]));
				}
			}
			return array.reverse();
		}
		
		/**
		 * 
		 *	Mathes against a sequence of given integers
		 * 
		 *	@param	value	The value
		 *	@param options	The integer values to match the value against
		 * 
		 **/
		private function match(value:int, ... options:Array):Array
		{
			var option:int;
			var returnArr:Array = [];
			
			while (option = options.shift())
			{
				if ((value & option) == option)
				{
					returnArr.push(option);
				}
			}
			return returnArr;
		}
		
	}
}

import flash.geom.Rectangle;
internal class ReferenceRectangle extends Rectangle
{
	public var originalObjects:Array
	public function ReferenceRectangle(rect:Rectangle)
	{
		super(rect.x, rect.y, rect.width, rect.height);
	}
}