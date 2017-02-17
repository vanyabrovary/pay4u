package Core;

sub dump2json(){
    use JSON::Syck; 
    $JSON::Syck::ImplicitUnicode = 1;
    my $json;
    eval { $json = JSON::Syck::Dump( shift );  };
    return $json;
}




1;
