// Copyright © 2021 Intuit, Inc. All rights reserved.
import UIKit
import SafariServices

/// Presents full details for a single `CatBreed`.
final class CatBreedDetailViewController: UIViewController {

    var breed: CatBreed!

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var wikipediaURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        guard let breed else {
            return
        }

        title = breed.name
        wikipediaURL = breed.wikipedia_url.flatMap { URL(string: $0) }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .secondarySystemBackground
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 220).isActive = true

        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        let imageContainer = UIView()
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.addSubview(imageView)
        imageContainer.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor)
        ])

        contentStack.addArrangedSubview(imageContainer)

        if let description = breed.description, !description.isEmpty {
            contentStack.addArrangedSubview(sectionLabel(title: "About", body: description))
        }
        if let temperament = breed.temperament, !temperament.isEmpty {
            contentStack.addArrangedSubview(sectionLabel(title: "Temperament", body: temperament))
        }
        if let life = breed.life_span, !life.isEmpty {
            contentStack.addArrangedSubview(sectionLabel(title: "Life span", body: life))
        }

        let traits = Self.traitLines(from: breed)
        if !traits.isEmpty {
            contentStack.addArrangedSubview(sectionLabel(title: "Traits", body: traits.joined(separator: " · ")))
        }

        let ratings = Self.ratingLines(from: breed)
        if !ratings.isEmpty {
            contentStack.addArrangedSubview(sectionLabel(title: "Ratings", body: ratings.joined(separator: "\n")))
        }

        if wikipediaURL != nil {
            let button = UIButton(type: .system)
            button.setTitle("Open Wikipedia", for: .normal)
            button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
            button.addTarget(self, action: #selector(openWikipedia), for: .touchUpInside)
            contentStack.addArrangedSubview(button)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])

        loadBreedImage()
    }

    private func sectionLabel(title: String, body: String) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label

        let bodyLabel = UILabel()
        bodyLabel.text = body
        bodyLabel.numberOfLines = 0
        bodyLabel.font = .preferredFont(forTextStyle: .body)
        bodyLabel.textColor = .secondaryLabel

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(bodyLabel)
        return stack
    }

    private func loadBreedImage() {
        activityIndicator.startAnimating()

        if let urlString = breed.image?.url, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    if let data, let image = UIImage(data: data) {
                        self?.imageView.image = image
                    } else {
                        self?.activityIndicator.startAnimating()
                        self?.fallbackFetchImage()
                    }
                }
            }.resume()
            return
        }

        fallbackFetchImage()
    }

    private func fallbackFetchImage() {
        guard let id = breed.id else {
            activityIndicator.stopAnimating()
            return
        }

        Network.fetchCatImage(breedId: id) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let image):
                    self?.imageView.image = image
                case .failure:
                    self?.imageView.image = UIImage(systemName: "photo")
                    self?.imageView.tintColor = .tertiaryLabel
                }
            }
        }
    }

    @objc private func openWikipedia() {
        guard let url = wikipediaURL else { return }
        let safari = SFSafariViewController(url: url)
        safari.dismissButtonStyle = .close
        present(safari, animated: true)
    }

    private static func traitLines(from breed: CatBreed) -> [String] {
        var lines: [String] = []
        let pairs: [(String, Int?)] = [
            ("Experimental", breed.experimental),
            ("Hairless", breed.hairless),
            ("Indoor", breed.indoor),
            ("Lap cat", breed.lap),
            ("Hypoallergenic", breed.hypoallergenic),
            ("Rare", breed.rare),
            ("Natural breed", breed.natural)
        ]
        for (name, value) in pairs where value == 1 {
            lines.append(name)
        }
        return lines
    }

    private static func ratingLines(from breed: CatBreed) -> [String] {
        let pairs: [(String, Int?)] = [
            ("Adaptability", breed.adaptability),
            ("Affection", breed.affection_level),
            ("Child-friendly", breed.child_friendly),
            ("Dog-friendly", breed.dog_friendly),
            ("Energy", breed.energy_level),
            ("Grooming", breed.grooming),
            ("Health", breed.health_issues),
            ("Intelligence", breed.intelligence),
            ("Shedding", breed.shedding_level),
            ("Social needs", breed.social_needs),
            ("Stranger-friendly", breed.stranger_friendly),
            ("Vocalisation", breed.vocalisation)
        ]
        return pairs.compactMap { name, value in
            guard let value else { return nil }
            return "  \(name): \(value)/5"
        }
    }
}
