import UIKit

class DocumentTableViewController: UITableViewController, UISearchBarDelegate {

    struct DocumentFile {
        var title: String
        var size: Int
        var imageName: String?
        var url: URL
        var type: String
    }

    var bundleFiles = [DocumentFile]()
    var importedFiles = [DocumentFile]()
    var filteredFiles = [DocumentFile]()
    var isSearching = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Charger les fichiers du bundle et les assigner aux tableaux
        bundleFiles = listFileInBundle()
        importedFiles = listFileInStorage()
        filteredFiles = bundleFiles + importedFiles // Initialisation avec tous les fichiers

        // Ajouter un bouton "+" dans la barre de navigation
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDocument))

        // Ajouter la Search Bar
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Rechercher un document"
        navigationItem.titleView = searchBar

        // Recharger le TableView avec les nouvelles données
        tableView.reloadData()
    }

    // MARK: - Search Bar Delegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterDocuments(searchText: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filterDocuments(searchText: "")
    }

    // Fonction de filtrage des documents
    func filterDocuments(searchText: String) {
        if searchText.isEmpty {
            filteredFiles = bundleFiles + importedFiles // Afficher tous les fichiers
        } else {
            filteredFiles = (bundleFiles + importedFiles).filter { document in
                // Comparaison des titres des documents avec le texte de recherche
                return document.title.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDocumentSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedDocument = filteredFiles[indexPath.row] // Document sélectionné
                if let detailVC = segue.destination as? DocumentViewController {
                    detailVC.imageName = selectedDocument.imageName
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Deux sections : Bundle et Importés
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // Filtrer les fichiers du bundle
            return filteredFiles.filter { document in
                bundleFiles.contains(where: { $0.title == document.title })
            }.count
        } else {
            // Filtrer les fichiers importés
            return filteredFiles.filter { document in
                importedFiles.contains(where: { $0.title == document.title })
            }.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DocumentCell")
        
        let document: DocumentFile
        if indexPath.section == 0 {
            // Fichiers du bundle
            document = filteredFiles.filter { document in
                bundleFiles.contains(where: { $0.title == document.title })
            }[indexPath.row]
        } else {
            // Fichiers importés
            document = filteredFiles.filter { document in
                importedFiles.contains(where: { $0.title == document.title })
            }[indexPath.row]
        }
        
        cell.textLabel?.text = document.title
        cell.detailTextLabel?.text = "Size: \(document.size.formattedSize())"
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Bundle" : "Importés"
    }

    // Fonction pour lister les fichiers dans le bundle principal
    func listFileInBundle() -> [DocumentFile] {
        let supportedExtensions = ["jpg", "jpeg", "png", "gif"]
        let fm = FileManager.default
        guard let path = Bundle.main.resourcePath else { return [] }
        let items = try! fm.contentsOfDirectory(atPath: path)

        var documentListBundle = [DocumentFile]()

        for item in items {
            if let fileExtension = item.split(separator: ".").last, supportedExtensions.contains(fileExtension.lowercased()) {
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

    @objc func addDocument() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
}

// MARK: - Extensions

extension Int {
    func formattedSize() -> String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        byteCountFormatter.countStyle = .file
        return byteCountFormatter.string(fromByteCount: Int64(self))
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
            importedFiles.append(newDocument)
            filteredFiles = bundleFiles + importedFiles
            tableView.reloadData()
        } catch {
            print("Erreur lors de l'importation : \(error)")
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("L'utilisateur a annulé la sélection.")
    }
}
