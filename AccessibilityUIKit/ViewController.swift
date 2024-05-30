//
//  ViewController.swift
//  AccessibilityUIKit
//
//  Created by Dmytro Chumakov on 29.05.2024.
//

import UIKit

let fruitJson = """
[
    {
        "name": "Apple",
        "callories": 52
    },
    {
        "name": "Banana",
        "callories": 89
    },
    {
        "name": "Orange",
        "callories": 47
    }
]
"""

struct FruitModel: Decodable {
    let name: String
    let callories: Int    
}

final class FruitTableViewCell: UITableViewCell {

    static let reuseIdentifier = "FruitTableViewCell"    

    private let nameLabel = UILabel()
    private let calloriesLabel = UILabel()
    private let favouriteButton = UIButton()

    override var accessibilityElements: [Any]? {
        get {
            return [
                nameLabel as Any,
                calloriesLabel as Any,
                favouriteButton as Any
            ]
        }
        set { }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(calloriesLabel)        
        contentView.addSubview(favouriteButton)
        favouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        favouriteButton.setImage(UIImage(systemName: "star.fill"), for: .selected) 
        favouriteButton.addTarget(self, action: #selector(favouriteButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        calloriesLabel.translatesAutoresizingMaskIntoConstraints = false
        favouriteButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            calloriesLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            calloriesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            calloriesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            calloriesLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            favouriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favouriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            favouriteButton.widthAnchor.constraint(equalToConstant: 30),
            favouriteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    func configure(with model: FruitModel) {
        nameLabel.text = model.name
        calloriesLabel.text = "\(model.callories) per 100g"              
        applyAccessibility() 
    }

    private func applyAccessibility() {
        nameLabel.isAccessibilityElement = true           
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.font = UIFont.scaledFont(name: "Helvetica", textSize: 20)

        calloriesLabel.isAccessibilityElement = true    
        calloriesLabel.adjustsFontForContentSizeCategory = true
        calloriesLabel.font = UIFont.scaledFont(name: "Helvetica", textSize: 15)

        favouriteButton.isAccessibilityElement = true
        favouriteButton.accessibilityLabel = "favourite"        
        favouriteButton.accessibilityHint = favouriteButton.isSelected ? "makes favourite" : "removes favourite"
    }

    @objc private func favouriteButtonTapped() {
        favouriteButton.isSelected.toggle()
    }
}

final class ViewController: UIViewController {

    private let tableView = UITableView()
    private let fruits: [FruitModel] = {
        let data = fruitJson.data(using: .utf8)!
        return try! JSONDecoder().decode([FruitModel].self, from: data)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        self.title = "Fruits Calories Counter"
    }

    private func setupUI() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(FruitTableViewCell.self, forCellReuseIdentifier: FruitTableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fruits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FruitTableViewCell.reuseIdentifier, for: indexPath) as! FruitTableViewCell        
        cell.configure(with: fruits[indexPath.row])
        return cell
    }

}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

extension UIFont {
   /// Scaled and styled version of any custom Font
   ///
   /// - Parameters:
   ///   - name: Name of the Font
   ///   - textSize: text size i.e 10, 15, 20, ...
   /// - Returns: The scaled custom Font version with the given size
   static func scaledFont(name: String, textSize size: CGFloat) -> UIFont {
    guard let customFont = UIFont(name: name, size: size) else {
       fatalError("Failed to load the \(name) font.")
    }
    return UIFontMetrics.default.scaledFont(for: customFont)
  }
}
