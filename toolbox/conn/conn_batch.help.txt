
  CONN BATCH batch functionality for connectivity toolbox
  
  Defines experiment information and/or run processing steps programmatically
  
  CONN_BATCH syntax:
  
  1) conn_batch(BATCH);
     where BATCH is a structure (with fields defined in the section below)
     e.g. 
        clear BATCH;
        BATCH.Setup.RT=2;
        conn_batch(BATCH);
  
  2) conn_batch('fieldname1',fieldvalue1,'fieldname2',fieldvalue2,...) 
     where 'fieldname*' are individual BATCH structure fields
     e.g. 
        conn_batch('Setup.RT',2); 
  
  3) conn_batch(batchfilename)
     where batchfilename is a .mat file containing a batch structure
     or a .m file containing a Matlab script
     e.g.
        conn_batch('mybatchfile.mat');
 
  note1: in standalone releases use syntax (from system-prompt):
      conn batch batchfilename    : runs a batch file (.m or .mat)
      conn batch "matlabcommands" : runs one or several matlab commands 
  note2: syntax conn_batch({BATCH1 BATCH2 ...}) processes sequentially multiple batch structures (equivalent to 
        conn_batch(BATCH1); conn_batch(BATCH2); ... e.g. useful when defining/running multiple first- or 
        second- level analyses)
 
 __________________________________________________________________________________________________________________
  
  BATCH structure fields:
  
   filename          : conn_*.mat project file (defaults to currently open project)
   subjects          : Subset of subjects to run processing steps or define parameters for (defaults to all subjects)
   parallel          : Parallelization options (defaults to local procesing / no parallelization)
   Setup             : Information/processes regarding experiment Setup and Preprocessing
   Denoising         : Information/processes regarding Denoising step
   Analysis          : Information/processes regarding first-level analyses
   Results           : Information/processes regarding second-level analyses/results
  
  
  BATCH.parallel DEFINES PARALLELIZATION OPTIONS (applies to any Setup/Setup.preprocessing/Denoising/Analysis steps) %!
   parallel            
  
     N               : Number of parallel jobs; 0 to run locally ([0])
     profile                    : (optional) Name of parallelization profile 
                                    if undefined CONN uses the default parallelization profile defined in GUI.Tools.GridSettings
                                    see "conn_jobmanager profiles" for a list of all available profiles
                                    see GUI Tools.GridSettings for additional information and to add/edit profiles
                                    use the profile name 'Null profile' to queue this job (queued/scripted jobs are prepared but
                                     not submitted; see GUI.Tools.SeePendingJobs to submit next queued job)
     cmd_submitoptions          : (optional) alternative value for parallelization profile 'in-line' additional submit-settings 
                                    defaults to the chosen parallelization profile value for this field
     cmd_submitoptions_infile   : (optional) alternative value for parallelization profile 'in-file' additional submit-settings
                                    defaults to the chosen parallelization profile value for this field
     cmd_rundeployed            : (optional) aternative value for profile 'nodes use pre-compiled CONN only' setting
                                    defaults to the chosen parallelization profile value for this field
     cmd_checkstatus_automatic  : (optional) aternative value for profile 'check jobs status automatically' setting
                                    defaults to the chosen parallelization profile value for this field
     immediatereturn            : (optional) 1/0 : 1 returns control to Matlab without waiting for parallel job to finish ([0])
  
  BATCH.Setup DEFINES EXPERIMENT SETUP AND PERFORMS INITIAL DATA EXTRACTION AND/OR PREPROCESSING STEPS %!
   Setup               
  
     isnew           : 1/0 is this a new conn project [0]
     done            : 1/0: 0 defines fields only; 1 runs SETUP processing steps [0]
     overwrite       : (for done=1) 1/0 overwrites target files if they exist [1]
  
     nsubjects       : Number of subjects
     RT              : Repetition time (seconds) [2]
     acquisitiontype : 1/0: Continuous acquisition of functional volumes [1] 
  
     functionals     : functionals{nsub}{nses} char array of functional volume files (dataset-0; for voxel-level analyses; 
                        see roifunctionals below) 
     structurals     : structurals{nsub} char array of structural volume files 
                       OR structurals{nsub}{nses} char array of anatomical session-specific volume files 
     roifunctionals  : (for Setup.rois.roiextract>0) structure array identifying one or several additional functional 
                        datasets for ROI-level timeseries extraction (dataset-1 and above); default 
                        roifunctionals=struct('roiextract',2)
        roiextract            : Source of functional data: 1: same as 'Setup.functionals' field; 2: same as 
                                'Setup.functionals' field after removing leading 's' from filename; 3: other (same as 
                                'Setup.functionals' field but using alternative filename-change rule; see roiextract_rule 
                                below and help conn_rulebasedfilename); 4: other (explicitly specify the functional volume 
                                files; see roiextract_functionals below) [2] 
        roiextract_rule       : (for roiextract==3 only) regexprep(filename,roiextract_rule{2},roiextract_rule{3}) converts 
                                filenames in 'Setup.functionals' field to filenames that will be used when extracting BOLD 
                                signal ROI timeseries (if roiextract_rule{1}==2 filename is interpreted as a full path; if 
                                roiextract_rule{1}==1 filename is interpreted as only the file *name* -no file path, no 
                                file extension-)    
        roiextract_functionals: (for roiextract==4 only) roiextract_functionals{nsub}{nses} char array of functional 
                                volume files
     add             : 1/0; use 0 (default) to define the full set of subjects in your experiment; use 1 to define an 
                        additional set of subjects (to be added to any already-existing subjects in your project) [0]
                       When using Setup.add=1, the following fields are expected to contain the information for the new
                        /added subjects *only*: Setup.functionals, Setup.structurals, Setup.roiextract_functionals, 
                        Setup.unwarp_functionals, Setup.coregsource_functionals, Setup.spmfiles, Setup.masks.Grey/White/CSF, 
                        Setup.rois.files, Setup.conditions.onsets/durations, Setup.covariates.files
                       When using Setup.add=1 in combination with Setup.done, Setup.preprocessing, Denoising.done, and/or 
                        Analysis.done only the new/added subjects will be processed
                       When using Setup.add=1 the BATCH.subjects field is disregarded/overwritten to point to the new/added 
                        subjects only
                       note: Setup.add cannot be used in combination with any of the Setup.rois.add, Setup.conditions.add, or 
                        Setup.covariates.add options within the same batch structure
  
     masks
       Grey          : masks.Grey{nsub} char array of grey matter mask volume file [defaults to Grey mask from structural] 
       White         : masks.White{nsub} char array of white matter mask volume file [defaults to White mask from structural] 
       CSF           : masks.CSF{nsub} char array of CSF mask volume file [defaults to CSF mask from structural] 
                     : each of these fields can also be defined as a double cell array for session-specific files (e.g. 
                        mask.Grey{nsub}{nses} grey matter file for subject nsub and session nses)
                     : each of these fields can also be defined as a structure with fields files/dimensions/etc. 
                        (same as 'Setup.rois' below).
     rois
       names         : rois.names{nroi} char array of ROI name [defaults to ROI filename]
       files         : rois.files{nroi}{nsub}{nses} char array of roi file (rois.files{nroi}{nsub} char array of roi file, 
                        to use the same roi for all sessions; or rois.files{nroi} char array of roi file, to use the same 
                        roi for all subjects)
       dimensions    : rois.dimensions{nroi} number of ROI dimensions - # temporal components to extract from ROI [1] (set 
                        to 1 to extract the average timeseries within ROI voxels; set to a number greater than 1 to extract 
                        additional PCA timeseries within ROI voxels; set to 0 to compute a weighted sum within ROI voxels 
                        (ROI mask values are interpreted as weights))
       multiplelabels: rois.multiplelabels(nroi) 1/0 to indicate roi file contains multiple labels/ROIs (default: set to 
                        1 if there exist an associated .txt or .xls file with the same filename and in the same folder as 
                        the roi file)
       mask          : rois.mask(nroi) 1/0 to mask with grey matter voxels [0] 
       regresscovariates: rois.regresscovariates(nroi) 1/0 to regress known first-level covariates before computing PCA 
                        decomposition of BOLD signal within ROI [1 if dimensions>1; 0 otherwise] 
       roiextract    : rois.roiextract(nroi) index n to Setup.roifunctionals(n) identifying functional dataset 
                        coregistered  to this ROI to extract BOLD timeseries from [1] (set to 0 to extract BOLD signal 
                        from Setup.functionals instead)
       add           : 1/0; use 0 (default) to define the full set of ROIs to be used in your analyses; use 1 to define 
                        an additional set of ROIs (to be added to any already-existing ROIs in your project) [0]
   
     conditions
       names         : conditions.names{ncondition} char array of condition name
       onsets        : conditions.onsets{ncondition}{nsub}{nses} vector of condition onsets (in seconds)
       durations     : conditions.durations{ncondition}{nsub}{nses} vector of condition durations (in seconds)
       param         : conditions.param(ncondition) temporal modulation (0 for no temporal modulation; positive index to 
                        first-level covariate for other temporal interactions) 
       filter        : conditions.filter{ncondition} temporal/frequency decomposition ([] for no decomposition; [low high] 
                        for fixed band-pass frequency filter; [N] for filter bank decompositoin with N frequency filters; 
                        [Duration Onsets] in seconds for sliding-window decomposition where Duration is a scalar and Onsets 
                        is a vector of two or more sliding-window onset values) 
       missingdata   : 1/0 Allow subjects with missing condition data (empty onset/duration fields in *all* of the
                        sessions) [0] 
       importfile    : (optional) Alternatively, importfile is a char or cell array pointing to a '*.txt','*.csv', or 
                        BIDS- '*.tsv' file containing conditions names/onsets/durations information (see help 
                        conn_importcondition)
       importfile_options: (for conditions.importfile procedure only) Cell array containing additional options to pass 
                        to conn_importcondition when importing condition info (see help conn_importcondition)
       add           : 1/0; use 0 (default) to define the full set of conditions to be used in your analyses; use 1 to 
                        define an additional set of conditions (to be added to any already-existing conditions in your 
                        project) [0]
 
     covariates
       names         : covariates.names{ncovariate} char array of first-level covariate name
       files         : covariates.files{ncovariate}{nsub}{nses} char array of covariate file 
       add           : 1/0; use 0 (default) to define the full set of covariates to be used in your analyses; use 1 to 
                        define an additional set of covariates (to be added to any already-existing covariates in your 
                        project) [0]
   
     subjects
       effect_names  : subjects.effect_names{neffect} char array of second-level covariate name
       effects       : subjects.effects{neffect} vector of size [nsubjects,1] defining second-level effects
       descrip       : (optional) subjects.descrip{neffect} char array of effect description (long name; for display 
                        purposes only)
       add           : 1/0; use 0 (default) to define the full set of covariates to be used in your analyses; use 1 to 
                        define an additional set of covariates (to be added to any already-existing covariates in your 
                        project) [0]
   
     subjects
       group_names   : subjects.group_names{ngroup} char array of second-level group name
       groups        : subjects.group vector of size [nsubjects,1] (with values from 1 to ngroup) defining subject groups
       descrip       : (optional) subjects.descrip{neffect} char array of group description (long name; for display 
                        purposes only)
       add           : 1/0; use 0 (default) to define the full set of covariates to be used in your analyses; use 1 to 
                        define an additional set of covariates (to be added to any already-existing covariates in your 
                        project) [0]
   
     analyses        : Vector of index to analysis types (1: ROI-to-ROI; 2: Seed-to-voxel; 3: Voxel-to-voxel; 4: Dynamic 
                        FC) Defaults to vector [1,2,3,4] (all analyses)
     voxelmask       : Analysis mask (voxel-level analyses): 1: Explicit mask (brainmask.nii); 2: Implicit mask 
                        (subject-specific) [1] 
     voxelmaskfile   : Explicit mask file (only when voxelmask=1) [fullfile(fileparts(which('spm')),'apriori',
                        'brainmask.nii')] 
     voxelresolution : Analysis space (voxel-level analyses): 1: Volume-based template (SPM; default 2mm isotropic 
                        or same as explicit mask if specified); 2: Same as structurals; 3: Same as functionals; 
                        4: Surface-based template (Freesurfer) [1] 
     surfacesmoothing: (for voxelresolution=4) Smoothing level for surface-based analyses (number of discrete diffusion 
                        steps) [10]
     analysisunits   : BOLD signal units: 1: PSC units (percent signal change); 2: raw units [1] 
     outputfiles     : Optional output files (outputfiles(1): 1/0 creates confound beta-maps; outputfiles(2): 1/0 creates 
                        confound-corrected timeseries; outputfiles(3): 1/0 creates seed-to-voxel r-maps) ;outputfiles(4): 
                        1/0 creates seed-to-voxel p-maps) ;outputfiles(5): 1/0 creates seed-to-voxel FDR-p-maps); 
                        outputfiles(6): 1/0 creates ROI-extraction REX files; [0,0,0,0,0,0] 
     spmfiles        : Optionally, spmfiles{nsub} is a char array pointing to the 'SPM.mat' source file to extract Setup 
                        information from for each subject (use alternatively spmfiles{nsub}{nses} for session-specific 
                        SPM.mat files) 
     spmfiles_options: (for Setup.spmfiles procedure) Cell array containing additional options to pass to conn_importspm 
                        when importing experiment info from spmfiles (see help conn_importspm)
     unwarp_functionals: (for Setup.preprocessing.steps=='realign&unwarp&phasemap') unwarp_functionals{nsub}{nses} char 
                        array of Phase Map volumes (vdm* file; explicitly entering these volumes here superceeds CONN's 
                        default option to search for/use vdm* files in same directory as functional data) 
     coregsource_functionals: (for Setup.preprocessing.steps=='functional_coregister/segment/normalize') 
                        coregsource_functionals{nsub} char array of source volume for coregistration/normalization/
                        segmentation (used only when preprocessing "coregtomean" field is set to 2, user-defined source 
                        volumes are used in this case instead of either the first functional volume (coregtomean=0) or the 
                        mean functional volume (coregtomean=1) for coregistration/normalization/segmentation) 
     localcopy       : (for Setup.structural and Setup.functional) 1/0 : copies structural/functional files into 
                        conn_*/data/BIDS folder before importing into CONN [0]
     binary_threshold: (for BOLD extraction from Grey/White/CSF ROIs) Threshold value # for binarizing Grey/White/CSF 
                        masks [.5 .5 .5] 
     binary_threshold_type: (for BOLD extraction from Grey/White/CSF ROIs) 1: absolute threshold (keep voxels with values
                        above x); 2: percentile threshold (keep x% of voxels with the highest values) [1 1 1] 
     erosion_steps   : (for BOLD extraction from Grey/White/CSF ROIs) integer numbers are interpreted as erosion kernel 
                        size for Grey/White/CSF mask erosion after binarization; non-integer numbers are interpreted as 
                        percentile voxels kept after erosion [0 1 1]
     erosion_neighb  : (for BOLD extraction from Grey/White/CSF ROIs; only when using integer erosion_steps/ kernel sizes, 
                        this field is disregarded otherwise) Neighborhood size for Grey/White/CSF mask erosion after
                        binarization (a voxel is eroded if there are more than masks_erosion_neighb zeros within the 
                        (2*masks_erosionsteps+1)^3-neighborhood of each voxel) [1 1 1]
  
   
  BATCH.Setup.preprocessing PERFORMS DATA PREPROCESSING STEPS (realignment/slicetiming/coregistration/segmentation/normalization/smoothing) %!
   Setup
     preprocessing     
       steps         : List of data preprocessing steps (cell array containing a subset of the following step names, in 
                        the desired order; e.g. {'functional_realign','functional_art'}):
                       PIPELINES:
                         'default_mni'                           : default MNI-space preprocessing pipeline
                         'default_mniphase'                      : same as default_mni but with vdm/fieldmap information
                         'default_ss'                            : default subject-space preprocessing pipeline
                         'default_ssphase'                       : same as default_ss but with vdm/fieldmap information
                         'default_ssnl'                          : same as default_ss but with non-linear coregistration
                       INDIVIDUAL STRUCTURAL STEPS:
                         'structural_center'                     : centers structural data to origin (0,0,0) coordinates
                         'structural_manualorient'               : applies user-defined affine transform to structural
                         'structural_manualspatialdef'           : applies user-defined spatial deformation to structural
                         'structural_normalize'                  : structural normalization to MNI space
                         'structural_segment'                    : structural segmentation (Gray/White/CSF tissue classes)
                         'structural_segment&normalize'          : structural unified normalization and segmentation 
                       INDIVIDUAL FUNCTIONAL (or combined functional/structural) STEPS:
                         'functional_art'                        : functional identification of outlier scans (from motion 
                                                                    displacement and global signal changes)
                         'functional_center'                     : centers functional data to origin (0,0,0) coordinates
                         'functional_coregister_affine'          : functional affine coregistration to structural volumes
                         'functional_coregister_nonlinear'       : functional non-linear coregistration to structural volumes
                         'functional_manualorient'               : applies user-defined affine transformation to functional data
                         'functional_manualspatialdef'           : applies user-defined spatial deformation to functional data
                         'functional_motionmask'                 : creates functional motion masks (mean BOLD signal spatial 
                                                                    derivatives wrt motion parameters)
                         'functional_normalize_direct'           : functional direct normalization
                         'functional_normalize_indirect'         : functional indirect normalization (coregister to structural; 
                                                                    normalize structural; apply same transform to functionals)
                         'functional_realign'                    : functional realignment
                         'functional_realign_noreslice'          : functional realignment without reslicing (applies transform
                                                                    to source header files)
                         'functional_realign&unwarp'             : functional realignment & unwarp (motion-by-inhomogeneity 
                                                                    interactions)
                         'functional_realign&unwarp&fieldmap'    : functional realignemnt & unwarp & inhomogeneity correction
                                                                    (from vdm/fieldmap files)
                         'functional_removescans'                : removes user-defined number of initial scans from functional
                         'functional_segment'                    : functional segmentation (Gray/White/CSF tissue classes)
                         'functional_segment&normalize_direct'   : functional direct unified normalization and segmentation
                         'functional_segment&normalize_indirect' : functional indirect unified normalization and segmentation
                                                                    (coregister to structural; normalize and segment structural; 
                                                                    apply same transformation to functionals)
                         'functional_slicetime'                  : functional slice-timing correction
                         'functional_smooth'                     : functional spatial smoothing
                       If steps is left empty or unset a gui will prompt the user to specify the desired preprocessing pipeline 
                       If steps points to an existing preprocessing-pipeline file (e.g. saved from GUI) the corresponding 
                        preprocessing-pipeline will be run
    
       voxelsize_anat  : (structural normalization) target voxel size for resliced volumes (mm) [2]
       voxelsize_func  : (functional normalization) target voxel size for resliced volumes (mm) [2]
       boundingbox     : (normalization) target bounding box for resliced volumes (mm) [-90,-126,-72;90,90,108] 
       interp          : (normalization) target voxel interpolation method (0:nearest neighbor; 1:trilinear; 2 or higher:n-order spline) [4]
       fwhm            : (functional_smooth) Smoothing factor (mm) [8]
       coregtomean     : (functional_coregister/segment/normalize) 0: use first volume; 1: use mean volume (computed during 
                          realignment); 2: use user-defined source volume (see Setup.coregsource_functionals field) [1]
       sliceorder      : (functional_slicetime) acquisition order (vector of indexes; 1=first slice in image; note: use cell
                          array for subject-specific vectors)
                          alternatively sliceorder may also be defined as one of the following strings: 'ascending',
                          'descending','interleaved (middle-top)','interleaved (bottom-up)','interleaved (top-down)',
                          'interleaved (Siemens)','BIDS'  
                          alternatively sliceorder may also be defined as a vector containing the acquisition time in 
                          milliseconds for each slice (e.g. for multi-band sequences) 
       ta              : (functional_slicetime) acquisition time (TA) in seconds (used to determine slice times when 
                          sliceorder is defined by a vector of slice indexes; note: use vector for subject-specific 
                          values). Defaults to (1-1/nslices)*TR where nslices is the number of slices
       art_thresholds  : (functional_art) ART thresholds for identifying outlier scans 
                                             art_thresholds(1): threshold value for global-signal (z-value; default 5) 
                                             art_thresholds(2): threshold value for subject-motion (mm; default .9) 
                         additional options: art_thresholds(3): 1/0 global-signal threshold based on scan-to-scan changes
                                                                in global-BOLD measure (default 1) 
                                             art_thresholds(4): 1/0 subject-motion threshold based on scan-to-scan changes 
                                                                in subject-motion measure (default 1) 
                                             art_thresholds(5): 1/0 subject-motion threhsold based on composite-movement 
                                                                measure (default 1) 
                                             art_thresholds(6): 1/0 force interactive mode (ART gui) (default 0) 
                                             art_thresholds(7): [only when art_threshold(5)=0] subject-motion threshold 
                                                                based on rotation measure 
                                             art_thresholds(8): N number of initial scans to be flagged for removal 
                                                                (default 0)
                             note: when art_threshold(5)=0, art_threshold(2) defines the threshold based on the translation 
                              measure, and art_threhsold(7) defines the threshold based on the rotation measure; otherwise 
                              art_threshold(2) defines the (single) threshold based on the composite-motion measure 
                             note: the default art_thresholds(1:2) [5 .9] values correspond to the "intermediate" 
                              (97th percentile) settings, to use the "conservative" (95th percentile) settings use 
                              [3 .5], to use the "liberal" (99th percentile) settings use [9 2] values instead
                             note: art needs subject-motion files to estimate possible outliers. If a 'realignment' 
                              first-level covariate exists it will load the subject-motion parameters from that first-
                              level covariate; otherwise it will look for a rp_*.txt file (SPM format) in the same 
                              folder as the functional data
                             note: subject-motion files can be in any of the following formats: a) *.txt file (SPM 
                              format; three translation parameters in mm followed by pitch/roll/yaw in radians); 
                              b) *.par (FSL format; three Euler angles in radians followed by translation parameters 
                              in mm); c) *.siemens.txt (Siemens MotionDetectionParameter.txt format); d) *.deg.txt (same 
                              as SPM format but rotations in degrees instead of radians)
       removescans     : (functional_removescans) number of initial scans to remove
       reorient        : (functional/structural_manualorient) 3x3 or 4x4 transformation matrix or filename containing corresponding matrix
       respatialdef    : (functional/structural_manualspatialdef) nifti deformation file (e.g. y_*.nii or *seg_sn.mat files)
       template_structural: (structural_normalize SPM8 only) anatomical template file for approximate coregistration 
                          [spm/template/T1.nii]
       template_functional: (functional_normalize SPM8 only) functional template file for normalization 
                          [spm/template/EPI.nii]
       affreg          : (normalization) affine registration before normalization ['mni']
       tpm_template    : (structural_segment, structural_segment&normalize in SPM8, and any segment/normalize option 
                          in SPM12) tissue probability map [spm/tpm/TPM.nii]
       tpm_ngaus       : (structural_segment, structural_segment&normalize in SPM8&SPM12) number of gaussians for each 
                          tissue probability map
   
   
  BATCH.Denoising PERFORMS DENOISING STEPS (confound removal & filtering) %!
   Denoising       
  
     done            : 1/0: 0 defines fields only; 1 runs DENOISING processing steps [0]
     overwrite       : (for done=1) 1/0: overwrites target files if they exist [1]
     filter          : vector with two elements specifying band pass filter: low-frequency & high-frequency cutoffs (Hz)
     detrending      : 0/1/2/3: BOLD times-series polynomial detrending order (0: no detrending; 1: linear detrending; 
                        ... 3: cubic detrending) 
     despiking       : 0/1/2: temporal despiking with a hyperbolic tangent squashing function (1:before regression; 
                        2:after regression) [0] 
     regbp           : 1/2: order of band-pass filtering step (1 = RegBP: regression followed by band-pass; 2 = Simult: 
                        simultaneous regression&band-pass) [1] 
     confounds       : Cell array of confound names (alternatively see 'confounds.names' below)
  
     confounds       : alternatively confounds can be a structure with fields
       names         : confounds.names{nconfound} char array of confound name (confound names can be: 'Grey Matter',
                        'White Matter','CSF',any ROI name, any covariate name, or 'Effect of *' where * represents 
                        any condition name])
       dimensions    : confounds.dimensions{nconfound} number of confound dimensions [defaults to using all dimensions 
                        available for each confound variable]
       deriv         : confounds.deriv{nconfound} include temporal derivatives up to n-th order of each effect (0 for 
                        raw timeseries, 1 for raw+firstderivative timeseries, etc.) [0|1]
       power         : confounds.power{nconfound} include powers up to n-th order of each effect (1 for linear effects, 
                        2 for linear+quadratic effect, etc.) [1]
       filter        : (for regbp==1) confounds.filter{nconfound} band-pass filter confound regressors before entering 
                        in regression equation [0]
   
   
  BATCH.Analysis PERFORMS FIRST-LEVEL ANALYSES (ROI-to-ROI and seed-to-voxel) %!
   Analysis            
  
     done            : 1/0: 0 defines fields only; 1 runs ANALYSIS processing steps [0]
     overwrite       : (for done=1) 1/0: overwrites target files if they exist [1]
     analysis_number : sequential index identifying each set of independent analyses [1] 
                       (alternative a string identifying the analysis name)
     measure         : connectivity measure used, 1 = 'correlation (bivariate)', 2 = 'correlation (semipartial)', 3 = 
                        'regression (bivariate)', 4 = 'regression (multivariate)'; [1] 
     weight          : within-condition weight, 1 = 'none', 2 = 'hrf', 3 = 'hanning'; [2] 
     modulation      : temporal modulation, 0 = standard weighted GLM analyses; 1 = gPPI analyses of condition-specific 
                        temporal modulation factor, or a string for PPI analyses of other temporal modulation factor 
                        (same for all conditions; valid strings are ROI names and 1st-level covariate names)'; [0] 
     conditions      : (for modulation==1 only) list of task condition names to be simultaneously entered in gPPI 
                        model (leave empty for default 'all existing conditions') [] 
     type            : analysis type, 1 = 'ROI-to-ROI', 2 = 'Seed-to-Voxel', 3 = 'all'; [3] 
     sources         : Cell array of sources names (seeds) (source names can be: any ROI name) (if this variable does 
                        not exist the toolbox will perform the analyses for all of the existing ROIs which are not 
                        defined as confounds in the Denoising step) 
  
     sources         : alternatively sources can be a structure with fields
       names         : sources.names{nsource} char array of source names (seeds)
       dimensions    : sources.dimensions{nsource} number of source dimensions [1]
       deriv         : sources.deriv{nsource} number of derivatives for each dimension [0]
       fbands        : sources.fbands{nsource} number of frequency bands for each dimension [1]
  
  
  BATCH.vvAnalysis PERFORMS FIRST-LEVEL ANALYSES (voxel-to-voxel) %!
   vvAnalysis            
 
     done            : 1/0: 0 defines fields only; 1 runs ANALYSIS processing steps [0]
     overwrite       : (for done=1) 1/0: overwrites target files if they exist [1]
     analysis_number : sequential index identifying each set of independent analyses [1] 
                       (alternative a string identifying the analysis name)
   
     measures        : voxel-to-voxel measure name (type 'conn_v2v measurenames' for a list of default measures) (if 
                        this variable does not exist the toolbox will perform the analyses for all of the default 
                        voxel-to-voxel measures) 
                            'group-PCA'             : Principal Component Analysis of BOLD timeseries
                            'group-ICA'             : Independent Component Analysis of BOLD timeseries
                            'group-MVPA'            : MultiVoxel Pattern Analysis of connectivity patterns
                            'IntrinsicConnectivity' : Intrinsic Connectivity Contrast (pICC0)
                            'LocalCorrelation'      : Integrated Local Correlation (ILC,LCOR)     
                            'GlobalCorrelation'     : Integrated Global Correlation (IGC,GCOR)   
                            'RadialCorrelation'     : Radial Correlation Contrast (RCC)
                            'RadialSimilarity'      : Radial Similarity Contrast (RSC)
                            'ALFF'                  : Amplitude of Low Frequency Fluctuations
                            'fALFF'                 : fractional ALFF
 
     measures        : alternatively voxel-to-voxel measures can be a structure with fields
       names         : measures.names voxel-to-voxel measure name (see 'conn_v2v measurenames' for a list of valid 
                        measure names)
       factors       : (for group-PCA, group-ICA, group-MVPA) number of group-level components to estimate
       kernelsupport : (for ILC, RCC) local support (FWHM mm) of smoothing kernel [8]
       norm          : (for ILC,ICC,RCC,RSC,ALFF,fALFF) 0/1 normalize values to z-scores [1]
       mask          : (for group-PCA, group-ICA, group-MVPA) optional mask for group-level component estimation 
                        (e.g. masked ICA)
       dimensions    : number of subject-level dimensions to retain (subject-level dimensionality reduction) [64]
   
   
  BATCH.dynAnalysis PERFORMS FIRST-LEVEL ANALYSES (dynamic connectivity) %!
   dynAnalysis            
 
     done            : 1/0: 0 defines fields only; 1 runs ANALYSIS processing steps [0]
     overwrite       : (for done=1) 1/0: overwrites target files if they exist [1]
     analysis_number : sequential index identifying each set of independent analyses [1] 
                       (alternative a string identifying the analysis name)
   
     sources         : Cell array of sources names (seeds) (source names can be: any ROI name) (if this variable does 
                        not exist the toolbox will perform the analyses for all of the existing ROIs which are not 
                        defined as confounds in the Denoising step) 
     factors         : Number of group-level dynamic components to estimate [20]
     window          : Length of temporal windows (FWHM in seconds) [30]
   
   
  BATCH.Results PERFORMS SECOND-LEVEL ANALYSES (ROI-to-ROI and Seed-to-Voxel analyses) %!
   Results             
  
     done            : 1/0: 0 defines fields only; 1 runs processing steps [0]
     overwrite       : (for done=1) 1/0: overwrites target files if they exist [1]
     analysis_number : sequential indexes identifying each set of independent analysis [1]
                       (alternative a string identifying the analysis name)
     foldername      : folder to store the results
     display         : 1/0 display results [1]
     saveas          : optional name to save between-subjects/between_conditions contrast
  
     between_subjects
       effect_names  : cell array of second-level effect names
       contrast      : contrast vector (same size as effect_names)
   
     between_conditions [defaults to multiple analyses, one per condition]
       effect_names  : cell array of condition names (as in Setup.conditions.names)
       contrast      : contrast vector (same size as effect_names)
   
     between_sources    [defaults to multiple analyses, one per source]
       effect_names  : cell array of source names (as in Analysis.regressors, typically appended with _1_1; generally 
                        they are appended with _N_M -where N is an index ranging from 1 to 1+derivative order, and M 
                        is an index ranging from 1 to the number of dimensions specified for each ROI; for example 
                        ROINAME_2_3 corresponds to the first derivative of the third PCA component extracted from the 
                        roi ROINAME) 
       contrast      : contrast vector (same size as effect_names)
   
   
  BATCH.vvResults PERFORMS SECOND-LEVEL ANALYSES (Voxel-to-Voxel analyses) %!
   vvResults             
  
     done            : 1/0: 0 defines fields only; 1 performs processing steps [0]
     overwrite       : (for done=1) 1/0: overwrites target files if they exist [1]
     analysis_number : sequential indexes identifying each set of independent analysis [1]
                       (alternative a string identifying the analysis name)
     foldername      : folder to store the results
     display         : 1/0 display results [1]
     saveas          : optional name to save between-subjects/between_conditions contrast
   
     between_subjects
       effect_names  : cell array of second-level effect names
       contrast      : contrast vector (same size as effect_names)
   
     between_conditions [defaults to multiple analyses, one per condition]
       effect_names  : cell array of condition names (as in Setup.conditions.names)
       contrast      : contrast vector (same size as effect_names)
   
     between_measures [defaults to multiple analyses, one per measure]
       effect_names  : cell array of measure names (as in Analysis.measures) 
       contrast      : contrast vector (same size as effect_names)
   
 __________________________________________________________________________________________________________________
  
  See 
    conn_batch_workshop_nyu.m 
    conn_batch_workshop_nyu_parallel.m 
    conn_batch_humanconnectomeproject.m 
  for additional information and examples of use.
  

