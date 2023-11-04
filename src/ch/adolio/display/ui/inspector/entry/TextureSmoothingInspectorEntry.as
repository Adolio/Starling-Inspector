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
	import starling.textures.TextureSmoothing;

	public class TextureSmoothingInspectorEntry extends PickerListInspectorEntry
	{
		private static const TEXTURE_SMOOTHING_ITEMS:Array = [
			{ label:"None", value:TextureSmoothing.NONE },
			{ label:"Bilinear", value:TextureSmoothing.BILINEAR },
			{ label:"Trilinear", value:TextureSmoothing.TRILINEAR }
		];

		public function TextureSmoothingInspectorEntry(title:String, getterFunc:Function, setterFunc:Function = null)
		{
			super(title, TEXTURE_SMOOTHING_ITEMS,
				function():String
				{
					return getterFunc();
				},
				function(object:Object):void
				{
					if (setterFunc)
						setterFunc(object.value);
				}
			);
		}
	}
}