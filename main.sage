load("src/paillier.sage")
load("src/client3d.sage")
load("src/server3d.sage")
load("src/NdTrials/serverNd.sage")
load("src/NdTrials/clientNd.sage")


# Configuration réelle
# Hypercube 4x4x4 = 64 éléments
ell = 4
# On remplit avec des nombres de 32 bits pour simuler des vraies données
# database = [ZZ.random_element(2**31, 2**32) for _ in range(ell**3)]
testdata= [0,1,2,3]

# Choix secret
# k, i, j = 3, 1, 2
testi,testj= 0,1
# expected = database[k*ell^2 + i*ell + j]

print(f"--- TEST PIR 3D (Parameters: n=2048 bits, DB=64 elements) ---")
# client = PIRClient3D(bits=1024) 
# server = PIRServer3D(database, ell)
clientNd = PIRClientND(bits=1024)
serverNd = PIRServerND(testdata,2, 2)

# alpha, beta, gamma = client.generate_query(i, j, k, ell)

# response = server.answer_query(alpha, beta, gamma, client.crypto)
# result = client.decrypt_result(response)
responseNd = serverNd.answer_query_Nd([[clientNd.crypto.encrypt(1),clientNd.crypto.encrypt(0)],[clientNd.crypto.encrypt(0),clientNd.crypto.encrypt(1)]],clientNd.crypto)
resultNd = clientNd.decrypt_result(responseNd)

# print(f"Index cible: ({k},{i},{j}) | Valeur: {expected}")
# print(f"Résultat décrypté: {result}")
print(f"Résultat en N-d décrypté: {resultNd}")
# if result == expected:
#     print("✅ TEST RÉUSSI : Le protocole est robuste sur de grands entiers.")