function varargout = untitled1(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled1_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled1_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before untitled1 is made visible.
function untitled1_OpeningFcn(hObject, eventdata, handles, varargin)
    set(handles.zero,'Visible','On')
    set(handles.one,'Visible', 'Off')
    set(handles.two0,'Visible','Off')
    set(handles.two1,'Visible','Off')
    set(handles.two2,'Visible','Off')
    set(handles.two3,'Visible','Off')
    set(handles.two4,'Visible','Off')
    set(handles.two5,'Visible','Off')
    set(handles.two6,'Visible','Off')
    
    xlabel(handles.time_response,'time(s)')
    ylabel(handles.time_response,'Amplitude')

    xlabel(handles.freq_response,'Frequency (Hz)')
    ylabel(handles.freq_response,'Amplitude')
    
    handles.rawFs = 8000; % default sampling rate for recording a signal
    handles.newFs = 8000;

    % handles.raw  => Raw Input Signal for all three input types
    % handles.rawFs   => Sampling rate for all three raw input signals
    
    handles.spec_type = 'Rectangular';
    handles.LengthWind = 4;
    handles.overlap = 2;
    
    handles.gas_choose = 'Sinusoidal';
    handles.gas_length_type = 'seconds';
    handles.gas_seconds = 1;
    handles.gas_amplitude = 1;
    handles.gas_frequency = 1;
    handles.gas_phase = 0;
    
    dt = 1/handles.rawFs;
    t = [0:dt:handles.gas_seconds-dt];
    handles.raw = handles.gas_amplitude*cos(2*pi*handles.gas_frequency*t + handles.gas_phase);
    
    %Windowed
    handles.gas_window = 'Hamming';
    handles.gas_starting_time = 0;
    % handles.gas_window_length = 100;
    
    %Rectangle Windowed Linear Chirp
    handles.gas_initial_freq = 50;
    handles.gas_bandwidth = 10;
    % handles.gas_duration = 1;
    
    %Square Wave
    handles.gas_duty_cycle = 50;
    
    %Sawtooth Wave
    handles.gas_width = 5;
    
    %Signal Involving Multiple Components
    handles.number_of_components = 0;
    
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes untitled1 wait for user response (see UIRESUME)
    % uiwait(handles.figure1);

    
function update_graphs(handles)
    axes(handles.time_response);
    t = linspace(0,length(handles.raw)/handles.newFs,length(handles.raw));
    plot(t,handles.raw);

    axes(handles.freq_response);
    df = handles.newFs/length(handles.raw);
    fs = handles.newFs;
    f = -fs/2+df:df:fs/2;
    G = abs(fftshift(fft(handles.raw)));
    plot(f,G)    

    axes(handles.spectrogram);
    MyInput = handles.raw;
    LengthInp = length(handles.raw);
    LengthWind = handles.LengthWind;
    Overlap = handles.overlap;
    
    switch handles.spec_type
        case 'Hamming'
            w2 = hamming(LengthWind);
        case 'Hann'
            w2 = hann(LengthWind);
        case 'Bartlett'
            w2 = bartlett(LengthWind);
        case 'Taylor'
            w2 = taylorwin(LengthWind);
        case 'Triangular'
            w2 = triang(LengthWind);
        case 'Blackman'
            w2 = blackman(LengthWind);
        case 'Rectangular'
            w2 = rectwin(LengthWind);
    end
    
    Window = [w2' zeros(1,LengthInp - LengthWind)];
    x = round(LengthInp/(LengthWind-Overlap));
    y = zeros(LengthInp,x);
    
    if(size(MyInput,2) == 1)
        MyInput = MyInput';
    end
        
    for i = 1 : x
        y(:,i) = MyInput.*Window;
        WindowNew = Window(1 : (LengthInp - LengthWind + Overlap));
        Window = [ zeros(1,LengthWind - Overlap)  WindowNew];
    end

    yFFT = fft(y);
    yFFT = abs(yFFT);
    imagesc(20*log10(yFFT'));
    colorbar;
    title('Spectrogram');
    set(gca,'YDir','normal');
    
function Sinusoidal(hObject,handles)
    dt = 1/handles.rawFs;
    t = [0:dt:handles.gas_seconds-dt];
    handles.raw = handles.gas_amplitude*cos(2*pi*handles.gas_frequency*t + handles.gas_phase); 
    guidata(hObject,handles)
    update_graphs(handles);
function Windowed(hObject,handles)
    dt = 1/handles.rawFs;
    t = [handles.gas_starting_time:dt:handles.gas_seconds-dt]';
    s = handles.gas_amplitude*cos(2*pi*handles.gas_frequency*t + handles.gas_phase);

    n = handles.gas_seconds*handles.rawFs;
    
    switch handles.gas_window
        case 'Hamming'
            w = hamming(n);
        case 'Hann'
            w = hann(n);
        case 'Bartlett'
            w = bartlett(n);
        case 'Taylor'
            w = taylorwin(n);
        case 'Triangular'
            w = triang(n);
        case 'Blackman'
            w = blackman(n);
    end
    
    w = w(handles.gas_starting_time*handles.rawFs+1:end);
    handles.raw = s.*w;
    guidata(hObject,handles);
    update_graphs(handles);
function Rectangle_Windowed_Linear_Chirp(hObject,handles)
    dt = 1/handles.rawFs;
    t = [handles.gas_starting_time:dt:handles.gas_seconds-dt];
    handles.raw = handles.gas_amplitude*cos(2*pi*handles.gas_initial_freq*t + (2*pi*handles.gas_bandwidth*t.^2)/(2*handles.gas_seconds) + handles.gas_phase);
    guidata(hObject,handles)
    update_graphs(handles);
function Square_Wave(hObject,handles)
    dt = 1/handles.rawFs;
    t = [0:dt:handles.gas_seconds-dt];
    handles.raw=handles.gas_amplitude*(square(2*pi*handles.gas_frequency*t + handles.gas_phase,handles.gas_duty_cycle));
    guidata(hObject,handles)
    update_graphs(handles);
function Sawtooth_Wave(hObject,handles)
    dt = 1/handles.rawFs;
    t = [0:dt:handles.gas_seconds-dt];
    handles.raw=handles.gas_amplitude*(sawtooth(2*pi*handles.gas_frequency*t + handles.gas_phase,handles.gas_width));
    guidata(hObject,handles)
    update_graphs(handles);
function Signal_Involving_Multiple_Components(hObject,handles)
    if(handles.number_of_components ~= 0)
        dt = 1/handles.rawFs;
        t = [0:dt:handles.gas_seconds-dt];
        s = handles.gas_amplitude*cos(2*pi*handles.gas_frequency*t + handles.gas_phase);
        handles.raw = handles.raw + s;
        handles.number_of_components = handles.number_of_components - 1;
        set(handles.text52,'String',strcat(num2str(handles.number_of_components),' left'));
        update_graphs(handles);
    else
        update_graphs(handles);
    end  
    guidata(hObject,handles)



% --- Outputs from this function are returned to the command line.
function varargout = untitled1_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure

% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles)
file = uigetfile
[handles.raw,handles.rawFs] = audioread(file);
handles.raw = handles.raw(:,1);
handles.newFs = handles.rawFs;
guidata(hObject,handles)
update_graphs(handles);
set(handles.text47,'String',num2str(handles.rawFs));

function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)

% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)

% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)



% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)

% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)



% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)

% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)

% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)

% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in stop.
function stop_Callback(hObject, eventdata, handles)
disp('Stopped');
clear sound;

% --- Executes on button press in play.
function play_Callback(hObject, eventdata, handles)
disp('Playing...');
sound(handles.raw,handles.newFs);
    
function window_length_edit_Callback(hObject, eventdata, handles)
    handles.LengthWind = str2double(get(hObject,'String'));
    guidata(hObject,handles);
    update_graphs(handles);

% --- Executes during object creation, after setting all properties.
function window_length_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to window_length_edit (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
    handles.rawFs =  str2double(get(hObject,'String'));
    handles.newFs = handles.rawFs;
    guidata(hObject,handles);
    update_graphs(handles);


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
    switch handles.gas_length_type
        case 'seconds'
            handles.gas_seconds = str2double(get(hObject,'String'));
        case 'number of samples'
            handles.gas_seconds = str2double(get(hObject,'String'))*(1/handles.newFs);
    end

guidata(hObject,handles)
update_graphs(handles)

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu9.
function popupmenu9_Callback(hObject, eventdata, handles)
    str = get( hObject , 'String');
    val = get( hObject , 'Value' );
    handles.gas_length_type = char(str(val))
    guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function popupmenu9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)



% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in window_type_popupmenu.
function window_type_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to window_type_popupmenu (see GCBO)

% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns window_type_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from window_type_popupmenu


% --- Executes during object creation, after setting all properties.
function window_type_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to window_type_popupmenu (see GCBO)



% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)

% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)

% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)

% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)

% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)



% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in record.
function record_Callback(hObject, eventdata, handles)
% hObject    handle to record (see GCBO)

% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in stop_recording.
function stop_recording_Callback(hObject, eventdata, handles)
% hObject    handle to stop_recording (see GCBO)

% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pause_recording.
function pause_recording_Callback(hObject, eventdata, handles)
% hObject    handle to pause_recording (see GCBO)

% handles    structure with handles and user data (see GUIDATA)



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)

% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
clear sound;
disp('Recording...');
handles.recorder = audiorecorder(handles.rawFs,8,1);
handles.newFs = handles.rawFs;
record(handles.recorder);
guidata(hObject,handles);


% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
stop(handles.recorder);
disp('End of Recording.');
handles.raw = getaudiodata(handles.recorder);
guidata(hObject,handles);
update_graphs(handles);

function edit7_Callback(hObject, eventdata, handles)
handles.rawFs = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in push_button_input_type.
function push_button_input_type_Callback(hObject, eventdata, handles)
   
    str = get( hObject , 'String');
    val = get( hObject , 'Value' );
    
    set(handles.zero,'Visible','Off');
    set(handles.one,'Visible','Off');
    set(handles.two0,'Visible','Off');
   
    switch char(str(val))
        case 'Record a Sound'
            set(handles.zero,'Visible','On');
        case 'Upload a File'
            set(handles.one,'Visible','On');
        case 'Generate a Signal'
            set(handles.two0,'Visible','On');
    end

% --- Executes during object creation, after setting all properties.
function push_button_input_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to push_button_input_type (see GCBO)



% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit39_Callback(hObject, eventdata, handles)
    handles.gas_width = str2double(get(hObject,'String'));
    guidata(hObject,handles)
    Sawtooth_Wave(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit39_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit39 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit38_Callback(hObject, eventdata, handles)
    handles.gas_phase = str2num(char(get(hObject,'String')));
    guidata(hObject,handles)
    Sawtooth_Wave(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit38_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit38 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit37_Callback(hObject, eventdata, handles)
    handles.gas_frequency = str2double(get(hObject,'String'));
    guidata(hObject,handles)
    Sawtooth_Wave(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit37_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit37 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit36_Callback(hObject, eventdata, handles)
    handles.gas_amplitude = str2double(get(hObject,'String'));
    guidata(hObject,handles)
    Sawtooth_Wave(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit36_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit36 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit23_Callback(hObject, eventdata, handles)
    handles.gas_amplitude = str2double(get(hObject,'String'));
    guidata(hObject,handles)
    Rectangle_Windowed_Linear_Chirp(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit24_Callback(hObject, eventdata, handles)
    handles.gas_initial_freq = str2double(get(hObject,'String'));
    guidata(hObject,handles)
    Rectangle_Windowed_Linear_Chirp(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit25_Callback(hObject, eventdata, handles)
    handles.gas_bandwidth = str2double(get(hObject,'String'));
    guidata(hObject,handles)
    Rectangle_Windowed_Linear_Chirp(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit26_Callback(hObject, eventdata, handles)
    handles.gas_duration = str2double(get(hObject,'String'));
    guidata(hObject,handles)
    Rectangle_Windowed_Linear_Chirp(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit27_Callback(hObject, eventdata, handles)
    handles.gas_phase = str2num(char(get(hObject,'String')));
    guidata(hObject,handles)
    Rectangle_Windowed_Linear_Chirp(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit28_Callback(hObject, eventdata, handles)
    handles.gas_amplitude = str2double(get(hObject,'String'));
    guidata(hObject,handles)
    Square_Wave(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit29_Callback(hObject, eventdata, handles)
    handles.gas_frequency = str2double(get(hObject,'String'));
    guidata(hObject,handles)
    Square_Wave(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit30_Callback(hObject, eventdata, handles)
    handles.gas_phase = str2num(char(get(hObject,'String')));
    guidata(hObject,handles)
    Square_Wave(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit30_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit31_Callback(hObject, eventdata, handles)
    handles.gas_duty_cycle = str2double(get(hObject,'String'));
    guidata(hObject,handles)
    Square_Wave(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
    handles.gas_amplitude = str2double(get(hObject,'String'));
    guidata(hObject,handles)
    Windowed(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
    handles.gas_frequency = str2double(get(hObject,'String'));
    guidata(hObject,handles)
    Windowed(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
    handles.gas_phase = str2num(char(get(hObject,'String')));
    guidata(hObject,handles)
    Windowed(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu13.
function popupmenu13_Callback(hObject, eventdata, handles)
    str = get( hObject , 'String');
    val = get( hObject , 'Value' );
    handles.gas_window = char(str(val));
    guidata(hObject,handles)
    Windowed(hObject,handles);
    

% --- Executes during object creation, after setting all properties.
function popupmenu13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu13 (see GCBO)



% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
    handles.gas_starting_time = str2double(get(hObject,'String'));
    guidata(hObject,handles)
    Windowed(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
    handles.gas_amplitude = str2double(get(hObject,'String'));
    guidata(hObject,handles)
    Sinusoidal(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
    handles.gas_frequency = str2double(get(hObject,'String'));
    guidata(hObject,handles)
    Sinusoidal(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
    handles.gas_phase = str2num(char(get(hObject,'String')));
    guidata(hObject,handles)
    Sinusoidal(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu10.
function popupmenu10_Callback(hObject, eventdata, handles)   
    str = get( hObject , 'String');
    val = get( hObject , 'Value' );
    handles.gas_choose = char(str(val));
    guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function popupmenu10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)



% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton34.
function pushbutton34_Callback(hObject, eventdata, handles)
set(handles.two0,'Visible','On')
set(handles.two5,'Visible','Off')


% --- Executes on button press in pushbutton35.
function pushbutton35_Callback(hObject, eventdata, handles)
set(handles.two0,'Visible','On')
set(handles.two6,'Visible','Off')

% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, handles)
set(handles.two0,'Visible','On')
set(handles.two3,'Visible','Off')


% --- Executes on button press in pushbutton36.
function pushbutton36_Callback(hObject, eventdata, handles)
set(handles.two0,'Visible','On')
set(handles.two4,'Visible','Off')

% --- Executes on button press in pushbutton31.
function pushbutton31_Callback(hObject, eventdata, handles)
set(handles.two0,'Visible','On')
set(handles.two1,'Visible','Off')

% --- Executes on button press in pushbutton32.
function pushbutton32_Callback(hObject, eventdata, handles)
set(handles.two0,'Visible','On')
set(handles.two2,'Visible','Off')


% --- Executes on button press in pushbutton37.
function pushbutton37_Callback(hObject, eventdata, handles)
    set(handles.two0,'Visible','Off')
    
    switch handles.gas_choose
        case 'Sinusoidal'
            set(handles.two1,'Visible','On')
        case 'Windowed'
            set(handles.two2,'Visible','On')
        case 'Rectangle Windowed Linear Chirp'
            set(handles.two3,'Visible','On')
        case 'Square Wave'
            set(handles.two4,'Visible','On')
        case 'Sawtooth Wave'
            set(handles.two5,'Visible','On')
        case 'Signal Involving Multiple Components'
            set(handles.two6,'Visible','On')
    end



function edit40_Callback(hObject, eventdata, handles)
    handles.number_of_components = str2double(get(hObject,'String'));
    handles.raw = 0;
    guidata(hObject,handles)
    set(handles.text52,'String',strcat(num2str(handles.number_of_components),' left'));
    
% --- Executes during object creation, after setting all properties.
function edit40_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit40 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu14.
function popupmenu14_Callback(hObject, eventdata, handles)
    str = get( hObject , 'String');
    val = get( hObject , 'Value' );
     
    handles.spec_type = char(str(val));
    guidata(hObject,handles);
    update_graphs(handles);

    
% --- Executes during object creation, after setting all properties.
function popupmenu14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu14 (see GCBO)



% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit41_Callback(hObject, eventdata, handles)
    handles.overlap = str2double(get(hObject,'String'));
    guidata(hObject,handles);
    update_graphs(handles);

% --- Executes during object creation, after setting all properties.
function edit41_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit41 (see GCBO)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in speed_ratio.
function speed_ratio_Callback(hObject, eventdata, handles)
    str = get( hObject , 'String');
    val = get( hObject , 'Value' );
    handles.newFs = handles.rawFs * str2double(cell2mat(str(val)));
    set(handles.text47,'String',num2str(handles.newFs));
    guidata(hObject,handles);
    update_graphs(handles);


function edit42_Callback(hObject, eventdata, handles)
    handles.gas_starting_time = str2double(get(hObject,'String'));
    guidata(hObject,handles)
    Rectangle_Windowed_Linear_Chirp(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit42_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit42 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit43_Callback(hObject, eventdata, handles)
    handles.gas_amplitude = str2double(get(hObject,'String'));
    guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function edit43_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit44_Callback(hObject, eventdata, handles)
    handles.gas_frequency = str2double(get(hObject,'String'));
    guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit44_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit45_Callback(hObject, eventdata, handles)
    handles.gas_phase = str2num(char(get(hObject,'String')));
    guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function edit45_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton38.
function pushbutton38_Callback(hObject, eventdata, handles)
    Signal_Involving_Multiple_Components(hObject,handles);


% --- Executes on button press in pushbutton39.
function pushbutton39_Callback(~,~, handles)
    set(untitled1, 'HandleVisibility', 'off');
    close all;
    set(untitled1, 'HandleVisibility', 'on');

    figure;
    t = linspace(0,length(handles.raw)/handles.newFs,length(handles.raw));
    plot(t,handles.raw);
    xlabel('Time(s)');
    ylabel('Amplitude');

    figure;
    df = handles.newFs/length(handles.raw);
    fs = handles.newFs;
    f = -fs/2+df:df:fs/2;
    G = abs(fftshift(fft(handles.raw)));
    plot(f,G)    
    xlabel('Frequency(Hz)');
    ylabel('Amplitude');
    
    figure;
    MyInput = handles.raw;
    LengthInp = length(handles.raw);
    LengthWind = handles.LengthWind;
    Overlap = handles.overlap;
    
    switch handles.spec_type
        case 'Hamming'
            w2 = hamming(LengthWind);
        case 'Hann'
            w2 = hann(LengthWind);
        case 'Bartlett'
            w2 = bartlett(LengthWind);
        case 'Taylor'
            w2 = taylorwin(LengthWind);
        case 'Triangular'
            w2 = triang(LengthWind);
        case 'Blackman'
            w2 = blackman(LengthWind);
        case 'Rectangular'
            w2 = rectwin(LengthWind);
    end
    
    Window = [w2' zeros(1,LengthInp - LengthWind)];
    x = round(LengthInp/(LengthWind-Overlap));
    y = zeros(LengthInp,x);
    
    if(size(MyInput,2) == 1)
        MyInput = MyInput';
    end
    
    for i = 1 : x
        y(:,i) = MyInput.*Window;
        WindowNew = Window(1 : (LengthInp - LengthWind + Overlap));
        Window = [ zeros(1,LengthWind - Overlap)  WindowNew];
    end
    yFFT = fft(y);
    yFFT = abs(yFFT);
    
    imagesc(20*log10(yFFT'));
    colorbar;
    set(gca,'YDir','normal');
    ylabel('Samples');
