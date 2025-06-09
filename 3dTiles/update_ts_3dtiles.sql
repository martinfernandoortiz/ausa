UPDATE geostore.gs_stored_data
SET stored_data = CASE
  -- Caso 1: si ya hay un ts=... → lo reemplazamos
  WHEN stored_data ~ 'ts=\d+' THEN
    regexp_replace(
      stored_data,
      'ts=\d+',
      'ts=' || floor(random() * 100000000)::int,
      'g'
    )

  -- Caso 2: no hay ts=... pero hay una URL a tileset.json
  WHEN stored_data ~ 'tileset\.json(\?[^ ]*)?' THEN
    regexp_replace(
      stored_data,
      '(tileset\.json)(\?[^ ]*)?',
      '\1\2' || CASE
        WHEN stored_data ~ 'tileset\.json\?' THEN
          '&ts=' || floor(random() * 100000000)::int
        ELSE
          '?ts=' || floor(random() * 100000000)::int
      END,
      'g'
    )

  -- Caso por defecto: no hacer nada
  ELSE stored_data
END
WHERE stored_data ILIKE '%revit%'
  AND stored_data ~ 'tileset\.json';
