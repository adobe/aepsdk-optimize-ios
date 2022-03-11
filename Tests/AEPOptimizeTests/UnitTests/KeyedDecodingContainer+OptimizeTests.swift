/*
Copyright 2021 Adobe. All rights reserved.
This file is licensed to you under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License. You may obtain a copy
of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under
the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
OF ANY KIND, either express or implied. See the License for the specific language
governing permissions and limitations under the License.
*/

@testable import AEPOptimize
import XCTest

class KeyedDecodingContainer_OptimizeTests: XCTestCase {
    class Book: Decodable {
        let title: String
        let author: String

        enum CodingKeys: String, CodingKey {
            case title
            case author
        }
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            title = try container.decode(String.self, forKey: .title)
            author = try container.decode(String.self, forKey: .author)
        }
    }
    
    class LibraryA: Decodable {
        let books: [Book]
        
        enum CodingKeys: String, CodingKey {
            case books
        }
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            books = (try? container.decode([Book].self, forKey: .books, ignoreInvalid: true)) ?? []
        }
        
    }
    
    class LibraryB: Decodable {
        let books: [Book]

        enum CodingKeys: String, CodingKey {
            case books
        }
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            books = (try? container.decode([Book].self, forKey: .books, ignoreInvalid: false)) ?? []
        }

    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLibraryA_validEntries() {
        guard
            let libraryData = BOOKS_JSON_VALID_ENTRIES.data(using: .utf8),
            let library = try? JSONDecoder().decode(LibraryA.self, from: libraryData)
        else {
            XCTFail("Library should be valid.")
            return
        }
        
        XCTAssertEqual(2, library.books.count)
        let book1 = library.books[0]
        XCTAssertEqual("Gulliver's Travels", book1.title)
        XCTAssertEqual("Jonathan Swift", book1.author)
        let book2 = library.books[1]
        XCTAssertEqual("Alice's Adventures in Wonderland", book2.title)
        XCTAssertEqual("Lewis Carroll", book2.author)
    }
    
    func testLibraryB_validEntries() {
        guard
            let libraryData = BOOKS_JSON_VALID_ENTRIES.data(using: .utf8),
            let library = try? JSONDecoder().decode(LibraryB.self, from: libraryData)
        else {
            XCTFail("Library should be valid.")
            return
        }
        
        XCTAssertEqual(2, library.books.count)
        let book1 = library.books[0]
        XCTAssertEqual("Gulliver's Travels", book1.title)
        XCTAssertEqual("Jonathan Swift", book1.author)
        let book2 = library.books[1]
        XCTAssertEqual("Alice's Adventures in Wonderland", book2.title)
        XCTAssertEqual("Lewis Carroll", book2.author)
    }
    
    func testLibraryA_validAndInvalidEntries() {
        guard
            let libraryData = BOOKS_JSON_VALID_AND_INVALID_ENTRIES.data(using: .utf8),
            let library = try? JSONDecoder().decode(LibraryA.self, from: libraryData)
        else {
            XCTFail("Library should be valid.")
            return
        }
        
        XCTAssertEqual(2, library.books.count)
        let book1 = library.books[0]
        XCTAssertEqual("Gulliver's Travels", book1.title)
        XCTAssertEqual("Jonathan Swift", book1.author)
        let book2 = library.books[1]
        XCTAssertEqual("Alice's Adventures in Wonderland", book2.title)
        XCTAssertEqual("Lewis Carroll", book2.author)
    }
    
    func testLibraryB_validAndInvalidEntries() {
        guard
            let libraryData = BOOKS_JSON_VALID_AND_INVALID_ENTRIES.data(using: .utf8),
            let library = try? JSONDecoder().decode(LibraryB.self, from: libraryData)
        else {
            XCTFail("Library should be valid.")
            return
        }
        
        XCTAssertTrue(library.books.isEmpty)
    }
    
    func testLibraryA_invalidEntries() {
        guard
            let libraryData = BOOKS_JSON_INVALID_ENTRIES.data(using: .utf8),
            let library = try? JSONDecoder().decode(LibraryA.self, from: libraryData)
        else {
            XCTFail("Library should be valid.")
            return
        }
        
        XCTAssertTrue(library.books.isEmpty)
    }
    
    func testLibraryB_invalidEntries() {
        guard
            let libraryData = BOOKS_JSON_INVALID_ENTRIES.data(using: .utf8),
            let library = try? JSONDecoder().decode(LibraryB.self, from: libraryData)
        else {
            XCTFail("Library should be valid.")
            return
        }
        
        XCTAssertTrue(library.books.isEmpty)
    }
    
    let BOOKS_JSON_VALID_ENTRIES =
"""
{\
    "books": [\
        {\
            "title": "Gulliver's Travels",\
            "author": "Jonathan Swift"\
        },\
        {\
            "title": "Alice's Adventures in Wonderland",\
            "author": "Lewis Carroll"\
        }\
    ]\
}
"""
    
    let BOOKS_JSON_VALID_AND_INVALID_ENTRIES =
"""
{\
    "books": [\
        {\
            "title": "Gulliver's Travels",\
            "author": "Jonathan Swift"\
        },\
        {\
           "title": "Something"\
        },\
        {\
            "title": "Alice's Adventures in Wonderland",\
            "author": "Lewis Carroll"\
        }\
    ]\
}
"""
    
    let BOOKS_JSON_INVALID_ENTRIES =
"""
{\
    "books": [\
        {\
           "title": "Something"\
        },\
        {\
           "author": "Someone"\
        }\
    ]\
}
"""
}
