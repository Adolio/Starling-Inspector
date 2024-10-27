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
	import feathers.controls.TextInput;
	import starling.events.Event;

	public class TextInputInspectorEntry extends InspectorEntry
	{
		private var _label:Label;
		private var _input:TextInput;
		private var _getterFunc:Function;
		private var _setterFunc:Function;

		private var _disableCallback:Boolean = false;

		public function TextInputInspectorEntry(title:String, getterFunc:Function, setterFunc:Function = null)
		{
			_title = title;
			_getterFunc = getterFunc;
			_setterFunc = setterFunc;

			_label = new Label();
			_label.styleName = InspectorConfiguration.STYLE_NAME_LABEL_ENTRY_TITLE;
			_label.text = title;
			_label.toolTip = title;
			_label.height = _preferredHeight;
			addChild(_label);

			_input = new TextInput();
			_input.styleName = InspectorConfiguration.STYLE_NAME_TEXT_INPUT;
			_input.height = _preferredHeight;
			_input.text = getterFunc();
			_input.isEditable = _setterFunc;
			addChild(_input);
			_input.validate();

			width = _preferredWidth;
		}

		public function getText():String
		{
			return _input.text;
		}

		public function setText(text:String):void
		{
			_disableCallback = true;
			_input.text = text;
			_disableCallback = false;
		}

		override public function refresh():void
		{
			setText(_getterFunc());
		}

		public function get isEnabled():Boolean
		{
			return _input.isEnabled;
		}

		public function set isEnabled(value:Boolean):void
		{
			_input.isEnabled = value && _setterFunc;
		}

		//---------------------------------------------------------------------
		//-- Accessors
		//---------------------------------------------------------------------

		public function get titleLabel():Label
		{
			return _label;
		}

		public function get textInput():TextInput
		{
			return _input;
		}

		//---------------------------------------------------------------------
		//-- Event handlers
		//---------------------------------------------------------------------

		override protected function onAddedToStage(e:Event):void
		{
			super.onAddedToStage(e);

			_input.addEventListener(Event.CHANGE, onTextValueChanged);
		}

		override protected function onRemovedFromStage(e:Event):void
		{
			super.onRemovedFromStage(e);

			_input.removeEventListener(Event.CHANGE, onTextValueChanged);
		}

		private function onTextValueChanged(e:Event):void
		{
			if (_setterFunc && !_disableCallback)
				_setterFunc(_input.text);
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
			_input.x = _label.x + _label.width + InspectorConfiguration.COMPONENTS_PADDING;
			_input.width = getAvailableWidthForInputComponents();
		}
	}
}