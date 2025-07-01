filename = "larrazabal_cividis.las"
f = open(filename, "rb+")
f.seek(6)
f.write(bytes([17, 0, 0, 0]));
f.close()