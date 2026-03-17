load("src/paillier.sage")
load("src/client3d.sage")
load("src/server3d.sage")

# Configuration réelle
# Hypercube 4x4x4 = 64 éléments
ell = 4
# On remplit avec des nombres de 32 bits pour simuler des vraies données
database = [ZZ.random_element(2**31, 2**32) for _ in range(ell**3)]

# Choix secret
k, i, j = 3, 1, 2
expected = database[k*ell^2 + i*ell + j]

print(f"--- TEST PIR 3D (Parameters: n=2048 bits, DB=64 elements) ---")
client = PIRClient3D(bits=1024) 
server = PIRServer3D(database, ell)

alpha, beta, gamma = client.generate_query(i, j, k, ell)
response = server.answer_query(alpha, beta, gamma, client.crypto)
result = client.decrypt_result(response)

print(f"Index cible: ({k},{i},{j}) | Valeur: {expected}")
print(f"Résultat décrypté: {result}")

if result == expected:
    print("✅ TEST RÉUSSI : Le protocole est robuste sur de grands entiers.")