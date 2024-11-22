//
//  DocumentViewController.swift
//  Document App
//
//  Created by Simon GOY on 11/18/24.
//

import UIKit

class DocumentViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var imageName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let imageName = imageName {
            // Afficher l'image dans l'ImageView
            imageView.image = UIImage(named: imageName)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
