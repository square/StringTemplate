//
//  Copyright © 2018 Square, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

// MARK: -

extension String {

    // MARK: -

    /**
     An opaque reference to a template that can be applied to a `String` instance.

     The internals for this type are intentionally hidden, and shouldn't be a
     concern of the caller. You should instead use `String.apply(template:)` (or
     one of the variants) in order to use instances of this type.
     */
    public struct Template {

        // MARK: -

        public enum Error: Swift.Error {
            case tooLong
            case tooShort
        }

        // MARK: -

        /**
         Options for how to apply the template
         */
        public struct Options: OptionSet {
            public let rawValue: Int

            public init(rawValue: Int) {
                self.rawValue = rawValue
            }

            /**
             Allow partial application. If this is set, the template will only
             be applied for the available characters in the target string, and
             the remaining template placeholder characters will be dropped. Any
             formatting characters that extend beyond the length of the target
             string will still be added to the result.

             ```swift
             let template = String.Template(placeholderToken: "X", template: "XXX-XXX")
             let string = "123".applying(template: template, options: [.allowPartial])
             // string == "123-"
             ```
             */
            public static let allowPartial = Options(rawValue: 1)

            /**
             Allow overflow application. If this is set, any characters in the
             target string that extend beyond the template will be discarded.

             ```swift
             let template = String.Template(placeholderToken: "X", template: "XXX-XXX")
             let string = "12345678".applying(template: template, options: [.allowOverflow])
             // string == "123-456"
             ```
             */
            public static let allowOverflow = Options(rawValue: 2)
        }

        // MARK: - Public Properties

        public let placeholderToken: Character
        public let template: String

        // MARK: - Private Properties

        fileprivate let formattingCharacterSet: CharacterSet
        fileprivate let length: Int

        // MARK: - Life Cycle

        /**
         Construct a new `Template`.

         The template will be created from the provided `placeholderToken` and
         `template` string. The `placeholderToken` should correspond to the
         character used in the template to denote the characters that should be
         replaced.

         If you have formatting characters in your template string that might
         also appear in your target string, you can use the optional
         `preservedCharacters` parameter to mark those characters as needing to
         be preserved so that they aren't stripped from the target during
         template application.

         For example:

         ```swift
         let template = String.Template(placeholderToken: "X", template: "0XX0")
         let string = try? "00".applying(template: template)
         // string == nil, because the character `0` is treated as a formatting
         // character, and so was stripped from the target string during
         // application.

         let fixedTemplate = String.Template(placeholderToken: "X", template: "0XX0", preservedCharacters: .decimalDigits)
         let fixedString = try? "00".applying(template: fixedTemplate)
         // string == "0000", because we explicitly marked decimal digits as
         // being preserved characters that should not be stripped from the
         // source.
         ```

         - parameter placeholderToken: The token used in the template string to
           indicate where characters should be replaced.
         - parameter template: The template string to use. This string should
           represent a specific format and should use the `placeholderToken` to mark
           where character replacements will happen.
         - parameter preservedCharacters: A character set representing
           characters that should be treated as formatting characters, but should
           _not_ be stripped from the target string. Defaults to `nil`. 
         */
        public init(placeholderToken: Character, template: String, preservedCharacters: CharacterSet? = nil) {
            self.placeholderToken = placeholderToken
            self.template = template

            let placeholderCharacters = CharacterSet(character: placeholderToken)
            let formatting = template.removingCharacters(in: placeholderCharacters)

            var formattingCharacterSet = CharacterSet(charactersIn: formatting)

            self.length = template.removingCharacters(in: formattingCharacterSet).count

            if let preservedCharacters = preservedCharacters {
                formattingCharacterSet.subtract(preservedCharacters)
            }

            self.formattingCharacterSet = formattingCharacterSet
        }
    }


    // MARK: - Public Methods

    /**
     Apply a template to `self` with the provided options. This method mutates
     the callee.

     You can use the `options` parameter to conditionally allow partial or
     overflow behavior for the template application. This property defaults to
     an empty set of options, which will enforce an exact match between the
     length of the template and the length of the target.

     See `Template.Options` for more information.

     - parameter template: The `Template` instance to apply to `self`
     - parameter options: The `Template.Options` to use when applying the
       template. This defaults to `[]`, which results in enforcing an exact match
       between the template length and the target string length.
     - throws: String.Template.Error if the template application fails, usually
       because of a length mismatch.
     */
    public mutating func apply(template: Template, options: Template.Options = []) throws {
        removeCharacters(in: template.formattingCharacterSet)

        try validate(length: template.length, options: options)

        var formatted = template.template
        var currentIndex = startIndex;
        var formatStringIndex = formatted.index(of: template.placeholderToken)

        while let placeholderIndex = formatStringIndex, currentIndex < endIndex {
            let characterToInsert = String(self[currentIndex])
            formatted = formatted.replacingCharacters(in: placeholderIndex...placeholderIndex, with: characterToInsert)

            // Increment our indices
            currentIndex = index(currentIndex, offsetBy: 1)
            formatStringIndex = formatted[placeholderIndex...].index(of: template.placeholderToken)
        }

        // Only use the part of the string we formatted, defaulting to the whole string if we completed formatting
        let end = formatStringIndex ?? formatted.endIndex
        self = String(formatted[..<end])
    }

    /**
     Apply a template to `self` using the provided options, returning a new
     string with the template applied

     You can use the `options` parameter to conditionally allow partial or
     overflow behavior for the template application. This property defaults to
     an empty set of options, which will enforce an exact match between the
     length of the template and the length of the target.

     See `Template.Options` for more information.

     This is an immutable variant of `apply(template:)`

     - parameter template: The `Template` instance to apply to `self`
     - parameter options: The `Template.Options` to use when applying the
       template. This defaults to `[]`, which results in enforcing an exact match
       between the template length and the target string length.
     - throws: String.Template.Error if the template application fails, usually
       because of a length mismatch.
     */
    public func applying(template: Template, options: Template.Options = []) throws -> String {
        var copy = self
        try copy.apply(template: template, options: options)
        return copy
    }

    // MARK: - Private Methods

    private func validate(length: Int, options: Template.Options) throws {
        if !options.contains(.allowOverflow) {
            try validateMaxLength(length)
        }

        if !options.contains(.allowPartial) {
            try validateMinLength(length)
        }
    }

    private func validateMinLength(_ length: Int) throws {
        if count < length {
            throw String.Template.Error.tooShort
        }
    }

    private func validateMaxLength(_ length: Int) throws {
        if count > length {
            throw String.Template.Error.tooLong
        }
    }
}
