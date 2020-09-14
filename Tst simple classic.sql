set serveroutput on

declare
  v_num1 number:= 4.2;
  v_num2 number:= 2.6;
begin
  dbms_output.put_line ( pkg_simple.add_two_numbers (4,2));
  dbms_output.put_line ( pkg_simple.add_two_numbers (null,null));
  dbms_output.put_line ( pkg_simple.add_two_numbers (v_num1,v_num2));
  dbms_output.put_line ( pkg_simple.add_two_numbers (null,2));
end;