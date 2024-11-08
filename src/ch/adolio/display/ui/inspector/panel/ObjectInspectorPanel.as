// =================================================================================================
//
//	Starling Inspector
//	Copyright (c) 2023 Aurelien Da Campo (Adolio), All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package ch.adolio.display.ui.inspector.panel
{
	import ch.adolio.display.shape.BorderedRectangle;
	import ch.adolio.display.ui.inspector.InspectorConfiguration;
	import ch.adolio.display.ui.inspector.entry.ActionInspectorEntry;
	import ch.adolio.display.ui.inspector.entry.BlendModeInspectorEntry;
	import ch.adolio.display.ui.inspector.entry.CheckInspectorEntry;
	import ch.adolio.display.ui.inspector.entry.ColorInspectorEntry;
	import ch.adolio.display.ui.inspector.entry.ObjectReferenceInspectorEntry;
	import ch.adolio.display.ui.inspector.entry.SliderInspectorEntry;
	import ch.adolio.display.ui.inspector.entry.TextInputInspectorEntry;
	import ch.adolio.display.ui.inspector.entry.TextureInspectorEntry;
	import ch.adolio.display.ui.inspector.entry.TextureSmoothingInspectorEntry;
	import ch.adolio.utils.InspectionUtils;
	import feathers.controls.Button;
	import flash.geom.Rectangle;
	import flash.utils.describeType;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.filters.FilterChain;
	import starling.textures.Texture;
	import starling.utils.deg2rad;
	import starling.utils.rad2deg;

	/**
	 * Inspector panel for any Object.
	 *
	 * <p>The `Inspectable` metadata can be used for `Number` field type.
	 * Usage: `[Inspectable(min=0, max=5.0, step=0.5)]`</p>
	 */
	public class ObjectInspectorPanel extends InspectorPanel implements IAnimatable
	{
		// object
		private var _object:Object;
		private var _hasSizeBeenSetup:Boolean = false;

		// stack
		private var _objectStack:Vector.<Object> = new Vector.<Object>();
		private var _backButton:Button;

		// inspection quad
		private var _boundsIndicator:BorderedRectangle;
		private var _objectBounds:Rectangle = new Rectangle();

		// native types
		private const TYPE_BOOLEAN:String = "Boolean";
		private const TYPE_NUMBER:String = "Number";
		private const TYPE_INT:String = "int";
		private const TYPE_UINT:String = "uint";
		private const TYPE_STRING:String = "String";

		// special types
		private const TYPE_TEXTURE:String = "starling.textures::Texture";

		// access
		private const ACCESS_READ_ONLY:String = "readonly";
		private const ACCESS_READ_WRITE:String = "readwrite";
		private const ACCESS_WRITE_ONLY:String = "writeonly";

		// metadata
		private const INSPECTABLE_METADATA_NAME:String = "Inspectable";
		private const INSPECTABLE_METADATA_KEY_MIN:String = "min";
		private const INSPECTABLE_METADATA_KEY_MAX:String = "max";
		private const INSPECTABLE_METADATA_KEY_STEP:String = "step";

		// methods
		public var ignoredMethods:Array = ["dispose"];

		// singleton
		private static var _instance:ObjectInspectorPanel;
		static public function get instance():ObjectInspectorPanel
		{
			if (_instance == null)
				_instance = new ObjectInspectorPanel();

			return _instance;
		}

		public function ObjectInspectorPanel()
		{
			super();

			_backButton = new Button();
			_backButton.styleName = InspectorConfiguration.STYLE_NAME_PANEL_BACK_BUTTON;
			_backButton.height = _footer.height;
			_backButton.label = "Back";
			_backButton.visible = false;
			_backButton.maxHeight = _footer.height;
			_footer.addChild(_backButton);
		}

		public function get object():Object
		{
			return _object;
		}

		public function set object(value:Object):void
		{
			inspect(value, true, false);
		}

		/**
		 * Inspects a given object.
		 *
		 * @param value The object to inspect
		 * @param resetStack Reset the stack (breadcrumb navigation)
		 * @param stackPreviousObject Stack the object to enable the back button and return to the previous object
		 */
		public function inspect(value:Object, resetStack:Boolean, stackPreviousObject:Boolean):void
		{
			// reset the breadcrumb
			if (resetStack)
				_objectStack.length = 0;

			// stack current object
			if (object != null && stackPreviousObject)
				_objectStack.push(object);

			// update the entity
			_object = value;

			// remove the inspection rectangle, it will be re-added just after if available
			if (_boundsIndicator)
				_boundsIndicator.removeFromParent();

			// setup panel
			if (_object)
			{
				// setup title
				title = InspectionUtils.findObjectName(_object);

				// setup entries
				setupEntries();

				// update overlay
				updateInspectionOverlay();
			}
			else
			{
				// reset title
				title = "";

				// dispoes all entries
				_body.removeEntries(true);
			}

			// force stage re-addition to perfom checks
			if (parent != null)
				removeFromParent();

			// setup & add to stage
			InspectorConfiguration.ROOT_LAYER.addChild(ObjectInspectorPanel.instance);

			// reset stack
			refreshBackButton();
			body.sortEntriesAlphabetically();
		}

		override public function close():void
		{
			object = null;

			super.close();
		}

		private function refreshBackButton():void
		{
			_backButton.visible = _objectStack.length > 0;
		}

		//---------------------------------------------------------------------
		//-- Size management
		//---------------------------------------------------------------------

		override public function setupHeightFromContent():void
		{
			// don't setup height until there are entries
			if (_body.entries.length == 0)
				return;

			super.setupHeightFromContent();
		}

		//----------------------------------------------------------------------
		//-- Entries management
		//----------------------------------------------------------------------

		private function setupEntries():void
		{
			// dispoes all entries
			_body.removeEntries(true);

			if (_object is FilterChain)
				createFilterChainEntries();
			else
				createEntriesFromClassDescription();

			// setup size at the first inspection
			if (!_hasSizeBeenSetup)
			{
				setupWidth();
				setupHeight();
				_hasSizeBeenSetup = true;
			}
		}

		private function createFilterChainEntries():void
		{
			// create entries from class description
			createEntriesFromClassDescription();

			// add each filter as an inspector entry to allow inspection
			var filterChain:FilterChain = _object as FilterChain;
			for (var i:int = 0; i < filterChain.numFilters; i++)
				addObjectReferenceEntryFromObject("filter [" + i + "]", filterChain.getFilterAt(i));
		}

		private function createEntriesFromClassDescription():void
		{
			// variable (for static objects)
			var description:XML = describeType(_object);
			//trace("Description: " + description + "");

			var type:String;
			var name:String;
			var access:String;

			// variables
			for each (var variable:XML in description.variable)
			{
				name = variable.@name;
				type = variable.@type;

				if (type == TYPE_BOOLEAN)
					addBooleanEntry(name, ACCESS_READ_WRITE);
				else if (type == TYPE_NUMBER)
					addNumberEntry(name, ACCESS_READ_WRITE, variable.metadata);
				else if (type == TYPE_INT)
					addIntEntry(name, ACCESS_READ_WRITE);
				else if (type == TYPE_UINT)
					addUintEntry(name, ACCESS_READ_WRITE);
				else if (type == TYPE_STRING)
					addStringEntry(name, ACCESS_READ_WRITE);
				else if (type == TYPE_TEXTURE)
					addTextureEntry(name, ACCESS_READ_WRITE);
				else
					addObjectReferenceEntry(name, ACCESS_READ_WRITE);
			}

			// accessors
			for each (var accessor:XML in description.accessor)
			{
				name = accessor.@name;
				type = accessor.@type;
				access = accessor.@access;

				// "write only" access is not supported
				if (access == ACCESS_WRITE_ONLY)
				{
					trace("Unsupported access for field '"+ name +"': " + access);
					continue;
				}

				if (type == TYPE_BOOLEAN)
					addBooleanEntry(name, access);
				else if (type == TYPE_NUMBER)
					addNumberEntry(name, access, accessor.metadata);
				else if (type == TYPE_INT)
					addIntEntry(name, access);
				else if (type == TYPE_UINT)
					addUintEntry(name, access);
				else if (type == TYPE_STRING)
					addStringEntry(name, access);
				else if (type == TYPE_TEXTURE)
					addTextureEntry(name, access);
				else
					addObjectReferenceEntry(name, access);
			}

			// methods
			for each (var method:XML in description.method)
			{
				var methodName:String = method.@name;

				// ignore certain methods
				if (ignoredMethods.indexOf(methodName) != -1)
					continue;

				// only treat zero parameters methods
				var parametersCount:uint = method.parameter.length();
				if (parametersCount > 0)
					continue;

				// add method entry
				addBasicMethodEntry(methodName);
			}
		}

		private function addBasicMethodEntry(methodName:String):void
		{
			var entry:ActionInspectorEntry = new ActionInspectorEntry("Call " + methodName+"()",
				function():void
				{
					try
					{
						_object[methodName]();
					}
					catch (e:Error)
					{
						trace("An error occured while calling " + methodName + " on " + _object + ". Error:" + e);
					}
				}
			);

			entry.title = "zzzAction " + methodName; // HACK: zzz to sort to the end
			addEntry(entry);
		}

		private function addBooleanEntry(fieldName:String, access:String):void
		{
			if (access == ACCESS_READ_ONLY)
			{
				addEntry(new CheckInspectorEntry(fieldName,
					function():Boolean { return _object[fieldName]; },
					null)
				);
			}
			else if (access == ACCESS_READ_WRITE)
			{
				addEntry(new CheckInspectorEntry(fieldName,
					function():Boolean { return _object[fieldName]; },
					function(value:Boolean):void { _object[fieldName] = value; })
				);
			}
			else
			{
				trace("Unsupported access for field '"+ fieldName +"': " + access);
			}
		}

		private function addNumberEntry(fieldName:String, access:String, metadataList:XMLList):void
		{
			var value:Number = _object[fieldName];

			// guess best min, max
			var min:Number = -100;
			var max:Number = 100;

			// check for "alpha" keyword in fieldName
			if (fieldName.toLowerCase().indexOf("alpha") != -1)
			{
				min = 0;
				max = 1.0;
				step = 0.05;
			}
			// check for "rotation" and "angle" fields
			else if (fieldName == "rotation" || fieldName == "angle")
			{
				addRotationEntry(fieldName, access); // TODO add support for metadata
				return;
			}
			else
			{
				if (value != 0)
				{
					min = value / 10.0;
					max = value * 10.0;
				}

				if (min > max)
				{
					var temp:Number = max;
					max = min;
					min = max;
				}

				// guess best step from min/max
				var step:Number = (max - min) / 100.0;
			}

			// override guessed values with metadata
			if (metadataList)
			{
				for each (var metadata:XML in metadataList)
				{
					if (metadata.@name == INSPECTABLE_METADATA_NAME)
					{
						for each (var metadataArg:XML in metadata.arg)
						{
							switch (metadataArg.@key.toString())
							{
								case INSPECTABLE_METADATA_KEY_MIN:
									min = Number(metadataArg.@value);
								break;
								case INSPECTABLE_METADATA_KEY_MAX:
									max = Number(metadataArg.@value);
								break;
								case INSPECTABLE_METADATA_KEY_STEP:
									step = Math.abs(Number(metadataArg.@value));
								break;
								default:
									trace("Unsupported argument '" + metadataArg.@key + "' in '" + INSPECTABLE_METADATA_NAME + "' metadata for field '" + fieldName + "'.");
								break;
							}
						}
					}
				}

				// invert min / max if needed
				if (min > max)
				{
					temp = max;
					max = min;
					min = max;
				}
			}

			if (access == ACCESS_READ_ONLY)
			{
				addEntry(new SliderInspectorEntry(fieldName,
					function():Number { return _object[fieldName]; },
					null, min, max, step, false)
				);
			}
			else if (access == ACCESS_READ_WRITE)
			{
				var sliderEntry:SliderInspectorEntry = new SliderInspectorEntry(fieldName,
					function():Number { return _object[fieldName]; },
					function(value:Number):void { _object[fieldName] = value; },
					min, max, step, false);
				sliderEntry.isValueClampingEnabled = false; // disable clamping since limits were guessed
				addEntry(sliderEntry);
			}
			else
			{
				trace("Unsupported access for field '"+ fieldName +"': " + access);
			}
		}

		/** Add a rotation / angle entry. Unit will be presented in degrees but treated in radians. */
		private function addRotationEntry(fieldName:String, access:String):void
		{
			if (access == ACCESS_READ_ONLY)
			{
				addEntry(new SliderInspectorEntry(fieldName,
					function():Number { return rad2deg(_object[fieldName]); },
					null, -180, 180, 5.0, false)
				);
			}
			else if (access == ACCESS_READ_WRITE)
			{
				addEntry(new SliderInspectorEntry(fieldName,
					function():Number { return rad2deg(_object[fieldName]); },
					function(value:Number):void { _object[fieldName] = deg2rad(value); },
					-180, 180, 5.0, false)
				);
			}
			else
			{
				trace("Unsupported access for field '"+ fieldName +"': " + access);
			}
		}

		private function addIntEntry(fieldName:String, access:String):void
		{
			// guest min, max & step values
			var value:int = _object[fieldName];
			var min:int = -Math.abs(value) * 5.0;
			var max:int = Math.abs(value) * 5.0;

			if (value == 0)
			{
				min = -100;
				max = 100;
			}

			var step:Number = Math.round((max - min) / 100.0);

			if (access == ACCESS_READ_ONLY)
			{
				addEntry(new SliderInspectorEntry(fieldName,
					function():int { return _object[fieldName]; },
					null, min, max, step, false)
				);
			}
			else if (access == ACCESS_READ_WRITE)
			{
				var sliderEntry:SliderInspectorEntry = new SliderInspectorEntry(fieldName,
					function():int { return _object[fieldName]; },
					function(value:int):void { _object[fieldName] = value; },
					min, max, step, false);
				sliderEntry.isValueClampingEnabled = false; // disable clamping since limits were guessed
				addEntry(sliderEntry);
			}
			else
			{
				trace("Unsupported access for field '"+ fieldName +"': " + access);
			}
		}

		private function addUintEntry(fieldName:String, access:String):void
		{
			// check for "color" keyword in fieldName
			if (fieldName.toLowerCase().indexOf("color") != -1)
			{
				addColorEntry(fieldName, access);
				return;
			}

			// guest min, max & step values
			var value:uint = _object[fieldName];
			var min:uint = Math.round(value / 10.0);
			var max:uint = value * 10.0;

			if (value == 0)
			{
				min = 0;
				max = 100;
			}

			var step:Number = Math.round((max - min) / 100.0);

			if (access == ACCESS_READ_ONLY)
			{
				addEntry(new SliderInspectorEntry(fieldName,
					function():uint { return _object[fieldName]; },
					null, min, max, step, false)
				);
			}
			else if (access == ACCESS_READ_WRITE)
			{
				var sliderEntry:SliderInspectorEntry = new SliderInspectorEntry(fieldName,
					function():uint { return _object[fieldName]; },
					function(value:uint):void { _object[fieldName] = value; },
					min, max, step, false);
				sliderEntry.isValueClampingEnabled = false; // disable clamping since limits were guessed
				addEntry(sliderEntry);
			}
			else
			{
				trace("Unsupported access for field '"+ fieldName +"': " + access);
			}
		}

		private function addStringEntry(fieldName:String, access:String):void
		{
			// check for "blendMode" keyword in fieldName
			if (fieldName.indexOf("blendMode") != -1)
			{
				addBlendModeEntry(fieldName, access);
				return;
			}

			// check for "textureSmoothing" keyword in fieldName
			if (fieldName.indexOf("textureSmoothing") != -1)
			{
				addTextureSmoothingEntry(fieldName, access);
				return;
			}

			if (access == ACCESS_READ_ONLY)
			{
				addEntry(new TextInputInspectorEntry(fieldName,
					function():String { return _object[fieldName]; })
				);
			}
			else if (access == ACCESS_READ_WRITE)
			{
				addEntry(new TextInputInspectorEntry(fieldName,
					function():String { return _object[fieldName]; },
					function(value:String):void { _object[fieldName] = value; })
				);
			}
			else
			{
				trace("Unsupported access for field '"+ fieldName +"': " + access);
			}
		}

		private function addBlendModeEntry(fieldName:String, access:String):void
		{
			if (access == ACCESS_READ_ONLY)
			{
				addEntry(new BlendModeInspectorEntry(fieldName,
					function():String { return _object[fieldName]; })
				);
			}
			else if (access == ACCESS_READ_WRITE)
			{
				addEntry(new BlendModeInspectorEntry(fieldName,
					function():String { return _object[fieldName]; },
					function(value:String):void { _object[fieldName] = value; })
				);
			}
			else
			{
				trace("Unsupported access for field '"+ fieldName +"': " + access);
			}
		}

		private function addTextureSmoothingEntry(fieldName:String, access:String):void
		{
			if (access == ACCESS_READ_ONLY)
			{
				addEntry(new TextureSmoothingInspectorEntry(fieldName,
					function():String { return _object[fieldName]; })
				);
			}
			else if (access == ACCESS_READ_WRITE)
			{
				addEntry(new TextureSmoothingInspectorEntry(fieldName,
					function():String { return _object[fieldName]; },
					function(value:String):void { _object[fieldName] = value; })
				);
			}
			else
			{
				trace("Unsupported access for field '"+ fieldName +"': " + access);
			}
		}

		private function addTextureEntry(fieldName:String, access:String):void
		{
			if (access == ACCESS_READ_ONLY)
			{
				addEntry(new TextureInspectorEntry(fieldName, null,
					function():Texture { return _object[fieldName]; },
					null,
					false)
				);
			}
			else if (access == ACCESS_READ_WRITE)
			{
				addEntry(new TextureInspectorEntry(fieldName, null,
					function():Texture { return _object[fieldName]; },
					function(value:Texture):void { _object[fieldName] = value; },
					false)
				);
			}
			else
			{
				trace("Unsupported access for field '"+ fieldName +"': " + access);
			}
		}

		private function addObjectReferenceEntry(fieldName:String, access:String):void
		{
			addEntry(new ObjectReferenceInspectorEntry(fieldName,
				function():Object { return _object[fieldName]; },
				function():void
				{
					if (_object[fieldName] != null)
						ObjectInspectorPanel.instance.inspect(_object[fieldName], false, true);
				})
			);
		}

		private function addObjectReferenceEntryFromObject(title:String, object:Object):void
		{
			addEntry(new ObjectReferenceInspectorEntry(title,
				function():Object { return object; },
				function():void
				{
					if (object != null)
						ObjectInspectorPanel.instance.inspect(object, false, true);
				})
			);
		}

		private function addColorEntry(fieldName:String, access:String):void
		{
			if (access == ACCESS_READ_ONLY)
			{
				addEntry(new ColorInspectorEntry(fieldName,
					function():uint { return _object[fieldName]; },
					null)
				);
			}
			else if (access == ACCESS_READ_WRITE)
			{
				addEntry(new ColorInspectorEntry(fieldName,
					function():uint { return _object[fieldName]; },
					function(value:uint):void { _object[fieldName] = value; })
				);
			}
			else
			{
				trace("Unsupported access for field '"+ fieldName +"': " + access);
			}
		}

		//----------------------------------------------------------------------
		//-- Events handlers
		//----------------------------------------------------------------------

		override protected function onAddedToStage(e:Event):void
		{
			super.onAddedToStage(e);

			Starling.juggler.add(this);

			_backButton.addEventListener(Event.TRIGGERED, onBackButtonTriggered);
		}

		override protected function onRemovedFromStage(e:Event):void
		{
			super.onRemovedFromStage(e);

			Starling.juggler.remove(this);

			_backButton.removeEventListener(Event.TRIGGERED, onBackButtonTriggered);
		}

		private function onBackButtonTriggered(event:Event):void
		{
			if (_objectStack.length > 0)
			{
				inspect(_objectStack.pop(), false, false);
				refreshBackButton();
			}
		}

		//----------------------------------------------------------------------
		//-- Inspection overlay for Display Object
		//----------------------------------------------------------------------

		private function updateInspectionOverlay():void
		{
			if (!_object)
				return;

			if (!(_object is DisplayObject))
				return;

			// find the bounds in the root layer space
			var displayObject:DisplayObject = _object as DisplayObject;

			// handle display object not added to the stage
			if (!displayObject.stage)
				return;

			// instantiate bounds indicator
			if (!_boundsIndicator)
			{
				_boundsIndicator = new BorderedRectangle(1, 1,
				                                         InspectorConfiguration.INSPECTED_OBJECT_BOUNDS_BODY_COLOR,
				                                         InspectorConfiguration.INSPECTED_OBJECT_BOUNDS_BORDER_SIZE,
				                                         InspectorConfiguration.INSPECTED_OBJECT_BOUNDS_BORDER_COLOR);
				_boundsIndicator.touchable = false;
				_boundsIndicator.bodyAlpha = InspectorConfiguration.INSPECTED_OBJECT_BOUNDS_BODY_ALPHA;
				_boundsIndicator.borderAlpha = InspectorConfiguration.INSPECTED_OBJECT_BOUNDS_BORDER_ALPHA;
			}

			try
			{
				displayObject.getBounds(InspectorConfiguration.ROOT_LAYER, _objectBounds);
				_boundsIndicator.x = _objectBounds.x;
				_boundsIndicator.y = _objectBounds.y;
				_boundsIndicator.width = _objectBounds.width;
				_boundsIndicator.height = _objectBounds.height;
			}
			catch (error:Error)
			{
				trace("Failed to setup the inspection overlay.");
				return;
			}

			// add the bound indicator in the root layer
			InspectorConfiguration.ROOT_LAYER.addChild(_boundsIndicator);
		}

		public function advanceTime(time:Number):void
		{
			if (!_object)
				return;

			if (!(_object is DisplayObject))
				return;

			updateInspectionOverlay();
		}
	}
}