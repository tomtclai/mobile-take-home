//
//  CSVReader.swift
//  Airport Routes
//
//  Created by Tom Lai on 6/8/19.
//  Copyright © 2019 Tom Lai. All rights reserved.
//

import Foundation
struct CSVReader {
    func parseCSV(filename: String) -> [[String]]? {
        guard let filePath = Bundle.main.path(forResource: filename, ofType: "csv", inDirectory: "data")  else  {
            print("no file found")
            return nil
        }
        let fileURL = URL(fileURLWithPath: filePath)
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            print("read file failed")
            return nil
        }
        return parseCSVString(content)
    }
    
    private func parseCSVString(_ str: String) -> [[String]] {
        var rows = str.components(separatedBy: "\n")
        rows.removeFirst() // drop the header row
        return rows.map{ $0.components(separatedBy: ",")}
    }
}
