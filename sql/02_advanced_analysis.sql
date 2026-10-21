-- ============================================
-- 02 - ANÁLISIS AVANZADO
-- ============================================

-- Rendimiento general por género
SELECT
    genre,
    COUNT(*) AS cantidad_canciones,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(popularity), 2) AS popularidad_promedio
FROM spotify_streaming
GROUP BY genre
ORDER BY total_streams DESC;



-- Géneros con mayor promedio de streams
SELECT
    genre,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    SUM(stream_count) AS total_streams
FROM spotify_streaming
GROUP BY genre
HAVING COUNT(*) >= 1000
ORDER BY promedio_streams DESC;



-- Popularidad y streams por género
SELECT
    genre,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(popularity), 2) AS popularidad_promedio,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    SUM(stream_count) AS total_streams
FROM spotify_streaming
GROUP BY genre
HAVING COUNT(*) >= 1000
ORDER BY popularidad_promedio DESC;



-- Evolución de streams por año y género
SELECT
    release_year,
    genre,
    COUNT(*) AS cantidad_canciones,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS promedio_streams
FROM spotify_streaming
GROUP BY
    release_year,
    genre
ORDER BY
    release_year,
    total_streams DESC;



-- Género con más streams en cada año
WITH streams_anuales AS (
    SELECT
        release_year,
        genre,
        COUNT(*) AS cantidad_canciones,
        SUM(stream_count) AS total_streams,
        ROUND(AVG(stream_count), 2) AS promedio_streams
    FROM spotify_streaming
    GROUP BY release_year, genre
),
ranking AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY release_year
            ORDER BY total_streams DESC
        ) AS posicion
    FROM streams_anuales
)

SELECT
    release_year,
    genre,
    cantidad_canciones,
    total_streams,
    promedio_streams
FROM ranking
WHERE posicion = 1
ORDER BY release_year;



-- Crecimiento anual de streams
WITH streams_por_anio AS (
    SELECT
        release_year,
        SUM(stream_count) AS total_streams
    FROM spotify_streaming
    GROUP BY release_year
),
comparacion AS (
    SELECT
        release_year,
        total_streams,
        LAG(total_streams) OVER (
            ORDER BY release_year
        ) AS streams_anio_anterior
    FROM streams_por_anio
)

SELECT
    release_year,
    total_streams,
    streams_anio_anterior,
    ROUND(
        (total_streams - streams_anio_anterior) * 100.0
        / streams_anio_anterior,
        2
    ) AS crecimiento_porcentaje
FROM comparacion
ORDER BY release_year;



-- Crecimiento anual de streams por género
WITH streams_anuales AS (
    SELECT
        release_year,
        genre,
        SUM(stream_count) AS total_streams
    FROM spotify_streaming
    GROUP BY release_year, genre
),
comparacion AS (
    SELECT
        release_year,
        genre,
        total_streams,
        LAG(total_streams) OVER (
            PARTITION BY genre
            ORDER BY release_year
        ) AS streams_anio_anterior
    FROM streams_anuales
)

SELECT
    release_year,
    genre,
    total_streams,
    streams_anio_anterior,
    ROUND(
        (total_streams - streams_anio_anterior) * 100.0
        / streams_anio_anterior,
        2
    ) AS crecimiento_porcentaje
FROM comparacion
ORDER BY release_year, crecimiento_porcentaje DESC;



-- Género con mayor crecimiento de streams por año
WITH streams_anuales AS (
    SELECT
        release_year,
        genre,
        SUM(stream_count) AS total_streams
    FROM spotify_streaming
    GROUP BY release_year, genre
),
crecimiento AS (
    SELECT
        release_year,
        genre,
        total_streams,
        LAG(total_streams) OVER (
            PARTITION BY genre
            ORDER BY release_year
        ) AS streams_anio_anterior
    FROM streams_anuales
),
ranking AS (
    SELECT
        release_year,
        genre,
        total_streams,
        ROUND(
            (total_streams - streams_anio_anterior) * 100.0
            / streams_anio_anterior,
            2
        ) AS crecimiento_porcentaje,
        RANK() OVER (
            PARTITION BY release_year
            ORDER BY
                (total_streams - streams_anio_anterior) * 100.0
                / streams_anio_anterior DESC
        ) AS posicion
    FROM crecimiento
    WHERE streams_anio_anterior IS NOT NULL
)

