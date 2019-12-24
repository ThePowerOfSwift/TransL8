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

# Logfile

## Keyboard Extension

Providing a [novel text input](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html) in the context of a translator seems natural at first but does not easily apply to a "tranlation service" where there is a `source text -> translate -> destination text` flow. But what about a simple "Translate" button for converting the "current text"?

Sadly the available API is severely limited and broken (as of iOS 13.2, look into the `feature/keyboard-extension` branch): with the `UITextDocumentProxy` you can access the "current text" in two ways:

- by means of the before/after strings around the cursor, but that is limited to the current paragraph only. Furthermore changing the text with that approach leads to multiple weird calls to let UIKit update the text view in between.

- by means of the selected text only. That is probably the right user interaction and simplifies the action calls, but has a severe error: once the selections spans over three or more paragraphs, the inner paragraphs are dropped from the selection text and cannot be retrieved - the selected text contains the start cursor part from the first paragraph and the end cursor part from the last paragraph (most likely a bug).

Sad but true, no Keyboard extension...

## Action Extension

As per definition, [Actions should transform/convert the given content](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/Action.html) - which makes perfect sense for a translator. So a meaningful user flow is to translate a given text and serve the result back - which is what the `TransL8 in Action` extension does.

Surprisingly sending back the result is ignored by most originating apps although the iOS SDK has a callback for this (`completionWithItemsHandler` on `UIActivityViewController`). As a first tweak TransL8 will copy the translation to the system clipboard automatically and second it extends its clipboard feature to a history of translations (to be reviewed later at any time).

This extension was fun is is probably the most meaningful extension for a translator.

## Share Extension

Although sharing is more considered of a one-way flow to [send content to other services](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/Share.html) and hence the flow and intention is very different compraed an Action Extension, both extension share the same API! So we could reuse exactly the same UI and UX - but that would be a poor design choice.

Given the default `SLComposeServiceViewController` design and sharing being considered a fast, one-directional path, TransL8 will use the Share Extension as a means to populate the clipboard history with the input text - but will not translate it directly.

Admittedly this conservative feature is driven by the paid service we're using and may change later (with an `auto-translate` preference switch)

# Contact

Oliver Michalak - [oliver@werk01.de](mailto:oliver@werk01.de) - [@omichde](http://twitter.com/omichde)

## License

TransL8 is available under the MIT license
