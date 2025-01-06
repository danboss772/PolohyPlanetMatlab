function muj_projekt(data,data2)
%matfile
load data_table.mat           % nacteme potrebna data z tabulky
load data2.mat

global radiusyAdj             %deklarace globalnich promennych, ktere komponenty sdili mezi sebou
global delka_pausy
global hraj
global radiusyAdj
hodnotyTabulky = []

planetyAdj = [10,10,10,10,10,10,10,10,10];                %adjusted velikosti planet
radiusyAdj = [1,1,1,1,0.45,0.3,0.25,0.12];                %adjusted radiusy, aby se vesli do obrazku

k = datetime

hraj = false


velikostObrazovky = get(groot).MonitorPositions(3:4)      %tady byl pokus se trochu prizpusobit svislym monitorum
if velikostObrazovky(1) > velikostObrazovky(2)
    velikostVetsiho = velikostObrazovky(1)
else
    velikostVetsiho = velikostObrazovky(2)

end
startPrSl = velikostObrazovky(1)*0.55                     %zacatek praveho sloupce s daty
poziceAxes = [velikostObrazovky(2).*0.05,velikostObrazovky(2)*0.1,velikostObrazovky(2)*0.9,velikostObrazovky(2)*0.9];      %pozice samotneho obrazku simulace

hFig = uifigure('Position',[0,0,velikostObrazovky],'Color','Black', 'Name','Polohy Planet');                 %hFig s cernym pozadim
%hAlert = uialert("File not found.","Invalid File")
s = uistyle("FontColor","white");                                                    %styl pro tabulku
%hMenu = uimenu(hFig, 'Text', '&Soubor', 'Separator','on');
hMenu1 = uimenu(hFig,'Text','&Napoveda');                                         %horni menu                              
%4ehItem = uimenu(hMenu,'Text','&Exportovat');
hItem1 = uimenu(hMenu1,'Text', '&O Autorovi')                                   %neco i o mne
hItem1.MenuSelectedFcn = @(src,value)o_autorovi(src,value, velikostObrazovky);
hItem2 = uimenu(hMenu1,'Text', '&Vysvetleni');
hItem2.MenuSelectedFcn = @(src,value)presmerovat_na_nasa(src,value);                  %funkce, ktera presmerovava na externi stranku, aby uzivatel vedel o co jde
hAxes = uiaxes(hFig, 'Position', [poziceAxes], 'XLim', [-5 5], 'YLim', [-5 5]);
%hAxes.View = [90 0];
axis(hAxes,'off');                                         %nechci na strankach hAxes meritka
axtoolbar(hAxes,{'rotate','zoomin','zoomout','restoreview'});                        %toolbar muze postradat nektere veci
velikostSloupce = {50,50,70,100,70,70,50,50,50}
%velikostSloupce = {round(ones(9,1).*velikostVetsiho/2/9)}
hTab = uitable(hFig, 'Position',[startPrSl, velikostObrazovky(2)*0.5,620,250], 'Data', hodnotyTabulky, 'BackgroundColor','white','ForegroundColor','black', ...
    'RowName',{'Merkur','Venuse','EM Bary','Mars','Jupiter', 'Saturn','Uran','Neptun'}, 'ColumnName',{'semi-maj. ax.','ecc.','inc.','mean long.','long. of peri.','long. of asc. node', 'x ecl.','y ecl.','z ecl.'}, ...
    'ColumnWidth', velikostSloupce);
%addStyle(hTab,s);                                                %nakreslime tabulku, kde uzivatel bude videt hodnoty
hDatePicker = uidatepicker(hFig, 'Position', [startPrSl+150,velikostObrazovky(2)*0.8,200,50], ...
    'Value',datetime('today'));                                                                           %vyber datumu
hDatePicker.ValueChangedFcn = @(src, value)spocitejKoord(value, hAxes, data, data2, planetyAdj, radiusyAdj, hTab);
hSw = uiswitch(hFig, 'rocker', 'Position',[startPrSl,velikostObrazovky(2)*0.8, 100,100], 'Items', ["Norm. Velikost", "Prizpusobena"], 'FontColor','white', 'Value','Prizpusobena');
hSw.ValueChangedFcn = @(src, value)sjednotKoord(value, hDatePicker, hAxes, data, data2, planetyAdj, hTab);


%hTool = uitoolbar(hAxes);
%pt = uipushtool(hTool);

