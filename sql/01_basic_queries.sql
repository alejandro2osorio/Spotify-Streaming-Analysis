-- Active: 1791213492650@@127.0.0.1@3306

-- Ver las primeras 10 canciones del dataset
SELECT *
FROM spotify_streaming
LIMIT 10;


-- Top 10 géneros por streams totales
SELECT
    genre,
    SUM(stream_count) AS total_streams
FROM spotify_streaming
GROUP BY genre
ORDER BY total_streams DESC
LIMIT 10;


-- Top 10 géneros por promedio de streams
SELECT
    genre,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    COUNT(*) AS cantidad_canciones
FROM spotify_streaming
GROUP BY genre
ORDER BY promedio_streams DESC
LIMIT 10;


-- Top 10 artistas por streams totales
SELECT
    artist_name,
    SUM(stream_count) AS total_streams,
    COUNT(*) AS cantidad_canciones
FROM spotify_streaming
GROUP BY artist_name
ORDER BY total_streams DESC
LIMIT 10;


-- Top 10 canciones Pop por streams
SELECT
    track_name,
    artist_name,
    stream_count,
    popularity
FROM spotify_streaming
WHERE genre = 'Pop'
ORDER BY stream_count DESC
LIMIT 10;


-- Canciones Pop populares con más de 1 millón de streams
SELECT
    track_name,
    artist_name,
    stream_count,
    popularity
FROM spotify_streaming
WHERE genre = 'Pop'
    AND popularity >= 70
    AND stream_count > 1000000
ORDER BY stream_count DESC;


-- Canciones de Pop o R&B
SELECT
    track_name,
    artist_name,
    genre,
    stream_count,
    popularity
FROM spotify_streaming
WHERE genre IN ('Pop', 'R&B')
ORDER BY stream_count DESC
LIMIT 10;


-- Canciones con popularidad entre 70 y 90
SELECT
    track_name,
    artist_name,
    genre,
    popularity,
    stream_count
FROM spotify_streaming
WHERE popularity BETWEEN 70 AND 90
ORDER BY popularity DESC
LIMIT 10;



-- Canciones cuyo nombre empieza por "The"
SELECT
    track_name,
    artist_name,
    genre,
    stream_count
FROM spotify_streaming
WHERE track_name LIKE 'The%'
ORDER BY stream_count DESC
LIMIT 10;



-- Artistas con al menos 20 canciones
SELECT
    artist_name,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams
FROM spotify_streaming
GROUP BY artist_name
HAVING COUNT(*) >= 20
ORDER BY promedio_streams DESC
LIMIT 10;



-- Crear categorías de popularidad
SELECT
    track_name,
    artist_name,
    popularity,
    CASE
        WHEN popularity >= 80 THEN 'Very High'
        WHEN popularity >= 60 THEN 'High'
        WHEN popularity >= 30 THEN 'Medium'
        ELSE 'Low'
    END AS popularity_category
FROM spotify_streaming
ORDER BY popularity DESC
LIMIT 20;



-- Streams por categoría de popularidad
SELECT
    CASE
        WHEN popularity >= 80 THEN 'Very High'
        WHEN popularity >= 60 THEN 'High'
        WHEN popularity >= 30 THEN 'Medium'
        ELSE 'Low'
    END AS popularity_category,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams
FROM spotify_streaming
GROUP BY
    CASE
        WHEN popularity >= 80 THEN 'Very High'
        WHEN popularity >= 60 THEN 'High'
        WHEN popularity >= 30 THEN 'Medium'
        ELSE 'Low'
    END
ORDER BY promedio_streams DESC;



-- Comparación de canciones explícitas y no explícitas
SELECT
    explicit,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams,
    SUM(stream_count) AS total_streams
FROM spotify_streaming
GROUP BY explicit
ORDER BY promedio_streams DESC;



-- Streams por año de lanzamiento
SELECT
    release_year,
    COUNT(*) AS cantidad_canciones,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS promedio_streams
FROM spotify_streaming
GROUP BY release_year
ORDER BY release_year;



-- Streams por trimestre de lanzamiento
SELECT
    release_quarter,
    COUNT(*) AS cantidad_canciones,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS promedio_streams
FROM spotify_streaming
GROUP BY release_quarter
ORDER BY release_quarter;



-- Streams por mes de lanzamiento
SELECT
    release_month,
    COUNT(*) AS cantidad_canciones,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS promedio_streams
FROM spotify_streaming
GROUP BY release_month
ORDER BY release_month;



-- Streams por día de la semana
SELECT
    release_day_of_week,
    COUNT(*) AS cantidad_canciones,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS promedio_streams
FROM spotify_streaming
GROUP BY release_day_of_week
ORDER BY promedio_streams DESC;



