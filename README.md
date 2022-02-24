<!-- LTeX: language=en-US -->

# Aseprite Helper

Godot 4 Import Plugins for Aseprite

## Plugins
- Aseprite Helper Texture
	- import the **Aseprite file** as a **Texture2D**
	- animations are saved as a single image
- Aseprite Helper Animation
	- import the **Aseprite file** as a **PackedScene**
	- **root node** is a **Sprite2D** with the image data
		- right-click **root node** and check **editable children** to see hidden children
	- **children**
		- **AnimationPlayer** with a **Track** for every animation

## Tested
- Godot 4 Alpha 3 for Windows
- Linux or macOS are not tested
	- please create an issue if you encounter a problem

## Installation
- Install Plugins
	- [Official Guide](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html)
- Make **Aseprite** available (one of the following)
	- Install in default location
		- Aseprite default location or Steam (C:)
	- Change **ProjectSettings/Editor/Import/Aseprite Path** to the location of your **Aseprite Executable**
		- Activate **Advanced Settings** to see the setting
	- Add to system path
