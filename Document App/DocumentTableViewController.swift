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
        
        // Ajouter un bouton "+" dans la barre de navigation
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDocument))
        
        // Recharger le TableView avec les nouvelles données
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDocumentSegue" { // Vérifiez que l'identifiant correspond à celui défini dans le storyboard
            // Récupérer l'index de la ligne sélectionnée
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedDocument = documentsFile[indexPath.row] // Document sélectionné
                
                // Cibler le DocumentViewController
                if let detailVC = segue.destination as? DocumentViewController {
                    detailVC.imageName = selectedDocument.imageName // Transmettre le nom de l'image
                }
            }
        }
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
        let supportedExtensions = ["jpg", "jpeg", "png", "gif"] // Types d'images pris en charge
        
        let fm = FileManager.default // Gestionnaire de fichiers
        guard let path = Bundle.main.resourcePath else { return [] } // Chemin des ressources du bundle
        let items = try! fm.contentsOfDirectory(atPath: path) // Liste des fichiers dans le bundle
        
        var documentListBundle = [DocumentFile]() // Liste des fichiers validés
        
        for item in items {
            // Vérifier si le fichier a une extension prise en charge
            if let fileExtension = item.split(separator: ".").last,
               supportedExtensions.contains(fileExtension.lowercased()) {
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
    
    func listFileInStorage() -> [DocumentFile] {
        let fileManager = FileManager.default
        guard let appDocumentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
        
        do {
            let items = try fileManager.contentsOfDirectory(at: appDocumentsDir, includingPropertiesForKeys: [.contentTypeKey, .nameKey, .fileSizeKey], options: .skipsHiddenFiles)
            return items.map { url in
                let resourcesValues = try? url.resourceValues(forKeys: [.contentTypeKey, .nameKey, .fileSizeKey])
                return DocumentFile(
                    title: resourcesValues?.name ?? "Unknown",
                    size: resourcesValues?.fileSize ?? 0,
                    imageName: nil,
                    url: url,
                    type: resourcesValues?.contentType?.description ?? "Unknown"
                )
            }
        } catch {
            print("Erreur lors de la lecture des fichiers : \(error)")
            return []
        }
    }

    
    @objc func addDocument() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
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

extension DocumentTableViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedUrl = urls.first else { return }
        
        do {
            // Copier le fichier dans le répertoire de l'application
            let fileManager = FileManager.default
            let appDocumentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let targetUrl = appDocumentsDir.appendingPathComponent(selectedUrl.lastPathComponent)
            
            if !fileManager.fileExists(atPath: targetUrl.path) {
                try fileManager.copyItem(at: selectedUrl, to: targetUrl)
            }
            
            // Mettre à jour la liste des fichiers
            let resourcesValues = try targetUrl.resourceValues(forKeys: [.contentTypeKey, .nameKey, .fileSizeKey])
            let newDocument = DocumentFile(
                title: resourcesValues.name ?? "Unknown",
                size: resourcesValues.fileSize ?? 0,
                imageName: nil, // Pas d'image associée pour le moment
                url: targetUrl,
                type: resourcesValues.contentType?.description ?? "Unknown"
            )
            documentsFile.append(newDocument)
            tableView.reloadData()
        } catch {
            print("Erreur lors de l'importation : \(error)")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("L'utilisateur a annulé la sélection.")
    }
}
