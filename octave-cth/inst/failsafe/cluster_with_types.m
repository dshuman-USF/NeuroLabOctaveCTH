% create a list of all the non-flat cths, cluster them using archetype classes
% and return the cluster list.
% INPUTS:   CthVars - Contents of .cth file
%           namesnof - non-flat names
%           names    - all names
%           pd_algo  - distance algorithm
%           pdistal  - list of all distance algorithms
%           arch     - a struct holding info like so:
%                       arch.std.have
%                       arch.std.nums
%                       arch.std.centers
%                       Makes it easier to add more types later.
% OUTPUTS:    type_clusts - cluster number ordered by ptsnof
%             classify - sort of like what dend function creates
function [type_clusts classify] = cluster_with_types(CthVars,namesnof,names,pd_algo,pdistalgo,arch);
   debug_on_error(0,'local');
   cth_list=[];
   info='';
   type_clusts=[];
   num_cths = length(namesnof);  % only non-flat cths can be clustered
   classify=[];
   arch_offset=0;
   bins=length(CthVars.(namesnof{1}).NSpaceCoords);

   if strcmp(pd_algo,pdistalgo{1}) == 1   % archetypes have no custom distance matrix
      info=sprintf('Note: The %s custom distance metric is\nnot available for archetypes\nDefaulting to euclidean distance.\n',pdistalgo{1});
      real_pd_algo='euclidean';
   else
      real_pd_algo=pd_algo;
   end

   if arch.swall1.have
      sw_ctl_num=name2period("SWALLOW1CTL");
      sw_stim_num=name2period("SWALLOW1STIM");
   end
   if arch.laref.have
      laref_ctl_num=name2period("LAREFLEXCTL");
      laref_stim_num=name2period("LAREFLEXSTIM");
   end

   if arch.std.have
      num_clusts = rows(arch.std.centers);
      last_row=num_clusts+1;
      info = cstrcat(info,sprintf('Using %s distance algorithm\n',real_pd_algo));
      ui_msg(info);
      for cthnum=1:num_cths
         curr_name = namesnof{cthnum};
         cth=CthVars.(curr_name).NSpaceCoords;
         if arch.swall1.have
            name_fields =strsplit(curr_name,"_");
            if strcmp(name_fields{end-1},sw_stim_num) == 1   % skip swallow stim cths
               continue;
            end
         end
         if arch.laref.have
            name_fields =strsplit(curr_name,"_");
            if strcmp(name_fields{end-1},laref_stim_num) == 1   % skip lareflex cths
               continue;
            end
         end
            % The idea here is to create a set of the archetypes and each cth, then
            % calculate a distance matrix, then find what archetype the cth is nearest.
            % We then add to a matrix that looks, more or less, what the loc_dendrogram
            % function returns.
         cth_set = [arch.std.centers;cth];
         dist_matrix = loc_pdist(cth_set,real_pd_algo); 
         dm=squareform(dist_matrix);
         cthdist=dm(last_row,:);
         cthdist(last_row)=Inf;   % distance to ourself, always 0
         nearest=find(cthdist==min(cthdist));
         nearest_dist=cthdist(nearest);
         nearest_type = arch.std.nums(nearest);
         type_clusts=[type_clusts;nearest];
         classify =[classify;[cthnum nearest_type nearest_dist]];
      end
   end

   if arch.swall1.have 
      clear cth_set;
      clear cthdist;
      clear nearest;
      arch_offset = length(arch.std.nums);  % skip possible ctl archetypes
      num_clusts = rows(arch.swall1.centers);
      last_row=num_clusts+1;
      for cthnum=1:num_cths
         curr_name = namesnof{cthnum};
         cth=CthVars.(curr_name).NSpaceCoords;
         name_fields =strsplit(curr_name,"_");
         if strcmp(name_fields{end-1},sw_ctl_num) == 1   % skip swallow ctl 
            continue;
         end
         cth_set = [arch.swall1.centers;cth];
         dist_matrix = loc_pdist(cth_set,real_pd_algo); 
         dm=squareform(dist_matrix);
         cthdist=dm(last_row,:);
         cthdist(last_row)=Inf;
         nearest=find(cthdist==min(cthdist));
         nearest_dist=cthdist(nearest);
         nearest_type = arch.swall1.nums(nearest);
         nearest = nearest+arch_offset;
         type_clusts=[type_clusts;nearest];
         classify =[classify;[cthnum nearest_type nearest_dist]];
      end
   end

   if arch.laref.have
      clear cth_set;
      clear cthdist;
      clear nearest;
      arch_offset = length(arch.std.nums) + length(arch.swall1.nums);
      num_clusts = rows(arch.laref.centers);
      last_row=num_clusts+1;
      for cthnum=1:num_cths
         curr_name = namesnof{cthnum};
         cth=CthVars.(curr_name).NSpaceCoords;
         name_fields =strsplit(curr_name,"_");
         if strcmp(name_fields{end-1},laref_ctl_num) == 1   % skip lareflex ctl cths
            continue;
         end
         cth_set = [arch.laref.centers;cth];
         dist_matrix = loc_pdist(cth_set,real_pd_algo); 
         dm=squareform(dist_matrix);
         cthdist=dm(last_row,:);
         cthdist(last_row)=Inf;
         nearest=find(cthdist==min(cthdist));
         nearest_dist=cthdist(nearest);
         nearest_type = arch.laref.nums(nearest);
         nearest = nearest+arch_offset;
         type_clusts=[type_clusts;nearest];
         classify =[classify;[cthnum nearest_type nearest_dist]];
      end
   end
   classify = sortrows(classify,2);  % sort in archetype order
end
