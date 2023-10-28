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
	import ch.adolio.display.ui.inspector.panel.InspectorPanel;
	import flash.geom.Point;
	import org.osflash.signals.Signal;
	import starling.assets.AssetManager;
	import starling.textures.Texture;

	public class AssetManagerTexturesPickerPanel extends InspectorPanel
	{
		private var _assetsManager:AssetManager;
		private var _assetManagerTexturesPickerBody:AssetManagerTexturesPickerBody;

		public var textureSelected:Signal = new Signal(Texture, String); // texture, alias

		private var _isTrackingSizeUpdate:Boolean = false;
		private static var _lastPosition:Point = new Point(NaN, NaN);
		private static var _lastSize:Point = new Point(NaN, NaN);

		public function AssetManagerTexturesPickerPanel(assetsManager:AssetManager, powerOfTwoTexturesOnly:Boolean)
		{
			super(true, true);

			_assetsManager = assetsManager;

			// setup title
			title = "Textures from Asset Manager";

			// add POT flag
			if (powerOfTwoTexturesOnly)
				title += " (POT only)";

			// replace default body
			_assetManagerTexturesPickerBody = new AssetManagerTexturesPickerBody(this, assetsManager, powerOfTwoTexturesOnly);
			_assetManagerTexturesPickerBody.textureSelected.add(onTextureSelected);
			body = _assetManagerTexturesPickerBody;

			// setup position from last panel
			if (!isNaN(_lastPosition.x))
				x = _lastPosition.x;

			if (!isNaN(_lastPosition.y))
				y = _lastPosition.y;

			// setup size from last panel
			if (!isNaN(_lastSize.x))
				width = _lastSize.x;

			if (!isNaN(_lastSize.y))
				height = _lastSize.y;

			// start tracking size update after initialization
			_isTrackingSizeUpdate = true;
		}

		public function get assetsManager():AssetManager
		{
			return _assetsManager;
		}

		protected function onTextureSelected(texture:Texture, textureAlias:String):void
		{
			textureSelected.dispatch(texture, textureAlias);
			close();
		}

		//---------------------------------------------------------------------
		//-- Position management
		//---------------------------------------------------------------------

		override public function set x(value:Number):void
		{
			super.x = value;

			_lastPosition.x = x;
		}

		override public function set y(value:Number):void
		{
			super.y = value;

			_lastPosition.y = y;
		}

		//---------------------------------------------------------------------
		//-- Size management
		//---------------------------------------------------------------------

		override public function set width(value:Number):void
		{
			super.width = value;

			if (_isTrackingSizeUpdate)
				_lastSize.x = width;
		}

		override public function set height(value:Number):void
		{
			super.height = value;

			if (_isTrackingSizeUpdate)
				_lastSize.y = height;
		}
	}
}