package Bryar::Renderer::TT;
use 5.006;
use strict;
use warnings;
use Carp;
use Template;
our $VERSION = '1.1';

=head1 NAME

Bryar::Renderer::TT - Render a blog page with Template Toolkit

=head1 SYNOPSIS

	my ($content_type, $output) = $self->generate_html(...);

=head1 DESCRIPTION

This takes a Bryar blog, and the documents selected by the
C<Bryar::Collector>, and turns them into a page. 

You'll probably want to read a Template Toolkit tutorial before mucking
with the templates. Take a look at http://www.template-toolkit.org/

This module passes in an array called C<documents>, full of
L<Bryar::Document|Bryar::Document> objects, and a C<Bryar> object which
is most useful for calling the C<config> method on to extract things
from the L<Bryar::Config|Bryar::Config>.

=head1 METHODS

=head2 generate

    $self->generate($format, $bryar, @documents)

Returns a page from templates and documents provided by the Bryar object.

=cut

sub _tt {
    my ($class, $bryar) = @_;
    my @path = $bryar->{config}->datadir;
    unshift @path, $bryar->{config}->datadir."/".$bryar->{config}->{arguments}->{subblog} 
        if exists $bryar->{config}->{arguments}->{subblog};
        
    @path = map { $_, $_."/templates" } @path;
    return Template->new({
        INCLUDE_PATH => \@path,
	ABSOLUTE     => 1,
        EVAL_PERL    => 1,
        RELATIVE     => 1,
        PRE_CHOMP    => 1,
        POST_CHOMP   => 1,
    });
}

sub _tt_process {
    my ($class, $filename, $bryar, @documents) = @_;
    my $output;
    my $tt = $class->_tt($bryar);
    $tt->process($filename, {
        documents => \@documents,
        recent    => [$bryar->config()->collector()->collect($bryar->config())],
        archive   => [
            $bryar->config()->source()->all_but_recent($bryar->config())
        ],
        bryar     => $bryar,
    }, \$output);
    if (!$output) {
        $bryar->{config}->frontend->report_error("Template Error",
<<EOF
An error occurred while processing the templates for the blog. The
error as reported by Template Toolkit was:

<PRE>
@{[ $tt->error ]}
</PRE>
EOF
        );
    }
    # $output =~ s/\s+/ /g;
    # $output =~ s/>\s+</></g;
    return $output;
}

our %formats;

=head2 register_format

    $class->register_format($format, $filename, $content_type);

Registers a new format that Bryar is capable of producing. This can be used
both for spitting out RSS/RDF/ATOM/whatever and for skinning the blog with
alternate templates.

=cut

sub register_format {
    my ($self, $format, $filename, $content_type) = @_;
    $formats{$format} = [$filename, $content_type];
}

# display formats
__PACKAGE__->register_format( html => "template.html", "text/html" );

# TODO: put formats in a formats/ folder by default, but add a config option
# for their location.

# syndication formats (full posts)
__PACKAGE__->register_format( atom => "template.atom", "application/atom+xml" ); # "application/atom+xml" );
__PACKAGE__->register_format( xml  => "template.rss",  "application/rdf+xml");
__PACKAGE__->register_format( rss  => "template.rss",  "application/rdf+xml");
__PACKAGE__->register_format( rdf  => "template.rss",  "application/rdf+xml");
__PACKAGE__->register_format( rss2 => "template.rss2", "application/rss+xml");

# syndication formats (excerpted posts)
__PACKAGE__->register_format( atomexcerpt => "template.atomexcerpt", "application/atom+xml" );
__PACKAGE__->register_format( xmlexcerpt  => "template.rssexcerpt", "application/rdf+xml");
__PACKAGE__->register_format( rssexcerpt  => "template.rssexcerpt", "application/rdf+xml");
__PACKAGE__->register_format( rdfexcerpt  => "template.rssexcerpt", "application/rdf+xml");
__PACKAGE__->register_format( rss2excerpt => "template.rss2excerpt", "application/rss+xml");

sub generate {
    my $class = shift;
    my $format = shift;
    $_[0]->config->frontend->report_error("Unknown format",
        "Can't output a blog in format '$format', don't know what it is.")
        if !exists $formats{$format};

    my ($file, $ct) = @{$formats{$format}};
    return ($ct, $class->_tt_process($file, @_));
}

=head1 LICENSE

This module is free software, and may be distributed under the same
terms as Perl itself.

=head1 AUTHOR

Copyright (C) 2003, Simon Cozens C<simon@kasei.com>

some parts Copyright 2007 David Cantrell C<david@cantrell.org.uk>


=head1 SEE ALSO

=cut

1;
