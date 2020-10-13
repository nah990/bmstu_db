import csv
array_match_id = []
array_map_id = []
with open("./maps.csv", "r",encoding='utf-8',newline='') as dr:
    reader = csv.reader(dr)
    for row in reader:
        array_map_id.append(int(row[0]))
        array_match_id.append(int(row[1]))

count = 0

with open("./players.csv", "r",encoding='utf-8',newline='') as fr, open("./players1.csv", "w",encoding='utf-8',newline='') as fw:
    reader = csv.reader(fr)
    writer = csv.writer(fw)
    for row in reader:
        curRow = []
        curRow.extend(row[0:11])
        for i in range(len(array_match_id)):
            if int(row[1]) == array_match_id[i]:
                curRow.append(array_map_id[i])
                break
        writer.writerow(curRow)