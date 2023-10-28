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
		private var _setteFunc:Function;

		private var _disableCallback:Boolean = false;

		public function CheckInspectorEntry(title:String, getterFunc:Function, setterFunc:Function = null)
		{
			_getterFunc = getterFunc;
			_setteFunc = setterFunc;

			_label = new Label();
			_label.touchable = false;
			_label.styleName = InspectorConfiguration.STYLE_NAME_LABEL_ENTRY_TITLE;
			_label.text = title;
			_label.height = _preferredHeight;
			addChild(_label);

			_check = new Check();
			_check.styleName = InspectorConfiguration.STYLE_NAME_CHECK;
			_check.isEnabled = setterFunc != null;
			_check.isSelected = _getterFunc();
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
			if (_setteFunc && !_disableCallback)
				_setteFunc(_check.isSelected);
		}

		override public function refresh():void
		{
			setIsSelected(_getterFunc(), true);
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