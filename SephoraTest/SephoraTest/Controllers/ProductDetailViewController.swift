//
//  ProductDetailViewController.swift
//  SephoraTest
//
//  Created by Sébastien Gousseau on 08/06/2021.
//

import UIKit
import RxSwift

class ProductDetailViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    // MARK: Private properties
    
    private var disposeBag: DisposeBag! = DisposeBag()

    // MARK: Public properties

    var productService: ProductService?
    var product: Product?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if let service = productService {
            service.rx.getProductImageData(product?.image)
                .map { UIImage(data: $0) }
                .filter { $0 != nil }
                .bind(to: imageView.rx.image)
                .disposed(by: disposeBag)
        }
        
        idLabel.text = product?.id
        locationLabel.text = product?.location ?? "-- N/A --"
        descriptionLabel.text = product?.description ?? "-- N/A --"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disposeBag = nil
    }
}
