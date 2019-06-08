import Foundation
extension String {
    func components(separatedBy separator: String, escapingQuotes: String) -> [String] {
        guard contains(escapingQuotes) else {
            return components(separatedBy: separator)
        }
        
        var components = [String]()
        var oddNumberOfQuote = false
        var lastIndex = startIndex
        for i in indices {
            if self[i] == Character(escapingQuotes) {
                oddNumberOfQuote = !oddNumberOfQuote
            } else if self[i] == ",", !oddNumberOfQuote {
                components.append(String(self[lastIndex..<i]).replacingOccurrences(of: escapingQuotes, with: ""))
                lastIndex = index(i, offsetBy: 1)
            }
        }
        
        components.append(String(self[lastIndex..<endIndex]).replacingOccurrences(of: escapingQuotes, with: ""))
        return components
    }
}
