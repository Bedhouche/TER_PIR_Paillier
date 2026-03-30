from sage.all import *

class PIRClientND:
    def __init__(self, crypto_instance):
        self.crypto = crypto_instance

    def generate_query(self, target_coords, ell):
        # On inverse l'ordre des coordonnées pour correspondre à la récursion du serveur
        # La Dim 1 du serveur traite les voisins directs (dernière coordonnée)
        query_vectors = []
        for coord in reversed(target_coords):
            vec = [self.crypto.encrypt(1 if i == coord else 0) for i in range(ell)]
            query_vectors.append(vec)
        return query_vectors

    def decrypt_result(self, response_list):
        n = self.crypto.n
        print(f"\n[CLIENT] Déchiffrement de la couche finale (Paillier)")
        current_values = [self.crypto.decrypt(c) for c in response_list]
        print(f" > Valeurs après premier déchiffrement: {current_values}")
        
        level = 1
        while len(current_values) > 1:
            print(f"\n[CLIENT] Reconstruction Niveau {level}")
            next_level = []
            for i in range(0, len(current_values), 2):
                u = current_values[i]
                v = current_values[i+1]
                # C'est ici que la magie de Chang opère
                m_recomposed = (u * n + v) % self.crypto.n2
                val = self.crypto.decrypt(m_recomposed)
                print(f" > Paire ({u}, {v}) -> Recomposé: {m_recomposed} -> Déchiffré: {val}")
                next_level.append(val)
            current_values = next_level
            level += 1
            
        return current_values[0]