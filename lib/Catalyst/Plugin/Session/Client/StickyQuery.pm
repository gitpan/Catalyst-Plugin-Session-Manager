package Catalyst::Plugin::Session::Client::StickyQuery;
use strict;
use warnings;
use base qw/Catalyst::Plugin::Session::Client/;

use HTML::StickyQuery;

our $SESSIONID = "SESSIONID";

sub set {
    my ( $self, $c ) = @_;
    my $sid = $c->sessionid or return;
    my $sessionid_name = $self->sessionid_name;
    my $content = $c->response->{body};
    $content =~ s/(<form\s*.*?>)/$1\n<input type="hidden" name="$sessionid_name" value="$sid">/isg;
    $c->response->output(
        HTML::StickyQuery->new->sticky(
            scalarref => \$content,
            param     => { $sessionid_name => $sid },
        )
    );
}

sub get {
    my ( $self, $c ) = @_;
    $c->request->param( $self->sessionid_name ) || undef;
}

sub sessionid_name {
    my $self = shift;
    return $self->{config}{name} || $SESSIONID;
}

1;
__END__
