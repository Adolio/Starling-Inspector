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
	import ch.adolio.display.ui.inspector.panel.SliderConfigPanel;
	import ch.adolio.utils.InspectionUtils;
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.Slider;
	import feathers.controls.TextInput;
	import feathers.events.FeathersEventType;
	import starling.events.Event;

	public class SliderInspectorEntry extends InspectorEntry
	{
		private var _value:Number;
		private var _label:Label;
		private var _slider:Slider;
		private var _valueTextInput:TextInput;
		private var _getterFunc:Function;
		private var _setteFunc:Function;
		private var _isValueClampingEnabled:Boolean = true;
		private var _doUpdateValueOnTextInputValueChanged:Boolean = false;
		private var _doUpdateValueOnTextInputFocusOut:Boolean = true;

		private var _disableSliderChangeEventReaction:Boolean;
		private var _disableTextInputChangeEventReaction:Boolean;

		private var _sliderExtraRightPadding:Number = 5;

		// options
		private var _numberPrecision:uint;

		// config
		private static var _configPanel:SliderConfigPanel;
		private var _configButton:Button;

		public function SliderInspectorEntry(title:String,
		                                     getterFunc:Function,
		                                     setterFunc:Function = null,
		                                     min:Number = 0,
		                                     max:Number = 1.0,
		                                     step:Number = 0.1,
		                                     showConfigButton:Boolean = false,
		                                     numberPrecision:int = -1)
		{
			_title = title;
			_getterFunc = getterFunc;
			_setteFunc = setterFunc;

			// setup precision
			if (numberPrecision < 0)
				setupPrecisionFromRange(max - min);
			else
				_numberPrecision = numberPrecision;

			_label = new Label();
			_label.touchable = false;
			_label.styleName = InspectorConfiguration.STYLE_NAME_LABEL_ENTRY_TITLE;
			_label.text = title;
			_label.height = _preferredHeight;
			addChild(_label);

			_value = _getterFunc();

			_slider = new Slider();
			_slider.styleName = InspectorConfiguration.STYLE_NAME_SLIDER;
			_slider.minimum = min;
			_slider.maximum = max;
			_slider.step = step;
			_slider.height = _preferredHeight;
			_slider.minWidth = 0;
			_slider.value = _value;
			addChild(_slider);
			_slider.validate();

			_valueTextInput = new TextInput();
			_valueTextInput.styleName = InspectorConfiguration.STYLE_NAME_TEXT_INPUT;
			_valueTextInput.text = formatNumber(_slider.value, _numberPrecision);
			_valueTextInput.height = _preferredHeight;
			addChild(_valueTextInput);

			// setup for read-only
			if (!_setteFunc)
			{
				_slider.isEnabled = false;
				_valueTextInput.isEditable = false;
			}
			// setup configuration
			else if (showConfigButton)
			{
				_configButton = new Button();
				_configButton.styleName = InspectorConfiguration.STYLE_NAME_BUTTON;
				_configButton.label = "c";
				_configButton.width = _preferredHeight;
				_configButton.height = _preferredHeight;
				addChild(_configButton);
			}

			width = _preferredWidth;
		}

		public function setValue(value:Number, disableCallback:Boolean = true):void
		{
			_value = value;

			_disableSliderChangeEventReaction = disableCallback;
			_slider.value = value;
			_disableSliderChangeEventReaction = false;

			_disableTextInputChangeEventReaction = disableCallback;
			_valueTextInput.text = formatNumber(value, _numberPrecision);
			_disableTextInputChangeEventReaction = false;
		}

		public function getValue():Number
		{
			return _value;
		}

		public function get isValueClampingEnabled():Boolean
		{
			return _isValueClampingEnabled;
		}

		public function set isValueClampingEnabled(value:Boolean):void
		{
			_isValueClampingEnabled = value;
		}

		/**
		 * Setup appropriate number precision from range.
		 *
		 * <p>&lt; 10 -> 3 (.xxx)</p>
		 * <p>10..100 -> 2 (.xx)</p>
		 * <p>100..1000 -> 1 (.x)</p>
		 * <p>&gt; 1000 -> 0 (no floating part)</p>
		 */
		public function setupPrecisionFromRange(range:Number):void
		{
			if (range < 10)
				_numberPrecision = 3;
			else if (range < 100)
				_numberPrecision = 2;
			else if (range < 1000)
				_numberPrecision = 1;
			else
				_numberPrecision = 0;
		}

		public function get numberPrecision():uint
		{
			return _numberPrecision;
		}

		public function set numberPrecision(value:uint):void
		{
			_numberPrecision = value;
		}

		private static function formatNumber(value:Number, precision:int):String
		{
			var pow:Number = Math.pow(10, precision);
			return (Math.round(value * pow) / pow).toString();
		}

		private function updateValueFromTextInput():void
		{
			// get value from text input
			_value = Number(_valueTextInput.text);

			// clamp value (if enabled)
			if (_isValueClampingEnabled)
				_value = InspectionUtils.clamp(_value, _slider.minimum, _slider.maximum);

			// update slider component silently
			_disableSliderChangeEventReaction = true;
			_slider.value = _value;
			_disableSliderChangeEventReaction = false;

			// call callback
			if (_setteFunc)
				_setteFunc(_value);
		}

		//---------------------------------------------------------------------
		//-- Event handlers
		//---------------------------------------------------------------------

		override protected function onAddedToStage(e:Event):void
		{
			super.onAddedToStage(e);

			// invalidate components
			_label.invalidate();
			_slider.invalidate();
			_valueTextInput.invalidate();

			// register to events
			_slider.addEventListener(Event.CHANGE, onSliderValueChanged);
			_valueTextInput.addEventListener(Event.CHANGE, onTextInputValueChanged);
			_valueTextInput.addEventListener(FeathersEventType.FOCUS_IN, onValueTextInputFocusedIn);
			_valueTextInput.addEventListener(FeathersEventType.FOCUS_OUT, onValueTextInputFocusedOut);

			if (_configButton)
				_configButton.addEventListener(Event.TRIGGERED, onConfigButtonTriggered);

			// refresh
			refresh();
		}

		override protected function onRemovedFromStage(e:Event):void
		{
			super.onRemovedFromStage(e);

			_slider.removeEventListener(Event.CHANGE, onSliderValueChanged);
			_valueTextInput.removeEventListener(Event.CHANGE, onTextInputValueChanged);
			_valueTextInput.removeEventListener(FeathersEventType.FOCUS_IN, onValueTextInputFocusedIn);
			_valueTextInput.removeEventListener(FeathersEventType.FOCUS_OUT, onValueTextInputFocusedOut);

			if (_configButton)
				_configButton.removeEventListener(Event.TRIGGERED, onConfigButtonTriggered);

			if (_configPanel)
			{
				_configPanel.minChanged.remove(onMinValueChanged);
				_configPanel.maxChanged.remove(onMaxValueChanged);
				_configPanel.stepChanged.remove(onStepValueChanged);
			}
		}

		private function onConfigButtonTriggered(e:Event):void
		{
			// create global panel
			if (!_configPanel)
				_configPanel = new SliderConfigPanel(_slider.minimum, _slider.maximum, _slider.step);

			// update config panel title
			_configPanel.title = "Slider Config: " + _label.text;

			// clear listeners
			_configPanel.minChanged.removeAll();
			_configPanel.maxChanged.removeAll();
			_configPanel.stepChanged.removeAll();

			// update default values
			_configPanel.min = _slider.minimum;
			_configPanel.max = _slider.maximum;
			_configPanel.step = _slider.step;

			// add current entry as listener
			_configPanel.minChanged.add(onMinValueChanged);
			_configPanel.maxChanged.add(onMaxValueChanged);
			_configPanel.stepChanged.add(onStepValueChanged);

			// show panel
			InspectorConfiguration.ROOT_LAYER.addChild(_configPanel);

			// if possible, place the new panel aside the current inspector
			if (_inspector)
			{
				_configPanel.x = _inspector.x + _inspector.width + InspectorConfiguration.COMPONENTS_PADDING;
				_configPanel.y = _inspector.y;
			}
		}

		private function onMinValueChanged(value:Number):void
		{
			if (value >= _slider.maximum)
				return;

			_slider.minimum = value;
			setValue(_slider.value);
		}

		private function onMaxValueChanged(value:Number):void
		{
			if (value <= _slider.minimum)
				return;

			_slider.maximum = value;
			setValue(_slider.value);
		}

		private function onStepValueChanged(value:Number):void
		{
			if (value <= 0)
				return;

			_slider.step = value;
			setValue(_slider.value);
		}

		private function onSliderValueChanged(e:Event):void
		{
			if (_disableSliderChangeEventReaction)
				return;

			_value = _slider.value;
			_disableTextInputChangeEventReaction = true;
			_valueTextInput.text = formatNumber(_slider.value, _numberPrecision);
			_disableTextInputChangeEventReaction = false;

			if (_setteFunc)
				_setteFunc(_value);
		}

		private function onTextInputValueChanged(e:Event):void
		{
			if (_disableTextInputChangeEventReaction)
				return;

			// update value
			if (_doUpdateValueOnTextInputValueChanged)
				updateValueFromTextInput();
		}

		private function onValueTextInputFocusedIn(e:Event):void
		{
			// select the whole text
			_valueTextInput.selectRange(0, _valueTextInput.text.length);
		}

		private function onValueTextInputFocusedOut(e:Event):void
		{
			// update value
			if (_doUpdateValueOnTextInputFocusOut)
				updateValueFromTextInput();
		}

		public function get slider():Slider
		{
			return _slider;
		}

		override public function refresh():void
		{
			setValue(_getterFunc(), true);
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

			// compute components width
			_label.width = getLabelWidth();
			var availableWidth:Number = getAvailableWidthForInputComponents();

			if (_configButton)
				availableWidth -= _configButton.width + InspectorConfiguration.COMPONENTS_PADDING;

			// compute guessed widths
			var sliderWidth:Number = availableWidth * InspectorConfiguration.SLIDER_ENTRY_SLIDER_INPUT_WIDTH_RATIO;
			var textInputWidth:Number =  availableWidth - (sliderWidth + _sliderExtraRightPadding + InspectorConfiguration.COMPONENTS_PADDING);

			// text input min width contraint
			if (!isNaN(InspectorConfiguration.SLIDER_ENTRY_TEXT_INPUT_MIN_WIDTH))
				textInputWidth = Math.max(textInputWidth, InspectorConfiguration.SLIDER_ENTRY_TEXT_INPUT_MIN_WIDTH);

			//  text input max width contraint
			if (!isNaN(InspectorConfiguration.SLIDER_ENTRY_TEXT_INPUT_MAX_WIDTH))
				textInputWidth = Math.min(textInputWidth, InspectorConfiguration.SLIDER_ENTRY_TEXT_INPUT_MAX_WIDTH);

			// update components
			_valueTextInput.width = textInputWidth;
			_slider.width = Math.max(availableWidth - _valueTextInput.width - (_sliderExtraRightPadding + InspectorConfiguration.COMPONENTS_PADDING), 0);

			// place components
			_label.x = _paddingLeft;
			_slider.x = _label.x + _label.width + InspectorConfiguration.COMPONENTS_PADDING;
			_valueTextInput.x = _slider.x + _slider.width + _sliderExtraRightPadding + InspectorConfiguration.COMPONENTS_PADDING;
			if (_configButton)
				_configButton.x = _valueTextInput.x + _valueTextInput.width + InspectorConfiguration.COMPONENTS_PADDING;
		}
	}
}