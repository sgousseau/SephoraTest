//
//  ProductManager.swift
//  SephoraTest
//
//  Created by Sébastien Gousseau on 08/06/2021.
//

import Foundation
import RxSwift

enum ProductServiceError: Error {
    case unknown
}

struct ProductService {
    /// Takes a `useCache` parameter. Returns a completion block containing the list of product.
    var getProducts: (Bool, @escaping ([Product]?, Error?) -> Void) -> Void
    /// Takes a `imageUrlString` parameter. Returns a completion block containing the image
    var getProductImageData: (String?, @escaping (Data?, Error?) -> Void) -> Void
}

extension ProductService {
    static var prod: ProductService = {

        let network = NetworkService.prod
        let cache = CacheService.local
        let parser = Parser.forType(BaseArrayResponse<Product>.self)

        return .init { useCache, completion in
            let url = URL(string: "https://sephoraios.github.io/items.json")!

            //The parsing procedure with completion call
            let parse: (Data) -> () = { data in
                parser.parse(data) { model, error in
                    //Parsing error, stop and returns error
                    if let error = error {
                        completion(nil, error)
                    } else if let model = model {
                        //Cache result if needed
                        if useCache {
                            //If caching error occurs, we dont want it to cancel our completion so we pass both items and error if any.
                            cache.set(url, data) { _, error in
                                completion(model.items, error)
                            }
                        } else {
                            completion(model.items, nil)
                        }
                    } else {
                        completion(nil, ProductServiceError.unknown)
                    }
                }
            }

            //The remote get procedure with parsing or completion call
            let remote: () -> Void = {
                network.get(url) { data, error in
                    if let error = error {
                        //Network Error
                        completion(nil, error)
                    } else if let data = data {
                        //Success, parse procedure
                        parse(data)
                    } else {
                        //Unknown error
                        completion(nil, ProductServiceError.unknown)
                    }
                }
            }

            //The local procedure with parsing, completion call, and fallback to remote procedure
            let local: () -> Void = {
                cache.get(url) { data, error in
                    if let _ = error {
                        //Cache Error -> Fallback
                        remote()
                    } else if let data = data {
                        //Success, parse procedure
                        parse(data)
                    } else {
                        //Unknown error
                        completion(nil, ProductServiceError.unknown)
                    }
                }
            }

            //Function logic become simple
            if useCache {
                local()
            } else {
                remote()
            }
        } getProductImageData: { urlString, completion in
            if let url = URL(string: urlString ?? "") {
                network.get(url) { data, error in
                    if let error = error {
                        network.get(URL(string: "https://picsum.photos/200/300")!) { data, error in
                            completion(data, error)
                        }
                    } else {
                        completion(data, nil)
                    }
                }
            } else {
                network.get(URL(string: "https://picsum.photos/200/300")!) { data, error in
                    completion(data, error)
                }
            }
        }
    }()
}

extension ProductService: ReactiveCompatible {}

extension Reactive where Base == ProductService {
    func getProducts(_ useCache: Bool) -> Observable<[Product]> {
        .deferred {
            .create { obs in

                base.getProducts(useCache) { products, error in
                    if let error = error {
                        obs.onError(error)
                    } else if let products = products {
                        obs.onNext(products)
                        obs.onCompleted()
                    } else {
                        obs.onCompleted()
                    }
                }

                return Disposables.create()
            }
        }
    }

    func getProductImageData(_ urlString: String?) -> Observable<Data> {
        .deferred {
            .create { obs in

                base.getProductImageData(urlString) { data, error in
                    if let error = error {
                        obs.onError(error)
                    } else if let data = data {
                        obs.onNext(data)
                        obs.onCompleted()
                    } else {
                        obs.onCompleted()
                    }
                }

                return Disposables.create()
            }
        }
    }
}
