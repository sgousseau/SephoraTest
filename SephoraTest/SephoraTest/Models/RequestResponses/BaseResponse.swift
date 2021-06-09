//
//  BaseResponse.swift
//  SephoraTest
//
//  Created by Sébastien Gousseau on 09/06/2021.
//

import Foundation

struct BaseResponse<DataModel: Codable>: Codable {
    let items: DataModel
}

struct BaseArrayResponse<DataModel: Codable>: Codable {
    let items: [DataModel]
}
