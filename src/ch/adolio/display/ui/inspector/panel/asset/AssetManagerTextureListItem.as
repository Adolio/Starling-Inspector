// =================================================================================================
//
//	Starling Inspector
//	Copyright (c) 2023 Aurelien Da Campo (Adolio), All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package ch.adolio.display.ui.inspector.panel.asset
{
	import ch.adolio.display.ui.inspector.InspectorConfiguration;
	import feathers.controls.Label;
	import org.osflash.signals.Signal;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	import starling.utils.Align;

	/** A visual item in the list of an Asset Manager's textures. */
	public class AssetManagerTextureListItem extends Sprite
	{
		// style
		private static const ITEM_BACKGROUND_SIZE:Number = 144;
		private static const IMAGE_SIZE_LIMIT:Number = 96;
		private const BACKGROUND_COLOR_SELECTED:uint = InspectorConfiguration.COLOR_BACKGROUND_HIGHLIGHT;
		private static const BACKGROUND_COLOR_DEFAULT:uint = 0xdddddd;
		private const ITEM_PADDING:Number = InspectorConfiguration.COMPONENTS_PADDING;

		// core elements
		private var _isSelected:Boolean;
		private var _texture:Texture;
		private var _textureAlias:String;

		// ui components
		private var _background:Quad;
		private var _aliasLabel:Label;
		private var _texturePropertiesLabel:Label;
		private var _previewImage:Image;
		private var _previewImageBackground:Quad;

		// signals
		public var selected:Signal = new Signal(AssetManagerTextureListItem, Boolean);

		/**
		 * Constructor.
		 *
		 * <p>Note that the item can be recycled by calling the `reset` method.</p>
		 */
		public function AssetManagerTextureListItem(texture:Texture, textureAlias:String)
		{
			// setup core variables
			_texture = texture;
			_textureAlias = textureAlias;

			// background
			_background = new Quad(ITEM_BACKGROUND_SIZE, ITEM_BACKGROUND_SIZE, BACKGROUND_COLOR_DEFAULT);
			addChild(_background);

			// properties label
			_texturePropertiesLabel = new Label();
			_texturePropertiesLabel.styleName = InspectorConfiguration.STYLE_NAME_LABEL_ENTRY_VALUE;
			_texturePropertiesLabel.touchable = false;
			_texturePropertiesLabel.x = ITEM_PADDING;
			_texturePropertiesLabel.y = ITEM_PADDING;
			_texturePropertiesLabel.width = _background.width - ITEM_PADDING * 2;
			_texturePropertiesLabel.validate();
			_texturePropertiesLabel.fontStyles.horizontalAlign = Align.RIGHT;
			_texturePropertiesLabel.fontStyles.size *= 0.8;
			setupTexturePropertiesLabel();
			_texturePropertiesLabel.validate();
			addChild(_texturePropertiesLabel);

			// texture preview
			_previewImage = new Image(_texture);
			_previewImage.touchable = false;
			setupPreviewImageSizeAndPosition();

			// texture preview background
			_previewImageBackground = new Quad(1, 1, 0xffffff);
			_previewImageBackground.touchable = false;
			_previewImageBackground.width = _previewImage.width;
			_previewImageBackground.height = _previewImage.height;
			_previewImageBackground.x = _previewImage.x;
			_previewImageBackground.y = _previewImage.y;
			addChild(_previewImageBackground);
			addChild(_previewImage);

			// label
			_aliasLabel = new Label();
			_aliasLabel.styleName = InspectorConfiguration.STYLE_NAME_LABEL_ENTRY_VALUE;
			_aliasLabel.touchable = false;
			_aliasLabel.text = _textureAlias;
			_aliasLabel.width = _background.width - ITEM_PADDING * 2;
			_aliasLabel.validate();
			_aliasLabel.x = ITEM_PADDING;
			_aliasLabel.y = _background.height - _aliasLabel.height - ITEM_PADDING;
			addChild(_aliasLabel);

			// register to stage addition
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		/** Reset to recycle with another texture. */
		public function reset(texture:Texture, textureAlias:String):void
		{
			// remove all listeners
			selected.removeAll();

			// setup core variables
			_texture = texture;
			_textureAlias = textureAlias;

			// setup alias label
			_aliasLabel.text = _textureAlias;
			_aliasLabel.validate();

			// setup details
			setupTexturePropertiesLabel();

			// update preview texture
			_previewImage.texture = _texture;
			_previewImage.readjustSize();

			// update size & position
			_previewImage.width = _texture.frameWidth;
			_previewImage.height = _texture.frameHeight;
			setupPreviewImageSizeAndPosition();

			// update preview image background
			_previewImageBackground.width = _previewImage.width;
			_previewImageBackground.height = _previewImage.height;
			_previewImageBackground.x = _previewImage.x;
			_previewImageBackground.y = _previewImage.y;

			// reset selection
			isSelected = false;
		}

		private static function formatNumber(value:Number, precision:int):String
		{
			var pow:Number = Math.pow(10, precision);
			return (Math.round(value * pow) / pow).toString();
		}

		private function setupTexturePropertiesLabel():void
		{
			var properties:String = "";

			// add texture size
			properties += formatNumber(_texture.frameWidth, 1) + "x" + formatNumber(_texture.frameHeight, 1);

			// add source size
			if (_texture.scale != 1.0)
				properties += " (" + formatNumber(_texture.frameWidth * _texture.scale, 1) + "x" + formatNumber(_texture.frameHeight * _texture.scale, 1) + ")";

			// add scale
			properties += " - " + _texture.scale+"x";

			// add pot flag
			if (_texture.root.isPotTexture && !(_texture is SubTexture))
				properties += " - POT";

			// update properties label
			_texturePropertiesLabel.text = properties;
		}

		private function setupPreviewImageSizeAndPosition():void
		{
			// setup size
			if (_previewImage.width > IMAGE_SIZE_LIMIT || _previewImage.height > IMAGE_SIZE_LIMIT)
				_previewImage.scale = _previewImage.width > _previewImage.height ? IMAGE_SIZE_LIMIT / _previewImage.width : IMAGE_SIZE_LIMIT / _previewImage.height;

			// setup position
			_previewImage.x = (_background.width - _previewImage.width) * 0.5;
			_previewImage.y = _texturePropertiesLabel.y + _texturePropertiesLabel.height + ITEM_PADDING;
		}

		//---------------------------------------------------------------------
		//-- Accessors
		//---------------------------------------------------------------------

		public function get texture():Texture
		{
			return _texture;
		}

		public function get textureAlias():String
		{
			return _textureAlias;
		}

		public function get isSelected():Boolean
		{
			return _isSelected;
		}

		public function set isSelected(value:Boolean):void
		{
			_isSelected = value;

			_background.color = value ? BACKGROUND_COLOR_SELECTED : BACKGROUND_COLOR_DEFAULT;
		}

		//---------------------------------------------------------------------
		//-- Event handlers
		//---------------------------------------------------------------------

		protected function onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);

			addEventListener(TouchEvent.TOUCH, onTouched);
		}

		protected function onRemovedFromStage(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			removeEventListener(TouchEvent.TOUCH, onTouched);
		}

		protected function onTouched(e:TouchEvent):void
		{
			var touch:Touch = e.touches[0];

			// double tap detection
			if (touch.tapCount == 2)
			{
				isSelected = true;
				selected.dispatch(this, true);
				return;
			}

			switch (touch.phase)
			{
				case TouchPhase.ENDED:
					isSelected = true;
					selected.dispatch(this, false);
				break;
			}
		}
	}
}