% TIEMPO DE MUESTREO MINIMO:      40 milisegundos
% TAMAÑO MAXIMO DE CADA VECTOR:  750 muestras
% Rango Angular  de 0-4095 equivalente a 0-360 grados,     donde 11.37 cuentas es 1 grado,     y 1 cuenta son 0,088 grados
% Rango Velocidad de 0-511 equivalente a 0-360 grados/seg, donde 1.419 cuentas es 1 grado/seg, y 1 cuenta son 0,704  grado/seg

% ENCABEZADO AUTOMATICO AL CREAR EL GUIDE
function varargout = Controlador(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Controlador_OpeningFcn, ...
                   'gui_OutputFcn',  @Controlador_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


% OutputFcn DONDE SE PONE EL CODIGO PARA MAXIMIZAR PANTALLA
function varargout = Controlador_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;
frame_h1 = get(handle(gcf),'JavaFrame'); % Estas dos lineas maximizan la pantalla. Pero además en el GUIDE se debe cambiar la opcion: "Tool - GUI Options - Proporcional"
set(frame_h1,'Maximized',1);


% CODIGO DE LA EQUIS (X) DE CIERRE DE VENTANA
function figure1_CloseRequestFcn(hObject, eventdata, handles)
global arduino    

fwrite(arduino,'h'); % Le dice al Arduino llevar todos los servos al Home
pause(0.2);

fclose(arduino); % Cierra el puerto serial del Arduino
pause(0.2);
delete(hObject);


% OpeningFcn CODIGO DE EJECUCION INICIAL
function Controlador_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;                   % Creado por defecto al generar el guide
guidata(hObject, handles);                  % Creado por defecto al generar el guide
warning('off','all')                        % Para quitar todos los warning
clc                                         % Limpia pantalla

global arduino k t_muestreo t_simulacion tamano_vector ...
       tamano_vector_angulos_izq tamano_vector_angulos_der tamano_vector_velocidades_izq tamano_vector_velocidades_der ...
       t_muestreo_angulos_izq t_muestreo_angulos_der t_muestreo_velocidades_izq t_muestreo_velocidades_der ...
       t_simulacion_angulos_izq t_simulacion_angulos_der t_simulacion_velocidades_izq t_simulacion_velocidades_der ...
       bandera_t_muestreo bandera_t_simulacion bandera_tamano_vector ...
       button_state_boton_detener ...
       vector_angulos_izq_GR vector_angulos_encoder_izq_G...
       vector_velocidades_izq_GR vector_velocidades_encoder_izq_G...
       vector_angulos_der_GR vector_angulos_encoder_der_G...
       vector_velocidades_der_GR vector_velocidades_encoder_der_G...
       vector_angulos_izq_SR vector_angulos_encoder_izq_SR...
       vector_velocidades_izq_SR vector_velocidades_encoder_izq_SR...
       vector_angulos_der_SR vector_angulos_encoder_der_SR...
       vector_velocidades_der_SR vector_velocidades_encoder_der_SR...
       bandera_servos_cargados xc_v yc_v l1 l2 l3 l4 l5...
       bandera_calculada_cinematica...
       bandera_boton_angulos_izq bandera_boton_velocidades_izq...
       bandera_boton_angulos_der bandera_boton_velocidades_der...
       bandera_trayectoria_ejecutada

%LONGITUDES BARRAS
l1=95; %95mm
l2=85; %85mm
l3=85; %85mm
l4=95; %95mm
l5=75; %75mm
    
xc_v=0;
yc_v=0;

vector_angulos_izq_GR=0;
vector_angulos_encoder_izq_G=0;
vector_velocidades_izq_GR=0; 
vector_velocidades_encoder_izq_G=0;
vector_angulos_der_GR=0;
vector_angulos_encoder_der_G=0;
vector_velocidades_der_GR=0;
vector_velocidades_encoder_der_G=0;

vector_angulos_izq_SR=0;
vector_angulos_encoder_izq_SR=0;
vector_velocidades_izq_SR=0;
vector_velocidades_encoder_izq_SR=0;
vector_angulos_der_SR=0;
vector_angulos_encoder_der_SR=0;
vector_velocidades_der_SR=0;
vector_velocidades_encoder_der_SR=0;

tamano_vector_angulos_izq = 1;
tamano_vector_angulos_der = 2;
tamano_vector_velocidades_izq = 3;
tamano_vector_velocidades_der = 4;
t_muestreo_angulos_izq = 5;
t_muestreo_angulos_der = 6;
t_muestreo_velocidades_izq = 7;
t_muestreo_velocidades_der = 8;
t_simulacion_angulos_izq = 9;
t_simulacion_angulos_der = 10;
t_simulacion_velocidades_izq = 11;
t_simulacion_velocidades_der = 12;
k = 0;
t_muestreo = 0;
t_simulacion = 0;
tamano_vector = 0;
button_state_boton_detener = 0;
bandera_t_muestreo = 0;
bandera_t_simulacion = 0;
bandera_tamano_vector = 0;
bandera_servos_cargados = 0;
bandera_calculada_cinematica = 0;
bandera_boton_angulos_izq = 0;
bandera_boton_velocidades_izq = 0;
bandera_boton_angulos_der = 0;
bandera_boton_velocidades_der = 0;
bandera_trayectoria_ejecutada = 0;

set(handles.panel_cargar_servos,'Visible','off');         % Oculta el panel cargar_servos
set(handles.boton_ejecutar,'Visible','off');              % Oculta el boton ejecutar_trayectoria
set(handles.boton_analizar,'Visible','off');              % Oculta el boton boton_analizar
set(handles.boton_detener,'Visible','off');               % Oculta el boton detener_trayectoria
set(handles.boton_calcular,'Visible','off');              % Oculta el boton boton_calcular

% Estas 5 lineas encuentran el puerto al que esta conectado el arduino 
COM_PORT = FindPort(); 
COM_PORT = regexprep(COM_PORT,'[^\w'']','');
disp('COM Port Selected');
disp(COM_PORT);
delete(instrfind({'Port'},{COM_PORT}));

% Initializa Arduino Connection
arduino = serial(COM_PORT,'BaudRate',1000000,'Terminator','CR/LF'); % sincronizacion con el arduino
warning('on','MATLAB:serial:fscanf:unsuccessfulRead'); 
fopen(arduino); % se abre el puerto serial

[q , fs] = audioread('sistema comunicado.wav'); % Lee la frecuencia y las muestras del archivo de audio
sound(q,fs); % reproduce el audio

fwrite(arduino,'h'); % Le dice al Arduino llevar todos los servos al Home

axes(handles.axes_posiciones_servo_izq); % Selecciona el axes a trabajar
cla;
axis([0 5 0 5]); % ejes por defecto de la grafica
title('Posiciones Servo Izquierdo')
ylabel('Posicion Angular [grados]','FontWeight','bold','FontSize',10,'Color',[0 0 0]); 
xlabel('Tiempo [ms]','FontWeight','bold','FontSize',10,'Color',[0 0 0]);
hold on;
grid on;

axes(handles.axes_posiciones_servo_der); % Selecciona el axes a trabajar
cla;
axis([0 5 0 5]); % ejes por defecto de la grafica
title('Posiciones Servo Derecho')
ylabel('Posicion Angular [grados]','FontWeight','bold','FontSize',10,'Color',[0 0 0]); 
xlabel('Tiempo [ms]','FontWeight','bold','FontSize',10,'Color',[0 0 0]);
hold on;
grid on;

axes(handles.axes_velocidades_servo_izq); % Selecciona el axes a trabajar
cla;
axis([0 5 0 5]); % ejes por defecto de la grafica
title('Velocidades Servo Izquierdo')
ylabel('Velocidad Angular [grados/seg]','FontWeight','bold','FontSize',10,'Color',[0 0 0]); 
xlabel('Tiempo [ms]','FontWeight','bold','FontSize',10,'Color',[0 0 0]); 
hold on;
grid on;

axes(handles.axes_velocidades_servo_der); % Selecciona el axes a trabajar
cla;
axis([0 5 0 5]); % ejes por defecto de la grafica
title('Velocidades Servo Derecho')
ylabel('Velocidad Angular [grados/seg]','FontWeight','bold','FontSize',10,'Color',[0 0 0]); 
xlabel('Tiempo [ms]','FontWeight','bold','FontSize',10,'Color',[0 0 0]); 
hold on;
grid on;

axes(handles.axes_trayectoria); % Selecciona el axes a trabajar
cla;
axis([-60 135 0 195]); % ejes por defecto de la grafica
title('Trayectoria del Mecanismo')
ylabel('Posicion eje Y [mm]','FontWeight','bold','FontSize',12,'Color',[0 0 0]);
xlabel('Posicion eje X [mm]','FontWeight','bold','FontSize',12,'Color',[0 0 0]); 
hold on;
grid on;


% BOTON DE POSICIONES SERVO IZQUIERDO
function boton_angulos_servo_izq_Callback(hObject, eventdata, handles)
global vector_solid_angulos_izq vector_angulos_izq vector_tiempo_angulos_izq tamano_vector_angulos_izq ... 
       t_muestreo_angulos_izq t_simulacion_angulos_izq bandera_servos_cargados...
       vector_angulos_izq_SR bandera_calculada_cinematica ...
       bandera_boton_angulos_izq bandera_boton_velocidades_izq...
       bandera_boton_angulos_der bandera_boton_velocidades_der...
       bandera_trayectoria_ejecutada vector_angulos_izq_GR
   
set(handles.boton_angulos_servo_izq,'Visible','off');     % Oculta el boton angulos_servo_izq
set(handles.boton_velocidades_servo_izq,'Visible','off'); % Oculta el boton velocidades_servo_izq
set(handles.boton_angulos_servo_der,'Visible','off');     % Oculta el boton angulos_servo_der
set(handles.boton_velocidades_servo_der,'Visible','off'); % Oculta el boton velocidades_servo_der
set(handles.panel_cargar_servos,'Visible','off');         % Oculta el panel cargar_servos
set(handles.boton_ejecutar,'Visible','off');              % Oculta el boton ejecutar_trayectoria
set(handles.boton_analizar,'Visible','off');              % Oculta el boton boton_analizar
set(handles.boton_detener,'Visible','off');               % Oculta el boton detener_trayectoria
set(handles.boton_calcular,'Visible','off');              % Oculta el boton boton_calcular

[filename, ~] = uigetfile('*.csv', 'Elije un archivo');   % Abre el cuadro de dialogo windows para seleccionar un archivo

if filename == 0 % Pregunta si NO se ha seleccionado un archivo y se ha cerrado el cuadro de dialogo
    set(handles.boton_angulos_servo_izq,'Visible','on');     % Visualiza el boton angulos_servo_izq
    set(handles.boton_velocidades_servo_izq,'Visible','on'); % Visualiza el boton velocidades_servo_izq
    set(handles.boton_angulos_servo_der,'Visible','on');     % Visualiza el boton angulos_servo_der
    set(handles.boton_velocidades_servo_der,'Visible','on'); % Visualiza el boton velocidades_servo_der
    if bandera_boton_angulos_izq == 1 && bandera_boton_velocidades_izq == 1 && bandera_boton_angulos_der == 1 && bandera_boton_velocidades_der == 1
        set(handles.boton_calcular,'Visible','on');              % Visualiza el boton boton_calcular
    end
    if bandera_servos_cargados == 1
    set(handles.boton_ejecutar,'Visible','on');              % Visualiza el boton ejecutar_trayectoria
    set(handles.boton_detener,'Visible','on');               % Visualiza el boton detener_trayectoria
    end
    if bandera_calculada_cinematica == 1
    set(handles.panel_cargar_servos,'Visible','on');         % Visualiza el panel cargar_servos
    end
    if bandera_trayectoria_ejecutada == 1
        set(handles.boton_analizar,'Visible','on');              % Visualiza el boton boton_analizar
    end

else % Pregunta si SI se ha seleccionado un archivo y se ha cerrado el cuadro de dialogo
    bandera_trayectoria_ejecutada = 0;
    bandera_boton_angulos_izq = 1;
    bandera_calculada_cinematica=0;
    bandera_servos_cargados=0;
    vector_angulos_izq_GR=0;
    vector_angulos_izq_SR=0;
    vector_solid_angulos_izq = csvread(filename,2);                                    % Carga el archivo de angulos izquierdo traido de SolidWorks 
    vector_angulos_izq = vector_solid_angulos_izq(:,2);                                % Extrae el vector de angulos izquierdo
    vector_tiempo_angulos_izq = vector_solid_angulos_izq(:,1);                         % Extrae el vector de tiempo asociado a los angulos izquierdos
    tamano_vector_angulos_izq = size(vector_tiempo_angulos_izq,1);                     % Extrae el tamaño del vector de angulos

    for i=1:tamano_vector_angulos_izq                                                  % Ejecuta el ciclo con valores de i desde 1 hasta el tamaño del vector, variando de uno en uno
        vector_angulos_izq_GR(i) = (180-vector_angulos_izq(i));                        % Suma el desfase de 180 grados debido al marco de referencia de medida de SolidWorks
        vector_angulos_izq_SR(i) = (11.375*vector_angulos_izq_GR(i));                  % Convierte grados en cuentas, 0-360 grados equivalente a 0-4095, sumando el desfase de 180 grados debido al marco de referencia de medida de SolidWorks
        vector_angulos_izq(i) = round(vector_angulos_izq_SR(i));                       % Redondea en cuentas
        vector_tiempo_angulos_izq(i) = round(vector_tiempo_angulos_izq(i)*1000);
    end
    t_muestreo_angulos_izq = vector_tiempo_angulos_izq(2,1);                           % Extrae el tiempo de muestreo del vector de angulos
    t_simulacion_angulos_izq = vector_tiempo_angulos_izq(tamano_vector_angulos_izq,1); % Extrae el tiempo de simulacion del vector de angulos

    set(handles.static_text_tiempo_muestreo,'string',[''],'BackgroundColor',[1 1 1]);   % Limpia static_text_tiempo_muestreo
    set(handles.static_text_tiempo_simulacion,'string',[''],'BackgroundColor',[1 1 1]); % Limpia static_text_tiempo_simulacion
    set(handles.static_text_carga_servos,'string',[''],'BackgroundColor',[1 1 1]);      % Limpia static_text_carga_servos
    set(handles.static_text_tamano_vector,'string',[''],'BackgroundColor',[1 1 1]);     % Limpia static_text_tamano_vector

    axes(handles.axes_posiciones_servo_izq);                                               % Selecciona el Axes a trabajar
    cla(handles.axes_posiciones_servo_izq);                                                % Limpia el axes
    axis([0 max(vector_tiempo_angulos_izq)+100 min(vector_angulos_izq_GR) max(vector_angulos_izq_GR)+4]);   % Fija la amplitud del osciloscopio respecto al minimo y maximo valor cargado
    scatter(vector_tiempo_angulos_izq,vector_angulos_izq_GR,'.','MarkerEdgeColor',[0 0.6 0]);               % Grafica los datos con el carga exitosa de color verde

vector_angulos_izq_GR=transpose(vector_angulos_izq_GR);   % Convierte un Vector Fila en un Vector Columna
ruta=[pwd,'\Datos_Estadisticos.xls']; % ubica la carpeta del actual directorio de trabajo (current working directory)
xlswrite(ruta,vector_angulos_izq_GR,1,'F2');

set(handles.boton_angulos_servo_izq,'Visible','on');                                % Visualiza el boton angulos_servo_izq
set(handles.boton_velocidades_servo_izq,'Visible','on');                            % Visualiza el boton velocidades_servo_izq
set(handles.boton_angulos_servo_der,'Visible','on');                                % Visualiza el boton angulos_servo_der
set(handles.boton_velocidades_servo_der,'Visible','on');                            % Visualiza el boton velocidades_servo_der
set(handles.boton_analizar,'Visible','off');                                        % Oculta el boton boton_analizar

if bandera_boton_angulos_izq == 1 && bandera_boton_velocidades_izq == 1 && bandera_boton_angulos_der == 1 && bandera_boton_velocidades_der == 1
    set(handles.boton_calcular,'Visible','on');              % Visualiza el boton boton_calcular
end

end


% BOTON DE POSICIONES SERVO DERECHO
function boton_angulos_servo_der_Callback(hObject, eventdata, handles)
global vector_solid_angulos_der vector_angulos_der vector_tiempo_angulos_der tamano_vector_angulos_der ...
       t_muestreo_angulos_der t_simulacion_angulos_der bandera_servos_cargados...
       vector_angulos_der_SR bandera_calculada_cinematica ...
       bandera_boton_angulos_izq bandera_boton_velocidades_izq...
       bandera_boton_angulos_der bandera_boton_velocidades_der...
       bandera_trayectoria_ejecutada vector_angulos_der_GR
    
set(handles.boton_angulos_servo_izq,'Visible','off');     % Oculta el boton angulos_servo_izq
set(handles.boton_velocidades_servo_izq,'Visible','off'); % Oculta el boton velocidades_servo_izq
set(handles.boton_angulos_servo_der,'Visible','off');     % Oculta el boton angulos_servo_der
set(handles.boton_velocidades_servo_der,'Visible','off'); % Oculta el boton velocidades_servo_der
set(handles.panel_cargar_servos,'Visible','off');         % Oculta el panel cargar_servos
set(handles.boton_ejecutar,'Visible','off');              % Oculta el boton ejecutar_trayectoria
set(handles.boton_analizar,'Visible','off');              % Oculta el boton boton_analizar
set(handles.boton_detener,'Visible','off');               % Oculta el boton detener_trayectoria
set(handles.boton_calcular,'Visible','off');              % Oculta el boton boton_calcular

[filename, ~] = uigetfile('*.csv', 'Elije un archivo');   % Abre el cuadro de dialogo windows para seleccionar un archivo

if filename == 0 % Pregunta si NO se ha seleccionado un archivo y se ha cerrado el cuadro de dialogo
    set(handles.boton_angulos_servo_izq,'Visible','on');      % Visualiza el boton angulos_servo_izq
    set(handles.boton_velocidades_servo_izq,'Visible','on');  % Visualiza el boton velocidades_servo_izq
    set(handles.boton_angulos_servo_der,'Visible','on');      % Visualiza el boton angulos_servo_der
    set(handles.boton_velocidades_servo_der,'Visible','on');  % Visualiza el boton velocidades_servo_der
    if bandera_boton_angulos_izq == 1 && bandera_boton_velocidades_izq == 1 && bandera_boton_angulos_der == 1 && bandera_boton_velocidades_der == 1;
        set(handles.boton_calcular,'Visible','on');              % Visualiza el boton boton_calcular
    end
    if bandera_servos_cargados == 1
    set(handles.boton_ejecutar,'Visible','on');              % Visualiza el boton ejecutar_trayectoria
    set(handles.boton_detener,'Visible','on');               % Visualiza el boton detener_trayectoria
    end
    if bandera_calculada_cinematica == 1
    set(handles.panel_cargar_servos,'Visible','on');         % Visualiza el panel cargar_servos
    end
    if bandera_trayectoria_ejecutada == 1
        set(handles.boton_analizar,'Visible','on');              % Visualiza el boton boton_analizar
    end
    
else % Pregunta si SI se ha seleccionado un archivo y se ha cerrado el cuadro de dialogo
    bandera_trayectoria_ejecutada = 0;
    bandera_boton_velocidades_izq = 1;
    bandera_calculada_cinematica = 0;
    bandera_servos_cargados=0;
    vector_angulos_der_GR=0;
    vector_angulos_der_SR=0;
    vector_solid_angulos_der = csvread(filename,2);                                     % Carga el archivo de angulos izquierdo traido de SolidWorks 
    vector_angulos_der = vector_solid_angulos_der(:,2);                                 % Extrae el vector de angulos izquierdo
    vector_tiempo_angulos_der = vector_solid_angulos_der(:,1);                          % Extrae el vector de tiempo asociado a los angulos izquierdos
    tamano_vector_angulos_der = size(vector_tiempo_angulos_der,1);                      % Extrae el tamaño del vector de angulos
   
    for i=1:tamano_vector_angulos_der                                                  % Ejecuta el ciclo con valores de i desde 1 hasta el tamaño del vector, variando de uno en uno
        vector_angulos_der_GR(i) = (180-vector_angulos_der(i));                        % Suma el desfase de 180 grados debido al marco de referencia de medida de SolidWorks
        vector_angulos_der_SR(i) = (11.375*vector_angulos_der_GR(i));                  % Convierte grados en cuentas, 0-360 grados equivalente a 0-4095, sumando el desfase de 180 grados debido al marco de referencia de medida de SolidWorks
        vector_angulos_der(i) = round(vector_angulos_der_SR(i));                       % Redondea las cuentas, 
        vector_tiempo_angulos_der(i) = round(vector_tiempo_angulos_der(i)*1000);
    end
    t_muestreo_angulos_der = vector_tiempo_angulos_der(2,1);                           % Extrae el tiempo de muestreo del vector de angulos
    t_simulacion_angulos_der = vector_tiempo_angulos_der(tamano_vector_angulos_der,1); % Extrae el tiempo de simulacion del vector de angulos
      
    set(handles.static_text_tiempo_muestreo,'string',[''],'BackgroundColor',[1 1 1]);   % Limpia static_text_tiempo_muestreo
    set(handles.static_text_tiempo_simulacion,'string',[''],'BackgroundColor',[1 1 1]); % Limpia static_text_tiempo_simulacion
    set(handles.static_text_carga_servos,'string',[''],'BackgroundColor',[1 1 1]);      % Limpia static_text_carga_servos
    set(handles.static_text_tamano_vector,'string',[''],'BackgroundColor',[1 1 1]);     % Limpia static_text_tamano_vector
    
    axes(handles.axes_posiciones_servo_der);                                               % Selecciona el Axes a trabajar
    cla(handles.axes_posiciones_servo_der);                                                % Limpia el axes
    axis([0 max(vector_tiempo_angulos_der)+100 min(vector_angulos_der_GR) max(vector_angulos_der_GR)+4]); % Fija la amplitud del osciloscopio respecto al minimo y maximo valor cargado
    scatter(vector_tiempo_angulos_der,vector_angulos_der_GR,'.','MarkerEdgeColor',[0 0.6 0]);
    
vector_angulos_der_GR=transpose(vector_angulos_der_GR);   % Convierte un Vector Fila en un Vector Columna
ruta=[pwd,'\Datos_Estadisticos.xls']; % ubica la carpeta del actual directorio de trabajo (current working directory)
xlswrite(ruta,vector_angulos_der_GR,1,'H2');

set(handles.boton_angulos_servo_izq,'Visible','on');                                % Visualiza el boton angulos_servo_izq
set(handles.boton_velocidades_servo_izq,'Visible','on');                            % Visualiza el boton velocidades_servo_izq
set(handles.boton_angulos_servo_der,'Visible','on');                                % Visualiza el boton angulos_servo_der
set(handles.boton_velocidades_servo_der,'Visible','on');                            % Visualiza el boton velocidades_servo_der
set(handles.boton_analizar,'Visible','off');                                        % Visualiza el boton boton_analizar

if bandera_boton_angulos_izq == 1 && bandera_boton_velocidades_izq == 1 && bandera_boton_angulos_der == 1 && bandera_boton_velocidades_der == 1;
    set(handles.boton_calcular,'Visible','on');              % Visualiza el boton boton_calcular
end

end


% BOTON DE VELOCIDADES SERVO IZQUIERDO
function boton_velocidades_servo_izq_Callback(hObject, eventdata, handles)
global vector_solid_velocidades_izq vector_velocidades_izq vector_tiempo_velocidades_izq tamano_vector_velocidades_izq ...
       t_muestreo_velocidades_izq t_simulacion_velocidades_izq bandera_servos_cargados...
       vector_velocidades_izq_SR bandera_calculada_cinematica ...
       bandera_boton_angulos_izq bandera_boton_velocidades_izq...
       bandera_boton_angulos_der bandera_boton_velocidades_der...
       bandera_trayectoria_ejecutada vector_velocidades_izq_GR
 
set(handles.boton_angulos_servo_izq,'Visible','off');     % Oculta el boton angulos_servo_izq
set(handles.boton_velocidades_servo_izq,'Visible','off'); % Oculta el boton velocidades_servo_izq
set(handles.boton_angulos_servo_der,'Visible','off');     % Oculta el boton angulos_servo_der
set(handles.boton_velocidades_servo_der,'Visible','off'); % Oculta el boton velocidades_servo_der
set(handles.panel_cargar_servos,'Visible','off');         % Oculta el panel cargar_servos
set(handles.boton_ejecutar,'Visible','off');              % Oculta el boton ejecutar_trayectoria
set(handles.boton_analizar,'Visible','off');              % Oculta el boton boton_analizar
set(handles.boton_detener,'Visible','off');               % Oculta el boton detener_trayectoria
set(handles.boton_calcular,'Visible','off');              % Oculta el boton boton_calcular

[filename, ~] = uigetfile('*.csv', 'Elije un archivo');   % Abre el cuadro de dialogo windows para seleccionar archivo

if filename == 0 % Pregunta si NO se ha seleccionado un archivo y se ha cerrado el cuadro de dialogo
    set(handles.boton_angulos_servo_izq,'Visible','on');      % Visualiza el boton angulos_servo_izq
    set(handles.boton_velocidades_servo_izq,'Visible','on');  % Visualiza el boton velocidades_servo_izq
    set(handles.boton_angulos_servo_der,'Visible','on');      % Visualiza el boton angulos_servo_der
    set(handles.boton_velocidades_servo_der,'Visible','on');  % Visualiza el boton velocidades_servo_der
    if bandera_boton_angulos_izq == 1 && bandera_boton_velocidades_izq == 1 && bandera_boton_angulos_der == 1 && bandera_boton_velocidades_der == 1;
        set(handles.boton_calcular,'Visible','on');              % Visualiza el boton boton_calcular
    end
    if bandera_servos_cargados == 1
    set(handles.boton_ejecutar,'Visible','on');              % Visualiza el boton ejecutar_trayectoria
    set(handles.boton_detener,'Visible','on');               % Visualiza el boton detener_trayectoria
    end
    if bandera_calculada_cinematica == 1
    set(handles.panel_cargar_servos,'Visible','on');         % Visualiza el panel cargar_servos
    end
    if bandera_trayectoria_ejecutada == 1
        set(handles.boton_analizar,'Visible','on');              % Visualiza el boton boton_analizar
    end
    
else % Pregunta si SI se ha seleccionado un archivo y se ha cerrado el cuadro de dialogo
    bandera_trayectoria_ejecutada = 0;
    bandera_boton_angulos_der = 1;
    bandera_calculada_cinematica = 0;
    bandera_servos_cargados=0;
    vector_velocidades_izq_GR=0;
    vector_velocidades_izq_SR=0;
    vector_solid_velocidades_izq = csvread(filename,2);                                             % Carga el archivo de velocidades izquierdo traido de SolidWorks 
    vector_velocidades_izq = vector_solid_velocidades_izq(:,2);                                     % Extrae el vector de velocidades izquierdo
    vector_tiempo_velocidades_izq = vector_solid_velocidades_izq(:,1);                              % Extrae el vector de tiempo asociado a las velocidades izquierdas
    tamano_vector_velocidades_izq = size(vector_tiempo_velocidades_izq,1);                          % Extrae el tamaño del vector de velocidades

    for i=1:tamano_vector_velocidades_izq                                                           % Ejecuta el ciclo con valores de i desde 1 hasta el tamaño del vector, variando de uno en uno
        vector_velocidades_izq_GR(i) = vector_velocidades_izq(i);                                   % Velocidad de 0-375 grados/seg
        vector_velocidades_izq_SR(i) = (1.419*vector_velocidades_izq_GR(i));               % Convierte grados/s en cuentas, Velocidad de 0-530 equivalente a 0-375 grados/seg
        vector_velocidades_izq(i) = round(vector_velocidades_izq_SR(i));                            % Redondea en cuentas
        vector_tiempo_velocidades_izq(i) = round(vector_tiempo_velocidades_izq(i)*1000);
    end
    t_muestreo_velocidades_izq = vector_tiempo_velocidades_izq(2,1);                                % Extrae el tiempo de muestreo del vector de angulos
    t_simulacion_velocidades_izq = vector_tiempo_velocidades_izq(tamano_vector_velocidades_izq,1);  % Extrae el tiempo de simulacion del vector de angulos
    
    set(handles.static_text_tiempo_muestreo,'string',[''],'BackgroundColor',[1 1 1]);   % Limpia static_text_tiempo_muestreo
    set(handles.static_text_tiempo_simulacion,'string',[''],'BackgroundColor',[1 1 1]); % Limpia static_text_tiempo_simulacion
    set(handles.static_text_carga_servos,'string',[''],'BackgroundColor',[1 1 1]);      % Limpia static_text_carga_servos
    set(handles.static_text_tamano_vector,'string',[''],'BackgroundColor',[1 1 1]);     % Limpia static_text_tamano_vector

    axes(handles.axes_velocidades_servo_izq);                                           % Selecciona el Axes a trabajar
    cla(handles.axes_velocidades_servo_izq);                                            %limpia el axes
    axis([0 max(vector_tiempo_velocidades_izq)+100 min(vector_velocidades_izq_GR) max(vector_velocidades_izq_GR)+4]); % Fija la amplitud del osciloscopio respecto al minimo y maximo valor cargado
    scatter(vector_tiempo_velocidades_izq,vector_velocidades_izq_GR,'.','MarkerEdgeColor',[0 0.6 0]);

vector_velocidades_izq_GR=transpose(vector_velocidades_izq_GR);   % Convierte un Vector Fila en un Vector Columna
ruta=[pwd,'\Datos_Estadisticos.xls']; % ubica la carpeta del actual directorio de trabajo (current working directory)
xlswrite(ruta,vector_velocidades_izq_GR,1,'J2');

set(handles.boton_angulos_servo_izq,'Visible','on');                                % Visualiza el boton angulos_servo_izq
set(handles.boton_velocidades_servo_izq,'Visible','on');                            % Visualiza el boton velocidades_servo_izq
set(handles.boton_angulos_servo_der,'Visible','on');                                % Visualiza el boton angulos_servo_der
set(handles.boton_velocidades_servo_der,'Visible','on');                            % Visualiza el boton velocidades_servo_der
set(handles.boton_analizar,'Visible','off');                                        % Visualiza el boton boton_analizar

if bandera_boton_angulos_izq == 1 && bandera_boton_velocidades_izq == 1 && bandera_boton_angulos_der == 1 && bandera_boton_velocidades_der == 1;
    set(handles.boton_calcular,'Visible','on');              % Visualiza el boton boton_calcular
end

end


% BOTON DE VELOCIDADES SERVO DERECHO
function boton_velocidades_servo_der_Callback(hObject, eventdata, handles)
global vector_solid_velocidades_der vector_velocidades_der vector_tiempo_velocidades_der tamano_vector_velocidades_der ...
       t_muestreo_velocidades_der t_simulacion_velocidades_der bandera_servos_cargados...
       vector_velocidades_der_SR bandera_calculada_cinematica ...
       bandera_boton_angulos_izq bandera_boton_velocidades_izq...
       bandera_boton_angulos_der bandera_boton_velocidades_der...
       bandera_trayectoria_ejecutada vector_velocidades_der_GR

set(handles.boton_angulos_servo_izq,'Visible','off');     % Oculta el boton angulos_servo_izq
set(handles.boton_velocidades_servo_izq,'Visible','off'); % Oculta el boton velocidades_servo_izq
set(handles.boton_angulos_servo_der,'Visible','off');     % Oculta el boton angulos_servo_der
set(handles.boton_velocidades_servo_der,'Visible','off'); % Oculta el boton velocidades_servo_der
set(handles.panel_cargar_servos,'Visible','off');         % Oculta el panel cargar_servos
set(handles.boton_ejecutar,'Visible','off');              % Oculta el boton ejecutar_trayectoria
set(handles.boton_analizar,'Visible','off');              % Oculta el boton boton_analizar
set(handles.boton_detener,'Visible','off');               % Oculta el boton detener_trayectoria
set(handles.boton_calcular,'Visible','off');              % Oculta el boton boton_calcular

[filename, ~] = uigetfile('*.csv', 'Elije un archivo');   % Abre el cuadro de dialogo windows para seleccionar archivo

if filename == 0 % Pregunta si NO se ha seleccionado un archivo y se ha cerrado el cuadro de dialogo
    set(handles.boton_angulos_servo_izq,'Visible','on');      % Visualiza el boton angulos_servo_izq
    set(handles.boton_velocidades_servo_izq,'Visible','on');  % Visualiza el boton velocidades_servo_izq
    set(handles.boton_angulos_servo_der,'Visible','on');      % Visualiza el boton angulos_servo_der
    set(handles.boton_velocidades_servo_der,'Visible','on');  % Visualiza el boton velocidades_servo_der
    if bandera_boton_angulos_izq == 1 && bandera_boton_velocidades_izq == 1 && bandera_boton_angulos_der == 1 && bandera_boton_velocidades_der == 1;
        set(handles.boton_calcular,'Visible','on');              % Visualiza el boton boton_calcular
    end
    if bandera_servos_cargados == 1
    set(handles.boton_ejecutar,'Visible','on');              % Visualiza el boton ejecutar_trayectoria
    set(handles.boton_detener,'Visible','on');               % Visualiza el boton detener_trayectoria
    end
    if bandera_calculada_cinematica == 1
    set(handles.panel_cargar_servos,'Visible','on');         % Visualiza el panel cargar_servos
    end
    if bandera_trayectoria_ejecutada == 1
        set(handles.boton_analizar,'Visible','on');              % Visualiza el boton boton_analizar
    end

else % Pregunta si SI se ha seleccionado un archivo y se ha cerrado el cuadro de dialogo
    bandera_trayectoria_ejecutada = 0;
    bandera_boton_velocidades_der = 1;
    bandera_calculada_cinematica = 0;
    bandera_servos_cargados=0;
    vector_velocidades_der_GR=0;
    vector_velocidades_der_SR=0;
    vector_solid_velocidades_der = csvread(filename,2);                                             % Carga el archivo de velocidades izquierdo traido de SolidWorks 
    vector_velocidades_der = vector_solid_velocidades_der(:,2);                                     % Extrae el vector de velocidades izquierdo
    vector_tiempo_velocidades_der = vector_solid_velocidades_der(:,1);                              % Extrae el vector de tiempo asociado a las velocidades izquierdas
    tamano_vector_velocidades_der = size(vector_tiempo_velocidades_der,1);                          % Extrae el tamaño del vector de velocidades

    for i=1:tamano_vector_velocidades_der                                                           % Ejecuta el ciclo con valores de i desde 1 hasta el tamaño del vector, variando de uno en uno
        vector_velocidades_der_GR(i) = vector_velocidades_der(i);                                   % Velocidad de 0-375 grados/seg
        vector_velocidades_der_SR(i) = (1.419*vector_velocidades_der_GR(i));               % Convierte grados/s en cuentas, Velocidad de 0-530 equivalente a 0-375 grados/seg
        vector_velocidades_der(i) = round(vector_velocidades_der_SR(i));                            % Redondea en cuentas
        vector_tiempo_velocidades_der(i) = round(vector_tiempo_velocidades_der(i)*1000);
    end
    t_muestreo_velocidades_der = vector_tiempo_velocidades_der(2,1);                                % Extrae el tiempo de muestreo del vector de velocidades
    t_simulacion_velocidades_der = vector_tiempo_velocidades_der(tamano_vector_velocidades_der,1);  % Extrae el tiempo de simulacion del vector de velocidades
   
    set(handles.static_text_tiempo_muestreo,'string',[''],'BackgroundColor',[1 1 1]);   % Limpia static_text_tiempo_muestreo
    set(handles.static_text_tiempo_simulacion,'string',[''],'BackgroundColor',[1 1 1]); % Limpia static_text_tiempo_simulacion
    set(handles.static_text_carga_servos,'string',[''],'BackgroundColor',[1 1 1]);      % Limpia static_text_carga_servos
    set(handles.static_text_tamano_vector,'string',[''],'BackgroundColor',[1 1 1]);     % Limpia static_text_tamano_vector

    axes(handles.axes_velocidades_servo_der);                                           % Selecciona el Axes a trabajar
    cla(handles.axes_velocidades_servo_der);                                            %limpia el axes
    axis([0 max(vector_tiempo_velocidades_der)+100 min(vector_velocidades_der_GR) max(vector_velocidades_der_GR)+4]); % Fija la amplitud del osciloscopio respecto al minimo y maximo valor cargado
    scatter(vector_tiempo_velocidades_der,vector_velocidades_der_GR,'.','MarkerEdgeColor',[0 0.6 0]);

vector_velocidades_der_GR=transpose(vector_velocidades_der_GR);   % Convierte un Vector Fila en un Vector Columna
ruta=[pwd,'\Datos_Estadisticos.xls']; % ubica la carpeta del actual directorio de trabajo (current working directory)
xlswrite(ruta,vector_velocidades_der_GR,1,'L2');

set(handles.boton_angulos_servo_izq,'Visible','on');                                % Visualiza el boton angulos_servo_izq
set(handles.boton_velocidades_servo_izq,'Visible','on');                            % Visualiza el boton velocidades_servo_izq
set(handles.boton_angulos_servo_der,'Visible','on');                                % Visualiza el boton angulos_servo_der
set(handles.boton_velocidades_servo_der,'Visible','on');                            % Visualiza el boton velocidades_servo_der
set(handles.boton_analizar,'Visible','off');              % Visualiza el boton boton_analizar

if bandera_boton_angulos_izq == 1 && bandera_boton_velocidades_izq == 1 && bandera_boton_angulos_der == 1 && bandera_boton_velocidades_der == 1;
    set(handles.boton_calcular,'Visible','on');              % Visualiza el boton boton_calcular
end

end


% BOTON CALCULAR CINEMATICA
function boton_calcular_Callback(hObject, eventdata, handles)
global tamano_vector_angulos_izq vector_solid_angulos_izq vector_solid_angulos_der...
       vector_tiempo_angulos_izq ...
       vector_tiempo_velocidades_izq ...
       vector_tiempo_angulos_der ...
       vector_tiempo_velocidades_der ...
       bandera_servos_cargados xc_v yc_v l1 l2 l3 l4 l5 t_muestreo...
       bandera_calculada_cinematica...
       t_simulacion tamano_vector tamano_vector_velocidades_izq ...
       tamano_vector_angulos_der tamano_vector_velocidades_der ...
       t_muestreo_angulos_izq t_muestreo_velocidades_izq...
       t_muestreo_angulos_der t_muestreo_velocidades_der...
       t_simulacion_angulos_izq t_simulacion_velocidades_izq ...
       t_simulacion_angulos_der t_simulacion_velocidades_der ...
       bandera_t_muestreo bandera_t_simulacion bandera_tamano_vector...
       bandera_trayectoria_ejecutada...
       vector_angulos_izq_GR vector_angulos_der_GR vector_velocidades_izq_GR vector_velocidades_der_GR
   
if tamano_vector_angulos_izq == tamano_vector_velocidades_izq && tamano_vector_angulos_izq == tamano_vector_angulos_der && tamano_vector_velocidades_izq == tamano_vector_velocidades_der % Pregunta si los tamaños de los vectores de angulos y velocidades para los servos son iguales
    tamano_vector = tamano_vector_angulos_izq;
if tamano_vector <= 751
    bandera_tamano_vector = 1;
    set(handles.static_text_tamano_vector,'string',['Cantidad de Muestras: ',num2str(tamano_vector)],'BackgroundColor',[1 1 1]);
else
    bandera_tamano_vector = 0;
    set(handles.static_text_tamano_vector,'string',['Cantidad de Muestras: ',num2str(tamano_vector)],'BackgroundColor',[1 1 0]);
end
else
    bandera_tamano_vector = 0;
    set(handles.static_text_tamano_vector,'string',['Cantidad de Muestras: 0'],'BackgroundColor',[1 1 1]);
end

if t_muestreo_angulos_izq == t_muestreo_velocidades_izq && t_muestreo_angulos_izq == t_muestreo_angulos_der && t_muestreo_velocidades_izq == t_muestreo_velocidades_der % Pregunta si los tiempos de muestreo de angulos y velocidades para los servos son iguales
    t_muestreo = t_muestreo_angulos_izq;
if t_muestreo >= 40
    bandera_t_muestreo = 1;
    set(handles.static_text_tiempo_muestreo,'string',['Tiempo de Muestreo: ',num2str(t_muestreo),' ms' ],'BackgroundColor',[1 1 1]);
else
    bandera_t_muestreo = 0;
    set(handles.static_text_tiempo_muestreo,'string',['Tiempo de Muestreo: ',num2str(t_muestreo),' ms' ],'BackgroundColor',[1 1 0]);
end
else
    bandera_t_muestreo = 0;
    set(handles.static_text_tiempo_muestreo,'string',['Tiempo de Muestreo: 0'],'BackgroundColor',[1 1 1]);
end

if t_simulacion_angulos_izq == t_simulacion_velocidades_izq && t_simulacion_angulos_izq == t_simulacion_angulos_der && t_simulacion_velocidades_izq == t_simulacion_velocidades_der % Pregunta si los tiempos de simulacion de angulos y velocidades para los servos son iguales
    t_simulacion = t_simulacion_angulos_izq;
    bandera_t_simulacion = 1;
    set(handles.static_text_tiempo_simulacion,'string',['Tiempo de Ejecución: ',num2str(t_simulacion/1000),' s' ],'BackgroundColor',[1 1 1]); 
else
    bandera_t_simulacion = 0;
    set(handles.static_text_tiempo_simulacion,'string',['Tiempo de Ejecución: 0'],'BackgroundColor',[1 1 1]);
end
    
if bandera_tamano_vector == 1 && bandera_t_muestreo == 1 && bandera_t_simulacion == 1 % Pregunta si son iguales los tamaños de los ventores, los tiempos de muestreo y los tiempos de simulacion 
    [q, fs]=audioread('calculando cinematica.wav'); % lee la frecuencia y las muestras del audio de abriendo generador
    sound(q,fs); % reproduce el audio regresando abriendo generador

    set(handles.boton_angulos_servo_izq,'Visible','off');     % Oculta el boton angulos_servo_izq
    set(handles.boton_velocidades_servo_izq,'Visible','off'); % Oculta el boton velocidades_servo_izq
    set(handles.boton_angulos_servo_der,'Visible','off');     % Oculta el boton angulos_servo_der
    set(handles.boton_velocidades_servo_der,'Visible','off'); % Oculta el boton velocidades_servo_der
    set(handles.panel_cargar_servos,'Visible','off');         % Oculta el panel cargar_servos
    set(handles.boton_ejecutar,'Visible','off');              % Oculta el boton ejecutar_trayectoria
    set(handles.boton_analizar,'Visible','off');              % Oculta el boton boton_analizar
    set(handles.boton_detener,'Visible','off');               % Oculta el boton detener_trayectoria
    set(handles.boton_calcular,'Visible','off');              % Oculta el boton boton_calcular

    axes(handles.axes_posiciones_servo_izq); % Selecciona el Axes a trabajar 
    cla();  % Limpia el axes seleccionado
    scatter(vector_tiempo_angulos_izq,vector_angulos_izq_GR,'.','MarkerEdgeColor',[0 0.6 0]);

    axes(handles.axes_velocidades_servo_izq); % Selecciona el Axes a trabajar
    cla();  % Limpia el axes seleccionado
    scatter(vector_tiempo_velocidades_izq,vector_velocidades_izq_GR,'.','MarkerEdgeColor',[0 0.6 0]);

    axes(handles.axes_posiciones_servo_der); % Selecciona el Axes a trabajar 
    cla();  % Limpia el axes seleccionado
    scatter(vector_tiempo_angulos_der,vector_angulos_der_GR,'.','MarkerEdgeColor',[0 0.6 0]);

    axes(handles.axes_velocidades_servo_der); % Selecciona el Axes a trabajar
    cla();  % Limpia el axes seleccionado
    scatter(vector_tiempo_velocidades_der,vector_velocidades_der_GR,'.','MarkerEdgeColor',[0 0.6 0]);

    %VECTORES DE DATOS
    q1=90.-vector_solid_angulos_izq(:,2);
    q4=90.-vector_solid_angulos_der(:,2);
    xc_v=0;
    yc_v=0;
    xe=l5;

    %CALCULO Y GRAFICACION DE CINEMATICA DIRECTA CON EL MODELO DE CLEMENCIA
    t_0_milisegundos=0;
    t_1_milisegundos=0;
    for i=1:tamano_vector_angulos_izq
    tActual=clock;
    t_0_milisegundos=((tActual(4)*3600)+(tActual(5)*60)+(tActual(6)))*1000;
    e=(l1*sind(q1(i))-l4*sind(q4(i)))/(xe+l4*cosd(q4(i))-l1*cosd(q1(i)));
    f=[l1^2+l3^2-l2^2-l4^2-xe^2-[2*l4*xe*cosd(q4(i))]]/[2*l1*cosd(q1(i))-2*l4*cosd(q4(i))-2*xe];
    d=e^2+1;
    g=(2*e*f-2*e*l1*cosd(q1(i))-2*l1*sind(q1(i)));
    h=f^2-2*f*l1*cosd(q1(i))+l1^2-l2^2;
    yc_v(i)=[-g+sqrt(g^2-4*d*h)]/(2*d);
    xc_v(i)=e*yc_v(i)+f;
    %GRAFICACION TRAYECTORIA VIRTUAL
    axes(handles.axes_trayectoria);
    cla;
    scatter(xc_v,yc_v,'.','MarkerEdgeColor',[0 0.6 0]);

    %GRAFICACION DE LAS BARRAS
    xb=l1*cosd(q1(i));
    yb=l1*sind(q1(i));
    xd=l5+l4*cosd(q4(i));
    yd=l4*sind(q4(i));
    Bx=linspace(0,xb);
    By=linspace(0,yb);
    Dx=linspace(l5,xd);
    Dy=linspace(0,yd);
    Cx1=linspace(xb,xc_v(i));
    Cy1=linspace(yb,yc_v(i));
    Cx2=linspace(xc_v(i),xd);
    Cy2=linspace(yc_v(i),yd);
    brazox=[Bx Cx1 Cx2 Dx ];
    brazoy=[By Cy1 Cy2 Dy ];
    plot(brazox,brazoy,'Color','blue','Linewidth',2)
    
%     while (t_1_milisegundos) < (t_0_milisegundos+t_muestreo)
%         tActual=clock;
%         t_1_milisegundos=((tActual(4)*3600)+(tActual(5)*60)+(tActual(6)))*1000;
%     end
    
    end % del for que grafica toda la cinematica

    set(handles.static_text_carga_servos,'string',['        Cálculo        Exitoso'],'BackgroundColor',[1 1 1]);
    set(handles.boton_angulos_servo_izq,'Visible','on');                                % Visualiza el boton angulos_servo_izq
    set(handles.boton_velocidades_servo_izq,'Visible','on');                            % Visualiza el boton velocidades_servo_izq
    set(handles.boton_angulos_servo_der,'Visible','on');                                % Visualiza el boton angulos_servo_der
    set(handles.boton_velocidades_servo_der,'Visible','on');                            % Visualiza el boton velocidades_servo_der
    set(handles.panel_cargar_servos,'Visible','on');                                    % Visualiza el panel cargar_servos
    set(handles.boton_cargar_servos,'Visible','on');                                    % Visualiza el boton boton_calcular
    set(handles.boton_calcular,'Visible','on');                                         % Visualiza el boton boton_calcular
    if bandera_servos_cargados == 1
    set(handles.boton_ejecutar,'Visible','on');              % Visualiza el boton_ejecutar
    set(handles.boton_detener,'Visible','on');               % Visualiza el boton_detener
    end
    if bandera_trayectoria_ejecutada == 1
        set(handles.boton_analizar,'Visible','on');          % Visualiza el boton boton_analizar
    end

    ruta=[pwd,'\Datos_Estadisticos.xls']; % ubica la carpeta del actual directorio de trabajo (current working directory)
    xlswrite(ruta,tamano_vector,1,'A2');% Escribe en el archivo de excel en la hoja 1, columna A

    bandera_calculada_cinematica=1;
    [q,fs] = audioread('proceso finalizado.wav');            % Lee la frecuencia y las muestras del archivo de audio
    sound(q,fs);                                             % Reproduce el audio
    
else

    set(handles.static_text_carga_servos,'string',['        Cálculo        Fallido'],'BackgroundColor',[1 0.5 0]);
    set(handles.boton_angulos_servo_izq,'Visible','on');     % Visualiza el boton posiciones_servo_izq
    set(handles.boton_velocidades_servo_izq,'Visible','on'); % Visualiza el boton velocidades_servo_izq
    set(handles.boton_angulos_servo_der,'Visible','on');     % Visualiza el boton posiciones_servo_der
    set(handles.boton_velocidades_servo_der,'Visible','on'); % Visualiza el boton velocidades_servo_der
    set(handles.panel_cargar_servos,'Visible','on');         % Visualiza el panel cargar_servos
    set(handles.boton_calcular,'Visible','on');              % Visualiza el boton boton_calcular
    set(handles.boton_cargar_servos,'Visible','off');              % Oculta el boton boton_calcular
    [q,fs] = audioread('calculo fallido.wav');               % Lee la frecuencia y las muestras del archivo de audio
    sound(q,fs); % Reproduce el audio
    
end


% BOTON CARGAR SERVOS
function boton_cargar_servos_Callback(hObject, eventdata, handles)
global arduino t_muestreo t_simulacion tamano_vector ...
       tamano_vector_angulos_izq tamano_vector_velocidades_izq ...
       tamano_vector_angulos_der tamano_vector_velocidades_der ...
       t_muestreo_angulos_izq t_muestreo_velocidades_izq...
       t_muestreo_angulos_der t_muestreo_velocidades_der...
       t_simulacion_angulos_izq t_simulacion_velocidades_izq ...
       t_simulacion_angulos_der t_simulacion_velocidades_der ...
       bandera_t_muestreo bandera_t_simulacion bandera_tamano_vector...
       vector_angulos_izq vector_velocidades_izq ...
       vector_angulos_der vector_velocidades_der ...
       vector_tiempo_angulos_izq ...
       vector_tiempo_velocidades_izq ...
       vector_tiempo_angulos_der ...
       vector_tiempo_velocidades_der ...
       bandera_servos_cargados k l1 l2 l3 l4 l5 xc_v yc_v...
       vector_angulos_izq_GR vector_angulos_der_GR vector_velocidades_izq_GR vector_velocidades_der_GR
       
k = 0;
bandera_servos_cargados=0;
set(handles.boton_angulos_servo_izq,'Visible','off');     % Oculta el boton posiciones_servo_izq
set(handles.boton_velocidades_servo_izq,'Visible','off'); % Oculta el boton velocidades_servo_izq
set(handles.boton_angulos_servo_der,'Visible','off');     % Oculta el boton posiciones_servo_der
set(handles.boton_velocidades_servo_der,'Visible','off'); % Oculta el boton velocidades_servo_der
set(handles.panel_cargar_servos,'Visible','off');         % Oculta el panel cargar_servos
set(handles.boton_ejecutar,'Visible','off');              % Oculta el boton ejecutar_trayectoria
set(handles.boton_analizar,'Visible','off');              % Oculta el boton boton_analizar
set(handles.boton_detener,'Visible','off');               % Oculta el boton detener_trayectoria
set(handles.boton_calcular,'Visible','off');              % Oculta el boton boton_calcular

axes(handles.axes_posiciones_servo_izq); % Selecciona el Axes a trabajar 
cla();  % Limpia el axes seleccionado
scatter(vector_tiempo_angulos_izq,vector_angulos_izq_GR,'.','MarkerEdgeColor',[0 0.6 0]);

axes(handles.axes_velocidades_servo_izq); % Selecciona el Axes a trabajar
cla();  % Limpia el axes seleccionado
scatter(vector_tiempo_velocidades_izq,vector_velocidades_izq_GR,'.','MarkerEdgeColor',[0 0.6 0]);

axes(handles.axes_posiciones_servo_der); % Selecciona el Axes a trabajar 
cla();  % Limpia el axes seleccionado
scatter(vector_tiempo_angulos_der,vector_angulos_der_GR,'.','MarkerEdgeColor',[0 0.6 0]);

axes(handles.axes_velocidades_servo_der); % Selecciona el Axes a trabajar
cla();  % Limpia el axes seleccionado
scatter(vector_tiempo_velocidades_der,vector_velocidades_der_GR,'.','MarkerEdgeColor',[0 0.6 0]);

%CALCULO Y GRAFICACION DE CINEMATICA DIRECTA CON EL MODELO DE CLEMENCIA
q1=90;
q4=90;
xe=l5;
e=(l1*sind(q1)-l4*sind(q4))/(xe+l4*cosd(q4)-l1*cosd(q1));
f=[l1^2+l3^2-l2^2-l4^2-xe^2-[2*l4*xe*cosd(q4)]]/[2*l1*cosd(q1)-2*l4*cosd(q4)-2*xe];
d=e^2+1;
g=(2*e*f-2*e*l1*cosd(q1)-2*l1*sind(q1));
h=f^2-2*f*l1*cosd(q1)+l1^2-l2^2;
yc_r=[-g+sqrt(g^2-4*d*h)]/(2*d);
xc_r=e*yc_r+f;
%GRAFICACION TRAYECTORIA VIRTUAL
axes(handles.axes_trayectoria);
cla;
scatter(xc_v,yc_v,'.','MarkerEdgeColor',[0 0.6 0]);

%GRAFICACION DE LAS BARRAS
xb=l1*cosd(q1);
yb=l1*sind(q1);
xd=l5+l4*cosd(q4);
yd=l4*sind(q4);
Bx=linspace(0,xb);
By=linspace(0,yb);
Dx=linspace(l5,xd);
Dy=linspace(0,yd);
Cx1=linspace(xb,xc_r(k+1));
Cy1=linspace(yb,yc_r(k+1));
Cx2=linspace(xc_r(k+1),xd);
Cy2=linspace(yc_r(k+1),yd);
brazox=[Bx Cx1 Cx2 Dx ];
brazoy=[By Cy1 Cy2 Dy ];
plot(brazox,brazoy,'Color','blue','Linewidth',2)
%FIN DE LA GRAFICCION DE LA CINEMATICA

if tamano_vector_angulos_izq == tamano_vector_velocidades_izq && tamano_vector_angulos_izq == tamano_vector_angulos_der && tamano_vector_velocidades_izq == tamano_vector_velocidades_der % Pregunta si los tamaños de los vectores de angulos y velocidades para los servos son iguales
    tamano_vector = tamano_vector_angulos_izq;
if tamano_vector <= 751
    bandera_tamano_vector = 1;
    set(handles.static_text_tamano_vector,'string',['Cantidad de Muestras: ',num2str(tamano_vector)],'BackgroundColor',[1 1 1]);
else
    bandera_tamano_vector = 0;
    set(handles.static_text_tamano_vector,'string',['Cantidad de Muestras: ',num2str(tamano_vector)],'BackgroundColor',[1 1 0]);
end
else
    bandera_tamano_vector = 0;
    set(handles.static_text_tamano_vector,'string',['Cantidad de Muestras: 0'],'BackgroundColor',[1 1 1]);
end

if t_muestreo_angulos_izq == t_muestreo_velocidades_izq && t_muestreo_angulos_izq == t_muestreo_angulos_der && t_muestreo_velocidades_izq == t_muestreo_velocidades_der % Pregunta si los tiempos de muestreo de angulos y velocidades para los servos son iguales
    t_muestreo = t_muestreo_angulos_izq;
if t_muestreo >= 40
    bandera_t_muestreo = 1;
    set(handles.static_text_tiempo_muestreo,'string',['Tiempo de Muestreo: ',num2str(t_muestreo),' ms' ],'BackgroundColor',[1 1 1]);
else
    bandera_t_muestreo = 0;
    set(handles.static_text_tiempo_muestreo,'string',['Tiempo de Muestreo: ',num2str(t_muestreo),' ms' ],'BackgroundColor',[1 1 0]);
end
else
    bandera_t_muestreo = 0;
    set(handles.static_text_tiempo_muestreo,'string',['Tiempo de Muestreo: 0'],'BackgroundColor',[1 1 1]);
end

if t_simulacion_angulos_izq == t_simulacion_velocidades_izq && t_simulacion_angulos_izq == t_simulacion_angulos_der && t_simulacion_velocidades_izq == t_simulacion_velocidades_der % Pregunta si los tiempos de simulacion de angulos y velocidades para los servos son iguales
    t_simulacion = t_simulacion_angulos_izq;
    bandera_t_simulacion = 1;
    set(handles.static_text_tiempo_simulacion,'string',['Tiempo de Simulacion: ',num2str(t_simulacion/1000),' s' ],'BackgroundColor',[1 1 1]); 
else
    bandera_t_simulacion = 0;
    set(handles.static_text_tiempo_simulacion,'string',['Tiempo de Simulacion: 0'],'BackgroundColor',[1 1 1]);
end

if bandera_tamano_vector == 1 && bandera_t_muestreo == 1 && bandera_t_simulacion == 1 % Pregunta si son iguales los tamaños de los ventores, los tiempos de muestreo y los tiempos de simulacion 
    bandera_servos_cargados = 1;
    [q,fs] = audioread('cargando servos.wav');               % Lee la frecuencia y las muestras del archivo de audio
    sound(q,fs); % Reproduce el audio
            
    fwrite(arduino,'a');                  % Prepara al Arduino para recibir el Tamaño del Vector
    fprintf(arduino,'%i',tamano_vector);  % Envia al arduino como valor entero el Tamaño del Vector
    
    fwrite(arduino,'b');                  % Prepara al Arduino para recibir el Tiempo de Muestreo
    fprintf(arduino,'%i',t_muestreo);     % Envia al arduino como valor entero el Tiempo de Muestreo
    
    fwrite(arduino,'c');                              % Prepara al Arduino para recibir el Vector de Angulos Derecho
    for i=1:tamano_vector                             % Ejecuta el ciclo con valores de i desde 1 hasta el tamaño del vector, variando de uno en uno
        fprintf(arduino,'%i',vector_angulos_der(i));  % Envia al arduino como valor entero cada dato del Vector de Angulos Derecho
        pause(0.001);
    end    
    
    fwrite(arduino,'d');                              % Prepara al Arduino para recibir el Vector de Angulos Izquierdo
    for i=1:tamano_vector                             % Ejecuta el ciclo con valores de i desde 1 hasta el tamaño del vector, variando de uno en uno
        fprintf(arduino,'%i',vector_angulos_izq(i));  % Envia al arduino como valor entero cada dato del Vector de Angulos Izquierdo
        pause(0.001);
    end

    fwrite(arduino,'e');                                  % Prepara al Arduino para recibir el Vector de Velocidades Derecha
    for i=1:tamano_vector                                 % Ejecuta el ciclo con valores de i desde 1 hasta el tamaño del vector, variando de uno en uno
        fprintf(arduino,'%i',vector_velocidades_der(i));  % Envia al arduino como valor entero cada dato del Vector de Velocidades Derecha
        pause(0.001);
    end
    
    fwrite(arduino,'f');                                  % Prepara al Arduino para recibir el Vector de Velocidades Izquierdo
    for i=1:tamano_vector                                 % Ejecuta el ciclo con valores de i desde 1 hasta el tamaño del vector, variando de uno en uno
        fprintf(arduino,'%i',vector_velocidades_izq(i));  % Envia al arduino como valor entero cada dato del Vector de Velocidades Izquierdo
        pause(0.001);
    end
    
    pause(0.5);                                              % Pausa para evitar solapamiento de audios
    set(handles.static_text_carga_servos,'string',['Carga de Servos Exitosa'],'BackgroundColor',[1 1 1]);
    set(handles.boton_angulos_servo_izq,'Visible','on');     % Visualiza el boton posiciones_servo_izq
    set(handles.boton_velocidades_servo_izq,'Visible','on'); % Visualiza el boton velocidades_servo_izq
    set(handles.boton_angulos_servo_der,'Visible','on');     % Visualiza el boton posiciones_servo_der
    set(handles.boton_velocidades_servo_der,'Visible','on'); % Visualiza el boton velocidades_servo_der
    set(handles.panel_cargar_servos,'Visible','on');         % Visualiza el panel cargar_servos
    set(handles.boton_ejecutar,'Visible','on');              % Visualiza el boton ejecutar_trayectoria
    set(handles.boton_detener,'Visible','on');               % Visualiza el boton detener_trayectoria
    set(handles.boton_calcular,'Visible','on');              % Visualiza el boton boton_calcular
    
[q,fs] = audioread('carga exitosa.wav');               % Lee la frecuencia y las muestras del archivo de audio
sound(q,fs); % Reproduce el audio

else % Else del If que pregunta si son iguales los tamaños de los vectores, los tiempos de muestreo y los tiempos de simulacion 
    
    set(handles.static_text_carga_servos,'string',['        Carga        Fallida'],'BackgroundColor',[1 0.5 0]);
    set(handles.boton_angulos_servo_izq,'Visible','on');     % Visualiza el boton posiciones_servo_izq
    set(handles.boton_velocidades_servo_izq,'Visible','on'); % Visualiza el boton velocidades_servo_izq
    set(handles.boton_angulos_servo_der,'Visible','on');     % Visualiza el boton posiciones_servo_der
    set(handles.boton_velocidades_servo_der,'Visible','on'); % Visualiza el boton velocidades_servo_der
    set(handles.panel_cargar_servos,'Visible','on');         % Visualiza el panel cargar_servos
    set(handles.boton_calcular,'Visible','on');              % Visualiza el boton boton_calcular
    [q,fs] = audioread('carga fallida.wav');              % Lee la frecuencia y las muestras del archivo de audio
    sound(q,fs); % Reproduce el audio
end


% BOTON EJECUTAR TRAYECTORIA
function boton_ejecutar_Callback(hObject, eventdata, handles)
global k arduino t_muestreo tamano_vector vector_tiempo_real ...
       vector_tiempo_angulos_izq vector_tiempo_velocidades_izq ...
       vector_tiempo_angulos_der vector_tiempo_velocidades_der ...
       vector_angulos_encoder_izq vector_velocidades_encoder_izq ...
       vector_angulos_encoder_der vector_velocidades_encoder_der ...
       button_state_boton_detener salto_para_imprimir incremento_salto_para_imprimir ...
       l1 l2 l3 l4 l5 xc_v yc_v xc_r yc_r vector_xc_v vector_yc_v vector_xc_r vector_yc_r...
       vector_angulos_encoder_izq_G vector_angulos_encoder_der_G... 
       vector_velocidades_encoder_izq_G vector_velocidades_encoder_der_G...
       bandera_trayectoria_ejecutada...
       vector_angulos_izq_GR vector_angulos_der_GR vector_velocidades_izq_GR vector_velocidades_der_GR

incremento_salto_para_imprimir = 14; %8   
   
k = 0;
vector_tiempo_real = 0;
button_state_boton_detener = 0;
vector_angulos_encoder_izq = 0;
vector_angulos_encoder_der = 0;
vector_velocidades_encoder_izq = 0;
vector_velocidades_encoder_der = 0;
salto_para_imprimir = k-1;

set(handles.boton_angulos_servo_izq,'Visible','off');     % Oculta el boton posiciones_servo_izq
set(handles.boton_velocidades_servo_izq,'Visible','off'); % Oculta el boton velocidades_servo_izq
set(handles.boton_angulos_servo_der,'Visible','off');     % Oculta el boton posiciones_servo_der
set(handles.boton_velocidades_servo_der,'Visible','off'); % Oculta el boton velocidades_servo_der
set(handles.boton_cargar_servos,'Visible','off');         % Oculta el boton_cargar_servos
set(handles.boton_ejecutar,'Visible','off');              % Oculta el boton_ejecutar
set(handles.boton_analizar,'Visible','off');              % Oculta el boton boton_analizar
set(handles.boton_calcular,'Visible','off');              % Oculta el boton boton_calcular

axes(handles.axes_posiciones_servo_izq); % Selecciona el Axes a trabajar 
cla();  % Limpia el axes seleccionado
scatter(vector_tiempo_angulos_izq,vector_angulos_izq_GR,'.','MarkerEdgeColor',[0 0.6 0]);

axes(handles.axes_velocidades_servo_izq); % Selecciona el Axes a trabajar
cla();  % Limpia el axes seleccionado
scatter(vector_tiempo_velocidades_izq,vector_velocidades_izq_GR,'.','MarkerEdgeColor',[0 0.6 0]);

axes(handles.axes_posiciones_servo_der); % Selecciona el Axes a trabajar 
cla();  % Limpia el axes seleccionado
scatter(vector_tiempo_angulos_der,vector_angulos_der_GR,'.','MarkerEdgeColor',[0 0.6 0]);

axes(handles.axes_velocidades_servo_der); % Selecciona el Axes a trabajar
cla();  % Limpia el axes seleccionado
scatter(vector_tiempo_velocidades_der,vector_velocidades_der_GR,'.','MarkerEdgeColor',[0 0.6 0]); % Grafica los datos con una funcion de Grafica de Dispercion

%CALCULO Y GRAFICACION DE CINEMATICA DIRECTA CON EL MODELO DE CLEMENCIA
q1=90;
q4=90;
xe=l5;
e=(l1*sind(q1)-l4*sind(q4))/(xe+l4*cosd(q4)-l1*cosd(q1));
f=[l1^2+l3^2-l2^2-l4^2-xe^2-[2*l4*xe*cosd(q4)]]/[2*l1*cosd(q1)-2*l4*cosd(q4)-2*xe];
d=e^2+1;
g=(2*e*f-2*e*l1*cosd(q1)-2*l1*sind(q1));
h=f^2-2*f*l1*cosd(q1)+l1^2-l2^2;
yc_r=[-g+sqrt(g^2-4*d*h)]/(2*d);
xc_r=e*yc_r+f;
%GRAFICACION TRAYECTORIA VIRTUAL
axes(handles.axes_trayectoria);
cla;
scatter(xc_v,yc_v,'.','MarkerEdgeColor',[0 0.6 0]); % Grafica los datos con una funcion de Grafica de Dispercion
%GRAFICACION DE LAS BARRAS
xb=l1*cosd(q1);
yb=l1*sind(q1);
xd=l5+l4*cosd(q4);
yd=l4*sind(q4);
Bx=linspace(0,xb);
By=linspace(0,yb);
Dx=linspace(l5,xd);
Dy=linspace(0,yd);
Cx1=linspace(xb,xc_r(k+1));
Cy1=linspace(yb,yc_r(k+1));
Cx2=linspace(xc_r(k+1),xd);
Cy2=linspace(yc_r(k+1),yd);
brazox=[Bx Cx1 Cx2 Dx ];
brazoy=[By Cy1 Cy2 Dy ];
plot(brazox,brazoy,'Color','blue','Linewidth',2)
%FIN DE LA GRAFICCION DE LA CINEMATICA

fwrite(arduino,'i'); % Le indica al Arduino llevar los servos al inicio de la trayectoria
[q,fs] = audioread('ejecutando trayectoria.wav'); % Lee la frecuencia y las muestras del archivo de audio
sound(q,fs); % Reproduce el audio
pause(2);

fwrite(arduino,'k'); % Le indica al arduino que lea los encoders y envíe las posiciones y velocidades del punto de inicio de la trayectoria
    Lectuta_Arduino = fscanf(arduino,'%i'); % Lee un dato de angulo enviado por el Arduino
    vector_angulos_encoder_der(k+1) = Lectuta_Arduino/11.375; % Almacena en un vector un angulo en grados enviado por el Arduino
    Lectuta_Arduino = fscanf(arduino,'%i'); % Lee un dato de angulo enviado por el Arduino
    vector_angulos_encoder_izq(k+1) = Lectuta_Arduino/11.375; % Almacena en un vector un angulo en grados enviado por el Arduino
    Lectuta_Arduino = fscanf(arduino,'%i'); % Lee un dato de velocidad enviado por el Arduino
    vector_velocidades_encoder_der(k+1) = Lectuta_Arduino/1.419; % Almacena en un vector un angulo en grados enviado por el Arduino
    Lectuta_Arduino = fscanf(arduino,'%i'); % Lee un dato de velocidad enviado por el Arduino
    vector_velocidades_encoder_izq(k+1) = Lectuta_Arduino/1.419; % Almacena en un vector un angulo en grados enviado por el Arduino
    vector_tiempo_real(k+1) = t_muestreo*k; % Se crea el vector de tiempo transcurrido para ser usado en los Graficos

axes(handles.axes_posiciones_servo_izq); % Selecciona el Axes a trabajar 
cla();  % Limpia el axes seleccionado
scatter(vector_tiempo_angulos_izq,vector_angulos_izq_GR,'.','MarkerEdgeColor',[0 0.6 0]); % Grafica los datos con una funcion de Grafica de Dispercion
scatter(vector_tiempo_real,vector_angulos_encoder_izq,'.','MarkerEdgeColor',[1 0 0]); % Grafica los datos con una funcion de Grafica de Dispercion

axes(handles.axes_velocidades_servo_izq); % Selecciona el Axes a trabajar
cla();  % Limpia el axes seleccionado
scatter(vector_tiempo_velocidades_izq,vector_velocidades_izq_GR,'.','MarkerEdgeColor',[0 0.6 0]); % Grafica los datos con una funcion de Grafica de Dispercion
scatter(vector_tiempo_real,vector_velocidades_encoder_izq,'.','MarkerEdgeColor',[1 0 0]); % Grafica los datos con una funcion de Grafica de Dispercion

axes(handles.axes_posiciones_servo_der); % Selecciona el Axes a trabajar 
cla();  % Limpia el axes seleccionado
scatter(vector_tiempo_angulos_der,vector_angulos_der_GR,'.','MarkerEdgeColor',[0 0.6 0]); % Grafica los datos con una funcion de Grafica de Dispercion
scatter(vector_tiempo_real,vector_angulos_encoder_der,'.','MarkerEdgeColor',[1 0 0]); % Grafica los datos con una funcion de Grafica de Dispercion

axes(handles.axes_velocidades_servo_der); % Selecciona el Axes a trabajar
cla();  % Limpia el axes seleccionado
scatter(vector_tiempo_velocidades_der,vector_velocidades_der_GR,'.','MarkerEdgeColor',[0 0.6 0]); % Grafica los datos con una funcion de Grafica de Dispercion
scatter(vector_tiempo_real,vector_velocidades_encoder_der,'.','MarkerEdgeColor',[1 0 0]); % Grafica los datos con una funcion de Grafica de Dispercion

%%% LE INDICA AL ARDUINO QUE INICIE LA RUTINA DE MOVIMIENTO DE LOS SERVOS
fwrite(arduino,'j'); 

while k < tamano_vector % Ciclo que garantiza la lectura en Matlab de todos los datos enviados por los Encoder de los Servos
   
if button_state_boton_detener == 0 % Entra si NO se ha oprimido el boton DETENER
    Lectuta_Arduino = fscanf(arduino,'%i'); % Lee un dato de angulo enviado por el Arduino
    vector_angulos_encoder_der(k+1) = Lectuta_Arduino/11.375; % Almacena en un vector un angulo en grados enviado por el Arduino
    Lectuta_Arduino = fscanf(arduino,'%i'); % Lee un dato de angulo enviado por el Arduino
    vector_angulos_encoder_izq(k+1) = Lectuta_Arduino/11.375; % Almacena en un vector un angulo en grados enviado por el Arduino
    Lectuta_Arduino = fscanf(arduino,'%i'); % Lee un dato de velocidad enviado por el Arduino
    vector_velocidades_encoder_der(k+1) = Lectuta_Arduino/1.419; % Almacena en un vector un angulo en grados enviado por el Arduino
    Lectuta_Arduino = fscanf(arduino,'%i'); % Lee un dato de velocidad enviado por el Arduino
    vector_velocidades_encoder_izq(k+1) = Lectuta_Arduino/1.419; % Almacena en un vector un angulo en grados enviado por el Arduino
    vector_tiempo_real(k+1) = t_muestreo*k; % Se crea el vector de tiempo transcurrido para ser usado en los Graficos
   
%CALCULO DE CINEMATICA DIRECTA CON EL MODELO DE CLEMENCIA
q1=(vector_angulos_encoder_izq(k+1))-90;
q4=(vector_angulos_encoder_der(k+1))-90;
xe=l5;
e=(l1*sind(q1)-l4*sind(q4))/(xe+l4*cosd(q4)-l1*cosd(q1));
f=[l1^2+l3^2-l2^2-l4^2-xe^2-[2*l4*xe*cosd(q4)]]/[2*l1*cosd(q1)-2*l4*cosd(q4)-2*xe];
d=e^2+1;
g=(2*e*f-2*e*l1*cosd(q1)-2*l1*sind(q1));
h=f^2-2*f*l1*cosd(q1)+l1^2-l2^2;
yc_r(k+1)=[-g+sqrt(g^2-4*d*h)]/(2*d);
xc_r(k+1)=e*yc_r(k+1)+f;
    
if k < salto_para_imprimir+incremento_salto_para_imprimir  
% NO IMPRIME NADA Y SALTA, CON EL FIN DE NO RELENTIZAR EL PROCESO DE IMPRIMIR EN LOS AXES     
else
    axes(handles.axes_posiciones_servo_der); % Selecciona el Axes a trabajar 
    cla();  % Limpia el axes seleccionado
    scatter(vector_tiempo_angulos_der,vector_angulos_der_GR,'.','MarkerEdgeColor',[0 0.6 0]); % Grafica los datos con una funcion de Grafica de Dispercion
    scatter(vector_tiempo_real,vector_angulos_encoder_der,'.','MarkerEdgeColor',[1 0 0]); % Grafica los datos con una funcion de Grafica de Dispercion
    
    axes(handles.axes_velocidades_servo_der); % Selecciona el Axes a trabajar
    cla();  % Limpia el axes seleccionado
    scatter(vector_tiempo_velocidades_der,vector_velocidades_der_GR,'.','MarkerEdgeColor',[0 0.6 0]); % Grafica los datos con una funcion de Grafica de Dispercion
    scatter(vector_tiempo_real,vector_velocidades_encoder_der,'.','MarkerEdgeColor',[1 0 0]); % Grafica los datos con una funcion de Grafica de Dispercion
    
    axes(handles.axes_posiciones_servo_izq); % Selecciona el Axes a trabajar
    cla();  % Limpia el axes seleccionado
    scatter(vector_tiempo_angulos_izq,vector_angulos_izq_GR,'.','MarkerEdgeColor',[0 0.6 0]); % Grafica los datos con una funcion de Grafica de Dispercion
    scatter(vector_tiempo_real,vector_angulos_encoder_izq,'.','MarkerEdgeColor',[1 0 0]); % Grafica los datos con una funcion de Grafica de Dispercion
    
    axes(handles.axes_velocidades_servo_izq); % Selecciona el Axes a trabajar
    cla();  % Limpia el axes seleccionado
    scatter(vector_tiempo_velocidades_izq,vector_velocidades_izq_GR,'.','MarkerEdgeColor',[0 0.6 0]); % Grafica los datos con una funcion de Grafica de Dispercion
    scatter(vector_tiempo_real,vector_velocidades_encoder_izq,'.','MarkerEdgeColor',[1 0 0]); % Grafica los datos con una funcion de Grafica de Dispercion
    
    %GRAFICACION TRAYECTORIA VIRTUAL
    axes(handles.axes_trayectoria);
    cla;
    scatter(xc_v,yc_v,'.','MarkerEdgeColor',[0 0.6 0]); % Grafica los datos con una funcion de Grafica de Dispercion
    
    %GRAFICACION TRAYECTORIA REAL
    scatter(xc_r,yc_r,'.','MarkerEdgeColor',[1 0 0]); % Grafica los datos con una funcion de Grafica de Dispercion
    %GRAFICACION DE LAS BARRAS
    xb=l1*cosd(q1);
    yb=l1*sind(q1);
    xd=l5+l4*cosd(q4);
    yd=l4*sind(q4);
    Bx=linspace(0,xb);
    By=linspace(0,yb);
    Dx=linspace(l5,xd);
    Dy=linspace(0,yd);
    Cx1=linspace(xb,xc_r(k+1));
    Cy1=linspace(yb,yc_r(k+1));
    Cx2=linspace(xc_r(k+1),xd);
    Cy2=linspace(yc_r(k+1),yd);
    brazox=[Bx Cx1 Cx2 Dx ];
    brazoy=[By Cy1 Cy2 Dy ];
    plot(brazox,brazoy,'Color','blue','Linewidth',2)
    %FIN DE LA GRAFICCION DE LA CINEMATICA
    
    salto_para_imprimir = k;
end
    k=k+1;
else % del if button_state_boton_detener == 0
    k = tamano_vector; 
end  % del if button_state_boton_detener == 0
    
pause(0.01) % pausa necesaria para poder leer el boton_detener 
end
%%% FIN DE LA RUTINA DE MOVIMIENTO DE LOS SERVOS

if button_state_boton_detener == 0
    set(handles.boton_detener,'Visible','off');               % Oculta el boton detener_trayectoria
    [q,fs] = audioread('proceso finalizado.wav');             % Lee la frecuencia y las muestras del archivo de audio
    sound(q,fs);                                              % Reproduce el audio
    
end
    set(handles.boton_detener,'Visible','off');               % Oculta el boton_detener
    pause(1.5)
    fwrite(arduino,'h'); % Le indica al arduino que lleve los Servos al Home

if button_state_boton_detener == 0
vector_xc_v = transpose(xc_v);
ruta=[pwd,'\Datos_Estadisticos.xls']; % ubica la carpeta del actual directorio de trabajo (current working directory)   
xlswrite(ruta,vector_xc_v,1,'B2');

vector_xc_r = transpose(xc_r);
ruta=[pwd,'\Datos_Estadisticos.xls']; % ubica la carpeta del actual directorio de trabajo (current working directory)
xlswrite(ruta,vector_xc_r,1,'C2');

vector_yc_v = transpose(yc_v);
ruta=[pwd,'\Datos_Estadisticos.xls']; % ubica la carpeta del actual directorio de trabajo (current working directory)
xlswrite(ruta,vector_yc_v,1,'D2');

vector_yc_r = transpose(yc_r);
ruta=[pwd,'\Datos_Estadisticos.xls']; % ubica la carpeta del actual directorio de trabajo (current working directory)
xlswrite(ruta,vector_yc_r,1,'E2');

vector_angulos_encoder_izq_G=transpose(vector_angulos_encoder_izq);   % Convierte un Vector Fila en un Vector Columna
ruta=[pwd,'\Datos_Estadisticos.xls']; % ubica la carpeta del actual directorio de trabajo (current working directory)
xlswrite(ruta,vector_angulos_encoder_izq_G,1,'G2'); 

vector_angulos_encoder_der_G=transpose(vector_angulos_encoder_der);   % Convierte un Vector Fila en un Vector Columna
ruta=[pwd,'\Datos_Estadisticos.xls']; % ubica la carpeta del actual directorio de trabajo (current working directory)
xlswrite(ruta,vector_angulos_encoder_der_G,1,'I2');

vector_velocidades_encoder_izq_G=transpose(vector_velocidades_encoder_izq);   % Convierte un Vector Fila en un Vector Columna
ruta=[pwd,'\Datos_Estadisticos.xls']; % ubica la carpeta del actual directorio de trabajo (current working directory)
xlswrite(ruta,vector_velocidades_encoder_izq_G,1,'K2');

vector_velocidades_encoder_der_G=transpose(vector_velocidades_encoder_der);   % Convierte un Vector Fila en un Vector Columna
ruta=[pwd,'\Datos_Estadisticos.xls']; % ubica la carpeta del actual directorio de trabajo (current working directory)
xlswrite(ruta,vector_velocidades_encoder_der_G,1,'M2');
end % del if button_state_boton_detener = 0;

set(handles.boton_angulos_servo_izq,'Visible','on');     % Visualiza el boton posiciones_servo_izq
set(handles.boton_velocidades_servo_izq,'Visible','on'); % Visualiza el boton velocidades_servo_izq
set(handles.boton_angulos_servo_der,'Visible','on');     % Visualiza el boton posiciones_servo_der
set(handles.boton_velocidades_servo_der,'Visible','on'); % Visualiza el boton velocidades_servo_der
set(handles.boton_cargar_servos,'Visible','on');         % Visualiza el boton_cargar_servos
set(handles.boton_ejecutar,'Visible','on');              % Visualiza el boton_ejecutar
set(handles.boton_analizar,'Visible','on');              % Visualiza el boton boton_analizar
set(handles.boton_detener,'Visible','on');               % Visualiza el boton_detener
set(handles.boton_calcular,'Visible','on');              % Visualiza el boton boton_calcular
bandera_trayectoria_ejecutada = 1;
k=0;


% BOTON ANALIZAR
function boton_analizar_Callback(hObject, eventdata, handles)
[q, fs]=audioread('abriendo analizador.wav'); % lee la frecuencia y las muestras del audio de abriendo generador
sound(q,fs); % reproduce el audio regresando abriendo generador
Estadistico %Abre la interfaz de analisis estadistico


% BOTON DETENER
function boton_detener_Callback(hObject, eventdata, handles)
global k arduino button_state_boton_detener 

fwrite(arduino,'s'); % Le indica al Arduino que detenga el ciclo de movimiento y lleve los Servos al inicio de la trayectoria
[q,fs] = audioread('proceso detenido.wav'); % Lee la frecuencia y las muestras del archivo de audio
sound(q,fs);                                % Reproduce el audio
set(handles.boton_detener,'Visible','off'); % Oculta el boton detener_trayectoria
button_state_boton_detener = 1;
pause(2)
if k==0
set(handles.boton_detener,'Visible','on');               % Visualiza el boton_detener
end
k=0;
