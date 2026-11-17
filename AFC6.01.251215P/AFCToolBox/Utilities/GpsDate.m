data = readtable('D0_2.csv');
data(data.PosZ_gps > 1000, :) = [];
writetable(data, 'D0_2_new.csv');