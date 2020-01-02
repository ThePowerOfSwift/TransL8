# TransL8

I've enjoyed and used the great translation service from [DeepL](https://www.deepl.com) a lot recently but could not find a simple yet deeply integrated mobile app for it. Hence this project was born:

- provide a straight forward mobile client to the [DeepL](https://www.deepl.com) translation service
- use multiple text input methods of recent iOS SDKs (clipboard, OCR via camera, voice via microphone)
- serve translated text via various outputs (clipboard, text sharing, voice)

## Installation

You need Xcode 11 and iOS 13 to build and run this app. Furthermore a paid [DeepL Pro Account with API access](https://www.deepl.com/pro-account.html) is needed for the translation - it's worth it but I earn no money out of that promotion!

# Features

For quite some time, Apple is extending Foundation and UIKit with powerful siblings - like Vision for higher level image processing, Speech for voice recognition and the fancy ML- and AR-frameworks. With TransL8 I want to explore these new APIs alongside a deep system integration:

- [system extensions](#system-extensions)
- [OCR via VisionKit](#ocr-via-visionkit)
- [Speech Recognition](#speech-recognition)
- [Diffable Data Source](#diffable-data-source)
- [Context Menus](#context-menus)
- using [SF Symbols](https://developer.apple.com/design/human-interface-guidelines/sf-symbols/overview/) - me likes [IconFonts](https://github.com/omichde/BOMFeedback/blob/master/BOMFeedback/Feedback/Feedback-Regular.otf) anyway
- [Property Wrapper](#property-wrapper)
- [Catalyst](#catalyst) = open
- drag&drop support on iPads = open
- x-url-mechanics = open

## iPad and iOS support

The UI is bascially driven by functional needs (and I am no designer anyway), but let me explain some UI and UX considerations:

![iPhone](Screenshots/screen-main-phone.png?raw=true)

![iPad](Screenshots/screen-main-tablet.png?raw=true)

- text is the main content of this app, hence there are two large text views alongside smaller action items
- although comparing translations is sometimes valuable I do not consider it the main use case especially not on mobile, hence the two languages of a text (source and destination) are overlapping, featuring a "layered" approach in the UI
- this layered UI gives a chance to focus/defocus 1st level and 2nd level action icons as well
- sadly the global "translate action button" moved into the lower-left corner
- accessibility should work but untested (as much as RTL)
- dark mode support (due to system components only atm)

## General client server observations

Thanks to [Moya](https://github.com/Moya/Moya) most REST APIs are simple to use nowadays. The only stumbling blocks for a mobile client are authentication and pricing for the service. So let's discuss pricing first:

- this project is mostly for fun, but putting it into the store with my API key hardcoded would put my pockets under pressure. Having no idea about the success of the app on the long run, an upfront price would not work as well. So as a first step I "hand over the costs" to the user by letting them create a DeepL Pro account and use *their* API key. Maybe I experiment with consumables or a subscription in the future but that distracts me too much from the fun part...

- sadly DeepL has no oauth, so the UX for the user is as ugly as manually copying the API key into the app from the website (sorry). There is a onboarding feature in TransL8 to login and help grabbing the API key but I wish it would not be needed.

## OCR via VisionKit

With [VisionKit](https://developer.apple.com/documentation/visionkit) you can take photos and OCR the text inside for free - no need to integrate Tesseract or other proprietary vendors SDKs anymore.

- `VisionKit` provides a powerful default `VNDocumentCameraViewController` which you create, assign yourself as a delegate and present modally to the user
- the user can take pictures, selects (skewed) rectangular parts to be scanned and even supports multiple page documents
- providing a custom user flow or different OCR mechanics is possible but obviously takes way more effort to implement
- sadly the UI of this powerful component can hardly by customized nor its behaviour (and I'm missing the loupe as I miss it everywhere in iOS 13)

This feature is based on [Apples sample code](https://developer.apple.com/documentation/vision/locating_and_displaying_recognized_text_on_a_document).

## Speech Recognition

In contrast to [OCR](#ocr-via-visionKit) the [Speech](https://developer.apple.com/documentation/speech) framework offers no default UX/input component. Luckily [Apple sample code](https://developer.apple.com/documentation/speech/recognizing_speech_in_live_audio) showcases the lower level API:

- the `SFSpeechRecognizer` is the top-level manager to handle authorization
- `AVAudioEngine`, `SFSpeechAudioBufferRecognitionRequest` and `SFSpeechRecognitionTask` have to be connected for the voice data to be transcribed
- adding `AVAudioPCMBuffer` is probably the least discoverable part of that API flow for me ("happy sample code")
- thanks to [SF Symbols](https://developer.apple.com/design/human-interface-guidelines/sf-symbols/overview/) implementing a basic voice recording screen was easy but I need to spend more time on the UI and understand the lower level APIs

With my linguistic university background I was enthusiastic and scared of the amount of work to fullfill realtime speech recognition - but technology has come a long way and this feature (even if you enable on-device-only) is impressive: real time speech-to-text for free!

## Diffable Data Source

As the posterchild of the delegation pattern, `UITableViewDataSource` is known to all iOS developers. With iOS 13 UIKit provides a fresh approach to it thanks to a standard implementation called `UITableViewDiffableDataSource`. Of special note and solving a major failure point with custom data sources, multiple updates and deletes on the data are handled automatically:

- `UITableViewDiffableDataSource` is feeded by `NSDiffableDataSourceSnapshot`, each contaning different data collections at different states of your app
- as these `NSDiffableDataSourceSnapshot`s leverage the `Hashable` protocol, they can identify each entry and calculate the transition from a previous state to another state -> app developers can mostly concentrate on the data (collection) only
- surprisingly, *enabling* to delete entries needs `UITableViewDiffableDataSource` to be subclassed (as `canEditRowAt` and `commit editingStyle` still need to be present at runtime), I was hoping this venerable behaviour to be replaced by a modern (callback) mechanism

If there is a simpler way to enable "delete rows" than [this subclassing](https://github.com/omichde/TransL8/commit/6031d9e130e92869f33b284bea2d07e123843e19) please [let me know](#contact).

## Context Menus

As iOS 13 provides more context menus (and favours them instead of gestures - I'll miss the wobbling app icons) I wanted to explore the driving API `UIContextMenuInteraction`. The first implementation of the history feature was driven by it:

- the delegate of a `UIContextMenuInteraction` serves a `UIContextMenuConfiguration` which contains the list of menu entries
- each entry provides a text-icon pair alongside a callback
- menus can be nested, provide a preview and offer some fine tuning with some more delegates

Overall this is a clean and powerful API, it's simple to start with and works well for a lot of cases.

Currently the history feature does not use it anymore, because an independent table view controller offers deleting of individual rows (something you cannot do in a context menu). But maybe the target language selection will move from the preferences towards a context menu in the future...

## Property Wrapper

Being a big fan of property getters and setters for blackboxing the internals of property handling, I was intrigued by `@propertyWrapper`s. After a nice [introduction around the mechanics and syntax](https://swiftsenpai.com/swift/create-the-perfect-userdefaults-wrapper-using-property-wrapper/), it helped to make the preference handling way more readable and compact and generic at the same time (`Codable` for the rescue). As a result, TransL8 now has as property wrapper around `UserDefault` and the `keychain` by means of [KeychainSwift](https://github.com/evgenyneu/keychain-swift) - even with default values.

## Catalyst

Intrigued by this "one switch"? Me too so I've enabled it but the UX is very alien to macOS - as expected. Long journey ahead...

## System Extensions

Integrating a feature into others app live-cycle and user flows can be achieved by system extension for quite some time now. Sadly they are sometimes limited beyond the ususal app sandbox, but I wanted to dig deeper, how far these extension could go, wether the API has evolved over the years and ultimately what value they bring to the user:

- [Keyboard extension](#keyboard-extension) = nope
- [Action extension](#action-extension) = done, simplified translation interface
- [Share extension](#share-extension) = done, direct and fast flow
- [Today Extension/Widget](#today-extension) = nope
- [Document Provider Extension](#file-provider-extension) = done, leveraging `DocumentPicker` as well
- Siri intents (open)

### Keyboard Extension

Providing a [novel text input](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html) in the context of a translator seems natural at first but does not easily apply to a "tranlation service" where there is a `source -> translate -> destination` flow. But what about a simple "Translate" button for converting the "current text"?

Sadly the available API for keyboard extensions is severely limited and broken (as of iOS 13.2, look into the `feature/keyboard-extension` branch): with the `UITextDocumentProxy` you can access the "current text" in two ways:

- by means of the before/after strings around the cursor, but that is limited to the current paragraph only. Furthermore changing the text with that approach leads to multiple weird calls to let UIKit update the text view in between.

- by means of the selected text only. That is probably the right user interaction and simplifies the action calls, but has a severe error: once the selections spans over three or more paragraphs, the inner paragraphs are dropped from the selection text and cannot be retrieved - the selected text contains the start cursor part from the first paragraph and the end cursor part from the last paragraph (most likely a bug).

Sad but true, no Keyboard extension...

### Action Extension

As per definition, [Actions should transform/convert the given content](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/Action.html) - which makes perfect sense for a translator. So a meaningful user flow is to translate a given text and serve the result back - which is what the `TransL8 in Action` extension does.

Surprisingly sending back the result is ignored by most originating apps although the iOS SDK has a callback for this (`completionWithItemsHandler` on `UIActivityViewController`). As a first tweak TransL8 will copy the translation to the system clipboard automatically and second it extends its internal clipboard feature to a history of translations.

This extension was fun and is probably the most meaningful extension for a translator.

### Share Extension

Although sharing is more considered of a one-way flow to [send content to other services](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/Share.html) and hence the flow and intention is very different compared to an Action Extension, both extension share the same API! So one *could* reuse exactly the same UI and UX - but that would be a poor design choice.

Given the default `SLComposeServiceViewController` design and sharing being considered a fast, one-directional path, TransL8 will use the Share Extension as a means to be the fastest translation roundtrip: it first translates the input text, second it stores this pair to its internal history and lastly copies it to the clipboard.

Took quite some consideration to streamline the flow this far but I think it's worth it.

### Today Extension

Given the API limitations I can hardly imagine any useful feature set for a TransL8 widget. It could serve as a fast entry point into the app (was originally forbidden but is commonly used nowadays), offer single line translations (not sure about wether it can accept keyboard input) or access to the history - not convincing. Then I though about camera or speech translation but even Shazam is deep linking into the main app to do so - API limitations fight back hard! I guess I'll drop it for now...

### File Provider Extension

There could be some value in offering translations as texts to other apps - up to 100 translations are stored in the app history already, why not open them up for easier text import. This extension creates ad-hoc files if the `UIDocumentBrowser` requests it. At the moment any changes to these files are ignored. The content is provided by means of a formatted text with the source (language and text) first and destination (lang and text) last.

Implementation is straight forward once you understand the connected parts. The simplicity mostly derived from using standard `FileProvider` components, a non-network-based approach, supporting simple read operation only and good [sample code](https://www.raywenderlich.com/697468-ios-file-provider-extension-tutorial)!

As a developer I could go further:

- adding [context menu actions](https://developer.apple.com/documentation/fileproviderUI) to the given file icons

- a custom [Document Picker View Controller](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/FileProvider.html) which in the context of TransL8 could very much use the given history view controller

- put these text files into iCloud via `UIDocument` support

After exporting the translations, there should be an import into TransL8 as well: the `UIDocumentPickerViewController` is dead simple to use and imports the selected file by means of a delegate call - which then imports the data back into the source text view. This currently works on plain text files only...

# Contact

Oliver Michalak - [oliver@werk01.de](mailto:oliver@werk01.de) - [@omichde](http://twitter.com/omichde)

## License

TransL8 is available under the MIT license
