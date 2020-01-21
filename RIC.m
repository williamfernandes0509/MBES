function varargout = RIC(varargin)
% RIC MATLAB code for RIC.fig / modified on 11/12/2019
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RIC_OpeningFcn, ...
                   'gui_OutputFcn',  @RIC_OutputFcn, ...
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
% End initialization code - DO NOT EDIT

% --- Executes just before RIC is made visible.
function RIC_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RIC (see VARARGIN)
% warning('off')
ch=0;rd=0;pr=0;
av=0;nb=0;Pmx=0;
swath=0;fileLoc=[];
locall=[];LoF=[];
folder_name=[];
% Choose default command line output for RIC
handles.output = hObject;
handles.ch=ch;
handles.rd=rd;
handles.pr=pr;
handles.av=av;
handles.nb=nb;
handles.Pmx=Pmx;
handles.LoF=LoF;
handles.swath=swath;
handles.locall=locall;
handles.fileLoc=fileLoc;
handles.folder_name=folder_name;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes RIC wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = RIC_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pb1.
function pb1_Callback(hObject, eventdata, handles)
clc
fclose('all');
delete('*MB.all');
delete('*.txt');
set(handles.ed1,'String','');
set(handles.rb1,'Value',0);
set(handles.rb2,'Value',0);
LoF=handles.LoF;
ch=handles.ch;
folder_name = uigetdir;     
if folder_name ~= 0
    [drec,name] = fileparts(folder_name);
    fileLoc=[drec,'\',name];
    locall=[fileLoc,'\*.all'];
    files= dir(locall);
    for i = 1:length(files)      
        if files(i).isdir==0
            LoF{end+1,1} = files(i).name;
        end
    end
    set(handles.lb1,'String',LoF)    
    set(handles.txt2,'String',name)     
    set(handles.txt4,'String',num2str(length(files)))
    set(handles.txt11, 'String', 'Idle');
    handles.ch=ch;
    handles.LoF=LoF;
    handles.folder_name=folder_name;
    handles.files=files;
    handles.fileLoc=fileLoc;
    handles.locall=locall;
    guidata(hObject, handles);
else
    if isempty(LoF)
        msgbox('Please select data folder..','Error','error');
    end
end

% --- Executes on selection change in lb1.
function lb1_Callback(hObject, eventdata, handles)
clc
set(handles.rb1,'Value',0);
set(handles.rb2,'Value',0);
set(handles.ed1,'String','');
set(handles.txt8,'String','');
set(handles.txt13, 'String', '');
set(handles.txt14, 'String', '');
set(handles.txt16, 'String', '');
set(handles.txt17, 'String', '');
set(handles.txt19, 'String', '');
set(handles.txt21, 'String', '');
set(handles.lb2, 'String', '');
delete('*MB.all');delete('*.txt');
axes(handles.axes1);cla reset;
axes(handles.axes2);cla reset;
axes(handles.axes3);cla reset;
folder_name=handles.folder_name;
fileLoc=handles.fileLoc;
lb_Items = cellstr(get(handles.lb1,'String'));
set(handles.txt4,'String',num2str(length(lb_Items)))
Ifile = lb_Items{get(handles.lb1,'Value')};
set(handles.txt6,'String',Ifile);
pause(0.001)
%------Inspect/Process------
ch=0;
choice = questdlg('Would you like to inspect or process?', ...
	'Inspect/Clean', ...
	'Inspect','Process','Cancel','Cancel');
% Handle response
switch choice
    case 'Inspect'
        set(handles.txt11, 'String', 'Processing...');
        delete('*.txt');
        %-----extractIdt.m------
        b=dir(Ifile);size=b.bytes;
        for i=1:length(Ifile)
            if strcmp({Ifile(i)},'.') == 1
                break;      
            end
        end
        chr = char({Ifile(1:i-1)});
        Itxt = [chr '.txt'];
        Atxt = [chr '_AVG.txt'];
        Btxt = [chr '_BN.txt'];
        Ptxt = [chr '_PD.txt'];
        Rtxt=[chr '_Rfit.txt'];
        ARD=zeros(111,1);
        DPR=zeros(111,1);
        DIF=zeros(111,1);
        AVD=zeros(111,1);
        CON=zeros(111,1);
        CAS=zeros(111,1);
        BMS=zeros(111,1);
        fr=fopen(Rtxt,'w');
        fp=fopen(Ptxt,'w');
        fg=fopen(Atxt,'w');
        fa=fopen(Itxt,'w');
        fn=fopen(Btxt,'w');
        fi=fopen(Ifile,'rb');
        n=0;sm=0;fw=0;lat=0;lon=0;D68=0;
        while ~feof(fi)
            by=fread(fi,1,'uint32=>int');
            pos=ftell(fi);
            id=fread(fi,1,'uint8=>int');
            ty=fread(fi,1,'uint8=>int');
            mo=fread(fi,1,'uint16=>int');
            da=fread(fi,1,'uint32=>int');
            ti=fread(fi,1,'uint32=>int');
            switch ty
                case 80
                    fread(fi,4,'uint8=>int');
                    lat=fread(fi,1,'int32=>float');lat=lat/20000000;
                    lon=fread(fi,1,'int32=>float');lon=lon/10000000;
                    pos=pos+by;
                    STAT =fseek(fi,pos,'bof');
                case 68
                    D68=D68+1;
                    fread(fi,11,'uint8=>int');
                    VLDBMS=fread(fi,1,'uint8=>int');fprintf(fn,'%d\n',VLDBMS);
                    fread(fi,4,'uint8=>int');
                    for i=1:VLDBMS
                        ARD(i,1)=fread(fi,1,'int16=>float');
                        y(i,1)=fread(fi,1,'int16=>float');
                        ly(i,1)=(y(i,1)/(100000*1.852*60))+lon;
                        x(i,1)=fread(fi,1,'int16=>float');
                        lx(i,1)=(x(i,1)/(100000*1.852*60))+lat;
                        DPR(i,1)=fread(fi,1,'int16=>float');
                        CON(i,1)=CON(i,1)+1;
                        if lx(i,1) > 1 && ly(i,1) > 1
                            fprintf(fp,'%0.8f %0.8f -%0.2f\n',ly(i,1),lx(i,1),ARD(i,1)/100);
                        end
                        fread(fi,8,'uint8=>int');
                    end
                    if VLDBMS < 56
                        CON(i,1)=CON(i,1)-1;
                    else    
                        FLAG=0;CTR=0;
                        for i=1:VLDBMS
                            if i < VLDBMS-1
                                A1=9000-DPR(i,1);
                                A2=9000-DPR(i+1,1);
                            end
                            if A2 > A1 && FLAG == 0
                                CTR=i;FLAG=1;
                            end
                        end
                        for i=1:VLDBMS
                            if i < CTR
                                INC(i,1)=DPR(i,1)-9000;
                                fprintf(fa,'%d %0.2f -%0.2f\n',i,INC(i,1)/100,ARD(i,1)/100);
                            else
                                INC(i,1)=9000-DPR(i,1);
                                fprintf(fa,'%d %0.2f -%0.2f\n',i,INC(i,1)/100,ARD(i,1)/100);
                            end
                        end
                        ps=0;ng=0;per=0;cent=0;
                        for i=1:VLDBMS
                            DIF(i,1)=(ARD(CTR,1)-ARD(i,1))+DIF(i,1);
                            CAS(i,1)=ARD(CTR,1)-ARD(i,1);
                            if CAS(i,1) >= 0
                                ps=ps+1;
                            else
                                ng=ng+1;
                            end
                        end
                        per=(ps*100/VLDBMS);cent=(ng*100/VLDBMS);
                        if per > cent
                            cs=1;
                        else
                            cs=2;
                        end
                    end
                    pos=pos+by;
                    STAT =fseek(fi,pos,'bof');
                case {48, 49, 65, 66, 67, 69, 70, 71, 72, 73, 74, 78, 82, 83, 84, 85, 87, 88, 89, 104, 102}
                    pos=pos+by;
                    STAT =fseek(fi,pos,'bof');
                case 105    
                    if D68 > 0
                        for i=1:111
                            AVG(i,1)=round(DIF(i,1)/CON(i,1));BMS(i,1)=i;
                            fprintf(fg,'%d %0.2f %0.2f\n',i,INC(i,1)/100,AVG(i,1)/100);
                        end
                        linearCoefficients = polyfit(BMS, AVG, 1);
                        xFit = linspace(1, 111, 111)';
                        yFit = polyval(linearCoefficients, xFit);
                        for i=1:111
                            fprintf(fr,'%d %0.2f\n',xFit(i,1),yFit(i,1)/100);
                        end
                        fclose(fr);fclose(fa);fclose(fn);fclose(fg);fclose(fp);
                        ch=1;
                    else
                        ch=0;
%                         msgbox('No Depth Data Exist','Error','error');
                    end
                    pos=pos+by;
                    STAT =fseek(fi,pos,'bof');%break;    
                otherwise
                    disp(['TY: ',num2str(ty),' Unknown Type'])
                    pause
            end
            stus=round(pos*100/size);
            Rstr=['Reading ',num2str(stus),'%/100%'];
            set(handles.txt11, 'String', Rstr);
            pause(0.001)
            if pos == size
                break;
            end       
        end
        fclose(fi);fclose('all');
        %------------
    case 'Process'
        set(handles.txt11, 'String', 'Processing...');
        delete('*MB.all');delete('*.txt');
        %-----extractRdt.m------
        set(handles.pb4,'userdata',0);
        b=dir(Ifile);size=b.bytes;
        for i=1:length(Ifile)
            if strcmp({Ifile(i)},'.') == 1
                break;      
            end
        end
        chr = char({Ifile(1:i-1)});
        Itxt = [chr '.txt'];
        Atxt = [chr '_AVG.txt'];
        Otxt = [chr '_MB.txt'];
        Btxt = [chr '_BN.txt'];
        Ofile=[chr '_MB.all'];
        Ptxt = [chr '_PD.txt'];
        Mtxt = [chr '_MD.txt'];
        Rtxt=[chr '_Rfit.txt'];
        Stxt=[chr '_Stat.txt'];
        ARD=zeros(111,1);
        DPR=zeros(111,1);
        DIF=zeros(111,1);
        AVD=zeros(111,1);
        AVG=zeros(111,1);
        CON=zeros(111,1);
        CAS=zeros(111,1);
        BMS=zeros(111,1);
        xFit=zeros(111,1);
        yFit=zeros(111,1);
        fm=fopen(Mtxt,'w');
        fs=fopen(Stxt,'w');
        fr=fopen(Rtxt,'w');
        fp=fopen(Ptxt,'w');
        fg=fopen(Atxt,'w');
        fa=fopen(Itxt,'w');
        fb=fopen(Otxt,'w');
        fn=fopen(Btxt,'w');
        fi=fopen(Ifile,'rb');n=0;sm=0;fw=0;lat=0;lon=0;D68=0;
        fo=fopen(Ofile,'wb');RD=0;CD=0;AV=0;DV=0;AG=0;qty=0;
        while ~feof(fi)
            by=fread(fi,1,'uint32=>int');
            pos=ftell(fi);
            id=fread(fi,1,'uint8=>int');
            ty=fread(fi,1,'uint8=>int');
            mo=fread(fi,1,'uint16=>int');
            da=fread(fi,1,'uint32=>int');
            ti=fread(fi,1,'uint32=>int');
            switch ty
                case 80
                    fread(fi,4,'uint8=>int');
                    lat=fread(fi,1,'int32=>float');lat=lat/20000000;
                    lon=fread(fi,1,'int32=>float');lon=lon/10000000;
                    pos=pos+by;
                    STAT =fseek(fi,pos,'bof');
                case 68
                    D68=D68+1;fread(fi,11,'uint8=>int');
                    VLDBMS=fread(fi,1,'uint8=>int');fprintf(fn,'%d\n',VLDBMS);
                    fread(fi,4,'uint8=>int');
                    for i=1:VLDBMS
                        ARD(i,1)=fread(fi,1,'int16=>float');
                        y(i,1)=fread(fi,1,'int16=>float');
                        ly(i,1)=(y(i,1)/(100000*1.852*60))+lon;
                        x(i,1)=fread(fi,1,'int16=>float');
                        lx(i,1)=(x(i,1)/(100000*1.852*60))+lat;
                        DPR(i,1)=fread(fi,1,'int16=>float');
                        CON(i,1)=CON(i,1)+1;
                        fread(fi,8,'uint8=>int');
                        if lx(i,1) > 1 && ly(i,1) > 1
                            fprintf(fp,'%0.8f %0.8f -%0.2f\n',ly(i,1),lx(i,1),ARD(i,1)/100);
                        end
                    end
                    if VLDBMS < 56
                        disp('OUT')
                        CON(i,1)=CON(i,1)-1;
                    else    
                        FLAG=0;CTR=0;
                        for i=1:VLDBMS
                            if i < VLDBMS-1
                                A1=9000-DPR(i,1);
                                A2=9000-DPR(i+1,1);
                            end
                            if A2 > A1 && FLAG == 0
                                CTR=i;FLAG=1;
                            end
                        end
                        for i=1:VLDBMS
                            if i < CTR
                                INC(i,1)=DPR(i,1)-9000;
                                fprintf(fa,'%d %0.2f -%0.2f\n',i,INC(i,1)/100,ARD(i,1)/100);
                            else
                                INC(i,1)=9000-DPR(i,1);
                                fprintf(fa,'%d %0.2f -%0.2f\n',i,INC(i,1)/100,ARD(i,1)/100);
                            end
                        end
                        ps=0;ng=0;per=0;cent=0;
                        for i=1:VLDBMS
                            DIF(i,1)=(ARD(CTR,1)-ARD(i,1))+DIF(i,1);
                            CAS(i,1)=ARD(CTR,1)-ARD(i,1);
                            if CAS(i,1) >= 0
                                ps=ps+1;
                            else
                                ng=ng+1;
                            end
                        end
                        per=(ps*100/VLDBMS);cent=(ng*100/VLDBMS);
                        if per > cent
                            cs=1;
                        else
                            cs=2;
                        end
                    end
                    pos=pos+by;
                    STAT =fseek(fi,pos,'bof');
                case {48, 49, 65, 66, 67, 69, 70, 71, 72, 73, 74, 78, 82, 83, 84, 85, 87, 88, 89, 104, 102}
                    pos=pos+by;
                    STAT =fseek(fi,pos,'bof');
                case 105
                    if D68 > 0
                        for i=1:111
                            AVG(i,1)=round(DIF(i,1)/CON(i,1));BMS(i,1)=i;
                            fprintf(fg,'%d %0.2f %0.2f\n',i,INC(i,1)/100,AVG(i,1)/100);
                        end
                        linearCoefficients = polyfit(BMS, AVG, 1);
                        xFit = linspace(1, 111, 111)';
                        yFit = polyval(linearCoefficients, xFit);
                        for i=1:111
                            fprintf(fr,'%d %0.2f\n',xFit(i,1),yFit(i,1)/100);
                        end
                        fclose(fr);fclose(fa);fclose(fn);fclose(fg);fclose(fp);
                        ch=2;
                    else
                        ch=0;
%                         msgbox('No Depth Data Exist','Error','error');
                    end
                    pos=pos+by;
                    STAT =fseek(fi,pos,'bof');    
                otherwise
                    disp(['TY: ',num2str(ty),' Unknown Type'])
                    pause
            end
            stus=round(pos*100/size);
            Rstr=['Reading ',num2str(stus),'%/100%'];
            set(handles.txt11, 'String', Rstr);
            pause(0.001)
            if pos == size
                break;
            end 
            clc
        end
        if pos == size
            frewind(fi);
            pos=ftell(fi);byte=pos;ping=0;
            while pos < size 
                by=fread(fi,1,'uint32');fwrite(fo,by,'uint32');
                pos=ftell(fi);
                id=fread(fi,1,'uint8');fwrite(fo,id,'uint8');
                ty=fread(fi,1,'uint8');fwrite(fo,ty,'uint8');
                mo=fread(fi,1,'uint16');fwrite(fo,mo,'uint16');
                da=fread(fi,1,'uint32');fwrite(fo,da,'uint32');
                ti=fread(fi,1,'uint32');fwrite(fo,ti,'uint32');
                clear bn sp
                switch ty
                    case 80
                        pc=fread(fi,1,'uint16=>int');fwrite(fo,pc,'uint16');
                        sr=fread(fi,1,'uint16=>int');fwrite(fo,sr,'uint16');
                        lat=fread(fi,1,'int32=>float');fwrite(fo,lat,'int32');lat=lat/20000000;
                        lon=fread(fi,1,'int32=>float');fwrite(fo,lon,'int32');lon=lon/10000000;
                        fp=ftell(fi);byte=fp-pos;
                        while byte < by
                            c=fread(fi,1,'uint8');fwrite(fo,c,'uint8');
                            fp=ftell(fi);byte=fp-pos;
                            if byte == by
                                break;
                            end
                        end
                        pos=pos+by;
                        STAT =fseek(fi,pos,'bof');
                    case 68
                        ARD=zeros(111,1);Ht=zeros(111,1);ping=ping+1;
                        pg=fread(fi,1,'uint16');fwrite(fo,pg,'uint16');
                        sr=fread(fi,1,'uint16');fwrite(fo,sr,'uint16');
                        hd=fread(fi,1,'uint16');fwrite(fo,hd,'uint16');
                        sp=fread(fi,1,'uint16');fwrite(fo,sp,'uint16');
                        wl=fread(fi,1,'uint16');fwrite(fo,wl,'uint16');
                        mb=fread(fi,1,'uint8');fwrite(fo,mb,'uint8');
                        nv=fread(fi,1,'uint8');fwrite(fo,nv,'uint8');
                        zr=fread(fi,1,'uint8');fwrite(fo,zr,'uint8');
                        xy=fread(fi,1,'uint8');fwrite(fo,xy,'uint8');
                        sr=fread(fi,1,'uint16');fwrite(fo,sr,'uint16');
                        fp=ftell(fi);
                        for i=1:nv
                            dp(i,1)=fread(fi,1,'int16=>float');
                            ARD(i,1)=dp(i,1)+AVG(i,1);
                            fread(fi,4,'uint8');
                            dpr(i,1)=fread(fi,1,'int16=>float');
                            fread(fi,8,'uint8');
                        end
                        [ dm, am, at,rsd, csd ] = SER( nv, ARD, DPR, dp, chr, ping, yFit);
                        RSD(ping,1)=rsd;CSD(ping,1)=csd;AMG(ping,1)=am;DMG(ping,1)=dm;
                        fseek(fi,fp,'bof');
                        for i=1:nv
                            fread(fi,1,'int16=>float');fwrite(fo,at(i,1),'int16');    
                            ay=fread(fi,1,'int16');fwrite(fo,ay,'int16');
                            ax=fread(fi,1,'int16');fwrite(fo,ax,'int16');
                            y(i,1)=ay;ly(i,1)=(y(i,1)/(100000*1.852*60))+lon;
                            x(i,1)=ax;lx(i,1)=(x(i,1)/(100000*1.852*60))+lat;
                            bd=fread(fi,1,'int16=>float');fwrite(fo,bd,'int16');
                            ba=fread(fi,1,'uint16');fwrite(fo,ba,'uint16');
                            rg=fread(fi,1,'uint16');fwrite(fo,rg,'uint16');
                            qf=fread(fi,1,'uint8');fwrite(fo,qf,'uint8');
                            dw=fread(fi,1,'uint8');fwrite(fo,dw,'uint8');
                            rf=fread(fi,1,'int8');fwrite(fo,rf,'int8');
                            bn=fread(fi,1,'uint8');fwrite(fo,bn,'uint8');
                            if lx(i,1) > 1 && ly(i,1) > 1
                                fprintf(fm,'%0.8f %0.8f -%0.2f\n',ly(i,1),lx(i,1),at(i,1)/100);
                            end
                        end
                        if nv < 56
                            CON(i,1)=CON(i,1)-1;
                        else    
                            FLAG=0;CTR=0;
                            for i=1:nv
                                if i < nv-1
                                    A1=9000-DPR(i,1);
                                    A2=9000-DPR(i+1,1);
                                end
                                if A2 > A1 && FLAG == 0
                                    CTR=i;FLAG=1;
                                end
                            end
                            for i=1:nv
                                if i < CTR
                                    INC(i,1)=DPR(i,1)-9000;
                                    fprintf(fb,'%d %0.2f -%0.2f\n',i,INC(i,1)/100,at(i,1)/100);
                                else
                                    INC(i,1)=9000-DPR(i,1);
                                    fprintf(fb,'%d %0.2f -%0.2f\n',i,INC(i,1)/100,at(i,1)/100);
                                end
                            end
                        end
                        td=fread(fi,1,'int8');fwrite(fo,td,'int8');
                        ed=fread(fi,1,'uint8');fwrite(fo,ed,'uint8');
                        cks=fread(fi,1,'uint16');fwrite(fo,cks,'uint16');
                    case {48, 49, 65, 66, 67, 69, 70, 71, 72, 73, 74, 78, 82, 83, 84, 85, 87, 88, 89, 104, 102}
                        fp=ftell(fi);byte=fp-pos;
                        while byte < by
                            c=fread(fi,1,'uint8');fwrite(fo,c,'uint8');
                            fp=ftell(fi);byte=fp-pos;
                            if byte == by
                                break;
                            end
                        end
                    case 105
                        fp=ftell(fi);byte=fp-pos;
                        while byte < by
                            c=fread(fi,1,'uint8');fwrite(fo,c,'uint8');
                            fp=ftell(fi);byte=fp-pos;
                        end
                        fclose(fo);fclose(fb);
                        if D68 > 0
                            RD=mean(RSD);CD=mean(CSD);AV=mean(AMG)/100;
                            DV=mean(DMG)/100;AG=mean(AVG)/100;AG=AG*2;
                            if AG < 0
                                AG=AG*-1;
                            end
                            qty=((RD-CD)*100/RD);
                            fprintf(fs,'%s: %0.2f %0.2f %0.2f %0.2f ±%0.2f %0.2f\n',Ifile,RD,CD,DV,AV,AG,qty);
                            pause(0.0001)
                        end
                        fclose(fs);
                    otherwise
                        disp(['TY: ',num2str(ty),' Unknown Type'])
                        pause
                end
                pos=ftell(fi);
                stus=round(pos*100/size);
                Wstr=['Writing ',num2str(stus),'%/100%'];
                set(handles.txt11, 'String', Wstr);
                if pos == size
                    break;
                end 
                drawnow
                if get(handles.pb4,'userdata') % stop condition
                    break;
                end
                pause(0.0001)
            end
        end
        fclose(fi);fclose('all');
        %----------------
    case 'Cancel'
        disp('Return to the main GUI window.')
        set(handles.txt11, 'String', 'Idle');
        ch=-1;
end
loctxt=[fileLoc,'\*.txt'];
swath=1;
if ch == 0
    msgbox('No Depth Data Exist','Error','error');
    set(handles.txt11, 'String', 'Idle');
    set(handles.rb1,'Value',0);
    set(handles.rb2,'Value',0);
else
    if ch == 1 
    %--- Inspect File-----
        R=dir(loctxt);
        Lfiles={R.name}';
        m=length(Lfiles);
        Txt=char(Lfiles);
        for j=1:m
            Rtxt=Txt(j,1:length(Txt));
            r=0;
            for i=1:length(Ifile)
                if strcmp({Ifile(i)},{Rtxt(i)}) == 1
                    r=r+1;
                end
            end
            fper(j,1)=r;
        end
        fmx=max(fper);
        for i=1:length(fper)
            if fper(i,1) == fmx
                file=Txt(i,1:length(Txt));
                break;
            end
        end
        Nfile=[file(1:fmx-1) '*.txt'];
        Fnaltxt=[fileLoc,'\',Nfile];
        N=dir(Fnaltxt);
        Nfiles={N.name}';
        Ntxt=char(Nfiles);
        Rtxt=Ntxt(1,1:length(Ntxt));
        Atxt=Ntxt(2,1:length(Ntxt));
        Btxt=Ntxt(3,1:length(Ntxt));
        Ftxt=Ntxt(5,1:length(Ntxt));
    
        rd=load(Rtxt); %---Raw File----
        av=load(Atxt); %---Avg File---
        nb=load(Btxt); %---NB File
        rf=load(Ftxt); %---Fit File
        Pmx=length(nb); % Maximum pings in a file
        if Pmx > 0
            for i=1:nb(1,1)
                NB(i,1)=rd(i,1);
                Dp(i,1)=rd(i,3);
            end
            axes(handles.axes1);
            plot(handles.axes1,NB,Dp,'r','LineWidth',2);grid on;axis tight;YL = ylim;hold on;
            xlabel('Beams','FontWeight','demi','FontSize',10,'FontName','Cambria');
            ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');
            clear m
            set(handles.txt11, 'String', 'Idle');
            set(handles.rb1,'Value',0);
            set(handles.rb2,'Value',1);
            handles.ch=ch;
            handles.rd=rd;
            handles.nb=nb;
            handles.av=av;
            handles.Pmx=Pmx;
            handles.swath=swath;
            handles.Ifile=Ifile;
            handles.fileLoc=fileLoc;
            handles.loctxt=loctxt;
            guidata(hObject, handles);
        end
    end
    if ch == 2
    %--- Process File-----
        R=dir(loctxt);
        Lfiles={R.name}';
        m=length(Lfiles);
        Txt=char(Lfiles);
        for j=1:m
            Rtxt=Txt(j,1:length(Txt));
            r=0;
            for i=1:length(Ifile)
                if strcmp({Ifile(i)},{Rtxt(i)}) == 1
                    r=r+1;
                end
            end
            fper(j,1)=r;
        end
        fmx=max(fper);
        for i=1:length(fper)
            if fper(i,1) == fmx
                file=Txt(i,1:length(Txt));
                break;
            end
        end
        Nfile=[file(1:fmx-1) '*.txt'];
        Mfile=[file(1:fmx-1) '*MB.all'];
        Fnaltxt=[fileLoc,'\',Nfile];
        N=dir(Fnaltxt);
        Nfiles={N.name}';
        Ntxt=char(Nfiles);
        Rtxt=Ntxt(1,1:length(Ntxt));
        Atxt=Ntxt(2,1:length(Ntxt));
        Btxt=Ntxt(3,1:length(Ntxt));
        Ptxt=Ntxt(4,1:length(Ntxt));
        Stxt=Ntxt(8,1:length(Ntxt));
    
        rd=load(Rtxt); %---Raw File----
        av=load(Atxt); %---Avg File---
        pr=load(Ptxt); %---MB File
        nb=load(Btxt); %---NB File
        Pmx=length(nb); % Maximum pings i a file
    
        Bm=zeros(nb(1,1),1);
        Ag=zeros(nb(1,1),1);
        At=zeros(nb(1,1),1);
        for i=1:nb(1,1)
            NB(i,1)=rd(i,1);
            Dp(i,1)=rd(i,3);
            Bm(i,1)=av(i,1);
            Ag(i,1)=av(i,3);
            At(i,1)=pr(i,3);
        end
% -----Plot Raw Depth ------
        axes(handles.axes1);
        plot(handles.axes1,NB,Dp,'r','LineWidth',2);grid on;axis tight;YL = ylim;XL = xlim;hold on;
        xlabel('Beams','FontWeight','demi','FontSize',10,'FontName','Cambria');
        ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');
% -----Plot Offsets ------
        axes(handles.axes2);
        plot(handles.axes2,Bm,Ag,'g','LineWidth',2);grid on;axis tight;hold on;
        xlabel('Beams','FontWeight','demi','FontSize',10,'FontName','Cambria');
        ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');
% -----Plot Proc depth -----
        axes(handles.axes3);
        plot(handles.axes3,NB,At,'b','LineWidth',2);grid on;axis tight;ylim(YL);xlim(XL);
        xlabel('Beams','FontWeight','demi','FontSize',10,'FontName','Cambria');
        ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');
    
        M=dir(fullfile(folder_name, Mfile));
    
        set(handles.rb1,'Value',0);
        set(handles.rb2,'Value',1);
        set(handles.lb2,'String',M.name);
        lb2_Items = cellstr(get(handles.lb2,'String'));
        set(handles.txt8,'String',num2str(length(lb2_Items)));
        set(handles.txt11, 'String', 'Idle');
        clear m
%-------------------
        [~,RSD,CSD,RH,CH,Err,QT] = textread(Stxt,'%s%f%f%f%f%s%f');
        set(handles.txt13, 'String', num2str(RSD));
        set(handles.txt14, 'String', num2str(CSD));
        set(handles.txt16, 'String', num2str(RH));
        set(handles.txt17, 'String', num2str(CH));
        set(handles.txt19, 'String', Err);
        set(handles.txt21, 'String', num2str(QT));
        set(handles.rb1,'Value',0);
        set(handles.rb2,'Value',1);
        handles.ch=ch;
        handles.rd=rd;
        handles.nb=nb;
        handles.pr=pr;
        handles.av=av;
        handles.Pmx=Pmx;
        handles.swath=swath;
        handles.Ifile=Ifile;
        handles.fileLoc=fileLoc;
        handles.loctxt=loctxt;
        guidata(hObject, handles);
    end
end

% --- Executes on button press in pb2.
function pb2_Callback(hObject, eventdata, handles)
set(handles.rb1,'Value',0);
set(handles.rb2,'Value',0);
axes(handles.axes1);cla reset;
axes(handles.axes2);cla reset;
axes(handles.axes3);cla reset;
%---------
ch=handles.ch;
rd=handles.rd;
nb=handles.nb;
av=handles.av;
Pmx=handles.Pmx;
LoF=handles.LoF;
swath=handles.swath;
%--------
if isempty(LoF)
    str1='Press Folder button to populate the Data List.';
    warndlg(str1,'Warning');
else
    x = get(handles.ed1,'String');
    if isempty(x)
        if ch == 0
            msgbox('No Depth Data Exist','Error','error');
        else
            str1=['Enter the number of profiles 1 - ',num2str(Pmx)];
            warndlg(str1,'Warning');
            swath=0;
        end
    else
        swath=str2double(x); 
    end
end
%%--------
if swath > 0
if ch > 0
    if ch == 1
        if swath <= Pmx
            k=1;j=0;m=0;
            set(handles.txt11, 'String', 'Generating Figure...');
            for i=1:swath
                l=0;
                for j=k:nb(i,1)+m
                    l=l+1;
                    NB(l,i)=rd(j,1);
                    Dp(l,i)=rd(j,3);
                end
                k=j+1;m=k-1;
            end
            for i=1:swath
                clear bn dp 
                bn=zeros(nb(i,1),1);
                dp=zeros(nb(i,1),1);
                for l=1:nb(i,1)
                    if NB(l,i) > 0
                        bn(l,1)=NB(l,i);
                        dp(l,1)=Dp(l,i);
                    end
                end
                Fstr=['Plotting swaths... ',num2str(i),' - ',num2str(swath)];
                set(handles.txt11, 'String', Fstr);
                axes(handles.axes1);
                plot(handles.axes1,bn,dp,'r','LineWidth',2);grid on;axis tight;TL = ylim;hold on;
                xlabel('Beams','FontWeight','demi','FontSize',10,'FontName','Cambria');
                ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');
            end
            set(handles.rb1,'Value',0);
            set(handles.rb2,'Value',1);
            set(handles.txt11, 'String', 'Idle');
        else
            str0=['Maximum No. of Profiles are ' num2str(Pmx)];
            msgbox(str0,'Error','error');
            set(handles.txt11, 'String', 'Idle');
        end
    else
        pr=handles.pr;
        if swath <= Pmx
            k=1;j=0;m=0;
            set(handles.txt11, 'String', 'Generating Figure...');
            for i=1:swath
                l=0;
                for j=k:nb(i,1)+m
                    l=l+1;
                    NB(l,i)=rd(j,1);
                    Dp(l,i)=rd(j,3);
                    At(l,i)=pr(j,3);
                end
                k=j+1;m=k-1;
            end
            for i=1:swath
                clear bp dp at
                bn=zeros(nb(i,1),1);
                dp=zeros(nb(i,1),1);
                at=zeros(nb(i,1),1);
                for l=1:nb(i,1)
                    if NB(l,i) > 0
                        bn(l,1)=NB(l,i);
                        dp(l,1)=Dp(l,i);
                        at(l,1)=At(l,i);
                    end
                end
                Fstr=['Plotting swaths... ',num2str(i),' - ',num2str(swath)];
                set(handles.txt11, 'String', Fstr);
                axes(handles.axes1);
                plot(handles.axes1,bn,dp,'r','LineWidth',2);grid on;axis tight;TL = ylim;hold on;
                xlabel('Beams','FontWeight','demi','FontSize',10,'FontName','Cambria');
                ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');
                axes(handles.axes3);
                plot(handles.axes3,bn,at,'b','LineWidth',2);grid on;axis tight;ylim(TL);hold on;
                xlabel('Beams','FontWeight','demi','FontSize',10,'FontName','Cambria');
                ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');
            end
            bn=zeros(length(av),1);
            at=zeros(length(av),1);
            for i=1:length(av)
                bn(i,1)=av(i,1);
                at(i,1)=av(i,3);
            end
            axes(handles.axes2);
            plot(handles.axes2,bn,at,'g','LineWidth',2);grid on;axis tight;
            xlabel('Beams','FontWeight','demi','FontSize',10,'FontName','Cambria');
            ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');
            set(handles.rb1,'Value',0);
            set(handles.rb2,'Value',1);
            set(handles.txt11, 'String', 'Idle');
        else
            str0=['Maximum No. of Profiles are ' num2str(Pmx)];
            msgbox(str0,'Error','error');
            set(handles.txt11, 'String', 'Idle');
        end
    end
else
    msgbox('No Depth Data Exist','Error','error');
    set(handles.txt11, 'String', 'Idle');
end
end
handles.swath=swath;
guidata(hObject, handles);

% --- Executes on button press in rb1.
function rb1_Callback(hObject, eventdata, handles)
set(handles.rb1,'Value',1);
set(handles.rb2,'Value',0);
axes(handles.axes1);cla reset;
axes(handles.axes2);cla reset;
axes(handles.axes3);cla reset;

ch=handles.ch;
rd=handles.rd;
nb=handles.nb;
av=handles.av;
Pmx=handles.Pmx;
swath=handles.swath;
%%------Depth v/s Angle
if ch > 0 
    if ch == 1
        if swath > 0 && swath <= Pmx
            k=1;j=0;m=0;
            set(handles.txt11, 'String', 'Generating Figure...');
            for i=1:swath
                l=0;
                for j=k:nb(i,1)+m
                    l=l+1;
                    NB(l,i)=rd(j,1);
                    Bp(l,i)=rd(j,2);
                    Dp(l,i)=rd(j,3);
                end
                k=j+1;m=k-1;
            end
            for i=1:swath
                clear bp dp 
                bp=zeros(nb(i,1),1);
                dp=zeros(nb(i,1),1);
                for l=1:nb(i,1)
                    if NB(l,i) > 0
                        bp(l,1)=Bp(l,i);
                        dp(l,1)=Dp(l,i);
                    end
                end
                Fstr=['Plotting swaths... ',num2str(i),' - ',num2str(swath)];
                set(handles.txt11, 'String', Fstr);
                axes(handles.axes1);
                STR0=['Incidence Angle (' char(176) ')'];
                plot(handles.axes1,bp,dp,'r','LineWidth',2);grid on;axis tight;YL = ylim;XL=xlim;hold on;
                xlabel(STR0,'FontWeight','demi','FontSize',10,'FontName','Cambria');
                ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');
            end
            set(handles.rb1,'Value',1);
            set(handles.rb2,'Value',0);
            set(handles.txt11, 'String', 'Idle');
        else
            STR1=['Maximum No. of Profiles are ' num2str(Pmx)];
            msgbox(STR1,'Error','error');
        end
    else
        pr=handles.pr;
        %%--------
        if swath > 0 && swath <= Pmx
            k=1;j=0;m=0;
            set(handles.txt11, 'String', 'Generating Figure...');
            for i=1:swath
                l=0;
                for j=k:nb(i,1)+m
                    l=l+1;
                    NB(l,i)=rd(j,1);
                    Bp(l,i)=rd(j,2);
                    Dp(l,i)=rd(j,3);
                    At(l,i)=pr(j,3);
                end
                k=j+1;m=k-1;
            end
            for i=1:swath
                clear bp dp at
                bp=zeros(nb(i,1),1);
                dp=zeros(nb(i,1),1);
                at=zeros(nb(i,1),1);
                for l=1:nb(i,1)
                    if NB(l,i) > 0
                        bp(l,1)=Bp(l,i);
                        dp(l,1)=Dp(l,i);
                        at(l,1)=At(l,i);
                    end
                end
                Fstr=['Plotting swaths... ',num2str(i),' - ',num2str(swath)];
                set(handles.txt11, 'String', Fstr);
                axes(handles.axes1);
                STR0=['Incidence Angle (' char(176) ')'];
                plot(handles.axes1,bp,dp,'r','LineWidth',2);grid on;axis tight;YL = ylim;XL=xlim;hold on;
                xlabel(STR0,'FontWeight','demi','FontSize',10,'FontName','Cambria');
                ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');

                axes(handles.axes3);
                plot(handles.axes3,bp,at,'b','LineWidth',2);grid on;axis tight;ylim(YL);xlim(XL);hold on;
                xlabel(STR0,'FontWeight','demi','FontSize',10,'FontName','Cambria');
                ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');
            end
            bp=zeros(length(av),1);
            at=zeros(length(av),1);
            for i=1:length(av)
                bp(i,1)=av(i,2);
                at(i,1)=av(i,3);
            end
            axes(handles.axes2);
            STR0=['Incidence Angle (' char(176) ')'];
            plot(handles.axes2,bp,at,'g','LineWidth',2);grid on;axis tight;
            xlabel(STR0,'FontWeight','demi','FontSize',10,'FontName','Cambria');
            ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');
            set(handles.rb1,'Value',1);
            set(handles.rb2,'Value',0);
            set(handles.txt11, 'String', 'Idle');
        else
            STR1=['Maximum No. of Profiles are ' num2str(Pmx)];
            msgbox(STR1,'Error','error');
        end
    end
else
    msgbox('No Depth Data Exist','Error','error');
    set(handles.txt11, 'String', 'Idle');
end

% --- Executes on button press in rb2.
function rb2_Callback(hObject, eventdata, handles)
set(handles.rb1,'Value',0);
set(handles.rb2,'Value',1);
axes(handles.axes1);cla reset;
axes(handles.axes2);cla reset;
axes(handles.axes3);cla reset;
ch=handles.ch;
rd=handles.rd;
nb=handles.nb;
av=handles.av;
Pmx=handles.Pmx;
swath=handles.swath;
%%------Depth v/s Beams
if ch > 0
    if ch == 1
        if swath > 0 && swath <= Pmx
            k=1;j=0;m=0;
            set(handles.txt11, 'String', 'Generating Figure...');
            for i=1:swath
                l=0;
                for j=k:nb(i,1)+m
                    l=l+1;
                    NB(l,i)=rd(j,1);
                    Dp(l,i)=rd(j,3);
                end
                k=j+1;m=k-1;
            end
            for i=1:swath
                clear bp dp 
                bn=zeros(nb(i,1),1);
                dp=zeros(nb(i,1),1);
                for l=1:nb(i,1)
                    if NB(l,i) > 0
                        bn(l,1)=NB(l,i);
                        dp(l,1)=Dp(l,i);
                    end
                end
                Fstr=['Plotting swaths... ',num2str(i),' - ',num2str(swath)];
                set(handles.txt11, 'String', Fstr);
                axes(handles.axes1);
                plot(handles.axes1,bn,dp,'r','LineWidth',2);grid on;axis tight;TL = ylim;hold on;
                xlabel('Beams','FontWeight','demi','FontSize',10,'FontName','Cambria');
                ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');
            end
            set(handles.rb1,'Value',0);
            set(handles.rb2,'Value',1);
            set(handles.txt11, 'String', 'Idle');
        else
            STR1=['Maximum No. of Profiles are ' num2str(Pmx)];
            msgbox(STR1,'Error','error');
        end
    else
        pr=handles.pr;
%%--------
        if swath > 0 && swath <= Pmx
            k=1;j=0;m=0;
            set(handles.txt11, 'String', 'Generating Figure...');
            for i=1:swath
                l=0;
                for j=k:nb(i,1)+m
                    l=l+1;
                    NB(l,i)=rd(j,1);
                    Dp(l,i)=rd(j,3);
                    At(l,i)=pr(j,3);
                end
                k=j+1;m=k-1;
            end
            for i=1:swath
                clear bn dp at
                bn=zeros(nb(i,1),1);
                dp=zeros(nb(i,1),1);
                at=zeros(nb(i,1),1);
                for l=1:nb(i,1)
                    if NB(l,i) > 0
                        bn(l,1)=NB(l,i);
                        dp(l,1)=Dp(l,i);
                        at(l,1)=At(l,i);
                    end
                end
                Fstr=['Plotting swaths... ',num2str(i),' - ',num2str(swath)];
                set(handles.txt11, 'String', Fstr);
                axes(handles.axes1);
                plot(handles.axes1,bn,dp,'r','LineWidth',2);grid on;axis tight;TL = ylim;hold on;
                xlabel('Beams','FontWeight','demi','FontSize',10,'FontName','Cambria');
                ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');

                axes(handles.axes3);
                plot(handles.axes3,bn,at,'b','LineWidth',2);grid on;axis tight;ylim(TL);hold on;
                xlabel('Beams','FontWeight','demi','FontSize',10,'FontName','Cambria');
                ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');
            end
            bn=zeros(length(av),1);
            at=zeros(length(av),1);
            for i=1:length(av)
                bn(i,1)=av(i,1);
                at(i,1)=av(i,3);
            end
            axes(handles.axes2);
            plot(handles.axes2,bn,at,'g','LineWidth',2);grid on;axis tight;
            xlabel('Beams','FontWeight','demi','FontSize',10,'FontName','Cambria');
            ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');

            set(handles.rb1,'Value',0);
            set(handles.rb2,'Value',1);
            set(handles.txt11, 'String', 'Idle');
        else
            STR1=['Maximum No. of Profiles are ' num2str(Pmx)];
            msgbox(STR1,'Error','error');
        end
    end
else
    msgbox('No Depth Data Exist','Error','error');
    set(handles.txt11, 'String', 'Idle');
end

% --- Executes on button press in pb3.
function pb3_Callback(hObject, eventdata, handles)
fclose('all'); % if files are not closedin previous session
delete('*MB.all');delete('*.txt');
set(handles.ed1,'String','');
set(handles.rb1,'Value',0);
set(handles.rb2,'Value',0);
axes(handles.axes1);cla reset;
axes(handles.axes2);cla reset;
axes(handles.axes3);cla reset;

set(handles.lb2, 'String', '');
pause(0.1)
LoF=handles.LoF;
fileLoc=handles.fileLoc;
locall=handles.locall;
ch=2;swath=1;
if isempty(LoF)
    str1='Press Folder button first to add files...';
    warndlg(str1,'Warning');
else
files= dir(locall);
fz=fopen('batch.txt','w');
set(handles.txt11, 'String', 'Processing...');
for i=1:length(files)
    fprintf(fz,'%s\n',files(i).name);
end
fclose(fz);
locMBall=[fileLoc,'\*MB.all'];
fz=fopen('batch.txt','r');
f=0;
set(handles.txt8,'String','');
while ~feof(fz)
    Ifile = fgetl(fz);
    set(handles.txt13, 'String', '');
    set(handles.txt14, 'String', '');
    set(handles.txt16, 'String', '');
    set(handles.txt17, 'String', '');
    set(handles.txt19, 'String', '');
    set(handles.txt21, 'String', '');
    set(handles.txt6,'String',Ifile);
    pause(0.001)
    f=f+1;
%---------------------------------------------------
    set(handles.pb4,'userdata',0);
    b=dir(Ifile);size=b.bytes;
    for i=1:length(Ifile)
        if strcmp({Ifile(i)},'.') == 1
            break;      
        end
    end
    chr = char({Ifile(1:i-1)});
    Itxt = [chr '.txt'];
    Atxt = [chr '_AVG.txt'];
    Otxt = [chr '_MB.txt'];
    Btxt = [chr '_BN.txt'];
    Ofile=[chr '_MB.all'];
    Ptxt = [chr '_PD.txt'];
    Mtxt = [chr '_MD.txt'];
    Rtxt=[chr '_Rfit.txt'];
    Stxt=[chr '_Stat.txt'];
    ARD=zeros(111,1);
    DPR=zeros(111,1);
    DIF=zeros(111,1);
    AVD=zeros(111,1);
    AVG=zeros(111,1);
    CON=zeros(111,1);
    CAS=zeros(111,1);
    BMS=zeros(111,1);
    xFit=zeros(111,1);
    yFit=zeros(111,1);
    fm=fopen(Mtxt,'w');
    fs=fopen(Stxt,'w');
    fr=fopen(Rtxt,'w');
    fp=fopen(Ptxt,'w');
    fg=fopen(Atxt,'w');
    fa=fopen(Itxt,'w');
    fb=fopen(Otxt,'w');
    fn=fopen(Btxt,'w');
    fi=fopen(Ifile,'rb');n=0;sm=0;fw=0;lat=0;lon=0;
    fo=fopen(Ofile,'wb');RD=0;CD=0;AV=0;DV=0;AG=0;qty=0;
    while ~feof(fi)
        by=fread(fi,1,'uint32=>int');
        pos=ftell(fi);
        id=fread(fi,1,'uint8=>int');
        ty=fread(fi,1,'uint8=>int');
        mo=fread(fi,1,'uint16=>int');
        da=fread(fi,1,'uint32=>int');
        ti=fread(fi,1,'uint32=>int');
        switch ty
            case 80
                fread(fi,4,'uint8=>int');
                lat=fread(fi,1,'int32=>float');lat=lat/20000000;
                lon=fread(fi,1,'int32=>float');lon=lon/10000000;
                pos=pos+by;
                STAT =fseek(fi,pos,'bof');
            case 68
                fread(fi,11,'uint8=>int');
                VLDBMS=fread(fi,1,'uint8=>int');fprintf(fn,'%d\n',VLDBMS);
                fread(fi,4,'uint8=>int');
                for i=1:VLDBMS
                    ARD(i,1)=fread(fi,1,'int16=>float');
                    y(i,1)=fread(fi,1,'int16=>float');
                    ly(i,1)=(y(i,1)/(100000*1.852*60))+lon;
                    x(i,1)=fread(fi,1,'int16=>float');
                    lx(i,1)=(x(i,1)/(100000*1.852*60))+lat;
                    DPR(i,1)=fread(fi,1,'int16=>float');
                    CON(i,1)=CON(i,1)+1;
                    if lx(i,1) > 1 && ly(i,1) > 1
                        fprintf(fp,'%0.8f %0.8f -%0.2f\n',ly(i,1),lx(i,1),ARD(i,1)/100);
                    end
                    fread(fi,8,'uint8=>int');
                end
                if VLDBMS < 56
                    CON(i,1)=CON(i,1)-1;
                else    
                    FLAG=0;CTR=0;
                    for i=1:VLDBMS
                        if i < VLDBMS-1
                            A1=9000-DPR(i,1);
                            A2=9000-DPR(i+1,1);
                        end
                        if A2 > A1 && FLAG == 0
                            CTR=i;FLAG=1;
                        end
                    end
                    for i=1:VLDBMS
                        if i < CTR
                            INC(i,1)=DPR(i,1)-9000;
                            fprintf(fa,'%d %0.2f -%0.2f\n',i,INC(i,1)/100,ARD(i,1)/100);
                        else
                            INC(i,1)=9000-DPR(i,1);
                            fprintf(fa,'%d %0.2f -%0.2f\n',i,INC(i,1)/100,ARD(i,1)/100);
                        end
                    end
                    ps=0;ng=0;per=0;cent=0;
                    for i=1:VLDBMS
                        DIF(i,1)=(ARD(CTR,1)-ARD(i,1))+DIF(i,1);
                        CAS(i,1)=ARD(CTR,1)-ARD(i,1);
                        if CAS(i,1) >= 0
                            ps=ps+1;
                        else
                            ng=ng+1;
                        end
                    end
                    per=(ps*100/VLDBMS);cent=(ng*100/VLDBMS);
                    if per > cent
                        cs=1;
                    else
                        cs=2;
                    end
                end
                pos=pos+by;
                STAT =fseek(fi,pos,'bof');
            case {48, 49, 65, 66, 67, 69, 70, 71, 72, 73, 74, 78, 82, 83, 84, 85, 87, 88, 89, 104, 102}
                pos=pos+by;
                STAT =fseek(fi,pos,'bof');
            case 105
                for i=1:111
                    AVG(i,1)=round(DIF(i,1)/CON(i,1));BMS(i,1)=i;
                    fprintf(fg,'%d %0.2f %0.2f\n',i,INC(i,1)/100,AVG(i,1)/100);
                end
                linearCoefficients = polyfit(BMS, AVG, 1);
                xFit = linspace(1, 111, 111)';
                yFit = polyval(linearCoefficients, xFit);
                for i=1:111
                    fprintf(fr,'%d %0.2f\n',xFit(i,1),yFit(i,1)/100);
                end
                fclose(fr);fclose(fa);fclose(fn);fclose(fg);fclose(fp);
                pos=pos+by;
                STAT =fseek(fi,pos,'bof');break;    
            otherwise
                disp(['TY: ',num2str(ty),' Unknown Type'])
                pause
        end
        stus=round(pos*100/size);
        Rstr=['Reading ',num2str(stus),'%/100%'];
        set(handles.txt11, 'String', Rstr);
        pause(0.0001)
        if pos == size
            break;
        end 
        clc
    end
    if pos == size
        frewind(fi);
        pos=ftell(fi);byte=pos;ping=0;
        while pos < size 
            by=fread(fi,1,'uint32');fwrite(fo,by,'uint32');
            pos=ftell(fi);
            id=fread(fi,1,'uint8');fwrite(fo,id,'uint8');
            ty=fread(fi,1,'uint8');fwrite(fo,ty,'uint8');
            mo=fread(fi,1,'uint16');fwrite(fo,mo,'uint16');
            da=fread(fi,1,'uint32');fwrite(fo,da,'uint32');
            ti=fread(fi,1,'uint32');fwrite(fo,ti,'uint32');
            clear bn sp
            switch ty
                case 80
                    pc=fread(fi,1,'uint16=>int');fwrite(fo,pc,'uint16');
                    sr=fread(fi,1,'uint16=>int');fwrite(fo,sr,'uint16');
                    lat=fread(fi,1,'int32=>float');fwrite(fo,lat,'int32');lat=lat/20000000;
                    lon=fread(fi,1,'int32=>float');fwrite(fo,lon,'int32');lon=lon/10000000;
                    fp=ftell(fi);byte=fp-pos;
                    while byte < by
                        c=fread(fi,1,'uint8');fwrite(fo,c,'uint8');
                        fp=ftell(fi);byte=fp-pos;
                        if byte == by
                            break;
                        end
                    end
                    pos=pos+by;
                    STAT =fseek(fi,pos,'bof');
                case 68
                    ARD=zeros(111,1);Ht=zeros(111,1);ping=ping+1;
                    pg=fread(fi,1,'uint16');fwrite(fo,pg,'uint16');
                    sr=fread(fi,1,'uint16');fwrite(fo,sr,'uint16');
                    hd=fread(fi,1,'uint16');fwrite(fo,hd,'uint16');
                    sp=fread(fi,1,'uint16');fwrite(fo,sp,'uint16');
                    wl=fread(fi,1,'uint16');fwrite(fo,wl,'uint16');
                    mb=fread(fi,1,'uint8');fwrite(fo,mb,'uint8');
                    nv=fread(fi,1,'uint8');fwrite(fo,nv,'uint8');
                    zr=fread(fi,1,'uint8');fwrite(fo,zr,'uint8');
                    xy=fread(fi,1,'uint8');fwrite(fo,xy,'uint8');
                    sr=fread(fi,1,'uint16');fwrite(fo,sr,'uint16');
                    fp=ftell(fi);
                    for i=1:nv
                        dp(i,1)=fread(fi,1,'int16=>float');
                        ARD(i,1)=dp(i,1)+AVG(i,1);
                        fread(fi,4,'uint8');
                        dpr(i,1)=fread(fi,1,'int16=>float');
                        fread(fi,8,'uint8');
                    end
                    [ dm, am, at,rsd, csd ] = SER( nv, ARD, DPR, dp, chr, ping, yFit);
                    RSD(ping,1)=rsd;CSD(ping,1)=csd;AMG(ping,1)=am;DMG(ping,1)=dm;
                    fseek(fi,fp,'bof');
                    for i=1:nv
                        fread(fi,1,'int16=>float');fwrite(fo,at(i,1),'int16');    
                        ay=fread(fi,1,'int16');fwrite(fo,ay,'int16');
                        ax=fread(fi,1,'int16');fwrite(fo,ax,'int16');
                        y(i,1)=ay;ly(i,1)=(y(i,1)/(100000*1.852*60))+lon;
                        x(i,1)=ax;lx(i,1)=(x(i,1)/(100000*1.852*60))+lat;
                        bd=fread(fi,1,'int16=>float');fwrite(fo,bd,'int16');
                        ba=fread(fi,1,'uint16');fwrite(fo,ba,'uint16');
                        rg=fread(fi,1,'uint16');fwrite(fo,rg,'uint16');
                        qf=fread(fi,1,'uint8');fwrite(fo,qf,'uint8');
                        dw=fread(fi,1,'uint8');fwrite(fo,dw,'uint8');
                        rf=fread(fi,1,'int8');fwrite(fo,rf,'int8');
                        bn=fread(fi,1,'uint8');fwrite(fo,bn,'uint8');
                        if lx(i,1) > 1 && ly(i,1) > 1
                            fprintf(fm,'%0.8f %0.8f -%0.2f\n',ly(i,1),lx(i,1),at(i,1)/100);
                        end
                    end
                    if nv < 56
                        CON(i,1)=CON(i,1)-1;
                    else    
                        FLAG=0;CTR=0;
                        for i=1:nv
                            if i < nv-1
                                A1=9000-dpr(i,1);
                                A2=9000-dpr(i+1,1);
                            end
                            if A2 > A1 && FLAG == 0
                                CTR=i;FLAG=1;
                            end
                        end
                        for i=1:nv
                            if i < CTR
                                INC(i,1)=dpr(i,1)-9000;
                                fprintf(fb,'%d %0.2f -%0.2f\n',i,INC(i,1)/100,at(i,1)/100);
                            else
                                INC(i,1)=9000-dpr(i,1);
                                fprintf(fb,'%d %0.2f -%0.2f\n',i,INC(i,1)/100,at(i,1)/100);
                            end
                        end
                    end
                    td=fread(fi,1,'int8');fwrite(fo,td,'int8');
                    ed=fread(fi,1,'uint8');fwrite(fo,ed,'uint8');
                    cks=fread(fi,1,'uint16');fwrite(fo,cks,'uint16');
                case {48, 49, 65, 66, 67, 69, 70, 71, 72, 73, 74, 78, 82, 83, 84, 85, 87, 88, 89, 104, 102}
                    fp=ftell(fi);byte=fp-pos;
                    while byte < by
                        c=fread(fi,1,'uint8');fwrite(fo,c,'uint8');
                        fp=ftell(fi);byte=fp-pos;
                        if byte == by
                            break;
                        end
                    end
                case 105
                    fp=ftell(fi);byte=fp-pos;
                    while byte < by
                        c=fread(fi,1,'uint8');fwrite(fo,c,'uint8');
                        fp=ftell(fi);byte=fp-pos;
                    end
                    fclose(fo);fclose(fb);fclose(fm);
                    RD=mean(RSD);CD=mean(CSD);AV=mean(AMG)/100;
                    DV=mean(DMG)/100;AG=mean(AVG)/100;AG=AG*2;
                    if AG < 0
                        AG=AG*-1;
                    end
                    qty=((RD-CD)*100/RD);
                    fprintf(fs,'%s: %0.2f %0.2f %0.2f %0.2f ±%0.2f %0.2f\n',Ifile,RD,CD,DV,AV,AG,qty);
                    pause(0.01)
                    fclose(fs);
                otherwise
                    disp(['TY: ',num2str(ty),' Unknown Type'])
                    pause
            end
            pos=ftell(fi);
            stus=round(pos*100/size);
            Wstr=['Writing ',num2str(stus),'%/100%'];
            set(handles.txt11, 'String', Wstr);
            if pos == size
                break;
            end
            drawnow
            if get(handles.pb4,'userdata') % stop condition
                fclose('all');    
                break;
            end
            pause(0.0001)
        clc
        end
    end
    fclose(fi);
%--------------------------------------------------
    Pfiles=dir(locMBall);
    set(handles.txt8,'String',num2str(f))
    if f == 1
        set(handles.lb2, 'String', Pfiles(f).name);
    else
        lb2_Items = get(handles.lb2,'String');
        lb2_Items = [cellstr(lb2_Items) ; cellstr(Pfiles(f).name)];
        set(handles.lb2,'String',lb2_Items);
    end
end
fclose(fz);fclose('all');
set(handles.txt11, 'String', 'Updating...');
pause(0.0001)
lb_Items = cellstr(get(handles.lb1,'String'));
set(handles.txt4,'String',num2str(length(lb_Items)))
lB_Value = get(handles.lb1,'Value');
Ifile = lb_Items{get(handles.lb1,'Value')};
set(handles.txt6,'String',Ifile);
set(handles.lb2,'Value',lB_Value);
set(handles.txt11, 'String', 'generating Figure...');
loctxt=[fileLoc,'\*.txt'];
%---Process File----
R=dir(loctxt);
Lfiles={R.name}';
m=length(Lfiles);
Txt=char(Lfiles);
for j=1:m
    Rtxt=Txt(j,:);
    r=0;
    for i=1:length(Ifile)
        if strcmp({Ifile(i)},{Rtxt(i)}) == 1
            r=r+1;
        end
    end
    fper(j,1)=r;
end
fmx=max(fper);
for i=1:length(fper)
    if fper(i,1) == fmx
        file=Txt(i,:);
        break;
    end
end
Nfile=[file(1:fmx-1) '*.txt'];
Fnaltxt=[fileLoc,'\',Nfile];
N=dir(Fnaltxt);
Nfiles={N.name}';
Ntxt=char(Nfiles);
Rtxt=Ntxt(1,:);
Atxt=Ntxt(2,:);
Btxt=Ntxt(3,:);
Ptxt=Ntxt(4,:);
Stxt=Ntxt(8,:);

rd=load(Rtxt); %---Raw File
av=load(Atxt); %---Avg File
nb=load(Btxt); %---NB File
pr=load(Ptxt); %---MB File

Pmx=length(nb); % Maximum pings i a file
if Pmx > 0
    if length(nb) > 0
        for i=1:nb(1,1)
            NB(i,1)=rd(i,1);
            Dp(i,1)=rd(i,3);
            Bm(i,1)=av(i,1);
            Ag(i,1)=av(i,3);
            At(i,1)=pr(i,3);
        end
    end
% -----Plot Raw Depth ----- 
    axes(handles.axes1);
    plot(handles.axes1,NB,Dp,'r','LineWidth',2);grid on;axis tight;YL = ylim;XL=xlim;hold on;
    xlabel('Beams','FontWeight','demi','FontSize',10,'FontName','Cambria');
    ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');
% ----- Plot Offset -----
    axes(handles.axes2);
    plot(handles.axes2,Bm,Ag,'g','LineWidth',2);grid on;axis tight;hold on;
    xlabel('Beams','FontWeight','demi','FontSize',10,'FontName','Cambria');
    ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');
% -----Plot Proc depth -----
    axes(handles.axes3);
    plot(handles.axes3,NB,At,'b','LineWidth',2);grid on;axis tight;ylim(YL);xlim(XL);
    xlabel('Beams','FontWeight','demi','FontSize',10,'FontName','Cambria');
    ylabel('Depth (m)','FontWeight','demi','FontSize',10,'FontName','Cambria');
%-------------------
    [~,RSD,CSD,RH,CH,Err,QT] = textread(Stxt,'%s%f%f%f%f%s%f');
    set(handles.txt13, 'String', num2str(RSD));
    set(handles.txt14, 'String', num2str(CSD));
    set(handles.txt16, 'String', num2str(RH));
    set(handles.txt17, 'String', num2str(CH));
    set(handles.txt19, 'String', Err);
    set(handles.txt21, 'String', num2str(QT));
    set(handles.rb1,'Value',0);
    set(handles.rb2,'Value',1);
    set(handles.txt11, 'String', 'Idle');
    pause(0.0001)
    handles.rd=rd;
    handles.nb=nb;
    handles.pr=pr;
    handles.av=av;
    handles.ch=ch;
    handles.Pmx=Pmx;
    handles.swath=swath;
    handles.file=file;
    handles.Ifile=Ifile;
    guidata(hObject, handles);
else
    msgbox('No Depth Data Exist','Error','error');
    set(handles.txt11, 'String', 'Idle');
end
end

% --- Executes on button press in pb4.
function pb4_Callback(hObject, eventdata, handles)
set(handles.txt11, 'String', 'Clearing background Data');
pause(1)
set(gcbo,'userdata',1);
clearStr = 'clear all';
evalin('base',clearStr);
delete(handles.figure1);
clc
% --- Executes during object creation, after setting all properties.
function lb1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ed1_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of ed1 as text
%        str2double(get(hObject,'String')) returns contents of ed1 as a double
% set(handles.ed1,'Value',0);
% --- Executes during object creation, after setting all properties.
function ed1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on selection change in lb2.
function lb2_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns lb2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lb2

% --- Executes during object creation, after setting all properties.
function lb2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end