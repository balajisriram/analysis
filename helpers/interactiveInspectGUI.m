function varargout = interactiveInspectGUI(varargin)
% INTERACTIVEINSPECTGUI M-file for interactiveInspectGUI.fig
%      INTERACTIVEINSPECTGUI, by itself, creates a new INTERACTIVEINSPECTGUI or raises the existing
%      singleton*.
%
%      H = INTERACTIVEINSPECTGUI returns the handle to a new INTERACTIVEINSPECTGUI or the handle to
%      the existing singleton*.
%
%      INTERACTIVEINSPECTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERACTIVEINSPECTGUI.M with the given input arguments.
%
%      INTERACTIVEINSPECTGUI('Property','Value',...) creates a new INTERACTIVEINSPECTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before interactiveInspectGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to interactiveInspectGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help interactiveInspectGUI

% Last Modified by GUIDE v2.5 02-Aug-2010 17:52:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @interactiveInspectGUI_OpeningFcn, ...
    'gui_OutputFcn',  @interactiveInspectGUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1}) && isempty(strfind(varargin{1},'datanetOutput'))
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
end
% End initialization code - DO NOT EDIT

%% GUI startup
% --- Executes just before interactiveInspectGUI is made visible.
function interactiveInspectGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to interactiveInspectGUI (see VARARGIN)

% Choose default command line output for interactiveInspectGUI
disp('will now store data necessary to run GUI');
switch nargin
    case 4   % ## new case, pass in all defaults then session and trode index of trode to be analyzed within session.trodes
        handles.trode = varargin{1};
    otherwise
        error('why do you call this GUI in this weird way???');
end
% some special functions for the ISI plot
set(handles.hist10MSAxis,'ButtonDownFcn',{@hist10MSAxis_ButtonDownFcn, handles});

% Update handles structure
guidata(hObject, handles);

% fill up the clusters panel
clusterListPanel_Initialize(hObject, eventdata, handles);

% now update the axes
updateAllAxes(hObject, eventdata, handles);

% UIWAIT makes interactiveInspectGUI wait for user response (see UIRESUME)
% uiwait(handles.inspectGUIFig);
end

%% GUI close
% --- Outputs from this function are returned to the command line.
function varargout = interactiveInspectGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

varargout{1} = handles.trode;
% Get default command line output from handles structure
% varargout{1} = handles.spikeSortingParams;
% varargout{2} = handles.currentSpikeRecord;
end

%% GUI Exit
function interactiveInspectGUI_ExitFcn(hObject, eventdata, handles)
% keyboard
delete(handles.inspectGUIFig);
end

%% Axes create funcs. nothing will be done. because handles is empty
% featureAxis
% --- Executes during object creation, after setting all properties.
function featureAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to featureAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate featureAxis
end
% waveAxis
% --- Executes during object creation, after setting all properties.
function waveAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to waveAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate waveAxis
end
% waveMeansAxis
% --- Executes during object creation, after setting all properties.
function waveMeansAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to waveMeansAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate waveMeansAxis
end
% hist10MSAxis
% --- Executes during object creation, after setting all properties.
function hist10MSAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hist10MSAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end
% trodesMenu
% --- Executes during object creation, after setting all properties.
function trodesMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trodesMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
end
% firingRateAxis
% --- Executes during object creation, after setting all properties.
function firingRateAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firingRateAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate firingRateAxis
end
% --- Executes during object creation, after setting all properties.
%detectionMethodMenu
function detectionMethodMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to detectionMethodMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
%sortingMethodMenu
% --- Executes during object creation, after setting all properties.
function sortingMethodMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sortingMethodMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

