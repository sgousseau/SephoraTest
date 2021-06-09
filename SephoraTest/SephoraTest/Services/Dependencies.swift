//
//  Dependancies.swift
//  SephoraTest
//
//  Created by Sébastien Gousseau on 08/06/2021.
//

import Foundation

struct Dependencies {

    //Raw services
    var networkService: NetworkService
    var localCacheService: CacheService

    //Composed services
    var productService: ProductService
}

extension Dependencies {
    static var prod: Dependencies = {
        return .init(
            networkService: .prod,
            localCacheService: .local, //Could be cloudkit
            productService: .prod
        )
    }()
}
