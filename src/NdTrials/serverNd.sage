from sage.all import *


def multi_exp(bases, exponents, mod):
    """
    Calcule le produit des (bases[i]^exponents[i]) % mod de façon optimisée.
    Algorithme de multi-exponentiation simultanée (Straus/Shamir trick).
    """
    if not bases:
        return 1
    
    # On s'assure que tout est au format Integer de Sage
    exponents = [ZZ(e) for e in exponents]
    
    # On détermine le nombre de bits maximum parmi les exposants
    max_exp = max(exponents)
    if max_exp == 0:
        return 1
    bit_length = max_exp.bit_length()
    
    res = 1
    # On parcourt les bits de gauche à droite
    for i in range(bit_length - 1, -1, -1):
        # Étape "Square" : on élève le résultat au carré une seule fois pour tout le monde
        res = (res * res) % mod
        
        # Étape "Multiply" : on multiplie par la base si le bit i de l'exposant est à 1
        for j in range(len(bases)):
            if (exponents[j] >> i) & 1:
                res = (res * bases[j]) % mod
    return res

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
            # res = 1
            # for j in range(len(current_db)):
            #    res = (res * power_mod(query_vectors[depth][j], current_db[j], n2)) % n2
            #return [res]
            return [multi_exp(query_vectors[depth], current_db, n2)]

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
            # acc_u = 1
            #acc_v = 1
            #for j in range(self.ell):
            #    acc_u = (acc_u * power_mod(query_vectors[depth][j], u_clairs[j], n2)) % n2
            #    acc_v = (acc_v * power_mod(query_vectors[depth][j], v_clairs[j], n2)) % n2
            
            acc_u = multi_exp(query_vectors[depth], u_clairs, n2)
            acc_v = multi_exp(query_vectors[depth], v_clairs, n2)
            
            final_layer.append(acc_u)
            final_layer.append(acc_v)

        return final_layer