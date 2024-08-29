## Listar procesos de apache
``` ps aux | grep httpd ``` 

## Aplicaciones que se ejecutan
``` httpd -S ```

## Logs
``` tail -f /var/log/httpd/access_log /var/log/httpd/error_log ```

## Modulos y scripts activos
``` httpd -M ```

## Servicios especificos
``` ps aux | grep php ```
 
## archivos abiertos
``` lsof -u apache ```
