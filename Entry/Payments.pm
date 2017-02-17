package Entry::Payments;

use strict;
use nginx;
use Logger;

sub handler() {
    my $r = shift; 
    my $u = $r->uri;
    $r->send_http_header('text/html');
    $log->info($r->remote_addr.' '.$r->request_method.' '.$r->uri);

    if ( $u =~ /^\/payments\/([0-9]{2,})+?\.html$/ ) {
        use Model::invoice;
        $r->print(&Model::invoice::pay_moneypolo($1));
        return OK;
    }
    return HTTP_NOT_FOUND;
}

1;

__END__
