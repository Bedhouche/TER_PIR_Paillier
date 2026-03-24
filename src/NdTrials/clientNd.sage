from sage.all import *
load("src/paillier.sage")

class PIRClientND:

    def __init__(self, bits=1024):
        self.crypto = Paillier(bits)

    def generate_query(self, star_list , ell):
        user_query = [[0]*ell]*len[star_list]
        for i in range(len(star_list)):
            user_query[i][star_list[i]] = 1
        return user_query

    def decrypt_result(self, response):
        n = self.crypto.n
        while (len(response) !=1):
            response.append(self.crypto.decrypt(response[0])*n + self.crypto.decrypt(response[1]))
            response = response[2::]
        return self.crypto.decrypt(response[0])