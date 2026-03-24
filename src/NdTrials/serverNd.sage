from sage.all import *


class PIRServerND:
    def __init__(self, database, dim, ell):
        self.nDimData = database 
        self.dim = dim
        self.ell = ell



    def answer_query_Nd (self, user_entry, crypto):

        """
        Calcule la réponse homomorphe à travers toutes les dimensions.
        user_entry : Liste de 'dim' vecteurs chiffrés.
        Exemple (3D) : [V_alpha, V_beta, V_gamma]
        """

        dim = self.dim
        n = crypto.n
        n2 = crypto.n2


        # --- ÉTAPE 1 : Réduction de la Dimension 1 ---
        # On réduit l'hypercube de départ à un hypercube de dimension (dim-1).
        # On utilise le premier vecteur (V1) envoyé par l'utilisateur.
        # Exemple 3D : On réduit un Cube (L^3) en une liste de L^2 résultats.

        # 1. Calcul des Sigmas (Première réduction)
        # On utilise le premier vecteur de l'utilisateur (V1)
        filtered = []


        print(user_entry)

        # On passe user_entry[0] car sigma_computing n'a besoin que du 1er vecteur
        self.sigma_computing(user_entry[0], n2 , filtered, self.dim,0)
        
        print(f"[DEBUG] Après Sigma Computing : {len(filtered)} chiffrés obtenus.")
        
        print(filtered)


        # --- ÉTAPE 2 : Boucle de réduction récursive (Dimensions 2 à D) ---
        # À chaque tour de boucle, on réduit la dimension de 1 cran.
        # On passe de dim-1 -> dim-2 -> ... -> Résultat final.

        # 2. Réduction itérative pour les dimensions restantes
        # On prend les vecteurs V2, V3... Vd on retire le V1
        remaining_queries = user_entry[1:]
        current_dim = 2

        for current_v in remaining_queries:
            print(f"[DEBUG] Réduction Dimension {current_dim}...")
            # A. SPLITTING : On traite les chiffrés comme des données claires.
            # On coupe chaque chiffré C en deux : u = C // n et v = C % n.
            # Cela double le nombre d'éléments dans la liste 'splits'.

            # On transforme chaque chiffré en deux clairs (u, v)
            splits = self.spliting(filtered,n)
            print(f"  > Splitting effectué : {len(splits)} valeurs claires générées.")

            # B. FILTERING : On applique l'homomorphisme de Paillier.
            # On combine les morceaux (u, v) avec le vecteur de la dimension actuelle.
            # On utilise : E(m) = Prod( g_i^m_i ) mod n^2
            # On réduit avec le vecteur de la dimension actuelle
            filtered = self.filtering(current_v,splits,n2)

            print(f"  > Filtering terminé : {len(filtered)} chiffrés restants.")
            current_dim += 1

        return filtered

    def spliting (self,filtered_splits,n):
        splits = []
        for unsplit in filtered_splits:
            splits.append(unsplit // n)
            splits.append(unsplit % n)
        return splits
        
    def filtering(self, relevant_user_entry, splits, n2):

        """
        Réduit la dimension actuelle en utilisant l'homomorphisme.
        Exemple (passage 2D->1D) :
        Si on a 4 splits [u_ligne1, v_ligne1, u_ligne2, v_ligne2] et ell=2.
        On va produire 2 nouveaux chiffrés :
        Res_U = E(selection_1 * u_ligne1 + selection_2 * u_ligne2)
        Res_V = E(selection_1 * v_ligne1 + selection_2 * v_ligne2)
        """

        # num_components représente le nombre de chiffrés "mères" 
        # (ex: si on a 8 splits et ell=2, on a 4 groupes à recombiner)        num_components = len(splits) // self.ell
        num_components = len(splits) // self.ell
        filtered = []
        
        for i in range(num_components):
            # Pour chaque composante (ex: UU, UV...), on applique le PIR
            res_comp = 1
            for d in range(self.ell):
                # On regroupe les splits de chaque tranche d.
                # L'indexation 'i + d * num_components' permet de garder 
                # la structure (U, V, UU, VV...) cohérente pour le déchiffrement.
                val_claire = splits[i + d * num_components]

                # Multiplication homomorphe : E(m)^k = E(m*k)
                res_comp = (res_comp * power_mod(relevant_user_entry[d], val_claire, n2)) % n2
            filtered.append(res_comp)
        return filtered


    def sigma_computing(self, v_selection, n2, sigmas, unfixed_dimension_nb, current_idx):
        # v_selection est user_entry[0] (une liste de chiffrés)
        
        if unfixed_dimension_nb == 1:
            sigma_i = 1
            for i in range(self.ell):
                # On multiplie par la donnée de la base (0 ou 1)
                data_val = self.nDimData[current_idx + i]
                # Homomorphisme : E(s_i)^data_val
                sigma_i = (sigma_i * power_mod(v_selection[i], data_val, n2)) % n2
            sigmas.append(sigma_i)
        else:
            # On descend récursivement dans les dimensions
            step = self.ell**(unfixed_dimension_nb - 1)
            for i in range(self.ell):
                self.sigma_computing(v_selection, n2, sigmas, unfixed_dimension_nb - 1, current_idx + i * step)