// =================================================================================================
//
//	Starling Inspector
//	Copyright (c) 2023 Aurelien Da Campo (Adolio), All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package ch.adolio.display.ui.inspector.entry
{
	import starling.display.BlendMode;

	public class BlendModeInspectorEntry extends PickerListInspectorEntry
	{
		private static const BLEND_MODE_ITEMS:Array = [
			{ label:"Add", value:BlendMode.ADD },
			{ label:"Auto", value:BlendMode.AUTO },
			{ label:"Below", value:BlendMode.BELOW },
			{ label:"Erase", value:BlendMode.ERASE },
			{ label:"Mask", value:BlendMode.MASK },
			{ label:"Multiply", value:BlendMode.MULTIPLY },
			{ label:"None", value:BlendMode.NONE },
			{ label:"Normal", value:BlendMode.NORMAL },
			{ label:"Screen", value:BlendMode.SCREEN }
		];

		public function BlendModeInspectorEntry(title:String, getterFunc:Function, setterFunc:Function = null)
		{
			super(title, BLEND_MODE_ITEMS,
				function():String
				{
					return getterFunc();
				},
				function(object:Object):void
				{
					if (setterFunc)
					{
						setterFunc(object.value);
					}
				}
			);
		}
	}
}