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
- Action extension (done, simplified translation interface)
- Share extension (done, direct and fast flow)
- Today Extension/Widget (unsure)
- serve as a Document provider extension (open)
- Siri intents (open)
- x-url-mechanics (open)
- drag&drop support on iPads (open)
- Catalyst support (open)

## General client server observations

Thanks to [Moya](https://github.com/Moya/Moya) most REST APIs are simple to use nowadays. The only stumbling block for a mobile client is authentication (and pricing for the service). So let's discuss pricing first:

- this project is mostly for fun, but putting it into the store with my API key hardcoded would put my pockets under pressure. Having no idea about the success of the app on the long run an upfront price would not work as well. So as a first step I hand over the pricing to the user by letting them create a DeepL Pro account and let the user enter *their* API key. Maybe I experiment with consumables or a subscription but that distracts me too much from the core product...

- sadly DeepL has no oauth, so the UX for the user is as ugly as manually copying the API key into the app (sorry). There is a onboarding feature in TransL8 to login and help grabbing the API key but I wish it would not be needed.

## new SDKs

For quite some time, Apple is extending Foundation and UIKit with powerful siblings for which AR and ML are only two fancy packages: with (VisionKit)[https://developer.apple.com/documentation/visionkit] you can take photos and OCR the text inside for free - no need to integrate Tesseract or integrate other proprietary verndors SDKs anymore! And with [Speech](https://developer.apple.com/documentation/speech) you can transcribe spoken words into text - complete speech-to-text for free!

## Keyboard Extension

Providing a [novel text input](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html) in the context of a translator seems natural at first but does not easily apply to a "tranlation service" where there is a `source -> translate -> destination` flow. But what about a simple "Translate" button for converting the "current text"?

Sadly the available API for keyboard extensions is severely limited and broken (as of iOS 13.2, look into the `feature/keyboard-extension` branch): with the `UITextDocumentProxy` you can access the "current text" in two ways:

- by means of the before/after strings around the cursor, but that is limited to the current paragraph only. Furthermore changing the text with that approach leads to multiple weird calls to let UIKit update the text view in between.

- by means of the selected text only. That is probably the right user interaction and simplifies the action calls, but has a severe error: once the selections spans over three or more paragraphs, the inner paragraphs are dropped from the selection text and cannot be retrieved - the selected text contains the start cursor part from the first paragraph and the end cursor part from the last paragraph (most likely a bug).

Sad but true, no Keyboard extension...

## Action Extension

As per definition, [Actions should transform/convert the given content](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/Action.html) - which makes perfect sense for a translator. So a meaningful user flow is to translate a given text and serve the result back - which is what the `TransL8 in Action` extension does.

Surprisingly sending back the result is ignored by most originating apps although the iOS SDK has a callback for this (`completionWithItemsHandler` on `UIActivityViewController`). As a first tweak TransL8 will copy the translation to the system clipboard automatically and second it extends its internal clipboard feature to a history of translations (to be reviewed later at any time).

This extension was fun is is probably the most meaningful extension for a translator.

## Share Extension

Although sharing is more considered of a one-way flow to [send content to other services](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/Share.html) and hence the flow and intention is very different compraed an Action Extension, both extension share the same API! So one *could* reuse exactly the same UI and UX - but that would be a poor design choice.

Given the default `SLComposeServiceViewController` design and sharing being considered a fast, one-directional path, TransL8 will use the Share Extension as a means to be the fastest tranlation roundtrip: it first translates the input text, second it stores this pair to its internal clipboard history and lastly copies it to the clipboard.

Took quite some consideration to streamline the flow this far but I think it's worth it.

## Today Extension/Widget

Given the API limitations I can hardly imagine any useful feature set for a TransL8 widget. It could serve as a fast entry point into the app (was originally forbidden but is commonly used nowadays), offer single line translations (not sure about wether it can accept keyboard input) or access to the clipboard history - not convincing. Then I though about camera or voice translation but even Shazam is deep linking into the main app to do so - API limitations fight back hard! I guess I'll drop it for now...

## File Provider Extension

There could be some value in offering translations as texts to other apps - up to 100 translations are stored in the app history already, why not open them up for easier text import. This extension creates ad-hoc files if the `UIDocumentBrowser` requests it. At the moment any changes to these files are ignored. The content is provided by means of a formatted text with the source (language and text) first and destination (lang and text) last.

Implementation is straight forward once you understand the connected parts. The simplicity mostly derived from using standard `FileProvider` components, a non-network-based approach, supporting simple read operation only and good [sample code](https://www.raywenderlich.com/697468-ios-file-provider-extension-tutorial)!

As a developer I could go further:

- adding [context menu actions](https://developer.apple.com/documentation/fileproviderUI) to the given file icons

- a custom [Document Picker View Controller](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/FileProvider.html) which in the context of TransL8 could very much use the given `Clipboard History` view controller

- put these text files into iCloud via `UIDocument` suport

While tinkering with this extension, I thought it might be interesting to open up documents as another input method within TransL8... let's see

# Contact

Oliver Michalak - [oliver@werk01.de](mailto:oliver@werk01.de) - [@omichde](http://twitter.com/omichde)

## License

TransL8 is available under the MIT license
