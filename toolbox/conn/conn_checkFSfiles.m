function [ok,FS_folder,files]=conn_checkFSfiles(filename,verbose)
% conn_checkFSfiles checks existence of FreeSurfer result files
% 

if isstruct(filename), filename=filename(1).fname; end
FS_folder=spm_fileparts(filename);
if isempty(FS_folder), FS_folder=pwd; end
[temp1,temp2]=spm_fileparts(FS_folder);
if strcmp(temp2,'mri')||strcmp(temp2,'anat'), FS_folder=temp1; end
files1=cellfun(@(x)fullfile(FS_folder,'surf',x),{'lh.white','lh.pial','lh.sphere.reg','rh.white','rh.pial','rh.sphere.reg'},'uni',0); 
files2=cellfun(@(x)fullfile(FS_folder,'mri',x),{'T1.nii','T1.mgh','T1.mgz','brain.nii','brain.mgh','brain.mgz'},'uni',0); 
existfiles1=conn_existfile([{filename},files1]);
existfiles2=conn_existfile([files2]);
i2=find(existfiles2,1);
existfiles=[existfiles1 ~isempty(i2)];
files=[files1 files2(max([1 i2]))];
ok=all(existfiles);
if nargin>1
    tfiles=[{filename},files];
    str={'not ',''};
    for n=1:numel(tfiles)
        fprintf('File %s %sfound\n',tfiles{n},str{existfiles(n)+1});
    end
    end
end
