//
//  StudyListViewController.swift
//  jsontables
//
//  Created by Robert Diamond on 3/22/21.
//

import Dispatch
import UIKit

class StudyListViewController: UITableViewController {
  lazy var studySource = StudyDataSource()
  var studies : [Study]? {
    didSet {
      self.tableView.reloadData()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    studySource.fetchStudies(difficulty : 1, count : 5) { [weak self] studyList, error in
      guard let self = self else { return }
      if let error = error {
        print(error)
        return
      }
      DispatchQueue.main.async {
        self.studies = studyList
      }
    }
  }
}

