% Function to take a list of type files and concatenate them.
% This means renaming them so the sequence number increases from first CTH to last
% It also means not copying the zero flat from any file but the last.
% The type files don't include a distance matrix, that will be created when it
% is loaded because our custom distance matrix cannot be used because we don't
% have the stats it requires.
% This assumes the distance and linkage algorithms are the same for all files.
% it is kind of hard to support different ones of these. 
% arch_set is 0 for control period archetypes.
% arch_set is 1 for swallow1 period archetypes.
% arch_set is 2 for lareflex period archetypes.

function [res] = concat_types(namelist,outfname,arch_set)
   first = true;
   last = false;
   working_i = true;
   working_lrm = false;
   working_e = false;
   skip_header = false;
   res = true;
   arch_ranges=archnums();
   if arch_set == 0  
      i_seqnum = arch_ranges.std(1);
      lrm_seqnum = arch_ranges.std(2);
      e_seqnum = arch_ranges.std(3);
   elseif arch_set == 1
      i_seqnum = arch_ranges.swallow(1);
      lrm_seqnum = arch_ranges.swallow(2);
      e_seqnum = arch_ranges.swallow(3);
   elseif arch_set == 2
      i_seqnum = arch_ranges.lareflex(1);
      lrm_seqnum = arch_ranges.lareflex(2);
      e_seqnum = arch_ranges.lareflex(3);
   end
   flat_seqnum = arch_ranges.flat(1);

   num_files = length(namelist);
   if num_files < 1
      ui_msg("No files to merge, aborting. . .");
      res = false;
      return;
   elseif num_files < 5 
      ui_msg("There are not enough files, aborting. . .");
      res = false;
      return
   end

   outfname = strcat(outfname,".type");
   [fdout msg] = fopen(outfname,'wt');
   if fdout == -1
      ui_msg(sprintf("Could not open %s because %s. Merged type file not created.",outfname,msg));
      res = false;
      return;
   end

   for file = 1:num_files
      if length(namelist{file}) == 0
         if working_i
            working_i = false;    % move the state machine along
            working_lrm = true;
         elseif working_lrm
            working_lrm = false;
            working_e = true;
         end
         continue;
      end
      [fdin msg] = fopen(namelist{file},'r');
      if fdin == -1
         ui_msg(sprintf("Could not open %s because %s. Merged type file not created.",namelist{file},msg));
         res = false;
         return;
      end
      if file ~= 1             % use header from just first file
         in_header = true;
         while in_header
            line = fgets(fdin);
            match = strfind(line,"% START MARK A_");
            if match > 0
               fseek(fdin,-length(line),SEEK_CUR);
               in_header = false;
            end
         end 
      end
      if file == num_files
         last = true;
      end
         
      infile = true;
      while infile
         line = fgets(fdin);
         if line == -1
            infile = false;
            fclose(fdin);
            continue;
         end

         match = strfind(line,"% START MARK A_");
         if match > 0
            cthname=strsplit(line,'_');
            cthname=sprintf("%s_",cthname{1:end-1});
            if working_i
               line = sprintf("%s%05d\n",cthname,i_seqnum);
            elseif working_lrm
               line = sprintf("%s%05d\n",cthname,lrm_seqnum);
            else
               line = sprintf("%s%05d\n",cthname,e_seqnum);
            end
         end
         match = strfind(line,"% name: A_");
         if match > 0
            cthname=strsplit(line,'_');
            cthname=sprintf("%s_",cthname{1:end-1});
            if working_i
               line = sprintf("%s%05d\n",cthname,i_seqnum);
               i_seqnum = i_seqnum+1;
            elseif working_lrm
               line = sprintf("%s%05d\n",cthname,lrm_seqnum);
               lrm_seqnum = lrm_seqnum+1;
            else
               line = sprintf("%s%05d\n",cthname,e_seqnum);
               e_seqnum = e_seqnum+1;
            end
         end
         if last ~= true
            match = strfind(line,"START MARK ZeroFlat");
            if length(match) > 0
               first = false;
               fseek(fdin,0,'eof');
               continue;
            end
         else
            match = strfind(line,"START MARK ZeroFlat");
            if match > 0
               cthname=strsplit(line,'_');
               cthname=sprintf("%s_",cthname{1:end-1});
               line = sprintf("%s%05d\n",cthname,flat_seqnum);
            end
            match = strfind(line,"% name: ZeroFlat");
            if match > 0
               cthname=strsplit(line,'_');
               cthname=sprintf("%s_",cthname{1:end-1});
               line = sprintf("%s%05d\n",cthname,flat_seqnum);
               flat_seqnum = flat_seqnum + 1;
            end
         end
         fputs(fdout,line);
      end
   end
end

