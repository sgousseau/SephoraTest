//
//  CacheService.swift
//  SephoraTest
//
//  Created by Sébastien Gousseau on 08/06/2021.
//

import Foundation
import RxSwift

enum CacheError: Error {
    case read(URL, Error)
    case write(URL, Error)
    case unknown
}

struct CacheService {
    /// Gets a data from a stored file with that url as identifier. Takes the `url` as parameter and a completion block with optional data and error.
    var get: (URL, (Data?, Error?) -> Void) -> Void

    ///Sets a given data or nil for that file url identifier. Takes the `url` as parameter and the optional data plus a completion block with success bool and error.
    var set: (URL, Data?, (Bool, Error?) -> Void) -> Void
}

extension CacheService {
    static var local: CacheService = {

        //Documents url procedure
        let getDocumentsDirectory: () -> URL = {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }

        //URL formatting procedure
        let makeCacheUrl: (URL) -> URL = { url in
            var fileUrl = getDocumentsDirectory()
            return fileUrl.appendingPathComponent(url.path)
        }

        return .init { url, onComplete in
            let _url = makeCacheUrl(url)
            do {
                onComplete(try Data(contentsOf: _url), nil)
            } catch {
                onComplete(nil, CacheError.read(_url, error))
            }

        } set: { url, data, onComplete in
            let _url = makeCacheUrl(url)
            do {
                try data?.write(to: _url)
                onComplete(true, nil)
            } catch {
                onComplete(false, CacheError.write(_url, error))
            }
        }
    }()
}

extension CacheService: ReactiveCompatible {}

extension Reactive where Base == CacheService {

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
                        obs.onError(CacheError.unknown)
                    }
                }

                return Disposables.create()
            }
        }
    }

    func set(_ url: URL, data: Data?) -> Observable<Void> {
        return .deferred {
            .create { obs in

                base.set(url, data) { success, error in
                    if let error = error {
                        obs.onError(error)
                    } else if success {
                        obs.onNext(())
                        obs.onCompleted()
                    } else {
                        obs.onError(CacheError.unknown)
                    }
                }

                return Disposables.create()
            }

        }
    }
}
