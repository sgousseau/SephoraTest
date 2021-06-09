# SephoraTest
Ce code est destiné à être utilisé commme support lors d'un entretien technique chez Sephora.

L'application proposée est écrite en Swift 5 / MVC / Rx Familly, comporte deux écrans principaux. Le business layer est développé par callback avec interfaces Rx.
Les services sont indépendants, développé sous forme de structure à la manière TCA, permettant une implémentation à la volée sous forme de variable. Les services sont regroupés dans le fichier Dependencies.swift.

Le service de cache mérite une attention particulière, je l'ai développé dans l'idée de permettre un cache d'application porté par CloudKit, sous forme de fichier. La partie CloudKit n'a pas été développée dans un soucis de rapport temps/qualité principalement, mais l'idée est là. Actuellement, CacheService propose une implémentation nommée "local", stocke et récupère les données en début de chaine, avant parsing, par fichier: Data(contentsOf: URL).

L'écran de listing de produit utilise une UITableView branchée directement à la requête getProducts du ProductService. La tableView est branchée à l'aide de RxDataSources, permettant une population fluide et animée lorsque les données sont rafraichies, sans avoir à organiser les insertion et suppression par nous meme. Le tap sur une cellule déclenche un UIStoryboardSegue vers l'écran de détail, qui réutilise le modèle sélectionné. 

Le dépot a été réorganisé afin de segmenter l'ensemble des features. Utile pour du cherry-pick, ou ne serait-ce que pour la compréhension.
