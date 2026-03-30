from sage.all import *

class PIRServerND:
    def __init__(self, database, dim, ell):
        self.database = database
        self.dim = dim
        self.ell = ell

    def answer_query(self, query_vectors, crypto):
        """
        Lance la récursion sur la base complète.
        """
        return self._recursive_reduce(self.database, query_vectors, crypto, depth=0)

    def _recursive_reduce(self, current_db, query_vectors, crypto, depth):
        n, n2 = crypto.n, crypto.n2
        
        # Cas de base : Dimension 1 (La couche la plus proche des données claires)
        if depth == self.dim - 1:
            # On réduit la liste de clairs en un seul chiffré
            res = 1
            for j in range(len(current_db)):
                res = (res * power_mod(query_vectors[depth][j], current_db[j], n2)) % n2
            return [res]

        # Cas récursif : Dimensions 2 à D
        # 1. On divise la base actuelle en 'ell' sous-blocs
        sub_size = len(current_db) // self.ell
        sub_results = []
        for i in range(self.ell):
            sub_block = current_db[i * sub_size : (i + 1) * sub_size]
            # Appel récursif pour obtenir les chiffrés du sous-bloc
            sub_results.append(self._recursive_reduce(sub_block, query_vectors, crypto, depth + 1))

        # 2. On applique le "Splitting" (Chang) sur les résultats chiffrés
        # sub_results est une liste de listes de chiffrés.
        final_layer = []
        num_ciphers = len(sub_results[0]) # Nombre de chiffrés par sous-bloc
        
        for k in range(num_ciphers):
            # On extrait les k-ièmes chiffrés de chaque bloc pour les combiner
            # A. Splitting
            u_clairs = [ZZ(sub_results[i][k]) // n for i in range(self.ell)]
            v_clairs = [ZZ(sub_results[i][k]) % n for i in range(self.ell)]
            
            # B. Filtering (Combinaison homomorphe avec le vecteur de requête de l'étage actuel)
            acc_u = 1
            acc_v = 1
            for j in range(self.ell):
                acc_u = (acc_u * power_mod(query_vectors[depth][j], u_clairs[j], n2)) % n2
                acc_v = (acc_v * power_mod(query_vectors[depth][j], v_clairs[j], n2)) % n2
            
            final_layer.append(acc_u)
            final_layer.append(acc_v)

        return final_layer