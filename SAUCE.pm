package File::Find::Rule::SAUCE;

use strict;
use File::Find::Rule;
use base qw( File::Find::Rule );
use vars qw( @EXPORT $VERSION );

@EXPORT  = @File::Find::Rule::EXPORT;
$VERSION = '0.01';

use File::SAUCE;

sub File::Find::Rule::sauce {
	my $self = shift()->_force_object;

	# Procedural interface allows passing arguments as a hashref.
	my %criteria = UNIVERSAL::isa($_[0], 'HASH') ? %{$_[0]} : @_;

	$self->exec( sub {
		my $file = shift;
		
		my $info = File::SAUCE->new($file) or return;

		for my $fld (keys %criteria) {
			if ($fld eq 'comments') {

				my $comments = $info->get_comments;
				return unless $comments;

				if (ref $criteria{$fld} eq 'Regexp') {
					return unless grep($criteria{$fld}, @{$comments});
				}
				else {
					return unless grep($_ eq $criteria{$fld}, @{$comments});
				}	
			}
			elsif (ref $criteria{$fld} eq 'Regexp') {
				return unless $info->get(lc($fld)) =~ $criteria{$fld};
			}
			else {
				return unless $info->get(lc($fld)) eq $criteria{$fld};
			}
		}
		return 1;
	} );
}

1;

=pod

=head1 NAME

File::Find::Rule::SAUCE - Rule to match on title, author, etc from a file's SAUCE record

=head1 SYNOPSIS

	use File::Find::Rule::SAUCE;

	my @files = find( sauce => { author => qr/Brian/ }, in => '/ansi' );

=head1 DESCRIPTION

This module will search through a file's SAUCE metadata (using File::SAUCE) and match on the
specified fields.

=head1 METHODS

	my @files = find( sauce => { title => qr/My Ansi/ }, in => '/ansi' );

If more than one field is specified, it will only return the file if ALL of the criteria
are met. You can specify a regex (qr//) or just a string.

Matching on the comments field will search each line of comments for the requested string.

See File::SAUCE for a list of all the fields that can be matched.

=head1 BUGS

If you have any questions, comments, bug reports or feature suggestions, 
email them to Brian Cassidy <brian@alternation.net>.

=head1 CREDITS

This module was written by Brian Cassidy (http://www.alternation.net/). It borrows heavily
from File::Find::Rule::MP3Info.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the terms
of the Artistic License, distributed with Perl.

=head1 SEE ALSO

	File::SAUCE
	File::Find::Rule
	File::Find::Rule::MP3Info

=cut