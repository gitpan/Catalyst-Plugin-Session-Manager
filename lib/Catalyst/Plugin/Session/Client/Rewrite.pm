package Catalyst::Plugin::Session::Client::Rewrite;
use strict;
use warnings;

use base qw/Catalyst::Plugin::Session::Client/;

use URI::Find;

our $SESSIONID = "SESSIONID";

sub set {
    my ( $self, $c ) = @_;
    my $redirect = $c->response->redirect;
    $c->response->redirect( $self->uri($c, $redirect) ) if $redirect;
    my $sid = $c->sessionid or return;
    my $finder = URI::Find->new(
        sub {
            my ( $uri, $orig ) = @_;
            my $base = $c->request->base;
            return $orig unless $orig =~ /^$base/;
            return $orig if $uri->path =~ /\/-\//;
            return $self->uri($c, $orig);
        }
    );
    $finder->find( \$c->res->{body} ) if $c->res->body;
}

sub get {
    my ( $self, $c ) = @_;
    $c->request->param( $self->sessionid_name ) || undef;
}

sub sessionid_name {
    my $self = shift;
    return $self->{config}{name} || $SESSIONID;
}

sub uri {
    my ( $self, $c, $uri ) = @_;
    if ( my $sid = $c->sessionid ) {
        $uri = URI->new($uri);
        $uri->query_form($uri->query_form, $self->sessionid_name, $sid);
        return $uri->as_string;
    }
    return $uri;
}

1;
__END__

