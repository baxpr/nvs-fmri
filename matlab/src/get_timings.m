function timings = get_timings(eprime_csv)

warning('off','MATLAB:table:ModifiedAndSavedVarnames')
warning('off','MATLAB:table:RowsAddedExistingVars')
eprime = readtable(eprime_csv);

%% Run 1

% Backtick is ScannerWait5.RTTime and there should be four

% FIXME We are here for conversion to NVS
% Previous script is modeling these:
%
%    {'NeutralCue'         }
%    {'FearCue'            }
%    {'NeutralImage'       }
%    {'FearImage'          }
%    {'UnknownCue'         }
%    {'UnknownNeutralImage'}
%    {'UnknownFearImage'   }

% First trial:
%
% time    frombacktick
% 190862             0    Backtick
% 200896         10034    ISICue.OnsetTime
% 205911         15049    Cue.OnsetTime        *
% 206398         15536    Cue.RTTime
% 206927         16065    ISIImage.OnsetTime
% 211959         21097    Image.OnsetTime      *
% 212534         21672    Image.RTTime
%
% This Cue.OnsetTime is the first FearCue from the original script
%
% This Image.OnsetTime is the first FearImage from the original script


% We also have these vars
%    Valence    Fear / Neutral
%    Type       1 / 2 / 3  is  Neutral / Fear / Unknown
%    Cue        X.bmp / question.bmp / o.bmp

% conditions from original script:
%
%  NeutralCue               70 84 96         139             195     223     250     280
%  FearCue      15 28 44                 126     153 165                 236             293
%  UnknownCue            56          111                 180     210             265         306 320 334
%
% Condition:   F F F U N N N U F N F F U N U N F N U N F U U U
% Type:        2 2 2 3 1 1 1 3 2 1 2 2 3 1 3 1 2 1 3 1 2 3 3 3
%
% Unknown image condition is split by neutral/fear Valence


scanstarts = sort(eprime.ScannerWait5_RTTime(~isnan(eprime.ScannerWait5_RTTime)));

timings = [];

for r = 1:4
    runtag = sprintf('Run%dTrialProc',r);
    timings{r} = [];

    timings{r}(end+1).name = 'Cue_Neutral';
    inds = eprime.Type==1 & strcmp(eprime.Procedure,runtag);
    timings{r}(end).onsets = (eprime.Cue_OnsetTime(inds) - scanstarts(r)) / 1000;

    timings{r}(end+1).name = 'Cue_Fear';
    inds = eprime.Type==2 & strcmp(eprime.Procedure,runtag);
    timings{r}(end).onsets = (eprime.Cue_OnsetTime(inds) - scanstarts(r)) / 1000;

    timings{r}(end+1).name = 'Cue_Unknown';
    inds = eprime.Type==3 & strcmp(eprime.Procedure,runtag);
    timings{r}(end).onsets = (eprime.Cue_OnsetTime(inds) - scanstarts(r)) / 1000;

    timings{r}(end+1).name = 'Image_Neutral';
    inds = eprime.Type==1 & strcmp(eprime.Procedure,runtag);
    timings{r}(end).onsets = (eprime.Image_OnsetTime(inds) - scanstarts(r)) / 1000;

    timings{r}(end+1).name = 'Image_Fear';
    inds = eprime.Type==2 & strcmp(eprime.Procedure,runtag);
    timings{r}(end).onsets = (eprime.Image_OnsetTime(inds) - scanstarts(r)) / 1000;

    timings{r}(end+1).name = 'Image_Unknown_Neutral';
    inds = eprime.Type==3 & strcmp(eprime.Valence,'Neutral') & strcmp(eprime.Procedure,runtag);
    timings{r}(end).onsets = (eprime.Image_OnsetTime(inds) - scanstarts(r)) / 1000;

    timings{r}(end+1).name = 'Image_Unknown_Fear';
    inds = eprime.Type==3 & strcmp(eprime.Valence,'Fear') & strcmp(eprime.Procedure,runtag);
    timings{r}(end).onsets = (eprime.Image_OnsetTime(inds) - scanstarts(r)) / 1000;

end

