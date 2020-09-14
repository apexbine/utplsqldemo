create or replace package tst_simple as

  -- %suite(Testing function add_two_numbers:) 
  
  -- %test(- Both values are null, expected: null)
    procedure add_two_numbers_null_null;

  -- %test(- One value is null, one value is integer, expected: null)
    procedure add_two_numbers_one_null;
    
  -- %test(- Two integer values, expected: integer)
    procedure add_two_numbers_int_int;  
  
  -- %test(- Two float values, expected: integer)
    procedure add_two_numbers_float_float;
    
  -- %test(- One too large value, expected: ORA-06502)
  -- %throws (VALUE_ERROR)
    procedure add_two_large_numbers;

end;
/

create or replace package body tst_simple as

  procedure add_two_numbers_null_null is
  begin
    ut.expect( pkg_simple.add_two_numbers(
                                      null
                                    , null
                       )).to_equal( to_number(null) );
  end;

  procedure add_two_numbers_one_null is
  begin
    ut.expect( pkg_simple.add_two_numbers(
                                      null
                                    , 4
                       )).to_equal( to_number(null) );
  end;
  
  procedure add_two_numbers_int_int is
  begin
    ut.expect( pkg_simple.add_two_numbers(
                                      4
                                    , 2
                       ),'Exactly 6').to_equal( 6 );
    ut.expect( pkg_simple.add_two_numbers(
                                      4
                                    , 2
                       ),'Less than 8').to_be_less_than( 8 );                       
  end;

  procedure add_two_numbers_float_float is
  begin
    ut.expect( pkg_simple.add_two_numbers(
                                      4.2
                                    , 0.2
                       )).to_equal( 4 );
  end;

  procedure add_two_large_numbers is
  begin
    ut.expect( pkg_simple.add_two_numbers(
                                      power(10,40)
                                    , 4
                       )).to_be_greater_than( 1000000000000000000000 );
  end;
end;