function fh=conn_qaplotsexplore(varargin)
% CONN_QAPLOTSEXPLORE: QA plots display
%

global CONN_x CONN_gui;

if isfield(CONN_gui,'font_offset'),font_offset=CONN_gui.font_offset; else font_offset=0; end
if ~isfield(CONN_x,'folders')||~isfield(CONN_x.folders,'qa')||isempty(CONN_x.folders.qa), 
    qafolder=pwd;
    isCONN=false;
else qafolder=CONN_x.folders.qa; 
    isCONN=true;
end
fh=@(varargin)conn_qaplotsexplore_update([],[],varargin{:});
if nargin&&any(strcmp(varargin(cellfun(@ischar,varargin)),'initdenoise')), dlg.forceinitdenoise=true;
else dlg.forceinitdenoise=false;
end
if nargin&&any(strcmp(varargin(cellfun(@ischar,varargin)),'createdenoise')), dlg.forceinitdenoise=true; dlg.createdenoise=true;
else dlg.createdenoise=false;
end
if nargin&&any(strcmp(varargin(cellfun(@ischar,varargin)),'createreport')), dlg.createreport=true; 
else dlg.createreport=false;
end
if nargin&&any(strcmp(varargin(cellfun(@ischar,varargin)),'keepcurrentfigure')), dlg.keepcurrentfigure=true;
else dlg.keepcurrentfigure=false;
end
if nargin&&any(strcmp(varargin(cellfun(@ischar,varargin)),'overwritecurrentfigure')), dlg.overwritecurrentfigure=true;
else dlg.overwritecurrentfigure=false;
end
hfig=[];
if dlg.overwritecurrentfigure||dlg.keepcurrentfigure
    hfig=findobj('tag','conn_qaplotsexplore');
    if ~isempty(hfig), 
        hfig=hfig(end); 
        if dlg.keepcurrentfigure, 
            figure(hfig); 
            fh=get(hfig,'userdata'); 
            fh(varargin{~strcmp(varargin(cellfun(@ischar,varargin)),'keepcurrentfigure')});
            return;
        end
    end
end
if nargin&&any(strcmp(varargin(cellfun(@ischar,varargin)),'thesefolders')), 
    qafolder=pwd;
    qagroups=conn_dir(fullfile(qafolder,'QA_*'),'-dir','-cell');
    dlg.sets=regexprep(cellfun(@(x)x(numel(qafolder)+1:end),qagroups,'uni',0),'^[\\\/]','');
    isCONN=false; 
elseif nargin&&any(strcmp(varargin(cellfun(@ischar,varargin)),'thisfolder')), 
    [qafolder,qagroups]=fileparts(pwd);
    dlg.sets={qagroups};
    isCONN=false; 
elseif nargin&&ischar(varargin{1})&&isdir(varargin{1})
    [qafolder,qagroups]=fileparts(varargin{1});
    if isempty(qagroups), [qafolder,qagroups]=fileparts(qafolder); end
    if isempty(qafolder), qafolder=pwd; end
    dlg.sets={qagroups};
    isCONN=false; 
else
    qagroups=conn_dir(fullfile(qafolder,'QA_*'),'-dir','-cell');
    dlg.sets=regexprep(cellfun(@(x)x(numel(qafolder)+1:end),qagroups,'uni',0),'^[\\\/]','');
end
if nargin&&any(strcmp(varargin(cellfun(@ischar,varargin)),'isconn')), isCONN=true; end
if dlg.forceinitdenoise&&(dlg.createdenoise||isempty(dlg.sets)),
    conn_qaplotsexplore_update([],[],'newsetinit');
