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

extension String {
    /**
     Remove the characters in the provided `CharacterSet` from `self`.

     - parameter characterSet: The `CharacterSet` containing the characters
       that should be removed from `self`.
     */
    mutating func removeCharacters(in characterSet: CharacterSet) {
        var nextSearchRange = range(of: self)

        while let searchRange = nextSearchRange, !searchRange.isEmpty {
            guard var characterRange = rangeOfCharacter(from: characterSet, options: .literal, range: searchRange) else {
                break
            }

            // Make sure not to break up composed character sequences when removing content.
            characterRange = rangeOfComposedCharacterSequences(for: characterRange)
            removeSubrange(characterRange)

            nextSearchRange = characterRange.lowerBound ..< endIndex
        }
    }

    /**
     Remove the characters in the provided `CharacterSet` from the callee, returning a new instance.

     This is an immutable variant of `removeCharacters(in:)`

     - parameter characterSet: The `CharacterSet` containing the characters
       that should be removed from the new string.
     - returns: A copy of `self` with the specified characters removed
     */
    func removingCharacters(in characterSet: CharacterSet) -> String {
        var copy = self
        copy.removeCharacters(in: characterSet)
        return copy
    }
}
