//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.

import TextBundleKit
import XCTest

let expectedMarkdown = """
# Textbundle Example

This is a simple example of a textbundle package. The following paragraph contains an example of a referenced image using the embedding code `![](assets/textbundle.png)`.

![](assets/textbundle.png)

"""

final class TextStorageTests: XCTestCase {

  func testCanLoadMarkdown() {
    let document = try! TextBundleTestHelper.makeDocument("testCanLoadMarkdown")
    let storage = TextStorage(document: document)
    let didOpen = expectation(description: "did open")
    storage.open { (success) in
      XCTAssert(success)
      XCTAssertEqual(try? storage.text.value(), expectedMarkdown)
      didOpen.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
  }
  
  func testConcurrentEdits() {
    let activeDocument = try! TextBundleTestHelper.makeDocument("testConcurrentEdits")
    let passiveDocument = TextBundleDocument(fileURL: activeDocument.fileURL)
    let activeStorage = TextStorage(document: activeDocument)
    let passiveStorage = TextStorage(document: passiveDocument)
    let didOpenPassive = expectation(description: "did open passive")
    passiveStorage.open { (success) in
      XCTAssert(success)
      didOpenPassive.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    let didOpenActive = expectation(description: "did open active")
    activeStorage.open { (success) in
      XCTAssert(success)
      didOpenActive.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    activeStorage.text.setValue("# Edited!\n\nThis is my edited text.")
  }
}
