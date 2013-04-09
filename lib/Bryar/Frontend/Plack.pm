package Bryar::Frontend::Plack;
use base 'Bryar::Frontend::Base';

use strict;
use warnings;

use Plack::Request;

=head1 NAME

Bryar::Frontend::Plack - Plack interface to Bryar

=head1 DESCRIPTION

This is a frontend to Bryar which is used when Bryar is being driven as
a Plack application.

=cut

sub new {
	my $class = shift;
	bless { @_ }, $class;
}

sub obtain_params {
	my $self = shift;
	map { $_ => $self->{req}->parameters->{$_} } $self->{req}->parameters;
}

=head2 plack_request

    $frontend->plack_request($req)

Used to pass the new Plack::Request object inside the requests loop.

=cut

sub plack_request {
	my ($self, $req) = @_;
	$self->{req} = $req;
}

# man Plack::Request
# http://advent.plackperl.org/2009/12/day-2-hello-world.html
# /usr/share/perl5/Plack/Middleware/StackTrace.pm
# /usr/share/perl5/Plack/Middleware/ContentMD5.pm
# /usr/share/perl5/Plack/Middleware/ContentLength.pm
# /usr/share/perl5/Plack/Middleware/ConditionalGET.pm
# /usr/share/perl5/Plack/Middleware/Conditional.pm

=head1 LICENSE

This module is free software, and may be distributed under the same
terms as Perl itself.

=head1 AUTHOR

Copyright (C) 2011, Marco d'Itri C<md@Linux.IT>
