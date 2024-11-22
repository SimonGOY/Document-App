import UIKit
import QuickLook

class DocumentTableViewController: UITableViewController {
    
    struct DocumentFile {
        var title: String
        var size: Int
        var imageName: String?
        var url: URL
        var type: String
    }
    
    var documentsFile = [DocumentFile]()
    var selectedFileURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Charger les fichiers du bundle et du stockage
        documentsFile = listFileInBundle() + listFileInStorage()
        
        // Ajouter un bouton "+" dans la barre de navigation
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDocument))
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentsFile.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DocumentCell")
        
        let document = documentsFile[indexPath.row]
        
        cell.textLabel?.text = document.title
        cell.detailTextLabel?.text = "Size: \(document.size.formattedSize())"
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDocument = documentsFile[indexPath.row]
        self.instantiateQLPreviewController(withUrl: selectedDocument.url)
    }

    func instantiateQLPreviewController(withUrl url: URL) {
        selectedFileURL = url
        let previewController = QLPreviewController()
        previewController.dataSource = self
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

