from src.paillier import Paillier

def run_tests():

    crypto = Paillier(bits=128)

    # Test simple
    m = 1234
    assert crypto.decrypt(crypto.encrypt(m)) == m

    # Test addition
    m1, m2 = 10, 20
    c1 = crypto.encrypt(m1)
    c2 = crypto.encrypt(m2)

    c_sum = crypto.add(c1, c2)
    assert crypto.decrypt(c_sum) == (m1 + m2) % crypto.n

    # Test multiplication scalaire
    k = 5
    c_scalar = crypto.scalar_mult(c1, k)
    assert crypto.decrypt(c_scalar) == (m1 * k) % crypto.n

    print("✅ Tous les tests réussis")

run_tests()
