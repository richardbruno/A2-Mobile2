//
//  ArrayExtension.swift
//  Memorize
//
//  Created by Yhan Nunes on 09/12/23.
//

import Foundation

extension Array {
    var only: Element? {
        count == 1 ? first : nil
    }
}

extension Array where Element: Identifiable {
    func firstIndex(matching: Element) -> Int? {
        for index in 0..<self.count {
            if self[index].id == matching.id {
                return index
              }
          }
          return nil
        }
    }
