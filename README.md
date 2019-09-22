# Piz

The simplest unzipper just works.

```swift
import Piz
...
// create an unzipper with file URL or data
if let piz = Piz(fileURL: url) { // or let piz = Piz(data: data)
  // get all file names, including paths if available
  let files = piz.files

  // check if a file be available
  let isFileExisting = piz.contains(file: "path/to/file.ext")

  // get data from a file
  let data = piz.data(forFile: "path/to/file.ext")

  // or if you like subscription
  let data = piz["path/to/file.ext"]
}
```

## Install

Swift package only, add this repo URL to your `Package.swift`.

## About Me

- Twitter: [@_cxa](https://twitter.com/_cxa)
- Apps available on the App Store: <http://lazyapps.com>
- PayPal: xianan.chen+paypal 📧 gmail.com, buy me a cup of coffee if you find it's useful for you

## Credits

- Test file `test.epub` downloaded from <https://code.google.com/p/epub-samples/>
- Test zip64 file `64.zip` created with <https://gist.github.com/gumblex/5573ddb33c21fca4aecf>

## License

MIT