function o_autorovi(src,value, velikostObrazovky)  
sirkaFig = 500;
hFig1 = uifigure('Position',[velikostObrazovky(1)/2-sirkaFig/2,velikostObrazovky(2)*0.4,sirkaFig,500]);
hText = uilabel(hFig1, 'Position',[25,25,450,450],'WordWrap','on',"Text",'Tato aplikace byla vytvorena Denysem Lytvynenko jako zaverecny projekt. Veskere otazky smerujte na email lytvyden@cvut.cz.')
end

function presmerovat_na_nasa(src,value)                  %funkce presmeruje na externi stranku
web('https://ssd.jpl.nasa.gov/planets/approx_pos.html');
end



hButEx = uibutton(hFig, 'Position',[startPrSl, velikostObrazovky(2)*0.4, 100,50], 'Text','Export');                    %tlacitko exportu do csv
hButEx.ButtonPushedFcn = @(src,value)exportovat(src,value, hodnotyTabulky);                                                
hButPlay = uibutton(hFig,'Text','Play','Position',[startPrSl,150,100,50]);                                                                                   %tlacitko startu simulace
hButPlay.ButtonPushedFcn = @(src,value)prohraj(src, value, hDatePicker, hAxes, data,data2,planetyAdj, hTab);


hSlider = uislider(hFig,'Value',1, 'Limits',[0.1 5], 'FontColor','white','Position',[velikostObrazovky(2).*0.05,velikostObrazovky(2)*0.1,velikostObrazovky(2)*0.9,100],'MajorTicks',[0.1 1 2 3 4 5]);    %slider, ktery urcuje delku simulace
delka_pausy = hSlider.Value;                        %prvni delka pausy se urcuje hodnotou slideru
hSlider.ValueChangedFcn = @(src,value)sliderZmena(src,value);

function sliderZmena(src,value)                                     
hodnota = src.Value;
delka_pausy = 1/hodnota;                          %delka pauzy se urcuje tady
end


function prohraj(src, value, hDatePicker, hAxes, data,data2,planetyAdj, hTab)          %funkce, ktera odpovida za simulaci

if hraj == false
hraj = true                      %kdyz se prohrava simulace, zastav ji, kdyz naopak-prohraj

while hraj
hDatePicker.Value = hDatePicker.Value+1;                                           %kazdou delku pausy pridej jeden den a spocitej to
spocitejKoord(hDatePicker, hAxes, data, data2, planetyAdj, radiusyAdj, hTab);
pause(delka_pausy);
end
else
hraj = false;
end
end

    function[] = exportovat(src,value, hodnotyTabulky)

fileID = fopen('celldata.dat','w');
formatSpec = '%s %d %2.1f %s\n';

[nrows,ncols] = size(hodnotyTabulky);
for row = 1:nrows
    fprintf(fileID,formatSpec,hodnotyTabulky{row,:});
end
fclose(fileID);

end

    function sjednotKoord(value, hDatePicker, hAxes, data, data2, planetyAdj, hTab)
A = value.Value;
if A == "Prizpusobena";
radiusyAdj = [1,1,1,1,0.45,0.3,0.25,0.12];
else
radiusyAdj = [1,1,1,1,1,1,1,1];
end

spocitejKoord(hDatePicker, hAxes, data, data2, planetyAdj, radiusyAdj, hTab);
end
   %zde 
   

set(hAxes,'DataAspectRatio',[1 1 1]);         %aby hAxes byli stejne
%hAxes.GridLineStyle = 'none';
hAxes.Color = 'k';
hAxes.View = [90 0];                        %poloha kamery na zacatku
hAxes.Title.String = 'Poloha planet';
hAxes.Subtitle.String = string(k);              %datum
hAxes.ZLim = [-5 5];                      %limity hAxes

spocitejKoord(hDatePicker, hAxes, data, data2, planetyAdj, radiusyAdj, hTab);
hAxes.View = [0 90];  
%global hodnotyTabulky

 function[] = spocitejKoord(k, hAxes, data, data2, planetyAdj, radiusyAdj, hTab)                    %funkce, ktera dosadi koordinaty planet
    hTab.Data = []; %vynuluj hodnoty tabulky
     T_epch = juliandate(k.Value);                                                  %prevod casu na epochu
 T = (T_epch - 2451545)/36525;                                                     %pocet stoleti od J2000
 planety = ["Merkur",'Venuse','EM Bary','Mars','Jupiter', 'Saturn','Uran','Neptun'];      %nazvy planet
 cla(hAxes);                        %vycisti hAxes


hodnotyTabulky = [];                  %vynuluj hodnoty tabulky
  
