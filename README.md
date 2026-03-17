
# TER_PIR_Paillier
# TER PIR – Implémentation du chiffrement de Paillier en SageMath

# 🔐 PIR 3D basé sur Paillier (Schéma c-Hypercube)


## Description

Ce projet implémente un schéma de Private Information Retrieval (PIR)
sur un hypercube 3D en utilisant le cryptosystème de Paillier.

Le protocole suit la construction récursive décrite dans les travaux
sur les schémas c-hypercube (ici c = 3).

Le système permet à un utilisateur de récupérer un élément
x(i*, j*, k*) d’une base de données sans révéler son index au serveur.



Ce projet implémente le **chiffrement homomorphe additif de Paillier** en **SageMath**.  

À ce stade, le code permet :  

1. Génération de **clés publiques et privées** (`Paillier(bits)`)  
2. Chiffrement d’un message entier `m` (`encrypt(m)`)  
3. Déchiffrement d’un message chiffré `c` (`decrypt(c)`)  
4. Vérification de l’**homomorphisme additif** : `E(m1) * E(m2) = E(m1+m2)`  

---
---

## 🧠 Principe Mathématique

La base de données est vue comme un cube :

    x(i, j, k)

Le protocole fonctionne en 4 étapes :

### 1️⃣ Initialisation

Le serveur traite la base comme ℓ matrices 2D :

    x^(d)(i, j) = x(i, j, d)

---

### 2️⃣ Invocation du PIR 2D

Pour chaque tranche d :

Le serveur applique le protocole PIR 2D
et obtient deux valeurs chiffrées :

    u^(d)
    v^(d)

---

### 3️⃣ Splitting

Chaque valeur est écrite sous la forme :

    u^(d) = u_u^(d) * n + u_v^(d)
    v^(d) = v_u^(d) * n + v_v^(d)

avec tous les coefficients dans Z_n.

---

### 4️⃣ Filtering

Le serveur calcule :

    UU = ∏ γ_d^(u_v^(d))
    UV = ∏ γ_d^(u_u^(d))
    VU = ∏ γ_d^(v_v^(d))
    VV = ∏ γ_d^(v_v^(d))

où γ_d est le message envoyé par le client.

Le serveur renvoie :

    (UU, UV, VU, VV)

---

## 🔓 Reconstruction Client

Le client effectue :

1. Déchiffrement des 4 valeurs.
2. Reconstruction intermédiaire :
       u = d(UU)*n + d(UV)
       v = d(VU)*n + d(VV)
3. Recomposition finale :
       s = u*n + v
4. Déchiffrement final.

---

## 🔐 Cryptosystème utilisé

Le projet utilise le cryptosystème de Paillier :

- Sécurité basée sur la difficulté du problème composite residuosity.
- Propriété homomorphique additive.
- Fonction L pour la décryption.

---


## 📊 Paramètres de test

- Hypercube : 4×4×4
- Base de données : entiers 32 bits
- Clés : 1024 bits
- Tests unitaires inclus pour serveur et client.

---
## 📊 Paramètres de test

- Hypercube : 4×4×4
- Base de données : entiers 32 bits
- Clés : 1024 bits
- Tests unitaires inclus pour serveur et client.

---

## 📁 Structure du projet

src/
 ├── paillier.sage : 
          Implémentation du cryptosystème (chiffrement asymétrique homomorphe).

 ├── client3d.sage :
          Logique utilisateur (génération de requêtes chiffrées et reconstruction).
 ├── server3d.sage : 
          Logique serveur (calculs sur les données chiffrées sans déchiffrement).

test/
 ├── test_paillier.sage
 ├── test_client3d.sage

main.sage :
      Script de démonstration avec paramètres de sécurité réels.

# 🛠 Installation et Dépendances

## 📌 1. Prérequis

Ce projet nécessite :

- **SageMath** (version recommandée : ≥ 9.x)
- Un système Linux (recommandé)
- Python intégré à Sage (aucune installation externe requise)


Tout est implémenté en Sage natif.

---

## 📥 2. Installation de SageMath

### 🔹 Sous Linux (recommandé)

```bash
sudo apt update
sudo apt install sagemath
```
---

### pour verifier

```bash
sage --version
```

### 🔹 Pour lancer le test 

```bash
sage main.sage

```
