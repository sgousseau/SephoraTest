//
//  NetworkService.swift
//  SephoraTest
//
//  Created by Sébastien Gousseau on 08/06/2021.
//

import Foundation
import RxSwift

enum NetworkError: Error {
    case session(Error)
    case unknown
}

struct NetworkService {
    /// Gets a data over the network, takes the URL as first parameter and a completion block as callback with Data or Error
    var get: (URL, @escaping (Data?, Error?) -> Void) -> Void
}

extension NetworkService {
    static var prod: NetworkService = {

        let urlSession = URLSession.shared

        return .init { url, completion in
            let task = urlSession.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(nil, NetworkError.session(error))
                } else if let data = data {
                    #if DEBUG
                    print(String(data: data, encoding: .utf8) ?? "")
                    #endif
                    completion(data, nil)
                } else {
                    completion(nil, NetworkError.unknown)
                }
            }
            task.resume()
        }
    }()
}

extension NetworkService: ReactiveCompatible {}

extension Reactive where Base == NetworkService {
    func get(_ url: URL) -> Observable<Data> {
        return .deferred {
            .create { obs in

                base.get(url) { data, error in
                    if let error = error {
                        obs.onError(error)
                    } else if let data = data {
                        obs.onNext(data)
                        obs.onCompleted()
                    } else {
                        obs.onError(NetworkError.unknown)
                    }
                }

                return Disposables.create {}
            }
        }
    }
}
