# SimpleUnzipper

Unzip unencrypted (no password), non-zip64 (large than 4GB) files, written in Swift. It's driven by a private (currently) EPUB parser project, since EPUB is simply a zip file.

## Installation

`SimpleUnzipper` is encapsulated as a Framework. Drag `SimpleUnzipper.xcodeproj` into your project, add `libz.dylib` and `SimpleUnzipper` to “Linked Frameworks and Libraries” under “General” tab of target settings. The most important step, don't fprget to add correct path which contains `SimpleUnzipper` to target's `Build Settings` -> `Swift Compiler - Search Paths` -> `Import Paths`. As below shows, `SimpleUnzipper` is on the same directory as the target project.

![Build Settings Example](bsettings.png)

If you add `SimpleUnzipper` inside your project dirctory, the `Import Path` should be `$(SRCROOT)/SimpleUnzipper`


## Example

SimpleUnzipper is very simple as its name, contains only a few public properties and methods.

<pre>
import SimpleUnzipper
...
// create an unzipper with file URL or data
if let unzipper = <b>SimpleUnzipper.createWithURL(url)</b> {
  // or SimpleUnzipper.<b>createWithData(data)</b>
  
  // get all file names, including paths if available
  let files = unzipper.<b>files</b>
  
  // check if a file available
  let isAvailable = unzipper.<b>containsFile("path/to/file.ext")</b>
  
  // get data from a file
  let data = unzipper.<b>dataForFile("path/to/file.ext")</b>
  
}
</pre>
		
## Creator

* GitHub: <https://github.com/cxa>
* Twitter: [@_cxa](https://twitter.com/_cxa)
* Apps available in App Store: <http://lazyapps.com>

## Credits

Test examle file `test.epub` is downloaded from <https://code.google.com/p/epub-samples/>


## License

Under the MIT license. See the LICENSE file for more information.