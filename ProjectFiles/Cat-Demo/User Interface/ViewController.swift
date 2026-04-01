// Copyright © 2021 Intuit, Inc. All rights reserved.
import UIKit

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        guard let cat = viewModel.catBreeds?[indexPath.row],
              let catId = cat.id else {
            return
        }
        
        viewModel.getCatImage(breedId: catId)
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
    
    func imageChangedNotification() {
        DispatchQueue.main.async {
            guard let row = self.tableView.indexPathForSelectedRow?.row else {
                return
            }
            
            guard let cat = self.viewModel.catBreeds?[row] else {
                return
            }
            
            let alert = UIAlertController(title: cat.name, message: nil, preferredStyle: .alert)
            let imageView = UIImageView(frame: CGRect(x: 10.0, y: 50.0, width: 225, height: 225))
            imageView.contentMode = .scaleAspectFit
            imageView.image = self.viewModel.catImage
            
            alert.view.addSubview(imageView)
            
            let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
            let width = NSLayoutConstraint(item: alert.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
            
            alert.view.addConstraint(height)
            alert.view.addConstraint(width)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                self.tableView.reloadData()
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}
