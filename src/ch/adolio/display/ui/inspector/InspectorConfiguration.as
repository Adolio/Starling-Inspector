// =================================================================================================
//
//	Starling Inspector
//	Copyright (c) 2023 Aurelien Da Campo (Adolio), All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package ch.adolio.display.ui.inspector
{
	import starling.display.DisplayObjectContainer;

	public class InspectorConfiguration
	{
		// version of the library
		public static const VERSION:String = "0.1";

		// root layer
		public static var ROOT_LAYER:DisplayObjectContainer;

		// style names
		public static var STYLE_NAME_LABEL_PANEL_TITLE:String = "";
		public static var STYLE_NAME_LABEL_SEPARATOR_TITLE:String = "";
		public static var STYLE_NAME_LABEL_ENTRY_TITLE:String = "";
		public static var STYLE_NAME_LABEL_ENTRY_VALUE:String = "";
		public static var STYLE_NAME_TEXT_INPUT:String = "";
		public static var STYLE_NAME_TEXT_AREA:String = "";
		public static var STYLE_NAME_SLIDER:String = "";
		public static var STYLE_NAME_BUTTON:String = "";
		public static var STYLE_NAME_PICKER_LIST:String = "";
		public static var STYLE_NAME_CHECK:String = "";
		public static var STYLE_NAME_TOGGLE_SWITCH:String = "";
		public static var STYLE_NAME_TAB_TOGGLE_BUTTON:String = "";
		public static var STYLE_NAME_PANEL_REFRESH_BUTTON:String = "";
		public static var STYLE_NAME_PANEL_BACK_BUTTON:String = "";
		public static var STYLE_NAME_PANEL_CLOSE_BUTTON:String = "";

		// colors
		public static var COLOR_PANEL_HEADER_BACKGROUND_COLOR:uint = 0x222222;
		public static var COLOR_PANEL_HEADER_BACKGROUND_ALPHA:Number = 0.9;
		public static var COLOR_PANEL_FOOTER_BACKGROUND_COLOR:uint = 0x444444;
		public static var COLOR_PANEL_FOOTER_BACKGROUND_ALPHA:Number = 0.9;
		public static var COLOR_PANEL_BODY_BACKGROUND_COLOR:uint = 0xffffff;
		public static var COLOR_PANEL_BODY_BACKGROUND_ALPHA:Number = 0.9;
		public static var COLOR_BACKGROUND_HIGHLIGHT:uint = 0xBAD1DF;

		// inspection overlay
		public static var INSPECTED_OBJECT_BOUNDS_BODY_COLOR:Number = 0x0000ff;
		public static var INSPECTED_OBJECT_BOUNDS_BODY_ALPHA:Number = 0.1;
		public static var INSPECTED_OBJECT_BOUNDS_BORDER_COLOR:uint = 0x0000ff;
		public static var INSPECTED_OBJECT_BOUNDS_BORDER_ALPHA:Number = 0.5;
		public static var INSPECTED_OBJECT_BOUNDS_BORDER_SIZE:Number = 0.6;

		// inspection panel
		public static var PANEL_HEADER_MIN_HEIGHT:Number = 20; // pixels
		public static var PANEL_FOOTER_HEIGHT:Number = 20; // pixels
		public static var PANEL_FOOTER_SIZE_GRABBER_COLOR:uint = 0x666666;
		public static var PANEL_DEFAULT_WIDTH:Number = 300; // pixels
		public static var PANEL_DEFAULT_HEIGHT:Number = NaN; // pixels, use `NaN` for auto-size

		// inspection entries
		public static var ENTRY_TITLE_WIDTH_RATIO:Number = 0.35; // width ratio of the entire entry, the rest is for the value part
		public static var ENTRY_TITLE_MAX_WIDTH:Number = 200; // pixels
		public static var ENTRY_PREFERRED_HEIGHT:Number = 18; // pixels
		public static var COMPONENTS_PADDING:Number = 8; // pixels
		public static var SLIDER_ENTRY_SLIDER_INPUT_WIDTH_RATIO:Number = 0.6; // width ratio of the available value part
		public static var SLIDER_ENTRY_TEXT_INPUT_MIN_WIDTH:Number = 64; // pixels, use `NaN` for no constraints
		public static var SLIDER_ENTRY_TEXT_INPUT_MAX_WIDTH:Number = 96; // pixels, use `NaN` for no constraints

		// assets
		public static var TEXTURE_IMPORT_SCALE_MIN:Number = 1;
		public static var TEXTURE_IMPORT_SCALE_MAX:Number = 4;
		public static var TEXTURE_IMPORT_SCALE_STEP:Number = 1;
		public static var TEXTURE_IMPORT_SCALE_DEFAULT:Number = 1;
	}
}