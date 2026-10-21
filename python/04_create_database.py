import sqlite3
import pandas as pd

# Rutas
csv_path = "data/processed/spotify_streaming_clean.csv"
db_path = "sql/spotify.db"

# Cargar dataset limpio
df = pd.read_csv(csv_path)

# Crear conexión con SQLite
connection = sqlite3.connect(db_path)

# Guardar dataset como tabla
df.to_sql(
    "spotify_streaming",
    connection,
    if_exists="replace",
    index=False
)

# Cerrar conexión
connection.close()

print("Base de datos creada correctamente.")
print(f"Filas importadas: {len(df)}")
print(f"Columnas importadas: {len(df.columns)}")