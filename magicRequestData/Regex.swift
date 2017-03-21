//
//  Regex.swift
//  magicRequestData
//
//  Created by bruno raupp kieling on 6/16/16.
//  Copyright © 2016 brunokieling. All rights reserved.
//

import Foundation

class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init?(_ pattern: String) {
        self.pattern = pattern
        do {
            self.internalExpression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        } catch {
            print(error)
            return nil
        }
    }
    
    func test(_ input: String) -> [String] {
            let nsString = input as NSString
            let results = internalExpression.matches(in: input,
                                                options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        
        
    }
    
    func match(input: String) -> Bool {
        
        let matches = self.internalExpression.matches(in: input, options: [], range:NSMakeRange(0, input.characters.count))
        return matches.count > 0
    }
}
