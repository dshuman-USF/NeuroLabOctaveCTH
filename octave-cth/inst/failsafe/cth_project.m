% Function for all sorts of ways to play with CTH's
% and see if they cluster.
% Two ways to run it:
%  Default:  Running the run_cthgui or run_cthterm or other scripts.
%  Directly: In octave, invoke with args to use gui or terminal ui
% You can also start this with an optional port number.  This is useful for
% debugging.  It assumes you have aready started the gui and given it a port
% number as an argument, so it just tries to connect with the given port
% number.  This lets you have control over which port you want to use, and also
% the order you start the programs, like starting cth_gui in a debugger first.
# INPUTS: ui = 0 for gui
#         ui = 1 for terminal/text (note you still need a windowing env for plots)
#         port = 0 for connect with gui automatically
#         port = specific port # for debugging.

function cth_project(ui=0, port=0)

   graphics_toolkit('fltk')
%   graphics_toolkit('qt')   % 4.2.x STILL has bugs in qt plots

   atexit('time_to_quit'); 
   split_long_rows(0);
   format('short','g','compact');
   crash_dumps_octave_core(false);  % don't create sometimes huge octave-workspace file
   pkg load general
   pkg load geometry
   pkg load linear-algebra
   pkg load sockets
   pkg load statistics
   pkg load struct
   pkg load fuzzy-logic-toolkit
   % do these after pkg loading, there are some ignorable errors
   % we don't want break into debug mode on.
   % One-time inits 
   warning('on','clustering');  % one of the clustering algos complains, shut it up
% debug_on_interrupt(0,'local');
   debug_on_error(1,'local');
   ignore_function_time_stamp('none');  % useful for debugging to sense updated funcs
   debug_on_error(1);
   debug_on_interrupt(1);