end
% --- Executes during object creation, after setting all properties.
%barChartWhole
function barChartWhole_CreateFcn(hObject, eventdata, handles)
% hObject    handle to barChartWhole (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate barChartWhole
end
%barChartPart
% --- Executes during object creation, after setting all properties.
function barChartPart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to barChartPart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate barChartPart
end
% --- Executes during object creation, after setting all properties.

%% Deals with how the axes are updated
% updateAllAxes
function updateAllAxes(hObject, eventdata, handles)
featureAxis_UpdateFcn(hObject, eventdata, handles);
waveAxis_UpdateFcn(hObject, eventdata, handles);
waveMeansAxis_UpdateFcn(hObject, eventdata, handles);
linkaxes([handles.waveAxis handles.waveMeansAxis],'xy');
hist10MSAxis_UpdateFcn(hObject, eventdata, handles);
firingRateAxis_UpdateFcn(hObject, eventdata, handles);
barChartWhole_UpdateFcn(hObject, eventdata, handles);
barChartPart_UpdateFcn(hObject, eventdata, handles);
end

% featureAxis
function featureAxis_UpdateFcn(hObject, eventdata, handles)

% go to the axis
axes(handles.featureAxis);cla; hold on;

% now check if worth plotting
if isempty(handles.trode.spikeEvents)
    text(0.5,0.5,'no spikes in trode','HorizontalAlignment','center','VerticalAlignment','middle');
    return
end

% get the feature values

sizSpikeWvFrm = size(handles.trode.spikeWaveForms);

if length(sizSpikeWvFrm)==3
    [features nDim] = useFeatures(reshape(handles.trode.spikeWaveForms,sizSpikeWvFrm(1),sizSpikeWvFrm(2)*sizSpikeWvFrm(3)),handles.trode.spikeModel.featureList,handles.trode.spikeModel.featureDetails);
else
    [features nDim] = useFeatures(handles.trode.spikeWaveForms,handles.trode.spikeModel.featureList,handles.trode.spikeModel.featureDetails);
end

% choose color scheme
colors=getClusterColorValues(handles,handles.trode.spikeRankedCluster);

clusterVisibilityValues = getClusterVisibilityValues(handles, handles.trode.spikeRankedCluster);


% loop through clusters and plot features
for i=1:length(handles.trode.spikeRankedCluster)
    thisCluster=find(handles.trode.spikeAssignedCluster==handles.trode.spikeRankedCluster(i));
    if ~isempty(thisCluster)&&clusterVisibilityValues(i)
        markerType = '.';
        plot3(features(thisCluster,1),features(thisCluster,2),features(thisCluster,3),markerType,'color',colors(i,:));
        axis([min(features(:,1)) max(features(:,1)) min(features(:,2)) max(features(:,2)) min(features(:,3)) max(features(:,3))]);
        colorStr = sprintf('\\color[rgb]{%f %f %f}',colors(i,1),colors(i,2),colors(i,3));
        text(max(features(:,1)),max(features(:,2))-0.1*max(features(:,2))*(i-1),0,sprintf('%s%d:%d spikes',colorStr,handles.trode.spikeRankedCluster(i),length(thisCluster)),'HorizontalAlignment','right','VerticalAlignment','top');
    end
    
end
end

% waveAxis
function waveAxis_UpdateFcn(hObject, eventdata, handles)
% select the axis
axes(handles.waveAxis); cla; hold on;

% now check if worth plotting
if isempty(handles.trode.spikeEvents)
    text(0.5,0.5,'no spikes in trode','HorizontalAlignment','center','VerticalAlignment','middle');
    return
end


% choose color scheme
colors=getClusterColorValues(handles,handles.trode.spikeRankedCluster);
% colors(1,:) = [1 0 0]; % red

clusterVisibilityValues = getClusterVisibilityValues(handles, handles.trode.spikeRankedCluster);



% now plot
for i=1:length(handles.trode.spikeRankedCluster)
    thisCluster=find(handles.trode.spikeAssignedCluster==handles.trode.spikeRankedCluster(i));
    sizspikeWaveforms = size(handles.trode.spikeWaveForms);
    if length(sizspikeWaveforms)==3
        numChans = sizspikeWaveforms(3);
        numSamps = sizspikeWaveforms(2);
    else
        numChans = 1;
        numSamps = sizspikeWaveforms(2);
    end
    if ~isempty(thisCluster) && clusterVisibilityValues(i)
        switch numChans
            case 1
                plot(handles.trode.spikeWaveForms(thisCluster,:)','color',colors(i,:));
            otherwise
                for j = 1:numChans
                    
                    plot((j-1)*numSamps+(1:numSamps),handles.trode.spikeWaveForms(thisCluster,:,j)','color',colors(i,:));
                end
        end
    end
end

title('waveforms');
set(gca,'XTick',[]);
axis([1 numChans*numSamps  1.1*minmax(handles.trode.spikeWaveForms(:)') ])
end


% waveMeansAxis
function waveMeansAxis_UpdateFcn(hObject, eventdata, handles)
% select the axis
axes(handles.waveMeansAxis); cla; hold on;

% now check if worth plotting
if isempty(handles.trode.spikeEvents)
    text(0.5,0.5,'no spikes in trode','HorizontalAlignment','center','VerticalAlignment','middle');
    return
end


% choose color scheme
colors=getClusterColorValues(handles,handles.trode.spikeRankedCluster);
% colors(1,:) = [1 0 0]; % red

clusterVisibilityValues = getClusterVisibilityValues(handles, handles.trode.spikeRankedCluster);
sizSpikeWvFrm = size(handles.trode.spikeWaveForms);
if length(sizSpikeWvFrm)==3
    
    spikeWaveForms = reshape(handles.trode.spikeWaveForms,sizSpikeWvFrm(1),sizSpikeWvFrm(2)*sizSpikeWvFrm(3));
else
    spikeWaveForms = handles.trode.spikeWaveForms;
end
for i=1:length(handles.trode.spikeRankedCluster)
    thisCluster=find(handles.trode.spikeAssignedCluster==handles.trode.spikeRankedCluster(i));
    if ~isempty(thisCluster)&& clusterVisibilityValues(i)
        meanWave = mean(spikeWaveForms(thisCluster,:),1);
        stdWave = std(spikeWaveForms(thisCluster,:),1);
        plot(meanWave','color',colors(i,:),'LineWidth',2);
        lengthOfWaveform = size(spikeWaveForms,2);
        fillWave = fill([1:lengthOfWaveform fliplr(1:lengthOfWaveform)]',[meanWave+stdWave fliplr(meanWave-stdWave)]',colors(i,:));set(fillWave,'edgeAlpha',0,'faceAlpha',.2);
    end
end

% set(gca,'XTick',[1 25 61],'XTickLabel',{sprintf('%2.2f',-24000/handles.plottingInfo.samplingRate),'0',sprintf('%2.2f',36000/handles.plottingInfo.samplingRate)});xlabel('ms');
end


% hist10MSAxis
function hist10MSAxis_UpdateFcn(hObject, eventdata, handles)

% select the axis
axes(handles.hist10MSAxis); cla; hold on;

% now check if worth plotting
if isempty(handles.trode.spikeEvents)
    text(0.5,0.5,'no spikes in trode','HorizontalAlignment','center','VerticalAlignment','middle');
    return
end

% set the colors
colors=getClusterColorValues(handles,handles.trode.spikeRankedCluster);
% colors(1,:) = [1 0 0]; %red

clusterVisibilityValues = getClusterVisibilityValues(handles, handles.trode.spikeRankedCluster);


%inter-spike interval distribution
existISILess10MS = false;
maxEdgePart = 0;
maxProbPart = 0;
% for other spikes
for i = 1:length(handles.trode.spikeRankedCluster)
    if clusterVisibilityValues(i)
        thisCluster = (handles.trode.spikeAssignedCluster==handles.trode.spikeRankedCluster(i));
        ISIThisCluster = diff(handles.trode.spikeTimeStamps(thisCluster)*1000); % all spike timestamps are in seconds and we want MS here
        
        % part
        edges = linspace(0,10,100);
        count=histc(ISIThisCluster,edges);
        if sum(count)>0
            existISILess10MS = true;
            prob=count/sum(count);
            ISIfill = fill([edges(1); edges(:); edges(end)],[0; prob(:); 0],colors(i,:));
            set(ISIfill,'edgeAlpha',0,'faceAlpha',.5);
            maxEdgePart = max(maxEdgePart,max(edges));
            maxProbPart = max(maxProbPart,max(prob));
        end
    end
end
if existISILess10MS
    axis([0 maxEdgePart 0 maxProbPart]);
    text(maxEdgePart/2,maxProbPart,'ISI<10ms','HorizontalAlignment','center','VerticalAlignment','Top')
    lockout=1000*39/handles.trode.detectParams.samplingFreq;  %why is there a algorithm-imposed minimum ISI?  i think it is line 65  detectSpikes
    lockout=edges(max(find(edges<=lockout)));
    plot([lockout lockout],get(gca,'YLim'),'k') %
    plot([2 2], get(gca,'YLim'),'k--')
else
    axis([0 10 0 1]);
    text(10,1,'no ISI < 10 ms','HorizontalAlignment','right','VerticalAlignment','Top');
end
end

% firingRateAxis
function firingRateAxis_UpdateFcn(hObject, eventdata, handles)

% select the axis
axes(handles.firingRateAxis); cla; hold on;

% now check if worth plotting
if isempty(handles.trode.spikeEvents)
    text(0.5,0.5,sprintf('no spikes in trode'),'HorizontalAlignment','center','VerticalAlignment','middle');
    return
end

% set the colors
colors=getClusterColorValues(handles,handles.trode.spikeRankedCluster);

clusterVisibilityValues = getClusterVisibilityValues(handles, handles.trode.spikeRankedCluster);

minimumTimeToEstimateFiringRate = 1;% seconds

for clustNum = 1:length(handles.trode.spikeRankedCluster)
    if clusterVisibilityValues(clustNum)
        spkTs=handles.trode.spikeTimeStamps(handles.trode.spikeAssignedCluster==handles.trode.spikeRankedCluster(clustNum));
        sessionDur = 0:minimumTimeToEstimateFiringRate:ceil(max(handles.trode.spikeTimeStamps));
        spikeInBin = histc(spkTs,sessionDur);
        
        plot(sessionDur,spikeInBin,'color',colors(clustNum,:));
    end
end
set(gca,'xlim',[0 ceil(max(handles.trode.spikeTimeStamps))],'ylim',[-3 40]);
end

% populating the trodesMenu popup menu
function trodesMenu_Initialize(hObject, eventdata, handles)
trodesAvail = {};
for i = 1:length(handles.trodes)
    trodesAvail{i} = createTrodeName(handles.trodes(i));
end
currTrodeNum = find(strcmp(handles.currTrode,trodesAvail));
set(handles.trodesMenu,'String',trodesAvail);
set(handles.trodesMenu,'Value',currTrodeNum);
end

% initialize the clusterPanel
function clusterListPanel_Initialize(hObject, eventdata, handles)

try
    length(handles.previouslyVisible);
catch ex
    % if it fails by not finding the .previouslyvisible list
    handles.previouslyVisible = [];
end

whichTrode = handles.trode;
try
    rankedClustersCell = whichTrode.spikeRankedCluster;
catch ex
    if strfind(ex.message,'Reference to non-existent field ''rankedClusters''')
        ex2 = MException('InteractiveInspectGUI:noRankedClusters','Did you sort those cells?');
        ex = addCause(ex,ex2);
        throw(ex);
    else
        throw(ex);
    end
end
% sometimes rankedClusters is a Cell array. Just
if iscell(rankedClustersCell) %(happens when we call after sorting on every chunk)
    rankedClusters = [];
    for i = 1:length(rankedClustersCell)
        rankedClusters = unique([rankedClusters;makerow(rankedClustersCell{i})']);
    end
else
    rankedClusters = rankedClustersCell;
end

positionOfCheckBoxes = arrangeInSpace(length(rankedClusters),'rowThenColumn');
if isfield(handles,'clusterListHandles')
    for i = 1:length(handles.clusterListHandles)
        delete(handles.clusterListHandles(i));
    end
end
handles.clusterListHandles = [];
colorPermOrder = randperm(length(rankedClusters));
colors = spikesColorMap(length(rankedClusters));
colors = colors(colorPermOrder,:);
handles.cMap = colors;
guidata(hObject,handles);
% colors(1,:) = [1,0,0];
for i = 1:length(rankedClusters)
    
    clusterName = sprintf('%d',rankedClusters(i));
    visible = any(handles.previouslyVisible ==i);
    handles.clusterListHandles(i) = uicontrol('Parent',handles.clusterListPanel,'Style','checkbox',...
        'String',clusterName,'Value',visible,'Units','normalized',...
        'Position',[([0 -0.15]+positionOfCheckBoxes(i,:)) 0.15 0.15],'ForegroundColor',colors(i,:),'CallBack',{@updateAllAxes,handles});
    
end

% update the guidata
guidata(hObject,handles);
end

% barChartWhole
function barChartWhole_UpdateFcn(hObject, eventdata, handles)
% select the axis
axes(handles.barChartWhole); cla; hold on;

% now check if worth plotting
if isempty(handles.trode.spikeEvents)
    text(0.5,0.5,sprintf('no spikes in trode'),'HorizontalAlignment','center','VerticalAlignment','middle');
    return
end

% set the colors
colors=getClusterColorValues(handles,handles.trode.spikeRankedCluster);

% get cluster visibility
clusterVisibilityValues = getClusterVisibilityValues(handles,handles.trode.spikeRankedCluster);

spikeCounts = nan(length(handles.trode.spikeRankedCluster),1);
clusterNames = {};
for i = 1:length(handles.trode.spikeRankedCluster)
    spikeCounts(i) = length(find(handles.trode.spikeAssignedCluster==handles.trode.spikeRankedCluster(i)));
    clusterNames{i} = sprintf('%d',handles.trode.spikeRankedCluster(i));
end
% normalize by the % of spikes
spikeCounts = 100*spikeCounts/sum(spikeCounts);

barWhole = bar(spikeCounts);

% now change colors according to colormap
for i = 1:length(handles.trode.spikeRankedCluster)
    if ~clusterVisibilityValues(i)
        colors(i,:) = [0.5 0.5 0.5];
    end
end
set(get(barWhole,'Children'),'FaceVertexCData',colors);
end

% barChartPart
function barChartPart_UpdateFcn(hObject, eventdata, handles)


% select the axis
axes(handles.barChartPart); cla; hold on;
% now check if worth plotting
if isempty(handles.trode.spikeEvents)
    text(0.5,0.5,sprintf('no spikes in trode'),'HorizontalAlignment','center','VerticalAlignment','middle');
    return
end

% set the colors
colors=getClusterColorValues(handles,handles.trode.spikeRankedCluster);

% get cluster visibility
clusterVisibilityValues = getClusterVisibilityValues(handles,handles.trode.spikeRankedCluster);

spikeCounts = [];
clusterNames = {};
for i = 1:length(handles.trode.spikeRankedCluster)
    spikeCounts(i) = length(find(handles.trode.spikeAssignedCluster==handles.trode.spikeRankedCluster(i)));
    clusterNames{i} = sprintf('%d',handles.trode.spikeRankedCluster(i));
end

%now include only those that actually are visible
whichClusters = find(~clusterVisibilityValues);
spikeCounts(whichClusters) = [];

% normalize by the % of spikes
spikeCounts = 100*spikeCounts/sum(spikeCounts);


colors(whichClusters,:) = [];
if ~isempty(spikeCounts)
    barPart = bar(spikeCounts);
    set(get(barPart,'Children'),'FaceVertexCData',colors);
end

end

%% Callbacks are set here

% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('automatically saved now');
end

% --- Executes on button press in saveAndExitButton.
function saveAndExitButton_Callback(hObject, eventdata, handles)
disp('automatically saved now');
interactiveInspectGUI_ExitFcn(hObject, eventdata, handles);
end

% --- Executes on button press in exitButton.
function exitButton_Callback(hObject, eventdata, handles)
% hObject    handle to exitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('automatically saved now');
interactiveInspectGUI_ExitFcn(hObject, eventdata, handles);
end

% --- Executes on slider movement.
function thresholdSlider_Callback(hObject, eventdata, handles)
% hObject    handle to thresholdSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
end

% --- Executes on button press in restoreButton.
function restoreButton_Callback(hObject, eventdata, handles)
% hObject    handle to restoreButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
question = 'Restore original data?';
option1 = 'Yes';
option2 = 'No';
saveChoice = questdlg(question,option1,option2);
switch saveChoice
    case 'Yes'
        handles.trode = handles.originalTrode;
    case 'No'
        return;
end
% reset values
guidata(hObject,handles);
%initialize the trodesMenu
trodesMenu_Initialize(hObject, eventdata, handles);

% fill up the clusters panel
clusterListPanel_Initialize(hObject, eventdata, handles);

% now update the axes
updateAllAxes(hObject, eventdata, handles);

end

% --- Executes on button press in mergePushButton.
function mergePushButton_Callback(hObject, eventdata, handles)
% hObject    handle to mergePushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clusterVisibilityValues = [];
clusterSelectionStrings = get(get(handles.clusterListPanel,'Children'),'String');
clusterVisibilityValuesUnordered = get(get(handles.clusterListPanel,'Children'),'Value');
for i = 1:length(handles.trode.spikeRankedCluster)
    index = find(strcmp(clusterSelectionStrings,sprintf('%d',handles.trode.spikeRankedCluster(i))));
    clusterVisibilityValues(i) = clusterVisibilityValuesUnordered{index};
end

if all(~clusterVisibilityValues)
    noClusterError = errordlg('no clusters selected for merging','no cluster error');
    return;
end

whichClusters = find(clusterVisibilityValues);
mergedClusterNumber = min(handles.trode.spikeRankedCluster(whichClusters));
handles.trode.spikeAssignedCluster(ismember(handles.trode.spikeAssignedCluster,...
    handles.trode.spikeRankedCluster(whichClusters))) = mergedClusterNumber;
handles.trode.spikeRankedCluster(ismember(handles.trode.spikeRankedCluster,...
    handles.trode.spikeRankedCluster(whichClusters))&(handles.trode.spikeRankedCluster~=mergedClusterNumber)) = [];

% ##zzz sets previously visible NOTE: SETS TO INDEX NOT VALUE
handles.previouslyVisible = find(handles.trode.spikeRankedCluster == mergedClusterNumber);
disp(handles.previouslyVisible)

guidata(hObject,handles);
% fill up the clusters panel
%clusterListPanel_Initialize(hObject, eventdata, handles);

% only shows merged cluster.
clusterListPanel_Initialize(hObject, eventdata, handles);

% now update the axes
updateAllAxes(hObject, eventdata, handles);
end

% --- Executes on button press in splitPushButton.
function splitPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to splitPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check if there is only one cluster visible. else warn.

clusterVisibilityValues = getClusterVisibilityValues(handles,handles.trode.spikeRankedCluster);
if length(find(clusterVisibilityValues))~=1
    h = warndlg('Exactly one cluster should be visible'); uiwait(h);
    return
end
whichCluster = handles.trode.spikeRankedCluster(find(clusterVisibilityValues));

viewPosition = get(handles.featureAxis,'CameraPosition');
viewAngle = get(handles.featureAxis,'CameraViewAngle');
viewPosition = viewPosition/norm(viewPosition);
% get the feature values
switch length(size(handles.trode.spikeWaveForms))
    case 2
        [featuresAll, nDim] = useFeatures(handles.trode.spikeWaveForms,...
            handles.trode.spikeModel.featureList,...
            handles.trode.spikeModel.featureDetails);
    case 3
        sizWvFrm = size(handles.trode.spikeWaveForms)
        [featuresAll, nDim] = useFeatures(...
            reshape(handles.trode.spikeWaveForms,sizWvFrm(1),sizWvFrm(2)*sizWvFrm(3)),...
            handles.trode.spikeModel.featureList,...
            handles.trode.spikeModel.featureDetails);
end

% filter original record to get only relevant spikes
whichSpikes = ismember(handles.trode.spikeAssignedCluster,whichCluster);
featuresAll = featuresAll(whichSpikes,:);
whichAssignedClusters = handles.trode.spikeAssignedCluster(whichSpikes);

% we are using only features (1,2,and 3)
featureNumbers = [1 2 3];
featuresUsed = featuresAll(:,featureNumbers);
% now project features onto the viewAngle vector
featuresProjectedBeforeRotation = featuresUsed*null(viewPosition);

% now rotate according to the camera view Angle????
featuresProjected(:,1) = featuresProjectedBeforeRotation(:,1)*cos(viewAngle)-featuresProjectedBeforeRotation(:,2)*sin(viewAngle);
featuresProjected(:,2) = featuresProjectedBeforeRotation(:,2)*cos(viewAngle)+featuresProjectedBeforeRotation(:,1)*sin(viewAngle);

clusterColorValues = getClusterColorValues(handles,handles.trode.spikeRankedCluster);
colors = clusterColorValues(find(clusterVisibilityValues),:);
splitFigure = figure('Name','Place an ellipse to split the cluster');
featAxis = axes;
plot(featuresProjected(:,1),featuresProjected(:,2),'.','color',colors);hold on;
% create an imellipse object
regionOfInterest = imellipse(featAxis); wait(regionOfInterest);
posn = getPosition(regionOfInterest);
delete(regionOfInterest);
delete(splitFigure); % everything necessary is done!
a = posn(3)/2; b = posn(4)/2; cenX = posn(1)+a; cenY = posn(2)+b;

% move coordinates to center of ellipse
featShifted = [featuresProjected(:,1)-cenX featuresProjected(:,2)-cenY];
[theta, rho] = cart2pol(featShifted(:,1),featShifted(:,2));
whichIn = (rho<(a*b)./sqrt(((b^2*cos(theta).^2)+(a^2*sin(theta).^2))));

if 0 % for verification only
    figure; polar(theta,rho,'.');
    thetaPrime = 0:0.01:2*pi
    rhoPrime = (a*b)./sqrt(((b^2*cos(thetaPrime).^2)+(a^2*sin(thetaPrime).^2)));
    hold on;
    polar(thetaPrime,rhoPrime)
    polar(theta(whichIn),rho(whichIn),'r.');
end

% deal with the original records.
newClusterNum = max(handles.trode.spikeRankedCluster)+1;
handles.trode.spikeRankedCluster(end+1) = newClusterNum;
% now the assignedClusters. Ones not in the selected region get the new number
whichAssignedClusters(~whichIn) = newClusterNum;
handles.trode.spikeAssignedCluster(whichSpikes)=whichAssignedClusters;

% ##zzz sets previously visible NOTE: SETS TO INDEX NOT VALUE
handles.previouslyVisible = find(handles.trode.spikeRankedCluster == whichCluster);
handles.previouslyVisible(end+1) = find(handles.trode.spikeRankedCluster == newClusterNum);
disp(handles.previouslyVisible)

% update the records
guidata(hObject,handles);

% update cluster list panel
%clusterListPanel_Initialize(hObject, eventdata, handles);

% ##zzz Instad of clusterListPanel_Initialize, run different initialize that
% only shows two split clusters.
clusterListPanel_Initialize(hObject, eventdata, handles);

% update Axes
updateAllAxes(hObject, eventdata, handles);

end

% --- Executes on mouse press over axes background.
function hist10MSAxis_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to hist10MSAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
whichTrode = handles.trode;
spikes =  whichTrode.spikeEvents;
spikeWaveForms =  whichTrode.waveformsToCluster;
assignedClusters =  whichTrode.spikeAssignedCluster;
spikeTimestamps = whichTrode.spikeTimeStamps;
rankedClustersCell = whichTrode.spikeRankedCluster;

% now check if worth plotting
if isempty(spikes)
    text(0.5,0.5,sprintf('no spikes in %s',whichTrode),'HorizontalAlignment','center','VerticalAlignment','middle');
    return
end

% sometimes rankedClusters is a Cell array. Just
if iscell(rankedClustersCell) %(happens when we call after sorting on every chunk)
    rankedClusters = [];
    for i = 1:length(rankedClustersCell)
        rankedClusters = unique([rankedClusters;makerow(rankedClustersCell{i})']);
    end
else
    rankedClusters = rankedClustersCell;
end


% select the axis
axes(handles.hist10MSAxis); cla; hold on;

% set the colors
colors = [0 0 0]; %blk

clusterVisibilityValues = [];
clusterSelectionStrings = get(get(handles.clusterListPanel,'Children'),'String');
clusterVisibilityValuesUnordered = get(get(handles.clusterListPanel,'Children'),'Value');
for i = 1:length(rankedClusters)
    %     if length(rankedClusters)~=1
    index = find(strcmp(clusterSelectionStrings,sprintf('%d',rankedClusters(i))));
    clusterVisibilityValues(i) = clusterVisibilityValuesUnordered{index};
    %     else
    %         clusterVisibilityValues = clusterVisibilityValuesUnordered;
    %     end
end


%inter-spike interval distribution
existISILess10MS = false;
maxEdgePart = 0;
maxProbPart = 0;
% for other spikes
whichClusters = find(clusterVisibilityValues);
whichSpikes = ismember(assignedClusters,rankedClusters(whichClusters));
whichSpikeTimeStamps = spikeTimestamps(whichSpikes);
ISIMergedCluster = diff(whichSpikeTimeStamps*1000);

edges = linspace(0,10,100);
count=histc(ISIMergedCluster,edges);
if sum(count)>0
    existISILess10MS = true;
    prob=count/sum(count);
    ISIfill = fill([edges(1); edges(:); edges(end)],[0; prob(:); 0],colors);
    set(ISIfill,'edgeAlpha',0,'faceAlpha',.5);
    maxEdgePart = max(maxEdgePart,max(edges));
    maxProbPart = max(maxProbPart,max(prob));
end
if existISILess10MS
    axis([0 maxEdgePart 0 maxProbPart]);
    text(maxEdgePart/2,maxProbPart,'ISI<10ms','HorizontalAlignment','center','VerticalAlignment','Top')
    lockout=1000*39/handles.trode.detectParams.samplingFreq;
    lockout=edges(max(find(edges<=lockout)));
    plot([lockout lockout],get(gca,'YLim'),'k') %
    plot([2 2], get(gca,'YLim'),'k--')
else
    axis([0 10 0 1]);
    text(10,1,'no ISI < 10 ms','HorizontalAlignment','right','VerticalAlignment','Top');
end
% uiwait(handles.inspectGUIFig);
h = warndlg('Press OK to continue'); uiwait(h);
hist10MSAxis_UpdateFcn(hObject, eventdata, handles);
end

% --- Executes on button press in processedClusterButton.
function processedClusterButton_Callback(hObject, eventdata, handles)
% hObject    handle to processedClusterButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whichTrode = handles.currTrode;
rankedClustersCell = whichTrode.spikeRankedCluster;
assignedClusters =  whichTrode.spikeAssignedCluster;


% sometimes rankedClusters is a Cell array. Just
if iscell(rankedClustersCell) %(happens when we call after sorting on every chunk)
    rankedClusters = [];
    for i = 1:length(rankedClustersCell)
        rankedClusters = unique([rankedClusters;makerow(rankedClustersCell{i})']);
    end
else
    rankedClusters = rankedClustersCell;
end

clusterVisibilityValues = [];
clusterSelectionStrings = get(get(handles.clusterListPanel,'Children'),'String');
clusterVisibilityValuesUnordered = get(get(handles.clusterListPanel,'Children'),'Value');
if iscell(clusterVisibilityValuesUnordered)
    for i = 1:length(rankedClusters)
        index = find(strcmp(clusterSelectionStrings,sprintf('%d',rankedClusters(i))));
        clusterVisibilityValues(i) = clusterVisibilityValuesUnordered{index};
    end
else
    clusterVisibilityValues = clusterVisibilityValuesUnordered;
end

if all(~clusterVisibilityValues)
    noClusterError = errordlg('no clusters selected for merging','no cluster error');
    return;
end

whichClusters = find(clusterVisibilityValues);
processedClusters =  ismember(assignedClusters,rankedClusters(whichClusters));

handles.currentSpikeRecord.(whichTrode).processedClusters=processedClusters;
guidata(hObject,handles);
end


function assignnoise_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to mergePushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clusterVisibilityValues = getClusterVisibilityValues(handles,handles.trode.spikeRankedCluster);

if all(~clusterVisibilityValues)
    noClusterError = errordlg('no clusters selected for assigning to noise','no cluster error');
    return;
end

whichClusters = find(clusterVisibilityValues);
mergedClusterNumber = 1; % this is the default noise cluster number
handles.trode.spikeAssignedCluster(ismember(handles.trode.spikeAssignedCluster,...
    handles.trode.spikeRankedCluster(whichClusters))) = mergedClusterNumber;
handles.trode.spikeRankedCluster(ismember(handles.trode.spikeRankedCluster,...
    handles.trode.spikeRankedCluster(whichClusters))&(handles.trode.spikeRankedCluster~=mergedClusterNumber)) = [];

% ##zzz sets previously visible NOTE: SETS TO INDEX NOT VALUE
handles.previouslyVisible = find(handles.trode.spikeRankedCluster == mergedClusterNumber);
disp(handles.previouslyVisible)

guidata(hObject,handles);
% fill up the clusters panel
%clusterListPanel_Initialize(hObject, eventdata, handles);

% only shows merged cluster.
clusterListPanel_Initialize(hObject, eventdata, handles);

% now update the axes
updateAllAxes(hObject, eventdata, handles);end

function processCluster_ButtonDownFcn(hObject, eventdata, handles)
disp('processing');
clusterVisibilityValues = getClusterVisibilityValues(handles,handles.trode.spikeRankedCluster);

if length(find(clusterVisibilityValues))~=1
    h = warndlg('Exactly one cluster should be visible'); uiwait(h);
    return
end

clusterNumber = handles.trode.spikeRankedCluster(logical(clusterVisibilityValues));

% create the single unit
unitChans = handles.trode.chans;
unitID = handles.trode.numUnits+1;

whichSpikes = handles.trode.spikeAssignedCluster==clusterNumber;
sU = singleUnit(unitChans,...
    unitID,...
    handles.trode.spikeEvents(whichSpikes),...
    handles.trode.spikeTimeStamps(whichSpikes),...
    handles.trode.spikeWaveForms(whichSpikes,:,:),...
    handles.trode.detectParams.samplingFreq);

handles.trode = handles.trode.addUnit(sU);

handles.trode.spikeEvents(whichSpikes) = [];
handles.trode.spikeWaveForms(whichSpikes,:,:) = [];
handles.trode.spikeTimeStamps(whichSpikes) = [];
handles.trode.spikeAssignedCluster(whichSpikes) = [];
handles.trode.spikeRankedCluster(handles.trode.spikeRankedCluster==clusterNumber) = [];

handles.previouslyVisible = []; % default to viewing nothing
disp(handles.previouslyVisible)

guidata(hObject,handles);
% fill up the clusters panel
%clusterListPanel_Initialize(hObject, eventdata, handles);

% only shows merged cluster.
clusterListPanel_Initialize(hObject, eventdata, handles);

% now update the axes
updateAllAxes(hObject, eventdata, handles);

end


%% HELPER FUNCTIONS
function x = makerow(x)
%y = makerow(x)

x = squeeze(x);
if(size(x,2) == 1)
    x = x';
end
end
function position = arrangeInSpace(n,order,border)
if ~exist('border','var') || isempty(border)
    border = 0.02;
end

if ~exist('order','var')||isempty(order)
    order = 'rowThenColumn';
end

availableSpace = [1-2*border 1-2*border];
arrangement = [5,ceil(n/5)];

% create the numbering
numbering = nan(arrangement(1),arrangement(2));
position = nan(n,2);
switch order
    case 'rowThenColumn'
        for col=1:arrangement(2)
            numbering(:,col) = (col-1)*arrangement(1)+(1:arrangement(1));
        end
    case 'columnThenRow'
        for row=1:arrangement(1)
            numbering(row,:) = (row-1)*arrangement(2)+(1:arrangement(2));
        end
    otherwise
        error('unknown order');
end

eachRowSize = availableSpace(1)/arrangement(1);
eachColSize = availableSpace(2)/arrangement(2);

for i = 1:n
    [yPos,xPos] = find(numbering==i);
    position(i,:) = [((xPos-1)*eachColSize) 1-((yPos-1)*eachRowSize)];
end
end

function clusterVisibilityValues = getClusterVisibilityValues(handles,rankedClusters)
clusterVisibilityValues = [];
clusterSelectionStrings = get(get(handles.clusterListPanel,'Children'),'String');
clusterVisibilityValuesUnordered = get(get(handles.clusterListPanel,'Children'),'Value');
for i = 1:length(rankedClusters)
    index = find(strcmp(clusterSelectionStrings,sprintf('%d',rankedClusters(i))));
    clusterVisibilityValues(i) = clusterVisibilityValuesUnordered{index};
    
end
end


function clusterColorValues = getClusterColorValues(handles,rankedClusters)
clusterColorValues = nan(length(rankedClusters),3);
clusterSelectionStrings = get(get(handles.clusterListPanel,'Children'),'String');
clusterColorValuesUnordered = get(get(handles.clusterListPanel,'Children'),'ForeGroundColor');
for i = 1:length(rankedClusters)
    index = find(strcmp(clusterSelectionStrings,sprintf('%d',rankedClusters(i))));
    clusterColorValues(i,:) = clusterColorValuesUnordered{index};
    
end

end
