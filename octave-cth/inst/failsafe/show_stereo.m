% Show the selected clusters in the stereotaxic cluster plot
%
%

function show_stereo(stereoh, stereo_clusts, clusts)

   if isempty(clusts)
      return;
   end

   figure(stereoh);
   if ~isempty(find(clusts == 0))  % special case, turn all on
      set(stereo_clusts,'visible','on');
      return;
   end

   set(stereo_clusts,'visible','off');
   maxclust=numel(stereo_clusts);  % assumes clusters 1-n
   cl_len = numel(clusts);
   for cl=1:cl_len
      if clusts(cl) >= 1 && clusts(cl) <= maxclust
         set(stereo_clusts(clusts(cl)),'visible','on');
      end
   end
   drawnow;
end
