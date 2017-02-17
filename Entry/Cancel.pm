package Entry::Cancel;

use strict;
use nginx;
use Logger;

sub handler() {
    my $r = shift;
    $r->send_http_header('text/html');
    $log->debug($r->remote_addr.' '.$r->request_method.' '.$r->uri);
    $r->print('CANCEL');
    return OK;
}

1;

__END__
