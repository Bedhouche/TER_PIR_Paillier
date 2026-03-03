from sage.all import *

class PIRServer2D:

    def __init__(self, database, ell):
        """
        database : liste de taille ell^2
        """
        self.ell = ell

        # transformer en matrice 2D
        self.matrix = []

        for i in range(ell):
            row = []
            for j in range(ell):
                row.append(database[i*ell + j])
            self.matrix.append(row)

    def answer_query(self, alpha, beta, crypto):

        ell = self.ell
        n2 = crypto.n2

        # -----------------------
        # Étape 1 : filtrage colonne
        # -----------------------

        sigma = []

        for i in range(ell):

            row_result = 1

            for j in range(ell):

                # Enc(I(j,j*))^x[i][j]
                row_result = (row_result * power_mod(beta[j], self.matrix[i][j], n2)) % n2


            sigma.append(row_result)

        # -----------------------
        # Étape 2 : filtrage ligne
        # -----------------------

        result = 1

        for i in range(ell):

# Décrypter alpha[i] pour savoir si c'est 1 ou 0
            alpha_val = crypto.decrypt(alpha[i])
            result = (result * power_mod(sigma[i], alpha_val, n2)) % n2
            
        return result
