create or replace package pkg_complex as

  v_debug_commit boolean;
  
  procedure move_objects_to_versioned_table(
    p_date date
  );

end;
/

-- SECRET ALGORITHMS ...

create or replace package body pkg_complex as

  procedure move_objects_to_versioned_table(
    p_date date
  )is
  begin
    -- find and terminate all tracks existing tracks that are not delivered anymore
    update versioned_tracks v
    set
      valid_until = p_date
    where not exists(
      select *
      from import_tracks i
      where v.node_from = i.node_from
            and v.node_to = i.node_to
    );
  
    -- find all *changed* records
    for rec in(
      select i.*
           , v.id id_versioned
      from import_tracks i
      join versioned_tracks v on v.node_from = i.node_from
                                 and v.node_to = i.node_to
      where v.valid_until is null
            and v.track_length != i.track_length
    )loop
      update versioned_tracks
      set
        valid_until = p_date
      where id = rec.id_versioned;

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
      , rec.node_from
      , rec.node_to
      , rec.track_length
      , p_date
      , null
      , 'Changed'
      );

    end loop;
    
    -- find and insert all new tracks
    insert into versioned_tracks
      select test_sequence.nextval
           , i.node_from
           , i.node_to
           , i.track_length
           , p_date  as valid_from
           , null    as valid_until
           , 'New record'
      from import_tracks i
      where not exists(
        select *
        from versioned_tracks v
        where v.node_from = i.node_from
              and v.node_to = i.node_to
      );

    if v_debug_commit then
      commit;
    end if;
    
  end move_objects_to_versioned_table;

end;