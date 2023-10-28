// =================================================================================================
//
//	Starling Inspector
//	Copyright (c) 2023 Aurelien Da Campo (Adolio), All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package ch.adolio.display.ui.inspector
{
	import ch.adolio.display.ui.inspector.panel.InspectorPanel;

	public interface IInspectable
	{
		function getInspector():InspectorPanel;
	}
}