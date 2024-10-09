Configuración para vincular Geoserver con la base de Mapstore

El documento que guía la vinculación es: 
GeoServer - MapStore (geosolutionsgroup.com)
Sin embargo hay que hacer algunos pasos diferentes ya que sino no funciona. A su vez, copiar y pegar la carpeta de seguridad de producción a ésta nueva tampoco funciona.


Luego de crear los users groups hay que copiar y reemplazar los archivos usersddl, usersdml con los de producción. Esto se debe a que uno de los archivos llama a otras tablas. Las de nuestra base geostore tiene el prefix gs_ mientras que las que origina el archivo en geoserver no. Esto hace que no haya comunicación. Recordar que los permisos sean de tomcat y no de root en estos nuevos archivos.

Luego crear los roles. La dinámica es la misma. Solo que una vez que se copian los archivos rolesddl y roledml hay que poner en geoserver crear tablas. 
