# StringTemplate

Quickly and easily apply a template to a target string.

This library allows you to create light-weight templates and then arbitrarily
apply them to string instances. You can also pass options that will let you
customize the strictness with which a template is applied.

## Usage

```swift
// Create a template:
let nanpPhoneNumber = String.Template(
  placeholderToken: "X",
  template: "(XXX) XXX-XXXX"
)

// And apply it:
let formatted = try? "5125550001".applying(template: nanpPhoneNumber)
print(formatted) // Optional("(512) 555-0001")

// Allow for partial application:
let partial = try? "512555".applying(template: nanpPhoneNumber, options: [.allowPartial])
print(partial) // Optional("(512) 555-")

// Allow for overflow application:
let overflow = try? "5125550001111111111".applying(template: nanpPhoneNumber, options: [.allowOverflow])
print(overflow) // Optional("(512) 555-0001")

// Mutate the string directly:
var str = "5125550001"
try? str.apply(template: nanpPhoneNumber)
print(str) // "(512) 555-0001"
```

See [the tests] for more examples.

[the tests]: Tests/StringTemplateTests.swift

## Installation

### [Swift Package Manager]

[Swift Package Manager]: https://swift.org/package-manager/

Add this project as a dependency in your `Package.swift` file:

```swift
dependencies: [
  .package(url: "https://github.com/square/StringTemplate.git", .from("1.0.0")),
]
```

### [Carthage]

[Carthage]: https://github.com/Carthage/Carthage

Add the following to your Cartfile:

```
github "square/StringTemplate"
```

Then run `carthage update`.

Follow the current instructions in [Carthage's README][carthage-installation]
for up to date installation instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

### [CocoaPods]

[CocoaPods]: http://cocoapods.org

Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```ruby
pod 'StringTemplate'
```

You will also need to make sure you're opting into using frameworks:

```ruby
use_frameworks!
```

Then run `pod install` with CocoaPods 0.36 or newer.

### Git Submodules

I guess you could do it this way if that's your thing.

Add this repo as a submodule, and add the project file to your workspace. You
can then link against `StringTemplate.framework` for your application target.

[Runes]: https://github.com/thoughtbot/Runes

## Contributing

We love our
[contributors](https://github.com/square/StringTemplate/graphs/contributors)!
Please read our [contributing guidelines](Contributing.md) prior to submitting
a pull request.

License
-------

    Copyright 2017 Square, Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
