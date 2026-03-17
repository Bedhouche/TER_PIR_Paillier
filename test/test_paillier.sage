load("src/paillier.sage")

def run_tests():
    print("=== DÉBUT DES TESTS UNITAIRES : PAILLIER ===")
    
    # On utilise 128 bits pour que les tests soient significatifs
    cipher = Paillier(bits=128)
    n = cipher.n
    
    # --- TEST 1 : Chiffrement / Déchiffrement simple ---
    m1 = 12345
    c1 = cipher.encrypt(m1)
    d1 = cipher.decrypt(c1)
    assert d1 == m1, f"Erreur Test 1: Attendu {m1}, obtenu {d1}"
    print("[OK] Test 1 : Chiffrement/Déchiffrement de base")

    # --- TEST 2 : Propriété Homomorphe d'Addition ---
    # E(m1) * E(m2) mod n² doit déchiffrer m1 + m2 mod n
    m2 = 6789
    c2 = cipher.encrypt(m2)
    c_sum = cipher.add(c1, c2)
    d_sum = cipher.decrypt(c_sum)
    assert d_sum == (m1 + m2) % n, "Erreur Test 2: Somme homomorphe fausse"
    print("[OK] Test 2 : Addition homomorphe")

    # --- TEST 3 : Propriété de Multiplication par un scalaire ---
    # E(m1)^k mod n² doit déchiffrer k * m1 mod n
    k = 10
    c_mult = cipher.scalar_mult(c1, k)
    d_mult = cipher.decrypt(c_mult)
    assert d_mult == (k * m1) % n, "Erreur Test 3: Multiplication scalaire fausse"
    print("[OK] Test 3 : Multiplication scalaire homomorphe")

    # --- TEST 4 : Chiffrement de Zéro (Crucial pour le PIR) ---
    c_zero = cipher.encrypt(0)
    d_zero = cipher.decrypt(c_zero)
    assert d_zero == 0, "Erreur Test 4: Le déchiffrement de 0 a échoué"
    print("[OK] Test 4 : Chiffrement du message 0")

    # --- TEST 5 : Indistingabilité (Caractère probabiliste) ---
    # Deux chiffrements du même message doivent donner deux nombres différents
    c1_bis = cipher.encrypt(m1)
    assert c1 != c1_bis, "Erreur Test 5: Le chiffrement n'est pas probabiliste (r est identique ?)"
    print("[OK] Test 5 : Chiffrement probabiliste (Aléa r fonctionnel)")

    print("============================================")
    print("✅ TOUS LES TESTS ONT RÉUSSI !")

if __name__ == "__main__":
    run_tests()