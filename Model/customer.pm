package Model::customer;

use strict;

use Model;
our @ISA = qw/Model/;

sub db_table()   {'customer'}
sub db_columns() { qw/id first_name last_name mobile email/; }

## to do. move to external class.
sub moneypolo_valid() {
    my $self = shift; 
    $self    = $self->moneypolo;
    my @wrong;
    ## to do. change qw to $cfg->rquired_fields
    foreach (qw/client_name client_country client_city client_street client_zip client_phone client_email/) {
	my $str = $self->{$_};
        if ( $_ eq 'client_name' ) {
            unless ( $str =~ m/^[A-Za-z0-9_\-\.,;:\\\@\/#\$%\&\*\(\)\[\] ]{1,150}$/i ) {
                push @wrong, $_;
            }
        }
        if ( $_ eq 'client_country' ) {
            unless ( $str =~ m/^[A-Z]{2}$/i ) {
                push @wrong, $_;
            }
        }
        if ( $_ eq 'client_city' ) {
            unless ( $str =~ m/^[A-Za-z0-9_\-\.,;:\\\@\/#\$%\&\*\(\)\[\] ]{1,50}$/i ) {
                push @wrong, $_;
            }
        }
        if ( $_ eq 'client_street' ) {
            unless ( $str =~ m/^[A-Za-z0-9_\-\.,;:\\\@\/#\$%\&\*\(\)\[\] ]{1,50}$/i ) {
                push @wrong, $_;
            }
        }
        if ( $_ eq 'client_zip' ) {
            unless ( $str =~ m/^[a-zA-Z0-9]{1,32}$/i ) {
                push @wrong, $_;
            }
        }
        if ( $_ eq 'client_email' ) {
            my $e;
            eval {
                use Email::Valid;
                $e = Email::Valid->address( -address => $str, -mxcheck => 1 );
            };
            unless ($e) {
                push @wrong, $_;
            }
        }
        if ( $_ eq 'client_phone' ) {
            unless ( $str =~ m/^\+[0-9]{5,}$/i ) {
                push @wrong, $_;
            }
            my $c;
            eval {
                use Number::Phone;
                my $p = Number::Phone->new($str);
                $c = $p->country();
            };
            push @wrong, $_ unless $c;
        }
    }
    if ( scalar @wrong ) {
        return \@wrong;
    } else {
        return 0;
    }
}
# mp means - MoneyPolo
sub moneypolo() {
    my $self = shift;
    my %c = (
        client_name    => $self->{first_name}.' '.$self->{last_name},
        client_email   => $self->{email},
        client_phone   => $self->{mobile},
        client_country => 'GB',
        client_city    => 'City',
        client_street  => 'Street',
        client_zip     => 'zip',
    );
    return \%c;
}

1;
