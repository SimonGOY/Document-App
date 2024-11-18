//
//  DocumentTableViewController.swift
//  Document App
//
//  Created by Simon GOY on 11/18/24.
//

import UIKit

class DocumentTableViewController: UITableViewController {
    
    struct DocumentFile {
        var title: String
        var size: Int
        var imageName: String? = nil
        var url: URL
        var type: String
    }
    
    static var documentsFile = [
        DocumentFile(title: "Document 1", size: 100, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
        DocumentFile(title: "Document 2", size: 200, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
        DocumentFile(title: "Document 3", size: 300, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
        DocumentFile(title: "Document 4", size: 400, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
        DocumentFile(title: "Document 5", size: 500, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
        DocumentFile(title: "Document 6", size: 600, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
        DocumentFile(title: "Document 7", size: 700, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
        DocumentFile(title: "Document 8", size: 800, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
        DocumentFile(title: "Document 9", size: 900, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
        DocumentFile(title: "Document 10", size: 1000, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Documents"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DocumentTableViewController.documentsFile.count
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DocumentCell")
        let document = DocumentTableViewController.documentsFile[indexPath.row]
        
        cell.textLabel?.text = document.title
        cell.detailTextLabel?.text = "Size: \(document.size.formattedSize())"
        
        if let imageName = document.imageName, let image = UIImage(named: imageName) {
            cell.imageView?.image = image
        } else {
            cell.imageView?.image = UIImage(systemName: "doc.text")
        }
        
        return cell
    }
}

extension Int {
    // Extension de Int pour formater la taille en Bytes, KB, MB, GB
    func formattedSize() -> String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB] // Limiter aux unités pertinentes
        byteCountFormatter.countStyle = .file
        
        return byteCountFormatter.string(fromByteCount: Int64(self))
    }
}
