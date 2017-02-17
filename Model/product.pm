package Model::product;

use strict;

use Model;
our @ISA = qw/Model/;

sub db_table()   { 'product' };
sub db_columns() { qw/id product_id name price/ };

1;
