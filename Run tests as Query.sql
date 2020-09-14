select t.*, rownum line_no
  from table( ut.run( 'TST_COMPLEX' ) ) t;