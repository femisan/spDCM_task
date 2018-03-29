function matlabbatch = masking_batch
%masking_batch: return a matlabbatch structure for the masking toolbox

makeavg.innames = '<UNDEFINED>';
makeavg.avgexpr = 'mean(X)';
makeavg.outname = 'average.nii';
makeavg.outdir = '';

optthr.inname(1) = cfg_dep;
optthr.inname(1).tname = 'Input Image';
optthr.inname(1).tgt_spec{1}(1).name = 'filter';
optthr.inname(1).tgt_spec{1}(1).value = 'image';
optthr.inname(1).tgt_spec{1}(2).name = 'strtype';
optthr.inname(1).tgt_spec{1}(2).value = 'e';
optthr.inname(1).sname = 'Make Average: Average Image';
optthr.inname(1).src_exbranch = substruct('.','val', '{}',{1}, ...
    '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
optthr.inname(1).src_output = substruct('.','files');
optthr.optfunc = '@opt_thr_corr';
optthr.outname = 'average_optthr.nii';
optthr.outdir = '';

checkreg.data(1) = cfg_dep;
checkreg.data(1).tname = 'Images to Display';
checkreg.data(1).tgt_spec{1}(1).name = 'filter';
checkreg.data(1).tgt_spec{1}(1).value = 'image';
checkreg.data(1).tgt_spec{1}(2).name = 'strtype';
checkreg.data(1).tgt_spec{1}(2).value = 'e';
checkreg.data(1).sname = 'Make Average: Average Image';
checkreg.data(1).src_exbranch = substruct('.','val', '{}',{1}, ...
    '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
checkreg.data(1).src_output = substruct('.','files');
checkreg.data(2) = cfg_dep;
checkreg.data(2).tname = 'Images to Display';
checkreg.data(2).tgt_spec{1}(1).name = 'filter';
checkreg.data(2).tgt_spec{1}(1).value = 'image';
checkreg.data(2).tgt_spec{1}(2).name = 'strtype';
checkreg.data(2).tgt_spec{1}(2).value = 'e';
checkreg.data(2).sname = 'Optimal Thresholding: Mask Image';
checkreg.data(2).src_exbranch = substruct('.','val', '{}',{2}, ...
    '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
checkreg.data(2).src_output = substruct('.','outname');

matlabbatch{1}.spm.tools.masking{1}.makeavg = makeavg;
matlabbatch{2}.spm.tools.masking{1}.optthr = optthr;
matlabbatch{3}.spm.util.checkreg = checkreg;
