# Réponses


## 1 - Environnement

### Exercice 1 :

- **Targets** : Les Targets dans UIKit permettent de définir les actions que les composants de l'interface utilisateur doivent exécuter lorsqu'un événement spécifique se produit. Par exemple, lorsqu'un utilisateur interagit avec un bouton, un Target associe cet événement à une méthode précise dans le code. En pratique, cela se fait en utilisant la méthode addTarget(_:action:for:), où l'on spécifie l'objet (le "target"), la méthode à exécuter (l'"action") et le type d'événement (comme un appui ou un relâchement du bouton). Cette fonctionnalité est essentielle pour gérer les interactions utilisateur et lier efficacement l'interface graphique à la logique de l'application.
- **Fichiers de base** : 

    - __AppDelegate__ : Le fichier AppDelegate gère les événements globaux de l'application, comme son lancement, son passage en arrière-plan ou sa fermeture. Il sert également à configurer des services partagés, comme les notifications ou la persistance des données.
    - __SceneDelegate__ : Le SceneDelegate gère la configuration et la gestion des scènes (UI multi-fenêtres), notamment la création de l'interface utilisateur et la gestion des états des scènes pour les applications iOS modernes.
    - __ViewController__ : Le ViewController contient la logique et le code de gestion pour une vue spécifique de l'application. Il contrôle l'affichage et interagit avec les éléments de l'interface utilisateur pour répondre aux actions de l'utilisateur.
    - __Info__ : Le fichier Info.plist contient des informations de configuration importantes pour l'application, comme son nom, son identifiant unique, ses autorisations ou ses paramètres spécifiques liés au système.

- **Assets** : Le dossier Assets.xcassets stocke les ressources de l'application, telles que les images, les icônes et les couleurs utilisées dans l'interface utilisateur.
- **Main** : Le fichier Main.storyboard définit graphiquement la structure des vues de l'application et leurs relations, comme les transitions entre les écrans via des segues.
- **LaunchScreen** : Le fichier LaunchScreen.storyboard est utilisé pour afficher un écran temporaire (splash screen) au lancement de l'application, donnant une impression de fluidité pendant son chargement.
- **Simulateur** : Le simulateur est une sorte de machine virtuelle (un téléphone), il permet de tester les fonctionnalité comme si elles étaient déployées.

### Exercice 2 :

- **Cmd + R** : build l'application et lance (ou relance) le simulateur avec l'application.
- **Cmd + shift + o** : recherche rapide.
- **Indenter** : Ctrl + I
- **Commenter** : Cmd + :

### Exercice 3 :

- **Changer d'appareil** : Barre au dessus du code, "DocumentApp" > menu deroulant des appareils.

## 3 - Délégation 

### Exercice 1 :

Une propriété statique en programmation est une propriété attachée à une classe plutôt qu'à une instance de cette classe. Cela signifie qu'elle est partagée par toutes les instances de la classe et qu'elle peut être utilisée sans créer d'objet à partir de cette classe.

### Exercice 2 :

La méthode dequeueReusableCell est essentielle pour optimiser les performances des tables dans les applications iOS. Elle permet de réutiliser les cellules déjà affichées à l'écran, plutôt que de créer de nouvelles instances à chaque fois qu'une cellule doit être affichée. Cela réduit la consommation de mémoire, améliore la fluidité du défilement et évite des recalculs inutiles, car les cellules réutilisées conservent leur état. En réutilisant les cellules plutôt qu'en les recréant, l'application devient plus rapide, plus réactive et plus économe en ressources, ce qui est crucial pour les listes longues et les appareils mobiles à ressources limitées.

## 4 - Navigation :

### Exercice 1 : 

En ajoutant un NavigationController via le menu Embed In > Navigation Controller, nous avons encapsulé notre TableViewController dans une hiérarchie de navigation. Cela signifie que notre TableViewController devient la racine d'une pile de vues gérée par le NavigationController. Cela permet d'ajouter facilement la navigation entre plusieurs pages de l'application, comme passer d'une liste à un détail, tout en bénéficiant d'une NavigationBar intégrée.
- Le NavigationController sert à : 
    - Gérer une pile de contrôleurs de vue
    - Faciliter la navigation
    - Afficher une NavigationBar


- NavigationBar : Élément visuel affiché en haut de l'écran, contenant le titre et des boutons.
- NavigationController : Contrôleur logique qui gère la pile de vues et permet la navigation entre les écrans.
- La NavigationBar est une partie visible, tandis que le NavigationController gère la logique de navigation.

## 6 - Ecran 

### Exercice 1

Un Segue en Swift est une transition entre deux ViewControllers dans un Storyboard. Il sert à naviguer d'un écran à un autre, comme afficher un détail après avoir sélectionné un élément dans une liste. Le Segue automatise cette navigation, souvent sans nécessiter de code supplémentaire.

### Exercice 2

Une constraint (contrainte) en Swift est une règle qui définit la position et la taille d'un élément d'interface dans une vue. Elle sert à définir comment un élément doit se positionner par rapport aux autres éléments ou à son parent, tout en permettant de gérer différentes tailles d'écrans (réactivité).

Les constraints font partie du système AutoLayout, qui permet de définir des interfaces dynamiques et adaptatives, garantissant ainsi que l'interface s'ajuste correctement sur différents appareils et orientations. Grâce aux contraintes, AutoLayout peut automatiquement redimensionner et repositionner les éléments en fonction de la taille de l'écran.


## QLPreview 

### Code :
Voir la branch QLPreview

### Pourquoi serait-il pertinent de changer l’accessory des cellules en disclosureIndicator ?

Le disclosureIndicator est pertinent car il indique clairement que sélectionner une cellule mène à une action ou une vue détaillée, comme l'ouverture d'un document. Cela rend l'application cohérente avec les standards iOS, améliore l'expérience utilisateur et facilite la navigation intuitive.

## Importation

### Expliquez ce qu’est un #selector en Swift
Un #selector est une référence à une méthode qui peut être appelée dynamiquement à l'exécution. Cela est nécessaire lorsque vous passez une méthode comme action pour des événements d'UI (boutons, gestes, etc.).
### Que représente .add dans notre appel ?
.add est une constante prédéfinie du type UIBarButtonSystemItem. Elle représente un bouton avec une icône “+” standardisée par Apple.
### Expliquez également pourquoi XCode vous demande de mettre le mot clé @objc devant la fonction ciblée par le #selector
Le mot-clé @objc rend la méthode compatible avec Objective-C, nécessaire pour les mécanismes dynamiques comme #selector, qui reposent sur le runtime Objective-C.
### Peut-on ajouter plusieurs boutons dans la barre de navigation ? Si oui, comment en code ?
Oui, on peut ajouter plusieurs boutons en utilisant la propriété navigationItem.rightBarButtonItems, qui accepte un tableau de UIBarButtonItem :
```Swift
navigationItem.rightBarButtonItems = [
    UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDocument)),
    UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editDocuments))
]
```

Pour voir les fichiers, utiliser la branche QLPreview, la branche main ne permet pas d'afficher autre chose que des images.

### A quoi sert la fonction defer ?

Le mot-clé defer en Swift permet d'exécuter un bloc de code juste avant la sortie de la fonction ou méthode, quel que soit le chemin de sortie (qu'il y ait un return, une erreur, etc.). Il est souvent utilisé pour garantir que des actions de nettoyage, comme fermer des fichiers ou libérer des ressources, sont toujours effectuées à la fin de la fonction. Si plusieurs blocs defer sont utilisés, ils s'exécutent dans l'ordre inverse de leur déclaration.