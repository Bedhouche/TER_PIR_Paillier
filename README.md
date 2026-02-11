
# TER_PIR_Paillier
# TER PIR – Implémentation du chiffrement de Paillier en SageMath

## Description

Ce projet implémente le **chiffrement homomorphe additif de Paillier** en **SageMath**.  

À ce stade, le code permet :  

1. Génération de **clés publiques et privées** (`Paillier(bits)`)  
2. Chiffrement d’un message entier `m` (`encrypt(m)`)  
3. Déchiffrement d’un message chiffré `c` (`decrypt(c)`)  
4. Vérification de l’**homomorphisme additif** : `E(m1) * E(m2) = E(m1+m2)`  

---

## Installation et dépendances

- SageMath 10.7  
- Fonctionne dans **Jupyter Notebook / Sage Notebook**  

Pour lancer Sage :

```bash
sage

