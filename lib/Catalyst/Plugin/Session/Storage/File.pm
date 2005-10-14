package Catalyst::Plugin::Session::Storage::File;
use strict;
use warnings;

use base qw/Catalyst::Plugin::Session::Storage/;

use Catalyst::Exception;
use File::Spec;
use Fcntl qw/:flock/;

our $DIR     = "/tmp";
our $PREFIX  = "Catalyst-Session";
our $EXPIRES = 60 * 60;

sub new {
    my $class = shift;
    bless { config => $_[0], _data => {} }, $class;
}

sub set {
    my ( $self, $c ) = @_;
    my $sid  = $c->sessionid or return;
    my $file = $self->filepath($sid);
    my $fh = IO::File->new($file, "w")
        or Catalyst::Exception->throw(qq/Couldn't save session "$file"/);
    flock($fh, LOCK_EX);
    $fh->print( $self->serialize( $self->{_data} ) );
    $fh->close;
    $self->{_data} = {};
    $self->cleanup;
}

sub get {
    my ( $self, $sid ) = @_;
    my $file = $self->filepath($sid);
    my $fh   = IO::File->new($file);
    return $self->{_data} unless $fh;
    flock($fh, LOCK_SH);
    my $data;
    $data .= $_ while ( <$fh> );
    $fh->close;
    $self->{_data} = $self->deserialize($data);
    return $self->{_data};
}

sub filepath {
    my ( $self, $sid ) = @_;
    my $dir    = $self->{config}{storage_dir} || $DIR;
    my $prefix = $self->{config}{file_prefix} || $PREFIX;
    my $file   = sprintf "%s-%s", $prefix, $sid;
    return File::Spec->catfile($dir, $file);
}

sub cleanup {
    my $self    = shift;
    my $dir     = $self->{config}{storage_dir} || $DIR;
    my $expires = $self->{config}{expires}     || $EXPIRES;
    my $prefix  = $self->{config}{file_prefix} || $PREFIX;
    my $file    = sprintf "%s-*", $prefix;
    my $glob    = File::Spec->catfile($dir, $file);
    unlink $_ for grep { _mtime($_) < time - $expires } glob $glob;
}

sub _mtime { (stat(shift))[9] }
1;
__END__