% debug_on_warning(1);
   global scrn_caps=0;
   global client;
   global termUI;
   global color;
   global PERIODS;
   global HIDETHRESH = 11;  % if this many rows in subplot, don't draw X labels

   BASIS_MOSTDIST = 1;
   BASIS_PCA = 2;
   BASIS_PICK = 3;

   termUI=ui;
   client = 0;
   done = 0;
   reset = 0;
   winID='';
   bring_to_fg_cmd='';

   scrn_pos1=[];
   scrn_pos2=[];
   num_slots=0;
   numclusts=[];  % indexed by num_runs
   if termUI == 0
      guiconn(port);
   else
      disp('Using local terminal UI');
   end

   [color, colorbgnd, cb_friendly, graybgnd, pdistalgo, menu_pdistalgo, linkalgo, menu_linkalgo] = init_consts();
   [primary,secondary]=get_dtops();  % desktops
   wininfo=plot_wins(1,2);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%% OUTER-MOST LOOP for START OVER choice
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   while done == 0
        % zap all but these
      clear -x done reset termUI client primary secondary color colorbgnd cb_friendly graybgnd pdistalgo menu_pdistalgo linkalgo menu_linkalgo winID bring_to_fg_cmd scrn_pos1 scrn_pos2 num_slots BASIS_MOSTDIST BASIS_PCA BASIS_PICK scrn_caps wininfo

      global names
      global stats
      global coords
      global tot_pts

      guiparams=struct();
      fname='';
      barh=[];    % figure handles for bar charts
      type_clusts=[];
      bar_ids=[]; % window ids of bar charts
      dendoh=[];  % dendrograms
      scatth=[];  % scatter plots
      fuzzyh=[];  % fuzzy clusters
      modh=[];    % modulation depth plots
      modh2=[];   % modulation depth plots using 2nd algorithm
      modhf1=[];   % modulation depth plots for flats
      modhf2=[];
      kmeanh=[];  % k-means plots
      exph=[];    % individual pt plots go here
      isoh=[];
      allpts=[];
      ptsnof=[];  % subsets, nof == no flats
      distnof=[];
      namesnof=[];
      SparseVars=struct;
      coordsnofpts=[];
      cluster_centers=[];
      km_cluster_centers=[];
      km_cent_cluster_centers=[];
      fuzzy_cluster_centers=[];
      expnames=[];
      cthstats=[];
      curves=[];
      stay_on_file = 0;
      num_runs=1;
      num_type_runs=1;
      numclusts=[];
      quit_cmd = 0;
      do_kmeans = 0;
      do_fuzzy = 0;
      fuzzycut = 0.0;
      constplotchars='o+xs^v>p<h';  % for stereotaxic plots
      stereoh=[];  % stereotaxic pt projections
      stereohf=[];
      stereo_clusts=[];
      kmeans_clusts_c=[];
      kmeans_clusts=[];
      cthinfoh=[];
      autoscale = 2;
      cthinfo(0);   % clear lingering persistent data
      bad_version = 0;
      a_valid = false;
      archetype = false;  % todo this is not supported for cmd line interface

      if termUI == 0
         ui_msg('Select the cth file and settings you want, then click on Create Plots.');
         cmd = '';
         while ~strcmp(cmd,'CONTROLS') 
            [guiparams,cmd] = chk_for_gui_cmd(1);  % wait until params or
            if strcmp(cmd,'QUIT')                  % quit sent by gui
               done = 1;
               break;
            end
         end
      end

      % The plots steal the focus.  Sometimes we steal it back.
      % The GUI sends us its window id.
      % If running in a term, the winid is in the environment.
      if done == 0
         if termUI == 0
            winID=guiparams.winid;
            bring_to_fg_cmd = sprintf('wmctrl -i -a %s',winID); % gui to fg cmd
         else
            winID=getenv('WINDOWID');
            if ~isempty(winID)
               bring_to_fg_cmd=sprintf('wmctrl -i -a %s',winID); % term to fg cmd
            end
         end
      end
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % start main loop -- stay here until START OVER or QUIT
      % Can do different options for same file, or pick new file
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      while done == 0
         if bad_version
            break;
         end
         if termUI == 0
            if strcmp(fname,guiparams.fname) == 1   % same file, don't reload
               stay_on_file = 1;
            else
               fname = guiparams.fname;  % assumes we picked from list, so file exists
               stay_on_file = 0;
            end
         elseif stay_on_file == 0
            have_file = 0;
            while have_file == 0
               fname = getfname();
               [f_info err msg] = stat(fname);
               if err == 0
                  have_file = 1;
               else
                  disp(sprintf('Cannot open file %s, try again',fname));
               end
            end
         end
         if termUI == 0
            if strcmp(linkalgo{guiparams.link_algo},'archetype')
               archetype = true;
            else
               archetype = false;
            end
         end
         plotchars=constplotchars;       % reset plot chars
         scroll_start=numel(barh)+1;     % for multiple runs, this is where
                                         % we start scrolling from
           % new file business
         if stay_on_file == 0
            clear('F_*'); % pts in file
            clear('A_*'); % possible archetypes
            clear('ZeroFlat*');
            clear('ExpName*');
            modh=[];      % only need to do this once per file
            modhf1=[];
            modh2=[];
            modhf2=[];
            meandist=[];  % distance matrix in file
            needctl=false;
            needswall1=false;
            needlareflex=false;

            ui_msg(sprintf('Loading %s (may take a while). . .',fname));
             % note: even if you just want to load 1 var from a file, octave reads
             % in and creates all the vars, then searches them for the variable(s) 
             % you asked for. We use to read in different subsets of the vars
             % which meant we read the file 4 times. Once is enough.
             % This loads them so names{...} is in the same order as dist matrix in file
            try
               clear CTH_VERSION
               CthVars=load(fname);
               CTH_VERSION=CthVars.CTH_VERSION;
               CthVars=rmfield(CthVars,'CTH_VERSION');
            catch
               % don't exit on error, will be handled below
            end
            if exist('CTH_VERSION') ~= 0
               tmp=strsplit(CTH_VERSION);
               last=size(tmp)(2);
               ver=str2double(tmp{last});  % last is ver %
               if ver < 1.5
                  ui_msg(sprintf('ERROR WARNFile version %s is not supported, use cth_cluster to create a new one.',tmp{last}));
                  stay_on_file = 0;
                  fname='';
                  bad_version = 1;
                  continue;
               end
            else
               ui_msg('ERROR WARNThis file has no version number, not supported.');
               stay_on_file = 0;
               fname='';
               bad_version = 1;
               continue;
            end
            % make file path the cwd
            [path]=fileparts(fname);
            cd(path);
             % Remove all but F_*, A_*, and ZeroFlat* vars from CthVars
            rmv=cell;
            tmp=struct;
            pt=1;
            haveArchFile=false;
            for [val,key]=CthVars
               if regexp(key,"ExpName_*")
                  tmp.(key)=val;
                  rmv{pt}=key;
                  pt=pt+1;
               elseif regexp(key,"NumSparse")  % obsolete but in older files
                  rmv{pt}=key;
                  pt=pt+1;
               elseif regexp(key,"SparseThresh") % obsolete but in older files
                  rmv{pt}=key;
                  pt=pt+1;
               elseif regexp(key,"meandist")
                  meandist=val;
                  rmv{pt}=key;
                  pt=pt+1;
               elseif regexp(key,"ZeroFlat_*")
                  eval(sprintf([key,'=','val;'])); % create named var
                  ZeroFlat = val;   %dereference these to unclutter code
                  ZeroFlatName = key;
               elseif regexp(key,"^A_")
                  haveArchFile=true;
               end
            end
            if ~isempty(tmp)
               expnames=struct2cell(tmp);
            end
            CthVars=rmfield(CthVars,rmv);

            tot_pts = length(fieldnames(CthVars));
             % Move sparse CTHs to their own struct, we only need them for db export 
            rmv=cell;
            pt=1;
            NumSparse = 0;
            SparseVars=struct;
            for [val,key]=CthVars 
               if val.IsSparse == 1
                  rmv{pt} = key;
                  SparseVars.(key)=val;
                  pt=pt+1;
               end
            end
            NumSparse = pt-1;
            CthVars=rmfield(CthVars,rmv);
            names=fieldnames(CthVars);

             % put cth stats in a struct array so we can index it and pass it
             % around to functions
            clear cthstats;
            clear curves;
            pt = 1;
            for [val,key]=CthVars 
               cthstats(pt).stat=val.Cthstat;
               curves(pt).curve=val.Curve;
               pt=pt+1;
            end

            clear tmp;

            if haveArchFile
               ui_msg(sprintf("This is a file of archetype CTHs.\nArchetype info: %s",expnames{1}));
            end

            if exist('CTH_VERSION') ~= 0
               ui_msg(CTH_VERSION);
            end
            numpts = length(names);
            allpts=[];      % start out clean 
            ptsnof=[];
            pt = 1;
            for [val,key]=CthVars 
               allpts(pt,:) = val.NSpaceCoords;
               pt = pt + 1;
            end
            numbins = columns(allpts);
            msg = sprintf('Loaded %d points with %d bins.',tot_pts,numbins);
            ui_msg(msg);  

             % Find zeroflat's neighbors
             % The last row and col in meandist MUST be the ZeroFlat entry
             % In general, meandist will exists.  The .type files that are exported
             % archetype CTHs from a previous session will not, so create it.
             if isempty(meandist)
                meandist=squareform(loc_pdist(allpts, 'euclidean'),'tomatrix');
             end
              % Calculate criteria for being a flat
              % note: this does not work for some distance types, such as
              % correlation, so we have to use our modified euclidean distance 
              % or simple euclidean distance.
            if guiparams.noflats
               zdi = rows(allpts);
            else
               dist = 7;
               zd=meandist(:,end);   % column 1
               do
                  prev_dist = dist;
                  [zdi,zdl]=find(zd <= dist);
                  count=sum(zdl);
                  if count ~= 0
                     dist = sqrt(chi2inv(1-(1/count),numbins));
                  end
               until count == 0 || dist == 0 || dist == prev_dist
            end;
            distnof = meandist;
            distzf = meandist;
            ptsnof=allpts;
            cthstatsnof=cthstats;
            curvesnof=curves;
            namesnof=names;
            sparsenames=[];

            if rows(zdi) > 0
               flatpts=allpts(zdi,:);   % zero flats go in these
               flatnames=names(zdi,:)';
               flatstats=cthstats(zdi);
               flatcurves=curves(zdi)';
               numflats=rows(zdi);
               ptsnof(zdi,:)=[];
               cthstatsnof(zdi)=[];
               curvesnof(zdi)=[];
               namesnof(zdi,:)=[];      % all non flat names
               distnof(zdi,:)=[];       % and distances, take out rows and cols
               distnof(:,zdi)=[];
               with_z=zdi;           % we need a distance matrix that includes the zero
               with_z(end)=[];       % flat for saving subsets of clusters, so
               distzf(with_z,:)=[];  % snip off the last (zero) flat from zdi and
               distzf(:,with_z)=[];  % select all non-flats plus zero flat
            else
               ui_msg('ERROR WARNExpected to find at least one flat in cth file, something is wrong.');
               flatpts=[];        % should not happen, always a ZeroFlat
               flatnames=cell;    % things now probably break badly
               flatstats=[];
               numflats=0;
               ptsnof=allpts;
            end
            numpts=rows(ptsnof);
            globalmax=max(max(ptsnof));
            maxdist=max(max(distnof));

            flmsg=sprintf('Found %d flats',numflats);
            ui_msg(flmsg);

            num_coords = numel(namesnof);
            coordsnofpts=struct();
            for st_coords=1:num_coords
               coordsnofpts(st_coords)=CthVars.(namesnof{st_coords}).RealCoords;
           end
                 % don't forget to add ZeroFlat
            ui_msg(sprintf('%d sparse CTHs filtered out.',NumSparse));
            ui_msg(sprintf('Using %d points for clustering and other plots',num_coords));

             % build a set of indexes in names for each experiment
             % used later to extract the clusters from single experiments
             % (use expidx{1}{2} to get index)
            numnames=numel(expnames);
            if numnames > 0
               expidx=cell(numnames,1);
               for nindx=1:numnames
                  currexp=strfind(namesnof,expnames{nindx});
                  in_names=cellfun('length',currexp);
                  idx=find(in_names==1);
                  if ~isempty(idx)
                     expidx{nindx}={expnames{nindx},idx};
                  end
               end
            end
         end    % end of new file (re)setup

          % if we loaded a .type file to use it as if it were a .cth file, it
          % is possible that needs to be renormalized if we added in newly
          % discovered types later.
         if haveArchFile
            CthVars = renorm_cths(CthVars, namesnof);
         end

         a_centers=[];
         arch_names={};
         arch_nums=[];
         sorted_arch_names={};
         swall_arch_centers=[];
         swall_arch_names={};
         swall_arch_nums=[];
         sorted_swall_arch_names={};
         lareflex_arch_centers=[];
         lareflex_arch_names={};
         lareflex_arch_nums=[];
         sorted_lareflex_arch_names={};
         a_valid = false;
         swall_valid = false;
         lareflex_valid = false;

         if archetype   % always (re)load archetypes, it's a small file
            needctl = need_ctl(CthVars);
            needswall1 = need_swall1(CthVars);
            needlareflex = need_lareflex(CthVars);
            numbins=length(CthVars.(namesnof{1}).NSpaceCoords);
            archname = guiparams.typename;
            if needctl
               if strcmp(archname,"NONE") == 1
                  ui_msg("ERROR WARNSelect a .type file for Standard CTHs, aborting operation");
                  break;
               end
               [a_centers arch_names arch_nums a_valid] = load_archfile(archname,numbins);
               if a_valid
                  norm_type = getnorm(names{1});
                  a_centers = renorm_archetypes(a_centers, CthVars.(namesnof{1}).NSpaceCoords, norm_type);
                  globalmax = max(max(max(a_centers)),globalmax);
               else
                  ui_msg("ERROR WARNThere was an error loading the standard .type file, aborting operation");
                  break;
               end
            end
            if needswall1
               swallarchname = guiparams.swallname;
               if strcmp(swallarchname,"NONE") == 1
                  ui_msg("ERROR WARNSelect a .type file for Swallow CTHs, aborting operation");
                  break;
               end
               [swall_arch_centers swall_arch_names swall_arch_nums swall_valid] = load_archfile(swallarchname,numbins);
               if swall_valid
                  norm_type = getnorm(names{1});
                  swall_arch_centers = renorm_archetypes(swall_arch_centers, CthVars.(namesnof{1}).NSpaceCoords, norm_type);
                  globalmax = max(max(max(swall_arch_centers)),globalmax);
               else
                  ui_msg("ERROR WARNThere was an error loading the swallow .type file, aborting operation");
                  break;
               end
            end

            if needlareflex
               lareflexarchname = guiparams.lareflexname;
               if strcmp(lareflexarchname,"NONE") == 1
                  ui_msg("ERROR WARNSelect a .type file for Lareflex CTHs, aborting operation");
                  break;
               end
               [lareflex_arch_centers lareflex_arch_names lareflex_arch_nums lareflex_valid] = load_archfile(lareflexarchname,numbins);
               if lareflex_valid
                  norm_type = getnorm(names{1});
                  lareflex_arch_centers = renorm_archetypes(lareflex_arch_centers, CthVars.(namesnof{1}).NSpaceCoords, norm_type);
                  globalmax = max(max(max(lareflex_arch_centers)),globalmax);
               else
                  ui_msg("ERROR WARNThere was an error loading the lareflex .type file, aborting operation");
                  break;
               end
            end
         end
          % package the archetypes
          arch={};
          arch.std.have      = needctl;
          arch.std.nums      = arch_nums;
          arch.std.centers   = a_centers;
          arch.swall1.have   = needswall1;
          arch.swall1.nums    = swall_arch_nums;
          arch.swall1.centers = swall_arch_centers;
          arch.laref.have     = needlareflex;
          arch.laref.nums    = lareflex_arch_nums;
          arch.laref.centers = lareflex_arch_centers;

   %      do
   %         nobuff=kbhit(1);   % flush input buffer to accomodate impatient user
   %      until isempty(nobuff) % queuing up lots of key presses

         if termUI == 0
            choice = guiparams.color;
         else
            choice = loc_menu('Colors',1,'color*','color blind friendly');
         end
         if choice == 1
            colors = color;
            bkgnd = colorbgnd;
         else
            colors = cb_friendly;
            bkgnd = graybgnd;
         end

         if termUI == 0
            pick = guiparams.plotdim;
         else
            pick=loc_menu('Plot Dimensions',2,'2-D plot','3-D plot*');
         end
         if pick == 1
           dim=2;
         else
           dim=3;
         end

         if termUI == 0
            basispts = guiparams.basis;
         else
            if dim == 2
               basispts=loc_menu('Basis points',1,'Most distant 3 clusters*','Use PCA basis','Pick 3 points');
            else
               basispts=loc_menu('Basis points',1,'Most distant 4 clusters*','Use PCA basis','Pick 4 points');
            end
         end

           % pick point to point distance algorithm
         if termUI == 0
            choice = guiparams.pd_algo;
         else
            choice = loc_menu('PDIST algorithm',1,menu_pdistalgo);
         end
         pd_algo=pdistalgo{choice};
         if choice == 1
             if isempty(distnof)
                ui_msg('There is no distance info in this file, defaulting to Euclidean.');
                dist_matrix = loc_pdist(ptsnof, 'euclidean');
             else
                dist_matrix = squareform(distnof,'tovector')';  % from file
             end
         else
            dist_matrix = loc_pdist(ptsnof,pd_algo);
         end

         if termUI == 0
            choice = guiparams.log_dist;
         else
            choice = loc_menu('Dendrogram Plots Use log(distance)',1,'Yes*','No');
         end
         do_dendo_log = ifelse(choice==1,true,false);

         if termUI == 0
            choice = guiparams.autoscale;
         else
            choice = loc_menu('Used autoscaling for all CTH bar charts?',2,'Yes', 'No*');
         end
         autoscale = ifelse(choice==1,true,false);

         if termUI == 0
            choice = guiparams.errorbars;
         else
            choice = loc_menu('Create errorbar plots?',2,'Yes', 'No*');
         end
         do_errb = ifelse(choice==1,true,false);
         if termUI == 0
            choice = guiparams.curveshow;
         else
            choice = loc_menu('Create CTH curve plots?',2,'Yes', 'No*');
         end
         do_curves = ifelse(choice==1,true,false);

         if termUI == 0
            choice = guiparams.curvederive;
         else
            choice = loc_menu('Show derivatives for curve plots?',2,'Yes', 'No*');
         end
         do_derive = ifelse(choice==1,true,false);

         if termUI == 0
            choice = guiparams.errscale;
         else
            choice = loc_menu('Use same axis scale for errorbar plots?',2,'Yes', 'No*');
         end
         do_errbscale = ifelse(choice==1,true,false);

         if termUI == 0
            choice = guiparams.kmeans;
         else
            choice = loc_menu('Show k-means plots?',2,'Yes', 'No*');
         end
         do_kmeans = ifelse(choice==1,true,false);

         if termUI == 0
            choice = guiparams.fuzzy;
         else
            choice = loc_menu('Show Fuzzy C-means Cluster plots?',2,'Yes', 'No*');
         end
         do_fuzzy = ifelse(choice==1,true,false);
         if do_fuzzy
            if termUI == 0
               fuzzycut = guiparams.fuzzycutoff;
            else
               fuzzycut = getnum('Fuzzy Cut Off (0.1 is a good choice), 0 for none',0);
            end
         end
         if termUI == 0
            choice = guiparams.scrncap;
         else
            choice = loc_menu('Use large windows for screen caps?',2,'Yes', 'No*');
         end
         scrn_caps = ifelse(choice==1,true,false);

         [x1,y1,w1,h1] = tilemon1d1(1,4,3);  % (re)set plot locations desktop 1
         [x3,y3,w3,h3] = tilemon1d2(1,4,3);  % (re)set plot locations desktop 2
         cascademon1(1);
         scrn_pos1=[];
         [scrn_pos1]=calc_slots_m1(4,3);

         if termUI == 0
            choice = guiparams.flatplots;
         else
            choice = loc_menu('Create Flat barchart??',2, 'Yes', 'No*');
         end
         do_flatplots = ifelse(choice==1,true,false);

         if termUI == 0
            choice = guiparams.stereoper;
         else
            choice = loc_menu('Create Sterotaxic Plots For Each Experiment?',2,'Yes', 'No*');
         end
         do_stereo_per = ifelse(choice==1,true,false);

         if termUI == 0
            choice = guiparams.mod1;
         else
            choice = loc_menu('Create Modulation Depth Using Simple Region Algorithm?',2,'Yes', 'No*');
         end
         do_mod1 = ifelse(choice==1,true,false);

         if termUI == 0
            choice = guiparams.mod2;
         else
            choice = loc_menu('Create Modulation Depth Using Region Combining?',2,'Yes', 'No*');
         end
         do_mod2 = ifelse(choice==1,true,false);

         if termUI == 0
            choice = guiparams.pairwise;
         else
            choice = loc_menu('Create Pair-Wise Plots?',2,'Yes', 'No*');
         end
         do_pairwise = ifelse(choice==1,true,false);

         if termUI == 0
            choice = guiparams.typepairs;
         else
            choice = loc_menu('Create Archetype Pair-Wise Plots?',2,'Yes', 'No*');
         end
         do_typepairs = ifelse(choice==1,true,false);

         if termUI == 0
            do_iso = guiparams.isoplots;
            do_isoover = guiparams.isoover;
            do_isoembed = guiparams.isoembed;
            do_isocolor = guiparams.isocolor;
            do_isoscale = guiparams.isoscale;
         else
            choice = loc_menu('Create Isomap Plots?',2,'Yes', 'No*');
            do_iso = ifelse(choice==1,true,false);
            if do_iso
               choice = loc_menu('Create Isomap Plot Overlay?',2,'Yes', 'No*');
               do_isoover = ifelse(choice==1,true,false);
               choice = loc_menu('Create Isomap CTH Dimension Embeddings?',2,'Yes', 'No*');
               do_isoembed = ifelse(choice==1,true,false);
               choice = loc_menu('Create Isomap Color Per-Axis Plots?',2,'Yes', 'No*');
               do_isocolor = ifelse(choice==1,true,false);
               choice = loc_menu('Used autoscaling for ISO CTH bar charts?',2,'Yes', 'No*');
               do_isoscale = ifelse(choice==1,true,false);
            end
         end

         if do_iso
               [Y,R,E,C,isoh]=isoplots(dist_matrix,namesnof,ptsnof,cthstatsnof,isoh,x1,y1,w1,h1,colors,bkgnd,globalmax,num_runs,do_isoover,do_isoembed,do_errb,do_errbscale,do_isocolor,do_isoscale);
                if isempty(Y)
                   do_iso = false;   % can't do iso, distances <= 0
                   isoz=[];
                else
                   isoz=Y.coords{3};
                   [x1,y1,w1,h1] = tilemon1d1();  % isoplots used up some slots, move to next
                end
         end

         if termUI == 0
            choice = guiparams.link_algo;
         else
            choice = loc_menu('Linkage algorithm',2,menu_linkalgo);
         end
         link_algo=linkalgo{choice};

         if archetype
            [type_clusts tree] = cluster_with_types(CthVars,namesnof,names,pd_algo,pdistalgo,arch);
            numclusts(num_runs) = length(unique(type_clusts));
            dend = tree;
         else
            tree = loc_linkage(dist_matrix,link_algo);
         end
         if termUI == 0
            choice = guiparams.cophen;
         else
            choice = loc_menu('Calculate cophenetic coefficient?',2,'Yes', 'No*');
         end

         if choice == 1 && ~archetype
            ui_msg('Calculating cophenetic coefficient (this may take a while)...');
            [coeff,~] = loc_cophenet(tree,dist_matrix);
            msg = sprintf('Cophenetic coefficient is: %f.', coeff);
            ui_msg(msg);
         end

         if termUI == 0
            choice = guiparams.incon_sel;
            lev = guiparams.incon_depth;
            lev = round(lev);  % ints only
         else
            choice = loc_menu('Calculate inconsistency coefficient?',2, 'Yes', 'No*');
            if choice == 1
               lev = getnum('Enter depth (default is 2): ',2);
            end
         end
         if choice == 1 && ~archetype
            if lev > 0
               format('short','g');
               [incon,cl]=loc_inconsistent(tree,lev);
               msg=sprintf("   %10f     %10f     %3d           %10f\n",incon(incon(:,3) > 1,:)');
               msg1 = cstrcat("\nInconsistency Coeffcient\n      mean           stdev     #clusters   iconsistency coefficient\n",msg);
               ui_msg(msg1);
               format('long','g');
            end
         end

         if termUI == 0
            choice = guiparams.pickclust;  % 1 2 3
         else
            choice = loc_menu('Cluster choice',1,'Number of clusters*','Enter distance', 'Click on line');
         end
         clus_sel=choice;

           % draw dendrogram here
         tmph = figure('position',[wininfo(1).xorg, wininfo(1).yorg-wininfo(1).y_step,wininfo(1).width,wininfo(1).height],'visible','off');
         set(tmph,'numbertitle','off');
         dendoh=[dendoh;tmph];
         hold on;

         if ~archetype
            [~,currf,~,~] = fileparts(fname);
            titletxt = sprintf('[%s]   pdist: %s   linkage: %s  Run: %d %d',currf,pd_algo,link_algo,num_runs,getpid());
            set(gcf,'name',titletxt);
            set(gca,'color',bkgnd);
            set(gca,'defaultlinecolor','black');
            set(gca,'ticklength',[.001 .01]);
            axis('tight','autox');
            ui_msg('Creating dendrogram');
            box(gca,'off');

            if do_dendo_log
               adjust=min(tree(:,3));
               if adjust < 1.0
                  adjust = 1.0 + (sign(adjust)*adjust);
                  ui_msg("The dendrogram has distance values less than 1.\nValues adjusted so log(distance) will work");
               else
                  adjust = 0.0;
               end
               logtree=[tree(:,1),tree(:,2),log(tree(:,3)+adjust)]; % 'compress' Y coordinates
               logtree(end,3)=ceil(logtree(end-1,3));  % ensure top line seen 
               [pd1, td1, permd1, lhd] = loc_dendrogram(logtree);
               ylabel('log distance');
            else
               [pd1, td1, permd1, lhd] = loc_dendrogram(tree);
               ylabel('distance');
            end
         else
            axis('tight','autox');
            ui_msg('Dendrograms are not supported for archetype clustering');
            box(gca,'off');
            text(.2,.5,{"Dendrograms are not supported for archetype clustering."},'fontsize',16,'color','blue');
         end
         figure(dendoh(end),'visible','on');
         system(bring_to_fg_cmd);   % focus back to us
         drawnow();

         if ~archetype
            if clus_sel == 1
               if termUI == 0
                  if guiparams.numclust == 0  % prompt for it
                     numclusts(num_runs) = ui_prompt('Number Of Clusters: ');
                  else
                     numclusts(num_runs) = guiparams.numclust;
                  end
               else
                  numclusts(num_runs) = input('Number of clusters: ');
               end
               [clus,dend] = findclus(tree,numclusts(num_runs));
            elseif clus_sel == 2
               if termUI == 0
                  if guiparams.numclust == 0  % prompt for it
                     y = ui_prompt('Cluster distance ');
                  else
                     y = guiparams.numclust;
                  end
               else
                  y = input('Cluster distance ');
               end
               if do_dendo_log
                  [clus,dend,numclusts(num_runs)] = findcluslev(logtree,y);
               else
                  [clus,dend,numclusts(num_runs)] = findcluslev(tree,y);
               end
            else
               ui_msg("INPUT REQUIRED>> Click on a Y axis value in dendrogram for number of clusters.\rThe number of vertical lines at or above the value will be the number of clusters.");
               figure(dendoh(end));
               htxt = text(4,max(get(gca,'ytick')-1),{"Click on Y axis value","The number of vertical lines at or above the value","will be the number of clusters"},'fontsize',16,'color','blue');
               do
                  [x y buttons]=ginput(1);  % hitting enter can cause a empty return
               until (~isempty(x))
               msg = sprintf('Clicked on %d',y);
               delete(htxt);
               ui_msg(msg);
               if do_dendo_log
                  [clus,dend,numclusts(num_runs)] = findcluslev(logtree,y);
               else
                  [clus,dend,numclusts(num_runs)] = findcluslev(tree,y);
               end
            end
         end

          % now we know how many clusters, figure out how many windows on monitor 2
         num_plots = numclusts(num_runs);
         if guiparams.errorbars
            num_plots = num_plots + numclusts(num_runs);
         end
         if guiparams.curveshow
            num_plots = num_plots + numclusts(num_runs);
         end
         if guiparams.curvederive
            num_plots = num_plots + numclusts(num_runs);
         end
         max_win_warn = false;
         plot_rows = floor(sqrt(num_plots));
         if plot_rows > 8   % more than this many results in very tiny windows
            plot_rows = 8;
            max_win_warn = true;
         end
         plot_cols = floor(num_plots/plot_rows);
         while plot_cols * plot_rows < num_plots
            plot_cols = plot_cols+1;
         end
         if plot_cols > 8
            plot_cols = 8;
            max_win_warn = true;
         end
         if max_win_warn;
            ui_msg("NOTE: There are too many CTH windows to show all of them at once.\nUse the scroll buttons to see the rest of the windows.");
         end
         [x2,y2,w2,h2] = tilemon2d1(1,plot_cols,plot_rows);
         [x4,y4,w4,h4] = tilemon2d2(1,plot_cols,plot_rows);
         scrn_pos2=[];
         [scrn_pos2]=calc_slots_m2(plot_cols,plot_rows);
         num_slots=rows(scrn_pos2);

         if basispts == BASIS_MOSTDIST && ~archetype
            if dim == 2
               % pick top 3 clusters for coordinate points
               [clusters,dendorder] = findclus(tree,3);
            else
               [clusters,dendorder] = findclus(tree,4);  % or 4 for 3D
            end
            if sum(dendorder(:,2)==1) == 1        % just 1 pt
               p1 = ptsnof(dendorder(dendorder(:,2)==1),:);
            else
               p1 = centroid(ptsnof(dendorder(dendorder(:,2)==1),:)); % or several
            end

            if sum(dendorder(:,2)==2) == 1
               p2 = ptsnof(dendorder(dendorder(:,2)==2),:);
            else
               p2 = centroid(ptsnof(dendorder(dendorder(:,2)==2),:));
            end

            if sum(dendorder(:,2)==3) == 1
               p3 = ptsnof(dendorder(dendorder(:,2)==3),:);
            else
               p3 = centroid(ptsnof(dendorder(dendorder(:,2)==3),:));
            end
            if dim == 3
               if sum(dendorder(:,2)==4) == 1
                  p4 = ptsnof(dendorder(dendorder(:,2)==4),:);
               else
                  p4 = centroid(ptsnof(dendorder(dendorder(:,2)==4),:));
               end
            end
         else
            basispts = BASIS_PCA;  % a bit of a hack, no dendrogram for archetypes
         end

           % We may already have basis points.  If not, these are the
           % same for denrogram and cluster cases
         if basispts == BASIS_PCA
            [pca_coeff,score,latent,tsquare]=princomp(ptsnof);  % principal components
         elseif  basispts == BASIS_PICK
            if termUI == 0
               pt1 = guiparams.p0;
               pt2 = guiparams.p1;
               pt3 = guiparams.p2;
               pt4 = guiparams.p3;
            else
               if dim == 2
                  disp('Enter Three Points');
               else
                  disp('Enter Four Points');
               end
               pt1 = getnum('First: ');
               pt2 = getnum('Second: ');
               pt3 = getnum('Third: ');
               if dim == 3
                  pt4 = getnum('Fourth: ');
               end
            end
            p1 = ptsnof(pt1,:);
            p2 = ptsnof(pt2,:);
            p3 = ptsnof(pt3,:);
            if dim == 3
               p4 = ptsnof(pt4,:);
            end
         end

             % basis for projections
         if dim == 2
            if numbins == 2   % special case, no projection
               e1 = [1 0];
               e2 = [0 1];
               status = 1;
            else
               [e1,e2,status] = basis2d(p1,p2,p3);
            end
         else
            if numbins == 2
               ui_msg('Projecting 2D points into 3D not supported, switching to 2D plots');
               e1 = [1 0];
               e2 = [0 1];
               dim = 2;
               status = 1;
            else
               if basispts == BASIS_PCA
                  e1=pca_coeff(:,1)';
                  e2=pca_coeff(:,2)';
                  e3=pca_coeff(:,3)';
                  status = 1;
               else
                  [e1,e2,e3,status] = basis3d(p1,p2,p3,p4);
               end
            end
         end
         if status == 0
            ui_msg('There seems to be a problem with creating a basis, projections may not work.');
         end

         % create the projection of all pts and non-flat points
         % if using PCA, we must translate the points so the mean is at the origin.
         % The rotatations performed as part of PCA expect this.  We use the
         % mean of all the points as the origin of, uh, all the points.
         if basispts == BASIS_PCA
              mean_all = mean(allpts);
              mean_nof_pts = ptsnof - repmat(mean_all, size(ptsnof,1), 1); % non flats
              mean_flat_pts = flatpts - repmat(mean_all, size(flatpts,1), 1); % flats
              covar = mean_all' * mean_all/size(allpts,1);
              [U,S,V] = svd(covar);
              cap_var = diag(S)/sum(diag(S));
              if dim == 2
                 proj_nof = project2(e1,e2,mean_nof_pts);
                 proj_flat = project2(e1,e2,mean_flat_pts);
                 ui_msg(sprintf('Two axes capture %.2f percent of the variance',sum(cap_var(1:2))*100.0));
              else
                 proj_nof = project3(e1,e2,e3,mean_nof_pts);
                 proj_flat = project3(e1,e2,e3,mean_flat_pts);
                 ui_msg(sprintf('Three axes capture %.2f percent of the variance',sum(cap_var(1:3))*100.0));
              end
         else
            mean_all = 0;
            if dim == 2
               proj_nof = project2(e1,e2,ptsnof);
               proj_flat = project2(e1,e2,flatpts);
            else
               proj_nof = project3(e1,e2,e3,ptsnof);
               proj_flat = project3(e1,e2,e3,flatpts);
            end
         end

         % plot points here
         if scrn_caps
             hfig = figure('position',[wininfo(1).xorg, wininfo(1).yorg,wininfo(1).width,wininfo(1).height]);
         else
            hfig = figure('position',[x1,y1,w1,h1]);
         end
         set(hfig,'numbertitle','off');
         [x1,y1,w1,h1] = tilemon1d1();  % for next plot
         set(gca,'color',bkgnd);
         scatth=[scatth;hfig];
         hold on;
         if basispts == BASIS_PCA
            msg = sprintf('%d SPACE CTH PROJECTION (PCA) Run: %d %d',columns(ptsnof),num_runs,getpid());
         else
            msg = sprintf('%d SPACE CTH PROJECTION  Run: %d %d',columns(ptsnof),num_runs,getpid());
         end
         set(gcf,'name',msg);
         axis('auto');
         hold on;
         xlabel('X');
         ylabel('Y');
         if dim == 3
            zlabel('Z');
         end

         if dim == 2
           %origin
            plot(0,0,'o','markersize',10,'markerfacecolor','k','markeredgecolor','k','tag','points');
            % project the basis points and draw them (no pts for pca)
            if basispts ~= BASIS_PCA
               pp1 = project2(e1,e2,p1);
               pp2 = project2(e1,e2,p2);
               pp3 = project2(e1,e2,p3);
               plot(pp1(1),pp1(2),'o','markersize',8,'markerfacecolor','b','markeredgecolor','b','tag','points');
               plot(pp2(1),pp2(2),'o','markersize',8,'markerfacecolor','b','markeredgecolor','b','tag','points');
               plot(pp3(1),pp3(2),'o','markersize',8,'markerfacecolor','b','markeredgecolor','b','tag','points');
            end
            zf = proj_flat(end,:);  % zero flat at end
            plot(zf(1),zf(2),'o','markersize',12,'markerfacecolor','k','markeredgecolor','k','tag','points');
            pe1 = project2(e1,e2,e1);
            pe2 = project2(e1,e2,e2);
            pe1 = pe1*10;
            pe2 = pe2*10;
            line([0;pe1(1)],[0;pe1(2)],'tag','line');
            line([0;pe2(1)],[0;pe2(2)],'tag','line');
         else
            plot3(0,0,0,'o','markersize',10,'markerfacecolor','k','markeredgecolor','k','tag','points');
            if basispts ~= BASIS_PCA
               pp1 =  project3(e1,e2,e3,p1);
               pp2 =  project3(e1,e2,e3,p2);
               pp3 =  project3(e1,e2,e3,p3);
               pp4 =  project3(e1,e2,e3,p4);
               plot3(pp1(1),pp1(2),pp1(3),'o','markersize',8,'markerfacecolor','b','markeredgecolor','b','tag','points');
               plot3(pp2(1),pp2(2),pp2(3),'o','markersize',8,'markerfacecolor','b','markeredgecolor','b','tag','points');
               plot3(pp3(1),pp3(2),pp3(3),'o','markersize',8,'markerfacecolor','b','markeredgecolor','b','tag','points');
               plot3(pp4(1),pp4(2),pp4(3),'o','markersize',8,'markerfacecolor','b','markeredgecolor','b','tag','points');
            end
            zf = proj_flat(end,:);
            plot3(zf(1),zf(2),zf(3),'o','markersize',12,'markerfacecolor','k','markeredgecolor','k','tag','points');
            pe1 = project3(e1,e2,e3,e1);
            pe2 = project3(e1,e2,e3,e2);
            pe3 = project3(e1,e2,e3,e3);
            pe1 = pe1*10;
            pe2 = pe2*10;
            pe3 = pe3*10;
            line([0;pe1(1)],[0;pe1(2)],[0;pe1(3)],'tag','line');
            line([0;pe2(1)],[0;pe2(2)],[0;pe2(3)],'tag','line');
            line([0;pe3(1)],[0;pe3(2)],[0;pe3(3)],'tag','line');
         end

         fflush(stdout);

          % non-flat stereotaxic pts here
         hfig = figure('position',[x1,y1,w1,h1]);
         set(hfig,'numbertitle','off');
         [x1,y1,w1,h1] = tilemon1d1();  % for next plot
         set(gca,'color',bkgnd);
         stereoh=[stereoh;hfig];
         hold on;
         msg = sprintf('STEREOTAXIC CLUSTERS Run: %d %d',num_runs,getpid());
         set(gcf,'name',msg);
         box(gca,'on');
         axis('auto');
         hold on;
         xlabel('Right-Left (mm)');
         ylabel('Depth (mm)');
         zlabel('Anterior-Posteror (mm)');
         view(0,0);

         if do_flatplots
             % flat stereotaxic pts here
            hfig = figure('position',[x1,y1,w1,h1]);
            set(hfig,'numbertitle','off');
            [x1,y1,w1,h1] = tilemon1d1();  % for next plot
            set(gca,'color',bkgnd);
            stereohf=[stereohf;hfig];
            hold on;
            msg = sprintf('STEREOTAXIC FLAT POINTS Run: %d %d',num_runs,getpid());
            set(gcf,'name',msg);
            axis('auto');
            box(gca,'on');
            hold on;
            xlabel('Right-Left (mm)');
            ylabel('Depth (mm)');
            zlabel('Anterior-Posteror (mm)');
            view(0,0);
         end

         if do_stereo_per == 1
              % create figures where we will show individual pts
            drawnow;
            cmd=sprintf('wmctrl -s %d',secondary);
            system(cmd);
            exph=[];
            for expplot=1:numnames
               hfig = figure('position',[x4,y4,w4,h4]);
               set(hfig,'numbertitle','off');
               [x4,y4,w4,h4] = tilemon2d2();
               set(gca,'color',bkgnd);
               exph =[exph;hfig];
               msg = sprintf('STEREOTAXIC PLOTS BY EXPERIMENT  Run: %d %d',num_runs,getpid);
               set(gcf,'name',msg);
               axis('auto');
               box(gca,'on');
               hold on
               xlabel('Right-Left');
               ylabel('Depth');
               zlabel('Anterior-Posteror');
               view(0,0);
                 % names have _ chars, if using tex formatter,
                 % _ is displayed as subscript. Pick 'none'.
               title(expnames{expplot},'interpreter','none');
            end
            drawnow;
            cmd=sprintf('wmctrl -s %d',primary);
            system(cmd);
         end

         if do_mod1 && isempty(modh)   % true for new files, only do once
            %  modulation depth  algo #1
            modx=[];
            mody=[];
            modz=[];
            [modx,mody,modz] = mod_depth1(ptsnof);
            tmph = figure('position',[x1,y1,w1,h1]);
            set(tmph,'numbertitle','off');
            [x1,y1,w1,h1] = tilemon1d1();  % for next plot
            hold on;
            modh=[modh;tmph];  % will be fig sub1 sub2
            msg = sprintf('Modulation Depth Algo #1');
            set(gcf,'name',msg);
            tmph = v38_subplot(1,2,1,'align');
            modh=[modh;tmph];
            hold on;
            box(gca,'on');
            title('Modulation Depth');
            xlabel('High Rate Start Bin');
            ylabel('High Rate Region Width');
            zlabel('Modulation Depth');
            set(gca,'xminortick','on','yminortick','on','zminortick','on');
            tmph = v38_subplot(1,2,2,'align');
            modh=[modh;tmph];
            hold on;
            box(gca,'on');
            title('Modulation Depth With Random Width & Start Jitter');
            xlabel('High Rate Start Bin');
            ylabel('High Rate Region Width');
            zlabel('Modulation Depth');
            set(gca,'xminortick','on','yminortick','on','zminortick','on');
            xbin=hist(modx,numbins);

            tmph = figure('position',[x1,y1,w1,h1]);
            set(tmph,'numbertitle','off');
            [x1,y1,w1,h1]=tilemon1d1();
            hold on;
            set(gcf,'name','Modulation Depth Distributions Algo #1');
            v38_subplot(1,3,1,'align');
            hold on;
            xlabel('Hight Rate Start Bin');
            hist(modx,numbins);
            xexp=numpts/numbins;
            xdf=numbins-1;
            ybin=hist(mody,numbins-1);
            v38_subplot(1,3,2,'align');
            hold on;
            xlabel('High Rate Region Width');
            hist(mody,numbins-1);
            yexp=numpts/numbins-1;
            ydf=numbins-2;
            zbin=hist(modz,numpts);
            zexp=numpts;
            zdf=numpts-1;
            v38_subplot(1,3,3,'align');
            hold on;
            xlabel('Modulation Depth');
            hist(modz,numbins);
            px = pval(xbin,xexp,xdf);
            py = pval(ybin,yexp,ydf);
            pz = pval(zbin,zexp,zdf);
            if (px > .1 || py > .1 || pz > .1)
               msg=sprintf("Algo#1:\np for start bins: %d\np for high rate region: %d\np for modulation depth: %d ",px,py,pz);
               ui_msg(msg);
            end
         end
             % do flats

         if do_mod1 && do_flatplots && isempty(modhf1) && numflats > 1
            modx1=[];
            mody1=[];
            modz1=[];
            [modx1,mody1,modz1] = mod_depth1(flatpts);
            tmph = figure('position',[x1,y1,w1,h1]);
            set(gcf,'numbertitle','off');
            [x1,y1,w1,h1]=tilemon1d1();
            modhf1=[modhf1;tmph];
            hold on;
            msg = sprintf('Modulation Depth For Flats Algo 1');
            set(gcf,'name',msg);
            xlabel('High Rate Start Bin');
            ylabel('High Rate Bin Width');
            zlabel('Modulation Depth');
            zlim([0 1]);
            set(gca,'xminortick','on','yminortick','on','zminortick','on');
            plot3(modx1,mody1,modz1,'o','markerfacecolor','b','markeredgecolor','b');
         end

         if do_mod2 && isempty(modh2) 
            %  modulation depth, algo 2
            modx2=[];
            mody2=[];
            modz2=[];
            [modx2,mody2,modz2,errstat,nummerg] = mod_depth2(ptsnof);
            tmph = figure('position',[x1,y1,w1,h1]);
            set(tmph,'numbertitle','off');
            [x1,y1,w1,h1] = tilemon1d1();  % for next plot
            hold on;
            modh2=[modh2;tmph];  % will be fig sub1 sub2
            msg = sprintf('Modulation Depth  Algo #2');
            set(gcf,'name',msg);
            tmph = v38_subplot(1,2,1,'align');
            modh2=[modh2;tmph];
            hold on;
            box(gca,'on');
            title('Modulation Depth');
            xlabel('High Rate Peak Bin');
            ylabel('High Rate Region Width');
            zlabel('Modulation Depth');
            set(gca,'xminortick','on','yminortick','on','zminortick','on');
            tmph = v38_subplot(1,2,2,'align');
            modh2=[modh2;tmph];
            hold on;
            box(gca,'on');
            title('Modulation Depth With Random Width & Start Jitter');
            xlabel('High Rate Peak Bin');
            ylabel('High Rate Region Width');
            zlabel('Modulation Depth');
            set(gca,'xminortick','on','yminortick','on','zminortick','on');
            xbin2=hist(modx2,numbins);

            tmph = figure('position',[x1,y1,w1,h1]);
            set(tmph,'numbertitle','off');
            [x1,y1,w1,h1]=tilemon1d1();
            hold on;
            set(gcf,'name','Modulation Depth Distributions Algo #2');
            v38_subplot(1,5,1,'align');
            hold on;
            xlabel('Hight Rate Peak Bin');
            hist(modx2,numbins);
            xexp2=numpts/numbins;
            xdf2=numbins-1;
            ybin2=hist(mody2,numbins-1);
            v38_subplot(1,5,2,'align');
            hold on;
            xlabel('High Rate Region Width');
            hist(mody2,numbins-1);
            yexp2=numpts/numbins-1;
            ydf2=numbins-2;
            zbin2=hist(modz2,numpts);
            zexp2=numpts;
            zdf2=numpts-1;
            v38_subplot(1,5,3,'align');
            hold on;
            xlabel('Modulation Depth');
            hist(modz2,numbins);
            v38_subplot(1,5,4,'align');
            hold on;
            xlabel('Region Adjust');
            hist(errstat);
            v38_subplot(1,5,5,'align');
            hold on;
            xlabel('Number of Merges');
            bar([0:numbins/2-1],nummerg);
            px = pval(xbin2,xexp2,xdf2);
            py = pval(ybin2,yexp2,ydf2);
            pz = pval(zbin2,zexp2,zdf2);
            if (px > .1 || py > .1 || pz > .1)
               msg=sprintf("Algo #2:\np for start bins: %d\np for high rate region: %d\np for modulation depth: %d ",px,py,pz);
               ui_msg(msg);
             end
             % do flats
         end

         if do_mod2 && do_flatplots && isempty(modhf2) && numflats > 1
            modx1=[];
            mody1=[];
            modz1=[];
            [modx1,mody1,modz1,errstat] = mod_depth2(flatpts);
            tmph = figure('position',[x1,y1,w1,h1]);
            set(tmph,'numbertitle','off');
            [x1,y1,w1,h1]=tilemon1d1();
            modhf2=[modhf2;tmph];
            hold on;
            msg = sprintf('Modulation Depth For Flats Algo 2  Run: %d %d',num_runs,getpid());
            set(gcf,'name',msg);
            xlabel('High Rate Peak Bin');
            ylabel('High Rate Bin Width');
            zlabel('Modulation Depth');
            set(gca,'xminortick','on','yminortick','on','zminortick','on');
            zlim([0 1]);
            plot3(modx1,mody1,modz1,'o','markerfacecolor','b','markeredgecolor','b');
         end

            %project pts
         colidx = 0;
         scattcol = 0;
         clust_cents=cell;
         cluster_centers=[];
         km_cluster_centers=[];
         km_cent_cluster_centers=[];
         fuzzy_cluster_centers=[];
         stereo_clusts=[];
         curr_arch_idx=1;
         curr_swall_arch_idx=1;
         curr_lareflex_arch_idx=1;

         [~, order]=unique(dend(:,2));
         lr_order=sort(order);
         clust_list=dend(lr_order,2)';
         currclusnum = 1; % sometimes order in clust_list is not 1-N, sort names, etc.
         if archetype
            if needctl
               curr_arch_idx = [(1:size(arch_nums)(1))' arch_nums];
               [c_idx,~] = find(clust_list == curr_arch_idx(:,2));
               sorted_arch_names = {arch_names{c_idx}}; % sort names 
            end
            if needswall1
               curr_swall_arch_idx = [(1:size(swall_arch_nums)(1))' swall_arch_nums];
               [s_idx,~] = find(clust_list == curr_swall_arch_idx(:,2));
               sorted_swall_arch_names = {swall_arch_names{s_idx}}; % sort names 
            end
            if needlareflex
               curr_lareflex_arch_idx = [(1:size(lareflex_arch_nums)(1))' lareflex_arch_nums];
               [s_idx,~] = find(clust_list == curr_lareflex_arch_idx(:,2));
               sorted_lareflex_arch_names = {lareflex_arch_names{s_idx}}; % sort names 
            end
            msg = sprintf('Found %d clusters using %d Archetypes CTHs', length(clust_list),length(arch_names));
         else
            msg = sprintf('%d clusters selected',length(clust_list));
         end
         ui_msg(msg);
         msg1='';

         % *********************************************************
         % MAIN LOOP for cluster scatter, cth hists, error bars, etc.
         % *********************************************************
         for num=clust_list
            proj=[];
            curr_idx = dend(find(dend(:,2)==num))';
            proj = proj_nof(curr_idx,:);
            bars={namesnof{curr_idx}};
            pts=ptsnof(curr_idx,:);
            stats=cthstatsnof(curr_idx);
            plotcurves=curvesnof(curr_idx);
            nextblock = ptsnof(curr_idx,:);
            curr_color = shift(colors,-scattcol)(1,:);
            figure(scatth(end));   % current projection fig
            if ~isempty(proj)
               if dim == 2
                  plot(proj(:,1),proj(:,2),'o','markersize',4,'markerfacecolor',curr_color,'markeredgecolor',curr_color,'tag','points');
               else
                  plot3(proj(:,1),proj(:,2),proj(:,3),'o','markersize',4,'markerfacecolor',curr_color,'markeredgecolor',curr_color,'tag','points');
               end
            end
            cm_name=sprintf('ClusterMean_%d_m_%d_x_%d',currclusnum, numclusts(num_runs),numpts+currclusnum);
            clust_cents{num} = cm_name;

            if ~archetype
               if rows(nextblock) == 1
                  clust_mean = nextblock; % only one point in cluster
               else
                  clust_mean = centroid(nextblock);
               end
            else
               clust_mean=[];
               if needctl
                  clust_mean = a_centers(find(curr_arch_idx(:,2)==num),:);
               end
               if needswall1 && isempty(clust_mean)
                  clust_mean = swall_arch_centers(find(curr_swall_arch_idx(:,2)==num),:);
               end
               if needlareflex && isempty(clust_mean)
                  clust_mean = lareflex_arch_centers(find(curr_lareflex_arch_idx(:,2)==num),:);
               end
            end
            eval([clust_cents{num} '= clust_mean;']);  % assign value to this var
            cluster_centers=[cluster_centers;clust_mean];
            if dim == 2
               cent = project2(e1,e2,clust_mean-mean_all);
               plot(cent(:,1),cent(:,2),'+','color',curr_color,'markersize', 20,'linewidth',3,'tag','center');
            else
               cent = project3(e1,e2,e3,clust_mean-mean_all);
               plot3(cent(:,1),cent(:,2),cent(:,3),'+','color',curr_color,'markersize', 20,'linewidth',3,'tag','center');
            end

              % stereotaxic pts in cluster, in group plot and also
              % individual plots for each experiment
            figure(stereoh(end));   % current projection fig
            proj=[];
            proj=[ [coordsnofpts(curr_idx).ap_atlas]'  [coordsnofpts(curr_idx).rl_atlas]' -[coordsnofpts(curr_idx).dp_atlas]'];
            if ~isempty(proj)
               stereo_clusts(num) = plot3(proj(:,1),proj(:,2),proj(:,3),plotchars(1),'markersize',8,'markeredgecolor',curr_color,'linewidth',1.6);
            end

            if do_stereo_per == 1
                  % pts in this cluster for each exp in all per-exp plots
               for curr_exp=1:numnames
                  in_exp = intersect(expidx{curr_exp}{2},curr_idx);
                  if ~isempty(in_exp)
                      figure(exph(curr_exp));
                      exp_pts =[ [coordsnofpts(in_exp).ap_atlas]'  [coordsnofpts(in_exp).rl_atlas]' -[coordsnofpts(in_exp).dp_atlas]'];
                      plot3(exp_pts(:,1),exp_pts(:,2),exp_pts(:,3),plotchars(1),'markersize',8,'markeredgecolor',curr_color,'linewidth',1.6);
                  end
               end
            end

            plotchars=shift(plotchars,-1);   % rotate through chars

             % color the dendrogram leaves in this cluster
            if ~archetype
               figure(dendoh(end));
               set(lhd(curr_idx),'color',curr_color);
            end

            if do_mod1
                   % algo #1
               figure(modh(end-2));
               v38_subplot(modh(end-1));
               if dim == 2
                  plot(modx(curr_idx),mody(curr_idx),'o','markersize',6,'markerfacecolor',curr_color,'markeredgecolor',curr_color);
            else
                  plot3(modx(curr_idx),mody(curr_idx),modz(curr_idx),'o','markersize',6,'markerfacecolor',curr_color,'markeredgecolor',curr_color);
               end
               v38_subplot(modh(end));
               if dim == 2
                  plot(modx(curr_idx),mody(curr_idx),'o','markersize',6,'markerfacecolor',curr_color,'markeredgecolor',curr_color);
               else
                   % add a random bit of jitter to each pt so duplicate pts in different
                   % colors can be seen
                  jitx= rand(columns(curr_idx),1) - 0.333;
                  jity= rand(columns(curr_idx),1) - 0.333;
                  plot3(modx(curr_idx) .+ jitx,mody(curr_idx) .+ jity,modz(curr_idx),'o','markersize',6,'markerfacecolor',curr_color,'markeredgecolor',curr_color);
               end
            end

                % algo #2
            if do_mod2
               figure(modh2(end-2));
               v38_subplot(modh2(end-1));
               if dim == 2
                  plot(modx2(curr_idx),mody2(curr_idx),'o','markersize',6,'markerfacecolor',curr_color,'markeredgecolor',curr_color);
               else
                  plot3(modx2(curr_idx),mody2(curr_idx),modz2(curr_idx),'o','markersize',6,'markerfacecolor',curr_color,'markeredgecolor',curr_color);
               end
               v38_subplot(modh2(end));
               if dim == 2
                  plot(modx2(curr_idx),mody2(curr_idx),'o','markersize',6,'markerfacecolor',curr_color,'markeredgecolor',curr_color);
               else
                  jitx= rand(columns(curr_idx),1) - 0.333;
                  jity= rand(columns(curr_idx),1) - 0.333;
                  plot3(modx2(curr_idx) .+ jitx,mody2(curr_idx) .+ jity,modz2(curr_idx),'o','markersize',6,'markerfacecolor',curr_color,'markeredgecolor',curr_color);
               end
            end
            % ISOMAP
            if do_iso
               figure(isoh(end));
               plot3(isoz(1,curr_idx),isoz(2,curr_idx),isoz(3,curr_idx),'o','markersize',4,'markerfacecolor',curr_color,'markeredgecolor',curr_color);
            end

             % show bar charts
            if ~archetype 
               msg = sprintf('Creating bar chart %d of %d.',currclusnum,numclusts(num_runs));
               ui_msg(msg);
               cnum=sprintf('CTHs for Cluster# %d  Run: %d  %d',currclusnum,num_runs,getpid());
               enum=sprintf('Error Bars for Cluster# %d  Run: %d  %d',currclusnum,num_runs,getpid());
               vnum=sprintf('Curves for Cluster# %d  Run: %d  %d',currclusnum,num_runs,getpid());
               dnum=sprintf('Derivatives for Cluster# %d  Run: %d  %d',currclusnum,num_runs,getpid());
            else
               msg = sprintf('Creating bar chart %d of %d using archetype %d.',currclusnum,numclusts(num_runs),num);
               ui_msg(msg);
               cnum=sprintf('CTHs for Archetype# %d  Run: %d  %d',num,num_runs,getpid());
               enum=sprintf('Error Bars for Archetype# %d  Run: %d  %d',num,num_runs,getpid());
               vnum=sprintf('Curves for Archetype# %d  Run: %d  %d',num,num_runs,getpid());
               dnum=sprintf('Derivatives for Archetype# %d  Run: %d  %d',num,num_runs,getpid());
            end
            tmph = showbars(cnum,bars,pts,curr_color,x2,y2,w2,h2,bkgnd,globalmax,clust_mean,autoscale,archetype,num);
            barh = [barh tmph];
            scroll_step = 1;
            if do_errb == 1
               msg = sprintf('Creating error bar plots %d of %d.',currclusnum,numclusts(num_runs));
               ui_msg(msg);
               [x2,y2,w2,h2] = tilemon2d1();
               tmph = showstats(enum,bars,stats,curr_color,x2,y2,w2,h2,bkgnd,do_errbscale);
               barh = [barh tmph];
               scroll_step = scroll_step+1;
            end
            if do_curves == 1
               msg = sprintf('Creating curve plots %d of %d.',currclusnum,numclusts(num_runs));
               ui_msg(msg);
               [x2,y2,w2,h2] = tilemon2d1();
               if do_derive
                  [xd,yd,wd,hd] = tilemon2d1();
               else
                  xd=0;yd=0;wd=0;hd=0;
               end
               [tmph,tmpd] = showcurves(vnum,dnum,bars,plotcurves,curr_color,x2,y2,w2,h2,xd,yd,wd,hd,bkgnd,autoscale,do_derive);
               barh = [barh tmph];
               scroll_step = scroll_step+1;
               if do_derive
                  barh = [barh tmpd];
                  scroll_step = scroll_step+1;
               end
            end
            currclusnum = currclusnum + 1;
            [x2,y2,w2,h2] = tilemon2d1();
            colidx = colidx+1;
            scattcol = scattcol+1;
         end
           % adjust aspects and limits on these
         figure(stereoh(end));   % current projection fig
         stax=axis();
         min_stax=min(stax);
         max_stax=max(stax);
         axis([min_stax max_stax min_stax max_stax min_stax max_stax],'square');

         if do_typepairs
            if archetype
              compare_types(CthVars,clust_list,namesnof,names,dend,colors,maxdist,arch);
            else
               ui_msg("ERROR WARNPair-Wise Type Plots are only created when using archetype clustering.");
            end
         end

         if do_flatplots
            figure(stereohf(end));   % plot flat pts
            min_stax=min(stax);
            max_stax=max(stax);
            axis([min_stax max_stax min_stax max_stax min_stax max_stax],'square');
         end

         if do_stereo_per == 1
               % pts in this cluster for each exp in all per-exp plots
            for curr_exp=1:numnames
               figure(exph(curr_exp));
               stax=axis();
               min_stax=min(stax);
               max_stax=max(stax);
               axis([min_stax max_stax min_stax max_stax min_stax max_stax],'square');
            end
         end

         % Get the window ids of the cth and errorbar plots so we can move them around
         % Things are complicated if doing multiple runs
         if ~archetype
            this_run_str=sprintf('Cluster# [0-9]* *Run: %d*  *%d',num_runs,getpid());
         else
            this_run_str=sprintf('CTHs for Archetype# [0-9]* *Run: %d* *%d',num_runs,getpid());
         end
         bar_ids=[get_win_ids(this_run_str) bar_ids];
         tot_bars=numel(bar_ids);
         num_to_show=min(num_slots,tot_bars);

         if do_flatplots
            if numflats > 0  % even if just ZeroFlat, user wanted to see it
               ui_msg('Creating bar chart for flats.');
               cnum=sprintf('Flats  Run: %d  %d',num_runs);
               enum=sprintf('Error Bars for Flats Run: %d',num_runs);
               vnum=sprintf('Curves for Flats Run: %d',num_runs);
               dnum=sprintf('Derivatives for Flats  Run: %d',num_runs);
               curr_color = shift(colors,-scattcol)(1,:);
               scattcol = scattcol + 1;
               showbars(cnum,flatnames,flatpts,curr_color,x1,y1,w1,h1,bkgnd,globalmax,ZeroFlat.NSpaceCoords,autoscale,false,archetype,0);
               [x1,y1,w1,h1] = tilemon1d1();
               if do_errb == 1
                  showstats(enum,flatnames,flatstats,curr_color,x1,y1,w1,h1,bkgnd,do_errbscale);
                  [x1,y1,w1,h1] = tilemon1d1();
               end

               if do_curves == 1
                  if do_derive
                     [xd,yd,wd,hd] = tilemon1d1();
                  end
                  showcurves(vnum,dnum,flatnames,flatcurves,curr_color,x1,y1,w1,h1,xd,yd,wd,hd,bkgnd,autoscale,do_derive);
                  [x1,y1,w1,h1] = tilemon1d1();
               end
            end

            figure(stereohf(end));   % plot flat pts
            proj=[];
            num_coords = numel(flatnames);
            for st_coords=1:num_coords
               proj=[proj;[CthVars.(flatnames{st_coords}).RealCoords.ap_atlas CthVars.(flatnames{st_coords}).RealCoords.rl_atlas  -CthVars.(flatnames{st_coords}).RealCoords.dp_atlas]];
            end
            if ~isempty(proj)
               plot3(proj(:,1),proj(:,2),proj(:,3),'o','markersize',4,'markerfacecolor',curr_color,'markeredgecolor',curr_color);
            end
         end
           % too much stuff on screens!  use desktop to right, or wrap to 1st if on last
         if do_kmeans == 1 || do_fuzzy == 1
            drawnow();
            pause(1);  % give last plot window time to show or 
                       % else it will be on next desktop
            cmd=sprintf('wmctrl -s %d',secondary);
            system(cmd);
         end

         if do_kmeans
            drawnow();
            pause(1);  % give last plot window time to show or 
                       % else it will be on next desktop
            cmd=sprintf('wmctrl -s %d',secondary);
            system(cmd);

               % use our avg cth's as initial centers
            [kmeans_clusts_c, kmcent_centers, sumd, dist_matrix] = loc_kmeans(ptsnof, [],'emptyaction','singleton','start','matrix',cluster_centers);
            scattcol = 0;
            tmph = figure('position',[x3,y3,w3,h3]);
            kmeanh=[kmeanh;tmph];
            [x3,y3,w3,h3]=tilemon1d2();
            hold on;
            msg = sprintf('K-Means Run: %d  %d',num_runs,getpid());
            set(gcf,'name',msg);
            tmph = v38_subplot(1,2,1,'align');
            kmeanh=[kmeanh;tmph];
            hold on;
            title('Using Centroids');
            currclusnum=1;

            if archetype
               k_clust_list = curr_arch_idx(:,2)==clust_list;
               k_clust_list = sum(k_clust_list,2);
               a_idx=find(k_clust_list==1);
               k_clust_list=curr_arch_idx(a_idx,1)';
            end
            for num=1:numclusts
               figure(kmeanh(end-1));
               v38_subplot(kmeanh(end));
               proj=[];
               kmean_idx = find(kmeans_clusts_c==num);
               proj = proj_nof(kmean_idx,:);
               km_color = shift(colors,-scattcol)(1,:);
               if ~isempty(proj)
                  if dim == 2
                     plot(proj(:,1),proj(:,2),'o','markersize',4,'markerfacecolor',km_color,'markeredgecolor',km_color);
                     cent = project2(e1,e2,cluster_centers(num,:)-mean_all);
                     lh1 = plot(cent(:,1),cent(:,2),'+','color',km_color,'markersize', 10,'linewidth',3);
                     lh1 = copyobj(lh1);
                     cent = project2(e1,e2,kmcent_centers(num,:)-mean_all);
                     lh2 = plot(cent(:,1),cent(:,2),'v','color',km_color,'markersize', 10,'linewidth',3);
                  else
                      plot3(proj(:,1),proj(:,2),proj(:,3),'o','markersize',4,'markerfacecolor',km_color,'markeredgecolor',km_color,'tag','points');
                     cent = project3(e1,e2,e3,cluster_centers(num,:)-mean_all);
                     lh1 = plot3(cent(:,1),cent(:,2),cent(:,3),'+','color',km_color,'markersize', 10,'linewidth',3);
                     cent = project3(e1,e2,e3,kmcent_centers(num,:)-mean_all);
                     lh2 = plot3(cent(:,1),cent(:,2),cent(:,3),'v','color',km_color,'markersize', 10,'linewidth',3);
                     lh2 = copyobj(lh2);
                  end
               end
               if ~archetype
                  cnum=sprintf('K-Means Using Centroids Cluster# %d  Run: %d  %d',currclusnum,num_runs,getpid());
               else
                  cnum=sprintf('K-Means Using Archetype Cluster# %d  Run: %d  %d',curr_arch_idx(k_clust_list(currclusnum),2),num_runs,getpid());
               end
               bars={namesnof{kmean_idx}};
               pts=ptsnof(kmean_idx,:);
               tmph = showbars(cnum,bars,pts,km_color,x4,y4,w4,h4,bkgnd,globalmax,cluster_centers(num,:),autoscale,archetype,0);
               [x4,y4,w4,h4] = tilemon2d2();
               currclusnum = currclusnum + 1;
               scattcol = scattcol+1;
            end
            figure(kmeanh(end-1));
            set(lh1,'color','k');
            set(lh2,'color','k');
            legend(gca,[lh1 lh2],{'Centroid Centers','K-Means Centers'},'location','northwest');
            legend('boxoff')';

               % let k-means find it's own centers
            [kmeans_clusts, km_centers, sumd, dist_matrix] = loc_kmeans (ptsnof, numclusts(num_runs),'emptyaction','singleton');
            scattcol = 0;
            figure(kmeanh(end-1));
            tmph = v38_subplot(1,2,2,'align');
            kmeanh=[kmeanh;tmph];
            hold on;
            title('K-Means Finds Clusters');
            currclusnum=1;
            for num=1:numclusts(num_runs);
               figure(kmeanh(end-2));
               v38_subplot(kmeanh(end));
               proj=[];
               kmean_idx = find(kmeans_clusts==num);
               proj = proj_nof(kmean_idx,:);
               km_color = shift(colors,-scattcol)(1,:);

               if ~isempty(proj)
                  if dim == 2
                     plot(proj(:,1),proj(:,2),'o','markersize',4,'markerfacecolor',km_color,'markeredgecolor',km_color,'tag','points');
                     cent = project2(e1,e2,km_centers(num,:)-mean_all);
                     plot(cent(:,1),cent(:,2),'v','color',km_color,'markersize', 10,'linewidth',3);
                  else
                     plot3(proj(:,1),proj(:,2),proj(:,3),'o','markersize',4,'markerfacecolor',km_color,'markeredgecolor',km_color);
                     cent = project3(e1,e2,e3,km_centers(num,:)-mean_all);
                     plot3(cent(:,1),cent(:,2),cent(:,3),'v','color',km_color,'markersize', 10,'linewidth',3);
                  end
               end

               cnum=sprintf('K-Means Cluster# %d  Run: %d  %d',currclusnum,num_runs,getpid());
               bars={namesnof{kmean_idx}};
               pts=ptsnof(kmean_idx,:);
               tmph = showbars(cnum,bars,pts,km_color,x4,y4,w4,h4,bkgnd,globalmax,km_centers(num,:),autoscale,archetype,0);
               [x4,y4,w4,h4] = tilemon2d2();
               currclusnum = currclusnum + 1;
               scattcol = scattcol+1;
            end
         end

         if do_fuzzy == 1
            if do_kmeans == 1  % already on second workspace, switch back
               drawnow;
               pause(1);
               cmd=sprintf('wmctrl -s %d',primary);
               system(cmd);
            end
            system(bring_to_fg_cmd);
            ui_msg("\nNOTE: Fuzzy clustering will take a while to calculate the clusters.\nPlease wait and do not click on anything.\nWORKING. . .");

            [fcm_cent,softp,itres]=fcm(ptsnof,max(clust_list),[NaN,200,NaN,0]);

            ui_msg("Fuzzy clustering done.");
            drawnow();
            cmd=sprintf('wmctrl -s %d',secondary);
            system(cmd);

            hfig = figure('position',[x3,y3,w3,h3]);
            set(hfig,'numbertitle','off');
            [x3,y3,w3,h3] = tilemon1d2();
            set(gca,'color',bkgnd);
            fuzzyh=[fuzzyh;hfig];
            hold on;
            msg = sprintf('%d FUZZY C-MEANS CLUSTERS Run: %d  %d',columns(ptsnof),num_runs,getpid());
            set(gcf,'name',msg);
            axis('auto');
            set(gca,'fontsize',12);
            xlabel("X\nCircles are colored by first cluster membership\nSquares are CTHs inside the cutoff value and are colored by second cluster membership");
            ylabel('Y');
            if dim == 3
               zlabel('Z');
            end

            if dim == 2
               ccp=project(e1,e2,fcm_cent);
            else
               ccp=project3(e1,e2,e3,fcm_cent);
            end

            figure(fuzzyh(end));
            hold on
            % softp is a matrix where each column has the degree to which
            % a pt belongs to the cluster.  That is, softp(:,1) is a ranking
            % of how much a point belongs to the cluster by number of clusters
            [val,f_idx]=max(softp);
            softcol = 0;
            currclusnum=1;
            for clnum=clust_list
               softcurr_color = shift(colors,-softcol)(1,:);
               curr_idx = find(f_idx==clnum);
               proj = proj_nof(curr_idx,:);
               if ~isempty(proj)
                  if dim == 2
                     plot(ccp(clnum,1),ccp(clnum,2),'+','color',softcurr_color,'markersize', 20,'linewidth',3);
                     plot(proj(:,1),proj(:,2),'o','markersize',4,'markerfacecolor',softcurr_color,'markeredgecolor',softcurr_color);
                  else
                     plot3(ccp(clnum,1),ccp(clnum,2),ccp(clnum,3),'+','color',softcurr_color,'markersize', 20,'linewidth',3);
                     plot3(proj(:,1),proj(:,2),proj(:,3),'o','markersize',4,'markerfacecolor',softcurr_color,'markeredgecolor',softcurr_color);
                  end
               end
               softcol = softcol+1;
            end

            if fuzzycut - 0.0 > eps
                  % 2nd clust membership inside cutoff
               softp2 = softp;
               maxidx=sub2ind(size(softp),f_idx,1:columns(softp));
               softp2(maxidx) = 0;
               [val2,idx2]=max(softp2);
               softcol=0;
               cdiffs=[val-val2];
               diffsclust=[cdiffs' idx2'];   % lookup table
               for clnum=clust_list
                  softcurr_color = shift(colors,-softcol)(1,:);
                  curr_idx = find(diffsclust(:,1) <= fuzzycut & diffsclust(:,2)==clnum);
                  proj = proj_nof(curr_idx,:);
                  if ~isempty(proj)
                     if dim == 2
                        plot(proj(:,1),proj(:,2),'s','markersize',8,'markeredgecolor',sofcurr_color,'linewidth',2);
                     else
                        plot3(proj(:,1),proj(:,2),proj(:,3),'s','markersize',8,'markeredgecolor',softcurr_color,'linewidth',2);
                     end
                  end
                  softcol = softcol+1;
               end

               vdx = find(diffsclust(:,1) < fuzzycut)';
               partcoef = partition_coeff(softp);
               partentr = partition_entropy(softp,2);
               fuzziter = length(itres);
               msg = sprintf("\nFuzzy C-Means CTHs inside cuttoff\npartition coefficient: %f   partition entropy %f\nCTHs inside cutoff value:  %d   Iterations: %d\nCTH\t1st Membership\t2nd Membership\tDiff",partcoef,partentr,length(vdx),fuzziter);
               ui_msg(msg);
               msg='';
               for fuzz = vdx
                  fuzznum=strsplit(namesnof{fuzz},'_')(end);
                  msg1 = sprintf("%s\t%f\t\t%f\t\t%f\n",fuzznum{1},val(fuzz),val2(fuzz),cdiffs(fuzz));
                  msg = cstrcat(msg,msg1);
               end
               ui_msg(msg);
               hfig = figure('position',[x3,y3,w3,h3]);
               set(hfig,'numbertitle','off');
               [x3,y3,w3,h3] = tilemon1d2();
               set(gca,'color',bkgnd);
               box('off');
               fuzzyh=[fuzzyh;hfig];
               hold on;
               msg = sprintf('%d FUZZY C-MEANS Cluster Membership Diffs   Run: %d  %d',columns(ptsnof),num_runs,getpid());
               set(gcf,'name',msg);
               [counts,centers] = hist(cdiffs,20);
               bar(centers,counts,'hist');
               centers = str2num(sprintf("%2.2f\n",centers));
               set(gca,'fontsize',12,'xticklabelmode','manual','xtick',centers,'xticklabel',centers);
               xlabel("1st cluster membership value - 2nd cluster membership value\nSmall differences mean a CTH is near the edge of two clusters\nLarge differences mean a CTH is far away from other clusters.");
               ylabel('Frequency');
            end
              % now show cths
            softcol = 0;
            currclusnum=1;
            for clnum=clust_list
               cnum=sprintf('Fuzzy C-Means Cluster# %d  Run: %d  %d',currclusnum,num_runs,getpid());
               softcurr_color = shift(colors,-softcol)(1,:);
               curr_idx = find(f_idx==clnum);
               proj = proj_nof(curr_idx,:);
               if length(curr_idx) == 1
                  clust_mean = ptsnof(curr_idx,:); % only one point in cluster
               else
                  clust_mean = centroid(ptsnof(curr_idx,:));
               end
               bars={namesnof{curr_idx}};
               pts=ptsnof(curr_idx,:);
               if isempty(bars)   % sometimes have an empty cluster
                  msg = sprintf('Cluster # %d is empty. . .',currclusnum);
               end
               tmph = showbars(cnum,bars,pts,softcurr_color,x4,y4,w4,h4,bkgnd,globalmax,clust_mean,autoscale,archetype,0);
               [x4,y4,w4,h4] = tilemon2d2();
               softcol = softcol+1;
               currclusnum = currclusnum + 1;
            end
         end

          % perhaps switch back to other desktop
         if do_kmeans == 1 || do_fuzzy == 1
            drawnow;
            pause(1);
            cmd=sprintf('wmctrl -s %d',primary);
            system(cmd);
         end

         % histogram of distances, see if it sort of looks like the
         % expected chi-square form
         if do_flatplots && numflats > 1
            figure('position',[x1,y1,w1,h1]);
            [x1,y1,w1,h1]=tilemon1d1();
            hold on
            distri=sprintf('Flat Distances for Run: %d  File: %s  %d',num_runs,fname,getpid());
            set(gcf,'name',distri);
            hist(zd(zdi(1:rows(zdi)-1)),rows(zdi)/sqrt(rows(zdi)),'facecolor','b','edgecolor', 'b');
            msg=sprintf("Distribution of flat distances\nCutoff distance is %f",dist);
            title(msg);
         end

          % pairwise plots 
          % use zeroflat, and centers of 2 clusters as basis points
          % project the 2 clusters into this 2 space
          %   OR
          % if using PCA, use zeroflat and the clusters to find PCA basis
         if do_pairwise == 1
            ui_msg('Creating pair-wise plots');
            origin=zeros(1,numbins);
            numplots= nchoosek(numclusts(num_runs),2);
            subs=ceil(sqrt(numplots));
            tmph=figure('position',[x1,y1,w1,h1]);
            [x1,y1,w1,h1]=tilemon1d1();
            if basispts == BASIS_PCA
               msg = sprintf('Pair-wise plots of CTHs and Flats (PCA)  Run: %d  %d',num_runs,getpid());
            else
               msg = sprintf('Pair-wise plots of CTHs and Flats   Run: %d  %d',num_runs,getpid());
            end
            set(gcf,'name',msg);
            hold on;
            currplot=1;

            for clust1=1:numclusts(num_runs)-1
               for clust2=clust1+1:numclusts(num_runs)
                  c1idx = dend(find(dend(:,2)==clust_list(clust1)))';
                  c2idx = dend(find(dend(:,2)==clust_list(clust2)))';
                  v38_subplot(subs,subs,currplot,'align');
                  hold on;
                  msg = sprintf('Clust # %d  Cust # %d',clust1,clust2);
                  title(msg);
                  currplot = currplot + 1;

                  if basispts ~= BASIS_PCA
                     cent1=cluster_centers(clust1,:);
                     cent2=cluster_centers(clust2,:);
                     [ce1,ce2,status]=basis2d(ZeroFlat.NSpaceCoords,cent1,cent2);
                     if status == 0
                        ui_msg(sprintf('No basis is possible for clusters %d and %d, their centers are collinear, skipping. . .',clust1,clust2));
                        continue;
                     end
                     proj = project2(ce1,ce2,ZeroFlat.NSpaceCoords);
                     plot(proj(1),proj(2),'+','color','k','markersize', 12,'linewidth',3);
                     proj = project2(ce1,ce2,flatpts);
                     plot(proj(:,1),proj(:,2),'o','markersize',4,'markerfacecolor',shift(colors,-colidx)(1,:),'markeredgecolor',shift(colors,-colidx)(1,:));
                     c1color=clust1-1;
                     proj = project2(ce1,ce2,cent1);
                     plot(proj(1),proj(2),'+','color','k','markersize', 12,'linewidth',3);
                     proj = project2(ce1,ce2,ptsnof(c1idx,:));
                     plot(proj(:,1),proj(:,2),'o','markersize',4,'markerfacecolor',shift(colors,-c1color)(1,:),'markeredgecolor',shift(colors,-c1color)(1,:));
                     c2color=clust2-1;
                     proj = project2(ce1,ce2,cent2);
                     plot(proj(1),proj(2),'+','color','k','markersize', 12,'linewidth',3);
                     proj = project2(ce1,ce2,ptsnof(c2idx,:));
                     plot(proj(:,1),proj(:,2),'o','markersize',4,'markerfacecolor',shift(colors,-c2color)(1,:),'markeredgecolor',shift(colors,-c2color)(1,:));
                  else
                    pairs = [ptsnof(c1idx,:);ptsnof(c2idx,:);flatpts;ZeroFlat.NSpaceCoords];
                    coeff = princomp(pairs);
                    pe1 = coeff(:,1)';
                    pe2 =coeff(:,2)';
                    mean_pairs = mean(pairs);
                    pair_covar = mean_pairs' * mean_pairs/size(mean_pairs,1);
                    [U,S,V] = svd(pair_covar);
                    cap_var = diag(S)/sum(diag(S));
                    ui_msg(sprintf('Two axes capture %f percent of the variance',100.0*sum(cap_var(1:2))));

                     proj = project2(pe1,pe2,ZeroFlat.NSpaceCoords-mean_pairs);
                     plot(proj(1),proj(2),'+','color','k','markersize', 12,'linewidth',3);
                     pair_pts = flatpts - repmat(mean_pairs, size(flatpts,1), 1);
                     proj = project2(pe1,pe2,pair_pts);
                     plot(proj(:,1),proj(:,2),'o','markersize',4,'markerfacecolor',shift(colors,-colidx)(1,:),'markeredgecolor',shift(colors,-colidx)(1,:));
                     c1color=clust1-1;

                     pair_pts = ptsnof(c1idx,:) - repmat(mean_pairs, size(c1idx,1), 1);
                     proj = project2(pe1,pe2,pair_pts);
                     plot(proj(:,1),proj(:,2),'o','markersize',4,'markerfacecolor',shift(colors,-c1color)(1,:),'markeredgecolor',shift(colors,-c1color)(1,:));
                     c2color=clust2-1;

                     pair_pts = ptsnof(c2idx,:) - repmat(mean_pairs, size(c2idx,1), 1);
                     proj = project2(pe1,pe2,ptsnof(c2idx,:));
                     plot(proj(:,1),proj(:,2),'o','markersize',4,'markerfacecolor',shift(colors,-c2color)(1,:),'markeredgecolor',shift(colors,-c2color)(1,:));
                  end
               end
            end
         end

      % WHEW!  WORK DONE.  USER HAS CHOICES TO MAKE
         if termUI == 0   % using GUI
            drawnow();
            ui_msg("\nThis pass complete\n");
            p = struct();
            system(bring_to_fg_cmd);
            cmd='';

            curr_bar_pos=scroll_start-scroll_step;  % back up so we can step forward
            cmd='FORWARD';   % fake out to redraw plots starting at cth1

            while ~strcmp(cmd,'QUIT') && ~strcmp(cmd,'CONTROLS') % 2 ways out
               if strcmp(graphics_toolkit(),'fltk')
                  refresh();   %this seems to keep the plots interactive
               end
               pause(0.03);    % sleep 30 ms so not too busy waiting
               if isempty(cmd)
                  [p,cmd] = chk_for_gui_cmd(0);
               end
               if isempty(cmd)
                  continue;
               end

               if strcmp(cmd,'QUIT')
                  done = 1;
               elseif strcmp(cmd,'START_OVER')
                  ui_msg('Closing figures and resetting variables');
                  close all hidden;
                  reset = 1;
                  break;
               elseif strcmp(cmd,'CONTROLS')
                  if numfields(p) > 0
                     guiparams = p;
                  else
                     cmd='';  % odd, no params, stay here
                  end
               elseif strcmp(cmd,'STEREO_CLUSTERS')
                  cmd='';
                  if isempty(p{1}) || min(p{1}) < 0 || max(p{1}) > numclusts(num_runs)
                     ui_msg('ERROR WARNMissing or invalid cluster numbers');
                  else
                     show_stereo(stereoh(end), stereo_clusts(clust_list), p{1});
                  end
               elseif strcmp(cmd,'SAVE_CLUSTERS')
                  cmd='';
                  if isempty(namesnof)
                     ui_msg('ERROR WARNThere are no clusters to save');
                     continue;
                  end
                  testnums=[p.d p.k p.kc p.f];

                  if ~archetype
                     if isempty(testnums) || min(testnums) < 1 || max(testnums) > numclusts(num_runs)
                        ui_msg('ERROR WARNCTH cluster number(s) not valid');
                        continue;
                     end
                  else
                     if isempty(testnums) || min(testnums) < 1 || length(find(clust_list == testnums')) != length(p.d)
                        ui_msg('ERROR WARNCTH cluster number(s) not valid');
                        continue;
                     end
                  end

                  if isempty(p.fname)
                     ui_msg('ERROR WARNNo file name');
                  else
                     outname=p.fname;
                  end

                  if ~isempty(p.d)
                     ui_msg('Saving clusters...');
                     res = save_clust(namesnof,distzf,p.d,ZeroFlatName,dend,[],[],fname,outname);
                     if res < 0
                        ui_msg('ERROR WARNFile has not been saved');
                     else
                        ui_msg(sprintf('File %s saved',outname));
                     end
                  end
                  if do_kmeans && ~isempty(p.k)
                     k_outname=cstrcat(outname,'_kmeans');
                     res = save_clust(namesnof,distzf,p.k,ZeroFlatName,[],kmeans_clusts,[],fname,k_outname);
                  end
                  if do_kmeans && ~isempty(p.kc)
                     k_outname=cstrcat(outname,'_kmeans_centr');
                     res = save_clust(namesnof,distzf,p.kc,ZeroFlatName,[],kmeans_clusts_c,[],fname,k_outname);
                  end
                  if do_fuzzy && ~isempty(p.f)
                     f_outname = cstrcat(outname,'_fuzzy');
                     res = save_clust(namesnof,distzf,p.f,ZeroFlatName,[],[],f_idx',fname,f_outname);
                  end
               elseif strcmp(cmd,'FORWARD') || strcmp(cmd,'BACKWARD')
                  curr_bar_pos = scroll_plots(cmd,curr_bar_pos,scroll_step,num_to_show,tot_bars,barh,bar_ids,scrn_pos2);
                  system(bring_to_fg_cmd);   % focus back to gui win
                  cmd='';
               elseif strcmp(cmd,'CTHINFO')
                  cmd='';
                  cths=[];
                  for cthfacts=1:numel(p{1})
                     currcth=p{1}(cthfacts);
                     if isscalar(currcth)
                        cths=[cths,currcth];
                     end
                  end
                  lookup=find(cths==-1);  % we use a * in the gui to ask for ctl/stim
                  if ~isempty(lookup)     % pairs. This lets us stagger the two windows
                     have_star = true;    % that we use for the info instead of showing
                  else                    % all of one type, then all of another.
                     have_star = false;
                  end
                  for onecth=cths
                     if onecth == -1      % last in list, time to leave
                        break;
                     end
                     if have_star
                        onecth=[onecth -1];
                     end
                     tmp = cthinfo(onecth,CthVars,names,namesnof,flatnames,dend,scatth(end),proj_nof,colors,archetype,clust_list);
                     cthinfoh=[cthinfoh tmp];
                     if archetype
                        [clust_class tmph] = cth_classify(a_centers,onecth,CthVars,dend,names,namesnof,flatnames,pd_algo,pdistalgo,link_algo,colors,arch_names,arch_nums,sorted_arch_names,true);
                        cthinfoh = [cthinfoh tmph];
                     else
                        [clust_class tmph]= cth_classify(cluster_centers,onecth,CthVars,dend,names,namesnof,flatnames,pd_algo,pdistalgo,link_algo,colors,[],{},true);
                        cthinfoh = [cthinfoh tmph];
                     end
                  end
                  system(bring_to_fg_cmd);   % focus back to gui win
               elseif strcmp(cmd,'EXPORT_ATLAS')
                  cmd='';
                  if isempty(p{1})
                     ui_msg('ERROR WARNNo file name');
                  else
                     outname=p{1};
                     ui_msg('Exporting cluster information to .csv and .db.csv files...');
                     export_db(CthVars,SparseVars,names,namesnof,flatnames,dend,outname,archetype);
                     export_clust(CthVars,names,namesnof,flatnames,coordsnofpts,dend,[],[],outname,colors,pd_algo,link_algo,archetype);
                     if do_kmeans
                        k_outname = strcat(outname,'_kmeans');
                        export_clust(CthVars,names,namesnof,flatnames,coordsnofpts,[],kmeans_clusts,[],k_outname,colors,pd_algo,'kmeans');
                        k_outname = strcat(outname,'_kmeans_centr');
                        export_clust(CthVars,names,namesnof,flatnames,coordsnofpts,[],kmeans_clusts_c,[],k_outname,colors,pd_algo,'kmeans');
                     end
                     if do_fuzzy
                        f_outname = strcat(outname,'_fuzzy');
                        export_clust(CthVars,names,namesnof,flatnames,coordsnofpts,[],[],f_idx,f_outname,colors,pd_algo,'fuzzy cmeans');
                     end
                  end
               elseif strcmp(cmd,'EXPORT_ARCHETYPES')
                  cmd='';
                  if isempty(p{1})
                     ui_msg('ERROR WARNNo file name');
                  else
                     outname=p{1};
                     d_outname=strcat(outname,"_dend");
                     ui_msg('Exporting archetype information to .type files...');
                     norm=getnorm(names{1});
                     save_archetypes(cluster_centers,d_outname,norm,pd_algo,link_algo);
                     if do_kmeans
                        k_outname = strcat(outname,'_km');
                        save_archetypes(km_centers ,k_outname,norm,'K_MEANS');
                        k_outname = strcat(outname,'_km_cent');
                        save_archetypes(kmcent_centers ,k_outname,norm,'K_MEANS_WITH_PREDEFINED_CENTERS');
                     end
                     if do_fuzzy
                        f_outname = strcat(outname,'_fcm');
                        save_archetypes(fcm_cent,f_outname,'FUZZY_C_MEANS');
                     end
                  end
               elseif strcmp(cmd,'EXPORT_PAIRS')
                  cmd='';
                  if isempty(p{1})
                     ui_msg('ERROR WARNNo file name');
                  else
                     outname=p{1};
                     if archetype
                       d_outname=cstrcat(outname,'_arch');
                     else
                       d_outname=cstrcat(outname,'_dend');
                     end
                     ctlstim_clust(CthVars,names,namesnof,flatnames,dend,pd_algo,link_algo,colors,meandist,ZeroFlatName,fname,d_outname,archetype);
                  end
               elseif strcmp(cmd,'CLOSE_INFO')
                  cmd='';
                  if ~isempty(cthinfoh)
                     close(cthinfoh);
                     cthinfoh=[];
                     cascademon1(1);
                  end
               else
                  cmd='';  % don't know command, ignore it
               end
            end
         else    % NON-GUI TERMINAL MODE
            stayhere = 1;

            figure(dendoh(end));
            sav_dendo=axis();
            curr_dendo=sav_dendo;
            sfact=sav_dendo(4)/10;

            do
               system(bring_to_fg_cmd);
               choice = loc_menu('Now what?',1,'Different choices for same file*','Start over','Break', 'Save cluster subset', 'Show Detail For CTH','Dendrogram scale down','Restore Dendrogram','Quit');

               if choice == 1
                  stay_on_file = 1;
                  stayhere=0;
               elseif choice == 2
                  stay_on_file = 0;
                  stayhere=0;
               elseif choice == 3
                  keyboard();  % need this here, it's not a breakpoint, leave it
               elseif choice == 4
                  cth_num = input('Enter CTH number(s) or q to quit: ', 's');
                  if cth_num == 'q'
                     continue;
                  end
                  [cth_num,state]=str2num(cth_num);
                  if isempty(cth_num) || min(cth_num) < 1 || max(cth_num) > numclusts;(num_runs)
                     ui_msg('ERROR WARNpoint number(s) not valid');
                     continue;
                  end
                  outname = input('Enter base file name to save: ', 's');
                  outname=strcat('cth_',outname,'.cth');
                  save_clust(namesnof,distzf,cth_num,ZeroFlatName,dend,fname,outname);
                  continue;
               elseif choice == 5
                  detail = input('Enter CTH number(s) or q to quit: ', 's');
                  if detail == 'q'
                     continue;
                  end
                  [multi,state]=str2num(detail);
                  if isempty(multi) || min(multi) < 1 || max(multi) > numpts
                     ui_msg('ERROR WARNpoint number(s) not valid');
                     continue;
                  end
                  tmp = cthinfo(multi,CthVars,names,namesnof,flatnames,dend,scatth(end),proj_nof,colors,archetype,clust_list);
                  cthinfoh=[cthinfoh tmp];
                  continue;
               elseif choice == 6
                  figure(dendoh(end));
                  curr_dendo(4) = curr_dendo(4) - sfact;
                  axis(curr_dendo);
               elseif choice == 7
                  figure(dendoh(end));
                  axis(sav_dendo);
                  curr_dendo=sav_dendo;
               else
                  stayhere=0;
                  stay_on_file = 0;
                  done = 1;
               end
            until stayhere == 0
         end
         if reset == 1
            reset = 0;
            break;
         end
         num_runs=num_runs+1;
      end
      % end of main loop
   end

   ui_msg('exiting. . .');
   fflush(1);
   close all;

   if termUI == 0
      disconnect(client);
      do
         [pid,status]=waitpid(-1);  % reap children
      until pid < 0;
   end
end


% NOTES

% To print
% figure(figurehandle)
% print('-dpdf','-S2000,2000','outname.pdf')
%  -S controls the resolution, you'll have to play with this

%% For potential figure and point selection and manipulation
%% get(gca,'position') returns [ x0 y0 w h] normalized 0 to 1 for both axes
%% get(gca,'outerposition') returns [ x0 y0 w h], includes axes, ticks, labels
%% in our busy figures, this could overlap with other windows.  the position
% prop seems to be inside where things are drawn.
%% get(gca,'parent') returns figure window handle (1,2,3,4...)
%% get(gca,'currentpoint') returns [ x0 y0 x1 y1] in points or something where
%% the last click was.
%% set(gca,'units','pixels') sets everything to pixels.  of course, if you
%% resize the window, things change.  Normalized seems to be independent of 
%% the window resizing


