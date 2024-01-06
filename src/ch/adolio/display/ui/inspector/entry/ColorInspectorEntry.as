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
	import ch.adolio.display.ui.inspector.panel.ColorSelectorPanel;
	import feathers.controls.Label;
	import feathers.controls.TextInput;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class ColorInspectorEntry extends InspectorEntry
	{
		private var _label:Label;
		private var _previewColor:Quad;
		private var _colorTextInput:TextInput;

		private var _getterFunc:Function;
		private var _setterFunc:Function;

		private var _disableCallback:Boolean = false;

		private static var _colorPickerPanel:ColorSelectorPanel;
		private var _previewContainer:Sprite;

		public function ColorInspectorEntry(title:String, getterFunc:Function, setterFunc:Function = null)
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

			var color:uint = 0;
			color = _getterFunc();

			_previewContainer = new Sprite();
			var bgMargin:Number = 2;
			var previewBackground:Quad = new Quad(_preferredHeight, _preferredHeight, 0x0);
			_previewContainer.addChild(previewBackground);
			_previewColor = new Quad(_preferredHeight - 2*bgMargin, _preferredHeight - 2*bgMargin, color);
			_previewColor.x = bgMargin;
			_previewColor.y = bgMargin;
			_previewColor.useHandCursor = true;
			_previewContainer.addChild(_previewColor);
			addChild(_previewContainer);

			_colorTextInput = new TextInput();
			_colorTextInput.styleName = InspectorConfiguration.STYLE_NAME_TEXT_INPUT;
			_colorTextInput.height = _preferredHeight;
			_colorTextInput.text = ColorSelectorPanel.colorToHexString(color);
			addChild(_colorTextInput);

			width = _preferredWidth;

			_colorTextInput.addEventListener(Event.CHANGE, onColorTextInputChanged);
		}

		private function onColorTextInputChanged(e:Event):void
		{
			var color:uint = uint(_colorTextInput.text);
			_previewColor.color = color;

			if (_setterFunc && !_disableCallback)
				_setterFunc(color);
		}

		public function getColor():uint
		{
			return _previewColor.color;
		}

		// Expect Argb color
		public function setColor(color:uint, disableCallback:Boolean = true):void
		{
			_disableCallback = disableCallback;
			_previewColor.color = color;
			_colorTextInput.text = ColorSelectorPanel.colorToHexString(color);
			_disableCallback = false;
		}

		//---------------------------------------------------------------------
		//-- Event handlers
		//---------------------------------------------------------------------

		override protected function onAddedToStage(e:Event):void
		{
			super.onAddedToStage(e);

			addEventListener(TouchEvent.TOUCH, onTouched);

			refresh();
		}

		override protected function onRemovedFromStage(e:Event):void
		{
			super.onRemovedFromStage(e);

			removeEventListener(TouchEvent.TOUCH, onTouched);

			if (_colorPickerPanel)
				_colorPickerPanel.colorChanged.remove(onPickerColorChanged);
		}

		private function onTouched(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(_previewContainer);
			if (touch && touch.phase == TouchPhase.ENDED)
			{
				if (!_colorPickerPanel)
					_colorPickerPanel = new ColorSelectorPanel();

				// if possible, place the color selector aside the current inspector
				if (_inspector)
				{
					_colorPickerPanel.x = _inspector.x + _inspector.width + InspectorConfiguration.COMPONENTS_PADDING;
					_colorPickerPanel.y = touch.globalY;
				}

				// force stage re-addition to perfom checks
				if (_colorPickerPanel.parent != null)
					_colorPickerPanel.removeFromParent();

				// setup & add to stage
				InspectorConfiguration.ROOT_LAYER.addChild(_colorPickerPanel);
				_colorPickerPanel.title = _label.text;
				_colorPickerPanel.entry = this;
				_colorPickerPanel.colorChanged.removeAll();
				_colorPickerPanel.color = _previewColor.color;
				_colorPickerPanel.colorChanged.add(onPickerColorChanged);
			}
		}

		private function onPickerColorChanged(color:uint):void
		{
			_previewColor.color = color;
			_colorTextInput.text = ColorSelectorPanel.colorToHexString(color);

			if (_setterFunc && !_disableCallback)
				_setterFunc(color);
		}

		override public function refresh():void
		{
			setColor(_getterFunc(), true);
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

			_label.width = getLabelWidth();
			_colorTextInput.width = getAvailableWidthForInputComponents() - (_previewContainer.width + InspectorConfiguration.COMPONENTS_PADDING);

			_label.x = _paddingLeft;
			_previewContainer.x = _label.x + _label.width + InspectorConfiguration.COMPONENTS_PADDING;
			_colorTextInput.x = _previewContainer.x + _previewContainer.width + InspectorConfiguration.COMPONENTS_PADDING;
		}
	}
}