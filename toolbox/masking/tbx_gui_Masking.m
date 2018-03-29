function tbx_gui_Masking
% tbx_gui_Masking - start SPM5 or SPM8 batch GUI with Masking toolbox.
% Called when Masking is selected from the toolbox pull-down menu.
%
% See also: opt_thresh, make_majority_mask

% spm.m puts the first (spm_select 'list'ed) file matching the pattern
% toolbox/masking/*_masking.m (this file) as the call-back for the toolbox
% name in the toolboxes pulldown menu, calling it with no output arguments.
% The following code handles this callback for SPM5 or later.

switch spm('Ver')
    case 'SPM5'
        spm_jobman('interactive', '', 'jobs.tools.masking');
    case {'SPM8b', 'SPM8', 'SPM12a', 'SPM12b', 'SPM12'}
        matlabbatch = masking_batch;
        spm_jobman('interactive', matlabbatch);
    otherwise
        error('Unrecognised version of SPM')
end
