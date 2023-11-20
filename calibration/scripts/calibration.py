import cv2

# Intentar abrir la cámara con el backend de DirectShow
cap = cv2.VideoCapture(0, cv2.CAP_DSHOW)

# Verificar si la cámara se abrió correctamente
if not cap.isOpened():
    print("Error: No se pudo abrir la cámara.")
    exit()

# Loop para capturar y mostrar frames
while True:
    # Capturar frame por frame
    ret, frame = cap.read()

    # Si se captura un frame, mostrarlo
    if ret:
        cv2.imshow('Frame', frame)
    else:
        print("No se pudo leer el frame.")
        # No usar 'break' para permitir múltiples intentos de captura
        continue

    # Romper el bucle con la tecla 'q'
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Liberar la cámara y cerrar todas las ventanas
cap.release()
cv2.destroyAllWindows()
