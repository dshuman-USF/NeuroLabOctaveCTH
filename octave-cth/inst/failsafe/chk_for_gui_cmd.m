% Wait for user input from the gui.  This can be used to poll
% in a busy-wait state, or it can stay local until something shows
% up from the gui.
% The type of input from the gui can be:
% CONTROLS - values from the gui controls
% CMD      - text from command input control, use eval to run it
%            some values can be returned, but not all are passed back
% PARAMS  - text from Send Param window - used to send values back
%           in response to a prompt
% SHOW_HIDE - Show clusters in the stereotaxic plot from Sterotaxic control

function [p cmd]=chk_for_gui_cmd(wait)

global client

   p = struct();
   done = 0;
   msg = "";
   data=[];
   count=0;
   cmd = '';
   [data,count] = recv(client,1,MSG_DONTWAIT);
   if count <= 0 && wait == 0   % nothing, don't wait
      return;
   elseif count > 0  % even if nowait requested, we have data, so get the rest of it
      msg = cstrcat(msg,char(data));  % don't lose this
   endif

     % keep accumulating input until we hit "END" marker
   while done == 0
      [data,count] = recv(client,1,MSG_PEEK); % busy wait
      if  count > 0
         [data,count] = recv(client,1);
         msg = cstrcat(msg,char(data));
         found_end = strfind(msg,"END");
         if size(found_end) > 0
            done = 1;
         end
      end
   end
   p0 = strsplit(msg);
   if strcmp(p0{1},'CONTROLS') == 1
      cmd=p0{1};
      p1 = p0(1:2:end);
      p2 = p0(2:2:end);
      p = cell2struct(p2,p1,2);
      p = rmfield(p,"end");
      p = rmfield(p,p0{1});
        % no easy way to turn some of these into ints
      p.pd_algo = str2num(p.pd_algo);
      p.link_algo = str2num(p.link_algo);
      p.color = str2num(p.color);
      p.densperc = str2double(p.densperc);
      p.cophen = str2num(p.cophen);
      p.incon_sel = str2num(p.incon_sel);
      p.incon_depth = str2num(p.incon_depth);
      p.errorbars = str2num(p.errorbars);
      p.errscale = str2num(p.errscale);
      p.kmeans = str2num(p.kmeans);
      p.plotdim = str2num(p.plotdim);
      p.basis = str2num(p.basis);
      p.p0 = str2num(p.p0);
      p.p1 = str2num(p.p1);
      p.p2 = str2num(p.p2);
      p.p3 = str2num(p.p3);
      p.pickclust = str2num(p.pickclust);
      p.numclust = str2num(p.numclust);
      p.pid = str2num(p.pid);
      p.flatplots = str2num(p.flatplots);
      p.stereoper = str2num(p.stereoper);
      p.pairwise = str2num(p.pairwise);
      p.typepairs = str2num(p.typepairs);
      p.log_dist = str2num(p.log_dist);
      p.autoscale = str2num(p.autoscale);
      p.isoplots = str2num(p.isoplots);
      p.isoover = str2num(p.isoover);
      p.isoembed = str2num(p.isoembed);
      p.isocolor = str2num(p.isocolor);
      p.isoscale = str2num(p.isoscale);
      p.mod1 = str2num(p.mod1);
      p.mod2 = str2num(p.mod2);
      p.curveshow = str2num(p.curveshow);
      p.curvederive = str2num(p.curvederive);
      p.fuzzy = str2num(p.fuzzy);
      p.fuzzycutoff = str2double(p.fuzzycutoff);
      p.scrncap = str2num(p.scrncap);
      p.noflats = str2num(p.noflats);
       % aaaand finally, deal with cursed spaces in dir/fnames
      p.fname = strrep(p.fname,"<<**SPACE**>>"," ");
      p.typename = strrep(p.typename,"<<**SPACE**>>"," ");
      p.swallname = strrep(p.swallname,"<<**SPACE**>>"," ");
      p.lareflexname = strrep(p.lareflexname,"<<**SPACE**>>"," ");
   elseif strcmp(p0{1},'CMD') == 1
   try
      cmd='';  % we process this here, so nothing to return to caller
      cmdline='';
      strt_idx=find(strcmp(p0,'CMD'));
      end_idx=find(strcmp(p0,'END'));
      p1 = p0(strt_idx+1:end_idx-1);  % strip 1st and last rows
      for i=1:numel(p1)  % CMD text text text ... END
         cmdline=cstrcat(cmdline,p1{i});
         cmdline=cstrcat(cmdline,' ');
      end
      ui_msg(cmdline);
      res='Error';
      res = evalin('caller', cmdline, 'disp("illegal command") ');
      if iscell(res)
         res = disp(char(res));
      else
         res=disp(res);
      end
      if length(res) > 0
         res = strcat(res,"__END__");
         send(client,res,0x8000);  % 0x8000 == MSG_MORE flag
      end
      catch 
         send(client,"Bad command__END__");
         ui_msg(sprintf("ERROR WARNcommand returns error %s\n",lasterr));
      end_try_catch
      fflush(stdout);
   elseif strcmp(p0{1},'PARAMS') == 1
      cmd='PARAMS';
      strt_idx=find(strcmp(p0,'PARAMS'));
      end_idx=find(strcmp(p0,'END'));
      p1 = p0(strt_idx+1:end_idx-1);  % strip 1st and last rows
      cmdline='';
      for i=1:numel(p1)  % PARAMS text text text ... END
         cmdline=cstrcat(cmdline,p1{i});
         cmdline=cstrcat(cmdline,' ');
      end
      if ~isempty(str2num(cmdline))
         p = str2num(cmdline);
      else
         p = cmdline;
      end
   elseif strcmp(p0{1},'STEREO_CLUSTERS') == 1
       % STEREO_CLUSTERS 0 param c1 c2 ... cn end END
      cmd='STEREO_CLUSTERS';
      strt_idx=find(strcmp(p0,'STEREO_CLUSTERS'));
      end_idx=find(strcmp(p0,'END'));
      p1 = p0(strt_idx+1:end_idx-1);  % strip 1st and last rows
      clusts=[];
      for (num=1:numel(p1))
         n=str2num(p1{num});
         if ~isempty(n)
            clusts=[clusts;n];
         end
      end
      p= {clusts};
   elseif strcmp(p0{1},'SAVE_CLUSTERS') == 1
       % SAVE_CLUSTERS 0 [d] n n] [k n n n] [kc n n] [f n n n] fname end END
      cmd='SAVE_CLUSTERS';
      strt_idx=find(strcmp(p0,'SAVE_CLUSTERS'));
      end_idx=find(strcmp(p0,'END'));
      p1 = p0(strt_idx+1:end_idx-1);  % strip 1st and last rows
      dclusts=[];
      kclusts=[];
      kcclusts=[];
      fclusts=[];
      p=struct('d',[],'k',[],'kc',[],'f',[],'fname','');
      in_d = false;
      in_k = false;
      in_kc = false;
      in_f = false;
      fname=p1{end};
      p1={p1{1:end-1}};
      for num=1:numel(p1)  % numbers 1st, fname at end, but all nums
         if strcmpi(p1{num},'d')
            in_d = true;
            in_k = false;
            in_kc = false;
            in_f = false;
         elseif strcmpi(p1{num},'k')
            in_d = false;
            in_k = true;
            in_kc = false;
            in_f = false;
         elseif strcmpi(p1{num},'kc')
            in_d = false;
            in_k = false;
            in_kc = true;
            in_f = false;
         elseif strcmpi(p1{num},'f')
            in_d = false;
            in_k = false;
            in_kc = false;
            in_f = true;
         else 
            n=str2double(p1{num});
            if ~isempty(n) && ~isnan(n)
               if in_d
                  dclusts=[dclusts n];
               elseif in_k
                  kclusts=[kclusts n];
               elseif in_kc
                  kcclusts=[kcclusts n];
               elseif in_f
                  fclusts=[fclusts n];
               else
                  dclusts=[dclusts n];  # if no prefix, default to dendrogram clusts
               end
            end
         end
      end
      if all(isstrprop(fname,'digit')) # forgot fname at end? if all numbers, yes.
         ui_msg('ERROR WARNThe filename is missing or is all numbers.  Use some non-numbers in the filename.');
      else
         p.d=dclusts;
         p.k=kclusts;
         p.kc=kcclusts;
         p.f=fclusts;
         p.fname=fname;
      end
   elseif strcmp(p0{1},'START_OVER') == 1
      cmd='START_OVER';
   elseif strcmp(p0{1},'QUIT') == 1
      cmd='QUIT';
      p = struct('pid',str2num(p0{2}));
   elseif strcmp(p0{1},'FORWARD') == 1
      cmd='FORWARD';
   elseif strcmp(p0{1},'BACKWARD') == 1
      cmd='BACKWARD';
   elseif strcmp(p0{1},'CTHINFO') == 1
      cmd='CTHINFO';
      strt_idx=find(strcmp(p0,'CTHINFO'));
      end_idx=find(strcmp(p0,'END'));
      p1 = p0(strt_idx+1:end_idx-1);  % strip 1st and last rows
      cths=[];

      have_star=false;
      for (num=1:numel(p1))   % pick up numbers or '*', ignore anything else
         if p1{num} == '*'
            have_star = true;
            n = -1;
         else
            n=str2double(p1{num}); 
         end
         if ~isempty(n) && ~isnan(n)
            cths=[cths;n];
         end
      end
      if (numel(cths) == 0) || (have_star && numel(cths) == 1)
         ui_msg('ERROR WARNCTH numbers are missing.  Command ignored.')
      end
      p={cths};
   elseif strcmp(p0{1},'EXPORT_ATLAS') == 1
      cmd='EXPORT_ATLAS';
      p={p0{2}};
   elseif strcmp(p0{1},'EXPORT_ARCHETYPES') == 1
      cmd='EXPORT_ARCHETYPES';
      p={p0{2}};
   elseif strcmp(p0{1},'EXPORT_PAIRS') == 1
      cmd='EXPORT_PAIRS';
      p={p0{2}};
   elseif strcmp(p0{1},'CLOSE_INFO') == 1
      cmd='CLOSE_INFO';
   endif

endfunction

