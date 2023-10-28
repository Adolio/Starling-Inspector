// =================================================================================================
//
//	Starling Inspector
//	Copyright (c) 2023 Aurelien Da Campo (Adolio), All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package ch.adolio.utils
{
	import avmplus.getQualifiedClassName;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;

	/**
	 * Inspection utility class
	 */
	public class InspectionUtils
	{
		/** Returns a name for a given object. */
		public static function findObjectName(object:Object):String
		{
			var className:String = getQualifiedClassName(object);

			var classSplitIndex:int = className.indexOf("::");
			if (classSplitIndex != -1)
				className = className.substr(classSplitIndex+2, className.length - classSplitIndex+2);

			if (object is DisplayObject)
			{
				var displayObject:DisplayObject = object as DisplayObject;
				if (!isNullOrEmpty(displayObject.name))
					return displayObject.name + " [" + className + "]";
			}

			return "[" + className + "]";
		}

		/** Checks if a string is `null` or empty. */
		[Inline]
		public static function isNullOrEmpty(str:String):Boolean
		{
			return str == null || str.length == 0;
		}

		/** Clamp value between min (inclusive) & max (inclusive). */
		[Inline]
		public static function clamp(value:Number, min:Number, max:Number):Number
		{
			return value > max ? max : value < min ? min : value;
		}

		/** Checks if a given display object is a child object of another. */
		public static function isChildOf(parent:DisplayObject, child:DisplayObject):Boolean
		{
			// is the parent a container?
			if (parent is DisplayObjectContainer)
			{
				var container:DisplayObjectContainer = parent as DisplayObjectContainer;
				for (var i:int = 0; i < container.numChildren; ++i)
				{
					var containerChild:DisplayObject = container.getChildAt(i);

					// check if the current child is found
					if (containerChild == child)
						return true;

					// recusively look for the child, if found stop the search
					if (isChildOf(containerChild, child))
						return true;
				}
			}

			return false;
		}
	}
}