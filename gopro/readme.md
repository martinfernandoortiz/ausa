# Extraer fotogramas y lat long de videos go pro

url : https://medium.com/@jrballesteros/a-simple-guide-to-extract-gps-information-from-gopro-photos-and-videos-cf6edf6dc601

* Para extraer metadata
```
  exiftool.exe -ee C:\Users\mfortiz\Desktop\AUGENRE\250113-AU2-PPL-A.MP4 > C:\Users\mfortiz\Desktop\AUGENRE\250113-AU2-PPL-A.txt
```
  
* Para extraer kml/gpx :
```
for the .kml file:
"c:\Users\mfortiz\Downloads\exiftool-13.33_64\exiftool-13.33_64\exiftool.exe" -ee -p "c:\Users\mfortiz\Desktop\AUGENRE\kml_format.txt" "c:\Users\mfortiz\Desktop\AUGENRE\250113-AU2-PPL-A.MP4" > "c:\Users\mfortiz\Desktop\AUGENRE\250113-AU2-PPL-A.kml"
```
```
for the .gpx file:
"c:\Users\mfortiz\Downloads\exiftool-13.33_64\exiftool-13.33_64\exiftool.exe" -ee -p "c:\Users\mfortiz\Desktop\AUGENRE\gpx_format.txt" "c:\Users\mfortiz\Desktop\AUGENRE\250113-AU2-PPL-A.MP4" > "c:\Users\mfortiz\Desktop\AUGENRE\250113-AU2-PPL-A.gpx"
```


* Para extraer fotogramas de video

```
ffmpeg.exe -i "C:\Users\mfortiz\Desktop\AUGENRE\240304-AU2-PPL-A.MP4" -vf fps=1 "frames/frames_%05d.jpg" # Calidad media

ffmpeg.exe -i "C:\Users\mfortiz\Desktop\AUGENRE\240304-AU2-PPL-A.MP4" -vf fps=1 -q:v 1 "frames/frames_%05d.jpg" # Calidad máxima

ffmpeg.exe -i "C:\Users\mfortiz\Desktop\AUGENRE\240304-AU2-PPL-A.MP4" -vf fps=1 "frames/frames_%05d.png" # Sin compresión

```
