%    Copyright (C) 2014-2020 K. F. Morris

%    This file is part of the USF CTH Clustering software suite.
%    This software is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.

%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.

%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <https://www.gnu.org/licenses/>.
%
%
# program to edit names in a .cth file.
# intended to be used to give names to archetype CTHs.
# This might have been a good idea for a few CTHs, but more
# than 20 types creates a window too big. It also does not help
# splice files together from iterative CTHs. So, retired, just
# edit the .cth files by hand, because you are going to have to
# do that anyway.
# Tue Jan 31 08:31:20 EST 2017

function name_cth()
   debug_on_error(1,'local');
   quit = false;
   cthVars = struct;
   currNames = cell;
   newNames = cell;
   justNames = cell;
   fName = '';
   saved = true;

  if (~__octave_link_enabled__ ())
      disp("This programn needs to be running in a GUI environment, exiting. . .");
      return;
   end
   currline=1;
   do
      [choice,ok] = listdlg('name','Rename Archetype CTHs','liststring',{'Load','Name CTHs','Write','Quit'},'selectionmode','single','initialvalue',[currline],'cancelstring','Exit','listsize',[200 100]);
      if ~ok
         choice = 4;
      end
      if choice == 1
         cthVars = struct;
         [cthVars,currNames,fName,justNames] = loadCTH();
         if numfields(cthVars)
            saved = false;
            currline=2;
         end
      elseif choice == 2
         [newNames,justNames]=renameCTH(cthVars,currNames,justNames);
         currline=3;
      elseif choice == 3
         writeCTH(currNames,newNames,fName)
            saved = true;
            currline=4;
      elseif choice == 4
         if saved == false
            leave = questdlg("Changes not saved, continue with quit?","NOT SAVED","Yes","No","No");
            if strcmpi(leave,'Yes')
               quit = true;
            end
         else
            quit = true;
         end
      end
   until quit == true;
end


# load a cth .type file and return the A_ names
# if this is a file we have previously created, extract the 
# names
function [cthVars,currNames,fullname,justNames] = loadCTH()
   cthVars=struct;
   currNames = cell;
   justNames = cell;
   t_name=0;
   t_path=0;
   t_fltidx =0;
   [t_name,t_path,t_fltidx] = uigetfile("*.type");
   if ~isscalar(t_name)
      fullname = cstrcat(t_path,t_name);
      cthVars=load(fullname);
      n = 1;
      for [val,key] = cthVars             # extract names
         if regexp(key,"^A_")
            currNames{n} = key;
            fields=strsplit(key,'_');
            tname=fields(1:end-5);
            namelen=length(tname);
            if namelen > 1
               justNames{n}=tname{2};
               for t = 3:namelen
                  justNames{n} = cstrcat(justNames{n},cstrcat('_',tname{t}));
               end
            else
               justNames{n}='';
            end
            n = n + 1;
         end
      end
      if length(currNames) == 0
         warndlg("There were no archetype names in the file.","NO ARCHETYPE NAMES");
      end
   end
end


# Show existing names, let user type in new onws
function [nameList,new_names]=renameCTH(cthVars,currNames,newNames)
   nameList=cell;
   if numfields(cthVars) == 0
      warndlg("Names have not been loaded.","NO NAMES");
      return;
   end 
   n = 1;
   if length(newNames)
      new_names = inputdlg(currNames,"CHANGE NAMES, BLANK FOR SAME",1,newNames);
   else
      new_names = inputdlg(currNames,"CHANGE NAMES, BLANK FOR SAME",1);
   end

   if ~isempty(new_names)
      new_names = strrep(new_names,' ','');  # NO spaces
      for name = 1:length(new_names)
         if length(new_names{name})
              % remove up previously entered name if there is one.
            fields=strsplit(currNames{name},'_');
            tname=fields(1:end-5);
            namelen=length(tname);
            if namelen > 1
               for t = 2:namelen
                  fields{t}='';
               end
               fields=fields(~cellfun(@isempty,fields));
               currNames{name} = sprintf("%s_",fields{1:end-1});
               currNames{name} = cstrcat(currNames{name},fields{end});
            end
            nameList{name} = strrep(currNames{name},'A_',cstrcat('A_',new_names{name},'_'));
         else
            nameList{name} = currNames{name};
         end
      end
   end
end

function [ok]=writeCTH(currNames,newNames,fName)
   cth_as_text=fileread(fName);
   for name = 1:length(newNames)
      cth_as_text = strrep(cth_as_text,currNames{name},newNames{name});
   end
   [name,dir] = uiputfile(fName,'Save to file',fName);
   if ~isscalar(name)
      newFile=cstrcat(dir,'/',name);
      fid=fopen(newFile,'w');
      fputs(fid,cth_as_text);
      fclose(fid);
      ok = true;
   else
      ok = false;
   end
end
