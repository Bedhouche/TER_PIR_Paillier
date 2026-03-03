from sage.all import *
load("src/paillier.sage")

class PIRClient2D:

    def __init__(self, bits=1024):
        self.crypto = Paillier(bits)

    def generate_query(self, i_star, j_star, ell):
        """
        Génère les vecteurs alpha et beta chiffrés
        """

        alpha = []
        beta = []

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

        return alpha, beta

    def decrypt_result(self, c):
        return self.crypto.decrypt(c)
