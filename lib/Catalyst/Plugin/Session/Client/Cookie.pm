package Catalyst::Plugin::Session::Client::Cookie;
use strict;
use warnings;
use base qw/Catalyst::Plugin::Session::Client/;

our $EXPIRES = 60 * 60 * 24;

sub set {
    my ( $self, $c ) = @_;
    my $sid = $c->sessionid or return;
    my $set = 1;
    if ( my $cookie = $c->request->cookies->{session} ) {
        $set = 0 if $cookie->value eq $sid;
    }
    if ( $set ) {
        $c->response->cookies->{session} = {
            value   => $sid,
            expires => '+'. $self->expires .'s',
        };
    }
}

sub get {
    my ( $self, $c ) = @_;
    if ( my $cookie = $c->request->cookies->{session} ) {
        return $cookie->value;
    }
}

sub expires {
    my $self = shift;
    $self->{config}{expires} || $EXPIRES;
}

1;
__END__

