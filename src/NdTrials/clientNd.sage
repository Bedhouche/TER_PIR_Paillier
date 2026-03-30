from sage.all import *

class PIRClientND:
    def __init__(self, crypto_instance):
        self.crypto = crypto_instance

    def generate_query(self, target_coords, ell):
        # On garde l'ordre direct des dimensions
        return [[self.crypto.encrypt(1 if i == c else 0) for i in range(ell)] for c in target_coords]

    def decrypt_result(self, response_list):
        return self._recursive_decrypt(response_list)

    def _recursive_decrypt(self, values):
        n, n2 = self.crypto.n, self.crypto.n2
        
        # Si on a une liste de chiffrés, on déchiffre d'abord la couche Paillier
        # Si ce sont déjà des entiers (issus d'un déchiffrement précédent), on continue
        decrypted = [self.crypto.decrypt(v) if v > n else v for v in values]

        # Cas de base : Il ne reste qu'une valeur
        if len(decrypted) == 1:
            return decrypted[0]

        # Cas récursif : Recomposition (u*n + v)
        next_level = []
        for i in range(0, len(decrypted), 2):
            u, v = decrypted[i], decrypted[i+1]
            m_recomposed = (u * n + v) % n2
            # On déchiffre pour enlever une couche de la récursion de Chang
            next_level.append(self.crypto.decrypt(m_recomposed))
            
        return self._recursive_decrypt(next_level)