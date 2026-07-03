import Foundation

extension String {
    var htmlDecoded: String {
        var result = self
        let entities = [
            "&quot;": "\"",
            "&#039;": "'",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&nbsp;": " ",
            "&rsquo;": "’",
            "&lsquo;": "‘",
            "&ldquo;": "“",
            "&rdquo;": "”",
            "&hellip;": "…",
            "&mdash;": "—",
            "&ndash;": "–",
            "&deg;": "°",
            "&aacute;": "á",
            "&eacute;": "é",
            "&iacute;": "í",
            "&oacute;": "ó",
            "&uacute;": "ú",
            "&ntilde;": "ñ",
            "&uuml;": "ü",
            "&Aacute;": "Á",
            "&Eacute;": "É",
            "&Iacute;": "Í",
            "&Oacute;": "Ó",
            "&Uacute;": "Ú",
            "&Ntilde;": "Ñ",
            "&Uuml;": "Ü"
        ]
        
        for (entity, unicode) in entities {
            result = result.replacingOccurrences(of: entity, with: unicode)
        }
        
        var finalResult = ""
        var currentIndex = result.startIndex
        
        while currentIndex < result.endIndex {
            if result[currentIndex...].hasPrefix("&#") {
                if let semicolonIndex = result[currentIndex...].firstIndex(of: ";") {
                    let startOfNumber = result.index(currentIndex, offsetBy: 2)
                    let numberString = String(result[startOfNumber..<semicolonIndex])
                    
                    var charCode: UInt32? = nil
                    if numberString.hasPrefix("x") || numberString.hasPrefix("X") {
                        let hexString = String(numberString.dropFirst())
                        charCode = UInt32(hexString, radix: 16)
                    } else {
                        charCode = UInt32(numberString, radix: 10)
                    }
                    
                    if let code = charCode, let unicodeChar = UnicodeScalar(code) {
                        finalResult.append(Character(unicodeChar))
                        currentIndex = result.index(after: semicolonIndex)
                        continue
                    }
                }
            }
            finalResult.append(result[currentIndex])
            currentIndex = result.index(after: currentIndex)
        }
        
        return finalResult
    }
}