for i = 1:8                                                    %pro kazdou ze sesti planet namaluj orbitu
a = data{i,'a_0'} + data{i,'dot_a'} * T;
je = data{i,'e_0'} + data{i,'dot_e'} * T;
w = data{i,'w_0'} + data{i,'dot_w'} * T;
Omega = data{i,'Omega_0'} + data{i,'dot_Omega'} * T;


    b=sqrt(a^2-je^2);     % vertical radius
    x0=-je;              % x0,y0 ellipse centre coordinates
    y0=0;
    t=-pi:0.01:pi;
    uhel = deg2rad(Omega);                                          %uhel otoceni osy (konkretneji v popisu NASA)
    x = x0 + (a*cos(t)*cos(uhel) - b*sin(t)*sin(uhel))*radiusyAdj(i);
    y = y0 + (b*sin(t)*cos(uhel) + a*cos(t)*sin(uhel))*radiusyAdj(i);

    Plot = plot3(hAxes,x,y,zeros(1,numel(x)));
    hold(hAxes, 'on' )
    direction = [1 0 0];

    omega = w - Omega;
    
    rotate(Plot,direction,deg2rad(omega))
    
   end
    [x,y,z] = sphere;
   surf(hAxes,x*0.00465047.*2*planetyAdj(9),y.*0.00465047.*2*planetyAdj(9),z.*0.00465047.*2*planetyAdj(9), ...
    'EdgeColor',[0.9290 0.6940 0.1250], 'SelectionHighlight','off');                  %namaluj Slunce



%sest Keplerovskych hodnot
for i = 1:8


a = data{i,'a_0'} + data{i,'dot_a'} * T;
je = data{i,'e_0'} + data{i,'dot_e'} * T;
I = data{i,'I_0'} + data{i,'dot_I'} * T;
L = data{i,'L_0'} + data{i,'dot_L'} * T;
w = data{i,'w_0'} + data{i,'dot_w'} * T;
Omega = data{i,'Omega_0'} + data{i,'dot_Omega'} * T;

p = data2{i, 'b'};              %musel jsem prejmenovat element b, aby nedoslo ke zmatkum
c = data2{i, 'c'};
s = data2{i, 's'};
f = data2{i, 'f'};

%konec

omega = w - Omega;

M = L - w + p*(T^2) + c*cosd(f*T) + s*sind(f*T);

if M < 0
M = -M;
M = mod(M,180);
M = -M;
else
 M = abs(M)

end

%Keplerova rovnice
tol = 10e-6;                                 %tolerance
delta_E = Inf;                              %zmena E
E = M+(180/pi*je)*sind(M);
while abs(delta_E) > tol
    delta_M = M - (E - (180/pi*je)*sind(E));
    delta_E = delta_M/(1-je*cosd(E));
    E = E + delta_E;

end

x = a*(cosd(E)-je);
y = a*sqrt(1-je^2)*sind(E);
z = 0;

%koordinaty v J2000
x_ecl = ((cosd(omega)*cosd(Omega)-sind(omega)*sind(Omega)*cosd(I)) * x + (-sind(omega)*cosd(Omega)-cosd(omega)*sind(Omega)*cosd(I)) * y)*radiusyAdj(i);
y_ecl = ((cosd(omega)*sind(Omega)+sind(omega)*cosd(Omega)*cosd(I)) * x + (-sind(omega)*sind(Omega)+cosd(omega)*cosd(Omega)*cosd(I)) * y)*radiusyAdj(i);
z_ecl = (sind(omega)*sind(I))*x + (cosd(omega)*sind(I))*y;


[x,y,z] = sphere;
p = surf(hAxes,x*0.00465047*2*planetyAdj(i)+x_ecl,y.*0.00465047.*2*planetyAdj(i)+y_ecl,z.*0.00465047.*2*planetyAdj(i)+z_ecl, ...
    'EdgeColor',[0.9290 0.6940 0.1250], 'SelectionHighlight','off'); %namaluj planetu
dtt = p.DataTipTemplate;                                %data tipy pro kazdou planetu, kde je napsano, co to je za planetu a jeji poloha
dtt.DataTipRows(1) = planety(i);
dtt.DataTipRows(2) = num2str(x_ecl);
dtt.DataTipRows(3) = num2str(y_ecl);            

nove_hodnoty = [a, je, I, L, w, Omega,x_ecl,y_ecl,z_ecl];
hodnotyTabulky = hTab.Data;
hodnotyTabulky = [hodnotyTabulky;nove_hodnoty];
hTab.Data = [hodnotyTabulky];         %pridani do tabulky novych hodnot
%path = export(hodnotyTabulky)
end
 end
end