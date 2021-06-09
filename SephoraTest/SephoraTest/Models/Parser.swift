//
//  Parser.swift
//  SephoraTest
//
//  Created by Sébastien Gousseau on 09/06/2021.
//

import Foundation

enum ParserError: Error {
    case decoding(Error)
}

struct Parser<T: Codable> {
    ///Takes a codable data stream and a completion block with the parsed object and error as parameter.
    var parse: (Data, (T?, Error?) -> Void) -> Void
}

extension Parser {
    static func forType(_ type: T.Type) -> Parser {
        return .init { data, completion in
            do {
                let parsed = try JSONDecoder().decode(type, from: data)
                completion(parsed, nil)
            } catch {
                completion(nil, ParserError.decoding(error))
            }
        }
    }
}
