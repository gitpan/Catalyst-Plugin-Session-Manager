package Catalyst::Plugin::Session::Storage::FastMmap;
use strict;
use warnings;
use base qw/Catalyst::Plugin::Session::Storage/;
use Cache::FastMmap;

our $SHARE_FILE = "/tmp/session";
our $EXPIRES    = 60 * 60;

sub new { 
    my ($class, $config) = @_;
    bless {
        config => $config,
        cache  => Cache::FastMmap->new(
            share_file  => $config->{session}{file} || $SHARE_FILE,
            expire_time => $config->{session}{expires} || $EXPIRES,
        ),
    }, $class;
}

sub get {
    my $self = shift;
    $self->{cache}->get(@_);
}

sub set {
    my ( $self, $c ) = @_;
    my $sid = $c->sessionid or return;
    $self->{cache}->set( $sid, $c->session );
}

1;
__END__

