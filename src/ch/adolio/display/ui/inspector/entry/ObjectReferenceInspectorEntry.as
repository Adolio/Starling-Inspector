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
	import ch.adolio.utils.InspectionUtils;
	import feathers.controls.Button;
	import feathers.controls.Label;
	import starling.events.Event;

	/** Object reference entry. */
	public class ObjectReferenceInspectorEntry extends InspectorEntry
	{
		private var _label:Label;
		private var _inspectButton:Button;
		private var _getterFunc:Function;
		private var _inspectRequestFunc:Function;

		public function ObjectReferenceInspectorEntry(title:String, getterFunc:Function, inspectRequestFunc:Function = null)
		{
			_getterFunc = getterFunc;
			_inspectRequestFunc = inspectRequestFunc;

			// label
			_label = new Label();
			_label.touchable = false;
			_label.styleName = InspectorConfiguration.STYLE_NAME_LABEL_ENTRY_TITLE;
			_label.text = title;
			_label.height = _preferredHeight;
			addChild(_label);

			// button
			_inspectButton = new Button();
			_inspectButton.styleName = InspectorConfiguration.STYLE_NAME_BUTTON;
			_inspectButton.height = _preferredHeight;
			addChild(_inspectButton);

			// setup value
			var value:Object = getterFunc();
			_inspectButton.isEnabled = value != null && _inspectRequestFunc;
			_inspectButton.label = "Inspect " + InspectionUtils.findObjectName(value);

			// setup height from button height
			_preferredHeight = _inspectButton.height;
		}

		override protected function onAddedToStage(e:Event):void
		{
			super.onAddedToStage(e);

			_inspectButton.addEventListener(Event.TRIGGERED, onButtonTriggered);
		}

		override protected function onRemovedFromStage(e:Event):void
		{
			super.onRemovedFromStage(e);

			_inspectButton.removeEventListener(Event.TRIGGERED, onButtonTriggered);
		}

		private function onButtonTriggered(e:Event):void
		{
			if (_inspectRequestFunc)
				_inspectRequestFunc();
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

			_label.x = _paddingLeft;
			_label.width = getLabelWidth();
			_inspectButton.x = _label.x + _label.width + InspectorConfiguration.COMPONENTS_PADDING;
			_inspectButton.width = getAvailableWidthForInputComponents();
		}
	}
}