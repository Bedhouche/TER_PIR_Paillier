from sage.all import *

class Paillier:
    """
    Implémentation du cryptosystème de Paillier.
    """

    # =============================
    # KEY GENERATION
    # =============================
    def __init__(self, bits=4):

        self.bits = bits
        self.keygen()

    def keygen(self):
        """
        Génération des clés publiques et privées.
        """

        # 1. Choisir p, q premiers distincts
        # self.p = random_prime(2**self.bits, lbound=2**(self.bits-1))
        # self.q = random_prime(2**self.bits, lbound=2**(self.bits-1))
        self.p = 5
        self.q = 3
        while self.p == self.q:
            self.q = random_prime(2**self.bits, lbound=2**(self.bits-1))

        # 2. Calcul de n et n²
        self.n = self.p * self.q
        self.n2 = self.n**2

        # 3. Choix de g
        self.g = self.n + 1

        # 4. Clé privée
        self.lam = lcm(self.p - 1, self.q - 1)

        self.mu = inverse_mod(self.lam, self.n)

        print(f"[+] Clés générées ({self.n.nbits()} bits)")

    # =============================
    # FONCTION L
    # =============================
    def _L(self, u):
    	"""
    	Fonction L(u) = (u - 1) / n
    	Valide seulement si u ≡ 1 mod n
    	"""
    	return (u - 1) // self.n

    # =============================
    # ENCRYPTION
    # =============================
    def encrypt(self, m):

        m = ZZ(m)

        if m < 0 or m >= self.n:
            raise ValueError("m doit appartenir à Z_n")

        # r dans Z*_n
        # r = ZZ.random_element(1, self.n)
        # while gcd(r, self.n) != 1:
        #     r = ZZ.random_element(1, self.n)

        # Optimisation : (n+1)^m mod n² = 1 + m*n
        gm = (1 + m * self.n) % self.n2

        # rn = power_mod(r, self.n, self.n2)

        # c = (gm * rn) % self.n2

        # return c
        return gm
    # =============================
    # DECRYPTION
    # =============================
    def decrypt(self, c):

        c = ZZ(c)
        u = power_mod(c, self.lam, self.n2)
        m = (self._L(u) * self.mu) % self.n

        return m

    # =============================
    # OPERATIONS HOMOMORPHIQUES
    # =============================
    def add(self, c1, c2):
        return (c1 * c2) % self.n2

    def scalar_mult(self, c, k):
        k = ZZ(k)
        return power_mod(c, k, self.n2)
