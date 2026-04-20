import time
import math
from sage.all import *
import random as py_random

load("src/paillier.sage")
load("src/NdTrials/serverNd.sage")
load("src/NdTrials/clientNd.sage")

# --- CONFIGURATION ---
dim = 12
ell = 2 
bits_cle = 1024 
size = ell^dim 

# 1. Base de données
database = [ZZ(py_random.randint(1000, 9999)) for _ in range(size)]
target_idx = py_random.randint(0, size - 1)

# 2. Conversion index -> coordonnées
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
print(f"Sécurité   : Clé de {bits_cle} bits")

# --- EXÉCUTION ---

# A. REQUÊTE (Client)
t0_client = time.time()
query = client.generate_query(target_coords, ell)
t_gen = time.time() - t0_client

# B. CALCUL SERVEUR
print(f"\n[Calcul Serveur en cours...]")
t0_server = time.time()
response = server.answer_query(query, crypto)
t_server = time.time() - t0_server

# C. RÉPONSE (Déchiffrement Client)
t0_dec = time.time()
result = client.decrypt_result(response)
t_dec = time.time() - t0_dec

# --- CALCUL DES TAILLES (COMMUNICATION) ---
# Taille d'un chiffré Paillier = n^2, soit 2 * bits_cle
taille_un_chiffre_octets = (2 * bits_cle) // 8

# 1. Taille Requête (Montante)
num_ciphers_query = sum(len(layer) for layer in query)
query_size_kb = (num_ciphers_query * taille_un_chiffre_octets) / 1024

# 2. Taille Réponse (Descendante) - NOUVEAU
num_ciphers_res = len(response)
res_size_kb = (num_ciphers_res * taille_un_chiffre_octets) / 1024

# 3. Communication Totale
total_comm_kb = query_size_kb + res_size_kb

# --- STATISTIQUES FINALES ---
print(f"\n{'-'*25} STATISTIQUES {'-'*25}")
print(f"1. Temps Serveur         : {float(t_server):.4f} s")
print(f"2. Temps Génér. Client   : {float(t_gen):.4f} s")
print(f"3. Temps Déchif. Client  : {float(t_dec):.4f} s")
print(f"4. Temps Total PIR       : {float(t_gen + t_server + t_dec):.4f} s")
print(f"{'.' * 64}")
print(f"5. Taille REQUÊTE        : {float(query_size_kb):.2f} Ko ({num_ciphers_query} chiffrés)")
print(f"6. Taille RÉPONSE        : {float(res_size_kb):.2f} Ko ({num_ciphers_res} chiffrés)")
print(f"7. COMM. TOTALE          : {float(total_comm_kb):.2f} Ko")
print(f"{'-'*64}")

# --- VERDICT ---
if result == expected_val:
    print("✅ SUCCÈS : Valeur correcte trouvée.")
else:
    print("❌ ÉCHEC : Erreur de reconstruction.")