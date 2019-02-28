//
//  ShowsAlert.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/13.
//  Copyright © 2017 NM. All rights reserved.
//

import Foundation
import UIKit

protocol ShowsAlert {}

extension ShowsAlert where Self: UIViewController {
    func showAlert(title: String = "Error", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
