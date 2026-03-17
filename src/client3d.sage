from sage.all import *
load("src/paillier.sage")

class PIRClient3D:

    def __init__(self, bits=1024):
        self.crypto = Paillier(bits)

    def generate_query(self, i_star, j_star,k_star , ell):
        """
        Génère les vecteurs alpha , beta  et gamma chiffrés
        """

        alpha = []
        beta = []
        gamma = []

        for t in range(ell):

            # Vecteur ligne
            if t == i_star:
                alpha.append(self.crypto.encrypt(1))
            else:
                alpha.append(self.crypto.encrypt(0))

            # Vecteur colonne
            if t == j_star:
                beta.append(self.crypto.encrypt(1))
            else:
                beta.append(self.crypto.encrypt(0))

            if t == k_star:
                gamma.append(self.crypto.encrypt(1))
            else :
                gamma.append(self.crypto.encrypt(0))

        return alpha, beta , gamma

    def decrypt_result(self, response):
        """
        Reconstruction selon le Lemme 6 : triple déchiffrement récursif.
        """
        UU, UV, VU, VV = response
        n = self.crypto.n

        # Triple déchiffrement récursif (Peler l'oignon)
        # 1. Retrait couche Gamma
        d_uu = self.crypto.decrypt(UU)
        d_uv = self.crypto.decrypt(UV)
        d_vu = self.crypto.decrypt(VU)
        d_vv = self.crypto.decrypt(VV)

        # 2. Reconstruction couche intermédiaire (Alpha/Beta)
        u_k_star = d_uu * n + d_uv
        v_k_star = d_vu * n + d_vv

        # 3. Retrait couche Alpha/Beta
        d_u = self.crypto.decrypt(u_k_star)
        d_v = self.crypto.decrypt(v_k_star)
        
        # 4. Déchiffrement final (Valeur DB)
        s_star = d_u * n + d_v
        return self.crypto.decrypt(s_star)