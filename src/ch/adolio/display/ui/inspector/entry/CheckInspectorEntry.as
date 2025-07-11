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
	import feathers.controls.Check;
	import feathers.controls.Label;
	import starling.events.Event;

	public class CheckInspectorEntry extends InspectorEntry
	{
		private var _label:Label;
		private var _check:Check;
		private var _getterFunc:Function;
		private var _setterFunc:Function;

		private var _disableCallback:Boolean = false;

		public function CheckInspectorEntry(title:String, getterFunc:Function, setterFunc:Function = null)
		{
			_title = title;
			_getterFunc = getterFunc;
			_setterFunc = setterFunc;

			_label = new Label();
			_label.styleName = InspectorConfiguration.STYLE_NAME_LABEL_ENTRY_TITLE;
			_label.text = title;
			_label.toolTip = title;

			if (!isNaN(_preferredHeight) && _preferredHeight > 0)
				_label.height = _preferredHeight;

			_label.validate();
			addChild(_label);

			_check = new Check();
			_check.styleName = InspectorConfiguration.STYLE_NAME_CHECK;
			_check.isEnabled = setterFunc != null;
			_check.isSelected = _getterFunc();

			if (!isNaN(_preferredHeight) && _preferredHeight > 0)
				_check.height = _preferredHeight;

			_check.validate();
			addChild(_check);

			width = _preferredWidth;
		}

		public function setIsSelected(value:Number, disableCallback:Boolean = true):void
		{
			_disableCallback = disableCallback;
			_check.isSelected = value;
			_disableCallback = false;
		}

		override protected function onAddedToStage(e:Event):void
		{
			super.onAddedToStage(e);

			_check.addEventListener(Event.CHANGE, onCheckValueChanged);

			refresh();
		}

		override protected function onRemovedFromStage(e:Event):void
		{
			super.onRemovedFromStage(e);

			_check.removeEventListener(Event.CHANGE, onCheckValueChanged);
		}

		private function onCheckValueChanged(e:Event):void
		{
			if (_setterFunc && !_disableCallback)
				_setterFunc(_check.isSelected);
		}

		override public function refresh():void
		{
			setIsSelected(_getterFunc(), true);
		}

		public function get isEnabled():Boolean
		{
			return _check.isEnabled;
		}

		public function set isEnabled(value:Boolean):void
		{
			_check.isEnabled = value && _setterFunc;
		}

		//---------------------------------------------------------------------
		//-- Accessors
		//---------------------------------------------------------------------

		public function get titleLabel():Label
		{
			return _label;
		}

		public function get check():Check
		{
			return _check;
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
			_check.x = _label.x + _label.width + InspectorConfiguration.COMPONENTS_PADDING;
		}
	}
}