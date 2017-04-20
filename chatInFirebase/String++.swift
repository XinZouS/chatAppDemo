//
//  String++.swift
//  chatInFirebase
//
//  Created by Xin Zou on 4/20/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

// for detect emoji in text: 
// http://stackoverflow.com/questions/30757193/find-out-if-character-in-string-is-emoji

extension UnicodeScalar {
    
    var isEmoji : Bool {
        switch value {
        case 0x1F600...0x1F64F, // Emoticons
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs
            0x1F680...0x1F6FF, // Transport and Map
            0x2600...0x26FF,   // Misc symbols
            0x2700...0x27BF,   // Dingbats
            0xFE00...0xFE0F,   // Variation Selectors
            0x1F900...0x1F9FF:  // Supplemental Symbols and Pictographs
            return true
            
        default: return false
        }
    }
    
    var isZeroWidthJoiner: Bool {
        return value ==  8025
    }
    
}


extension String {
    
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                0x1F680...0x1F6FF, // Transport and Map
                0x2600...0x26FF,   // Misc symbols
                0x2700...0x27BF,   // Dingbats
                0xFE00...0xFE0F,   // Variation Selectors
                0x1F900...0x1F9FF:  // Supplemental Symbols and Pictographs
                return true
            default:
                continue
            }
        }
        return false
    }

    var glyphCount: Int {
        let richText = NSAttributedString(string: self)
        let line = CTLineCreateWithAttributedString(richText)
        return CTLineGetGlyphCount(line)
    }
    
    var isSingleEmoji: Bool {
        return glyphCount ==  1 && containsEmoji
    }
    
    var containsOnlyEmojis: Bool {
        return unicodeScalars.first(where: { !$0.isEmoji && !$0.isZeroWidthJoiner }) == nil
    }
    
    var emojiString: String {
        return emojiScalars.map{ String($0) }.reduce("", +)
    }
    
    var emojis: [String] {
        var scalars : [[UnicodeScalar]] = []
        var currentScalarSet : [UnicodeScalar] = []
        var previousScalar: UnicodeScalar?
        
        for scalar in emojiScalars {
            if let prev = previousScalar, !prev.isZeroWidthJoiner && !scalar.isZeroWidthJoiner {
                scalars.append(currentScalarSet)
                currentScalarSet.removeAll()
            }
            currentScalarSet.append(scalar)
            previousScalar = scalar
        }
        scalars.append(currentScalarSet)
        
        return scalars.map{ $0.map{ String($0) }.reduce("", +) }
    }
    
    fileprivate var emojiScalars : [UnicodeScalar] {
        var chars : [UnicodeScalar] = []
        var previous: UnicodeScalar?
        for c in unicodeScalars {
            if let previous = previous, previous.isZeroWidthJoiner && c.isEmoji {
                chars.append(previous)
                chars.append(c)
            }else if c.isEmoji {
                chars.append(c)
            }
            previous = c
        }
        return chars
    }
    
}

/* // use as:
"👨‍👩‍👧‍👧".isSingleEmoji // true
"👨‍👩‍👧‍👧".containsOnlyEmoji // true
"Hello 👨‍👩‍👧‍👧".containsOnlyEmoji // false
"Hello 👨‍👩‍👧‍👧".containsEmoji // true
"👫 Héllo 👨‍👩‍👧‍👧".emojiString // "👫👨‍👩‍👧‍👧"
"👨‍👩‍👧‍👧".glyphCount // 1
"👨‍👩‍👧‍👧".characters.count // 4

"👫 Héllœ 👨‍👩‍👧‍👧".emojiScalars // [128107, 128104, 8205, 128105, 8205, 128103, 8205, 128103]
"👫 Héllœ 👨‍👩‍👧‍👧".emojis // ["👫", "👨‍👩‍👧‍👧"]

"👫👨‍👩‍👧‍👧👨‍👨‍👦".isSingleEmoji // false
"👫👨‍👩‍👧‍👧👨‍👨‍👦".containsOnlyEmoji // true
"👫👨‍👩‍👧‍👧👨‍👨‍👦".glyphCount // 3
"👫👨‍👩‍👧‍👧👨‍👨‍👦".characters.count // 8
*/
