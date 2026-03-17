from sage.all import *

class PIRServer3D:
    def __init__(self, database, ell):
        self.ell = ell
        self.cube = []
        idx = 0
        
        for i in range(ell):
            plane = []
            for j in range(ell):
                row = []
                for k in range(ell):
                    row.append(database[idx])
                    idx += 1
                plane.append(row)
            self.cube.append(plane)

    def answer_query(self, alpha, beta, gamma, crypto):

        ell = self.ell
        n = crypto.n
        n2 = crypto.n2

        UU, UV, VU, VV = 1, 1, 1, 1

        for d in range(ell):
            # 1. PIR 2D sur la tranche d (Colonnes)
            col_vector = []
            for i in range(ell):
                val_i = 1
                for j in range(ell):
                    val_i = (val_i * power_mod(beta[j], self.cube[d][i][j], n2)) % n2
                col_vector.append(val_i)

            # 2. PIR 2D sur la tranche d (Lignes + Split interne)
            u_d_enc, v_d_enc = 1, 1
            for i in range(ell):
                s_i = ZZ(col_vector[i])
                u_d_enc = (u_d_enc * power_mod(alpha[i], s_i // n, n2)) % n2
                v_d_enc = (v_d_enc * power_mod(alpha[i], s_i % n, n2)) % n2

            # 3. Splitting (Etape du papier : u_d = uud*n + uvd)
            u_val, v_val = ZZ(u_d_enc), ZZ(v_d_enc)
            uud, uvd = u_val // n, u_val % n
            vud, vvd = v_val // n, v_val % n

            # 4. Filtering avec gamma (Agrégation homomorphe)
            UU = (UU * power_mod(gamma[d], uud, n2)) % n2
            UV = (UV * power_mod(gamma[d], uvd, n2)) % n2
            VU = (VU * power_mod(gamma[d], vud, n2)) % n2
            VV = (VV * power_mod(gamma[d], vvd, n2)) % n2

        return (UU, UV, VU, VV)