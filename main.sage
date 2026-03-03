import os

# On récupère le dossier où se trouve le script main.sage
os.chdir("/home/sage/project")

load("src/paillier.sage")
load("src/client.sage")
load("src/server.sage")

# ------------------------
# Base de données
# ------------------------

ell = 2
database = [5, 9,
            3, 7]

client = PIRClient2D(bits=128)
server = PIRServer2D(database, ell)

# On veut l'élément (1,0) → valeur 3
i_star = 1
j_star = 0

alpha, beta = client.generate_query(i_star, j_star, ell)

encrypted_result = server.answer_query(alpha, beta, client.crypto)

result = client.decrypt_result(encrypted_result)

print("Élément demandé :", database[i_star*ell + j_star])
print("Résultat PIR :", result)
