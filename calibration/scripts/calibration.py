import numpy as np
import cv2

# Parámetros de terminación de la calibración
criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 30, 0.001)

# Establecer el tamaño de cuadro en cm 
cuadro_ancho = 4.7
cuadro_alto = 4.7

# Configurar puntos 3D 
num_cuadros_x = 8 
num_cuadros_y = 8 
objp = np.zeros((num_cuadros_x*num_cuadros_y,3), np.float32) 

objp[:,:2] = np.mgrid[0:num_cuadros_x, 0:num_cuadros_y].T.reshape(-1,2)

# Multiplicar cada punto por el tamaño real de cuadro  
objp = objp * cuadro_ancho

# Arreglos para almacenar puntos de objeto y puntos de imagen de todas las imágenes.
objpoints = []  # puntos 3d en el espacio real.
imgpoints = []  # puntos 2d en el plano de imagen.

# Iniciar captura de video
cap = cv2.VideoCapture(2)

if not cap.isOpened():
    print("No se pudo abrir la cámara.")
    exit()

print("Presione 'c' para capturar una imagen para calibración o 'q' para salir...")

while True:
    # Captura un frame
    ret, img = cap.read()
    if not ret:
        print("No se pudo leer el frame. Saliendo...")
        break

    # Convertir a escala de grises
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    cv2.imshow('Frame', gray)

    # Esperar tecla de captura o salida
    key = cv2.waitKey(1) & 0xFF
    if key == ord('c'):
        # Encontrar las esquinas del tablero
        ret, corners = cv2.findChessboardCorners(gray, (7, 6), None)
        if ret:
            # Mejora la precisión de las esquinas encontradas
            corners2 = cv2.cornerSubPix(gray, corners, (11, 11), (-1, -1), criteria)
            objpoints.append(objp)
            imgpoints.append(corners2)
            # Dibujar y mostrar las esquinas
            cv2.drawChessboardCorners(img, (7, 6), corners2, ret)
            cv2.imshow('Calibration', img)
            cv2.waitKey(500)
        else:
            print("No se pudieron encontrar las esquinas. Intente nuevamente.")
    elif key == ord('q'):
        break

# Calibración de la cámara
if len(objpoints) > 0:
    ret, mtx, dist, rvecs, tvecs = cv2.calibrateCamera(objpoints, imgpoints, gray.shape[::-1], None, None)
    print("Matriz de la cámara:")
    print(mtx)
    print("Coeficientes de distorsión:")
    print(dist)

    # Guardar los datos de calibración en un archivo .npz
    np.savez('calibration_data.npz', mtx=mtx, dist=dist)
    print("Datos de calibración guardados en 'calibration_data.npz'")
else:
    print("No se tomaron suficientes imágenes para la calibración.")

# Liberar la cámara y cerrar todas las ventanas
cap.release()
cv2.destroyAllWindows()
