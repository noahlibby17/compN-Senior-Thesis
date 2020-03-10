 % Start EEGLAB
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

% Replace this fields with your path and filenames
datapath = '/home/mdynamics/Desktop/noahSPROJ_participants/5/uncut/';
datafilename = '5_uncut.edf';
datafile2save = 'test_export.edf';

% Import EDF using BIOSIG
EEG = pop_biosig([datapath datafilename]);

% Writing the data
pop_writeeeg(EEG, [datapath datafile2save], 'TYPE','EDF');

 % Now importing again the saved file
EEG = pop_biosig([datapath datafile2save]);

% This works for me :)