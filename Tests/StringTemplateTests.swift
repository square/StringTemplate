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

import StringTemplate
import XCTest

final class StringTemplateTests: XCTestCase {
    func testSuccessfulTemplateApplication() {
        let phone = String.Template(placeholderToken: "&", template: "(&&&) &&&-&&&&")
        let template = String.Template(placeholderToken: "%", template: "%% %%% (%%)*(%%)")

        XCTAssertEqual(try? "5555555555".applying(template: phone), "(555) 555-5555")
        XCTAssertEqual(try? "1234567890".applying(template: phone), "(123) 456-7890")
        XCTAssertEqual(try? "123456789".applying(template: template), "12 345 (67)*(89)")
        XCTAssertEqual(try? "000000000".applying(template: template), "00 000 (00)*(00)")
    }

    func testSuccessfulPartialTemplateApplication() {
        let phone = String.Template(placeholderToken: "&", template: "(&&&) &&&-&&&&")
        let template = String.Template(placeholderToken: "%", template: "%% %%% (%%)*(%%)")

        XCTAssertEqual(try? "5555555555".applying(template: phone, options: [.allowPartial]), "(555) 555-5555")
        XCTAssertEqual(try? "5555555".applying(template: phone, options: [.allowPartial]), "(555) 555-5")
        XCTAssertEqual(try? "123456".applying(template: phone, options: [.allowPartial]), "(123) 456-")
        XCTAssertEqual(try? "12345".applying(template: template, options: [.allowPartial]), "12 345 (")
        XCTAssertEqual(try? "0000000".applying(template: template, options: [.allowPartial]), "00 000 (00)*(")
    }

    func testSuccessfulOverflowTemplateApplication() {
        let phone = String.Template(placeholderToken: "&", template: "(&&&) &&&-&&&&")
        let template = String.Template(placeholderToken: "%", template: "%% %%% (%%)*(%%)")

        XCTAssertEqual(try? "5555555555555".applying(template: phone, options: [.allowOverflow]), "(555) 555-5555")
        XCTAssertEqual(try? "123456789000".applying(template: phone, options: [.allowOverflow]), "(123) 456-7890")
        XCTAssertEqual(try? "1234567890000".applying(template: template, options: [.allowOverflow]), "12 345 (67)*(89)")
        XCTAssertEqual(try? "00000000000000".applying(template: template, options: [.allowOverflow]), "00 000 (00)*(00)")
    }

    func testUnsuccessfulTemplateApplication() {
        let template = String.Template(placeholderToken: "X", template: "XXXX")

        assert(try "123".applying(template: template), throws: String.Template.Error.tooShort)
        assert(try "12345".applying(template: template), throws: String.Template.Error.tooLong)
    }

    func testUnsuccessfulPartialTemplateApplication() {
        let template = String.Template(placeholderToken: "X", template: "XXXX")

        XCTAssertEqual(try? "123".applying(template: template, options: [.allowPartial]), "123")
        assert(try "12345".applying(template: template, options: [.allowPartial]), throws: String.Template.Error.tooLong)
    }

    func testUnsuccessfulOverflowTemplateApplication() {
        let template = String.Template(placeholderToken: "X", template: "XXXX")

        XCTAssertEqual(try? "12345".applying(template: template, options: [.allowOverflow]), "1234")
        assert(try "123".applying(template: template, options: [.allowOverflow]), throws: String.Template.Error.tooShort)
    }

    func testPreservedCharacters() {
        let template = String.Template(placeholderToken: "X", template: "0XXX0", preservedCharacters: .decimalDigits)

        XCTAssertEqual(try? "103".applying(template: template), "01030")
    }
}

// Assert that a throwing function throws a specific error
func assert<T, E>(_ function: @autoclosure () throws -> T, throws expected: E, file: StaticString = #file, line: UInt = #line) where E: Error & Equatable {
    do {
        _ = try function()
        XCTFail("Expected an error to be thrown", file: file, line: line)
    } catch let error as E {
        XCTAssertEqual(error, expected, file: file, line: line)
    } catch {
        XCTFail("Incorrect error type was thrown: \(error)", file: file, line: line)
    }
}
