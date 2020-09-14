drop sequence test_sequence;

create sequence test_sequence 
minvalue -999999999999999999999999999 
maxvalue -1 
increment by -1 
start with -1 
nocache noorder nocycle nokeep noscale global;