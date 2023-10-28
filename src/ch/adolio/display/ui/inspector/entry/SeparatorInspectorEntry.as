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
	import ch.adolio.display.ui.inspector.InspectorConfiguration;
	import feathers.controls.Label;
	import starling.events.Event;

	public class SeparatorInspectorEntry extends InspectorEntry
	{
		private var _label:Label;

		public function SeparatorInspectorEntry(title:String)
		{
			// title
			_label = new Label();
			_label.touchable = false;
			_label.styleName = InspectorConfiguration.STYLE_NAME_LABEL_SEPARATOR_TITLE;
			_label.text = title;
			_label.height = _preferredHeight;
			_label.validate();
			addChild(_label);

			width = _preferredWidth;
		}

		//---------------------------------------------------------------------
		//-- Event handlers
		//---------------------------------------------------------------------

		override protected function onAddedToStage(e:Event):void
		{
			super.onAddedToStage(e);

			// invalidate components
			_label.invalidate();
		}

		//---------------------------------------------------------------------
		//-- Size management
		//---------------------------------------------------------------------

		override public function get width():Number
		{
			return _preferredWidth;
		}

		override public function set width(value:Number):void
		{
			_preferredWidth = value;

			_label.width = _preferredWidth;
		}
	}
}