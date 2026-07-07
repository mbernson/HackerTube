# HackerTube

<img width="128" height="128" align="right" alt="HackerTube icon" src="https://github.com/user-attachments/assets/9415d24b-9554-4045-b60a-ed86e6c79cd2" />

HackerTube is an app for watching the talks and activities of the Chaos Computer Club and related conferences on tvOS (Apple TV), iOS and macOS. It is a client that uses the public REST API of [media.ccc.de](https://media.ccc.de/). It is free software (GPL licensed) and is not officially affiliated with the CCC.

I've created it because of my personal desire to watch Chaos Event talks on my Apple TV. At that time, there was no such app available on the tvOS App Store. The project goal is to create the best native viewing experience on Apple platforms.

HackerTube respects your privacy. It does not use tracking, analytics or "cookies" of any kind. The network requests it makes are solely for the purposes of calling the [media.ccc.de](https://media.ccc.de/) public API and to stream the actual videos.

## Where to get it?

* 🍏 [Download on the App Store](https://apps.apple.com/us/app/ccc-tube/id1637341762)
* ✈️ [Join the public beta on TestFlight](https://testflight.apple.com/join/44XL86pK)
* 🐙 Or you can build and run the code yourself.

## Screenshots

### Apple TV

<img width="640" alt="Screenshot 2024-01-05 at 13 55 36 Large" src="https://github.com/mbernson/CCCTube/assets/477710/a966967b-69d6-4fda-8bc6-9e20f6650166">


### iPhone

<img width="335" alt="Screenshot 2024-01-05 at 13 55 51 Large" src="https://github.com/mbernson/CCCTube/assets/477710/75763340-48f4-4044-97b0-1abfb6f46a02">


### iPad

<img width="640" alt="Screenshot 2024-01-05 at 13 56 45 Large" src="https://github.com/mbernson/CCCTube/assets/477710/84c9ffeb-aad5-46ec-af60-0f39cdf07a6d">

## About

### English

HackerTube is an app for watching the talks and activities of the Chaos Computer Club. It is not officially affiliated with the CCC.

The Chaos Computer Club is Europe's largest hacker community and allows people with a wide range of interests from all over the world to meet up and discuss various topics. The club generally meets in small groups/get-togethers, but also hosts large conferences. Here they tinker, talk and exchange ideas. Technical barriers are overcome, new things created and old ones taken apart. Discussions range from technological to political and social topics, with a focus on communication and exchange of ideas and information.

For over fifteen years, the Chaos Computer Club has created videos to document the many talks and activities, many of which are available via various platforms. The HackerTube app now allows users to comfortably access this video material via their Apple TV and provides an insight into the club's activities.

Just relax on your couch, select the HackerTube app and immerse yourself in the wonderful world of the Chaos Computer Club!

### German

HackerTube ist eine App zum Ansehen der Vorträge und Aktivitäten des Chaos Computer Clubs. Sie ist nicht offiziell mit dem CCC verbunden.

Der Chaos Computer Club ist Europas größte Hackervereinigung und ein Treffpunkt für vielfältig interessierte Menschen aus der ganzen Welt. Man trifft sich vor Allem auf kleinen Events, aber auch auf großen Konferenzen. Es wird gebastelt, ausprobiert und getüftelt. Technische Hürden werden beseitigt, Neues gebaut und Altes zerlegt. Es wird diskutiert und politisiert. Bei allen Aktivitäten stehen jedoch Kommunikation und Austausch im Vordergrund.

Seit vielen Jahren kreiert der Chaos Computer Club Videos, die viele der Vorträge und Aktivitäten dokumentieren. Natürlich sind diese Videos auch über verschiedene Wege abrufbar. Mit der App HackerTube ist der Video-Content des Chaos Computer Clubs nun auf bequeme Art und Weise auf Apple-Geräten verfügbar. Diese einfach zu bedienende App macht die Aktivitäten de Clubs einer breiteren Öffentlichkeit verfügbar.

Einfach aufs Sofa setzen, HackerTube auswählen und in die wunderbar vielfältige Welt des Chaos Computer Club eintauchen!

### Dutch

HackerTube is een app waarmee de lezingen en activiteiten van de Chaos Computer Club kunnen worden bekeken. Het is niet officieel verbonden met de CCC.

De "Chaos Computer Club" is Europaʼs grootste hacker gemeenschap en een platform voor mensen uit de hele wereld met zeer gevarieerde interesses om zeer uiteenlopende onderwerpen te bespreken. Zij ontmoeten elkaar in kleine groepen of bijeenkomsten, maar ook op grote conferenties. Hier wordt geknutseld, geëxperimenteerd en worden ideeën uitgewisseld. Technische barrières worden geslecht, nieuwe gebieden ontgonnen en oude ideeën ontmanteld. Er wordt gesproken en gedebatteerd over zowel technische als politieke en sociale onderwerpen, waarbij communicatie en uitwisseling van ideeën en informatie altijd centraal blijven staan.

Sinds vele jaren maakt de Chaos Computer Club videos, die de vele gesprekken en activiteiten van de club vastleggen. Deze videoʼs zijn uiteraard voor iedereen toegankelijk gemaakt via verschillende kanalen en platforms. Met de HackerTube app is de video-inhoud van de Chaos Computer Club nu gemakkelijk op de Apple TV te bekijken en worden de activiteiten van de club aan een breder publiek beschikbaar gesteld.

Gewoon lekker gaan zitten, HackerTube selecteren, en duik in de wonderbaarlijk diverse wereld van de Chaos Computer Club!

## Development

This app is written in Swift and SwiftUI. It tries to stay close to the native conventions, using native user interface elements in order to fit in on the Apple platforms that the app supports.
It uses the native video player, which supports behaviours such as picture-in-picture out of the box. On tvOS, it supports a top shelf extension. Etcetera.

The app is localized to English, German and Dutch.

### Code formatting

Apple's `swift-format` is used for linting and formatting the source code.
You can run it using the following commands:

```
# Lint
xcrun swift-format lint -r .
# Format all files
xcrun swift-format format -i -r .
```

## Libraries

HackerTube tries to use as few third party libraries as possible, in order to keep the project lean, maintainable and fun to work on.
It uses the following free / open source libraries:

* [NanoSVG](https://github.com/memononen/nanosvg): To render the conference thumbnails, some of which are given as SVG files.

## License

As all other C3VOC tools, this software is distributed under the GPL v3. See the `LICENSE.txt` file.

## Acknowledgements

* [Voctocat logo by Blinry](https://blinry.org/voctocat/), [CC BY-SA 4.0](https://blinry.org/about/#license): Used in the app icon.

## Contributors

* Mathijs Bernson