SELECT
    release_year,
    genre,
    total_streams,
    crecimiento_porcentaje
FROM ranking
WHERE posicion = 1
ORDER BY release_year;



-- Géneros con crecimiento de streams en años consecutivos
WITH streams_anuales AS (
    SELECT
        release_year,
        genre,
        SUM(stream_count) AS total_streams
    FROM spotify_streaming
    GROUP BY release_year, genre
),
comparacion AS (
    SELECT
        release_year,
        genre,
        total_streams,
        LAG(total_streams) OVER (
            PARTITION BY genre
            ORDER BY release_year
        ) AS streams_anio_anterior
    FROM streams_anuales
),
crecimiento AS (
    SELECT
        release_year,
        genre,
        total_streams,
        streams_anio_anterior,
        ROUND(
            (total_streams - streams_anio_anterior) * 100.0
            / streams_anio_anterior,
            2
        ) AS crecimiento_porcentaje
    FROM comparacion
)

SELECT
    release_year,
    genre,
    crecimiento_porcentaje
FROM crecimiento
WHERE crecimiento_porcentaje > 0
ORDER BY genre, release_year;



-- Géneros que crecieron durante al menos dos años consecutivos
WITH streams_anuales AS (
    SELECT
        release_year,
        genre,
        SUM(stream_count) AS total_streams
    FROM spotify_streaming
    GROUP BY release_year, genre
),
comparacion AS (
    SELECT
        release_year,
        genre,
        total_streams,
        LAG(total_streams) OVER (
            PARTITION BY genre
            ORDER BY release_year
        ) AS streams_anio_anterior
    FROM streams_anuales
),
crecimiento AS (
    SELECT
        release_year,
        genre,
        ROUND(
            (total_streams - streams_anio_anterior) * 100.0
            / streams_anio_anterior,
            2
        ) AS crecimiento_porcentaje
    FROM comparacion
),
rachas AS (
    SELECT
        *,
        LAG(crecimiento_porcentaje) OVER (
            PARTITION BY genre
            ORDER BY release_year
        ) AS crecimiento_anio_anterior
    FROM crecimiento
)

SELECT
    release_year,
    genre,
    crecimiento_anio_anterior,
    crecimiento_porcentaje
FROM rachas
WHERE crecimiento_porcentaje > 0
  AND crecimiento_anio_anterior > 0
ORDER BY genre, release_year;



-- Rendimiento general por país
SELECT
    country,
    COUNT(*) AS cantidad_canciones,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(popularity), 2) AS popularidad_promedio
FROM spotify_streaming
GROUP BY country
ORDER BY total_streams DESC;



-- Países con mayor promedio de streams
SELECT
    country,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    SUM(stream_count) AS total_streams
FROM spotify_streaming
GROUP BY country
HAVING COUNT(*) >= 500
ORDER BY promedio_streams DESC
LIMIT 10;



-- Países con mayor popularidad promedio
SELECT
    country,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(popularity), 2) AS popularidad_promedio,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    SUM(stream_count) AS total_streams
FROM spotify_streaming
GROUP BY country
HAVING COUNT(*) >= 500
ORDER BY popularidad_promedio DESC
LIMIT 10;



-- Rendimiento por país y género
SELECT
    country,
    genre,
    COUNT(*) AS cantidad_canciones,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(popularity), 2) AS popularidad_promedio
FROM spotify_streaming
GROUP BY country, genre
HAVING COUNT(*) >= 100
ORDER BY total_streams DESC
LIMIT 20;



-- Género con más streams de cada país
WITH rendimiento AS (
    SELECT
        country,
        genre,
        COUNT(*) AS cantidad_canciones,
        SUM(stream_count) AS total_streams,
        ROUND(AVG(stream_count), 2) AS promedio_streams
    FROM spotify_streaming
    GROUP BY country, genre
),
ranking AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY country
            ORDER BY total_streams DESC
        ) AS posicion
    FROM rendimiento
)

SELECT
    country,
    genre,
    cantidad_canciones,
    total_streams,
    promedio_streams
FROM ranking
WHERE posicion = 1
ORDER BY total_streams DESC;