-- Streams: fin de semana vs. días laborales
SELECT
    is_weekend_release,
    COUNT(*) AS cantidad_canciones,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS promedio_streams
FROM spotify_streaming
GROUP BY is_weekend_release
ORDER BY promedio_streams DESC;



-- Top 10 sellos discográficos por streams totales
SELECT
    label,
    COUNT(*) AS cantidad_canciones,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS promedio_streams
FROM spotify_streaming
GROUP BY label
ORDER BY total_streams DESC
LIMIT 10;



-- Top 10 sellos por promedio de streams
SELECT
    label,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams
FROM spotify_streaming
GROUP BY label
HAVING COUNT(*) >= 1000
ORDER BY promedio_streams DESC
LIMIT 10;



-- Top 10 sellos por popularidad promedio
SELECT
    label,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(popularity), 2) AS popularidad_promedio,
    ROUND(AVG(stream_count), 2) AS promedio_streams
FROM spotify_streaming
GROUP BY label
HAVING COUNT(*) >= 1000
ORDER BY popularidad_promedio DESC
LIMIT 10;



-- Comparación entre sellos Major y Other
SELECT
    CASE
        WHEN label IN (
            'Columbia Records',
            'RCA Records',
            'Capitol Records',
            'Warner Music Group',
            'Def Jam Recordings',
            'Island Records',
            'Atlantic Records',
            'Republic Records',
            'Sony Music Entertainment',
            'Epic Records',
            'Universal Music Group',
            'Interscope Records'
        ) THEN 'Major'
        ELSE 'Other'
    END AS label_group,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(popularity), 2) AS popularidad_promedio,
    ROUND(AVG(stream_count), 2) AS promedio_streams
FROM spotify_streaming
GROUP BY
    CASE
        WHEN label IN (
            'Columbia Records',
            'RCA Records',
            'Capitol Records',
            'Warner Music Group',
            'Def Jam Recordings',
            'Island Records',
            'Atlantic Records',
            'Republic Records',
            'Sony Music Entertainment',
            'Epic Records',
            'Universal Music Group',
            'Interscope Records'
        ) THEN 'Major'
        ELSE 'Other'
    END;




-- Major vs Other por categoría de popularidad
WITH categorized_data AS (
    SELECT
        stream_count,
        CASE
            WHEN popularity >= 80 THEN 'Very High'
            WHEN popularity >= 60 THEN 'High'
            WHEN popularity >= 30 THEN 'Medium'
            ELSE 'Low'
        END AS popularity_category,
        CASE
            WHEN label IN (
                'Columbia Records',
                'RCA Records',
                'Capitol Records',
                'Warner Music Group',
                'Def Jam Recordings',
                'Island Records',
                'Atlantic Records',
                'Republic Records',
                'Sony Music Entertainment',
                'Epic Records',
                'Universal Music Group',
                'Interscope Records'
            ) THEN 'Major'
            ELSE 'Other'
        END AS label_group
    FROM spotify_streaming
)

SELECT
    popularity_category,
    label_group,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams
FROM categorized_data
GROUP BY
    popularity_category,
    label_group
ORDER BY
    CASE popularity_category
        WHEN 'Low' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'High' THEN 3
        WHEN 'Very High' THEN 4
    END,
    label_group;



-- Top 10 países por streams totales
SELECT
    country,
    COUNT(*) AS cantidad_canciones,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS promedio_streams
FROM spotify_streaming
GROUP BY country
ORDER BY total_streams DESC
LIMIT 10;



-- Top 10 países por promedio de streams
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



-- Top combinaciones país + género por streams
SELECT
    country,
    genre,
    COUNT(*) AS cantidad_canciones,
    SUM(stream_count) AS total_streams,
    ROUND(AVG(stream_count), 2) AS promedio_streams
FROM spotify_streaming
GROUP BY
    country,
    genre
HAVING COUNT(*) >= 100
ORDER BY total_streams DESC
LIMIT 20;



-- Ranking de canciones por streams
SELECT
    track_name,
    artist_name,
    genre,
    stream_count,
    RANK() OVER (
        ORDER BY stream_count DESC
    ) AS ranking
FROM spotify_streaming
ORDER BY ranking
LIMIT 20;



-- Ranking de canciones dentro de cada género
SELECT
    track_name,
    artist_name,
    genre,
    stream_count,
    RANK() OVER (
        PARTITION BY genre
        ORDER BY stream_count DESC
    ) AS ranking_genero
FROM spotify_streaming
ORDER BY
    genre,
    ranking_genero;



