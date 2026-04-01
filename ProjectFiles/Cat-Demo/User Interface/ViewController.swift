// Copyright © 2021 Intuit, Inc. All rights reserved.
import UIKit

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    let viewModel = ViewModel()

    private lazy var breedSearchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Filter by name"
        return sc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        definesPresentationContext = true
        navigationItem.searchController = breedSearchController
        navigationItem.hidesSearchBarWhenScrolling = false

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.viewModel.catDataDelegate = self
        self.viewModel.getBreeds()
    }
}

// MARK: - UISearchResultsUpdating
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.nameFilter = searchController.searchBar.text ?? ""
    }
}

// MARK: -
// MARK: TableView Delegate Methods
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.displayBreeds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "catBreed") else {
            return UITableViewCell()
        }

        let breed = viewModel.displayBreeds[indexPath.row]
        cell.textLabel?.text = breed.name
        cell.detailTextLabel?.text = breed.description
        cell.detailTextLabel?.numberOfLines = 0  // allow wrapping for long descriptions

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        let breed = viewModel.displayBreeds[indexPath.row]

        let detail = CatBreedDetailViewController()
        detail.breed = breed
        navigationController?.pushViewController(detail, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        let count = viewModel.displayBreeds.count
        guard count > 0 else { return }
        let lastRow = count - 1
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
