package PayPolo;

use warnings;
use strict;

use Logger;
use Cfg;

use JSON::Parse 'parse_json';
use JSON::Syck;
$JSON::Syck::ImplicitUnicode = 1;

use HTTP::Request::Common qw(POST);
use LWP::UserAgent;


sub init() {
    my ( $class, $customer ) = @_;
    my $Data = JSON::Syck::Dump({
        FirstName    => 'Client',
        CountryCode  => $cfg->{DEF}->{CountryCode},
        PostalCode   => $cfg->{DEF}->{PostalCode},
        ClientIP     => $cfg->{DEF}->{ClientIP},

        LastName     => $customer->{client_name},
        AddressLine1 => $customer->{client_street},
        City         => $customer->{client_city},
        Mobile       => $customer->{client_phone},
        Email        => $customer->{client_email},        
    });

    my $ua = LWP::UserAgent->new; 
    my $res = $ua->request( POST $cfg->{'MONEYPOLOA'}->{'url'}, [ Data => $Data, MerchantCode => $cfg->{'MONEYPOLOA'}->{'MerchantCode'}, Signature => &_signature( $Data, 'MONEYPOLOA' ) ]);  
    my $json = $res->content;
    
    return $json if ( $json =~ m/ERROR:/ );   
    $log->debug($json);
    
    my $perl = parse_json($json);   
    
    PayPolo->ordt( $json );
    
    return $perl->{AccountID};
}

sub do() {
    my ( $class, $order ) = @_; 

    my $Data = JSON::Syck::Dump({   
        SPAccountID             => PayPolo->init( $order->customer->moneypolo ),
        SPMerchantTransactionID => $order->{id},
        SPAmount                => $order->total_sum_pay,

        SPTestMode              => $cfg->{DEF}->{SPTestMode},
        SPSuccessURL            => $cfg->{DEF}->{SPSuccessURL},
        SPFailURL               => $cfg->{DEF}->{SPFailURL},
        SPCurrency              => $cfg->{DEF}->{SPCurrency},
        SPDetails               => $cfg->{DEF}->{SPDetails},
        SPPaymentMethod         => $cfg->{DEF}->{SPPaymentMethod},
    });

    return &_query_form_url_do($Data);
}

sub _query_form_url_do() {

    my $Data = shift;
    return "<html>
    <head>
    <title>...</title>
    </head>
    <body onload='setTimeout(function(){ document.myform.submit() }, 5);'>
    <div style='display:none;'>
    <form id='dataForm' method='POST' action='". $cfg->{MONEYPOLO}->{url}. "' name='myform'>
    <textarea name='MerchantCode'>".$cfg->{MONEYPOLO}->{MerchantCode}. "</textarea>
    <textarea name='Signature'>". &_signature( $Data, 'MONEYPOLO' ). "</textarea>
    <textarea name='Data'>$Data</textarea>
    </form>
    </div>
    </body>
    </html>";

}

sub _signature() {
    my ( $data, $type ) = @_;
    use Crypt::Digest::SHA512 qw( sha512_hex );
    return uc(sha512_hex('##'.$cfg->{$type}->{'MerchantCode'}.'##'.$data.'##'.$cfg->{$type}->{'Key'}.'##'));    
}


sub ordt() {
    my $class = shift;
    my $json  = shift;

    eval {
    
        my $perl = parse_json($json);
        use Model::shop_ordt;
        my $t = Model::shop_ordt->new();

        $t->{transaction_id}          = $perl->{SPMerchantTransactionID};
        $t->{res}                     = $json;
        $t->{created}                 = 'NOW()';
        $t->save();

        if($perl->{SPMerchantTransactionID}){
        
            use Model::invoice;
            my $mod = Model::invoice->load( $perl->{SPMerchantTransactionID} );
            
            if ($mod->{id}){
                $mod->{paid_at} = 'NOW()';
                $mod->save();
            }

        }

    };
}

    ########### TO DO THIS Venichka

    #my $ua = LWP::UserAgent->new; 
    #my $res = $ua->request( POST $cfg->{'MONEYPOLO'}->{'url'}, [ Data => $Data, MerchantCode => $cfg->{'MONEYPOLO'}->{'MerchantCode'}, Signature => &_signature( $Data, 'MONEYPOLO' ) ]);  
    #my $json = $res->content;

    #$log->debug("location: ". $res->header('location') );
    #$log->debug("Code: ". $res->code);
    #$log->info("is_redirect:". $res->is_redirect );
#    return $qform;
    #return $res->content;

    #return $json if ( $json =~ m/ERROR:/ );   
    #
    #my $perl = parse_json($json);   
    #return $perl->{AccountID};



1;
