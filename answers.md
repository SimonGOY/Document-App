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

Une propriété statique en programmation est une propriété attachée à une classe plutôt qu'à une instance de cette classe. Cela signifie qu'elle est partagée par toutes les instances de la classe et qu'elle peut être utilisée sans créer d'objet à partir de cette classe.