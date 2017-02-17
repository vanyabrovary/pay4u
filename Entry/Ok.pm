package Entry::Ok;

use strict;
use nginx;
use Logger;


sub handler() {
    my $r = shift;
    $r->send_http_header('text/html');
    $log->info($r->remote_addr.' '.$r->request_method.' '.$r->uri);
    if ($r->has_request_body(\&post) && $r->request_method eq "POST") {
        return OK;
    }
    $r->print('OK');
    return OK;
}


sub post {
    my $r = shift;  
    $r->send_http_header;

    use URI::Escape;

    my %args = map { uri_unescape($_) } split /[=&;]/, $r->request_body; 
    my $a    = \%args;
    my $json = $r->request_body;

    eval{
        if($json =~ /^\{(.+)?\}$/){
            $json = $1;
        }
    };

    $log->debug( 'args:'. $json );

    use Model::shop_ordt;

    my $t = Model::shop_ordt->new();
    $t->{transaction_id} = $a->{MerchantTransactionID} || '987';
    $t->{res}            = $json;
    $t->{created}        = 'NOW()';
    $t->save();
    $r->print('OK');

    return OK;
}

1;

__END__
