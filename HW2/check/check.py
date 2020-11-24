import sys

f1 = open(sys.argv[1], 'r')
f2 = open(sys.argv[2], 'r')
f1 = f1.readlines()
f2 = f2.readlines()
comp1 = []
comp2 = []

for i in f1:
    comp1 = comp1 + i.split()
for i in f2:
    comp2 = comp2 + i.split()

if comp1 == comp2:
    print(True)
else:
    print(False)