-- Participación del género líder en cada país
WITH genero_pais AS (
    SELECT
        country,
        genre,
        SUM(stream_count) AS streams_genero
    FROM spotify_streaming
    GROUP BY country, genre
),
totales_pais AS (
    SELECT
        country,
        SUM(stream_count) AS streams_pais
    FROM spotify_streaming
    GROUP BY country
),
ranking AS (
    SELECT
        g.country,
        g.genre,
        g.streams_genero,
        t.streams_pais,
        ROUND(g.streams_genero * 100.0 / t.streams_pais, 2) AS porcentaje_pais,
        ROW_NUMBER() OVER (
            PARTITION BY g.country
            ORDER BY g.streams_genero DESC
        ) AS posicion
    FROM genero_pais g
    JOIN totales_pais t
        ON g.country = t.country
)

SELECT
    country,
    genre,
    streams_genero,
    streams_pais,
    porcentaje_pais
FROM ranking
WHERE posicion = 1
ORDER BY porcentaje_pais DESC;



-- Top 3 géneros por streams de cada país
WITH genero_pais AS (
    SELECT
        country,
        genre,
        SUM(stream_count) AS total_streams
    FROM spotify_streaming
    GROUP BY country, genre
),
ranking AS (
    SELECT
        country,
        genre,
        total_streams,
        DENSE_RANK() OVER (
            PARTITION BY country
            ORDER BY total_streams DESC
        ) AS posicion
    FROM genero_pais
)

SELECT
    country,
    genre,
    total_streams,
    posicion
FROM ranking
WHERE posicion <= 3
ORDER BY country, posicion;



-- País con más streams de cada género
WITH rendimiento AS (
    SELECT
        genre,
        country,
        SUM(stream_count) AS total_streams
    FROM spotify_streaming
    GROUP BY genre, country
),
ranking AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY genre
            ORDER BY total_streams DESC
        ) AS posicion
    FROM rendimiento
)

SELECT
    genre,
    country,
    total_streams
FROM ranking
WHERE posicion = 1
ORDER BY total_streams DESC;



-- Top 3 artistas con más streams de cada país
WITH artistas_pais AS (
    SELECT
        country,
        artist_name,
        SUM(stream_count) AS total_streams
    FROM spotify_streaming
    GROUP BY country, artist_name
),
ranking AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY country
            ORDER BY total_streams DESC
        ) AS posicion
    FROM artistas_pais
)

SELECT
    country,
    artist_name,
    total_streams,
    posicion
FROM ranking
WHERE posicion <= 3
ORDER BY country, posicion;



-- Participación del artista líder en los streams de cada país
WITH artista_pais AS (
    SELECT
        country,
        artist_name,
        SUM(stream_count) AS streams_artista
    FROM spotify_streaming
    GROUP BY country, artist_name
),
totales_pais AS (
    SELECT
        country,
        SUM(stream_count) AS streams_pais
    FROM spotify_streaming
    GROUP BY country
),
ranking AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY country
            ORDER BY streams_artista DESC
        ) AS posicion
    FROM artista_pais
)

SELECT
    r.country,
    r.artist_name,
    r.streams_artista,
    t.streams_pais,
    ROUND(r.streams_artista * 100.0 / t.streams_pais, 2) AS porcentaje_pais
FROM ranking AS r
JOIN totales_pais AS t
    ON r.country = t.country
WHERE r.posicion = 1
ORDER BY porcentaje_pais DESC;



-- Porcentaje de streams concentrado en los Top 3 artistas de cada país
WITH artista_pais AS (
    SELECT
        country,
        artist_name,
        SUM(stream_count) AS streams_artista
    FROM spotify_streaming
    GROUP BY country, artist_name
),
ranking AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY country
            ORDER BY streams_artista DESC
        ) AS posicion
    FROM artista_pais
),
totales_pais AS (
    SELECT
        country,
        SUM(stream_count) AS streams_pais
    FROM spotify_streaming
    GROUP BY country
)

SELECT
    r.country,
    SUM(r.streams_artista) AS streams_top_3,
    t.streams_pais,
    ROUND(
        SUM(r.streams_artista) * 100.0 / t.streams_pais,
        2
    ) AS porcentaje_top_3
FROM ranking AS r
JOIN totales_pais AS t
    ON r.country = t.country
