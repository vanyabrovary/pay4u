package Model::shop_ordt;

use strict;

use Model;
our @ISA = qw/Model/;

sub db_table()   { 'shop_ordt' };
sub db_columns() { qw/id transaction_id res created/ };

1;
