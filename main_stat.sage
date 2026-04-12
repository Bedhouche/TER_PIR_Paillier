import time
import math
from sage.all import *
import random as py_random # Utilisation d'un alias pour éviter l'erreur AttributeError

load("src/paillier.sage")
load("src/NdTrials/serverNd.sage")
load("src/NdTrials/clientNd.sage")


dim = 1
ell = 4096       
bits_cle = 1024  
# =========================================================

size = ell^dim 

# 1. Base de données avec des valeurs ALÉATOIRES
database = [ZZ(py_random.randint(1000, 9999)) for _ in range(size)]

# 2. Index cible ALÉATOIRE
target_idx = py_random.randint(0, size - 1)

# 3. Conversion de l'index plat en coordonnées
target_coords = []
temp_idx = target_idx
for i in range(dim):
    coord = (temp_idx // (ell**(dim - 1 - i))) % ell
    target_coords.append(int(coord))

expected_val = database[target_idx]

# --- INITIALISATION ---
crypto = Paillier(bits=bits_cle) 
client = PIRClientND(crypto)
server = PIRServerND(database, dim, ell)

print(f"--- TEST PERFORMANCE PIR {dim}D ---")
print(f"Paramètres : Dim={dim}, ell={ell}, Total={size} éléments")
print(f"Sécurité : Clé de {bits_cle} bits")

# --- EXÉCUTION ---

# Mesure du temps Client (Génération)
t0_client = time.time()
query = client.generate_query(target_coords, ell)
t_gen = time.time() - t0_client

# Calcul de la taille de la requête (Communication montante)
# Chaque chiffré fait environ 2 * bits_cle
num_ciphers = sum(len(layer) for layer in query)
query_size_kb = (num_ciphers * (2 * bits_cle // 8)) / 1024

# Mesure du temps Serveur (Le plus important pour tes stats)
print(f"\n[Calcul Serveur en cours...]")
t0_server = time.time()
response = server.answer_query(query, crypto)
t_server = time.time() - t0_server

# Mesure du temps Client (Déchiffrement)
t0_dec = time.time()
result = client.decrypt_result(response)
t_dec = time.time() - t0_dec

# ---> AJOUT : Calcul du temps total PIR <---
t_total = t_gen + t_server + t_dec

# --- RÉSULTATS STATISTIQUES ---
print(f"\n{'-'*20} STATISTIQUES {'-'*20}")
print(f"1. Temps Serveur         : {float(t_server):.4f} secondes")
print(f"2. Taille Requête        : {float(query_size_kb):.2f} Ko ({num_ciphers} chiffrés)")
print(f"3. Temps Génér. Client   : {float(t_gen):.4f} secondes")
print(f"4. Temps Déchif. Client  : {float(t_dec):.4f} secondes")
print(f"5. Temps Total PIR       : {float(t_total):.4f} secondes")
print(f"{'-'*54}")

# --- VERDICT ---
if result == expected_val:
    print("✅ SUCCÈS : Valeur correcte trouvée.")
else:
    print("❌ ÉCHEC : Erreur de reconstruction.")