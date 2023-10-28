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
	import ch.adolio.display.ui.inspector.panel.asset.AssetManagerTexturesPickerPanel;
	import feathers.controls.Button;
	import feathers.controls.Label;
	import flash.display.BitmapData;
	import starling.assets.AssetManager;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;

	/** Texture entry. */
	public class TextureInspectorEntry extends InspectorEntry
	{
		private var _assetManager:AssetManager;
		private var _titleLabel:Label;
		private var _loadFromAssetManagerButton:Button;
		private var _getterFunc:Function; // return starling.textures.Texture
		private var _setterFunc:Function; // set starling.textures.Texture

		private var _texturePreview:Image;
		private var _texture:Texture;
		private var _textureAlias:String;
		public var forcePotTexture:Boolean = false;

		public function TextureInspectorEntry(title:String, assetManager:AssetManager, getterFunc:Function, setterFunc:Function, forcePotTexture:Boolean = false)
		{
			_assetManager = assetManager;
			_getterFunc = getterFunc;
			_setterFunc = setterFunc;
			this.forcePotTexture = forcePotTexture;

			_titleLabel = new Label();
			_titleLabel.touchable = false;
			_titleLabel.styleName = InspectorConfiguration.STYLE_NAME_LABEL_ENTRY_TITLE;
			_titleLabel.text = title;
			_titleLabel.height = _preferredHeight;
			_titleLabel.validate();
			addChild(_titleLabel);

			_loadFromAssetManagerButton = new Button();
			_loadFromAssetManagerButton.styleName = InspectorConfiguration.STYLE_NAME_BUTTON;
			_loadFromAssetManagerButton.label = "Select";
			_loadFromAssetManagerButton.validate();
			_loadFromAssetManagerButton.isEnabled = setterFunc != null && _assetManager != null;
			addChild(_loadFromAssetManagerButton);

			_texture = _getterFunc();
			createImage();
		}

		//---------------------------------------------------------------------
		//-- Event handlers
		//---------------------------------------------------------------------

		override protected function onAddedToStage(e:starling.events.Event):void
		{
			super.onAddedToStage(e);

			_loadFromAssetManagerButton.addEventListener(starling.events.Event.TRIGGERED, onLoadFromAssetManagerButtonTriggered);

			refresh();
		}

		override protected function onRemovedFromStage(e:starling.events.Event):void
		{
			super.onRemovedFromStage(e);

			_loadFromAssetManagerButton.removeEventListener(starling.events.Event.TRIGGERED, onLoadFromAssetManagerButtonTriggered);
		}

		override public function refresh():void
		{
			_texture = _getterFunc();
			_textureAlias = getTextureAlias(_texture);

			refreshPreview();
		}

		public function refreshPreview():void
		{
			_texturePreview.texture = _texture;
		}

		private function onLoadFromAssetManagerButtonTriggered(e:starling.events.Event):void
		{
			if (_assetManager == null)
				return;

			var assetManagerTexturePicker:AssetManagerTexturesPickerPanel = new AssetManagerTexturesPickerPanel(_assetManager, forcePotTexture);
			assetManagerTexturePicker.textureSelected.add(onTextureSelected);

			// if possible, place the new panel aside the current inspector
			if (_inspector)
			{
				assetManagerTexturePicker.x = _inspector.x + _inspector.width + InspectorConfiguration.COMPONENTS_PADDING;
				assetManagerTexturePicker.y = _inspector.y;
			}

			InspectorConfiguration.ROOT_LAYER.addChild(assetManagerTexturePicker);
		}

		protected function onTextureSelected(texture:Texture, textureAlias:String):void
		{
			// update texture
			_texture = texture;
			_textureAlias = textureAlias;

			// refresh entry
			refreshPreview();

			// update
			_setterFunc(_texture);
		}

		public function get textureAlias():String
		{
			return _textureAlias;
		}

		public function getTextureAlias(texture:Texture):String
		{
			if (texture == null)
				return null;

			if (_assetManager == null)
				return null;

			var textures:Vector.<Texture> = _assetManager.getTextures();
			var texturesNames:Vector.<String> = _assetManager.getTextureNames();

			var len:int = textures.length;
			for (var i:int = 0; i < len; i++)
			{
				var tex:Texture = textures[i];
				if (texture == tex)
					return texturesNames[i];
			}

			return null;
		}

		private function createImage():void
		{
			if (_texture)
				_texturePreview = new Image(_texture);
			else
				_texturePreview = new Image(Texture.fromBitmapData(new BitmapData(1, 1)));

			_texturePreview.width = 24;
			_texturePreview.height = 24;
			addChild(_texturePreview);
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

			_titleLabel.x = _paddingLeft;
			_titleLabel.width = getLabelWidth();

			_texturePreview.x = _titleLabel.x + _titleLabel.width + InspectorConfiguration.COMPONENTS_PADDING;
			_loadFromAssetManagerButton.x = _texturePreview.x + _texturePreview.width + InspectorConfiguration.COMPONENTS_PADDING;
		}

		override public function get height():Number
		{
			return 24;
		}

		override public function set height(value:Number):void
		{
			// nop
		}
	}
}