-- Top 3 canciones con más streams de cada género
WITH ranking_generos AS (
    SELECT
        track_name,
        artist_name,
        genre,
        stream_count,
        RANK() OVER (
            PARTITION BY genre
            ORDER BY stream_count DESC
        ) AS ranking_genero
    FROM spotify_streaming
)

SELECT
    track_name,
    artist_name,
    genre,
    stream_count,
    ranking_genero
FROM ranking_generos
WHERE ranking_genero <= 3
ORDER BY
    genre,
    ranking_genero;



-- Canciones con más streams que el promedio general
SELECT
    track_name,
    artist_name,
    genre,
    stream_count
FROM spotify_streaming
WHERE stream_count > (
    SELECT AVG(stream_count)
    FROM spotify_streaming
)
ORDER BY stream_count DESC
LIMIT 20;



-- Canciones con más streams que el promedio de su género
WITH promedio_genero AS (
    SELECT
        genre,
        AVG(stream_count) AS promedio_streams
    FROM spotify_streaming
    GROUP BY genre
)

SELECT
    s.track_name,
    s.artist_name,
    s.genre,
    s.stream_count,
    ROUND(p.promedio_streams, 2) AS promedio_genero
FROM spotify_streaming AS s
JOIN promedio_genero AS p
    ON s.genre = p.genre
WHERE s.stream_count > p.promedio_streams
ORDER BY s.stream_count DESC
LIMIT 20;



-- Artistas cuyo promedio de streams supera el promedio general
SELECT
    artist_name,
    COUNT(*) AS cantidad_canciones,
    ROUND(AVG(stream_count), 2) AS promedio_streams
FROM spotify_streaming
GROUP BY artist_name
HAVING AVG(stream_count) > (
    SELECT AVG(stream_count)
    FROM spotify_streaming
)
ORDER BY promedio_streams DESC
LIMIT 20;



-- Canciones del artista con más streams totales
SELECT
    track_name,
    artist_name,
    genre,
    stream_count
FROM spotify_streaming
WHERE artist_name = (
    SELECT artist_name
    FROM spotify_streaming
    GROUP BY artist_name
    ORDER BY SUM(stream_count) DESC
    LIMIT 1
)
ORDER BY stream_count DESC;



-- Ranking de artistas por streams totales
WITH artist_streams AS (
    SELECT
        artist_name,
        SUM(stream_count) AS total_streams,
        COUNT(*) AS cantidad_canciones
    FROM spotify_streaming
    GROUP BY artist_name
)

SELECT
    artist_name,
    cantidad_canciones,
    total_streams,
    DENSE_RANK() OVER (
        ORDER BY total_streams DESC
    ) AS ranking
FROM artist_streams
ORDER BY ranking
LIMIT 20;



-- Numerar las canciones de cada artista por streams
SELECT
    artist_name,
    track_name,
    stream_count,
    ROW_NUMBER() OVER (
        PARTITION BY artist_name
        ORDER BY stream_count DESC
    ) AS posicion_artista
FROM spotify_streaming
ORDER BY artist_name, posicion_artista
LIMIT 50;



-- Porcentaje de streams que aporta cada canción a su artista
SELECT
    artist_name,
    track_name,
    stream_count,
    SUM(stream_count) OVER (
        PARTITION BY artist_name
    ) AS total_streams_artista,
    ROUND(
        stream_count * 100.0 /
        SUM(stream_count) OVER (
            PARTITION BY artist_name
        ),
        2
    ) AS porcentaje_artista
FROM spotify_streaming
ORDER BY artist_name, porcentaje_artista DESC
LIMIT 50;



-- Streams acumulados por artista
SELECT
    artist_name,
    track_name,
    stream_count,
    SUM(stream_count) OVER (
        PARTITION BY artist_name
        ORDER BY stream_count DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS streams_acumulados
FROM spotify_streaming
ORDER BY artist_name, stream_count DESC
LIMIT 50;



-- Comparar cada canción con la anterior del mismo artista
SELECT
    artist_name,
    track_name,
    stream_count,
    LAG(stream_count) OVER (
        PARTITION BY artist_name
        ORDER BY stream_count DESC
    ) AS streams_cancion_anterior,
    stream_count - LAG(stream_count) OVER (
        PARTITION BY artist_name
        ORDER BY stream_count DESC
    ) AS diferencia_streams
FROM spotify_streaming
ORDER BY artist_name, stream_count DESC
LIMIT 50;



-- Comparar cada canción con la siguiente del mismo artista
SELECT
    artist_name,
    track_name,
    stream_count,
    LEAD(stream_count) OVER (
        PARTITION BY artist_name
        ORDER BY stream_count DESC
    ) AS streams_siguiente_cancion
FROM spotify_streaming
ORDER BY artist_name, stream_count DESC
LIMIT 50;

