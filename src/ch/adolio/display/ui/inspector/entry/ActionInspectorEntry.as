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
	import feathers.controls.Button;
	import starling.events.Event;

	/** Simple button entry. */
	public class ActionInspectorEntry extends InspectorEntry
	{
		private var _button:Button;
		private var _triggerFunc:Function;

		public function ActionInspectorEntry(actionLabel:String, triggerFunc:Function)
		{
			_triggerFunc = triggerFunc;

			// button
			_button = new Button();
			_button.styleName = InspectorConfiguration.STYLE_NAME_BUTTON;
			_button.label = actionLabel;
			_button.height = _preferredHeight;
			addChild(_button);
			_button.validate();

			// setup height from button height
			_preferredHeight = _button.height;
		}

		override protected function onAddedToStage(e:Event):void
		{
			super.onAddedToStage(e);

			_button.addEventListener(Event.TRIGGERED, onButtonTriggered);
		}

		override protected function onRemovedFromStage(e:Event):void
		{
			super.onRemovedFromStage(e);

			_button.removeEventListener(Event.TRIGGERED, onButtonTriggered);
		}

		private function onButtonTriggered(e:Event):void
		{
			_triggerFunc();
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

			_button.x = _paddingLeft;
			_button.width = getWidthWithoutPaddings();
		}
	}
}