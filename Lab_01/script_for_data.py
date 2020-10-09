f = open('players.csv', encoding='UTF-8')
line = f.readline()
i=0
while line:
    i+=1
    try:
        num = str(i)
        line = line.replace('"','')
        arr = line.split(",")
        res = ",".join([arr[0],arr[1], arr[2],arr[3], arr[4], arr[5],arr[6], arr[7], arr[8][:-1], num])
        print(res)
    except UnicodeEncodeError:
        pass
    except IndexError:
        pass
    line = f.readline()
f.close()