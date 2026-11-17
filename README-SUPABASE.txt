AFFARYETTE — VERSION AMÉLIORÉE
================================

CONTENU
- Site vitrine et boutique
- Recherche, filtres et tri par prix
- Fiche produit
- Inscription / connexion via Supabase Auth
- Publication d'annonces avec images Supabase Storage
- Panier avec modification des quantités
- Checkout : coordonnées client, adresse, ville, téléphone
- Frais de livraison estimés à 8 DT
- Paiement à la livraison (aucun paiement bancaire simulé)
- Espace membre : mes annonces et historique des commandes
- Administration : produits, messages et statuts des commandes
- RLS (politiques de sécurité) dans le schéma SQL

INSTALLATION
1. Décompresser le dossier.
2. Ouvrir le projet avec VS Code.
3. Vérifier js/supabase-config.js : URL et clé Publishable Supabase.
   Ne jamais mettre une clé secret/service_role dans le navigateur.
4. Dans Supabase > SQL Editor, exécuter supabase-schema.sql.
   Si la base existe déjà, le script ajoute les colonnes et politiques nécessaires.
5. Dans Supabase > Authentication > URL Configuration, configurer le Site URL
   et les Redirect URLs selon l'adresse locale ou l'hébergement.
6. Créer un compte depuis compte.html et confirmer l'adresse e-mail si demandé.
7. Pour activer l'administration, remplacer VOTRE_EMAIL dans la dernière requête
   commentée du SQL par l'adresse du compte administrateur, puis exécuter cette requête.
8. Lancer avec Live Server (VS Code) ou un hébergement HTTPS.

IMPORTANT
- Le checkout enregistre une commande et choisit le paiement à la livraison.
- Les frais de livraison de 8 DT sont une estimation de démonstration à confirmer.
- Aucun prestataire de paiement en ligne n'est connecté.
- Les commandes et statuts sont enregistrés dans Supabase.
- Pour un vrai lancement commercial, faire vérifier les règles de prix, stock,
  livraison, modération, confidentialité et sécurité par un développeur.
- Le navigateur ne peut pas garantir seul le calcul du total. Pour une production,
  déplacer la création/calcul des commandes dans une fonction serveur (Edge Function)
  qui relit les prix en base et calcule le montant côté serveur.
- Le bucket d'images est public pour afficher les photos ; ne pas y stocker de données privées.

TESTS CONSEILLÉS
[ ] Créer un compte et confirmer l'e-mail.
[ ] Se connecter / se déconnecter.
[ ] Publier un article avec photo.
[ ] Rechercher, filtrer et ouvrir une fiche produit.
[ ] Ajouter au panier, modifier la quantité et supprimer.
[ ] Passer une commande avec adresse et téléphone.
[ ] Vérifier l'historique du client.
[ ] Se connecter avec le compte admin et changer le statut d'une commande.

MISES À JOUR DE LA VERSION FINALE
- Le panier propose le paiement en espèces à la livraison et le paiement électronique/virement avec confirmation manuelle.
- Le paiement électronique n'est pas un paiement par carte automatisé : il nécessite la confirmation du vendeur et la communication sécurisée des coordonnées de règlement.
- La page Produits propose une recherche visuelle : l'utilisateur peut importer une photo de référence, voir son aperçu puis décrire l'article dans la barre de recherche pour filtrer les annonces.
- Pour activer un véritable paiement par carte en ligne, il faut intégrer un prestataire de paiement compatible avec la Tunisie et configurer ses clés/API côté serveur.
