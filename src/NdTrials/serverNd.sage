from sage.all import *

class PIRServerND:
    def __init__(self, database, dim, ell):
        self.database = database
        self.dim = dim
        self.ell = ell

    def answer_query(self, query_vectors, crypto):
        n = crypto.n
        n2 = crypto.n2

        print(f"\n[SERVEUR] Réduction Dimension 1 (Initiale)")
        current_ciphertexts = []
        for i in range(0, len(self.database), self.ell):
            chunk = self.database[i : i + self.ell]
            res = 1
            for j in range(len(chunk)):
                res = (res * power_mod(query_vectors[0][j], chunk[j], n2)) % n2
            current_ciphertexts.append(res)
        
        print(f" > Après Dim 1: {len(current_ciphertexts)} chiffrés générés")

        for d in range(1, self.dim):
            print(f"\n[SERVEUR] Réduction Dimension {d+1}")
            # A. Splitting
            splits = []
            for c in current_ciphertexts:
                val = ZZ(c)
                splits.append(val // n)
                splits.append(val % n)
            
            print(f" > Splitting: {len(current_ciphertexts)} chiffrés -> {len(splits)} clairs")
            
            # B. Filtering
            current_ciphertexts = self._filter_step(splits, query_vectors[d], n2)
            print(f" > Après Dim {d+1}: {len(current_ciphertexts)} chiffrés restants")

        return current_ciphertexts

    def _filter_step(self, splits, query_vec, n2):
        res_list = []
        num_elements = len(splits) // self.ell
        for i in range(num_elements):
            acc = 1
            for j in range(self.ell):
                idx = i + j * num_elements
                acc = (acc * power_mod(query_vec[j], splits[idx], n2)) % n2
            res_list.append(acc)
        return res_list