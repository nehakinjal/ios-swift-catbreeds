// Copyright © 2021 Intuit, Inc. All rights reserved.
import UIKit

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.viewModel.catDataDelegate = self
        self.viewModel.getBreeds()
    }
}

// MARK: -
// MARK: TableView Delegate Methods
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.catBreeds?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "catBreed") else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = viewModel.catBreeds?[indexPath.row].name
        cell.detailTextLabel?.text = viewModel.catBreeds?[indexPath.row].description
        cell.detailTextLabel?.numberOfLines = 0  // allow wrapping for long descriptions
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        guard let cat = viewModel.catBreeds?[indexPath.row] else {
            return
        }
        
        let detail = CatBreedDetailViewController()
        detail.breed = cat
        navigationController?.pushViewController(detail, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        let lastRow = (viewModel.catBreeds?.count ?? 0) - 1
        if indexPath.row == lastRow {
            viewModel.getMoreBreeds()
        }
    }
}

// MARK: -
// MARK: Cat Data Model Delegate Methods
extension ViewController: CatDataDelegate {
    func breedsChangedNotification() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
