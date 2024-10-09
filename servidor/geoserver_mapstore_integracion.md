Configuración para vincular Geoserver con la base de Mapstore

El documento que guía la vinculación es: 
GeoServer - MapStore (geosolutionsgroup.com)
Sin embargo hay que hacer algunos pasos diferentes ya que sino no funciona. A su vez, copiar y pegar la carpeta de seguridad de producción a ésta nueva tampoco funciona.


Luego de crear los users groups hay que copiar y reemplazar los archivos usersddl, usersdml con los de producción. Esto se debe a que uno de los archivos llama a otras tablas. Las de nuestra base geostore tiene el prefix gs_ mientras que las que origina el archivo en geoserver no. Esto hace que no haya comunicación. Recordar que los permisos sean de tomcat y no de root en estos nuevos archivos.

Luego crear los roles. La dinámica es la misma. Solo que una vez que se copian los archivos rolesddl y roledml hay que poner en geoserver crear tablas. 




Al migrar recordar las querys de geostore_Data 

UPDATE geostore.gs_stored_data
SET stored_data = REPLACE(stored_data, 'https://maps.ausa.com.ar/geoserver/csw', 'http://172.25.92.12:8080/geoserver/csw')
WHERE stored_data LIKE '%https://maps.ausa.com.ar/geoserver/csw%';



UPDATE geostore.gs_stored_data
SET stored_data = REPLACE(stored_data, 'https://maps.ausa.com.ar/geoserver/wms', 'http://172.25.92.12:8080/geoserver/wms')
WHERE stored_data LIKE '%https://maps.ausa.com.ar/geoserver/wms%';



UPDATE geostore.gs_stored_data
SET stored_data = REPLACE(stored_data, 'https://maps.ausa.com.ar/', 'http://172.25.92.12:8080/')
WHERE stored_data LIKE '%https://maps.ausa.com.ar/%';


UPDATE geostore.gs_stored_data
SET stored_data = REPLACE(stored_data, '172.25.92.12:8080/', '172.25.92.12/')
WHERE stored_data LIKE '%172.25.92.12:8080/%';


CREATE user geostore LOGIN PASSWORD 'geostore$4usa2020' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;


GRANT USAGE ON SCHEMA geostore TO geostore ; 
GRANT ALL ON SCHEMA geostore TO geostore ;
alter user geostore set search_path to geostore , public;




Sino sincroniza los almacenes de datos, fijarse que el datastore.xml no tenga la línea de password. Hay que borrarla