WHERE r.posicion <= 3
GROUP BY r.country, t.streams_pais
ORDER BY porcentaje_top_3 DESC;



-- Diversidad de artistas por país
SELECT
    country,
    COUNT(*) AS cantidad_canciones,
    COUNT(DISTINCT artist_name) AS artistas_unicos,
    ROUND(
        COUNT(*) * 1.0 / COUNT(DISTINCT artist_name),
        2
    ) AS canciones_por_artista
FROM spotify_streaming
GROUP BY country
ORDER BY artistas_unicos DESC;



-- Diversidad de géneros por país
SELECT
    country,
    COUNT(*) AS cantidad_canciones,
    COUNT(DISTINCT genre) AS generos_unicos,
    COUNT(DISTINCT artist_name) AS artistas_unicos
FROM spotify_streaming
GROUP BY country
ORDER BY generos_unicos DESC, artistas_unicos DESC;



-- Géneros con mayor diversidad de artistas
SELECT
    genre,
    COUNT(*) AS cantidad_canciones,
    COUNT(DISTINCT artist_name) AS artistas_unicos,
    ROUND(
        COUNT(*) * 1.0 / COUNT(DISTINCT artist_name),
        2
    ) AS canciones_por_artista
FROM spotify_streaming
GROUP BY genre
ORDER BY artistas_unicos DESC;



-- Participación del artista líder dentro de cada género
WITH artista_genero AS (
    SELECT
        genre,
        artist_name,
        SUM(stream_count) AS streams_artista
    FROM spotify_streaming
    GROUP BY genre, artist_name
),
totales_genero AS (
    SELECT
        genre,
        SUM(stream_count) AS streams_genero
    FROM spotify_streaming
    GROUP BY genre
),
ranking AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY genre
            ORDER BY streams_artista DESC
        ) AS posicion
    FROM artista_genero
)

SELECT
    r.genre,
    r.artist_name,
    r.streams_artista,
    t.streams_genero,
    ROUND(r.streams_artista * 100.0 / t.streams_genero, 2) AS porcentaje_genero
FROM ranking AS r
JOIN totales_genero AS t
    ON r.genre = t.genre
WHERE r.posicion = 1
ORDER BY porcentaje_genero DESC;



-- Top 3 artistas con más streams de cada género
WITH artista_genero AS (
    SELECT
        genre,
        artist_name,
        SUM(stream_count) AS total_streams
    FROM spotify_streaming
    GROUP BY genre, artist_name
),
ranking AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY genre
            ORDER BY total_streams DESC
        ) AS posicion
    FROM artista_genero
)

SELECT
    genre,
    artist_name,
    total_streams,
    posicion
FROM ranking
WHERE posicion <= 3
ORDER BY genre, posicion;



-- Características de audio promedio por género
SELECT
    genre,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(danceability), 3) AS danceability_promedio,
    ROUND(AVG(energy), 3) AS energy_promedio,
    ROUND(AVG(tempo), 2) AS tempo_promedio,
    ROUND(AVG(loudness), 2) AS loudness_promedio,
    ROUND(AVG(upbeat_score), 3) AS upbeat_promedio
FROM spotify_streaming
GROUP BY genre
ORDER BY danceability_promedio DESC;



-- Características de audio según nivel de streams
SELECT
    CASE
        WHEN stream_count >= 500000 THEN 'Muy alto'
        WHEN stream_count >= 100000 THEN 'Alto'
        WHEN stream_count >= 10000 THEN 'Medio'
        ELSE 'Bajo'
    END AS nivel_streams,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(danceability), 3) AS danceability_promedio,
    ROUND(AVG(energy), 3) AS energy_promedio,
    ROUND(AVG(tempo), 2) AS tempo_promedio,
    ROUND(AVG(upbeat_score), 3) AS upbeat_promedio
FROM spotify_streaming
GROUP BY nivel_streams
ORDER BY AVG(stream_count) DESC;



-- Popularidad promedio según nivel de streams
SELECT
    CASE
        WHEN stream_count >= 500000 THEN 'Muy alto'
        WHEN stream_count >= 100000 THEN 'Alto'
        WHEN stream_count >= 10000 THEN 'Medio'
        ELSE 'Bajo'
    END AS nivel_streams,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(popularity), 2) AS popularidad_promedio
