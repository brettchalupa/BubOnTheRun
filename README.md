# Bub on the Run

Simple infinite runner

The game is built using [HaxeFlixel](https://haxeflixel.com).

## Developing

### Install Dependencies

1. Install Haxe (4.2.3) - https://haxe.org/download/, `brew install haxe` on MacOS
2. Install the project dependencies - `haxelib install dependencies.hxml`
3. Run the following setup commands:

```
haxelib run lime setup flixel
haxelib run lime setup
haxelib run flixel-tools setup
```

### Testing

Test the game quickly on the Neko VM with `lime test neko -debug`

Update assets with `lime update neko`

A note about test targets:

- Neko: VM that builds pretty quickly, similar to desktop
- HTML5: Web target that plays kinda meh but quick to build
- Mac/Windows/Linux: Slow to build but useful for testing

### Building

Build the game for playing with: `lime build TARGET -final -clean`
