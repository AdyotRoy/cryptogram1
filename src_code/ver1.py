import random
inp = (input("Enter the sentence to be encrypted: ")).lower()
print(inp)

def rand_char(ch):
    var=ch
    while var==ch:
        num= random.randint(97,122)
        var=str(chr(num))
    return var
def cryptogram(inp):
    encrypted = ""
    inp1 = ""
    for i in range(len(inp)):
        flag = False
        if inp[i] == " ":
            inp1 += " "
            encrypted += " "
        else:
            for j in range(len(inp1)):
                if inp[i] == inp1[j]:
                    flag = True
                    inp1 += inp[i]
                    encrypted += encrypted[j]
                    break
            if not flag:
                inp1 += inp[i]
                rd = rand_char(inp[i])
                while rd in encrypted:
                    rd = rand_char(inp[i])
                encrypted += rd

    return encrypted

print(cryptogram(inp))