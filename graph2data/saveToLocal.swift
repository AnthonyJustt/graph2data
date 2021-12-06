//
//  saveToLocal.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 05.12.2021.
//

import SwiftUI

func getDocumentsDirectory() -> URL {
    // find all possible documents directories for this user
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    // just send back the first one, which ought to be the only one
    return paths[0]
}

func saveToFile(fileName: String, fileContent: String) {
    let url = getDocumentsDirectory().appendingPathComponent(fileName)
    print(url)
    do {
        try fileContent.write(to: url, atomically: true, encoding: .utf8)
    } catch {
        print(error.localizedDescription)
    }
}

func readTagsFromFile(fileName: String) -> String {
    let url = getDocumentsDirectory().appendingPathComponent(fileName)
    var input: String = ""
    do {
        input = try String(contentsOf: url)
        print("read")
    } catch {
        print(error.localizedDescription)
    }
    return input
}

func isFileHere(fileName: String) -> Bool {
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let url = NSURL(fileURLWithPath: path)
    if let pathComponent = url.appendingPathComponent(fileName) {
        let filePath = pathComponent.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            print("isFileHere: FILE AVAILABLE")
            return true
        } else {
            print("isFileHere: FILE NOT AVAILABLE")
            return false
        }
    } else {
        print("isFileHere: FILE PATH NOT AVAILABLE")
        return false
    }
}

