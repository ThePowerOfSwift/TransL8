# TransL8

Simple iOS client for translating via [DeepL](https://www.deepl.com).

## Idea

I've enjoyed and used the great translation service from [DeepL](https://www.deepl.com) a lot recently but could not find a simple yet deeply integrated mobile app for it. Hence this project was born:

- provide a straight forward mobile client to the [DeepL](https://www.deepl.com) translation service
- use multiple text input methods of recent iOS SDKs (clipboard, OCR via camera, voice via microphone)
- serve translated text via various outputs (clipboard, text sharing, voice)

## Installation

You need Xcode 11 and iOS 13 to build and run this app. Furthermore a paid [DeepL Pro Account with API access](https://www.deepl.com/pro-account.html) is needed for the translation - it's worth it but I earn no money out of that promotion!

## Features

Apart from the core translation, I want to explore a deep system integration:

- Keyboard extension (nope, see below)
- Action extension (done, basically mimics the translation interface and serves the result back)
- Share extension (open)
- Widget (open)
- Siri intents (open)
- serve clipboard history as a Document provider extension (open)
- x-url-mechanics (open)
- drag&drop support on iPads (open)
- Catalyst support (open)

## Blockers

The *Keyboard extension* was tested but the API is severely limited and broken at the same time (as of iOS 13.2, look into the `feature/keyboard-extension` branch): with the `UITextDocumentProxy` you can access the current text in two ways:

- by means of the before/after string around the cursor, but that is limited to the current paragraph only (probably for "security reasons"). Adjusting text with that approach leads to weird calls to let UIKit update the text view in between.

- by means of the selected text only. That is probably the right user interaction and simplifies the action calls, but has a severe error: once the selections spans over three or more paragraphs, the inner paragraphs are dropped from the selection and cannot be retrieved - the selected text contains the start cursor part from the first paragraph and the end cursor part from the last paragraph (most likely a bug).

Sad but true, no Keyboard extension...
