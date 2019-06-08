# Piz

The simplest unzipper just works.

```swift
import Piz
...
// create an unzipper with file URL or data
if let piz = Piz(fileURL: url) { // or let piz = Piz(data: data)
  // get all file names, including paths if available
  let files = piz.files

  // check if a file available
  let isFileExisting = piz.containsFile("path/to/file.ext")

  // get data from a file
  let data = piz.dataForFile("path/to/file.ext")
  
  // or if you like subscription
  let data = piz["path/to/file.ext"]
}
```

## Install

Swift package only, add this repo URL to your `Package.swift`.

## About Me

- Twitter: [@_cxa](https://twitter.com/_cxa)
- Apps available in App Store: <http://lazyapps.com>
- PayPal: xianan.chen+paypal 📧 gmail.com, buy me a cup of coffee if you find it's useful for you.

## Credits

- Test file `test.epub` is downloaded from <https://code.google.com/p/epub-samples/>
- Test zip64 file `64.zip` created with [https://gist.github.com/gumblex/5573ddb33c21fca4aecf]().

## License

Under the MIT license. See the LICENSE file for more information. For non attributed commercial license, please contact me.
