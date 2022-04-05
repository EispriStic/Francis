from PIL import Image
import numpy as np
import random

def loadPixels(path):
	"""Entrée : Path de l'image
	Sortie : Matrice de boolean (True = Noir; False = White)"""
	image = Image.open(path)
	image = np.asarray(image).tolist()
	return image

m=loadPixels("trees-set1-64.png")
n=[]

for y in range(len(m)):
	n.append([])
	for x in range(len(m[y])):
		n[y].append([0,0,0,0])

for y in range(len(m)):
	for x in range(len(m[y])):
		if m[y][x][3] == 255:
			if y != 0:
				if m[y-1][x][3] == 0:
					n[y-1][x] = [0,0,0,255]

			if y != len(m):
				if m[y+1][x][3] == 0:
					n[y+1][x] = [0,0,0,255]

			if x != 0:
				if m[y][x-1][3] == 0:
					n[y][x-1] = [0,0,0,255]

			if x != len(m[y]):
				if m[y][x+1][3] == 0:
					n[y][x+1] = [0,0,0,255]
			p=m[y][x]
			n[y][x] = [p[0], p[1], p[2], 255]

img = Image.new("RGBA", (len(m[0]), len(m)), color="white")
for y in range(len(m)):
	for x in range(len(m[0])):
		img.putpixel((x,y), tuple(n[y][x]))
img.save("trees-border.png")