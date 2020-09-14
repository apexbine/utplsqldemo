create or replace package tst_complex as

  -- %suite(Testing procedure move_objects_to_versioned_table:) 
  
  -- %test(- An object that didn't exist previously should be inserted)
  procedure insert_new_object;

  -- %test(- The current version of an existing object should be terminated, a new version should be added)
  procedure update_existing_object;
    
  -- %test(- The current version of an object should be terminated)
  procedure terminate_existing_object;
              
  -- %test(- The current version of an object should remain untouched)
  procedure leave_existing_object_unchanged;

  -- % test(- Compare import table and current tracks in versioned table)
  procedure compare_tables;

end;
/

create or replace package body tst_complex as

  procedure insert_new_object is
    v_cnt pls_integer;
  begin
   -- setup
   insert into import_tracks(
      id
      , node_from
      , node_to
      , track_length
    )values(
      test_sequence.nextval
    , 'D'
    , 'E'
    , 6022
    );
   -- execute
    pkg_complex.move_objects_to_versioned_table( trunc( sysdate + 5 ));
   -- check
    select count( * )
    into v_cnt
    from versioned_tracks
    where node_from = 'D'
      and node_to = 'E';

    ut.expect( v_cnt ).to_equal( 1 );
  end;

  procedure update_existing_object is
    v_cnt pls_integer;
  begin
    -- setup
    insert into import_tracks(
      id
      , node_from
      , node_to
      , track_length
    )values(
      test_sequence.nextval
    , 'C'
    , 'D'
    , 2503
    );

    insert into versioned_tracks(
      id
      , node_from
      , node_to
      , track_length
      , valid_from
      , valid_until
      , track_comment
    )values(
      test_sequence.nextval
    , 'C'
    , 'D'
    , 59302
    , trunc( sysdate )
    , null
    , 'Track to be changed'
    );

    -- execute
    pkg_complex.move_objects_to_versioned_table( trunc( sysdate + 5 ));
    -- check
    select count( * )
    into v_cnt
    from versioned_tracks
    where node_from = 'C'
          and node_to = 'D';

    ut.expect( v_cnt ).to_equal( 2 );
  end;

  procedure terminate_existing_object is
    v_cnt pls_integer;
  begin
    -- setup
    insert into versioned_tracks(
      id
      , node_from
      , node_to
      , track_length
      , valid_from
      , valid_until
      , track_comment
    )values(
      test_sequence.nextval
    , 'A'
    , 'B'
    , 513
    , trunc( sysdate )
    , null
    , 'To be terminated'
    );
    
    -- execute
    pkg_complex.move_objects_to_versioned_table( trunc( sysdate + 5 ));

    -- check
    select count( * )
    into v_cnt
    from versioned_tracks
    where node_from = 'A'
          and node_to = 'B'
          and valid_until is not null;

    ut.expect( v_cnt ).to_equal( 1 );
  end;

  procedure leave_existing_object_unchanged is
    v_cnt pls_integer;
  begin
    -- setup
    insert into import_tracks(
      id
      , node_from
      , node_to
      , track_length
    )values(
      test_sequence.nextval
    , 'B'
    , 'C'
    , 1557
    );

    insert into versioned_tracks(
      id
      , node_from
      , node_to
      , track_length
      , valid_from
      , valid_until
      , track_comment
    )values(
      test_sequence.nextval
    , 'B'
    , 'C'
    , 1557
    , trunc( sysdate )
    , null
    , 'To be left unchanged'
    );
    
    -- execute
    pkg_complex.move_objects_to_versioned_table( trunc( sysdate + 5 ));

    -- check
    select count( * )
    into v_cnt
    from versioned_tracks
    where node_from = 'B'
          and node_to = 'C'
          and valid_until is null;

    ut.expect( v_cnt ).to_equal( 1 );
  end;

  procedure compare_tables is
    l_expected_data    sys_refcursor;
    l_actual_data      sys_refcursor;
  begin
    open l_expected_data for
      select node_from
           , node_to
           , track_length
        from import_tracks;

    open l_actual_data for
      select node_from
           , node_to
           , track_length
        from versioned_tracks
       where valid_until is null;

    ut.expect( l_expected_data ).to_equal( l_actual_data ).unordered;
  end;
 
end;