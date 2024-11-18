//
//  DocumentTableViewController.swift
//  Document App
//
//  Created by Simon GOY on 11/18/24.
//

import UIKit

class DocumentTableViewController: UITableViewController {
    
    // Structure pour représenter un fichier de document
    struct DocumentFile {
        var title: String         // Titre du fichier
        var size: Int             // Taille en octets
        var imageName: String?    // Nom de l'image associée (facultatif)
        var url: URL              // URL du fichier
        var type: String          // Type MIME du fichier
    }
    
    // Liste des fichiers à afficher dans le TableView
    var documentsFile = [DocumentFile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Charger les fichiers du bundle et les assigner au tableau
        documentsFile = listFileInBundle()
        
        // Recharger le TableView avec les nouvelles données
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // Une seule section
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentsFile.count // Nombre de fichiers dans la liste
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Réutiliser ou créer une cellule
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DocumentCell")
        
        // Récupérer le document correspondant à la ligne
        let document = documentsFile[indexPath.row]
        
        // Configurer le texte principal et les détails de la cellule
        cell.textLabel?.text = document.title
        cell.detailTextLabel?.text = "Size: \(document.size.formattedSize())"
        
        return cell
    }
    
    // Fonction pour lister les fichiers dans le bundle principal
    func listFileInBundle() -> [DocumentFile] {
        
        let fm = FileManager.default // Gestionnaire de fichiers
        guard let path = Bundle.main.resourcePath else { return [] } // Chemin des ressources du bundle
        let items = try! fm.contentsOfDirectory(atPath: path) // Liste des fichiers dans le bundle
        
        var documentListBundle = [DocumentFile]() // Liste des fichiers validés
        
        for item in items {
            // Filtrer les fichiers pour exclure les fichiers système et inclure uniquement les ".jpg"
            if !item.hasSuffix("DS_Store") && item.hasSuffix(".jpg") {
                let currentUrl = URL(fileURLWithPath: path + "/" + item) // URL complète du fichier
                
                // Récupération des métadonnées (nom, type, taille)
                if let resourcesValues = try? currentUrl.resourceValues(forKeys: [.contentTypeKey, .nameKey, .fileSizeKey]) {
                    documentListBundle.append(DocumentFile(
                        title: resourcesValues.name ?? "Unknown",      // Nom du fichier
                        size: resourcesValues.fileSize ?? 0,          // Taille du fichier
                        imageName: item,                              // Nom de l'image
                        url: currentUrl,                              // URL complète
                        type: resourcesValues.contentType?.description ?? "Unknown" // Type MIME
                    ))
                }
            }
        }
        return documentListBundle // Retourner la liste des fichiers trouvés
    }
}

// Extension pour formater les tailles de fichiers
extension Int {
    func formattedSize() -> String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB] // Limiter aux unités pertinentes
        byteCountFormatter.countStyle = .file
        
        return byteCountFormatter.string(fromByteCount: Int64(self))
    }
}
