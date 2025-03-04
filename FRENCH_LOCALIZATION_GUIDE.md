# Guide de localisation française pour l'application Real Estate
# (French Localization Guide for Real Estate App)

Ce guide vous aidera à ajouter la traduction française à votre application iOS Real Estate.

## Table des matières

1. [Préparation du projet pour la localisation](#préparation-du-projet-pour-la-localisation)
2. [Création des fichiers de traduction](#création-des-fichiers-de-traduction)
3. [Implémentation de la localisation dans le code](#implémentation-de-la-localisation-dans-le-code)
4. [Test de la localisation](#test-de-la-localisation)
5. [Traductions françaises](#traductions-françaises)

## Préparation du projet pour la localisation

### Étape 1: Configurer le projet Xcode

1. Ouvrez votre projet dans Xcode
2. Sélectionnez votre projet dans le navigateur de projet
3. Sélectionnez votre cible (target) principale
4. Allez dans l'onglet "Info"
5. Sous "Localizations", cliquez sur le bouton "+" et ajoutez "French (fr)"
6. Cochez tous les fichiers que vous souhaitez localiser

### Étape 2: Créer un fichier Localizable.strings

1. Dans Xcode, allez à File > New > File...
2. Sélectionnez "Strings File"
3. Nommez-le "Localizable.strings"
4. Ajoutez-le à votre cible principale
5. Sélectionnez le fichier Localizable.strings dans le navigateur de projet
6. Dans l'inspecteur de fichier (panneau de droite), cliquez sur "Localize..."
7. Sélectionnez "English" comme langue de base
8. Ensuite, cochez "French" dans la liste des localisations

## Création des fichiers de traduction

### Fichier Localizable.strings (English)

Créez d'abord la version anglaise avec toutes les chaînes de caractères de votre application:

```
// General
"app_name" = "Real Estate";
"loading" = "Loading...";
"error" = "Error";
"retry" = "Retry";
"cancel" = "Cancel";
"save" = "Save";
"delete" = "Delete";
"edit" = "Edit";
"done" = "Done";

// Authentication
"login" = "Login";
"signup" = "Sign Up";
"email" = "Email";
"password" = "Password";
"forgot_password" = "Forgot Password?";
"logout" = "Log Out";
"profile" = "Profile";

// Property Listings
"properties" = "Properties";
"property_details" = "Property Details";
"price" = "Price";
"bedrooms" = "Bedrooms";
"bathrooms" = "Bathrooms";
"area" = "Area";
"address" = "Address";
"description" = "Description";
"contact" = "Contact";
"favorites" = "Favorites";
"no_favorites" = "You don't have any favorites yet";
"add_to_favorites" = "Add to Favorites";
"remove_from_favorites" = "Remove from Favorites";

// Filters
"filters" = "Filters";
"min_price" = "Min Price";
"max_price" = "Max Price";
"property_type" = "Property Type";
"sort_by" = "Sort By";
"apply_filters" = "Apply Filters";
"reset_filters" = "Reset Filters";

// Property Types
"house" = "House";
"apartment" = "Apartment";
"condo" = "Condo";
"villa" = "Villa";
"land" = "Land";

// Admin
"admin" = "Admin";
"add_property" = "Add Property";
"edit_property" = "Edit Property";
"delete_property" = "Delete Property";
"property_title" = "Property Title";
"upload_images" = "Upload Images";
"select_location" = "Select Location";

// Map
"map" = "Map";
"list" = "List";
"view_on_map" = "View on Map";

// Errors
"login_error" = "Failed to login. Please check your credentials.";
"signup_error" = "Failed to create account. Please try again.";
"load_properties_error" = "Failed to load properties. Please try again.";
"save_property_error" = "Failed to save property. Please try again.";
"network_error" = "Network error. Please check your connection.";
```

### Fichier Localizable.strings (French)

Ensuite, créez la version française:

```
// General
"app_name" = "Immobilier";
"loading" = "Chargement...";
"error" = "Erreur";
"retry" = "Réessayer";
"cancel" = "Annuler";
"save" = "Enregistrer";
"delete" = "Supprimer";
"edit" = "Modifier";
"done" = "Terminé";

// Authentication
"login" = "Connexion";
"signup" = "Inscription";
"email" = "Email";
"password" = "Mot de passe";
"forgot_password" = "Mot de passe oublié ?";
"logout" = "Déconnexion";
"profile" = "Profil";

// Property Listings
"properties" = "Propriétés";
"property_details" = "Détails de la propriété";
"price" = "Prix";
"bedrooms" = "Chambres";
"bathrooms" = "Salles de bain";
"area" = "Surface";
"address" = "Adresse";
"description" = "Description";
"contact" = "Contact";
"favorites" = "Favoris";
"no_favorites" = "Vous n'avez pas encore de favoris";
"add_to_favorites" = "Ajouter aux favoris";
"remove_from_favorites" = "Retirer des favoris";

// Filters
"filters" = "Filtres";
"min_price" = "Prix minimum";
"max_price" = "Prix maximum";
"property_type" = "Type de propriété";
"sort_by" = "Trier par";
"apply_filters" = "Appliquer les filtres";
"reset_filters" = "Réinitialiser les filtres";

// Property Types
"house" = "Maison";
"apartment" = "Appartement";
"condo" = "Copropriété";
"villa" = "Villa";
"land" = "Terrain";

// Admin
"admin" = "Admin";
"add_property" = "Ajouter une propriété";
"edit_property" = "Modifier la propriété";
"delete_property" = "Supprimer la propriété";
"property_title" = "Titre de la propriété";
"upload_images" = "Télécharger des images";
"select_location" = "Sélectionner l'emplacement";

// Map
"map" = "Carte";
"list" = "Liste";
"view_on_map" = "Voir sur la carte";

// Errors
"login_error" = "Échec de connexion. Veuillez vérifier vos identifiants.";
"signup_error" = "Échec de création de compte. Veuillez réessayer.";
"load_properties_error" = "Échec de chargement des propriétés. Veuillez réessayer.";
"save_property_error" = "Échec d'enregistrement de la propriété. Veuillez réessayer.";
"network_error" = "Erreur réseau. Veuillez vérifier votre connexion.";
```

## Implémentation de la localisation dans le code

### Utilisation de NSLocalizedString

Dans votre code Swift, remplacez toutes les chaînes de caractères en dur par des appels à `NSLocalizedString`:

```swift
// Avant
Text("Properties")

// Après
Text(NSLocalizedString("properties", comment: "Property listings tab title"))
```

Pour simplifier l'utilisation, vous pouvez créer une extension:

```swift
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

// Utilisation
Text("properties".localized)
```

### Exemple de mise à jour d'une vue

Voici comment vous pourriez mettre à jour votre ContentView:

```swift
struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                LandingView()
            }
            .tabItem {
                Label {
                    Text("properties".localized)
                } icon: {
                    Image(systemName: "house.fill")
                }
            }
            
            NavigationView {
                FavoritesView()
            }
            .tabItem {
                Label {
                    Text("favorites".localized)
                } icon: {
                    Image(systemName: "heart.fill")
                }
            }
            
            // Autres onglets...
        }
    }
}
```

## Test de la localisation

### Tester dans le simulateur

1. Lancez votre application dans le simulateur
2. Allez dans Paramètres > Général > Langue et région
3. Changez la langue en Français
4. Relancez votre application

### Tester dans Xcode

Vous pouvez également tester la localisation directement dans Xcode:

1. Sélectionnez votre schéma de build
2. Cliquez sur "Edit Scheme..."
3. Sous "Run" > "Options", définissez "Application Language" sur "French"
4. Exécutez l'application

## Traductions françaises supplémentaires

### Termes immobiliers spécifiques

```
"square_meters" = "mètres carrés";
"square_feet" = "pieds carrés";
"for_sale" = "À vendre";
"for_rent" = "À louer";
"monthly" = "par mois";
"yearly" = "par an";
"furnished" = "Meublé";
"unfurnished" = "Non meublé";
"new_construction" = "Construction neuve";
"year_built" = "Année de construction";
"garage" = "Garage";
"parking" = "Stationnement";
"balcony" = "Balcon";
"garden" = "Jardin";
"pool" = "Piscine";
"elevator" = "Ascenseur";
"air_conditioning" = "Climatisation";
"heating" = "Chauffage";
"security_system" = "Système de sécurité";
```

### Messages d'information

```
"property_added_success" = "Propriété ajoutée avec succès";
"property_updated_success" = "Propriété mise à jour avec succès";
"property_deleted_success" = "Propriété supprimée avec succès";
"account_created_success" = "Compte créé avec succès";
"password_reset_email_sent" = "Email de réinitialisation du mot de passe envoyé";
"location_permission_needed" = "L'autorisation de localisation est nécessaire pour afficher les propriétés à proximité";
"no_properties_found" = "Aucune propriété trouvée";
"filter_no_results" = "Aucun résultat pour ces filtres";
```

## Ressources supplémentaires

- [Documentation Apple sur la localisation](https://developer.apple.com/documentation/xcode/localization)
- [Guide de style français pour iOS](https://developer.apple.com/fr/design/human-interface-guidelines/language-support/)
- [Outils de traduction en ligne](https://www.deepl.com/translator)

---

N'oubliez pas de tester votre application avec différentes longueurs de texte, car les traductions françaises sont souvent plus longues que les textes anglais, ce qui peut affecter la mise en page. 