package Model;

use strict;
use Logger;
use Cfg;
use DBI;

sub _db() {
    my $db;
    $db = DBI->connect(
            'DBI:mysql:database='
                . $cfg->{DB4U}->{n}           . ';hostname='
                . $cfg->{DB4U}->{h},
            $cfg->{DB4U}->{u},
            $cfg->{DB4U}->{p},
            {   'mysql_auto_reconnect' => 1,
                'RaiseError'           => 1,
                'AutoCommit'           => 1
            }
    );
    return $db;
}
sub new() {
    my ( $class, $arg ) = @_;
    my $self = {};
    if ( $arg->{id} ) {
        $self = load( $class, $arg->{id} );
    }
    else {
        bless $self, $class;
    }
    $self->set($arg);
    return $self;
}
sub load() {
    my ( $class, $value, $column ) = @_;
    
    $log->debug($class->db_table().'->load(v='.$value.', c='.$column.')');
    
    $column ||= 'id';
    return 0 unless $value;
    my $self = ();
    $self = &_fetch_from_db( $class, $column, $value );
    return $self;
}
sub list() {
    my ($class) = @_;
    
    $log->debug($class->db_table().'->list()');

    my $h
        = &_db->prepare( "SELECT "
            . join( ',', $class->db_columns() )
            . " FROM "
            . $class->db_table() );
    $h->execute();
    my @b = ();
    while ( my $l = $h->fetchrow_hashref ) {
        push @b, $l;
    }
    return \@b;
}
sub list_where() {
    my ( $class, $value, $column ) = @_;

    $log->debug($class->db_table().'->list_where(v='.$value.', c='.$column.')');

    my $h
        = &_db->prepare( "SELECT id FROM "
            . $class->db_table()
            . " WHERE "
            . ( $column || 'id' )
            . " = ?" );
    $h->execute( $value || 0 );
    eval "use $class;";
    my @b = ();
    while ( my ($id) = $h->fetchrow_array ) {
        push @b, $class->load($id);
    }

    return \@b;
}
sub list_where_hash() {
    my ( $class, $value, $column ) = @_;

    $log->debug($class->db_table().'->list_where_hash(v='.$value.', c='.$column.')');

    my $h
        = &_db->prepare( "SELECT "
            . join( ',', $class->db_columns() )
            . " FROM "
            . $class->db_table()
            . " WHERE "
            . ( $column || 'id' )
            . " = ?" );
    $h->execute( $value || 0 );

    my @b = ();

    while ( my $l = $h->fetchrow_hashref ) {
        push @b, $l;
    }

    return \@b;
}
sub list_html() {
    my ($class) = @_;


    my $limit = ' limit 0, 1000';

    my $ext_col = 'CONCAT("<a href=/api/'.$class->db_table().'/load/",id,".html>", id,"</a>") href, ';

    use Data::Table;
    my $t = Data::Table::fromSQL( &_db, "SELECT $ext_col " . join( ',', $class->db_columns() ) . " FROM " . $class->db_table(). ' '. $limit );

    return $t->html;
}
sub list2html() {
    my $class = shift;
    my $q     = shift;
    
    use Data::Table;
    my $t = Data::Table::fromSQL( &_db, $q );
    
    $log->debug('list2html()');
    
    undef $q;

    return $t->html;
}

sub save() { 
    my $self = shift; 
    $self->_store_in_db(); 
    return $self; 
}

sub newid() {
    my $self = shift;
    return &_db->{mysql_insertid} || $self->{id};
}

sub set() {
    my ( $self, $args ) = @_;
    foreach my $col ( $self->db_columns ) {
        $self->{$col} = $args->{$col} if defined $args->{$col};
    }
    foreach my $key ( keys %$args ) {
        $self->{$key} = 1
            if $key =~ /.*NULL$/;
    }
    return 1;
}

sub _fetch_from_db() {
    my ( $cls, $col, $val ) = @_;
    
    my $h
        = &_db->prepare( 'SELECT '
            . join( ',', $cls->db_columns() )
            . ' FROM '
            . $cls->db_table()
            . ' WHERE '
            . $col
            . ' = ? ' );
    $h->execute($val);
    my $obj = $h->fetchrow_hashref();

    return bless $obj, $cls;
}

sub _store_in_db() {
    my $self  = shift;
    my @binds = ();
    my @keys  = ();

    foreach my $key ( $self->db_columns ) {
        next unless defined $self->{$key};
        next if $key eq 'id';
        if ( $self->{"${key}NULL"} ) {
            push @keys,  "$key = ?";
            push @binds, undef;
        }
        elsif ( $self->{$key} =~ /^[A-Z_]+\(.*\)$/ ) {
            push @keys, "$key = $self->{$key}";
        }
        elsif ( $self->{$key} ne '' ) {
            push @keys,  "$key = ?";
            push @binds, $self->{$key};
        }
    }

    my $q = '';

    if ( $self->{id} ) {
        $q
            = 'UPDATE '
            . $self->db_table . ' SET '
            . join( ',', @keys )
            . ' WHERE id = ?';
    }

    else {
        $q = 'INSERT ' . $self->db_table . ' SET ' . join( ',', @keys ) . ' ';
    }

    if ( $self->{id} ) {
        push @binds, $self->{id};
    }

    my $h = &_db->prepare($q);
    $h->execute(@binds) or do { return 0; };

    $self->{id} ||= $self->newid();

    undef $q;
    undef @binds;
    undef @keys;

    return 1;
}

sub save() {
    my $self = shift;
    $self->_store_in_db();
    return $self;
}

sub newid() {
    my $self = shift;
    return &_db->{mysql_insertid} || $self->{id};
}

1;
