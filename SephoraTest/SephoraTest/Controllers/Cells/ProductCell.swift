//
//  ProductCell.swift
//  SephoraTest
//
//  Created by Sébastien Gousseau on 09/06/2021.
//

import UIKit
import RxSwift

class ProductCell: UITableViewCell {

    static let reuseIdentifier = "ProductCell"

    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    var disposeBag = DisposeBag()
}
