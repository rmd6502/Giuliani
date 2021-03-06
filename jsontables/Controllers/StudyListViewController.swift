//
//  StudyListViewController.swift
//  jsontables
//
//  Created by Robert Diamond on 3/22/21.
//

import Dispatch
import UIKit

protocol SearchingProtocol {
  func searchStudies(difficulty : Int, count : Int)
}

class StudyListViewController: UITableViewController, SearchingProtocol {
  lazy var studySource = StudyDataSource()
  var tableImageHeights = [Int : CGFloat]()
  var images = [String : UIImage]()
  let DEFAULT_CELL_HEIGHT : CGFloat = 50
  var studies = [Study]() {
    didSet {
      self.tableView.reloadData()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    //tableView.register(StudyCell.self, forCellReuseIdentifier: "studyCell")
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    searchStudies(difficulty: 1, count: 5)
  }

  func searchStudies(difficulty : Int, count : Int) {
    studySource.fetchStudies(difficulty : difficulty, count : count) { [weak self] studyList, error in
      guard let self = self else { return }
      if let error = error {
        print(error)
        return
      }
      if let studyList = studyList {
        DispatchQueue.main.async {
          self.studies = studyList
        }
      }
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return studies.count
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if let height = tableImageHeights[indexPath.item] {
      return height
    } else {
      return DEFAULT_CELL_HEIGHT
    }
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    tableImageHeights.removeAll()
    self.tableView.reloadData()
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     // Fetch a cell of the appropriate type.
    let cell = tableView.dequeueReusableCell(withIdentifier: "studyCell", for: indexPath)
    if let cell = cell as? StudyCell {
      cell.imageView?.translatesAutoresizingMaskIntoConstraints = false;
      cell.imageView?.contentMode = .scaleAspectFit
      let study = studies[indexPath.item]
      cell.studyNumber?.text = "Study Number \(study.studyNum)"

      if let imageUrl = URL(string: study.studyPath) {
        if let image = images[study.studyPath] {
          cell.studyImage?.image = image
            var ratio : CGFloat = 1
            if image.size.width != 0 {
           ratio = image.size.height / image.size.width
            }
            if (tableImageHeights[indexPath.item] == nil) {
          tableImageHeights[indexPath.item] = cell.studyNumber.sizeThatFits(cell.contentView.bounds.size).height + 8 + cell.contentView.bounds.size.width * ratio
            }
        } else {
            if (tableImageHeights[indexPath.item] == nil) {
          tableImageHeights[indexPath.item] = cell.studyNumber.sizeThatFits(cell.contentView.bounds.size).height + 8
            }
            images[study.studyPath] = UIImage()
          URLSession(configuration: .default).dataTask(with: imageUrl) { [weak self]
            data, response, error in
            guard let self = self else { return }
            if error != nil {
              print(error?.localizedDescription ?? "problem fetching URL")
              return
            }
            let response = response as? HTTPURLResponse
            if response == nil || !(200...299).contains(response!.statusCode) {
              print("Failed to fetch image data")
              return
            }
            if let data = data {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async { [weak self, weak cell] in
                        guard let self = self, let cell = cell else { return }
                  cell.studyImage?.image = image
                        self.images[study.studyPath] = image
                  let ratio = image.size.height / image.size.width
                  tableView.beginUpdates()
                  self.tableImageHeights[indexPath.item] = cell.studyNumber.sizeThatFits(cell.contentView.bounds.size).height + 8 + cell.contentView.bounds.size.width * ratio
                  cell.setNeedsLayout()
                  tableView.endUpdates()
                }
              }
            }
          }.resume()
        }
      }
    }

     return cell
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let dest = segue.destination as? SearchParametersController {
      dest.delegate = self
    }
  }
}
