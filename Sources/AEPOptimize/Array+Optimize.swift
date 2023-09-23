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

import Foundation

// MARK: Array extension

extension Array {
    func toDictionary<Key: Hashable>(_ transform: (Element) throws -> Key) rethrows -> [Key: Element] {
        var dictionary = [Key: Element]()

        for element in self {
            try dictionary[transform(element)] = element
        }
        return dictionary
    }

    /// Returns a new array containing the elements of this array that do not occur in the other array.
    /// - Parameter other: the other array.
    /// - Returns: a new array containing the difference of elements between this and the other array.
    func minus(_ other: [Element]) -> [Element] where Element: Hashable {
        let completeSet = Set(self)
        let subset = Set(other)
        return Array(completeSet.subtracting(subset)) as [Element]
    }
}
