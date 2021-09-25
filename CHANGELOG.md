# CHANGELOG

A compilation of changes for each release.

## r5

Lonely Paddle enters the fray!

Bub on the Run:

- Display "GAME OVER" for title text

Bullet Heck:

- Update description

Hearts:

- sfx on input & larger title

Lonely Paddle:

- Add music & tune gameplay
- Add emitter on buddy & star death
- Don't revive star until done flickering
- add score & high-score tracking
- Add buddies for collecting
- Increase player/paddle vel
- spawn ball on star collection
- Iterate on paddle sprite & star placement logic
- Add star
- Add initial basic game

Global:

- rename selectedGame to focusedGame in MenuState
- Rework game definition
- InputManager->Input & switch to static functions
- remove BaseState#addText in favor of MimeoText instantiation
- Render game at 4x resolution
- Update mono bitmap font to support color adjustments
- Create CHANGELOG

## r4

Bub on the Run:

- Fix high-score text display

## r3

Date: 2021-09-22

Global:

- Display global FPS
- Make Main.hx a unix ff

Bub on the Run:

- Add parallax bg
- Play sound on restart
- Display game over details
- increase camera height
- Add obstacles on top of the ground
- Add crash sfx
- Add dead frame & make use of it
- Rename Runny to BubOnTheRun throughout the codebase

## r2

Date: 2021-09-21

Bub on the Run bug fixes & adjustments.

## r1

Date: 2021-09-21

Initial release for Itch for friends.

Includes the following playable (but not finished) prototypes:

- Slither
- Quick Draw
- Hearts / Cutscene Prototype
- Runny / Bub on the Run
- Spacevania -- extremely basic
- Bullet Heck -- extremely basic
