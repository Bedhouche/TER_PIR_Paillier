from sage.all import *

class PIRClientND:
    def __init__(self, crypto_instance):
        self.crypto = crypto_instance

    def generate_query(self, target_coords, ell):
        query = []
        n = self.crypto.n
        n2 = self.crypto.n2
        
        for c in target_coords:
            layer = []
            for i in range(ell):
                m = 1 if i == c else 0
                r = ZZ.random_element(1, n)
                while gcd(r, n) != 1:
                    r = ZZ.random_element(1, n)
                
                # Ici on applique la logique : (1+m*n) * r^n mod n2
                # r^n peut être vu comme une multi_exp avec une seule base
                term_rn = multi_exp([r], [n], n2)
                term_gm = (1 + m * n) % n2
                
                layer.append((term_gm * term_rn) % n2)
            query.append(layer)
        return query

    def decrypt_result(self, response_list):
        return self._recursive_decrypt(response_list)

    def _recursive_decrypt(self, values):
        n = self.crypto.n
        
        # On déchiffre tout le bloc actuel d'un coup
        # C'est ici que l'optimisation CRT de ta classe Paillier brille !
        decrypted = [self.crypto.decrypt(v) for v in values]

        # Si on n'a qu'une valeur, c'est la donnée finale (en clair)
        if len(decrypted) == 1:
            return decrypted[0]

        # Recomposition (u, v) -> m_suivant
        # On divise la liste par 2 à chaque étape de la récursion
        next_level = []
        for i in range(0, len(decrypted), 2):
            u, v = decrypted[i], decrypted[i+1]
            m_recomposed = (u * n + v) 
            # m_recomposed est le CHIFFRÉ de l'étage suivant
            next_level.append(m_recomposed)
            
        return self._recursive_decrypt(next_level)