end
dlg.iset=numel(dlg.sets);
dlg.dispsize=[];
dlg.showavg=1;
bgc=.9*[1 1 1];
dlg.handles.fh=fh;
figcolor=[.95 .95 .9];
dlg.handles.hfig=hfig;
if isempty(dlg.handles.hfig)||~ishandle(dlg.handles.hfig), dlg.handles.hfig=figure('units','norm','position',[.1,.3,.8,.6],'menubar','none','numbertitle','off','name','Quality Assurance reports','color',figcolor,'colormap',gray(256),'interruptible','off','busyaction','cancel','tag','conn_qaplotsexplore','userdata',fh); 
else figure(dlg.handles.hfig); clf(dlg.handles.hfig);
end
%dlg.handles.menuprint=uimenu(dlg.handles.hfig,'Label','Print');
%uimenu(dlg.handles.menuprint,'Label','Print entire report (pdf/html)','callback',{@conn_qaplotsexplore_update,'createreport'});
%uimenu(dlg.handles.menuprint,'Label','Print individual plot (jpeg/tiff)','callback',{@conn_qaplotsexplore_update,'print'});
uicontrol('style','frame','units','norm','position',[0,.91,1,.09],'backgroundcolor',bgc,'foregroundcolor',bgc,'fontsize',9+font_offset);
uicontrol('style','text','units','norm','position',[.025,.925,.1,.05],'backgroundcolor',bgc,'foregroundcolor','k','horizontalalignment','left','string','QA reports:','fontweight','bold','fontsize',9+font_offset);
uicontrol('style','text','units','norm','position',[.025,.835,.1,.05],'backgroundcolor',figcolor,'foregroundcolor','k','horizontalalignment','left','string','Plots:','fontweight','bold','fontsize',9+font_offset);
dlg.handles.set=uicontrol('style','popupmenu','units','norm','position',[.125,.925,.5,.05],'string',dlg.sets,'value',dlg.iset,'backgroundcolor',bgc,'foregroundcolor','k','tooltipstring','<HTML>Select a Quality Assurance report<br/> - each report contains one or multiple plots created to visually assess the quality of the structural/functional data<br/> and/or easily identify potential outlier subjects or failed preprocessing steps<br/> - choose one existing report from this list, or select <i>new report</i> to create a new report instead</HTML>','callback',{@conn_qaplotsexplore_update,'set'},'fontsize',9+font_offset,'interruptible','off');
dlg.handles.settxt=uicontrol('style','text','units','norm','position',[.125,.925,.5,.05],'string','No QA sets found in this CONN project. Select ''New report'' to get started','backgroundcolor',bgc,'foregroundcolor','k','fontsize',9+font_offset,'visible','off');
dlg.handles.analysis=uicontrol('style','popupmenu','units','norm','position',[.125,.835,.5,.05],'string',' ','backgroundcolor',figcolor,'foregroundcolor','k','tooltipstring','<HTML>Select a Quality Assurance plot within this report<br/> - each report may contain one or multiple plots<br/> - choose one existing plot from this report, or select <i>new plot</i> to create a new plot and add it to this report</HTML>','callback',{@conn_qaplotsexplore_update,'plot'},'fontsize',9+font_offset,'interruptible','off');
dlg.handles.analysistxt=uicontrol('style','text','units','norm','position',[.125,.835,.5,.05],'string','No plots found in this QA report. Select ''New plot'' to get started','backgroundcolor',figcolor,'foregroundcolor','k','fontsize',9+font_offset,'visible','off');
dlg.handles.recomputeset=uicontrol('style','pushbutton','units','norm','position',[.625 .925 .12 .05],'string','Recreate report','tooltipstring','Recomputes all plots in current QA report','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'recreateset'},'interruptible','off');
dlg.handles.recomputeplot=uicontrol('style','pushbutton','units','norm','position',[.625 .835 .12 .05],'string','Recreate plot','tooltipstring','Recomputes the current plot','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'recreateplot'},'interruptible','off');
dlg.handles.addnewset=uicontrol('style','pushbutton','units','norm','position',[.745 .925 .12 .05],'string','Create new report','tooltipstring','Starts a new QA report','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'newset'},'interruptible','off');
dlg.handles.addnewplot=uicontrol('style','pushbutton','units','norm','position',[.745 .835 .12 .05],'string','Create new plot','tooltipstring','Adds a new plot to the current report','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'newplot'},'interruptible','off');
dlg.handles.deleteset=uicontrol('style','pushbutton','units','norm','position',[.875 .925 .05 .05],'string','Delete','tooltipstring','Deletes this report (and all plots in it)','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'deleteset'},'interruptible','off');
dlg.handles.deleteplot=uicontrol('style','pushbutton','units','norm','position',[.875 .835 .05 .05],'string','Delete','tooltipstring','Removes this plot from the current report','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'deleteplot'},'interruptible','off');
dlg.handles.printset=uicontrol('style','pushbutton','units','norm','position',[.925 .925 .05 .05],'string','Export','tooltipstring','Exports entire report to html/pdf file','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'printset'},'interruptible','off');
dlg.handles.printplot=uicontrol('style','pushbutton','units','norm','position',[.925 .835 .05 .05],'string','Print','tooltipstring','Prints current plot (to jpeg/tiff file)','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'printplot'},'interruptible','off');

%uicontrol('style','frame','units','norm','position',[0,0,.17,.86],'backgroundcolor',figcolor,'foregroundcolor',figcolor,'fontsize',9+font_offset);
dlg.handles.subjects=uicontrol('style','listbox','units','norm','position',[.035,.57,.1,.16],'max',2,'backgroundcolor',figcolor,'foregroundcolor','k','string','','tooltipstring','Select one or multiple subjects for display','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'subjects'},'interruptible','off');
dlg.handles.sessions=uicontrol('style','listbox','units','norm','position',[.035,.41,.1,.10],'max',2,'backgroundcolor',figcolor,'foregroundcolor','k','string','','tooltipstring','Select one or multiple sessions for display','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'sessions'},'interruptible','off');
dlg.handles.measures=uicontrol('style','listbox','units','norm','position',[.035,.25,.1,.10],'max',2,'backgroundcolor',figcolor,'foregroundcolor','k','string','','tooltipstring','Select one or multiple measures for display','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'measures'},'interruptible','off');
dlg.handles.selectall1=uicontrol('style','pushbutton','units','norm','position',[.035 .52 .1 .05],'string','Select all','tooltipstring','Selects all subjects','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'allsubjects'},'interruptible','off');
dlg.handles.selectall2=uicontrol('style','pushbutton','units','norm','position',[.035 .36 .1 .05],'string','Select all','tooltipstring','Selects all sessions','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'allsessions'},'interruptible','off');
dlg.handles.selectall3=uicontrol('style','pushbutton','units','norm','position',[.035 .20 .1 .05],'string','Select all','tooltipstring','Selects all measures','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'allmeasures'},'interruptible','off');
dlg.handles.showannot=uicontrol('style','checkbox','units','norm','position',[.02 .12 .15 .05],'string','show annotations','backgroundcolor',figcolor,'foregroundcolor','k','tooltipstring','show/hide plot annotations','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'subjects'},'interruptible','off','visible','on');
dlg.handles.showdiff=uicontrol('style','checkbox','units','norm','position',[.02 .07 .15 .05],'string','show diff','backgroundcolor',figcolor,'foregroundcolor','k','fontsize',9+font_offset,'tooltipstring','<HTML>Show z score maps: normalized differences between each image and the average of all images in this plot<br/>this can be useful to highlight differences between a selected subject and the group</HTML>','value',0,'callback',{@conn_qaplotsexplore_update,'subjects'},'interruptible','off');
dlg.handles.invertim=uicontrol('style','checkbox','units','norm','position',[.02 .02 .15 .05],'string','transparent display','value',1,'backgroundcolor',figcolor,'foregroundcolor','k','tooltipstring','invert image colors if necessary to keep light background and dark foreground','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'refresh'},'interruptible','off','visible','on');
dlg.handles.hax=[];%axes('units','norm','position',[.20 .10 .75 .70],'visible','off');
dlg.handles.han=[];
dlg.handles.text1=uicontrol('style','text','units','norm','position',[.30,.035,.52,.04],'backgroundcolor',figcolor,'foregroundcolor','k','horizontalalignment','center','string','','fontsize',9+font_offset);
dlg.handles.text2=uicontrol('style','text','units','norm','position',[.30,.005,.52,.03],'backgroundcolor',figcolor,'foregroundcolor','k','horizontalalignment','center','string','','fontsize',5+font_offset);
dlg.handles.textoptions=uicontrol('style','popupmenu','units','norm','position',[.45,.025,.2,.05],'backgroundcolor',figcolor,'foregroundcolor','k','horizontalalignment','center','string','','fontsize',9+font_offset,'tooltipstring','<HTML>Choose what to display when selecting multiple subjects/sessions<br/> -<i>average/variability</i> computes the average/variability of the selected plots (e.g. across multiple subjects or sessions)</HTML>','visible','off','callback',{@conn_qaplotsexplore_update,'textoptions'},'interruptible','off');
dlg.handles.details=uicontrol('style','pushbutton','units','norm','position',[.825 .015 .15 .07],'string','Details','tooltipstring','go to interactive or high-resolution version of this plot','fontsize',10+font_offset,'fontweight','bold','callback',{@conn_qaplotsexplore_update,'details'},'visible','off');
conn_qaplotsexplore_update([],[],'set',dlg.iset);
conn_qaplotsexplore_update([],[],'selectall');
%conn_qaplotsexplore_update([],[],'allsubjects');
%conn_qaplotsexplore_update([],[],'allsessions');
%conn_qaplotsexplore_update([],[],'allmeasures');
dlg.handles.hlabel=uicontrol('style','text','horizontalalignment','left','visible','off','fontsize',9+font_offset);
if ~ishandle(dlg.handles.hfig), return; end
set(dlg.handles.hfig,'units','pixels','windowbuttonmotionfcn',@conn_qaplotsexplore_figuremousemove,'windowbuttonupfcn',{@conn_qaplotsexplore_figuremousemove,'buttonup'},'resizefcn',{@conn_qaplotsexplore_update,'resize'});
if dlg.createreport, conn_qaplotsexplore_update([],[],'printset','nogui'); conn_qaplotsexplore_update([],[],'close'); end

    function conn_qaplotsexplore_update(hObject,eventdata,option,varargin)
        if isfield(dlg,'handles')&&isfield(dlg.handles,'hfig')&&~ishandle(dlg.handles.hfig), return; end
        switch(lower(option))
            case 'resize',
                try
                    if dlg.dispsize(end)>1, conn_qaplotsexplore_update([],[],'refresh'); end
                end
            case 'close'
                delete(dlg.handles.hfig);
            case 'printplot'
                conn_qaplotsexplore_update([],[],'togglegui');
                conn_print;
                conn_qaplotsexplore_update([],[],'togglegui');
            case 'printset'
                cwd=pwd;
                if numel(varargin)>0&&any(strcmp(varargin(cellfun(@ischar,varargin)),'nogui')), nogui=true;
                else nogui=false;
                end
                outputDir=fullfile(qafolder,dlg.sets{dlg.iset});
                if ispc, options={'*.html','HTML report (*.html)'; '*.pdf','PDF report (*.pdf)'; '*.ppt','PowerPoint report (*.ppt)'; '*.doc','Word report (*.doc)'; '*.xml','XML report (*.xml)'; '*.tex','LaTeX report (*.tex)'};
                else options={'*.html','HTML report (*.html)'; '*.pdf','PDF report (*.pdf)'; '*.xml','XML report (*.xml)'; '*.tex','LaTeX report (*.tex)'};
                end
                if nogui, tfilename='report.html';
                else [tfilename,outputDir]=uiputfile(options,'Output report to file:',fullfile(outputDir,'report.html'));
                end
                if ~ischar(tfilename)||isempty(tfilename), return; end
                if nogui, plots_summary=1:numel(dlg.uanalyses_long); plots_subject=1:numel(dlg.uanalyses_long);
                else
                    plots_summary=listdlg('liststring',dlg.uanalyses_long,'selectionmode','multiple','initialvalue',1:numel(dlg.uanalyses_long),'promptstring',{'Select plot(s) to include in SUMMARY section','(in this section each plot will display all subjects/measures combined)'},'ListSize',[600 250]);
                    plots_subject=listdlg('liststring',dlg.uanalyses_long,'selectionmode','multiple','initialvalue',1:numel(dlg.uanalyses_long),'promptstring',{'Select plot(s) to include in SUBJECTS section','(in this section a separate plot per individual subject will be displayed)'},'ListSize',[600 250]);
                end
                if isempty(plots_summary)&&isempty(plots_subject), return; end
                [nill,nill,tfileext]=fileparts(tfilename);
                format=regexprep(tfileext,{'^\.','^tex$'},{'','latex'});
                invertim=get(dlg.handles.invertim,'value')==0;
                hmsg=conn_msgbox({sprintf('Generating %s report',format),'This may take several minutes. Please wait...'});
                cd(outputDir);
                if strcmp(format,'html')&&~isempty(which('private/mxdom2simplehtml.xsl')), 
                    stylesheet=conn_prepend('',fullfile(outputDir,tfilename),'_style.xsl');
                    stylestr=textread(which('private/mxdom2simplehtml.xsl'),'%s');
                    stylestr=regexprep(stylestr,'background:#fff',['background:#',sprintf('%x',ceil(figcolor*255))]);
                    tfh=fopen(stylesheet,'wt');for n1=1:numel(stylestr), fprintf(tfh,'%s\n',stylestr{n1}); end; fclose(tfh);
                    stylesheet={'stylesheet',stylesheet};
                else stylesheet={};
                end
                %
                filename=conn_prepend('',tfilename,'.m');
                tfh=fopen(filename,'wt');
                fprintf(tfh,'%%%% Quality Control report\n');
                fprintf(tfh,'%% %s\n',outputDir);
                fprintf(tfh,'%%\n%% auto-generated by <http://www.conn-toolbox.org CONN> @ %s\n',datestr(now));
                fprintf(tfh,'%%\n%% <matlab:conn_qaplotsexplore(''%s'') [open report in Matlab]>\n',regexprep(outputDir,' ','%20'));
                fprintf(tfh,'\n%%%% *SUMMARY PLOTS*\n');
                maxns=0;maxnm=0;
                for np=1:numel(dlg.uanalyses)
                    in=find(ismember(dlg.ianalyses,np));
                    usubjects_shown=unique(dlg.isubjects(in));
                    usessions_shown=unique(dlg.isessions(in));
                    umeasures_shown=unique(dlg.imeasures(in));
                    maxns=max(maxns,numel(usubjects_shown));
                    maxnm=max(maxnm,numel(umeasures_shown));
                    if ismember(np,plots_summary)
                        fprintf(tfh,'\n%%%% %s\n',dlg.uanalyses_long{np});
                        fprintf(tfh,'%% <matlab:options=conn_qaplotsexplore(''%s'');options(''plot'',%d);options(''selectall''); [open plot in Matlab]>\n',regexprep(outputDir,' ','%20'),np);
                        if numel(usubjects_shown)>1, fprintf(tfh,'%% %d subjects\n',numel(usubjects_shown)); end
                        if numel(usessions_shown)>1, fprintf(tfh,'%% %d sessions\n',numel(usessions_shown)); end
                        if numel(umeasures_shown)>1, fprintf(tfh,'%% %d measures\n',numel(umeasures_shown)); end
                        fprintf(tfh,'options=conn_qaplotsexplore(''%s'');\n',regexprep(outputDir,' ','%20'));
                        if invertim, fprintf(tfh,'options(''invertimage'',0);\n'); end
                        fprintf(tfh,'options(''plot'',%d);\n',np);
                        fprintf(tfh,'options(''selectall'');\n');
                        fprintf(tfh,'options(''displayannotation'');\n');
                        fprintf(tfh,'options(''togglegui'');\n');
                        fprintf(tfh,'snapnow;\n');
                        fprintf(tfh,'options(''close'');\n');
                    end
                end
                if ~isempty(plots_subject)
                    fprintf(tfh,'\n%%%% *INDIVIDUAL SUBJECT PLOTS*\n');
                    for np=plots_subject(:)'
                        in=find(ismember(dlg.ianalyses,np));
                        usubjects_shown=unique(dlg.isubjects(in));
                        usessions_shown=unique(dlg.isessions(in));
                        umeasures_shown=unique(dlg.imeasures(in));
                        if numel(usubjects_shown)>1||(numel(usubjects_shown)==1&&numel(umeasures_shown)==1)
                            for ns=1:numel(usubjects_shown)
                                fprintf(tfh,'\n%%%% %s (%s)\n',regexprep(dlg.uanalyses_long{np},'\(\d+\)\s*$',''),dlg.usubjects{usubjects_shown(ns)});
                                fprintf(tfh,'%% <matlab:options=conn_qaplotsexplore(''%s'');options(''plot'',%d);options(''preselectall'');options(''selectsubjects'',%d); [open plot in Matlab]>\n',regexprep(outputDir,' ','%20'),np,ns);
                                if ns==1,
                                    fprintf(tfh,'options=conn_qaplotsexplore(''%s'');\n',regexprep(outputDir,' ','%20'));
                                    if invertim, fprintf(tfh,'options(''invertimage'',0);\n'); end
                                    fprintf(tfh,'options(''plot'',%d);\n',np);
                                else fprintf(tfh,'options(''togglegui'');\n');
                                end
                                fprintf(tfh,'options(''preselectall'');\n');
                                fprintf(tfh,'options(''selectsubjects'',%d);\n',ns);
                                fprintf(tfh,'options(''displayannotation'');\n');
                                fprintf(tfh,'options(''togglegui'');\n');
                            end
                            fprintf(tfh,'snapnow;\n');
                            fprintf(tfh,'options(''close'');\n');
                        elseif numel(umeasures_shown)>1
                            for ns=1:numel(umeasures_shown)
                                fprintf(tfh,'\n%%%% %s (%s)\n',regexprep(dlg.uanalyses_long{np},'\(\d+\)\s*$',''),dlg.umeasures{umeasures_shown(ns)});
                                fprintf(tfh,'%% <matlab:options=conn_qaplotsexplore(''%s'');options(''plot'',%d);options(''preselectall'');options(''selectmeasures'',%d); [open plot in Matlab]>\n',regexprep(outputDir,' ','%20'),np,ns);
                                if ns==1,
                                    fprintf(tfh,'options=conn_qaplotsexplore(''%s'');\n',regexprep(outputDir,' ','%20'));
                                    if invertim, fprintf(tfh,'options(''invertimage'',0);\n'); end
                                    fprintf(tfh,'options(''plot'',%d);\n',np);
                                else fprintf(tfh,'options(''togglegui'');\n');
                                end
                                fprintf(tfh,'options(''preselectall'');\n');
                                fprintf(tfh,'options(''selectmeasures'',%d);\n',ns);
                                fprintf(tfh,'options(''displayannotation'');\n');
                                fprintf(tfh,'options(''togglegui'');\n');
                            end
                            fprintf(tfh,'snapnow;\n');
                            fprintf(tfh,'options(''close'');\n');
                        end
                    end
                end
                fclose(tfh);
                publish(filename,struct('format',format,stylesheet{:},'showCode',false,'useNewFigure',false,'figureSnapMethod','getframe','outputDir',outputDir));
                fprintf('Report created\nOpen %s to view\n',fullfile(outputDir,tfilename));
                if ishandle(hmsg), delete(hmsg); end
                switch(format)
                    case 'html', web(conn_prepend('',fullfile(outputDir,tfilename),'.html'));
                    case 'pdf',  if ispc, system(sprintf('open "%s"',fullfile(outputDir,tfilename))); 
                                 else system(sprintf('open ''%s''',fullfile(outputDir,tfilename))); 
                                 end
                    otherwise, try, system(sprintf('open %s',fullfile(outputDir,tfilename))); end
                end
                cd(cwd);
            case 'togglegui'
                if ~isfield(dlg,'togglegui')||isempty(dlg.togglegui)
                    h=findobj(dlg.handles.hfig,'type','uicontrol','visible','on');
                    if ishandle(dlg.handles.hax), pos=get(dlg.handles.hax,'position'); else pos=[]; end
                    dlg.togglegui=struct('handles',h,'position',pos);
                    set(dlg.togglegui.handles,'visible','off');
                    set(dlg.handles.hlabel,'visible','off');
                    if ishandle(dlg.handles.hax), set(dlg.handles.hax,'position',[.1 .2 .8 .7]); end
                else
                    set(dlg.togglegui.handles,'visible','on');
                    if ishandle(dlg.handles.hax)&&~isempty(dlg.togglegui.position), set(dlg.handles.hax,'position',dlg.togglegui.position); end
                    dlg.togglegui=[];
                end
            case 'annotate'
                descr=get(dlg.handles.han(end),'string');
                fname=dlg.files_txt{dlg.dataIDXplots(dlg.dataIDXsubjects)};
                dlg.txtA{dlg.dataIDXsubjects}=descr;
                fh=fopen(fname,'wt');
                for n=1:numel(descr), fprintf(fh,'%s\n',regexprep(descr{n},'\n','')); end
                fclose(fh);
            case 'invertimage',
                set(dlg.handles.invertim,'value',varargin{1});
            case {'preselectall','selectall'}
                set(dlg.handles.subjects,'value',1:numel(cellstr(get(dlg.handles.subjects,'string'))));
                set(dlg.handles.sessions,'value',1:numel(cellstr(get(dlg.handles.sessions,'string'))));
                set(dlg.handles.measures,'value',1:numel(cellstr(get(dlg.handles.measures,'string'))));
                if strcmpi(option,'selectall'), conn_qaplotsexplore_update([],[],'refresh'); end
            case 'selectsubjects'
                set(dlg.handles.subjects,'value',varargin{1});
                conn_qaplotsexplore_update([],[],'subjects');
            case 'selectsessions'
                set(dlg.handles.sessions,'value',varargin{1});
                conn_qaplotsexplore_update([],[],'sessions');
            case 'selectmeasures'
                set(dlg.handles.measures,'value',varargin{1});
                conn_qaplotsexplore_update([],[],'measures');
            case 'allsubjects'
                set(dlg.handles.subjects,'value',1:numel(cellstr(get(dlg.handles.subjects,'string'))));
                conn_qaplotsexplore_update([],[],'subjects');
            case 'allsessions'
                set(dlg.handles.sessions,'value',1:numel(cellstr(get(dlg.handles.sessions,'string'))));
                conn_qaplotsexplore_update([],[],'sessions');
            case 'allmeasures'
                set(dlg.handles.measures,'value',1:numel(cellstr(get(dlg.handles.measures,'string'))));
                conn_qaplotsexplore_update([],[],'measures');
            case 'textoptions',
                dlg.showavg=get(dlg.handles.textoptions,'value');
                conn_qaplotsexplore_update([],[],'subjects');
            case {'deleteset','newset','newsetinit'}
                if strcmp(lower(option),'deleteset')
                    answ=conn_questdlg(sprintf('Are you sure you want to delete report %s?',dlg.sets{dlg.iset}),'','Delete','Cancel','Delete');
                    if ~isequal(answ,'Delete'), return; end
                    f=conn_dir(fullfile(qafolder,dlg.sets{dlg.iset},'*'));
                    if ~isempty(f),
                        f=cellstr(f);
                        spm_unlink(f{:});
                    end
                    [ok,nill]=rmdir(fullfile(qafolder,dlg.sets{dlg.iset}));
                    tag='';
                else
                    if numel(varargin)>=1, answ={varargin{1}};
                    elseif strcmp(lower(option),'newsetinit'), answer={[]};
                    else answer=inputdlg({'Name of new QA report: (must be valid folder name)'},'',1,{datestr(now,'yyyy_mm_dd_HHMMSSFFF')});
                    end
                    if isempty(answer), return; end
                    if isempty(answer{1}), answer={datestr(now,'yyyy_mm_dd_HHMMSSFFF')}; end
                    tag=['QA_',answer{1}];
                    [ok,nill]=mkdir(qafolder,tag);
                end
                qagroups=conn_dir(fullfile(qafolder,'QA_*'),'-dir','-cell');
                dlg.sets=regexprep(cellfun(@(x)x(numel(qafolder)+1:end),qagroups,'uni',0),'^[\\\/]','');
                [nill,qanames]=cellfun(@fileparts,dlg.sets,'uni',0);
                dlg.iset=find(strcmp(qanames,tag),1);
                if isempty(dlg.iset), dlg.iset=1; end
                if ~strcmp(lower(option),'newsetinit')
                    set(dlg.handles.set,'string',dlg.sets);
                    conn_qaplotsexplore_update([],[],'set',dlg.iset);
                end
            case 'deleteplot'
                answ=conn_questdlg(sprintf('Are you sure you want to delete plot %s?',dlg.uanalyses_long{dlg.ianalysis}),'','Delete','Cancel','Delete');
                if ~isequal(answ,'Delete'), return; end
                in=find(ismember(dlg.ianalyses,dlg.ianalysis));
                tfiles={};
                for n=1:numel(in),
                    tfiles{end+1}=dlg.files_jpg{in(n)};
                    tfiles{end+1}=dlg.files{in(n)};
                end
                spm_unlink(tfiles{:});
                conn_qaplotsexplore_update([],[],'set');
            case {'newplot','recreateplot','recreateset'}
                if ~isCONN, conn_msgbox('Load existing CONN project before proceeding','Error',2); return; end
                tag=dlg.sets{dlg.iset};
                analyses={'QA_COV','QA_NORM_structural','QA_NORM_functional','QA_NORM_ROI','QA_REG_functional','QA_REG__structural','QA_REG__functional','QA_REG__mni','QA_COREG_functional','QA_TIME_functional','QA_TIMEART_functional','QA_DENOISE_timeseries','QA_DENOISE_QC-FC','QA_DENOISE','QA_DENOISE_scatterplot','QA_SPM_design','QA_SPM_contrasts'};
                %analyses_numbers=[31,1,2,3,10,4,5,6,7,8,9,12,13,11,14,21,22];
                defaultset=[1,2,9,11,12,13,31];
                if ~isfield(CONN_x,'isready')||~CONN_x.isready(2), 
                    dokeep=~cellfun('length',regexp(lower(analyses),'denoise'));
                    analyses=analyses(dokeep);%analyses_numbers=analyses_numbers(dokeep); % disable analyses that require having run Setup step
                end
                if isempty(CONN_x.Setup.spm)||isempty(CONN_x.Setup.spm{1})||isempty(CONN_x.Setup.spm{1}{1})
                    dokeep=~cellfun('length',regexp(lower(analyses),'spm'));
                    analyses=analyses(dokeep);%analyses_numbers=analyses_numbers(dokeep); % disable analyses that require SPM.mat files
                end
                [uanalyses_long,analyses_numbers]=conn_qaplotsexplore_translate(analyses);
                %uanalyses_long = regexprep(analyses,...
                %    {'^QA_NORM_(.*)','^QA_REG_functional','^QA_REG_(.*?)_?functional','^QA_REG_(.*?)_?structural','^QA_REG_(.*?)_?mni','^QA_COREG_(.*)','^QA_TIME_(.*)','^QA_TIMEART_(.*)','^QA_DENOISE_timeseries','^QA_DENOISE_QC-FC','^QA_DENOISE_scatterplot','^QA_DENOISE','^QA_SPM_design','^QA_SPM_contrasts'},...
                %    {'QA normalization: $1 data + outline of MNI TPM template','QA registration: functional data + structural overlay','QA registration: functional data + outline of ROI $1','QA registration: structural data + outline of ROI $1','QA registration: mni reference template + outline of ROI $1','QA realignment: $1 center-slice across multiple sessions/datasets','QA artifacts: $1 movie across all timepoints/acquisitions','QA artifacts: BOLD GS changes & subject motion timeseries with $1 movie','QA denoising: BOLD signal traces (carpetplot) before and after denoising + ART timeseries','QA denoising: distribution of QC-FC associations before and after denoising','QA denoising: scatterplot of functional correlations (FC) vs. distance (mm) before and after denoising','QA denoising: distribution of functional correlations (FC) before and after denoising','QA SPM design: review SPM first-level design matrix','QA SPM contrasts: review SPM first-level contrasts'});
                if strcmpi(option,'recreateset'), answ=find(ismember(analyses_numbers,dlg.uanalysesnumber)); 
                elseif strcmpi(option,'recreateplot'), answ=find(analyses_numbers==dlg.uanalysesnumber(dlg.ianalysis)); 
                elseif isempty(dlg.uanalyses), answ=find(ismember(analyses_numbers,defaultset)); 
                else answ=[]; 
                end
                if 1||isempty(answ), answ=listdlg('liststring',uanalyses_long,'selectionmode','multiple','initialvalue',answ,'promptstring','Select type of plot(s) to create:','ListSize',[600 250]); end
                if isempty(answ), return; end
                procedures=analyses_numbers(answ);
                validsets=[];
                if any(ismember(procedures,[2,7,8,9,10]))&&numel(CONN_x.Setup.secondarydataset)>0,
                    if numel(CONN_x.Setup.secondarydataset)==0, nalt=1;
                    else nalt=listdlg('liststring',arrayfun(@(n)sprintf('dataset %d',n),0:numel(CONN_x.Setup.secondarydataset),'uni',0),'selectionmode','multiple','initialvalue',min(2,numel(CONN_x.Setup.secondarydataset)+1),'promptstring',{'Select functional dataset(s)','to include in functional data plots:'},'ListSize',[300 200]);
                    end
                    if isempty(nalt), return; end
                    validsets=nalt-1;
                end
                validrois=[];
                if any(ismember(procedures,[3:6])),
                    %nalt=listdlg('liststring',CONN_x.Setup.rois.names(1:end-1),'selectionmode','multiple','initialvalue',2,'promptstring',{'Select ROI(s)','to include in ROI data plots:'},'ListSize',[300 200]);
                    nalt=listdlg('liststring',[CONN_x.Setup.rois.names(1:end-1), regexprep(CONN_x.Setup.rois.names(1:3),'^(.*)$','eroded $1')],'selectionmode','multiple','initialvalue',1,'promptstring',{'Select ROI(s)','to include in ROI data plots:'},'ListSize',[300 200]);
                    if isempty(nalt), return; end
                    temp=numel(CONN_x.Setup.rois.names)-1;
                    nalt(nalt>temp)=-(nalt(nalt>temp)-temp);
                    validrois=nalt;
                end
                nl2covariates=[];
                if any(ismember(procedures,[13,31]))
                    [x,nl2covariates]=conn_module('get','l2covariates','^[^_]');
                    if any(procedures==13), il2covariates=find(cellfun('length',regexp(nl2covariates,'^QC_.*(Motion|Global|GSchange|ValidScans)')));
                    else il2covariates=find(cellfun('length',regexp(nl2covariates,'^QC_')));
                    end
                    il2covariates=listdlg('liststring',nl2covariates,'selectionmode','multiple','initialvalue',il2covariates,'promptstring',{'Select QC variable(s)','to include in QC-FC analyses:'},'ListSize',[300 200]);
                    if isempty(il2covariates), return; end
                    nl2covariates=nl2covariates(il2covariates);
                end
                if CONN_x.Setup.nsubjects==1, nalt=1;
                else  nalt=listdlg('liststring',arrayfun(@(n)sprintf('subject %d',n),1:CONN_x.Setup.nsubjects,'uni',0),'selectionmode','multiple','initialvalue',1:CONN_x.Setup.nsubjects,'promptstring',{'Select subject(s)','to include in these plots:'},'ListSize',[300 200]);
                end
                if isempty(nalt), return; end
                validsubjects=nalt;
                conn_qaplots(fullfile(qafolder,tag),procedures,validsubjects,validrois,validsets,nl2covariates);
                conn_qaplotsexplore_update([],[],'set');
                conn_msgbox('Finished creating new plot','',2);                
                figure(dlg.handles.hfig);
            case 'displayannotation'
                if isfield(dlg,'dataIDXsubjects')
                    in=dlg.dataIDXsubjects;
                    if numel(in)==1
                        txt=dlg.txtA(in);
                    elseif numel(in)>1
                        txt=arrayfun(@(n)sprintf('%s %s %s: %s',dlg.usubjects{dlg.isubjects(dlg.dataIDXplots(n))},dlg.usessions{dlg.isessions(dlg.dataIDXplots(n))},dlg.umeasures{dlg.imeasures(dlg.dataIDXplots(n))},sprintf('%s ',dlg.txtA{n}{:})),in,'uni',0);
                    end
                    for n1=1:numel(txt), 
                        if ischar(txt{n1}), txt{n1}=cellstr(txt{n1}); end
                        for n2=1:numel(txt{n1})
                            if ~isempty(txt{n1}{n2})&&isempty(regexp(txt{n1}{n2},'\[empty\]$')), fprintf('%s\n',txt{n1}{n2}); end; 
                        end
                    end
                end
            case 'details'
                filename=dlg.filethis;
                if isempty(filename)||~conn_existfile(filename), conn_msgbox(sprintf('Data file %s not found',filename),'Details not available',2); 
                else
                    conn_bookmark('open',filename);
                    %load(filename,'state');
                    %conn_slice_display(state);
                end
                return;
                
            case 'set'
                if numel(varargin)>=1&&~isempty(varargin{1}), dlg.iset=varargin{1}; set(dlg.handles.set,'value',dlg.iset);
                else dlg.iset=get(dlg.handles.set,'value');
                end
                if isempty(dlg.sets), 
                    set(dlg.handles.settxt,'visible','on');
                    set([dlg.handles.set dlg.handles.deleteset dlg.handles.recomputeset dlg.handles.printset],'visible','off');
                    set(dlg.handles.addnewset,'fontweight','bold'); 
                    set([dlg.handles.selectall1 dlg.handles.selectall2 dlg.handles.selectall3 dlg.handles.subjects dlg.handles.sessions dlg.handles.measures dlg.handles.showdiff dlg.handles.showannot dlg.handles.invertim dlg.handles.analysis dlg.handles.analysistxt dlg.handles.addnewplot dlg.handles.deleteplot dlg.handles.recomputeplot dlg.handles.printplot dlg.handles.text1 dlg.handles.text2 dlg.handles.textoptions dlg.handles.details],'visible','off');
                    delete(dlg.handles.hax(ishandle(dlg.handles.hax)));
                    delete(dlg.handles.han(ishandle(dlg.handles.han)));
                    dlg.dispsize=[];
                    return
                else
                    set(dlg.handles.settxt,'visible','off');
                    set([dlg.handles.set dlg.handles.deleteset dlg.handles.recomputeset dlg.handles.printset],'visible','on');
                    set(dlg.handles.addnewset,'fontweight','normal'); 
                end
                qafiles=conn_dir(fullfile(qafolder,dlg.sets{dlg.iset},'QA_*.mat'));%,'-R'); % note: remove -R to allow search of recursive subfolders in "plots"
                if isempty(qafiles), qanames={};
                else qanames=cellstr(qafiles);
                end
                jpgok=cellfun(@(x)conn_existfile(x)|~isempty(regexp(x,'QA_DENOISE\.|QA_DENOISE_QC-FC\.|QA_DENOISE_scatterplot\.|QA_COV\.')),conn_prepend('',qanames,'.jpg'));
                txtok=cellfun(@(x)conn_existfile(x),conn_prepend('',qanames,'.txt'));
                qanames=qanames(jpgok);
                txtok=txtok(jpgok);
                dlg.files=qanames;
                dlg.files_jpg=conn_prepend('',qanames,'.jpg');
                dlg.files_txt=conn_prepend('',qanames,'.txt');
                if ~all(txtok),cellfun(@(s)fclose(fopen(s,'wt')),dlg.files_txt(~txtok),'uni',0); end
                if isempty(qanames)
                    qanames_parts1={};qanames_parts2={};qanames_parts3={};qanames_parts4={};
                else
                    [qafolders,qanames]=cellfun(@fileparts,qanames,'uni',0);
                    qanames=regexp(qanames,'\.','split');

                    qanames_parts=repmat({''},numel(qanames),3);
                    for n=1:numel(qanames), i=1:min(3,numel(qanames{n})); qanames_parts(n,i)=qanames{n}(i); end % analyses / subject /session
                    qanames_parts1=qanames_parts(:,1);
                    qanames_parts2=str2double(regexprep(qanames_parts(:,2),'^subject',''));
                    qanames_parts3=str2double(regexprep(qanames_parts(:,3),'^session',''));
                    qanames_parts4valid=cellfun('length',regexp(qanames_parts(:,2),'^measure'))>0;
                    qanames_parts4=regexprep(qanames_parts(:,2),'^measure','');
                    if numel(qafolders)>1&any(any(diff(char(qafolders),1,1))), 
                        tidx=find(any(diff(char(qafolders),1,1)),1);
                        if max(qanames_parts2)==1 % folders are subjects
                            [nill,nill,temp]=unique(qafolders);
                            qanames_parts2(qanames_parts2==1)=temp(qanames_parts2==1);
                        else                      % folders are plots
                            qanames_parts1=cellfun(@(a,b)sprintf('%s (%s)',a,b(min(numel(b),tidx):end)),qanames_parts1,qafolders,'uni',0);
                        end
                    end
                    qanames_parts2(isnan(qanames_parts2))=0;
                    qanames_parts3(isnan(qanames_parts3))=0;
                    [qanames_parts4{~qanames_parts4valid}]=deal('');
                end
                [dlg.uanalyses,nill,dlg.ianalyses]=unique(qanames_parts1);
                [dlg.usubjects,nill,dlg.isubjects]=unique(qanames_parts2);
                [dlg.usessions,nill,dlg.isessions]=unique(qanames_parts3);
                [dlg.umeasures,nill,dlg.imeasures]=unique(qanames_parts4);
                %dlg.uanalysestype=ones(size(dlg.uanalyses)); % QA_NORM/QA_REG/QA_COREG/QA_TIME/QA_TIMEART
                %dlg.uanalysestype(cellfun('length',regexp(dlg.uanalyses,'^QA_DENOISE$'))>0)=2; %QA_DENOISE_FC
                %dlg.uanalysestype(cellfun('length',regexp(dlg.uanalyses,'^QA_DENOISE_QC-FC$'))>0)=3; %QA_DENOISE_QC-FC
                %dlg.uanalysestype(cellfun('length',regexp(dlg.uanalyses,'^QA_DENOISE_scatterplot$'))>0)=4; %QA_DENOISE_scatterplot
                %dlg.uanalysestype(cellfun('length',regexp(dlg.uanalyses,'^QA_COV$'))>0)=5; %QA_COV
                if 1
                    dlg.usubjects=regexprep(arrayfun(@(n)sprintf('subject %d',n),dlg.usubjects,'uni',0),'^subject 0$','---');
                    dlg.usessions=regexprep(arrayfun(@(n)sprintf('session %d',n),dlg.usessions,'uni',0),'^session 0$','---');
                    %dlg.umeasures=regexprep(arrayfun(@(n)sprintf('measure %d',n),dlg.umeasures,'uni',0),'^measure 0$','---');
                end
                dlg.ianalysis=0; 
                [dlg.uanalyses_long,dlg.uanalysesnumber,dlg.uanalysestype]=conn_qaplotsexplore_translate(dlg.uanalyses);
                if dlg.forceinitdenoise, 
                    dlg.ianalysis=find(dlg.uanalysestype==2,1);
                    %if ~dlg.createdenoise&&~isempty(dlg.ianalysis)
                    %    answ=conn_questdlg({'Overwrite existing denoising plot?'},'','Yes','No','Yes');
                    %    if strcmp(answ,'Yes'), dlg.createdenoise=true; end
                    %end
                    if dlg.createdenoise||isempty(dlg.ianalysis)
                        conn_qaplots(fullfile(qafolder,dlg.sets{dlg.iset}),11);
                        conn_qaplotsexplore_update([],[],'set');
                        return;
                    end
                    if isempty(dlg.ianalysis), dlg.ianalysis=find(dlg.uanalysestype>1,1); end
                    dlg.forceinitdenoise=false;
                %else
                %    temp=find(dlg.uanalysestype>1,1); % note: tries loading denoising by default (faster)
                %    if ~isempty(temp), dlg.ianalysis=temp; end
                end
                if numel(dlg.uanalyses)==1, dlg.ianalysis=1; end
                %if ~isfield(dlg,'ianalysis')||isempty(dlg.ianalysis)||dlg.ianalysis<1||dlg.ianalysis>numel(dlg.uanalyses), dlg.ianalysis=1; end
                %dlg.uanalyses_long = regexprep(dlg.uanalyses,...
                %    {'^QA_NORM_(.*)','^QA_REG_functional','^QA_REG_(.*?)_?functional','^QA_REG_(.*?)_?structural','^QA_REG_(.*?)_?mni','^QA_COREG_(.*)','^QA_TIME_(.*)','^QA_TIMEART_(.*)','^QA_DENOISE_timeseries','^QA_DENOISE_QC-FC','^QA_DENOISE_scatterplot','^QA_DENOISE','^QA_SPM_design','^QA_SPM_contrasts'},...
                %    {'QA normalization: $1 data + outline of MNI TPM template','QA registration: functional data + structural overlay','QA registration: functional data + outline of ROI $1','QA registration: structural data + outline of ROI $1','QA registration: mni reference template + outline of ROI $1','QA realignment: $1 center-slice across multiple sessions/datasets','QA artifacts: $1 movie across all timepoints/acquisitions','QA artifacts: BOLD GS changes & subject motion timeseries with $1 movie','QA denoising: BOLD signal traces (carpetplot) before and after denoising + ART timeseries','QA denoising: distribution of QC-FC associations before and after denoising','QA denoising: scatterplot of functional correlations (FC) vs. distance (mm) before and after denoising','QA denoising: distribution of functional correlations (FC) before and after denoising','QA SPM design: review SPM first-level design matrix','QA SPM contrasts: review SPM first-level contrasts'});
                dlg.uanalyses_long=arrayfun(@(n,m)sprintf('%s (%d)',dlg.uanalyses_long{n},m),1:numel(dlg.uanalyses_long),accumarray(dlg.ianalyses(:),1)','uni',0);
                set(dlg.handles.analysis,'string',[{'<HTML><i>choose an existing QA plot to display</i></HTML>'},dlg.uanalyses_long],'value',dlg.ianalysis+1);
                conn_qaplotsexplore_update([],[],'plot');
                
            case 'plot'
                if numel(varargin)>=1, dlg.ianalysis=varargin{1}; set(dlg.handles.analysis,'value',dlg.ianalysis+1);
                else dlg.ianalysis=get(dlg.handles.analysis,'value')-1;
                end
                if isempty(dlg.sets)||isempty(dlg.uanalyses),
                    set([dlg.handles.selectall1 dlg.handles.selectall2 dlg.handles.selectall3 dlg.handles.subjects dlg.handles.sessions dlg.handles.measures dlg.handles.showdiff dlg.handles.showannot dlg.handles.invertim dlg.handles.analysis dlg.handles.text1 dlg.handles.text2 dlg.handles.textoptions dlg.handles.details],'visible','off'); 
                    delete(dlg.handles.hax(ishandle(dlg.handles.hax)));
                    delete(dlg.handles.han(ishandle(dlg.handles.han)));
                    set([dlg.handles.analysis dlg.handles.deleteplot dlg.handles.recomputeplot dlg.handles.printplot dlg.handles.recomputeset dlg.handles.printset],'visible','off')
                    set(dlg.handles.analysistxt,'visible','on'); 
                    set(dlg.handles.addnewplot,'fontweight','bold','visible','on'); 
                    dlg.dispsize=[];
                    return;
                else
                    set([dlg.handles.selectall1 dlg.handles.selectall2 dlg.handles.selectall3 dlg.handles.subjects dlg.handles.sessions dlg.handles.measures dlg.handles.analysis dlg.handles.deleteplot dlg.handles.recomputeplot dlg.handles.printplot dlg.handles.recomputeset dlg.handles.printset],'visible','on')
                    set(dlg.handles.analysistxt,'visible','off');
                    set(dlg.handles.addnewplot,'fontweight','normal','visible','on');
                end
                if isequal(dlg.ianalysis,0)
                    set([dlg.handles.selectall1 dlg.handles.selectall2 dlg.handles.selectall3 dlg.handles.subjects dlg.handles.sessions dlg.handles.measures dlg.handles.showdiff dlg.handles.showannot dlg.handles.invertim dlg.handles.text1 dlg.handles.text2 dlg.handles.textoptions,dlg.handles.details,dlg.handles.deleteplot dlg.handles.recomputeplot dlg.handles.printplot],'visible','off'); 
                    delete(dlg.handles.hax(ishandle(dlg.handles.hax)));
                    delete(dlg.handles.han(ishandle(dlg.handles.han)));
                elseif dlg.uanalysestype(dlg.ianalysis)==1 % QA_NORM/QA_REG/QA_COREG/QA_TIME/QA_TIMEART
                    set([dlg.handles.subjects dlg.handles.sessions dlg.handles.measures dlg.handles.selectall1 dlg.handles.selectall2 dlg.handles.selectall3],'visible','off');
                    set([dlg.handles.showdiff dlg.handles.showannot dlg.handles.invertim],'visible','off');
                    set(dlg.handles.hfig,'pointer','watch');
                    in=find(ismember(dlg.ianalyses,dlg.ianalysis));% & ismember(dlg.isubjects, dlg.isubject) & ismember(dlg.isessions, dlg.isession);
                    %ht=conn_msgbox(sprintf('Loading %d plots. Please wait...',numel(in)),'');
                    ht=conn_waitbar(0,sprintf('Loading %d plots. Please wait...',numel(in)));
                    dlg.dataA=[];
                    dlg.txtA={};
                    dlg.dataIDXplots=in;
                    for n=1:numel(in),
                        data=imread(dlg.files_jpg{in(n)});
                        if isa(data,'uint8'), data=double(data)/255; end
                        if isempty(dlg.dataA), dlg.dataA=zeros([size(data,1),size(data,2),size(data,3),numel(in)]); end
                        if size(data,1)>size(dlg.dataA,1), dlg.dataA(size(data,1),1,1,1)=0; end
                        if size(data,2)>size(dlg.dataA,2), dlg.dataA(1,size(data,2),1,1)=0; end
                        if size(data,3)>size(dlg.dataA,3), dlg.dataA(1,1,size(data,3),1)=0; end
                        if size(dlg.dataA,1)>size(data,1), data(size(dlg.dataA,1),1,1,1)=0; end
                        if size(dlg.dataA,2)>size(data,2), data(1,size(dlg.dataA,2),1,1)=0; end
                        if size(dlg.dataA,3)>size(data,3), data(1,1,size(dlg.dataA,3),1)=0; end
                        %if mean(data(:))<.5, data=1-data; end
                        %if size(data,3)==3, data=data.*repmat(shiftdim(figcolor,-1),[size(data,1),size(data,2)]); end
                        dlg.dataA(:,:,:,n)=data;
                        descr = fileread(dlg.files_txt{in(n)});
                        if isempty(descr), dlg.txtA{n}={'[empty]'}; 
                        else dlg.txtA{n}=regexp(descr,'\n+','split');
                        end
                        conn_waitbar(n/numel(in),ht);
                    end
                    dlg.dataM=mean(dlg.dataA,4);
                    dlg.dataD=abs(dlg.dataA-repmat(dlg.dataM,[1,1,1,size(dlg.dataA,4)]));
                    dlg.dataS=sqrt(mean(dlg.dataD.^2,4)); %std(dlg.dataA,1,4);
                    temp=repmat(convn(convn(sum(dlg.dataS.^2,3),conn_hanning(3)/2,'same'),conn_hanning(3)'/2,'same'),[1,1,1,size(dlg.dataA,4)]);
                    dlg.dataD=sqrt(convn(convn(sum(dlg.dataD.^2,3),conn_hanning(3)/2,'same'),conn_hanning(3)'/2,'same')./max(eps,.01*mean(temp(:))+temp));
                    [dlg.dataDmax,dlg.dataDidx]=max(dlg.dataD,[],4);
                    conn_waitbar('close',ht);
                    %if ishandle(ht),delete(ht); end
                    if ~ishandle(dlg.handles.hfig), return; end
                    dlg.usubjects_shown=unique(dlg.isubjects(in));
                    set(dlg.handles.subjects,'string',dlg.usubjects(dlg.usubjects_shown),'value',unique(max(1,min(numel(dlg.usubjects_shown),get(dlg.handles.subjects,'value')))));
                    dlg.usessions_shown=unique(dlg.isessions(in));
                    set(dlg.handles.sessions,'string',dlg.usessions(dlg.usessions_shown),'value',unique(max(1,min(numel(dlg.usessions_shown),get(dlg.handles.sessions,'value')))));
                    dlg.umeasures_shown=unique(dlg.imeasures(in));
                    set(dlg.handles.measures,'string',dlg.umeasures(dlg.umeasures_shown),'value',unique(max(1,min(numel(dlg.umeasures_shown),get(dlg.handles.measures,'value')))));
                    set([dlg.handles.showdiff dlg.handles.showannot dlg.handles.invertim dlg.handles.analysis],'visible','on');
                    conn_qaplotsexplore_update([],[],'subjects');
                    set(dlg.handles.hfig,'pointer','arrow');
                elseif dlg.uanalysestype(dlg.ianalysis)>1 %QA_DENOISE/QA_COV
                    set([dlg.handles.subjects dlg.handles.sessions dlg.handles.measures dlg.handles.selectall1 dlg.handles.selectall2 dlg.handles.selectall3],'visible','off');
                    set([dlg.handles.showdiff dlg.handles.showannot dlg.handles.invertim dlg.handles.text1 dlg.handles.text2 dlg.handles.textoptions dlg.handles.details],'visible','off');
                    set(dlg.handles.hfig,'pointer','watch');
                    in=find(ismember(dlg.ianalyses,dlg.ianalysis));% & ismember(dlg.isubjects, dlg.isubject) & ismember(dlg.isessions, dlg.isession);
                    %ht=conn_msgbox(sprintf('Loading %d plots. Please wait...',numel(in)),''); 
                    ht=conn_waitbar(0,sprintf('Loading %d plots. Please wait...',numel(in)));
                    dlg.dataA={};
                    dlg.labelA={};
                    dlg.infoA={};
                    dlg.lineA={};
                    %dlg.dataB={};
                    dlg.dataIDXplots=in;
                    for n=1:numel(in),
                        data=load(dlg.files{in(n)});
                        dlg.dataA{n}=data.results_patch;
                        %dlg.dataB{n}=data.results_label;
                        descr = fileread(dlg.files_txt{in(n)});
                        if isfield(data,'results_label'), dlg.labelA{n}=data.results_label; 
                        else dlg.labelA{n}='';
                        end
                        if isfield(data,'results_info'), dlg.infoA{n}=data.results_info; 
                        else dlg.infoA{n}=[];
                        end
                        if isfield(data,'results_line'), dlg.lineA{n}=data.results_line; 
                        else dlg.lineA{n}=[];
                        end
                        if isempty(descr), dlg.txtA{n}={'[empty]'}; 
                        else dlg.txtA{n}=regexp(descr,'\n+','split');
                        end
                        conn_waitbar(n/numel(in),ht);
                    end
                    miny=inf(1,numel(dlg.dataA{1})); maxy=-inf(1,numel(dlg.dataA{1}));
                    for n=1:numel(dlg.dataA), miny=min(miny,cellfun(@(x)min(x(:)),dlg.dataA{n})); maxy=max(maxy,cellfun(@(x)max(x(:)),dlg.dataA{n})); end
                    %miny1=inf;miny2=inf;miny3=inf;maxy1=0;maxy2=0;maxy3=0;
                    %for n=1:numel(dlg.dataA), miny1=min(miny1,min(dlg.dataA{n}{1})); miny2=min(miny2,min(dlg.dataA{n}{2})); miny3=min(miny3,min(dlg.dataA{n}{3})); maxy1=max(maxy1,max(dlg.dataA{n}{1})); maxy2=max(maxy2,max(dlg.dataA{n}{2})); maxy3=max(maxy3,max(dlg.dataA{n}{3})); end
                    dlg.plotminmax=[miny; maxy]; %[miny1 miny2 miny3; maxy1 maxy2 maxy3];
                    dlg.plothistinfo=[0 maxy(2)*1.1 (maxy(2)+maxy(min(numel(maxy),3)))*1.1 max(maxy(2),maxy(min(numel(maxy),3))) maxy(1)*1.1];
                    %if ishandle(ht),delete(ht); end
                    conn_waitbar('close',ht);
                    if ~ishandle(dlg.handles.hfig), return; end
                    dlg.usubjects_shown=unique(dlg.isubjects(in));
                    set(dlg.handles.subjects,'string',dlg.usubjects(dlg.usubjects_shown),'value',unique(max(1,min(numel(dlg.usubjects_shown),get(dlg.handles.subjects,'value')))));
                    dlg.usessions_shown=unique(dlg.isessions(in));
                    set(dlg.handles.sessions,'string',dlg.usessions(dlg.usessions_shown),'value',unique(max(1,min(numel(dlg.usessions_shown),get(dlg.handles.sessions,'value')))));
                    dlg.umeasures_shown=unique(dlg.imeasures(in));
                    set(dlg.handles.measures,'string',dlg.umeasures(dlg.umeasures_shown),'value',unique(max(1,min(numel(dlg.umeasures_shown),get(dlg.handles.measures,'value')))));
                    set(dlg.handles.showannot,'visible','on');
                    conn_qaplotsexplore_update([],[],'subjects');
                    set(dlg.handles.hfig,'pointer','arrow');
                end
                
            case {'subjects','sessions','measures','selectannotation','refresh'}
                if isempty(dlg.sets)||isempty(dlg.uanalyses), return; end
                if isequal(dlg.ianalysis,0)
                        delete(dlg.handles.hax(ishandle(dlg.handles.hax)));
                        delete(dlg.handles.han(ishandle(dlg.handles.han)));
                    return; 
                elseif isempty(dlg.usubjects_shown)||isempty(dlg.usessions_shown)||isempty(dlg.umeasures_shown), 
                        delete(dlg.handles.hax(ishandle(dlg.handles.hax)));
                        delete(dlg.handles.han(ishandle(dlg.handles.han)));
                        set([dlg.handles.text1 dlg.handles.text2 dlg.handles.textoptions dlg.handles.details],'visible','off');
                    return; 
                end
                isvisible=[numel(dlg.usubjects_shown)>=2 numel(dlg.usessions_shown)>=2 numel(dlg.umeasures_shown)>=2];
                %.73 .57 - .51 .41 - .35 .25
                set([dlg.handles.subjects dlg.handles.sessions dlg.handles.measures dlg.handles.selectall1 dlg.handles.selectall2 dlg.handles.selectall3],'visible','off'); 
                if isvisible(1), set(dlg.handles.subjects,'position',[.035,.57*isvisible(2)+.41*~isvisible(2)*isvisible(3)+.25*~isvisible(2)*~isvisible(3),.1,.16*isvisible(2)+.32*~isvisible(2)*isvisible(3)+.48*~isvisible(2)*~isvisible(3)]); end
                if isvisible(2), set(dlg.handles.sessions,'position',[.035,.41*isvisible(3)+.25*~isvisible(3),.1,.10*isvisible(3)+.26*~isvisible(3)+~.22*isvisible(1)]); end
                if isvisible(3), set(dlg.handles.measures,'position',[.035,.25,.1,.10*isvisible(2)+.26*~isvisible(2)*isvisible(1)+.48*~isvisible(2)*~isvisible(1)]); end
                set(dlg.handles.selectall1,'position',get(dlg.handles.subjects,'position').*[1 1 1 0]+[0 -.05 0 .05]);
                set(dlg.handles.selectall2,'position',get(dlg.handles.sessions,'position').*[1 1 1 0]+[0 -.05 0 .05]);
                set(dlg.handles.selectall3,'position',get(dlg.handles.measures,'position').*[1 1 1 0]+[0 -.05 0 .05]);
                if isvisible(1), set([dlg.handles.subjects dlg.handles.selectall1],'visible','on'); end
                if isvisible(2), set([dlg.handles.sessions dlg.handles.selectall2],'visible','on'); end
                if isvisible(3), set([dlg.handles.measures dlg.handles.selectall3],'visible','on'); end
                if strcmp(lower(option),'selectannotation')
                   n=get(dlg.handles.han(end),'value');
                   subjects=dlg.isubjects(dlg.dataIDXplots(dlg.dataIDXsubjects(n)));
                   sessions=dlg.isessions(dlg.dataIDXplots(dlg.dataIDXsubjects(n)));
                   measures=dlg.imeasures(dlg.dataIDXplots(dlg.dataIDXsubjects(n)));
                   set(dlg.handles.subjects,'value',find(dlg.usubjects_shown==subjects));
                   set(dlg.handles.sessions,'value',find(dlg.usessions_shown==sessions));
                   set(dlg.handles.measures,'value',find(dlg.umeasures_shown==measures));
                 else
                    subjects=get(dlg.handles.subjects,'value');
                    sessions=get(dlg.handles.sessions,'value');
                    measures=get(dlg.handles.measures,'value');
                    if isempty(subjects)||any(subjects>numel(dlg.usubjects_shown)), subjects=1:numel(dlg.usubjects_shown); set(dlg.handles.subjects,'value',subjects); end
                    if isempty(sessions)||any(sessions>numel(dlg.usessions_shown)), sessions=1:numel(dlg.usessions_shown); set(dlg.handles.sessions,'value',sessions); end
                    if isempty(measures)||any(measures>numel(dlg.umeasures_shown)), measures=1:numel(dlg.umeasures_shown); set(dlg.handles.measures,'value',measures); end
                    subjects=dlg.usubjects_shown(subjects);
                    sessions=dlg.usessions_shown(sessions);
                    measures=dlg.umeasures_shown(measures);
                end
                in=find(ismember(dlg.isubjects(dlg.dataIDXplots),subjects)&ismember(dlg.isessions(dlg.dataIDXplots),sessions)&ismember(dlg.imeasures(dlg.dataIDXplots),measures));
                dlg.dataIDXsubjects=in;
                switch(dlg.uanalysestype(dlg.ianalysis))
                    case 1,
                        if numel(in)>1, set(dlg.handles.text1,'string','computing. please wait...','visible','on');set(dlg.handles.textoptions,'visible','off');set(dlg.handles.text2,'visible','off'); drawnow; end
                        if size(dlg.dataA,4)>1, 
                            set(dlg.handles.showdiff,'visible','on');
                            showdiff=get(dlg.handles.showdiff,'value');
                        else
                            set(dlg.handles.showdiff,'visible','off');
                            showdiff=false;
                        end
                        val=(numel(in)>1)*dlg.showavg + (numel(in)<=1);
                        delete(dlg.handles.hax(ishandle(dlg.handles.hax)));
                        pos=[.20 .10 .75 .65]; 
                        if get(dlg.handles.showannot,'value'), pos=[pos(1)+.225 pos(2) pos(3)-.20 pos(4)]; end
                        dlg.handles.hax=axes('units','norm','position',pos,'color',figcolor,'visible','off','parent',dlg.handles.hfig);
                        switch(val)
                            case {1,2,3},
                                if showdiff, data=dlg.dataD;
                                else data=dlg.dataA;
                                end
                                if val==1,
                                    if ~showdiff&&isequal(in(:)',1:size(data,4)), data=dlg.dataM;
                                    else data=mean(data(:,:,:,in),4);
                                    end
                                    dlg.dispsize=[size(data,2) size(data,1)];
                                elseif val==2,
                                    if ~showdiff&&isequal(in(:)',1:size(data,4)), data=dlg.dataS;
                                    else data=std(data(:,:,:,in),1,4);
                                    end
                                    data=sqrt(sum(data.^2,3));
                                    data=data/max(data(:));
                                    dlg.dispsize=[size(data,2) size(data,1)];
                                elseif val==3,
                                    data=data(:,:,:,in);
                                end
                                if get(dlg.handles.invertim,'value')>0,
                                    if size(data,3)==3&&min(data(:))>=0&&max(data(:))<=1, 
                                        maxdata=mode(round(data(:)*100))/100;
                                        if maxdata<.5, data=1-data; maxdata=1-maxdata; end
                                        data=max(0,min(1, data/maxdata.*repmat(shiftdim(figcolor,-1),[size(data,1),size(data,2),1,size(data,4)]) ));
                                    elseif size(data,3)==1, data=-data;
                                    end
                                end
                                [data,dlg.dispsize]=conn_menu_montage(dlg.handles.hax,data);
                                masknan=find(any(isnan(data),3)); if ~isempty(masknan), mostnan=data(1,1,:); for n=1:size(data,3), data(masknan+(n-1)*size(data,1)*size(data,2))=mostnan(n); end; end
                                cla(dlg.handles.hax); 
                                him=imagesc(data,'parent',dlg.handles.hax);
                                axis(dlg.handles.hax,'equal');
                                set(dlg.handles.hax,'ydir','reverse','visible','off');
                                %if numel(in)==1, set(him,'buttondownfcn',{@conn_qaplotsexplore_update,'details'} ); 
                                %else set(him,'buttondownfcn','disp(''select individual subject/session first'')'); 
                                %end
                            case 4, % placeholder
                                data=reshape(dlg.dataD(:,:,:,in),[],numel(in));
                                cla(dlg.handles.hax);
                                for n=1:size(data,2),
                                    [b,a]=hist(log10(data(data(:,n)>0,n)),linspace(-3,1,100));
                                    plot(a,b,'parent',dlg.handles.hax);
                                    hold(dlg.handles.hax,'on');
                                end
                                hold(dlg.handles.hax,'off');
                        end
                        if numel(in)==1,
                            if showdiff, str='z-map of '; else str=''; end
                            [tpath,tstr]=fileparts(dlg.files_jpg{dlg.dataIDXplots(in)});
                            set(dlg.handles.text1,'string',[str,tstr],'visible','on');
                            set(dlg.handles.text2,'string',tpath,'visible','on');
                            set(dlg.handles.textoptions,'visible','off');
                            dlg.filethis=dlg.files{dlg.dataIDXplots(in)};
                            set([dlg.handles.details],'visible','on');
                            %if conn_existfile(fullfile(qafolder,dlg.sets{dlg.iset},conn_prepend('',dlg.filethis,'.mat'))), set(dlg.handles.details,'visible','on'); else set(dlg.handles.details,'visible','on'); end
                        else
                            set([dlg.handles.text1 dlg.handles.text2],'visible','off');
                            if showdiff, str='z-maps'; else str='images'; end
                            set(dlg.handles.textoptions,'visible','on','value',dlg.showavg,'string',{sprintf('average of %d %s',numel(in),str),sprintf('variability of %d %s',numel(in),str),sprintf('Montage of %d %s',numel(in),str)});
                            set([dlg.handles.details],'visible','off');
                            dlg.filethis='';
                        end
                        
                    case {2,3,4} % QA_DENOISE
                        delete(dlg.handles.hax(ishandle(dlg.handles.hax)));
                        pos=[.30 .175 .55 .575]; 
                        if get(dlg.handles.showannot,'value'), pos=[pos(1)+.225 pos(2) pos(3)-.20 pos(4)]; end
                        dlg.handles.hax=axes('units','norm','position',pos,'color',figcolor,'visible','off','parent',dlg.handles.hfig);
                        dlg.results_patch=dlg.dataA(in); %%%
                        dlg.results_label=dlg.labelA(in);
                        dlg.results_info=dlg.infoA(in);
                        dlg.results_line=dlg.lineA(in);
                        dlg.handles.resultspatch=[];
                        dlg.handles.resultsline=[];
                        hold(dlg.handles.hax,'on');
                        if dlg.uanalysestype(dlg.ianalysis)==4, dlg.plothistinfo2=dlg.plothistinfo(5); dlg.plothistinfo3=2*dlg.plothistinfo2; dlg.plothistinfo4=dlg.plothistinfo2;
                        else dlg.plothistinfo2=dlg.plothistinfo(2); dlg.plothistinfo3=dlg.plothistinfo(3); dlg.plothistinfo4=dlg.plothistinfo(4);
                        end
                        refshow1=0;refshow1n=0;refshow2=0;refshow2n=0;
                        for n=1:numel(dlg.results_patch),
                            if dlg.uanalysestype(dlg.ianalysis)==4,
                                dlg.handles.resultspatch(n,1)=patch(dlg.results_patch{n}{3},dlg.results_patch{n}{1}+dlg.plothistinfo2,'k','edgecolor','none','linestyle',':','facecolor',.9*[.8 .8 1],'facealpha',.25,'parent',dlg.handles.hax); % title('Connectivity histogram before denoising'); xlabel('Correlation (r)');
                                dlg.handles.resultspatch(n,2)=patch(dlg.results_patch{n}{2},dlg.results_patch{n}{1},'k','edgecolor','none','linestyle',':','facecolor',.9*[.8 .8 1],'facealpha',.25,'parent',dlg.handles.hax); %title('Connectivity histogram after denoising'); xlabel('Correlation (r)');
                            else
                                dlg.handles.resultspatch(n,1)=patch(dlg.results_patch{n}{1},dlg.results_patch{n}{3}+dlg.plothistinfo2,'k','edgecolor','k','linestyle',':','facecolor',.9*[.8 .8 1],'facealpha',.25,'parent',dlg.handles.hax); % title('Connectivity histogram before denoising'); xlabel('Correlation (r)');
                                dlg.handles.resultspatch(n,2)=patch(dlg.results_patch{n}{1},dlg.results_patch{n}{2},'k','edgecolor','k','linestyle',':','facecolor',.9*[.8 .8 1],'facealpha',.25,'parent',dlg.handles.hax); %title('Connectivity histogram after denoising'); xlabel('Correlation (r)');
                            end
                            if numel(dlg.results_patch{n})>4
                                refshow2=refshow2+dlg.results_patch{n}{5}; refshow2n=refshow2n+1;
                                refshow1=refshow1+dlg.results_patch{n}{4}; refshow1n=refshow1n+1;
                            end
                        end
                        for n=1:numel(dlg.results_patch),
                            if numel(dlg.results_line)>=n&&~isempty(dlg.results_line{n})
                                dlg.handles.resultsline(n,1)=plot(dlg.results_line{n}{2},dlg.results_line{n}{1},'k-','linewidth',1,'color',.75*[.8 .8 1],'parent',dlg.handles.hax);
                                dlg.handles.resultsline(n,2)=plot(dlg.results_line{n}{3},dlg.plothistinfo2+dlg.results_line{n}{1},'k-','linewidth',1,'color',.75*[.8 .8 1],'parent',dlg.handles.hax);
                            end
                        end
                        plot([-1 1 nan -1 1],[0 0 nan dlg.plothistinfo2 dlg.plothistinfo2],'k-','linewidth',1,'parent',dlg.handles.hax);
                        if numel(dlg.results_line)>0
                            dlg.handles.resultsline_add=[plot(0,0,'k-','visible','off','parent',dlg.handles.hax), plot(0,0,'k-','visible','off','parent',dlg.handles.hax)];
                        else dlg.handles.resultsline_add=[];
                        end
                        if numel(dlg.results_patch)>0
                            if dlg.uanalysestype(dlg.ianalysis)==4,
                                dlg.handles.resultspatch_add=[patch(dlg.results_patch{n}{2},dlg.results_patch{n}{1},'k','edgecolor','none','linestyle','-','facecolor','k','facealpha',.25','visible','off','parent',dlg.handles.hax),...
                                    patch(dlg.results_patch{n}{2},dlg.results_patch{n}{1},'k','edgecolor','none','linestyle','-','facecolor','k','facealpha',.25,'visible','off','parent',dlg.handles.hax)];
                            else
                                dlg.handles.resultspatch_add=[patch(dlg.results_patch{n}{1},dlg.results_patch{n}{2},'k','edgecolor','k','linestyle','-','facecolor','k','facealpha',.25','visible','off','parent',dlg.handles.hax),...
                                    patch(dlg.results_patch{n}{1},dlg.results_patch{n}{2},'k','edgecolor','k','linestyle','-','facecolor','k','facealpha',.25,'visible','off','parent',dlg.handles.hax)];
                            end
                            if refshow1n
                                plot(dlg.results_patch{n}{1},refshow2/refshow2n+dlg.plothistinfo2,'k--','linewidth',2,'parent',dlg.handles.hax);
                                ht=plot(dlg.results_patch{n}{1},refshow1/refshow1n,'k--','linewidth',2,'parent',dlg.handles.hax);
                                try, ht=legend(ht,'expected distribution under no QC-FC associations (permutation test)','location','northwest'); set(ht,'box','off','fontsize',5+font_offset); catch, legend(ht,'randomised reference'); end
                            else
                                %plot([0 0],[0 dlg.plothistinfo3],'k-','linewidth',1);
                            end
                        else dlg.handles.resultspatch_add=[];
                        end
                        %plot([-1 1;-1 1],[ylim;ylim]','k-',[-1 -1;1 1],[ylim;ylim],'k-');
                        
                        text(0,-dlg.plothistinfo3*.1,'Correlation coefficients (r)','horizontalalignment','center','fontsize',11+font_offset,'parent',dlg.handles.hax);
                        text(-.95,dlg.plothistinfo2*.25,'After denoising','horizontalalignment','left','fontsize',10+font_offset,'fontweight','bold','parent',dlg.handles.hax);
                        text(-.95,dlg.plothistinfo2+(dlg.plothistinfo3-dlg.plothistinfo2)*.25,'Before denoising','horizontalalignment','left','fontsize',10+font_offset,'fontweight','bold','parent',dlg.handles.hax);
                        if numel(in)==1, 
                            ttitle=dlg.results_label{1};
                            tlabel={};
                            if iscell(ttitle), tlabel=ttitle(2:end); ttitle=ttitle{1}; end
                            text(0,-dlg.plothistinfo3*.175,tlabel,'horizontalalignment','center','fontsize',5+font_offset,'interpreter','none','parent',dlg.handles.hax); 
                            if ~isempty(dlg.results_info)&&isstruct(dlg.results_info{1}), 
                                text(-.95,dlg.plothistinfo2*.25-min(dlg.plothistinfo2,dlg.plothistinfo3-dlg.plothistinfo2)*.10,{sprintf('%.2f%c%.2f',dlg.results_info{1}.MeanAfter,177,dlg.results_info{1}.StdAfter)},'horizontalalignment','left','fontsize',7+font_offset,'parent',dlg.handles.hax);
                                text(-.95,dlg.plothistinfo2+(dlg.plothistinfo3-dlg.plothistinfo2)*.25-min(dlg.plothistinfo2,dlg.plothistinfo3-dlg.plothistinfo2)*.10,{sprintf('%.2f%c%.2f',dlg.results_info{1}.MeanBefore,177,dlg.results_info{1}.StdBefore)},'horizontalalignment','left','fontsize',7+font_offset,'parent',dlg.handles.hax); 
                            end
                            if ~isempty(ttitle), text(0,dlg.plothistinfo3*1.05,ttitle,'horizontalalignment','center','fontsize',10+font_offset,'fontweight','bold','interpreter','none','parent',dlg.handles.hax); end
                        end
                        if dlg.uanalysestype(dlg.ianalysis)==4, 
                            plot([.99 1 1 .99 nan .99 1 1 .99],[dlg.plotminmax([1 1 2 2],1)' nan dlg.plothistinfo2+dlg.plotminmax([1 1 2 2],1)'],'k-','linewidth',1,'parent',dlg.handles.hax);
                            text(1.05*[1 1 1 1],[dlg.plotminmax(1:2,1)' dlg.plothistinfo2+dlg.plotminmax(1:2,1)'],arrayfun(@(n)sprintf('%d mm',round(n)),[dlg.plotminmax(1:2,1)' dlg.plotminmax(1:2,1)'],'uni',0),'parent',dlg.handles.hax);
                            text(1.10,dlg.plothistinfo2/2,'Distance (mm)','rotation',90,'horizontalalignment','center','fontsize',11+font_offset,'parent',dlg.handles.hax);
                            text(1.10,dlg.plothistinfo2*1.5,'Distance (mm)','rotation',90,'horizontalalignment','center','fontsize',11+font_offset,'parent',dlg.handles.hax);
                        end
                        hold(dlg.handles.hax,'off');
                        if dlg.uanalysestype(dlg.ianalysis)==4, set(dlg.handles.hax,'ylim',[0 2*dlg.plothistinfo2]);
                        else set(dlg.handles.hax,'ylim',dlg.plothistinfo([1 3]))
                        end
                        set(dlg.handles.hax,'xlim',[-1,1],'ytick',[],'ycolor',figcolor,'ydir','normal','visible','on');
                    case 5 % QA_COV
                        delete(dlg.handles.hax(ishandle(dlg.handles.hax)));
                        pos=[.30 .175 .55 .575]; 
                        if get(dlg.handles.showannot,'value'), pos=[pos(1)+.225 pos(2) pos(3)-.20 pos(4)]; end
                        dlg.plothistinfo4=1;
                        dlg.handles.hax=axes('units','norm','position',pos,'color',figcolor,'visible','off','parent',dlg.handles.hfig);
                        dlg.results_patch=dlg.dataA(in); %%%
                        dlg.results_label=dlg.labelA(in);
                        dlg.results_info=dlg.infoA(in);
                        dlg.results_line=dlg.lineA(in);
                        dlg.handles.resultspatch=[];
                        dlg.handles.resultsline=[];
                        hold(dlg.handles.hax,'on');
                        refshow1=0;refshow1n=0;refshow2=0;refshow2n=0;
                        dlg.handles.resultspatch=[];
                        tx=[];ty=[];
                        for n=1:numel(dlg.results_patch),
                            if numel(in)>1
                                mask=dlg.results_line{n}{2}>dlg.results_info{n}.InterquartilesDisplay(5,:) | dlg.results_line{n}{2}<dlg.results_info{n}.InterquartilesDisplay(1,:);
                                if nnz(mask), 
                                    ttx=reshape(dlg.results_line{n}{1}(mask),[],1);
                                    tty=reshape(dlg.results_line{n}{2}(mask),[],1);
                                    plot([ttx ttx-.25]',[tty tty+sign(tty-.5)*.05]','-','color',.5*[.8 .8 1],'parent',dlg.handles.hax); 
                                    text(ttx-.25,tty+sign(tty-.5)*.05,regexprep(dlg.results_label{n}{1}{1},'^Subject ','S'),'color',.5*[.8 .8 1],'horizontalalignment','right','fontsize',5+font_offset,'parent',dlg.handles.hax); 
                                end
                            end
                            if ~isequal(tx,dlg.results_patch{n}{1})||~isequal(ty,dlg.results_patch{n}{2});
                                tx=dlg.results_patch{n}{1};
                                ty=dlg.results_patch{n}{2};
                                dlg.handles.resultspatch(n,1)=patch(tx(:),ty(:),-ones(numel(tx),1),'k','edgecolor','none','linestyle','-','facecolor',.9*[.8 .8 1],'facealpha',.75,'parent',dlg.handles.hax);
                                tx2=[tx;nan(1,size(tx,2))];
                                ty2=[ty;nan(1,size(ty,2))];
                                plot(tx2(:),ty2(:),'k-','parent',dlg.handles.hax);
                                %for n2=1:size(dlg.results_patch{n}{1},2)
                                %    dlg.handles.resultspatch(n,n2)=patch(dlg.results_patch{n}{1}(:,n2),dlg.results_patch{n}{2}(:,n2),'k','edgecolor',.8*[.8 .8 1],'linestyle','-','facecolor',.9*[.8 .8 1],'facealpha',.25,'parent',dlg.handles.hax);
                                %end
                            end
                        end
                        dlg.handles.resultsline=[];
                        for n=1:numel(dlg.results_patch),
                            dlg.handles.resultsline(n,1)=plot(dlg.results_line{n}{1},dlg.results_line{n}{2},'ko','markerfacecolor',.25*[.8 .8 1],'markeredgecolor',.25*[.8 .8 1],'linewidth',1,'color',.75*[.8 .8 1],'parent',dlg.handles.hax);
                        end
                        if numel(in)==1, 
                            ttitle=dlg.results_label{n}{1}{1};
                            text(numel(dlg.results_line{1}{1})/2+.5,1.1*1.05,ttitle,'horizontalalignment','center','fontsize',10+font_offset,'fontweight','bold','interpreter','none','parent',dlg.handles.hax); 
                            set(dlg.handles.resultsline(:,1),'linestyle','-'); 
                        end
                        dlg.handles.resultsline_add=plot(0,0,'ko-','markeredgecolor',[1 1 1],'visible','off');
                        dlg.handles.resultspatch_add=[];
                        ht=[];tx=[];
                        for n=1:numel(dlg.results_info),
                            if ~isequal(tx,dlg.results_info{n}.InterquartilesDisplay)
                                tx=dlg.results_info{n}.InterquartilesDisplay;
                                ht(1)=plot([.5 1:size(tx,2) size(tx,2)+.5],tx(1,[1 1:end end]),'r--','linewidth',2,'parent',dlg.handles.hax);
                                ht(2)=plot([.5 1:size(tx,2) size(tx,2)+.5],tx(2,[1 1:end end]),'k:','linewidth',1,'parent',dlg.handles.hax);
                                %ht(3)=plot([.5 1:size(tx,2) size(tx,2)+.5],tx(3,[1 1:end end]),'k:','linewidth',1,'parent',dlg.handles.hax);
                                ht(3)=plot([.5 1:size(tx,2) size(tx,2)+.5],tx(4,[1 1:end end]),'k:','linewidth',1,'parent',dlg.handles.hax);
                                ht(4)=plot([.5 1:size(tx,2) size(tx,2)+.5],tx(5,[1 1:end end]),'r--','linewidth',2,'parent',dlg.handles.hax);
                                text(size(tx,2)+.55+zeros(1,4),tx([5,4,2,1],end)',{'3rd Q + 1.5 IQR','3rd Quartile','1st Quartile','1st Q - 1.5 IQR'},'horizontalalignment','left','fontsize',5+font_offset,'parent',dlg.handles.hax);
                                if numel(dlg.results_info{n}.Variables)>1, 
                                    ty=dlg.results_info{n}.Interquartiles;
                                    text((1:size(tx,2))+.2,tx(1,:)-.02,arrayfun(@(x)mat2str(x,max(ceil(log10(abs(x))),2)),ty(1,:),'uni',0),'horizontalalignment','right','color',.5*[1 1 1],'fontsize',5+font_offset,'rotation',90,'parent',dlg.handles.hax);
                                    text((1:size(tx,2))+.2,tx(5,:)+.02,arrayfun(@(x)mat2str(x,max(ceil(log10(abs(x))),2)),ty(5,:),'uni',0),'horizontalalignment','left','color',.5*[1 1 1],'fontsize',5+font_offset,'rotation',90,'parent',dlg.handles.hax);
                                    text((1:size(tx,2)),-.15+zeros(1,size(tx,2)),regexprep(dlg.results_info{n}.Variables,'^QC_',''),'horizontalalignment','right','color','k','fontsize',7+font_offset,'rotation',90,'interpreter','none','parent',dlg.handles.hax); 
                                end
                            end
                            %ht(1)=plot(1:size(dlg.results_info{n}.InterquartilesDisplay,2),dlg.results_info{n}.InterquartilesDisplay(2,:),'k--','linewidth',2,'parent',dlg.handles.hax);
                            %ht(2)=plot(1:size(dlg.results_info{n}.InterquartilesDisplay,2),dlg.results_info{n}.InterquartilesDisplay(4,:),'k--','linewidth',2,'parent',dlg.handles.hax);
                        end
                        if numel(dlg.results_info{1}.Variables)==1, 
                            tx=dlg.results_info{n}.InterquartilesDisplay;
                            ty=dlg.results_info{n}.Interquartiles;
                            for n1=[1,2,4,5], text(.45,tx(n1,:),arrayfun(@(x)mat2str(x,max(ceil(log10(abs(x))),2)),ty(n1,:),'uni',0),'horizontalalignment','right','color',.5*[1 1 1],'fontsize',5+font_offset,'parent',dlg.handles.hax); end
                            tx=dlg.results_info{1}.Variables;
                            text(1,-.15,[regexprep(dlg.results_info{1}.Variables,'^QC_',''),dlg.results_info{1}.Variables_descr],'horizontalalignment','center','color','k','fontsize',8+font_offset,'interpreter','none','parent',dlg.handles.hax); 
                        end
                        hold(dlg.handles.hax,'off');
                        set(dlg.handles.hax,'xlim',[.5,numel(dlg.results_line{1}{1})+.5],'ytick',[],'ycolor',figcolor,'ydir','normal','visible','off');
                end
                if get(dlg.handles.showannot,'value')
                    delete(dlg.handles.han(ishandle(dlg.handles.han)));
                    %idx=find(cellfun('length',dlg.txtA(in))>0);
                    if numel(in)==1
                        dlg.handles.han=[uicontrol('style','text','units','norm','position',[.20 .75 .20 .05],'string','annotations','horizontalalignment','center','backgroundcolor',figcolor,'foregroundcolor','k','parent',dlg.handles.hfig),...
                            uicontrol('style','edit','units','norm','position',[.20 .10 .20 .65],'max',2,'string',dlg.txtA{in},'horizontalalignment','left','backgroundcolor',figcolor,'foregroundcolor','k','callback',{@conn_qaplotsexplore_update,'annotate'},'parent',dlg.handles.hfig)];
                    elseif numel(in)>1
                        txt=arrayfun(@(n)sprintf('%s %s %s: %s',dlg.usubjects{dlg.isubjects(dlg.dataIDXplots(n))},dlg.usessions{dlg.isessions(dlg.dataIDXplots(n))},dlg.umeasures{dlg.imeasures(dlg.dataIDXplots(n))},sprintf('%s ',dlg.txtA{n}{:})),in,'uni',0);
                        dlg.handles.han=[uicontrol('style','text','units','norm','position',[.20 .75 .20 .05],'string','annotations','horizontalalignment','center','backgroundcolor',figcolor,'foregroundcolor','k','parent',dlg.handles.hfig),...
                                         uicontrol('style','listbox','units','norm','position',[.20 .10 .20 .65],'max',1,'string',txt,'horizontalalignment','left','backgroundcolor',figcolor,'foregroundcolor','k','callback',{@conn_qaplotsexplore_update,'selectannotation'},'interruptible','off','parent',dlg.handles.hfig)];
                    end
                else
                    delete(dlg.handles.han(ishandle(dlg.handles.han)));
                end
                drawnow;

        end
    end

    function conn_qaplotsexplore_figuremousemove(hObject,eventdata,option,varargin)
        try
            p1=get(0,'pointerlocation');
            p2=get(dlg.handles.hfig,'position');
            p3=get(0,'screensize');
            p4=p2(1:2)+p3(1:2)-1; % note: fix issue when connecting to external monitor/projector
            pos0=(p1-p4);
            set(dlg.handles.hfig,'currentpoint',pos0);
            pos=(get(dlg.handles.hax,'currentpoint')); 
            pos=pos(1,1:3);
            switch(dlg.uanalysestype(dlg.ianalysis))
                case 1, % QA_NORM/QA_REG            
                    pos=round(pos);
                    set(dlg.handles.hax,'units','pixels');posax=get(dlg.handles.hax,'position');set(dlg.handles.hax,'units','norm');
                    nX=dlg.dispsize;
                    if numel(nX)<5, return; end
                    txyz=conn_menu_montage('coords2xyz',nX,pos(1:2)');
                    if txyz(3)>=1&&txyz(3)<=nX(end)&&txyz(1)>=1&&pos(1)<=nX(3)*nX(1)&&pos(2)>=1&&pos(2)<=nX(4)*nX(2)
                        f1=dlg.dataDidx(txyz(2),txyz(1));
                        f2=dlg.dataDmax(txyz(2),txyz(1));
                        if f2>0||nX(end)>1,
                            tlabel={};
                            if nX(end)>1, tlabel=[{[dlg.usubjects{dlg.isubjects(dlg.dataIDXplots(dlg.dataIDXsubjects(txyz(3))))},' ',dlg.usessions{dlg.isessions(dlg.dataIDXplots(dlg.dataIDXsubjects(txyz(3))))}],' '},tlabel];
                            elseif f2>0, tlabel=[tlabel {'Most different from average at this location:',sprintf('%s %s (diff z=%.2f)',dlg.usubjects{dlg.isubjects(dlg.dataIDXplots(f1))},dlg.usessions{dlg.isessions(dlg.dataIDXplots(f1))},f2)}];
                            end
                            set(dlg.handles.hlabel,'units','pixels','position',[pos0+[10 -10] 20 20],'visible','on','string',tlabel);%,'fontsize',8+4*f2);
                            hext=get(dlg.handles.hlabel,'extent');
                            nlines=ceil(hext(3)/(p2(3)/2));
                            ntlabel=numel(tlabel);
                            newpos=[pos0+[-min(p2(3)/2,hext(3))/2 +10] min(p2(3)/2,hext(3)) nlines*hext(4)]; % text position figure coordinates
                            newpos(1)=max(posax(1),newpos(1)-max(0,newpos(1)+newpos(3)-posax(1)-posax(3)));
                            newpos(2)=max(posax(2),newpos(2)-max(0,newpos(2)+newpos(4)-posax(2)-posax(4)));
                            set(dlg.handles.hlabel,'position',newpos,'string',reshape([tlabel,repmat(' ',1,nlines*ceil(ntlabel/nlines)-ntlabel)]',[],nlines)');
                        else
                            set(dlg.handles.hlabel,'visible','off');
                        end
                    else
                        set(dlg.handles.hlabel,'visible','off');
                    end
                case {2,3,4,5}, %QA_DENOISE
                    posb=pos;
                    if dlg.uanalysestype(dlg.ianalysis)==5, labels=2;
                    elseif pos(2)>=dlg.plothistinfo2&&pos(2)<=dlg.plothistinfo3, posb(2)=posb(2)-dlg.plothistinfo2; labels=3;
                    elseif pos(2)>=dlg.plothistinfo(1)&&pos(2)<=dlg.plothistinfo2, labels=2;
                    else pos=[];
                    end
                    if ~isempty(pos)
                        dwin=[];dmin=inf;
                        if dlg.uanalysestype(dlg.ianalysis)==5, 
                            for n1=1:numel(dlg.results_patch)
                                [d,idx]=min(abs(dlg.results_line{n1}{1}-posb(1))+abs((dlg.results_line{n1}{2}-posb(2))));
                                if d<dmin, dmin=d; dwin=n1; dpos=[dlg.results_line{n1}{1}(idx) dlg.results_line{n1}{2}(idx)]; end
                            end
                        elseif dlg.uanalysestype(dlg.ianalysis)==4, 
                            for n1=1:numel(dlg.results_patch)
                                [d,idx]=min(abs(dlg.results_line{n1}{labels}-posb(1))+abs((dlg.results_line{n1}{1}-posb(2))/dlg.plothistinfo4));
                                if d<dmin, dmin=d; dwin=n1; dpos=[dlg.results_line{n1}{labels}(idx) dlg.results_line{n1}{1}(idx)]; end
                            end
                        else
                            for n1=1:numel(dlg.results_patch)
                                [d,idx]=min(abs(dlg.results_patch{n1}{1}-posb(1))+abs((dlg.results_patch{n1}{labels}-posb(2))/dlg.plothistinfo4));
                                if d<dmin, dmin=d; dwin=n1; dpos=[dlg.results_patch{n1}{1}(idx) dlg.results_patch{n1}{labels}(idx)]; end
                            end
                        end
                        if ~isempty(dwin)&&max(abs(dpos-posb(1:2))./[1 dlg.plothistinfo4])<.10
                            if numel(dlg.results_patch)>1&&nargin>2&&isequal(option,'buttonup')
                                n=dwin;
                                subjects=dlg.isubjects(dlg.dataIDXplots(dlg.dataIDXsubjects(n)));
                                sessions=dlg.isessions(dlg.dataIDXplots(dlg.dataIDXsubjects(n)));
                                measures=dlg.imeasures(dlg.dataIDXplots(dlg.dataIDXsubjects(n)));
                                set(dlg.handles.subjects,'value',find(dlg.usubjects_shown==subjects));
                                set(dlg.handles.sessions,'value',find(dlg.usessions_shown==sessions));
                                set(dlg.handles.measures,'value',find(dlg.umeasures_shown==measures));
                                conn_qaplotsexplore_update([],[],'refresh');
                            else
                                %tlabel=[dlg.usubjects{dlg.isubjects(dlg.dataIDXplots(dlg.dataIDXsubjects(dwin)))},' ',dlg.usessions{dlg.isessions(dlg.dataIDXplots(dlg.dataIDXsubjects(dwin)))}];
                                tlabel=dlg.results_label{dwin};
                                if iscell(tlabel)&&~isempty(tlabel), tlabel=tlabel{1}; end
                                if dlg.uanalysestype(dlg.ianalysis)==5, tlabel=tlabel([1,max(2,min(numel(tlabel), 1+round(dpos(1))))]); end
                                set(dlg.handles.hlabel,'units','pixels','position',[pos0+[10 -10] 20 20],'visible','on','string',tlabel);
                                hext=get(dlg.handles.hlabel,'extent');
                                nlines=ceil(hext(3)/(p2(3)/2));
                                ntlabel=numel(tlabel);
                                set(dlg.handles.hlabel,'position',[pos0+[-min(p2(3)/2,hext(3))-10 -10] min(p2(3)/2,hext(3)) nlines*hext(4)],'string',reshape([tlabel,repmat(' ',1,nlines*ceil(ntlabel/nlines)-ntlabel)]',[],nlines)');
                                if dlg.uanalysestype(dlg.ianalysis)==5
                                    set(dlg.handles.resultsline_add,'xdata',get(dlg.handles.resultsline(dwin,1),'xdata'),'ydata',get(dlg.handles.resultsline(dwin,1),'ydata'),'zdata',get(dlg.handles.resultsline(dwin,1),'zdata'),'visible','on');
                                else
                                    set(dlg.handles.resultspatch_add(1),'xdata',get(dlg.handles.resultspatch(dwin,1),'xdata'),'ydata',get(dlg.handles.resultspatch(dwin,1),'ydata'),'zdata',get(dlg.handles.resultspatch(dwin,1),'zdata'),'visible','on');
                                    set(dlg.handles.resultspatch_add(2),'xdata',get(dlg.handles.resultspatch(dwin,2),'xdata'),'ydata',get(dlg.handles.resultspatch(dwin,2),'ydata'),'zdata',get(dlg.handles.resultspatch(dwin,2),'zdata'),'visible','on');
                                    if size(dlg.handles.resultsline,1)>=dwin,
                                        set(dlg.handles.resultsline_add(1),'xdata',get(dlg.handles.resultsline(dwin,1),'xdata'),'ydata',get(dlg.handles.resultsline(dwin,1),'ydata'),'zdata',get(dlg.handles.resultsline(dwin,1),'zdata'),'visible','on');
                                        set(dlg.handles.resultsline_add(2),'xdata',get(dlg.handles.resultsline(dwin,2),'xdata'),'ydata',get(dlg.handles.resultsline(dwin,2),'ydata'),'zdata',get(dlg.handles.resultsline(dwin,2),'zdata'),'visible','on');
                                    end
                                end
                            end
                        else
                            set(dlg.handles.hlabel,'visible','off','string','');
                            set(dlg.handles.resultsline_add,'visible','of');
                            set(dlg.handles.resultspatch_add,'visible','of');
                        end
                    else
                        set(dlg.handles.hlabel,'visible','off','string','');
                        set(dlg.handles.resultspatch_add,'visible','of');
                        set(dlg.handles.resultsline_add,'visible','of');
                    end
            end
        end
    end
end

function [descrip, procedure, proceduretype]=conn_qaplotsexplore_translate(root)
% root_list={'^QA_NORM_(.*)','^QA_REG_functional','^QA_REG_(.*?)_?functional','^QA_REG_(.*?)_?structural','^QA_REG_(.*?)_?mni','^QA_COREG_(.*)','^QA_TIME_(.*)','^QA_TIMEART_(.*)','^QA_DENOISE_timeseries','^QA_DENOISE_QC-FC','^QA_DENOISE_scatterplot','^QA_DENOISE','^QA_SPM_design','^QA_SPM_contrasts'};
% root_descrip={'QA normalization: $1 data + outline of MNI TPM template','QA registration: functional data + structural overlay','QA registration: functional data + outline of ROI $1','QA registration: structural data + outline of ROI $1','QA registration: mni reference template + outline of ROI $1','QA realignment: $1 center-slice across multiple sessions/datasets','QA artifacts: $1 movie across all timepoints/acquisitions','QA artifacts: BOLD GS changes & subject motion timeseries with $1 movie','QA denoising: BOLD signal traces (carpetplot) before and after denoising + ART timeseries','QA denoising: distribution of QC-FC associations before and after denoising','QA denoising: scatterplot of functional correlations (FC) vs. distance (mm) before and after denoising','QA denoising: distribution of functional correlations (FC) before and after denoising','QA SPM design: review SPM first-level design matrix','QA SPM contrasts: review SPM first-level contrasts'};
% 
root_list={...
    '^QA_NORM_structural.*?(\(.*?\)\s*)?$','QA normalization: structural data + outline of MNI TPM template $1','1','1';
    '^QA_NORM_functional.*?(\(.*?\)\s*)?$','QA normalization: functional data + outline of MNI TPM template $1','2','1';
    '^QA_NORM_(.*?)(\(.*?\)\s*)?$','QA normalization: $1 data + outline of MNI TPM template $2','3','1';
    '^QA_REG_functional.*?(\(.*?\)\s*)?$','QA registration: functional data + structural overlay $1','10','1';
    '^QA_REG_(.*?)_?functional.*?(\(.*?\)\s*)?$','QA registration: functional data + outline of ROI $1 $2','5','1';
    '^QA_REG_(.*?)_?structural.*?(\(.*?\)\s*)?$','QA registration: structural data + outline of ROI $1 $2','4','1';
    '^QA_REG_(.*?)_?mni.*?(\(.*?\)\s*)?$','QA registration: mni reference template + outline of ROI $1 $2','6','1';
    '^QA_COREG_(.*?)(\(.*?\)\s*)?$','QA realignment: $1 center-slice across multiple sessions/datasets $2','7','1';
    '^QA_TIME_(.*?)(\(.*?\)\s*)?$','QA artifacts: $1 movie across all timepoints/acquisitions $2','8','1';
    '^QA_TIMEART_(.*?)(\(.*?\)\s*)?$','QA artifacts: BOLD GS changes & subject motion timeseries with $1 movie $2','9','1';
    '^QA_DENOISE_timeseries.*?(\(.*?\)\s*)?$','QA denoising: BOLD signal traces (carpetplot) + ART timeseries $1','12','1';
    '^QA_DENOISE_QC-FC.*?(\(.*?\)\s*)?$','QA denoising: distribution of QC-FC associations $1','13','3';
    '^QA_DENOISE_scatterplot.*?(\(.*?\)\s*)?$','QA denoising: scatterplot of functional correlations (FC) vs. distance (mm) $1','14','4';
    '^QA_DENOISE.*?(\(.*?\)\s*)?$','QA denoising: distribution of functional correlations (FC) $1','11','2';
    '^QA_COV.*?(\(.*?\)\s*)?$','QA variables: histogram of QC subject-level values $1','31','5';
    '^QA_SPM_design.*?(\(.*?\)\s*)?$','QA SPM design: review SPM first-level design matrix $1','21','1';
    '^QA_SPM_contrasts.*?(\(.*?\)\s*)?$','QA SPM contrasts: review SPM first-level contrasts $1','22','1';
    '^(\D.*)','$1','0','1'};

descrip=regexprep(root,...
    root_list(:,1)',root_list(:,2)');
procedure=cellfun(@str2num,regexprep(root,...
    root_list(:,1)',root_list(:,3)'));
proceduretype=cellfun(@str2num,regexprep(root,...
    root_list(:,1)',root_list(:,4)'));
end
                

