% ENCABEZADO AUTOMATICO AL CREAR EL GUIDE
function varargout = Estadistico(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Estadistico_OpeningFcn, ...
                   'gui_OutputFcn',  @Estadistico_OutputFcn, ...
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
function varargout = Estadistico_OutputFcn(hObject, eventdata, handles) 
frame_h1 = get(handle(gcf),'JavaFrame');         % Estas dos lineas maximizan la pantalla. Pero además en el GUIDE se debe cambiar la opcion: "Tool - GUI Options... - Proportional"
set(frame_h1,'Maximized',1);varargout{1} = handles.output;


% OpeningFcn DONDE SE DECLARAN LAS VARIBLES GLOBALES QUE SE USAN ENTRE DIFERENTES SECCIONES DE CODIGO DE BOTONES Y TEXTOS
function Estadistico_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
warning('off','all')                        % Para quitar todos los warning
clc 

global  tamano_vector alfa alfa_porcentaje...
        vector_angulos_izq_E vector_angulos_encoder_izq_E...
        vector_velocidades_izq_E vector_velocidades_encoder_izq_E...
        vector_angulos_der_E vector_angulos_encoder_der_E...
        vector_velocidades_der_E vector_velocidades_encoder_der_E...
        vector_xc_r_E vector_xc_v_E vector_yc_r_E vector_yc_v_E     

set(handles.slider_alfa_porcentaje,'Min',1,'Max',99,'Value',5,'SliderStep',[0.01 0.13]);
alfa_porcentaje = round(get(handles.slider_alfa_porcentaje,'Value'));
alfa = alfa_porcentaje/100;
guidata(hObject,handles);
set(handles.valor_alfa_slider,'String',alfa_porcentaje);

filename=[pwd,'\Datos_Estadisticos.xls']; % ubica la carpeta del actual directorio de trabajo (current working directory)
tamano_vector=xlsread(filename,'Hoja1','A2'); % Lee la hoja 1 del archivo excel

columna_archivo=strcat('B2:B',num2str(tamano_vector+1));
vector_xc_v_E =xlsread(filename,'Hoja1',columna_archivo);
columna_archivo=strcat('C2:C',num2str(tamano_vector+1));
vector_xc_r_E=xlsread(filename,'Hoja1',columna_archivo);

columna_archivo=strcat('D2:D',num2str(tamano_vector+1));
vector_yc_v_E=xlsread(filename,'Hoja1',columna_archivo);
columna_archivo=strcat('E2:E',num2str(tamano_vector+1));
vector_yc_r_E=xlsread(filename,'Hoja1',columna_archivo);

columna_archivo=strcat('F2:F',num2str(tamano_vector+1)); % Genera una secuencia de caracteres como esta 'A1:A361' que correspondería al final del archivo para leer
vector_angulos_izq_E=xlsread(filename,'Hoja1',columna_archivo); % Lee la hoja 1 y la columna indicada del archivo excel
columna_archivo=strcat('G2:G',num2str(tamano_vector+1));
vector_angulos_encoder_izq_E=xlsread(filename,'Hoja1',columna_archivo); 

columna_archivo=strcat('H2:H',num2str(tamano_vector+1));
vector_angulos_der_E=xlsread(filename,'Hoja1',columna_archivo); 
columna_archivo=strcat('I2:I',num2str(tamano_vector+1));
vector_angulos_encoder_der_E=xlsread(filename,'Hoja1',columna_archivo); 

columna_archivo=strcat('J2:J',num2str(tamano_vector+1));
vector_velocidades_izq_E=xlsread(filename,'Hoja1',columna_archivo); 
columna_archivo=strcat('K2:K',num2str(tamano_vector+1));
vector_velocidades_encoder_izq_E=xlsread(filename,'Hoja1',columna_archivo); 

columna_archivo=strcat('L2:L',num2str(tamano_vector+1));
vector_velocidades_der_E=xlsread(filename,'Hoja1',columna_archivo); 
columna_archivo=strcat('M2:M',num2str(tamano_vector+1));
vector_velocidades_encoder_der_E=xlsread(filename,'Hoja1',columna_archivo); 

axes(handles.axes_cajas_y_bigotes); % Selecciona el axes a trabajar
cla(handles.axes_cajas_y_bigotes); % Limpia el axes
title('Gráfico Caja y Bigotes')

axes(handles.axes_histograma); % Selecciona el axes a trabajar
cla(handles.axes_histograma); % Limpia el axes
title('Histograma de Frecuencias')

axes(handles.axes_cuantil_cuantil); % Selecciona el axes a trabajar
cla(handles.axes_cuantil_cuantil); % Limpia el axes
title('Gráfico Cuantil-Cuantil')


% --- Executes on button press in boton_coordenadas_xc.
function boton_coordenadas_xc_Callback(hObject, eventdata, handles)
global vector_xc_r_E vector_xc_v_E alfa 

axes(handles.axes_cajas_y_bigotes); % Selecciona el axes a trabajar
cla(handles.axes_cajas_y_bigotes); % Limpia el axes
boxplot([vector_xc_r_E, vector_xc_v_E],'Orientation','horizontal','Labels',{'Calculada','Simulada'},'Widths',0.8); % Grafica el Diagrama de Cajas y Bigotes
title('Gráfico Caja y Bigotes - Coordenadas XP')
xlabel('Milimetros','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
ylabel('Trayectorias','FontWeight','bold','FontSize',9,'Color',[0 0 0]);

axes(handles.axes_histograma); % Selecciona el axes a trabajar
cla(handles.axes_histograma); % Limpia el axes
histogram(vector_xc_v_E,'EdgeAlpha',0.5,'EdgeColor','white','FaceAlpha',1,'BinMethod','scott') % Grafica el Histograma de Frecuencias
hold on
histogram(vector_xc_r_E,'EdgeAlpha',0.5,'EdgeColor','white','FaceAlpha',0.6,'FaceColor','green','BinMethod','scott') % Grafica el Histograma de Frecuencias
hold on
title('Histograma de Frecuencias - Coordenadas XP')
xlabel('Milimetros','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
ylabel('Frecuencia','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
legend('Trayectoria Simulada','Trayectoria Calculada','Location','best')

axes(handles.axes_cuantil_cuantil); % Selecciona el axes a trabajar
cla(handles.axes_cuantil_cuantil); % Limpia el axes
qqplot(vector_xc_v_E,vector_xc_r_E); % Grafica el Diagrama Cuantil-Cuantil
title('Gráfico Cuantil-Cuantil - Coordenadas XP')
xlabel('Trayectoria  Simulada [mm]','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
ylabel('Trayectoria  Calculada [mm]','FontWeight','bold','FontSize',9,'Color',[0 0 0]);

[h_f,valor_PF,intervalo_confianza_var] = vartest2(vector_xc_v_E,vector_xc_r_E,'Alpha',alfa);
if valor_PF > alfa
    set(handles.static_text_prueba_F_1,'FontSize',12,'string',['Hipótesis Nula: Sigma_Simulada / Sigma_Calculada = 1',char(10),'Hipótesis Alternativa: Sigma_Simulada / Sigma_Calculada <> 1',char(10),'valor-P = ',num2str(valor_PF),char(10),'No hay diferencia estadisticamente significativa entre las desviaciones de las dos muestras.',char(10),'No se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
else
    set(handles.static_text_prueba_F_1,'FontSize',12,'string',['Hipótesis Nula: Sigma_Simulada / Sigma_Calculada = 1',char(10),'Hipótesis Alternativa: Sigma_Simulada / Sigma_Calculada <> 1',char(10),'valor-P = ',num2str(valor_PF),char(10),'Existe una diferencia estadisticamente significativa entre las desviaciones de las dos muestras.',char(10),'Se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
end

if h_f == 0
    [h_t,valor_Pt,intervalo_confianza_med] = ttest2(vector_xc_v_E,vector_xc_r_E,'Vartype','equal','Alpha',alfa);
else
    [h_t,valor_Pt,intervalo_confianza_med] = ttest2(vector_xc_v_E,vector_xc_r_E,'Vartype','unequal','Alpha',alfa);
end

if h_t == 0
    set(handles.static_text_prueba_t_1,'FontSize',12,'string',['Hipótesis Nula: Media_Simulada - Media_Calculada = 0',char(10),'Hipótesis Alternativa: Media_Simulada - Media_Calculada <> 0',char(10),'valor-P = ',num2str(valor_Pt),char(10),'No hay diferencia estadisticamente significativa entre las medias de las dos muestras.',char(10),'No se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
else
    set(handles.static_text_prueba_t_1,'FontSize',12,'string',['Hipótesis Nula: Media_Simulada - Media_Calculada = 0',char(10),'Hipótesis Alternativa: Media_Simulada - Media_Calculada <> 0',char(10),'valor-P = ',num2str(valor_Pt),char(10),'Existe una diferencia estadisticamente significativa entre las medias de las dos muestras.',char(10),'Se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
end

recuento_v = size(vector_xc_v_E,1);
recuento_r = size(vector_xc_r_E,1);
valor_minimo_v = min(vector_xc_v_E);
valor_minimo_r = min(vector_xc_r_E);
valor_maximo_v = max(vector_xc_v_E);
valor_maximo_r = max(vector_xc_r_E);
mediana_v = median(vector_xc_v_E);
mediana_r = median(vector_xc_r_E);
cuartiles_v = quantile(vector_xc_v_E,[0.25, 0.5, 0.75]);
cuartiles_r = quantile(vector_xc_r_E,[0.25, 0.5, 0.75]);
cuartil_inferior_v = cuartiles_v(1);
cuartil_inferior_r = cuartiles_r(1);
cuartil_superior_v = cuartiles_v(3);
cuartil_superior_r = cuartiles_r(3);
media_v = mean(vector_xc_v_E);
media_r = mean(vector_xc_r_E);
varianza_v = var(vector_xc_v_E);
varianza_r = var(vector_xc_r_E);
diferencia_de_medias = media_v-media_r;
error_de_estimacion_medias = diferencia_de_medias-intervalo_confianza_med(1);

datos =[recuento_v, recuento_r; 
        valor_minimo_v, valor_minimo_r; 
        valor_maximo_v, valor_maximo_r; 
        mediana_v, mediana_r; 
        cuartil_inferior_v, cuartil_inferior_r; 
        cuartil_superior_v, cuartil_superior_r; 
        varianza_v, varianza_r
        media_v, media_r];

set(handles.resumen_estadistico,'data',datos);
set(handles.static_text_int_conf_var,'FontSize',14,'string',['[',num2str(intervalo_confianza_var(1)),' ; ',num2str(intervalo_confianza_var(2)),']']); 
set(handles.static_text_int_conf_med,'FontSize',14,'string',['[',num2str(intervalo_confianza_med(1)),' ; ',num2str(intervalo_confianza_med(2)),']']); 
set(handles.static_tex_ecu_int_confianza_media,'FontSize',14,'string',[num2str(diferencia_de_medias),' +/- ',num2str(error_de_estimacion_medias)]); 


% --- Executes on button press in boton_coordenadas_yc.
function boton_coordenadas_yc_Callback(hObject, eventdata, handles)
global vector_yc_r_E vector_yc_v_E alfa 

axes(handles.axes_cajas_y_bigotes); % Selecciona el axes a trabajar
cla(handles.axes_cajas_y_bigotes); % Limpia el axes
boxplot([vector_yc_r_E, vector_yc_v_E],'Orientation','horizontal','Labels',{'Calculada','Simulada'},'Widths',0.8); % Grafica el Diagrama de Cajas y Bigotes
title('Gráfico Caja y Bigotes - Coordenadas YP')
xlabel('Milimetros','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
ylabel('Trayectorias','FontWeight','bold','FontSize',9,'Color',[0 0 0]);

axes(handles.axes_histograma); % Selecciona el axes a trabajar
cla(handles.axes_histograma); % Limpia el axes
histogram(vector_yc_v_E,'EdgeAlpha',0.5,'EdgeColor','white','FaceAlpha',1,'BinMethod','scott') % Grafica el Histograma de Frecuencias
hold on
histogram(vector_yc_r_E,'EdgeAlpha',0.5,'EdgeColor','white','FaceAlpha',0.6,'FaceColor','green','BinMethod','scott') % Grafica el Histograma de Frecuencias
hold on
title('Histograma de Frecuencias - Coordenadas YP')
xlabel('Milimetros','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
ylabel('Frecuencia','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
legend('Trayectoria Simulada','Trayectoria Calculada','Location','best')

axes(handles.axes_cuantil_cuantil); % Selecciona el axes a trabajar
cla(handles.axes_cuantil_cuantil); % Limpia el axes
qqplot(vector_yc_v_E,vector_yc_r_E); % Grafica el Diagrama Cuantil-Cuantil
title('Gráfico Cuantil-Cuantil - Coordenadas YP')
xlabel('Trayectoria  Simulada [mm]','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
ylabel('Trayectoria  Calculada [mm]','FontWeight','bold','FontSize',9,'Color',[0 0 0]);

[h_f,valor_PF,intervalo_confianza_var] = vartest2(vector_yc_v_E,vector_yc_r_E,'Alpha',alfa);
if valor_PF > alfa
    set(handles.static_text_prueba_F_1,'FontSize',12,'string',['Hipótesis Nula: Sigma_Simulada / Sigma_Calculada = 1',char(10),'Hipótesis Alternativa: Sigma_Simulada / Sigma_Calculada <> 1',char(10),'valor-P = ',num2str(valor_PF),char(10),'No hay diferencia estadisticamente significativa entre las desviaciones de las dos muestras.',char(10),'No se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
else
    set(handles.static_text_prueba_F_1,'FontSize',12,'string',['Hipótesis Nula: Sigma_Simulada / Sigma_Calculada = 1',char(10),'Hipótesis Alternativa: Sigma_Simulada / Sigma_Calculada <> 1',char(10),'valor-P = ',num2str(valor_PF),char(10),'Existe una diferencia estadisticamente significativa entre las desviaciones de las dos muestras.',char(10),'Se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
end

if h_f == 0
    [h_t,valor_Pt,intervalo_confianza_med] = ttest2(vector_yc_v_E,vector_yc_r_E,'Vartype','equal','Alpha',alfa);
else
    [h_t,valor_Pt,intervalo_confianza_med] = ttest2(vector_yc_v_E,vector_yc_r_E,'Vartype','unequal','Alpha',alfa);
end

if h_t == 0
    set(handles.static_text_prueba_t_1,'FontSize',12,'string',['Hipótesis Nula: Media_Simulada - Media_Calculada = 0',char(10),'Hipótesis Alternativa: Media_Simulada - Media_Calculada <> 0',char(10),'valor-P = ',num2str(valor_Pt),char(10),'No hay diferencia estadisticamente significativa entre las medias de las dos muestras.',char(10),'No se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
else
    set(handles.static_text_prueba_t_1,'FontSize',12,'string',['Hipótesis Nula: Media_Simulada - Media_Calculada = 0',char(10),'Hipótesis Alternativa: Media_Simulada - Media_Calculada <> 0',char(10),'valor-P = ',num2str(valor_Pt),char(10),'Existe una diferencia estadisticamente significativa entre las medias de las dos muestras.',char(10),'Se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
end

recuento_v = size(vector_yc_v_E,1);
recuento_r = size(vector_yc_r_E,1);
valor_minimo_v = min(vector_yc_v_E);
valor_minimo_r = min(vector_yc_r_E);
valor_maximo_v = max(vector_yc_v_E);
valor_maximo_r = max(vector_yc_r_E);
mediana_v = median(vector_yc_v_E);
mediana_r = median(vector_yc_r_E);
cuartiles_v = quantile(vector_yc_v_E,[0.25, 0.5, 0.75]);
cuartiles_r = quantile(vector_yc_r_E,[0.25, 0.5, 0.75]);
cuartil_inferior_v = cuartiles_v(1);
cuartil_inferior_r = cuartiles_r(1);
cuartil_superior_v = cuartiles_v(3);
cuartil_superior_r = cuartiles_r(3);
media_v = mean(vector_yc_v_E);
media_r = mean(vector_yc_r_E);
varianza_v = var(vector_yc_v_E);
varianza_r = var(vector_yc_r_E);
diferencia_de_medias = media_v-media_r;
error_de_estimacion_medias = diferencia_de_medias-intervalo_confianza_med(1);

datos =[recuento_v, recuento_r; 
        valor_minimo_v, valor_minimo_r; 
        valor_maximo_v, valor_maximo_r; 
        mediana_v, mediana_r; 
        cuartil_inferior_v, cuartil_inferior_r; 
        cuartil_superior_v, cuartil_superior_r; 
        varianza_v, varianza_r
        media_v, media_r];

set(handles.resumen_estadistico,'data',datos);
set(handles.static_text_int_conf_var,'FontSize',14,'string',['[',num2str(intervalo_confianza_var(1)),' ; ',num2str(intervalo_confianza_var(2)),']']); 
set(handles.static_text_int_conf_med,'FontSize',14,'string',['[',num2str(intervalo_confianza_med(1)),' ; ',num2str(intervalo_confianza_med(2)),']']); 
set(handles.static_tex_ecu_int_confianza_media,'FontSize',14,'string',[num2str(diferencia_de_medias),' +/- ',num2str(error_de_estimacion_medias)]); 


% --- Executes on button press in boton_angulos_servo_izq.
function boton_angulos_servo_izq_Callback(hObject, eventdata, handles)
global vector_angulos_encoder_izq_E vector_angulos_izq_E alfa 

axes(handles.axes_cajas_y_bigotes); % Selecciona el axes a trabajar
cla(handles.axes_cajas_y_bigotes); % Limpia el axes
boxplot([vector_angulos_encoder_izq_E,vector_angulos_izq_E],'Orientation','horizontal','Labels',{'Calculada','Simulada'},'Widths',0.8); % Grafica el Diagrama de Cajas y Bigotes
title('Gráfico Caja y Bigotes - Posiciones Servo Izquierdo')
xlabel('Grados','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
ylabel('Trayectorias','FontWeight','bold','FontSize',9,'Color',[0 0 0]);

axes(handles.axes_histograma); % Selecciona el axes a trabajar
cla(handles.axes_histograma); % Limpia el axes
histogram(vector_angulos_izq_E,'EdgeAlpha',0.5,'EdgeColor','white','FaceAlpha',1,'BinMethod','scott') % Grafica el Histograma de Frecuencias
hold on
histogram(vector_angulos_encoder_izq_E,'EdgeAlpha',0.5,'EdgeColor','white','FaceAlpha',0.6,'FaceColor','green','BinMethod','scott') % Grafica el Histograma de Frecuencias
hold on
title('Histograma de Frecuencias - Posiciones Servo Izquierdo')
xlabel('Grados','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
ylabel('Frecuencia','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
legend('Trayectoria Simulada','Trayectoria Calculada','Location','northeast')

axes(handles.axes_cuantil_cuantil); % Selecciona el axes a trabajar
cla(handles.axes_cuantil_cuantil); % Limpia el axes
qqplot(vector_angulos_izq_E,vector_angulos_encoder_izq_E); % Grafica el Diagrama Cuantil-Cuantil
title('Gráfico Cuantil-Cuantil - Posiciones Servo Izquierdo')
xlabel('Trayectoria  Simulada [grados]','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
ylabel('Trayectoria  Calculada [grados]','FontWeight','bold','FontSize',9,'Color',[0 0 0]);

[h_f,valor_PF,intervalo_confianza_var] = vartest2(vector_angulos_izq_E,vector_angulos_encoder_izq_E,'Alpha',alfa);
if valor_PF > alfa
    set(handles.static_text_prueba_F_1,'FontSize',12,'string',['Hipótesis Nula: Sigma_Simulada / Sigma_Calculada = 1',char(10),'Hipótesis Alternativa: Sigma_Simulada / Sigma_Calculada <> 1',char(10),'valor-P = ',num2str(valor_PF),char(10),'No hay diferencia estadisticamente significativa entre las desviaciones de las dos muestras.',char(10),'No se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
else
    set(handles.static_text_prueba_F_1,'FontSize',12,'string',['Hipótesis Nula: Sigma_Simulada / Sigma_Calculada = 1',char(10),'Hipótesis Alternativa: Sigma_Simulada / Sigma_Calculada <> 1',char(10),'valor-P = ',num2str(valor_PF),char(10),'Existe una diferencia estadisticamente significativa entre las desviaciones de las dos muestras.',char(10),'Se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
end

if h_f == 0
    [h_t,valor_Pt,intervalo_confianza_med] = ttest2(vector_angulos_izq_E,vector_angulos_encoder_izq_E,'Vartype','equal','Alpha',alfa);
else
    [h_t,valor_Pt,intervalo_confianza_med] = ttest2(vector_angulos_izq_E,vector_angulos_encoder_izq_E,'Vartype','unequal','Alpha',alfa);
end

if h_t == 0
    set(handles.static_text_prueba_t_1,'FontSize',12,'string',['Hipótesis Nula: Media_Simulada - Media_Calculada = 0',char(10),'Hipótesis Alternativa: Media_Simulada - Media_Calculada <> 0',char(10),'valor-P = ',num2str(valor_Pt),char(10),'No hay diferencia estadisticamente significativa entre las medias de las dos muestras.',char(10),'No se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
else
    set(handles.static_text_prueba_t_1,'FontSize',12,'string',['Hipótesis Nula: Media_Simulada - Media_Calculada = 0',char(10),'Hipótesis Alternativa: Media_Simulada - Media_Calculada <> 0',char(10),'valor-P = ',num2str(valor_Pt),char(10),'Existe una diferencia estadisticamente significativa entre las medias de las dos muestras.',char(10),'Se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
end

recuento_v = size(vector_angulos_izq_E,1);
recuento_r = size(vector_angulos_encoder_izq_E,1);
valor_minimo_v = min(vector_angulos_izq_E);
valor_minimo_r = min(vector_angulos_encoder_izq_E);
valor_maximo_v = max(vector_angulos_izq_E);
valor_maximo_r = max(vector_angulos_encoder_izq_E);
mediana_v = median(vector_angulos_izq_E);
mediana_r = median(vector_angulos_encoder_izq_E);
cuartiles_v = quantile(vector_angulos_izq_E,[0.25, 0.5, 0.75]);
cuartiles_r = quantile(vector_angulos_encoder_izq_E,[0.25, 0.5, 0.75]);
cuartil_inferior_v = cuartiles_v(1);
cuartil_inferior_r = cuartiles_r(1);
cuartil_superior_v = cuartiles_v(3);
cuartil_superior_r = cuartiles_r(3);
media_v = mean(vector_angulos_izq_E);
media_r = mean(vector_angulos_encoder_izq_E);
varianza_v = var(vector_angulos_izq_E);
varianza_r = var(vector_angulos_encoder_izq_E);
diferencia_de_medias = media_v-media_r;
error_de_estimacion_medias = diferencia_de_medias-intervalo_confianza_med(1);

datos =[recuento_v, recuento_r; 
        valor_minimo_v, valor_minimo_r; 
        valor_maximo_v, valor_maximo_r; 
        mediana_v, mediana_r; 
        cuartil_inferior_v, cuartil_inferior_r; 
        cuartil_superior_v, cuartil_superior_r; 
        varianza_v, varianza_r
        media_v, media_r];

set(handles.resumen_estadistico,'data',datos);
set(handles.static_text_int_conf_var,'FontSize',14,'string',['[',num2str(intervalo_confianza_var(1)),' ; ',num2str(intervalo_confianza_var(2)),']']); 
set(handles.static_text_int_conf_med,'FontSize',14,'string',['[',num2str(intervalo_confianza_med(1)),' ; ',num2str(intervalo_confianza_med(2)),']']); 
set(handles.static_tex_ecu_int_confianza_media,'FontSize',14,'string',[num2str(diferencia_de_medias),' +/- ',num2str(error_de_estimacion_medias)]); 

 
% --- Executes on button press in boton_angulos_servo_der.
function boton_angulos_servo_der_Callback(hObject, eventdata, handles)
global vector_angulos_encoder_der_E vector_angulos_der_E alfa 

axes(handles.axes_cajas_y_bigotes); % Selecciona el axes a trabajar
cla(handles.axes_cajas_y_bigotes); % Limpia el axes
boxplot([vector_angulos_encoder_der_E,vector_angulos_der_E],'Orientation','horizontal','Labels',{'Calculada','Simulada'},'Widths',0.8); % Grafica el Diagrama de Cajas y Bigotes
title('Gráfico Caja y Bigotes - Posiciones Servo Derecho')
xlabel('Grados','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
ylabel('Trayectorias','FontWeight','bold','FontSize',9,'Color',[0 0 0]);

axes(handles.axes_histograma); % Selecciona el axes a trabajar
cla(handles.axes_histograma); % Limpia el axes
histogram(vector_angulos_der_E,'EdgeAlpha',0.5,'EdgeColor','white','FaceAlpha',1,'BinMethod','scott') % Grafica el Histograma de Frecuencias
hold on
histogram(vector_angulos_encoder_der_E,'EdgeAlpha',0.5,'EdgeColor','white','FaceAlpha',0.6,'FaceColor','green','BinMethod','scott') % Grafica el Histograma de Frecuencias
hold on
title('Histograma de Frecuencias - Posiciones Servo Derecho')
xlabel('Grados','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
ylabel('Frecuencia','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
legend('Trayectoria Simulada','Trayectoria Calculada','Location','northwest')

axes(handles.axes_cuantil_cuantil); % Selecciona el axes a trabajar
cla(handles.axes_cuantil_cuantil); % Limpia el axes
qqplot(vector_angulos_der_E,vector_angulos_encoder_der_E); % Grafica el Diagrama Cuantil-Cuantil
title('Gráfico Cuantil-Cuantil - Posiciones Servo Derecho')
xlabel('Trayectoria  Simulada [grados]','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
ylabel('Trayectoria  Calculada [grados]','FontWeight','bold','FontSize',9,'Color',[0 0 0]);

[h_f,valor_PF,intervalo_confianza_var] = vartest2(vector_angulos_der_E,vector_angulos_encoder_der_E,'Alpha',alfa);
if valor_PF > alfa
    set(handles.static_text_prueba_F_1,'FontSize',12,'string',['Hipótesis Nula: Sigma_Simulada / Sigma_Calculada = 1',char(10),'Hipótesis Alternativa: Sigma_Simulada / Sigma_Calculada <> 1',char(10),'valor-P = ',num2str(valor_PF),char(10),'No hay diferencia estadisticamente significativa entre las desviaciones de las dos muestras.',char(10),'No se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
else
    set(handles.static_text_prueba_F_1,'FontSize',12,'string',['Hipótesis Nula: Sigma_Simulada / Sigma_Calculada = 1',char(10),'Hipótesis Alternativa: Sigma_Simulada / Sigma_Calculada <> 1',char(10),'valor-P = ',num2str(valor_PF),char(10),'Existe una diferencia estadisticamente significativa entre las desviaciones de las dos muestras.',char(10),'Se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
end

if h_f == 0
    [h_t,valor_Pt,intervalo_confianza_med] = ttest2(vector_angulos_der_E,vector_angulos_encoder_der_E,'Vartype','equal','Alpha',alfa);
else
    [h_t,valor_Pt,intervalo_confianza_med] = ttest2(vector_angulos_der_E,vector_angulos_encoder_der_E,'Vartype','unequal','Alpha',alfa);   
end

if h_t == 0
    set(handles.static_text_prueba_t_1,'FontSize',12,'string',['Hipótesis Nula: Media_Simulada - Media_Calculada = 0',char(10),'Hipótesis Alternativa: Media_Simulada - Media_Calculada <> 0',char(10),'valor-P = ',num2str(valor_Pt),char(10),'No hay diferencia estadisticamente significativa entre las medias de las dos muestras.',char(10),'No se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
else
    set(handles.static_text_prueba_t_1,'FontSize',12,'string',['Hipótesis Nula: Media_Simulada - Media_Calculada = 0',char(10),'Hipótesis Alternativa: Media_Simulada - Media_Calculada <> 0',char(10),'valor-P = ',num2str(valor_Pt),char(10),'Existe una diferencia estadisticamente significativa entre las medias de las dos muestras.',char(10),'Se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
end

recuento_v = size(vector_angulos_der_E,1);
recuento_r = size(vector_angulos_encoder_der_E,1);
valor_minimo_v = min(vector_angulos_der_E);
valor_minimo_r = min(vector_angulos_encoder_der_E);
valor_maximo_v = max(vector_angulos_der_E);
valor_maximo_r = max(vector_angulos_encoder_der_E);
mediana_v = median(vector_angulos_der_E);
mediana_r = median(vector_angulos_encoder_der_E);
cuartiles_v = quantile(vector_angulos_der_E,[0.25, 0.5, 0.75]);
cuartiles_r = quantile(vector_angulos_encoder_der_E,[0.25, 0.5, 0.75]);
cuartil_inferior_v = cuartiles_v(1);
cuartil_inferior_r = cuartiles_r(1);
cuartil_superior_v = cuartiles_v(3);
cuartil_superior_r = cuartiles_r(3);
media_v = mean(vector_angulos_der_E);
media_r = mean(vector_angulos_encoder_der_E);
varianza_v = var(vector_angulos_der_E);
varianza_r = var(vector_angulos_encoder_der_E);
diferencia_de_medias = media_v-media_r;
error_de_estimacion_medias = diferencia_de_medias-intervalo_confianza_med(1);

datos =[recuento_v, recuento_r; 
        valor_minimo_v, valor_minimo_r; 
        valor_maximo_v, valor_maximo_r; 
        mediana_v, mediana_r; 
        cuartil_inferior_v, cuartil_inferior_r; 
        cuartil_superior_v, cuartil_superior_r; 
        varianza_v, varianza_r
        media_v, media_r];

set(handles.resumen_estadistico,'data',datos);
set(handles.static_text_int_conf_var,'FontSize',14,'string',['[',num2str(intervalo_confianza_var(1)),' ; ',num2str(intervalo_confianza_var(2)),']']); 
set(handles.static_text_int_conf_med,'FontSize',14,'string',['[',num2str(intervalo_confianza_med(1)),' ; ',num2str(intervalo_confianza_med(2)),']']); 
set(handles.static_tex_ecu_int_confianza_media,'FontSize',14,'string',[num2str(diferencia_de_medias),' +/- ',num2str(error_de_estimacion_medias)]); 


% --- Executes on button press in boton_velocidades_servo_der.
function boton_velocidades_servo_izq_Callback(hObject, eventdata, handles)
global vector_velocidades_encoder_izq_E vector_velocidades_izq_E alfa 

axes(handles.axes_cajas_y_bigotes); % Selecciona el axes a trabajar
cla(handles.axes_cajas_y_bigotes); % Limpia el axes
boxplot([vector_velocidades_encoder_izq_E,vector_velocidades_izq_E],'Orientation','horizontal','Labels',{'Calculada','Simulada'},'Widths',0.8); % Grafica el Diagrama de Cajas y Bigotes
title('Gráfico Caja y Bigotes - Velocidades Servo Izquierdo')
xlabel('Grados / Segundo','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
ylabel('Trayectorias','FontWeight','bold','FontSize',9,'Color',[0 0 0]);

axes(handles.axes_histograma); % Selecciona el axes a trabajar
cla(handles.axes_histograma); % Limpia el axes
histogram(vector_velocidades_izq_E,'EdgeAlpha',0.5,'EdgeColor','white','FaceAlpha',1,'BinMethod','scott') % Grafica el Histograma de Frecuencias
hold on
histogram(vector_velocidades_encoder_izq_E,'EdgeAlpha',0.5,'EdgeColor','white','FaceAlpha',0.6,'FaceColor','green','BinMethod','scott') % Grafica el Histograma de Frecuencias
hold on
title('Histograma de Frecuencias - Velocidades Servo Izquierdo')
xlabel('Grados / Segundo','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
ylabel('Frecuencia','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
legend('Trayectoria Simulada','Trayectoria Calculada','Location','northeast')

axes(handles.axes_cuantil_cuantil); % Selecciona el axes a trabajar
cla(handles.axes_cuantil_cuantil); % Limpia el axes
qqplot(vector_velocidades_izq_E,vector_velocidades_encoder_izq_E); % Grafica el Diagrama Cuantil-Cuantil
title('Gráfico Cuantil-Cuantil - Velocidades Servo Izquierdo')
xlabel('Trayectoria  Simulada [grados / segundo]','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
ylabel('Trayectoria  Calculada [grados / segundo]','FontWeight','bold','FontSize',9,'Color',[0 0 0]);

[h_f,valor_PF,intervalo_confianza_var] = vartest2(vector_velocidades_izq_E,vector_velocidades_encoder_izq_E,'Alpha',alfa);
if valor_PF > alfa
    set(handles.static_text_prueba_F_1,'FontSize',12,'string',['Hipótesis Nula: Sigma_Simulada / Sigma_Calculada = 1',char(10),'Hipótesis Alternativa: Sigma_Simulada / Sigma_Calculada <> 1',char(10),'valor-P = ',num2str(valor_PF),char(10),'No hay diferencia estadisticamente significativa entre las desviaciones de las dos muestras.',char(10),'No se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
else
    set(handles.static_text_prueba_F_1,'FontSize',12,'string',['Hipótesis Nula: Sigma_Simulada / Sigma_Calculada = 1',char(10),'Hipótesis Alternativa: Sigma_Simulada / Sigma_Calculada <> 1',char(10),'valor-P = ',num2str(valor_PF),char(10),'Existe una diferencia estadisticamente significativa entre las desviaciones de las dos muestras.',char(10),'Se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
end

if h_f == 0
    [h_t,valor_Pt,intervalo_confianza_med] = ttest2(vector_velocidades_izq_E,vector_velocidades_encoder_izq_E,'Vartype','equal','Alpha',alfa);
else
    [h_t,valor_Pt,intervalo_confianza_med] = ttest2(vector_velocidades_izq_E,vector_velocidades_encoder_izq_E,'Vartype','unequal','Alpha',alfa);
end

if h_t == 0
    set(handles.static_text_prueba_t_1,'FontSize',12,'string',['Hipótesis Nula: Media_Simulada - Media_Calculada = 0',char(10),'Hipótesis Alternativa: Media_Simulada - Media_Calculada <> 0',char(10),'valor-P = ',num2str(valor_Pt),char(10),'No hay diferencia estadisticamente significativa entre las medias de las dos muestras.',char(10),'No se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
else
    set(handles.static_text_prueba_t_1,'FontSize',12,'string',['Hipótesis Nula: Media_Simulada - Media_Calculada = 0',char(10),'Hipótesis Alternativa: Media_Simulada - Media_Calculada <> 0',char(10),'valor-P = ',num2str(valor_Pt),char(10),'Existe una diferencia estadisticamente significativa entre las medias de las dos muestras.',char(10),'Se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
end

recuento_v = size(vector_velocidades_izq_E,1);
recuento_r = size(vector_velocidades_encoder_izq_E,1);
valor_minimo_v = min(vector_velocidades_izq_E);
valor_minimo_r = min(vector_velocidades_encoder_izq_E);
valor_maximo_v = max(vector_velocidades_izq_E);
valor_maximo_r = max(vector_velocidades_encoder_izq_E);
mediana_v = median(vector_velocidades_izq_E);
mediana_r = median(vector_velocidades_encoder_izq_E);
cuartiles_v = quantile(vector_velocidades_izq_E,[0.25, 0.5, 0.75]);
cuartiles_r = quantile(vector_velocidades_encoder_izq_E,[0.25, 0.5, 0.75]);
cuartil_inferior_v = cuartiles_v(1);
cuartil_inferior_r = cuartiles_r(1);
cuartil_superior_v = cuartiles_v(3);
cuartil_superior_r = cuartiles_r(3);
media_v = mean(vector_velocidades_izq_E);
media_r = mean(vector_velocidades_encoder_izq_E);
varianza_v = var(vector_velocidades_izq_E);
varianza_r = var(vector_velocidades_encoder_izq_E);
diferencia_de_medias = media_v-media_r;
error_de_estimacion_medias = diferencia_de_medias-intervalo_confianza_med(1);

datos =[recuento_v, recuento_r; 
        valor_minimo_v, valor_minimo_r; 
        valor_maximo_v, valor_maximo_r; 
        mediana_v, mediana_r; 
        cuartil_inferior_v, cuartil_inferior_r; 
        cuartil_superior_v, cuartil_superior_r; 
        varianza_v, varianza_r
        media_v, media_r];

set(handles.resumen_estadistico,'data',datos);
set(handles.static_text_int_conf_var,'FontSize',14,'string',['[',num2str(intervalo_confianza_var(1)),' ; ',num2str(intervalo_confianza_var(2)),']']); 
set(handles.static_text_int_conf_med,'FontSize',14,'string',['[',num2str(intervalo_confianza_med(1)),' ; ',num2str(intervalo_confianza_med(2)),']']); 
set(handles.static_tex_ecu_int_confianza_media,'FontSize',14,'string',[num2str(diferencia_de_medias),' +/- ',num2str(error_de_estimacion_medias)]); 


% --- Executes on button press in boton_velocidades_servo_der.
function boton_velocidades_servo_der_Callback(hObject, eventdata, handles)
global vector_velocidades_encoder_der_E vector_velocidades_der_E alfa 

axes(handles.axes_cajas_y_bigotes); % Selecciona el axes a trabajar
cla(handles.axes_cajas_y_bigotes); % Limpia el axes
boxplot([vector_velocidades_encoder_der_E,vector_velocidades_der_E],'Orientation','horizontal','Labels',{'Calculada','Simulada'},'Widths',0.8); % Grafica el Diagrama de Cajas y Bigotes
title('Gráfico Caja y Bigotes - Velocidades Servo Derecho')
xlabel('Grados / Segundo','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
ylabel('Trayectorias','FontWeight','bold','FontSize',9,'Color',[0 0 0]);

axes(handles.axes_histograma); % Selecciona el axes a trabajar
cla(handles.axes_histograma); % Limpia el axes
histogram(vector_velocidades_der_E,'EdgeAlpha',0.5,'EdgeColor','white','FaceAlpha',1,'BinMethod','scott') % Grafica el Histograma de Frecuencias
hold on
histogram(vector_velocidades_encoder_der_E,'EdgeAlpha',0.5,'EdgeColor','white','FaceAlpha',0.6,'FaceColor','green','BinMethod','scott') % Grafica el Histograma de Frecuencias
hold on
title('Histograma de Frecuencias - Velocidades Servo Derecho')
xlabel('Grados / Segundo','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
ylabel('Frecuencia','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
legend('Trayectoria Simulada','Trayectoria Calculada','Location','northeast')

axes(handles.axes_cuantil_cuantil); % Selecciona el axes a trabajar
cla(handles.axes_cuantil_cuantil); % Limpia el axes
qqplot(vector_velocidades_der_E,vector_velocidades_encoder_der_E); % Grafica el Diagrama Cuantil-Cuantil
title('Gráfico Cuantil-Cuantil - Velocidades Servo Derecho')
xlabel('Trayectoria  Simulada [grados / segundo]','FontWeight','bold','FontSize',9,'Color',[0 0 0]);
ylabel('Trayectoria  Calculada [grados / segundo]','FontWeight','bold','FontSize',9,'Color',[0 0 0]);

[h_f,valor_PF,intervalo_confianza_var] = vartest2(vector_velocidades_der_E,vector_velocidades_encoder_der_E,'Alpha',alfa);
if valor_PF > alfa
    set(handles.static_text_prueba_F_1,'FontSize',12,'string',['Hipótesis Nula: Sigma_Simulada / Sigma_Calculada = 1',char(10),'Hipótesis Alternativa: Sigma_Simulada / Sigma_Calculada <> 1',char(10),'valor-P = ',num2str(valor_PF),char(10),'No hay diferencia estadisticamente significativa entre las desviaciones de las dos muestras.',char(10),'No se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
else
    set(handles.static_text_prueba_F_1,'FontSize',12,'string',['Hipótesis Nula: Sigma_Simulada / Sigma_Calculada = 1',char(10),'Hipótesis Alternativa: Sigma_Simulada / Sigma_Calculada <> 1',char(10),'valor-P = ',num2str(valor_PF),char(10),'Existe una diferencia estadisticamente significativa entre las desviaciones de las dos muestras.',char(10),'Se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
end

if h_f == 0
    [h_t,valor_Pt,intervalo_confianza_med] = ttest2(vector_velocidades_der_E,vector_velocidades_encoder_der_E,'Vartype','equal','Alpha',alfa);
else
    [h_t,valor_Pt,intervalo_confianza_med] = ttest2(vector_velocidades_der_E,vector_velocidades_encoder_der_E,'Vartype','unequal','Alpha',alfa);
end

if h_t == 0
    set(handles.static_text_prueba_t_1,'FontSize',12,'string',['Hipótesis Nula: Media_Simulada - Media_Calculada = 0',char(10),'Hipótesis Alternativa: Media_Simulada - Media_Calculada <> 0',char(10),'valor-P = ',num2str(valor_Pt),char(10),'No hay diferencia estadisticamente significativa entre las medias de las dos muestras.',char(10),'No se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
else
    set(handles.static_text_prueba_t_1,'FontSize',12,'string',['Hipótesis Nula: Media_Simulada - Media_Calculada = 0',char(10),'Hipótesis Alternativa: Media_Simulada - Media_Calculada <> 0',char(10),'valor-P = ',num2str(valor_Pt),char(10),'Existe una diferencia estadisticamente significativa entre las medias de las dos muestras.',char(10),'Se rechaza la hipótesis nula, para alfa = ', num2str(alfa)]); 
end

recuento_v = size(vector_velocidades_der_E,1);
recuento_r = size(vector_velocidades_encoder_der_E,1);
valor_minimo_v = min(vector_velocidades_der_E);
valor_minimo_r = min(vector_velocidades_encoder_der_E);
valor_maximo_v = max(vector_velocidades_der_E);
valor_maximo_r = max(vector_velocidades_encoder_der_E);
mediana_v = median(vector_velocidades_der_E);
mediana_r = median(vector_velocidades_encoder_der_E);
cuartiles_v = quantile(vector_velocidades_der_E,[0.25, 0.5, 0.75]);
cuartiles_r = quantile(vector_velocidades_encoder_der_E,[0.25, 0.5, 0.75]);
cuartil_inferior_v = cuartiles_v(1);
cuartil_inferior_r = cuartiles_r(1);
cuartil_superior_v = cuartiles_v(3);
cuartil_superior_r = cuartiles_r(3);
media_v = mean(vector_velocidades_der_E);
media_r = mean(vector_velocidades_encoder_der_E);
varianza_v = var(vector_velocidades_der_E);
varianza_r = var(vector_velocidades_encoder_der_E);
diferencia_de_medias = media_v-media_r;
error_de_estimacion_medias = diferencia_de_medias-intervalo_confianza_med(1);

datos =[recuento_v, recuento_r; 
        valor_minimo_v, valor_minimo_r; 
        valor_maximo_v, valor_maximo_r; 
        mediana_v, mediana_r; 
        cuartil_inferior_v, cuartil_inferior_r; 
        cuartil_superior_v, cuartil_superior_r; 
        varianza_v, varianza_r
        media_v, media_r];

set(handles.resumen_estadistico,'data',datos);
set(handles.static_text_int_conf_var,'FontSize',14,'string',['[',num2str(intervalo_confianza_var(1)),' ; ',num2str(intervalo_confianza_var(2)),']']); 
set(handles.static_text_int_conf_med,'FontSize',14,'string',['[',num2str(intervalo_confianza_med(1)),' ; ',num2str(intervalo_confianza_med(2)),']']); 
set(handles.static_tex_ecu_int_confianza_media,'FontSize',14,'string',[num2str(diferencia_de_medias),' +/- ',num2str(error_de_estimacion_medias)]); 


% --- Executes on slider movement.
function slider_alfa_porcentaje_Callback(hObject, eventdata, handles)
global alfa alfa_porcentaje
alfa_porcentaje = round(get(handles.slider_alfa_porcentaje,'Value'));
alfa = alfa_porcentaje/100;

guidata(hObject,handles);
set(handles.valor_alfa_slider,'String',alfa_porcentaje);
