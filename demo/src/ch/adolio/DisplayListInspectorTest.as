// =================================================================================================
//
//	Starling Inspector
//	Copyright (c) 2023 Aurelien Da Campo (Adolio), All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package ch.adolio
{
	import ch.adolio.display.ui.inspector.InspectorConfiguration;
	import ch.adolio.display.ui.inspector.panel.DisplayListInspectorPanel;
	import ch.adolio.display.ui.inspector.panel.ObjectInspectorPanel;
	import ch.adolio.utils.InspectionUtils;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.FilterChain;
	import starling.filters.GlowFilter;
	import starling.text.TextField;
	import starling.textures.Texture;

	public class DisplayListInspectorTest extends Sprite
	{
		private var _displayListInspectorPanel:DisplayListInspectorPanel;
		private var _scene:Sprite;
		private var _inspectorLayer:Sprite;
		private var _bird:Image;

		[Embed(source="../../../media/textures/starling-flying.png")] private static const AlbedoTexture:Class;

		public function DisplayListInspectorTest()
		{
			setupScene();
			setupInspection();

			// inspect the bird at startup
			_displayListInspectorPanel.selectObject(_bird);
			ObjectInspectorPanel.instance.object = _bird; // this line is needed only because the display list inspector events listener are not yet registered

			// register to events
			Starling.current.stage.addEventListener(TouchEvent.TOUCH, onTouch);
		}

		private function setupScene():void
		{
			// create scene root object
			_scene = new Sprite();
			addChild(_scene);

			// create a red quad
			var redQuad:Quad = new Quad(100, 100, 0xff0000);
			redQuad.name = "A red quad";
			redQuad.x = 400;
			redQuad.y = 100;
			_scene.addChild(redQuad);

			// create a blue quad
			var blueQuad:Quad = new Quad(80, 80, 0x0000ff);
			blueQuad.name = "A blue quad";
			blueQuad.x = 450;
			blueQuad.y = 180;
			_scene.addChild(blueQuad);

			// create a label
			var label:TextField = new TextField(200, 50);
			label.text = "Hello World!";
			label.x = 500;
			label.y = 50;
			_scene.addChild(label);

			// create a bird
			var starlingTexture:Texture = Texture.fromEmbeddedAsset(AlbedoTexture, false, false, 1, "bgra", true);
			_bird = new Image(starlingTexture);
			_bird.name = "A lovely bird";
			_bird.x = 500;
			_bird.y = 200;
			_scene.addChild(_bird);

			// add sticker style filter
			var filterChain:FilterChain = new FilterChain();
			filterChain.addFilter(new GlowFilter(0xffffff, 10.0, 1.0, 1.0));
			filterChain.addFilter(new GlowFilter(0x000000, 1.0, 1.0, 1.0));
			_bird.filter = filterChain;
		}

		private function setupInspection():void
		{
			// create inspection layer
			_inspectorLayer = new Sprite();
			addChild(_inspectorLayer);

			// setup inspector
			InspectorConfiguration.ROOT_LAYER = _inspectorLayer;
			InspectorConfiguration.COLOR_PANEL_HEADER_BACKGROUND_COLOR = 0xdddddd;

			// create display list inspector
			_displayListInspectorPanel = new DisplayListInspectorPanel(_scene, true);
			_displayListInspectorPanel.ignoreList.push(_displayListInspectorPanel, ObjectInspectorPanel.instance);
			_displayListInspectorPanel.height = Starling.current.nativeStage.stageHeight;
			_inspectorLayer.addChild(_displayListInspectorPanel);

			// setup the object inspector
			ObjectInspectorPanel.instance.height = Starling.current.nativeStage.stageHeight;
			ObjectInspectorPanel.instance.x = Starling.current.nativeStage.stageWidth - ObjectInspectorPanel.instance.width;
		}

		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.touches[0];
			if (!touch)
				return;

			if (touch.phase != TouchPhase.BEGAN)
				return;

			// ignore inspectors layer and already selected object
			if (!InspectionUtils.isChildOf(_inspectorLayer, touch.target) && ObjectInspectorPanel.instance.object != touch.target)
			{
				if (_displayListInspectorPanel.parent)
					_displayListInspectorPanel.selectObject(touch.target);
				else
					ObjectInspectorPanel.instance.object = touch.target;
			}
		}
	}
}