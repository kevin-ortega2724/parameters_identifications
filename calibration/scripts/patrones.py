import numpy as np

# Tamaño de los cuadrados en el patrón de ajedrez (en metros)
square_size = 0.047  # 2 cm

# Número de filas y columnas en el patrón de ajedrez (interior)
pattern_size = (8, 8)  # Cambia esto según tu patrón

# Crear los object_points
object_points = np.zeros((np.prod(pattern_size), 3), dtype=np.float32)

# Llenar los object_points con las coordenadas 3D del patrón de ajedrez
object_points[:, :2] = np.mgrid[0:pattern_size[0], 0:pattern_size[1]].T.reshape(-1, 2)
object_points *= square_size
