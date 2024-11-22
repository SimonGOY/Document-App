import UIKit
import QuickLook

class DocumentTableViewController: UITableViewController {

    // Structure pour représenter un fichier
    struct DocumentFile {
        var title: String         // Titre du fichier
        var size: Int             // Taille en octets
        var imageName: String?    // Nom de l'image associée
        var url: URL              // URL du fichier
        var type: String          // Type MIME
    }

    // Liste des fichiers par section
    var bundleFiles = [DocumentFile]()    // Fichiers dans le bundle
    var importedFiles = [DocumentFile]()  // Fichiers importés
    var selectedFileURL: URL?             // URL du fichier sélectionné pour la prévisualisation

    override func viewDidLoad() {
        super.viewDidLoad()

        // Charger les fichiers des deux sources
        bundleFiles = listFileInBundle()
        importedFiles = listFileInStorage()

        // Ajouter un bouton "+" dans la barre de navigation
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDocument))

        // Recharger le tableau
        tableView.reloadData()
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Une section pour les fichiers Bundle et une pour les fichiers Importés
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return bundleFiles.count // Section Bundle
        } else {
            return importedFiles.count // Section Importés
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Bundle" // Titre de la section Bundle
        } else {
            return "Importés" // Titre de la section Importés
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DocumentCell")

        // Récupérer le document correspondant à la ligne et à la section
        let document: DocumentFile
        if indexPath.section == 0 {
            document = bundleFiles[indexPath.row] // Section Bundle
        } else {
            document = importedFiles[indexPath.row] // Section Importés
        }

        // Configurer la cellule
        cell.textLabel?.text = document.title
        cell.detailTextLabel?.text = "Size: \(document.size.formattedSize())"
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedDocument: DocumentFile

        // Sélectionner le document en fonction de la section
        if indexPath.section == 0 {
            selectedDocument = bundleFiles[indexPath.row] // Section Bundle
        } else {
            selectedDocument = importedFiles[indexPath.row] // Section Importés
        }

        // Assigner l'URL du fichier sélectionné
        self.selectedFileURL = selectedDocument.url

        // Vérifier si l'URL du fichier est valide avant d'ouvrir le QLPreviewController
        if let fileURL = selectedFileURL, fileURL.isFileURL {
            self.instantiateQLPreviewController(withUrl: fileURL)
        } else {
            // Afficher une alerte si l'URL du fichier n'est pas valide
            let alert = UIAlertController(title: "Erreur", message: "Le fichier sélectionné n'est pas valide.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func instantiateQLPreviewController(withUrl url: URL) {
        // Créer un QLPreviewController
        let previewController = QLPreviewController()

        // Vérifier si l'URL est bien un fichier local avant de l'assigner au QLPreviewController
        if url.isFileURL {
            previewController.dataSource = self
            self.navigationController?.pushViewController(previewController, animated: true)
        } else {
            // Si ce n'est pas un fichier valide, afficher un message d'erreur
            let alert = UIAlertController(title: "Erreur", message: "Le fichier n'est pas accessible pour la prévisualisation.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
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
        let supportedExtensions = ["jpg", "jpeg", "png", "gif"]
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

    // Fonction pour lister les fichiers dans le répertoire Documents
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

    // MARK: - UIDocumentPickerDelegate

}

extension DocumentTableViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1 // Toujours un seul fichier à prévisualiser
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        // Retourner l'URL valide pour le prévisualisateur
        guard let fileURL = selectedFileURL else {
            fatalError("Le fichier sélectionné est invalide ou inexistant.")
        }
        return fileURL as QLPreviewItem
    }
}

extension DocumentTableViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedUrl = urls.first else { return }

        do {
            let fileManager = FileManager.default
            let appDocumentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let targetUrl = appDocumentsDir.appendingPathComponent(selectedUrl.lastPathComponent)

            if !fileManager.fileExists(atPath: targetUrl.path) {
                try fileManager.copyItem(at: selectedUrl, to: targetUrl)
            }

            let resourcesValues = try targetUrl.resourceValues(forKeys: [.contentTypeKey, .nameKey, .fileSizeKey])
            let newDocument = DocumentFile(
                title: resourcesValues.name ?? "Unknown",
                size: resourcesValues.fileSize ?? 0,
                imageName: nil,
                url: targetUrl,
                type: resourcesValues.contentType?.description ?? "Unknown"
            )
            importedFiles.append(newDocument) // Ajouter aux fichiers importés
            tableView.reloadData()
        } catch {
            print("Erreur lors de l'importation : \(error)")
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("L'utilisateur a annulé la sélection.")
    }
}

// Extension pour formater les tailles de fichiers
extension Int {
    func formattedSize() -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(self))
    }
}
