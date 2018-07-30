function varargout = panGUI(varargin)
% PANGUI MATLAB code for panGUI.fig
%      PANGUI, by itself, creates a new PANGUI or raises the existing
%      singleton*.
%
%      H = PANGUI returns the handle to a new PANGUI or the handle to
%      the existing singleton*.
%
%      PANGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANGUI.M with the given input arguments.
%
%      PANGUI('Property','Value',...) creates a new PANGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before panGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to panGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help panGUI

% Last Modified by GUIDE v2.5 06-Jun-2016 09:53:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @panGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @panGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin > 1 && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before panGUI is made visible.
function panGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to panGUI (see VARARGIN)

% Choose default command line output for panGUI
handles.output = hObject;

handles.plotfunc = varargin{1}

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes panGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = panGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in prevbutton.
function prevbutton_Callback(hObject, eventdata, handles)
% hObject    handle to prevbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentindex = str2num(get(handles.currentindex,'String'));
if currentindex > 1
    set(handles.currentindex,'String', num2str(currentindex - 1));
    handles.plotfunc(currentindex)
end


% --- Executes on button press in nexbutton.
function nexbutton_Callback(hObject, eventdata, handles)
% hObject    handle to nexbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentindex = str2num(get(handles.currentindex,'String'));
if currentindex < Inf
    set(handles.currentindex,'String', num2str(currentindex + 1));
    handles.plotfunc(currentindex)
end


function currentindex_Callback(hObject, eventdata, handles)
% hObject    handle to currentindex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of currentindex as text
%        str2double(get(hObject,'String')) returns contents of currentindex as a double

        currentindex = str2num(get(handles.currentindex,'String'));

    handles.plotfunc(currentindex)
% --- Executes during object creation, after setting all properties.
function currentindex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentindex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