FROM spotify_streaming
GROUP BY nivel_streams
ORDER BY promedio_streams DESC;



-- Rendimiento de canciones explícitas vs no explícitas
SELECT
    explicit,
    COUNT(*) AS cantidad_canciones,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(popularity), 2) AS popularidad_promedio
FROM spotify_streaming
GROUP BY explicit
ORDER BY promedio_streams DESC;



-- Rendimiento según día de lanzamiento
SELECT
    release_day_of_week,
    COUNT(*) AS cantidad_canciones,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(popularity), 2) AS popularidad_promedio
FROM spotify_streaming
GROUP BY release_day_of_week
ORDER BY promedio_streams DESC;



-- Rendimiento: fin de semana vs entre semana
SELECT
    is_weekend_release,
    COUNT(*) AS cantidad_canciones,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(popularity), 2) AS popularidad_promedio
FROM spotify_streaming
GROUP BY is_weekend_release
ORDER BY promedio_streams DESC;



-- Rendimiento por trimestre de lanzamiento
SELECT
    release_quarter,
    COUNT(*) AS cantidad_canciones,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(popularity), 2) AS popularidad_promedio
FROM spotify_streaming
GROUP BY release_quarter
ORDER BY promedio_streams DESC;



-- Rendimiento por mes de lanzamiento
SELECT
    release_month,
    COUNT(*) AS cantidad_canciones,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(popularity), 2) AS popularidad_promedio
FROM spotify_streaming
GROUP BY release_month
ORDER BY promedio_streams DESC;



-- Rendimiento según duración de la canción
SELECT
    CASE
        WHEN duration_minutes < 2 THEN 'Menos de 2 min'
        WHEN duration_minutes < 3 THEN '2-3 min'
        WHEN duration_minutes < 4 THEN '3-4 min'
        WHEN duration_minutes < 5 THEN '4-5 min'
        ELSE 'Más de 5 min'
    END AS rango_duracion,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(popularity), 2) AS popularidad_promedio
FROM spotify_streaming
GROUP BY rango_duracion
ORDER BY promedio_streams DESC;



-- Rendimiento según tonalidad musical
SELECT
    key_name,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(popularity), 2) AS popularidad_promedio
FROM spotify_streaming
GROUP BY key_name
ORDER BY promedio_streams DESC;



-- Rendimiento según modo musical
SELECT
    mode_name,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(popularity), 2) AS popularidad_promedio
FROM spotify_streaming
GROUP BY mode_name
ORDER BY promedio_streams DESC;



-- Rendimiento según rango de tempo
SELECT
    CASE
        WHEN tempo < 90 THEN 'Lento'
        WHEN tempo < 120 THEN 'Moderado'
        WHEN tempo < 150 THEN 'Rápido'
        ELSE 'Muy rápido'
    END AS rango_tempo,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(popularity), 2) AS popularidad_promedio
FROM spotify_streaming
GROUP BY rango_tempo
ORDER BY promedio_streams DESC;



-- Rendimiento según nivel de danceability
SELECT
    CASE
        WHEN danceability >= 0.8 THEN 'Muy alta'
        WHEN danceability >= 0.6 THEN 'Alta'
        WHEN danceability >= 0.4 THEN 'Media'
        ELSE 'Baja'
    END AS nivel_danceability,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(popularity), 2) AS popularidad_promedio
FROM spotify_streaming
GROUP BY nivel_danceability
ORDER BY promedio_streams DESC;



-- Rendimiento según nivel de energy
SELECT
    CASE
        WHEN energy >= 0.8 THEN 'Muy alta'
        WHEN energy >= 0.6 THEN 'Alta'
        WHEN energy >= 0.4 THEN 'Media'
        ELSE 'Baja'
    END AS nivel_energy,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(popularity), 2) AS popularidad_promedio
FROM spotify_streaming
GROUP BY nivel_energy
ORDER BY promedio_streams DESC;



-- Rendimiento según nivel de loudness
SELECT
    loudness_category,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(popularity), 2) AS popularidad_promedio
FROM spotify_streaming
GROUP BY loudness_category
ORDER BY promedio_streams DESC;



