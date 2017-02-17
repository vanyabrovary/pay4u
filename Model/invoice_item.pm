package Model::invoice_item;

use strict;

use Model;
our @ISA = qw/Model/;

sub db_table()   { 'invoice_item' };
sub db_columns() { qw/id invoice_id item quantity subtotal/ };

1;
