//
//  Product.swift
//  SephoraTest
//
//  Created by Sébastien Gousseau on 09/06/2021.
//

import Foundation

struct Product: Codable, Equatable {
    var id: String
    var description: String?
    var location: String?
    var image: String?
}