-- Rendimiento según nivel de instrumentalness
SELECT
    CASE
        WHEN instrumentalness >= 0.5 THEN 'Alta'
        WHEN instrumentalness >= 0.1 THEN 'Media'
        ELSE 'Baja'
    END AS nivel_instrumentalness,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(popularity), 2) AS popularidad_promedio
FROM spotify_streaming
GROUP BY nivel_instrumentalness
ORDER BY promedio_streams DESC;



-- Rendimiento según combinación de danceability y energy
SELECT
    CASE
        WHEN danceability >= 0.6 AND energy >= 0.6 THEN 'Bailable y energética'
        WHEN danceability >= 0.6 AND energy < 0.6 THEN 'Bailable y tranquila'
        WHEN danceability < 0.6 AND energy >= 0.6 THEN 'Poco bailable y energética'
        ELSE 'Poco bailable y tranquila'
    END AS perfil_audio,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(popularity), 2) AS popularidad_promedio
FROM spotify_streaming
GROUP BY perfil_audio
ORDER BY promedio_streams DESC;



-- Características de audio del Top 10% de canciones por streams
WITH ranking AS (
    SELECT
        *,
        NTILE(10) OVER (ORDER BY stream_count DESC) AS decil_streams
    FROM spotify_streaming
)
SELECT
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(danceability), 3) AS danceability_promedio,
    ROUND(AVG(energy), 3) AS energy_promedio,
    ROUND(AVG(tempo), 2) AS tempo_promedio,
    ROUND(AVG(loudness), 2) AS loudness_promedio,
    ROUND(AVG(instrumentalness), 3) AS instrumentalness_promedio
FROM ranking
WHERE decil_streams = 1;



-- Comparación Top 10% vs resto de canciones
WITH ranking AS (
    SELECT
        *,
        NTILE(10) OVER (ORDER BY stream_count DESC) AS decil_streams
    FROM spotify_streaming
)
SELECT
    CASE
        WHEN decil_streams = 1 THEN 'Top 10%'
        ELSE 'Resto 90%'
    END AS grupo,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    ROUND(AVG(danceability), 3) AS danceability_promedio,
    ROUND(AVG(energy), 3) AS energy_promedio,
    ROUND(AVG(tempo), 2) AS tempo_promedio,
    ROUND(AVG(loudness), 2) AS loudness_promedio,
    ROUND(AVG(instrumentalness), 3) AS instrumentalness_promedio
FROM ranking
GROUP BY grupo
ORDER BY promedio_streams DESC;



-- Relación entre popularidad y nivel de streams
SELECT
    popularity_category,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(popularity), 2) AS popularidad_promedio,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    SUM(stream_count) AS total_streams
FROM spotify_streaming
GROUP BY popularity_category
ORDER BY promedio_streams DESC;




-- Porcentaje de streams por categoría de popularidad
WITH categorias AS (
    SELECT
        popularity_category,
        COUNT(*) AS cantidad_canciones,
        SUM(stream_count) AS total_streams
    FROM spotify_streaming
    GROUP BY popularity_category
),
total AS (
    SELECT SUM(stream_count) AS streams_globales
    FROM spotify_streaming
)
SELECT
    popularity_category,
    cantidad_canciones,
    total_streams,
    ROUND(total_streams * 100.0 / streams_globales, 2) AS porcentaje_streams
FROM categorias
CROSS JOIN total
ORDER BY porcentaje_streams DESC;



-- Concentración de streams: Top 10% de canciones vs resto

WITH ranking AS (
    SELECT
        stream_count,
        NTILE(10) OVER (ORDER BY stream_count DESC) AS decil_streams
    FROM spotify_streaming
),
grupos AS (
    SELECT
        CASE
            WHEN decil_streams = 1 THEN 'Top 10%'
            ELSE 'Resto 90%'
        END AS grupo,
        COUNT(*) AS cantidad_canciones,
        SUM(stream_count) AS total_streams
    FROM ranking
    GROUP BY grupo
),
total AS (
    SELECT SUM(stream_count) AS streams_globales
    FROM spotify_streaming
)
SELECT
    grupo,
    cantidad_canciones,
    total_streams,
    ROUND(total_streams * 100.0 / streams_globales, 2) AS porcentaje_streams
FROM grupos
CROSS JOIN total
ORDER BY porcentaje_streams DESC;