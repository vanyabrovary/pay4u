package Model::invoice;

use strict;

use Model;
our @ISA = qw/Model/;

sub db_table()   { 'invoice' };
sub db_columns() { qw/id customer_id invoice_id status paid_at created_at/ };

use Model::invoice_item;
use Model::customer;

sub customer(){
    my $self = shift; 
    $self->{customer} 
	||= Model::customer->load($self->{customer_id});
}

sub items() {
    my $self = shift;
    $self->{items} 
	||= Model::invoice_item->list_where_hash($self->{id}, 'invoice_id');
}

sub total_sum(){
    my $self = shift;
    my $c = 0;

    $c += $_->{subtotal} foreach( @{$self->items()} );

    return $c; 
}

sub total_sum_pay(){
    my $self = shift;
    my $c = 0;

    $c += sprintf( "%.2f", $_->{subtotal} ) foreach( @{$self->items()} );

    return $c; 
}

sub total_count(){
    my $self = shift;
    my $c = 0;

    $c++ foreach( @{$self->items()} );

    return $c;
}

sub pay_moneypolo(){
    my $id = shift;

    use Model::invoice;

    my $inv = Model::invoice->load( $id, 'invoice_id' ) 
	or return '{"error":["invoice"]}';

    my @err;
    push @err, 'amount' if $inv->total_sum_pay <= 0;

    my $aref = $inv->customer->moneypolo_valid;
    push @err, @$aref if $aref != 0;

    use Core;
    return '{"error":'.&Core::dump2json( \@err ).'}' if (scalar @err);

    use PayPolo;
    return PayPolo->do($inv);

}

1;
