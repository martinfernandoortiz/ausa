1. Si el servidor (192.168.0.30) tiene un recurso compartido SMB (como una carpeta compartida en Windows o Samba en Linux):
    • En Linux, puedes montar el recurso compartido de Windows/Samba usando smbclient o cifs-utils.
      bash
sudo apt install cifs-utils  # Instalar si no lo tienes
smbclient -L 192.168.0.30 -U ftpusher!
    • Te pedirá la contraseña. Si funciona, verás las carpetas compartidas.
    • Para montarlo permanentemente:
      bash
mkdir ~/mnt_share
sudo mount -t cifs //192.168.0.30/nombre_del_recurso ~/mnt_share -o username=ftpusher!
Password: chequear en http://192.168.0.155/S9Main.php?name=admin portforwaring
