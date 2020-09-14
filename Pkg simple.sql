create or replace package pkg_simple as

  function add_two_numbers(
    p_num1  integer
  , p_num2  integer
  )return integer;

end;
/

create or replace package body pkg_simple as

  function add_two_numbers(
    p_num1  integer
  , p_num2  integer
  )return integer is
    v_result integer;
  begin
    v_result := p_num1 + p_num2;
    return v_result;
  end;

end;