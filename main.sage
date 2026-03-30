# --- main.sage ---
load("src/paillier.sage")
load("src/NdTrials/serverNd.sage")
load("src/NdTrials/clientNd.sage")

dim = 4
ell = 2
size = ell^dim # 16 éléments
database = [ZZ.random_element(1000) for _ in range(size)]

# Index cible (ex: 1, 0, 1, 1)
target_coords = [1, 0, 1, 1]
# Calcul de l'index à plat pour vérification
expected_idx = sum(target_coords[i] * (ell^(dim-1-i)) for i in range(dim))
expected_val = database[expected_idx]

crypto = Paillier(bits=1024)
client = PIRClientND(crypto)
server = PIRServerND(database, dim, ell)

print(f"--- TEST PIR {dim}D ---")
query = client.generate_query(target_coords, ell)
response = server.answer_query(query, crypto)
result = client.decrypt_result(response)

print(f"Attendu: {expected_val} | Obtenu: {result}")
print("Succès !" if result == expected_val else "Échec...")