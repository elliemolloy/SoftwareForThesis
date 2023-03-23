from GTC import *

def CreateError():

    E = ureal(1,0.1)

    return(E)

def SubtractErrors(E1, E2):

    E = E1-E2

    return(E)

def MultiplyError(E1):

    E = E1*1

    return(E)