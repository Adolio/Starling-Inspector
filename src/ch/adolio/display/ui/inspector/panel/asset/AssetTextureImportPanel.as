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
	import ch.adolio.display.ui.inspector.entry.ActionInspectorEntry;
	import ch.adolio.display.ui.inspector.entry.CheckInspectorEntry;
	import ch.adolio.display.ui.inspector.entry.LabelInspectorEntry;
	import ch.adolio.display.ui.inspector.entry.SliderInspectorEntry;
	import ch.adolio.display.ui.inspector.panel.InspectorPanel;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display3D.Context3DTextureFormat;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import org.osflash.signals.Signal;
	import starling.assets.AssetManager;
	import starling.events.Event;
	import starling.textures.Texture;

	public class AssetTextureImportPanel extends InspectorPanel
	{
		private var _assetsManager:AssetManager;

		private var _texturePot:Boolean;
		private var _textureScale:Number = InspectorConfiguration.TEXTURE_IMPORT_SCALE_DEFAULT;
		private var _textureMipmaps:Boolean;
		private var _textureFormat:String = Context3DTextureFormat.BGRA;

		private var _currentFileRef:File;
		private var _loader:Loader;
		private var _loadingTexturePath:String;
		private var _importErrorMessage:String;

		private var _importErrorEntry:LabelInspectorEntry;

		public var textureImported:Signal = new Signal(Texture, String); // texture, alias

		public function AssetTextureImportPanel(assetsManager:AssetManager, powerOfTwoOnly:Boolean = false)
		{
			super(true, true);

			_assetsManager = assetsManager;
			_texturePot = powerOfTwoOnly;

			// setup title
			title = "Texture importation";

			addSparatorEntry("Options");

			addEntry(new CheckInspectorEntry("Generate mipmaps?",
				function():Boolean { return _textureMipmaps; },
				function(value:Boolean):void { _textureMipmaps = value; }
			));

			addEntry(new CheckInspectorEntry("Is power of two?",
				function():Boolean { return _texturePot; },
				powerOfTwoOnly ? null : function(value:Boolean):void { _texturePot = value; }
			));

			addSparatorEntry("Source file");

			addEntry(new SliderInspectorEntry("Scale",
				function():Number { return _textureScale; },
				function(value:Number):void { _textureScale = value; },
				InspectorConfiguration.TEXTURE_IMPORT_SCALE_MIN, InspectorConfiguration.TEXTURE_IMPORT_SCALE_MAX, InspectorConfiguration.TEXTURE_IMPORT_SCALE_STEP
			));

			addEntry(new ActionInspectorEntry("Select a file",
				function():void { selectFile(); }
			));

			_importErrorEntry = new LabelInspectorEntry("", function():String { return _importErrorMessage; });
			addEntry(_importErrorEntry);
		}

		//---------------------------------------------------------------------
		//-- Texture importation management
		//---------------------------------------------------------------------

		private function selectFile():void
		{
			_currentFileRef = new File();
			_currentFileRef.browse([new FileFilter("Image", "*.png;*.jpg;*.gif")]);
			_currentFileRef.addEventListener(flash.events.Event.SELECT, onFileSelected);
			_currentFileRef.addEventListener(flash.events.Event.CANCEL, onFileSelectionCanceled);
		}

		private function onFileSelectionCanceled(e:flash.events.Event):void
		{
			_currentFileRef = null;
		}

		private function onFileSelected(e:flash.events.Event):void
		{
			_currentFileRef.removeEventListener(starling.events.Event.SELECT, onFileSelected);

			loadTextureFile(_currentFileRef.nativePath);
		}

		private function loadTextureFile(texturePath:String):void
		{
			trace("[Asset Manager Texture Picker Body] Loading texture...");

			// create the loader
			_loader = new Loader();

			// load the texture
			_loadingTexturePath = texturePath;
			_loader.load(new URLRequest(texturePath));

			// when texture is loaded
			_loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, onComplete);
		}

		private function onComplete(e:flash.events.Event):void
		{
			// grab the loaded bitmap
			var loadedBitmap:Bitmap = _loader.content as Bitmap;

			// reset error
			_importErrorMessage = "";
			_importErrorEntry.refresh();

			// check POT
			if (_texturePot && (!isPowerOfTwo(loadedBitmap.width) || !isPowerOfTwo(loadedBitmap.height)))
			{
				_importErrorMessage = "ERROR: Texture size is not POT!";
				_importErrorEntry.refresh();
				return;
			}

			// check size
			if (loadedBitmap.width > Texture.maxSize || loadedBitmap.height > Texture.maxSize)
			{
				_importErrorMessage = "ERROR: Texture size is too big! Max size: " + Texture.maxSize;
				_importErrorEntry.refresh();
				return;
			}

			// create a texture from the loaded bitmap
			var texture:Texture = Texture.fromBitmap(loadedBitmap, _textureMipmaps, false, _textureScale, _textureFormat, _texturePot);

			// register to resources controller
			var textureFile:File = new File(_loadingTexturePath);
			var filename:String = textureFile.name;
			var filenameWithoutExtension:String = filename.substr(0, filename.lastIndexOf('.'));
			_assetsManager.addAsset(filenameWithoutExtension, texture);

			// done
			close();
			textureImported.dispatch(texture, filenameWithoutExtension);
		}

		public static function isPowerOfTwo(x:uint):Boolean
		{
			return (x & (x - 1)) == 0;
		}
	}
}