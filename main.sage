load("src/paillier.sage")
load("src/NdTrials/serverNd.sage")
load("src/NdTrials/clientNd.sage")

import random

# --- CONFIGURATION 6D ---
dim = 6
ell = 2
size = ell^dim  # 64 éléments

# 1. Base de données avec des valeurs ALÉATOIRES (ex: entre 1000 et 9999)
database = [ZZ(random.randint(1000, 9999)) for _ in range(size)]

# 2. Index cible ALÉATOIRE (entre 0 et 63)
target_idx = random.randint(0, size - 1)

# 3. Conversion de l'index plat en coordonnées [c1, c2, c3, c4, c5, c6]
target_coords = []
temp_idx = target_idx
for i in range(dim):
    # On extrait les bits de l'index (pour ell=2, c'est du binaire)
    coord = (temp_idx // (ell**(dim - 1 - i))) % ell
    target_coords.append(int(coord))

expected_val = database[target_idx]

# --- INITIALISATION ---
crypto = Paillier(bits=1024) 
client = PIRClientND(crypto)
server = PIRServerND(database, dim, ell)

print(f"--- TEST PIR {dim}D ALÉATOIRE ---")
print(f"Base de données : {size} éléments aléatoires.")
print(f"Index cible choisi : {target_idx}")
print(f"Coordonnées générées : {target_coords}")
print(f"Valeur à trouver : {expected_val}")

# --- EXÉCUTION ---
print("\n[STEP 1] Client : Chiffrement de la requête...")
query = client.generate_query(target_coords, ell)

print("[STEP 2] Serveur : Calcul homomorphe récursif...")
response = server.answer_query(query, crypto)

print("[STEP 3] Client : Déchiffrement de l'oignon...")
result = client.decrypt_result(response)

# --- VERDICT ---
print(f"\n{'='*40}")
print(f"Cible réelle : {expected_val}")
print(f"Résultat PIR : {result}")

if result == expected_val:
    print("✅ SUCCÈS : L'algorithme a trouvé la bonne valeur aléatoire !")
else:
    print("❌ ÉCHEC : Il y a un problème dans la logique de reconstruction.")
print(f"{'='*40}")