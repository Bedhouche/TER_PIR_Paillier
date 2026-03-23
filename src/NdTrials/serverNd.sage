from sage.all import *
load("/../src/paillier.sage")


class PIRServerND:
    def __init__(self, database):
        self.nDimData = database
        self.dim = len(database)



    def answer_query_Nd (self, user_entry, crypto):
        dim = self.dim
        n = crypto.n
        n2 = crypto.n2
        sigmas = sigma_computing(self,)
        computed_answer = recursive_aux(self, user_entry, [], turn_remaining,n2)

    def spliting (self, user_entry,filtered_splits,turn_remaining,n2)
        if dim == 1:
            return filtered_splits
        
    def filtering(self, relevant_user_entry, splits,n2 )
        UUUVVV = 1
        for user_sent in relevant_user_entry :
            UUUVVV = UUUVVV * power_mod(user_sent, ,n2)%n2
        
    def sigma_computing(self, relevant_user_entry, n2, sigmas, unfixed_dimension_nb,current_subdatabase_index)
        if unfixed_dimension_nb == 1
            sigma_i =1
            for i in range(dim):
                sigma_i = sigma_i * power_mod(relevant_user_entry[current_subdatabase_index][i], self.nDimData[current_subdatabase_index],n2)%n2
            sigmas.append(sigma_i)
        else :
            for i in range(dim):
                sigma_computing(selt,relevant_user_entry, n2 ,sigmas, unfixed_dimension_nb-1 ,current_subdatabase_index + [i])
        
