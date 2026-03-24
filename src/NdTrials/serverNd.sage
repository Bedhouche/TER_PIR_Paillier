from sage.all import *


class PIRServerND:
    def __init__(self, database, dim, ell):
        self.nDimData = database
        self.dim = dim
        self.ell = ell



    def answer_query_Nd (self, user_entry, crypto):

        dim = self.dim
        n = crypto.n
        n2 = crypto.n2
        filtered = []
        self.sigma_computing(user_entry, n2 , filtered, dim,0)
        user_entry= user_entry[1::]
        while (len(user_entry)!=0):
            splits = self.spliting(filtered,n)
            filtered = self.filtering(user_entry[0],splits,n2)
            user_entry = user_entry[1::]
        return filtered

    def spliting (self,filtered_splits,n):
        splits = []
        for unsplit in filtered_splits:
            splits.append(unsplit // n)
            splits.append(unsplit % n)
        return splits
        
    def filtering(self, relevant_user_entry, splits,n2 ):
        UUUVVV = 1
        filtered = []
        for UUVV in splits:
            for user_sent in relevant_user_entry :
                UUUVVV = UUUVVV * power_mod(user_sent,UUVV ,n2)%n2
            filtered.append(UUUVVV)
            UUUVVV = 1
        return filtered


    def sigma_computing(self, user_entry, n2, sigmas, unfixed_dimension_nb,current_subdatabase_index):
        if unfixed_dimension_nb == 1 :
            sigma_i =1
            for i in range(self.ell):
                sigma_i = sigma_i * power_mod(user_entry[0][i],self.nDimData[current_subdatabase_index + i],n2)%n2
            sigmas.append(sigma_i)
        else :
            for i in range(self.ell):
                self.sigma_computing(user_entry, n2 ,sigmas, unfixed_dimension_nb-1 ,current_subdatabase_index + self.dim **(unfixed_dimension_nb-1))
        