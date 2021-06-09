//
//  ProductListViewController.swift
//  SephoraTest
//
//  Created by Sébastien Gousseau on 08/06/2021.
//

import UIKit
import RxSwift
import RxDataSources
import Differentiator

class ProductListViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!

    // MARK: Private properties

    private let productService = Dependencies.prod.productService
    private var dataSource: RxTableViewSectionedAnimatedDataSource<Section>!
    private var disposeBag = DisposeBag()
    private var selectedProduct: Product?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Sephora products"
        tableView.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")

        dataSource = createDataSource()

        productService.rx.getProducts(true)
            .debug()
            .retry(3)
            .map { [Section(header: "All Products", items: $0)] }
            .catch({ [weak self] error in
                guard let sself = self else {
                    return Observable.just([])
                }

                return UIAlertController
                    .present(in: sself,
                             title: "Error",
                             message: "\(error)",
                             style: .alert,
                             actions: [
                                .action(title: "OK")
                             ])
                    .map { _ in [] }
            })
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(Product.self)
            .do(onNext: { [weak self] product in
                self?.selectedProduct = product
                self?.performSegue(withIdentifier: "productListToDetail", sender: self)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ProductDetailViewController {
            destination.productService = productService
            destination.product = selectedProduct
        }
    }
}

extension ProductListViewController {
    fileprivate func createDataSource() -> RxTableViewSectionedAnimatedDataSource<Section> {
        return RxTableViewSectionedAnimatedDataSource<Section>(
            configureCell: { [weak self] ds, tv, _, item in
                guard let sself = self else {
                    return ProductCell()
                }

                var currentCell: ProductCell
                if let cell = tv.dequeueReusableCell(withIdentifier: ProductCell.reuseIdentifier) as? ProductCell {
                    currentCell = cell
                } else {
                    currentCell = ProductCell()
                }

                //Clear any pending async work
                currentCell.disposeBag = DisposeBag()
                
                let idIndex = item.id.index(item.id.startIndex, offsetBy: 5)
                currentCell.idLabel.text = String(item.id.prefix(upTo: idIndex))
                currentCell.locationLabel.text = item.location ?? "-- N/A --"
                currentCell.descriptionLabel.text = item.description ?? "-- N/A --"

                //Assign remote image
                sself.productService.rx.getProductImageData(item.image)
                    .map { UIImage(data: $0) }
                    .filter { $0 != nil }
                    .bind(to: currentCell.pictureImageView.rx.image)
                    .disposed(by: currentCell.disposeBag)

                return currentCell
            },
            titleForHeaderInSection: { ds, index in
                return ds.sectionModels[index].header
            }
        )
    }
}

// MARK: TableView Modeling
private struct Section {
    var header: String
    var items: [Item]
}

extension Product: IdentifiableType {
    typealias Identity = String

    var identity: String {
        return id
    }
}

extension Section : AnimatableSectionModelType {
    typealias Item = Product

    var identity: String {
        return header
    }

    init(original: Section, items: [Item]) {
        self = original
        self.items = items
    }
}
