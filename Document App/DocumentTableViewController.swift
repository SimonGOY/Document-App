import UIKit
import QuickLook

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
    var selectedFileURL: URL? // URL du fichier actuellement sélectionné

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Charger les fichiers du bundle et les assigner au tableau
        documentsFile = listFileInBundle() + listFileInStorage()
        
        // Ajouter un bouton "+" dans la barre de navigation pour importer des documents
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDocument))
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DocumentCell")
        
        // Récupérer le document correspondant à la ligne
        let document = documentsFile[indexPath.row]
        
        // Configurer le texte principal et les détails de la cellule
        cell.textLabel?.text = document.title
        cell.detailTextLabel?.text = "Size: \(document.size.formattedSize())"
        cell.accessoryType = .disclosureIndicator // Ajouter une flèche pour indiquer un détail

        return cell
    }

    // MARK: - Gestion de la sélection des lignes
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDocument = documentsFile[indexPath.row]
        self.instantiateQLPreviewController(withUrl: selectedDocument.url)
    }

    // Fonction pour instancier et présenter un QLPreviewController
    func instantiateQLPreviewController(withUrl url: URL) {
        selectedFileURL = url // Stocker l'URL sélectionnée

        let previewController = QLPreviewController()
        previewController.dataSource = self // Définir le dataSource sur self
        self.navigationController?.pushViewController(previewController, animated: true)
    }

    // MARK: - Importation de fichiers via UIDocumentPicker
    @objc func addDocument() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }

    // Fonction pour lister les fichiers dans le bundle principal
    func listFileInBundle() -> [DocumentFile] {
        let supportedExtensions = ["jpg", "jpeg", "png", "gif"] // Types d'images pris en charge
        let fm = FileManager.default
        guard let path = Bundle.main.resourcePath else { return [] }
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        var documentListBundle = [DocumentFile]()
        
        for item in items {
            if let fileExtension = item.split(separator: ".").last,
               supportedExtensions.contains(fileExtension.lowercased()) {
                let currentUrl = URL(fileURLWithPath: path + "/" + item)
                if let resourcesValues = try? currentUrl.resourceValues(forKeys: [.contentTypeKey, .nameKey, .fileSizeKey]) {
                    documentListBundle.append(DocumentFile(
                        title: resourcesValues.name ?? "Unknown",
                        size: resourcesValues.fileSize ?? 0,
                        imageName: item,
                        url: currentUrl,
                        type: resourcesValues.contentType?.description ?? "Unknown"
                    ))
                }
            }
        }
        return documentListBundle
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

}

// Extension pour formater les tailles de fichiers
extension Int {
    func formattedSize() -> String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        byteCountFormatter.countStyle = .file
        return byteCountFormatter.string(fromByteCount: Int64(self))
    }
}

// Extension pour le protocole QLPreviewControllerDataSource
extension DocumentTableViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return selectedFileURL != nil ? 1 : 0
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return selectedFileURL! as QLPreviewItem
    }
}

// Extension pour le protocole UIDocumentPickerDelegate
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
