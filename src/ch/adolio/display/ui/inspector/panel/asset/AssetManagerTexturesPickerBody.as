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
	import ch.adolio.display.ui.inspector.panel.InspectorBody;
	import ch.adolio.display.ui.inspector.panel.InspectorPanel;
	import feathers.controls.Button;
	import feathers.controls.ScrollBarDisplayMode;
	import feathers.controls.ScrollContainer;
	import feathers.controls.ScrollInteractionMode;
	import feathers.controls.ScrollPolicy;
	import feathers.controls.TextInput;
	import feathers.layout.FlowLayout;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	import org.osflash.signals.Signal;
	import starling.assets.AssetManager;
	import starling.events.Event;
	import starling.textures.SubTexture;
	import starling.textures.Texture;

	public class AssetManagerTexturesPickerBody extends InspectorBody
	{
		// UI elements
		private var _assetsManager:AssetManager;
		private var _scrollContainer:ScrollContainer;

		// last inspector properties
		private static var _lastFilter:String;

		// filter
		private var MIN_FILTER_CHARACTERS:uint = 3; // prevent showing too much textures
		private var _searchInput:TextInput;
		private var _powerOfTwoTexturesOnly:Boolean = true;

		// selection
		private var _selectButton:Button;

		// importation
		private var _importButton:Button;
		private var _importPanel:AssetTextureImportPanel;

		// items
		private var _selectedItem:AssetManagerTextureListItem;
		private var _itemsInUse:Vector.<AssetManagerTextureListItem> = new Vector.<AssetManagerTextureListItem>();
		private static var _itemsPool:Vector.<AssetManagerTextureListItem> = new Vector.<AssetManagerTextureListItem>();
		private static var _texturesTmp:Vector.<Texture> = new Vector.<Texture>();
		private static var _texturesNamesTmp:Vector.<String> = new Vector.<String>();

		// events
		public var textureSelected:Signal = new Signal(Texture, String); // texture, alias

		public function AssetManagerTexturesPickerBody(panel:InspectorPanel, assetsManager:AssetManager, powerOfTwoTexturesOnly:Boolean)
		{
			super(panel);

			_assetsManager = assetsManager;
			_powerOfTwoTexturesOnly = powerOfTwoTexturesOnly;

			// search input
			_searchInput = new TextInput();
			_searchInput.styleName = InspectorConfiguration.STYLE_NAME_TEXT_INPUT;
			_searchInput.prompt = "Filter";
			_searchInput.text = _lastFilter;
			_searchInput.validate();
			addChild(_searchInput);

			// setup vertical scroll container
			_scrollContainer = new ScrollContainer();
			var layout:FlowLayout = new FlowLayout();
			layout.horizontalAlign = HorizontalAlign.LEFT;
			layout.verticalAlign = VerticalAlign.TOP;
			layout.gap = InspectorConfiguration.COMPONENTS_PADDING;
			_scrollContainer.layout = layout;
			_scrollContainer.interactionMode = ScrollInteractionMode.TOUCH_AND_SCROLL_BARS;
			_scrollContainer.horizontalScrollPolicy = ScrollPolicy.OFF;
			_scrollContainer.scrollBarDisplayMode = ScrollBarDisplayMode.FIXED_FLOAT;
			_scrollContainer.interactionMode = ScrollInteractionMode.MOUSE;
			_scrollContainer.padding = 5;
			_scrollContainer.y = _searchInput.y + _searchInput.height + InspectorConfiguration.COMPONENTS_PADDING;
			addChild(_scrollContainer);

			// select button
			_selectButton = new Button();
			_selectButton.label = "Select";
			_selectButton.validate();
			_selectButton.height *= 2; // double size for better visibility
			addChild(_selectButton);

			// import button
			_importButton = new Button();
			_importButton.styleName = InspectorConfiguration.STYLE_NAME_BUTTON;
			_importButton.label = "Import from disk";
			_importButton.validate();
			_importButton.height *= 2; // double size for better visibility
			addChild(_importButton);

			// update
			updateListOfTextures();
		}

		private function updateListOfTextures():void
		{
			// remove all items
			_scrollContainer.removeChildren();

			// move all used items in the cache
			while (_itemsInUse.length > 0)
				_itemsPool.push(_itemsInUse.pop());

			// check minimum character in filter input
			if (_searchInput.text.length < MIN_FILTER_CHARACTERS)
				return;

			// get textures & textures names
			_texturesTmp.length = 0;
			_assetsManager.getTextures("", _texturesTmp);
			_texturesNamesTmp.length = 0;
			_assetsManager.getTextureNames("", _texturesNamesTmp);

			// update texture entries
			var len:int = _texturesTmp.length;
			for (var i:int = 0; i < len; i++)
			{
				// discard atlases
				if (_assetsManager.getTextureAtlas(_texturesNamesTmp[i]) != null)
					continue;

				// filter power of two textures
 				if (_powerOfTwoTexturesOnly && (!_texturesTmp[i].root.isPotTexture || _texturesTmp[i] is SubTexture))
					continue;

				// check filter
				var alias:String = _texturesNamesTmp[i];
				if (alias.toLowerCase().indexOf(_searchInput.text.toLowerCase()) == -1)
					continue;

				// create texture item
				var textureItem:AssetManagerTextureListItem = getTextureItem(_texturesTmp[i], alias);
				textureItem.selected.add(onTextureItemSelected);
				_scrollContainer.addChild(textureItem);
			}
		}

		private function getTextureItem(texture:Texture, textureAlias:String):AssetManagerTextureListItem
		{
			var textureItem:AssetManagerTextureListItem;
			if (_itemsPool.length > 0)
			{
				textureItem = _itemsPool.pop();
				textureItem.reset(texture, textureAlias);
			}
			else
			{
				textureItem = new AssetManagerTextureListItem(texture, textureAlias);
			}

			_itemsInUse.push(textureItem);
			return textureItem;
		}

		//---------------------------------------------------------------------
		//-- Event handlers
		//---------------------------------------------------------------------

		override protected function onAddedToStage(e:starling.events.Event):void
		{
			super.onAddedToStage(e);

			_searchInput.addEventListener(starling.events.Event.CHANGE, onSearchTextChanged);
			_selectButton.addEventListener(starling.events.Event.TRIGGERED, onSelectButtonTriggered);
			_importButton.addEventListener(starling.events.Event.TRIGGERED, onImportButtonTriggered);

			// focus filter input
			_searchInput.setFocus();
		}

		override protected function onRemovedFromStage(e:starling.events.Event):void
		{
			super.onRemovedFromStage(e);

			_searchInput.removeEventListener(starling.events.Event.CHANGE, onSearchTextChanged);
			_selectButton.removeEventListener(starling.events.Event.TRIGGERED, onSelectButtonTriggered);
			_importButton.removeEventListener(starling.events.Event.TRIGGERED, onImportButtonTriggered);
		}

		protected function onSearchTextChanged(e:starling.events.Event):void
		{
			// update last filter for new inspector
			_lastFilter = _searchInput.text;

			updateListOfTextures();
		}

		protected function onSelectButtonTriggered(e:starling.events.Event):void
		{
			if (_selectedItem)
				textureSelected.dispatch(_selectedItem.texture, _selectedItem.textureAlias);
		}

		protected function onTextureItemSelected(item:AssetManagerTextureListItem, withDirectValidation:Boolean):void
		{
			if (_selectedItem && _selectedItem != item)
				_selectedItem.isSelected = false;

			_selectedItem = item;

			if (_selectedItem && withDirectValidation)
				textureSelected.dispatch(_selectedItem.texture, _selectedItem.textureAlias);
		}

		private function onImportButtonTriggered(e:starling.events.Event):void
		{
			// create import panel
			if (!_importPanel)
			{
				_importPanel = new AssetTextureImportPanel(_assetsManager, _powerOfTwoTexturesOnly);
				_importPanel.x = _inspector.x + _inspector.width + InspectorConfiguration.COMPONENTS_PADDING;
				_importPanel.y = _inspector.y;

				// listen to texture importation event
				_importPanel.textureImported.add(
					function(texture:Texture, alias:String):void
					{
						_searchInput.text = alias;
					}
				);
			}

			// add import panel to stage
			InspectorConfiguration.ROOT_LAYER.addChild(_importPanel);
		}

		//---------------------------------------------------------------------
		//-- Size management
		//---------------------------------------------------------------------

		override public function set width(value:Number):void
		{
			_preferredWidth = value;
			super.width = _preferredWidth;

			_searchInput.width = value;
			_scrollContainer.width = value;
			_selectButton.width = (value - InspectorConfiguration.COMPONENTS_PADDING) * 0.75;
			_importButton.x = _selectButton.x + _selectButton.width + InspectorConfiguration.COMPONENTS_PADDING;
			_importButton.width = (value - InspectorConfiguration.COMPONENTS_PADDING) * 0.25;
		}

		override public function set height(value:Number):void
		{
			_preferredHeight = value;
			super.height = _preferredHeight;

			_scrollContainer.y = _searchInput.y + _searchInput.height + InspectorConfiguration.COMPONENTS_PADDING;
			_scrollContainer.height = value - (_searchInput.height + _selectButton.height + InspectorConfiguration.COMPONENTS_PADDING * 2);
			_selectButton.y = _scrollContainer.y + _scrollContainer.height + InspectorConfiguration.COMPONENTS_PADDING;
			_importButton.y = _scrollContainer.y + _scrollContainer.height + InspectorConfiguration.COMPONENTS_PADDING;
		}
	}
}